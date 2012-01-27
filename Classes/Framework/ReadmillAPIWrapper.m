/*
 Copyright (c) 2011 Readmill LTD
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */

#import "ReadmillAPIWrapper.h"
#import "NSString+ReadmillAdditions.h"
#import "NSURL+ReadmillURLParameters.h"
#import "NSError+ReadmillAdditions.h"
#import "NSDictionary+ReadmillAdditions.h"
#import "NSDate+ReadmillAdditions.h"
#import "JSONKit.h"
#import "ReadmillAPIWrapper+Internal.h"

@interface ReadmillAPIWrapper () 

@property (readwrite, copy) NSString *refreshToken;
@property (readwrite, copy) NSString *accessToken;
@property (readwrite, copy) NSString *authorizedRedirectURL;
@property (readwrite, copy) NSDate *accessTokenExpiryDate;
@property (nonatomic, retain) NSOperationQueue *queue;
@property (nonatomic, readwrite, retain) ReadmillAPIConfiguration *apiConfiguration;

@property (nonatomic, retain) JSONDecoder *jsonDecoder;
@end

@implementation ReadmillAPIWrapper

- (id)init 
{
    if ((self = [super init])) {
        // Initialization code here.
        queue = [[NSOperationQueue alloc] init];
        [queue setMaxConcurrentOperationCount:3];        
    }
    return self;
}

- (id)initWithAPIConfiguration:(ReadmillAPIConfiguration *)configuration 
{
    self = [self init];
    if (self) {
        NSAssert(configuration != nil, @"API Configuration is nil");
        [self setApiConfiguration:configuration];
    }
    return self;
}

- (id)initWithPropertyListRepresentation:(NSDictionary *)plist 
{    
    if ((self = [self init])) {
        [self setAuthorizedRedirectURL:[plist valueForKey:@"authorizedRedirectURL"]];        
		[self setAccessToken:[plist valueForKey:@"accessToken"]];
        [self setAccessTokenExpiryDate:[plist valueForKey:@"accessTokenExpiryDate"]];
        [self setApiConfiguration:[NSKeyedUnarchiver unarchiveObjectWithData:[plist valueForKey:@"apiConfiguration"]]];
    }
    return self;
}

- (NSDictionary *)propertyListRepresentation 
{
    NSMutableDictionary *plist = [NSMutableDictionary dictionary];
    [plist setObject:[self accessToken] 
              forKey:@"accessToken"];
    [plist setObject:[self authorizedRedirectURL] 
              forKey:@"authorizedRedirectURL"];
    [plist setObject:[NSKeyedArchiver archivedDataWithRootObject:[self apiConfiguration]] 
              forKey:@"apiConfiguration"];

    [plist setObject:[self accessTokenExpiryDate] forKey:@"accessTokenExpiryDate"];
    
    return plist;
}

@synthesize refreshToken;
@synthesize accessToken;
@synthesize authorizedRedirectURL;
@synthesize accessTokenExpiryDate;
@synthesize apiConfiguration;
@synthesize jsonDecoder;
@synthesize queue;

- (void)dealloc 
{
    [self setAccessToken:nil];
    [self setAuthorizedRedirectURL:nil];
    [self setAccessTokenExpiryDate:nil];
    [self setApiConfiguration:nil];
    [self setJsonDecoder:nil];
    [self setQueue:nil];
    [super dealloc];
}

#pragma mark -
#pragma mark API endpoints

- (NSString *)apiEndPoint 
{
    return [[apiConfiguration apiBaseURL] absoluteString];
}
- (NSString *)booksEndpoint 
{
    return [NSString stringWithFormat:@"%@books", [self apiEndPoint]];
}
- (NSString *)readingsEndpoint 
{
    return [NSString stringWithFormat:@"%@readings", [self apiEndPoint]];
}
- (NSString *)usersEndpoint 
{
    return [NSString stringWithFormat:@"%@users", [self apiEndPoint]];
}
- (NSString *)highlightsEndpoint 
{
    return [NSString stringWithFormat:@"%@highlights", [self apiEndPoint]];
}

#pragma mark -
#pragma mark OAuth

- (void)authorizeWithAuthorizationCode:(NSString *)authCode 
                       fromRedirectURL:(NSString *)redirectURLString
                     completionHandler:(ReadmillAPICompletionHandler)completionHandler
{
    [self setAuthorizedRedirectURL:redirectURLString];
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                [[self apiConfiguration] clientID], kReadmillAPIClientIdKey, 
                                [[self apiConfiguration] clientSecret], kReadmillAPIClientSecretKey,
                                authCode, @"code",
                                redirectURLString, @"redirect_uri",
                                @"authorization_code", @"grant_type", nil];

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[[self apiConfiguration] accessTokenURL]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                       timeoutInterval:kTimeoutInterval];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:[parameters JSONData]];

    [self startPreparedRequest:request completion:^(NSDictionary *response, NSError *error) {
        if (response != nil) {
            NSTimeInterval accessTokenTTL = [[response valueForKey:@"expires_in"] doubleValue];        
            [self willChangeValueForKey:@"propertyListRepresentation"];
            [self setAccessTokenExpiryDate:[[NSDate date] dateByAddingTimeInterval:accessTokenTTL]];
            [self setAccessToken:[response valueForKey:@"access_token"]];
            [self didChangeValueForKey:@"propertyListRepresentation"];
        }            
        completionHandler(response, error);
    }];
}

- (NSURL *)clientAuthorizationURLWithRedirectURLString:(NSString *)redirect 
{    
    NSString *baseURL = [[[self apiConfiguration] authURL] absoluteString];
    NSString *urlString = [NSString stringWithFormat:@"%@oauth/authorize?response_type=code&client_id=%@&scope=non-expiring", 
                           baseURL, 
                           [[self apiConfiguration] clientID]];
    
    if ([redirect length] > 0) {
        // Need to urlEncode the URL string
        urlString = [NSString stringWithFormat:@"%@&redirect_uri=%@", urlString, [redirect urlEncodedString]];
    }
    return [NSURL URLWithString:urlString];
}

#pragma mark -
#pragma mark API Methods

#pragma mark - Readings

- (void)createReadingWithBookId:(ReadmillBookId)bookId 
                          state:(ReadmillReadingState)readingState 
                      isPrivate:(BOOL)isPrivate 
              completionHandler:(ReadmillAPICompletionHandler)completionHandler 
{    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    [parameters setValue:[NSNumber numberWithInteger:readingState] 
                  forKey:kReadmillAPIReadingStateKey];
    [parameters setValue:[NSNumber numberWithInteger:isPrivate ? 1 : 0]
                  forKey:kReadmillAPIReadingPrivateKey];
    [parameters setValue:[[self apiConfiguration] clientID] 
                  forKey:kReadmillAPIClientIdKey];
    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%d/readings", 
                                       [self booksEndpoint], 
                                       bookId]];

    [self sendPostRequestToURL:URL
                withParameters:[NSDictionary dictionaryWithObject:parameters forKey:kReadmillAPIReadingKey]
    shouldBeCalledUnauthorized:NO
             completionHandler:completionHandler];
}

- (void)updateReadingWithId:(ReadmillReadingId)readingId 
                  withState:(ReadmillReadingState)readingState
                  isPrivate:(BOOL)isPrivate 
              closingRemark:(NSString *)remark 
          completionHandler:(ReadmillAPICompletionHandler)completionHandler 
{    
    NSMutableDictionary *readingParameters = [[NSMutableDictionary alloc] init];

    [readingParameters setValue:[NSNumber numberWithInteger:readingState] 
                         forKey:kReadmillAPIReadingStateKey];
    [readingParameters setValue:[NSNumber numberWithInteger:isPrivate ? 1 : 0] 
                         forKey:kReadmillAPIReadingPrivateKey];
    [readingParameters setValue:[[self apiConfiguration] clientID]
                         forKey:kReadmillAPIClientIdKey];
    
    if ([remark length] > 0) {
        [readingParameters setValue:remark 
                             forKey:kReadmillAPIReadingClosingRemarkKey];
    }

    NSDictionary *parameters = [NSDictionary dictionaryWithObject:readingParameters 
                                                           forKey:kReadmillAPIReadingKey];
    [readingParameters release];
    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%d", 
                                       [self readingsEndpoint], 
                                       readingId]];

    [self sendPutRequestToURL:URL 
               withParameters:parameters 
   shouldBeCalledUnauthorized:NO 
            completionHandler:completionHandler];
}

- (void)publicReadingsForUserWithId:(ReadmillUserId)userId completionHandler:(ReadmillAPICompletionHandler)completionHandler 
{
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%d/readings", 
                                                        [self usersEndpoint], 
                                                            userId]];
    [self sendGetRequestToURL:URL   
               withParameters:nil
   shouldBeCalledUnauthorized:YES
            completionHandler:completionHandler];
}

- (void)readingsForUserWithId:(ReadmillUserId)userId completionHandler:(ReadmillAPICompletionHandler)completionHandler
{
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%d/readings", 
                                       [self usersEndpoint], 
                                       userId]];
    [self sendGetRequestToURL:URL   
               withParameters:nil
   shouldBeCalledUnauthorized:NO
            completionHandler:completionHandler];
}

- (void)readingWithId:(ReadmillReadingId)readingId completionHandler:(ReadmillAPICompletionHandler)completionHandler 
{    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%d", 
                                       [self readingsEndpoint], 
                                       readingId]];
    [self sendGetRequestToURL:URL 
               withParameters:nil
   shouldBeCalledUnauthorized:NO
            completionHandler:completionHandler];
}

- (void)readingWithURLString:(NSString *)urlString completionHandler:(ReadmillAPICompletionHandler)completionHandler 
{    
    NSError *error = nil;
    NSURLRequest *request = [self getRequestWithURL:[NSURL URLWithString:urlString] 
                                         parameters:nil
                         shouldBeCalledUnauthorized:NO 
                                              error:&error];
    
    if (request) {
        [self startPreparedRequest:request completion:completionHandler];
    } else {
        completionHandler(nil, error);
    }
}

- (void)readingsForBookWithId:(ReadmillBookId)bookId completionHandler:(ReadmillAPICompletionHandler)completionHandler 
{
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%d/readings", 
                                       [self booksEndpoint], 
                                       bookId]];
    [self sendGetRequestToURL:URL 
               withParameters:nil
   shouldBeCalledUnauthorized:NO
            completionHandler:completionHandler];
}

- (void)readingsFilteredByFriendsForBookWithId:(ReadmillBookId)bookId 
                             completionHandler:(ReadmillAPICompletionHandler)completionHandler
{
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%d/readings", 
                                       [self booksEndpoint], 
                                       bookId]];
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                kReadmillAPIFilterByFollowings, kReadmillAPIFilterKey, // Filter by followings
                                [NSNumber numberWithInteger:1], @"highlights_count[from]", nil]; // At least 1 highlight
    
    [self sendGetRequestToURL:URL 
               withParameters:parameters
   shouldBeCalledUnauthorized:NO
                  cachePolicy:NSURLRequestReturnCacheDataElseLoad
            completionHandler:completionHandler];
}

- (void)readingsOrderedByPopularForBookWithId:(ReadmillBookId)bookId 
                            completionHandler:(ReadmillAPICompletionHandler)completionHandler
{
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%d/readings", 
                                       [self booksEndpoint], 
                                       bookId]];
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                kReadmillAPIOrderByPopular, kReadmillAPIOrderKey, // Order by popularity (based on comments > highlights > followers)
                                [NSNumber numberWithInteger:1], @"highlights_count[from]", nil]; // At least 1 highlight

    [self sendGetRequestToURL:URL 
               withParameters:parameters
   shouldBeCalledUnauthorized:YES
                  cachePolicy:NSURLRequestReturnCacheDataElseLoad
            completionHandler:completionHandler];
}
#pragma mark - 
#pragma mark - Book

- (void)booksFromSearch:(NSString *)searchString completionHandler:(ReadmillAPICompletionHandler)completion
{
    return [self sendGetRequestToURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", [self booksEndpoint]]] 
                      withParameters:[NSDictionary dictionaryWithObject:searchString forKey:@"q"]
          shouldBeCalledUnauthorized:NO 
                   completionHandler:completion];    
}

- (void)bookWithId:(ReadmillBookId)bookId completionHandler:(ReadmillAPICompletionHandler)completion
{    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%d", [self booksEndpoint], bookId]];
    [self sendGetRequestToURL:url
               withParameters:nil
   shouldBeCalledUnauthorized:YES 
            completionHandler:completion];
}

- (void)bookMatchingTitle:(NSString *)searchString completionHandler:(ReadmillAPICompletionHandler)completion
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/match", [self booksEndpoint]]];
    [self sendGetRequestToURL:url
               withParameters:[NSDictionary dictionaryWithObject:searchString forKey:@"q[title]"]
   shouldBeCalledUnauthorized:YES
            completionHandler:completion];
}

- (void)bookMatchingISBN:(NSString *)isbn 
       completionHandler:(ReadmillAPICompletionHandler)completion
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/match", [self booksEndpoint]]];
    [self sendGetRequestToURL:url
               withParameters:[NSDictionary dictionaryWithObject:isbn forKey:@"q[isbn]"]
   shouldBeCalledUnauthorized:NO 
            completionHandler:completion];
}

- (void)addBookWithTitle:(NSString *)bookTitle 
                  author:(NSString *)bookAuthor 
                    isbn:(NSString *)bookIsbn 
       completionHandler:(ReadmillAPICompletionHandler)completionHandler
{
    NSMutableDictionary *bookParameters = [[NSMutableDictionary alloc] init];
    
    if ([bookTitle length] > 0) {
        [bookParameters setValue:bookTitle 
                          forKey:kReadmillAPIBookTitleKey];
    }
    
    if ([bookAuthor length] > 0) {
        [bookParameters setValue:bookAuthor 
                          forKey:kReadmillAPIBookAuthorKey];
    }
    
    if ([bookIsbn length] > 0) {
        [bookParameters setValue:bookIsbn 
                          forKey:kReadmillAPIBookISBNKey];
    }
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObject:bookParameters 
                                                           forKey:kReadmillAPIBookKey];
    [bookParameters release];
    
    [self sendPostRequestToURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", [self booksEndpoint]]]
                withParameters:parameters
    shouldBeCalledUnauthorized:NO
             completionHandler:completionHandler];    
}

//Pings     
#pragma mark - Pings

- (void)pingReadingWithId:(ReadmillReadingId)readingId 
             withProgress:(ReadmillReadingProgress)progress 
        sessionIdentifier:(NSString *)sessionId
                 duration:(ReadmillPingDuration)duration
           occurrenceTime:(NSDate *)occurrenceTime
                 latitude:(CLLocationDegrees)latitude
                longitude:(CLLocationDegrees)longitude
        completionHandler:(ReadmillAPICompletionHandler)completionHandler 
{
    NSMutableDictionary *pingParameters = [[NSMutableDictionary alloc] init];
    
    [pingParameters setValue:[NSNumber numberWithFloat:progress]
                      forKey:kReadmillAPIPingProgressKey];
    [pingParameters setValue:[NSNumber numberWithUnsignedInteger:duration] 
                      forKey:kReadmillAPIPingDurationKey];
    
    if ([sessionId length] > 0) {
        [pingParameters setValue:sessionId 
                          forKey:kReadmillAPIPingIdentifierKey];
    }
    
    if (occurrenceTime == nil) {
        occurrenceTime = [NSDate date];
    }
    
    // 2011-01-06T11:47:14Z
    NSString *dateString = [occurrenceTime stringWithRFC3339Format];
    [pingParameters setValue:dateString 
                      forKey:kReadmillAPIPingOccurredAtKey];

    if (!(longitude == 0.0 && latitude == 0.0)) {
        // Do not send gps values if lat/lng were not specified.
        [pingParameters setValue:[NSNumber numberWithDouble:latitude] 
                          forKey:kReadmillAPIPingLatitudeKey];
        [pingParameters setValue:[NSNumber numberWithDouble:longitude] 
                          forKey:kReadmillAPIPingLongitudeKey];
    }

    NSDictionary *parameters = [NSDictionary dictionaryWithObject:pingParameters
                                                           forKey:@"ping"];
    [pingParameters release];
    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%d/pings", 
                                       [self readingsEndpoint], 
                                       readingId]];
    
    [self sendPostRequestToURL:URL 
                withParameters:parameters
    shouldBeCalledUnauthorized:NO
             completionHandler:completionHandler];
}
- (void)pingReadingWithId:(ReadmillReadingId)readingId 
             withProgress:(ReadmillReadingProgress)progress 
        sessionIdentifier:(NSString *)sessionId
                 duration:(ReadmillPingDuration)duration
           occurrenceTime:(NSDate *)occurrenceTime
        completionHandler:(ReadmillAPICompletionHandler)completionHandler 
{    
    [self pingReadingWithId:readingId 
               withProgress:progress 
          sessionIdentifier:sessionId 
                   duration:duration 
             occurrenceTime:occurrenceTime 
                   latitude:0.0
                  longitude:0.0 
          completionHandler:completionHandler];
}


#pragma mark -
#pragma mark - Highlights

- (void)createHighlightForReadingWithId:(ReadmillReadingId)readingId 
                        highlightedText:(NSString *)highlightedText
                               locators:(NSDictionary *)locators
                               position:(ReadmillReadingProgress)position
                          highlightedAt:(NSDate *)highlightedAt 
                                comment:(NSString *)comment
                            connections:(NSArray *)connections
                      completionHandler:(ReadmillAPICompletionHandler)completionHandler
{       
    NSAssert(0 < readingId, @"readingId: %d is invalid.", readingId);
    NSAssert(highlightedText != nil && [highlightedText length], @"Locators can't be nil.");
    NSAssert(locators != nil && [locators count], @"Locators can't be nil.");

    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    
    NSMutableDictionary *highlightParameters = [[NSMutableDictionary alloc] init];
    [highlightParameters setValue:locators 
                           forKey:kReadmillAPIHighlightLocatorsKey];
    [highlightParameters setValue:highlightedText
                           forKey:kReadmillAPIHighlightContentKey];
    [highlightParameters setValue:[NSNumber numberWithFloat:position] 
                           forKey:kReadmillAPIHighlightPositionKey];
        
    if (comment != nil && 0 < [comment length]) {
        [parameters setValue:comment forKey:kReadmillAPIHighlightCommentKey];
    }
    
    if (connections != nil) {
        // Create a list of JSON objects (i.e array of NSDicionaries
        NSMutableArray *connectionsArray = [NSMutableArray array];
        for (id connection in connections) {
            [connectionsArray addObject:[NSDictionary dictionaryWithObject:connection 
                                                                    forKey:@"id"]];
        }
        [parameters setValue:connectionsArray forKey:kReadmillAPIHighlightPostToKey];
    }
    
    if (!highlightedAt) {
        highlightedAt = [NSDate date];
    }
    // 2011-01-06T11:47:14Z
    [highlightParameters setValue:[highlightedAt stringWithRFC3339Format] 
                           forKey:kReadmillAPIHighlightHighlightedAtKey];
    [parameters setObject:highlightParameters forKey:kReadmillAPIHighlightKey];
    [highlightParameters release];
    
    NSURL *highlightsURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%d/highlights", 
                                                 [self readingsEndpoint], readingId]];
    
    [self sendPostRequestToURL:highlightsURL 
                withParameters:[parameters autorelease]
    shouldBeCalledUnauthorized:NO
             completionHandler:completionHandler];
}

- (void)highlightsForReadingWithId:(ReadmillReadingId)readingId 
                 completionHandler:(ReadmillAPICompletionHandler)completionHandler 
{    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%d/highlights", 
                                       [self readingsEndpoint], 
                                       readingId]];

    [self sendGetRequestToURL:URL 
               withParameters:nil
   shouldBeCalledUnauthorized:NO
            completionHandler:completionHandler];
}

- (void)deleteHighlightWithId:(NSUInteger)highlightId 
            completionHandler:(ReadmillAPICompletionHandler)completionHandler
{
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%d", 
                                       [self highlightsEndpoint], 
                                       highlightId]];
    
    [self sendDeleteRequestToURL:URL
                  withParameters:nil
               completionHandler:completionHandler];
}

#pragma mark - Highlight comments

- (void)createCommentForHighlightWithId:(ReadmillHighlightId)highlightId 
                                comment:(NSString *)comment
                            commentedAt:(NSDate *)date
                      completionHandler:(ReadmillAPICompletionHandler)completionHandler 
{
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%d/comments", 
                                       [self highlightsEndpoint], 
                                       highlightId]];
    
    NSDictionary *commentDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                       comment, kReadmillAPICommentContentKey,
                                       [date stringWithRFC3339Format], kReadmillAPICommentPostedAtKey, nil];

    NSDictionary *parameters = [NSDictionary dictionaryWithObject:commentDictionary                         
                                                           forKey:@"comment"];
    
    [self sendPostRequestToURL:URL 
                withParameters:parameters
    shouldBeCalledUnauthorized:NO 
             completionHandler:completionHandler];
}

- (void)commentsForHighlightWithId:(ReadmillHighlightId)highlightId 
                 completionHandler:(ReadmillAPICompletionHandler)completionHandler 
{
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%d/comments", 
                                       [self highlightsEndpoint], 
                                       highlightId]];
    
    [self sendGetRequestToURL:URL 
               withParameters:nil
   shouldBeCalledUnauthorized:NO
            completionHandler:completionHandler];
}


#pragma mark
#pragma Connections

- (void)connectionsForCurrentUserWithCompletionHandler:(ReadmillAPICompletionHandler)completionHandler 
{    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@me/connections", [self apiEndPoint]]];
    [self sendGetRequestToURL:URL 
               withParameters:nil
   shouldBeCalledUnauthorized:NO 
            completionHandler:completionHandler];
}


#pragma mark
#pragma mark - Users

- (void)userWithId:(ReadmillUserId)userId 
 completionHandler:(ReadmillAPICompletionHandler)completionHandler
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@users/%d", [self apiEndPoint], userId]];
    [self sendGetRequestToURL:url 
               withParameters:nil
   shouldBeCalledUnauthorized:YES
            completionHandler:completionHandler];
}

- (NSURL *)urlForCurrentUser
{
    NSURL *baseURL = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@me", [self apiEndPoint]]];
    NSDictionary *parameters = [[NSDictionary alloc] initWithObjectsAndKeys:
                                [self accessToken], kReadmillAPIAccessTokenKey,
                                [[[self apiConfiguration] clientID] urlEncodedString], kReadmillAPIClientIdKey, nil];
    NSURL *finalURL = [baseURL URLByAddingParameters:parameters];
    [baseURL release];
    [parameters release];
    
    return finalURL;
}
- (NSDictionary *)currentUser:(NSError **)error 
{    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[self urlForCurrentUser]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                       timeoutInterval:kTimeoutInterval];
    [request setHTTPMethod:@"GET"];
        
    return [self sendPreparedRequest:request error:error];
}

- (void)currentUserWithCompletionHandler:(ReadmillAPICompletionHandler)completionHandler 
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[self urlForCurrentUser]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                       timeoutInterval:kTimeoutInterval];
    [request setHTTPMethod:@"GET"];
    
    [self startPreparedRequest:request completion:completionHandler];
}


#pragma mark -
#pragma mark UI URLs

- (NSURL *)URLForConnectingBookWithISBN:(NSString *)ISBN 
                                  title:(NSString *)title 
                                 author:(NSString *)author 
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setValue:ISBN forKey:@"isbn"];
    [parameters setValue:title forKey:@"title"];
    [parameters setValue:author forKey:@"author"];
    [parameters setValue:[[self apiConfiguration] clientID] forKey:kReadmillAPIClientIdKey];
    [parameters setValue:[self accessToken] forKey:kReadmillAPIAccessTokenKey];
    
    NSURL *baseURL = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@ui/#!/connect/book", 
                                                    [self apiEndPoint]]];
    NSURL *URL = [baseURL URLByAddingParameters:parameters];
    [baseURL release];
    [parameters release];
    
    return URL;
}

- (NSURL *)URLForViewingReadingWithId:(ReadmillReadingId)readingId 
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setValue:[[self apiConfiguration] clientID] forKey:kReadmillAPIClientIdKey];
    [parameters setValue:[self accessToken] forKey:kReadmillAPIAccessTokenKey];
    
    NSURL *baseURL = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@ui/#!/view/reading/%d", 
                                                    [self apiEndPoint], 
                                                    readingId]];
    
    NSURL *URL = [baseURL URLByAddingParameters:parameters];
    [parameters release];
    [baseURL release];
    
    return URL;
}

#pragma mark -
#pragma mark - Prepared requests

- (void)sendRequestToURL:(NSURL *)url
       completionHandler:(ReadmillAPICompletionHandler)completionHandler 
{
    [self sendGetRequestToURL:url 
               withParameters:nil 
   shouldBeCalledUnauthorized:NO 
            completionHandler:completionHandler];
}

#pragma mark -
#pragma mark - Cancel operations

- (void)cancelAllOperations 
{
    [queue cancelAllOperations];
}

#pragma mark - 
#pragma mark - Deprecated

- (void)createHighlightForReadingWithId:(ReadmillReadingId)readingId 
                        highlightedText:(NSString *)highlightedText
                                    pre:(NSString *)pre
                                   post:(NSString *)post
                    approximatePosition:(ReadmillReadingProgress)position
                          highlightedAt:(NSDate *)highlightedAt
                                comment:(NSString *)comment
                            connections:(NSArray *)connectionsOrNil
                      completionHandler:(ReadmillAPICompletionHandler)completionHandler 
{    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    
    NSMutableDictionary *highlightParameters = [[NSMutableDictionary alloc] init];
    [highlightParameters setValue:highlightedText
                           forKey:kReadmillAPIHighlightContentKey];
    [highlightParameters setValue:[NSNumber numberWithFloat:position] 
                           forKey:kReadmillAPIHighlightPositionKey];
    [highlightParameters setValue:pre
                           forKey:kReadmillAPIHighlightPreKey];
    [highlightParameters setValue:post
                           forKey:kReadmillAPIHighlightPostKey];
    
    if (comment != nil && [comment length] > 0) {
        [parameters setValue:comment forKey:kReadmillAPIHighlightCommentKey];
    }
    
    if (connectionsOrNil != nil) {
        // Create a list of JSON objects (i.e array of NSDicionaries
        NSMutableArray *connectionsArray = [NSMutableArray array];
        for (id connection in connectionsOrNil) {
            [connectionsArray addObject:[NSDictionary dictionaryWithObject:connection 
                                                                    forKey:@"id"]];
        }
        [parameters setValue:connectionsArray forKey:kReadmillAPIHighlightPostToKey];
    }
    
    if (!highlightedAt) {
        highlightedAt = [NSDate date];
    }
    // 2011-01-06T11:47:14Z
    [highlightParameters setValue:[highlightedAt stringWithRFC3339Format] 
                           forKey:kReadmillAPIHighlightHighlightedAtKey];
    [parameters setObject:highlightParameters forKey:@"highlight"];
    [highlightParameters release];
    
    NSURL *highlightsURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%d/highlights", 
                                                 [self readingsEndpoint], readingId]];
    
    [self sendPostRequestToURL:highlightsURL 
                withParameters:[parameters autorelease]
    shouldBeCalledUnauthorized:NO
             completionHandler:completionHandler];
}

@end


