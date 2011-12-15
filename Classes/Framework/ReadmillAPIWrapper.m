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
#import "ReadmillURLConnection.h"
#import "JSONKit.h"

static NSString *const kReadmillAPIHeaderKey = @"X-Readmill-API";

#define kTimeoutInterval 30.0

@interface ReadmillAPIWrapper () {
    JSONDecoder *jsonDecoder;
}

- (id)sendPreparedRequest:(NSURLRequest *)request error:(NSError **)error;

- (NSURLRequest *)putRequestWithURL:(NSURL *)url 
                         parameters:(NSDictionary *)parameters
         shouldBeCalledUnauthorized:(BOOL)allowUnauthed
                              error:(NSError **)error;
- (NSURLRequest *)postRequestWithURL:(NSURL *)url
                          parameters:(NSDictionary *)parameters
          shouldBeCalledUnauthorized:(BOOL)allowUnauthed
                               error:(NSError **)error;

- (NSURLRequest *)getRequestWithURL:(NSURL *)url
                         parameters:(NSDictionary *)parameters 
         shouldBeCalledUnauthorized:(BOOL)allowUnauthed 
                        cachePolicy:(NSURLRequestCachePolicy)cachePolicy
                              error:(NSError **)error;

- (NSURLRequest *)getRequestWithURL:(NSURL *)url
                         parameters:(NSDictionary *)parameters 
         shouldBeCalledUnauthorized:(BOOL)allowUnauthed
                              error:(NSError **)error;

- (NSURLRequest *)bodyRequestWithURL:(NSURL *)url
                          httpMethod:(NSString *)httpMethod 
                          parameters:(NSDictionary *)parameters
          shouldBeCalledUnauthorized:(BOOL)allowUnauthed
                               error:(NSError **)error;

- (void)sendPutRequestToURL:(NSURL *)url
             withParameters:(NSDictionary *)parameters 
 shouldBeCalledUnauthorized:(BOOL)allowUnauthed
          completionHandler:(ReadmillAPICompletionHandler)completionHandler;

- (void)sendPostRequestToURL:(NSURL *)url
              withParameters:(NSDictionary *)parameters
  shouldBeCalledUnauthorized:(BOOL)allowUnauthed
           completionHandler:(ReadmillAPICompletionHandler)completionHandler;

- (void)sendGetRequestToURL:(NSURL *)url
             withParameters:(NSDictionary *)parameters 
 shouldBeCalledUnauthorized:(BOOL)allowUnauthed
                cachePolicy:(NSURLRequestCachePolicy)cachePolicy
          completionHandler:(ReadmillAPICompletionHandler)completionHandler;

- (void)sendGetRequestToURL:(NSURL *)url
             withParameters:(NSDictionary *)parameters 
 shouldBeCalledUnauthorized:(BOOL)allowUnauthed
          completionHandler:(ReadmillAPICompletionHandler)completionHandler;

- (void)sendBodyRequestToURL:(NSURL *)url 
                  httpMethod:(NSString *)httpMethod
              withParameters:(NSDictionary *)parameters 
  shouldBeCalledUnauthorized:(BOOL)allowUnauthed
           completionHandler:(ReadmillAPICompletionHandler)completionHandler;

- (void)startPreparedRequest:(NSURLRequest *)request completion:(ReadmillAPICompletionHandler)completionBlock;

- (BOOL)refreshAccessToken:(NSError **)error DEPRECATED_ATTRIBUTE;

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
        
        jsonDecoder = [[JSONDecoder alloc] init];
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
        
        // Deprecated in favor of non-expiring tokens
        NSString *aRefreshToken = [plist valueForKey:@"refreshToken"];
        if (aRefreshToken) {
            [self setRefreshToken:aRefreshToken];
        }
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
    NSString *theRefreshToken = [self refreshToken];
    [plist setObject:[self accessTokenExpiryDate] forKey:@"accessTokenExpiryDate"];
    
    // Deprecated in favor of non-expiring tokens
    if (theRefreshToken) {
        [plist setObject:theRefreshToken forKey:@"refreshToken"];
    }
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
    [self setRefreshToken:nil];
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

- (BOOL)authenticateWithParameters:(NSDictionary *)parameters error:(NSError **)error 
{
    @synchronized (self) {
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[[self apiConfiguration] accessTokenURL]
                                                               cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                           timeoutInterval:kTimeoutInterval];
        
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:[parameters JSONData]];
        
        NSDictionary *response = [self sendPreparedRequest:request 
                                                     error:error];
        if (response != nil) {
            NSTimeInterval accessTokenTTL = [[response valueForKey:@"expires_in"] doubleValue];        
            [self willChangeValueForKey:@"propertyListRepresentation"];
            [self setAccessTokenExpiryDate:[[NSDate date] dateByAddingTimeInterval:accessTokenTTL]];
            NSString *aRefreshToken = [response valueForKey:@"refresh_token"];
            if (aRefreshToken) {
                [self setRefreshToken:aRefreshToken];
            }
            [self setAccessToken:[response valueForKey:@"access_token"]];
            [self didChangeValueForKey:@"propertyListRepresentation"];
            return YES;
        } 
        
        // Response was nil
        return NO;
    }
}

- (BOOL)authorizeWithAuthorizationCode:(NSString *)authCode fromRedirectURL:(NSString *)redirectURLString error:(NSError **)error 
{
    [self setAuthorizedRedirectURL:redirectURLString];
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                [[self apiConfiguration] clientID], kReadmillAPIClientIdKey, 
                                [[self apiConfiguration] clientSecret], kReadmillAPIClientSecretKey,
                                authCode, @"code",
                                redirectURLString, @"redirect_uri",
                                @"authorization_code", @"grant_type", nil];
    
    return [self authenticateWithParameters:parameters error:error];
}

- (BOOL)refreshAccessToken:(NSError **)error 
{
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                [[self apiConfiguration] clientID], kReadmillAPIClientIdKey, 
                                [[self apiConfiguration] clientSecret], kReadmillAPIClientSecretKey,
                                [self authorizedRedirectURL], @"redirect_uri",
                                [self refreshToken], @"refresh_token",
                                @"refresh_token", @"grant_type", nil];
    
    return [self authenticateWithParameters:parameters error:error];
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

- (BOOL)ensureAccessTokenIsCurrent:(NSError **)error 
{
    if ([self accessTokenExpiryDate] == nil || [(NSDate *)[NSDate date] compare:[self accessTokenExpiryDate]] == NSOrderedDescending) {
        return [self refreshAccessToken:error];
    } else {
        return YES;
    }
}


#pragma mark -
#pragma mark API Methods

#pragma mark - Readings

- (void)createReadingWithBookId:(ReadmillBookId)bookId state:(ReadmillReadingState)readingState private:(BOOL)isPrivate 
              completionHandler:(ReadmillAPICompletionHandler)completionHandler 
{    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    [parameters setValue:[NSNumber numberWithInteger:readingState] forKey:kReadmillAPIReadingStateKey];
    [parameters setValue:[NSNumber numberWithInteger:isPrivate ? 1 : 0] forKey:kReadmillAPIReadingPrivateKey];
    [parameters setValue:[[self apiConfiguration] clientID] forKey:kReadmillAPIClientIdKey];
    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%d/readings", [self booksEndpoint], bookId]];
    [self sendPostRequestToURL:URL
                withParameters:parameters
    shouldBeCalledUnauthorized:NO
             completionHandler:completionHandler];
}

- (void)updateReadingWithId:(ReadmillReadingId)readingId 
                  withState:(ReadmillReadingState)readingState
                    private:(BOOL)isPrivate 
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
	if (![self ensureAccessTokenIsCurrent:error]) {
        return nil;
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[self urlForCurrentUser]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                       timeoutInterval:kTimeoutInterval];
    [request setHTTPMethod:@"GET"];
        
    return [self sendPreparedRequest:request error:error];
}

- (void)currentUserWithCompletionHandler:(ReadmillAPICompletionHandler)completionHandler 
{
    NSError *error = nil;
    if (![self ensureAccessTokenIsCurrent:&error]) {
        
        // Failed, fail completion block
        completionHandler(nil, error);
        
    } else {

        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[self urlForCurrentUser]
                                                               cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                           timeoutInterval:kTimeoutInterval];
        [request setHTTPMethod:@"GET"];
        
        [self startPreparedRequest:request completion:completionHandler];        
    }
}


#pragma mark -
#pragma mark UI URLs

- (NSURL *)URLForConnectingBookWithISBN:(NSString *)ISBN 
                                  title:(NSString *)title 
                                 author:(NSString *)author 
{
    if (![self ensureAccessTokenIsCurrent:nil]) {
        return nil;
    }
 
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
    if (![self ensureAccessTokenIsCurrent:nil]) {
        return nil;
    }
    
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
#pragma mark Creating requests

- (NSURLRequest *)getRequestWithURL:(NSURL *)url 
                         parameters:(NSDictionary *)parameters 
         shouldBeCalledUnauthorized:(BOOL)calledUnauthorized 
                        cachePolicy:(NSURLRequestCachePolicy)cachePolicy
                              error:(NSError **)error 
{    
    if (![self ensureAccessTokenIsCurrent:error]) {
        if (!calledUnauthorized) {
            return nil;
        }
    }
	
    NSMutableDictionary *finalParameters = [[NSMutableDictionary alloc] initWithDictionary:parameters];
    
    if ([[self accessToken] length] > 0 && !calledUnauthorized) {
        [finalParameters setObject:[self accessToken] 
                            forKey:kReadmillAPIAccessTokenKey];
    }
    
    [finalParameters setObject:[[self apiConfiguration] clientID] 
                        forKey:kReadmillAPIClientIdKey];    

    NSURL *finalURL = [url URLByAddingParameters:finalParameters];
    [finalParameters release];
        
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:finalURL
                                                                cachePolicy:cachePolicy
                                                            timeoutInterval:kTimeoutInterval];
    
	[request setHTTPMethod:@"GET"];
    [request setValue:@"application/json" forHTTPHeaderField:@"accept"];
    [request setTimeoutInterval:kTimeoutInterval];
    return [request autorelease];
}

- (NSURLRequest *)getRequestWithURL:(NSURL *)url 
                         parameters:(NSDictionary *)parameters
         shouldBeCalledUnauthorized:(BOOL)allowUnauthed
                              error:(NSError **)error
{
    return [self getRequestWithURL:url 
                        parameters:parameters
        shouldBeCalledUnauthorized:allowUnauthed 
                       cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                             error:error];
}

- (NSURLRequest *)putRequestWithURL:(NSURL *)url 
                         parameters:(NSDictionary *)parameters
         shouldBeCalledUnauthorized:(BOOL)allowUnauthed
                              error:(NSError **)error 
{
    return [self bodyRequestWithURL:url 
                         httpMethod:@"PUT"
                         parameters:parameters
         shouldBeCalledUnauthorized:allowUnauthed
                              error:error];
}

- (NSURLRequest *)postRequestWithURL:(NSURL *)url
                          parameters:(NSDictionary *)parameters
          shouldBeCalledUnauthorized:(BOOL)allowUnauthed
                               error:(NSError **)error 
{
    return [self bodyRequestWithURL:url
                         httpMethod:@"POST"
                         parameters:parameters 
         shouldBeCalledUnauthorized:allowUnauthed
                              error:error];
}

- (NSURLRequest *)bodyRequestWithURL:(NSURL *)url 
                          httpMethod:(NSString *)httpMethod
                          parameters:(NSDictionary *)parameters
          shouldBeCalledUnauthorized:(BOOL)allowUnauthed
                               error:(NSError **)error 
{    
    if (![self ensureAccessTokenIsCurrent:error]) {
        if (!allowUnauthed) {
            return nil;
        }
    }
	
    NSMutableDictionary *finalParameters = [[NSMutableDictionary alloc] initWithDictionary:parameters];
    
    if ([[self accessToken] length] > 0 && !allowUnauthed) {
        [finalParameters setObject:[self accessToken] 
                            forKey:kReadmillAPIAccessTokenKey];
    }
    
    [finalParameters setObject:[[self apiConfiguration] clientID] 
                        forKey:kReadmillAPIClientIdKey];
    
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
	[request setHTTPMethod:httpMethod];
	[request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
	[request setHTTPBody:[finalParameters JSONData]];
    [request setValue:@"application/json" forHTTPHeaderField:@"accept"];
    [request setTimeoutInterval:kTimeoutInterval];
    [finalParameters release];
    
    return [request autorelease];
}

#pragma mark -
#pragma mark - Sending requests

- (void)sendRequestToURL:(NSURL *)url
       completionHandler:(ReadmillAPICompletionHandler)completionHandler 
{
    [self sendGetRequestToURL:url 
               withParameters:nil 
   shouldBeCalledUnauthorized:NO 
            completionHandler:completionHandler];
}

- (void)sendGetRequestToURL:(NSURL *)url
             withParameters:(NSDictionary *)parameters  
 shouldBeCalledUnauthorized:(BOOL)allowUnauthed
                cachePolicy:(NSURLRequestCachePolicy)cachePolicy
          completionHandler:(ReadmillAPICompletionHandler)completionHandler 
{    
    NSError *error = nil;
    NSURLRequest *request = [self getRequestWithURL:url 
                                         parameters:parameters 
                         shouldBeCalledUnauthorized:allowUnauthed
                                        cachePolicy:cachePolicy
                                              error:&error];
    
    if (request) {
        [self startPreparedRequest:request 
                        completion:completionHandler];
    } else {
        completionHandler(nil, error);
    }
}

- (void)sendGetRequestToURL:(NSURL *)url
             withParameters:(NSDictionary *)parameters  
 shouldBeCalledUnauthorized:(BOOL)allowUnauthed
          completionHandler:(ReadmillAPICompletionHandler)completionHandler 
{    
    NSError *error = nil;
    NSURLRequest *request = [self getRequestWithURL:url 
                                         parameters:parameters 
                         shouldBeCalledUnauthorized:allowUnauthed
                                        cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                              error:&error];
    
    if (request) {
        [self startPreparedRequest:request 
                        completion:completionHandler];
    } else {
        completionHandler(nil, error);
    }
}

- (void)sendPutRequestToURL:(NSURL *)url 
             withParameters:(NSDictionary *)parameters  
 shouldBeCalledUnauthorized:(BOOL)allowUnauthed
          completionHandler:(ReadmillAPICompletionHandler)completionHandler 
{
    NSError *error = nil;
    NSURLRequest *request = [self putRequestWithURL:url 
                                         parameters:parameters 
                         shouldBeCalledUnauthorized:allowUnauthed
                                              error:&error];
    
    if (request) {
        [self startPreparedRequest:request 
                        completion:completionHandler];
    } else {
        return completionHandler(nil, error);
    }
}

- (void)sendPostRequestToURL:(NSURL *)url 
              withParameters:(NSDictionary *)parameters
  shouldBeCalledUnauthorized:(BOOL)allowUnauthed
           completionHandler:(ReadmillAPICompletionHandler)completionHandler 
{
    NSError *error = nil;
    NSURLRequest *request = [self postRequestWithURL:url 
                                          parameters:parameters 
                          shouldBeCalledUnauthorized:allowUnauthed
                                               error:&error];
    
    if (request) {
        [self startPreparedRequest:request 
                        completion:completionHandler];
    } else {
        return completionHandler(nil, error);
    }
}

- (void)sendBodyRequestToURL:(NSURL *)url 
                  httpMethod:(NSString *)httpMethod
              withParameters:(NSDictionary *)parameters
  shouldBeCalledUnauthorized:(BOOL)allowUnauthed
           completionHandler:(ReadmillAPICompletionHandler)completionHandler 
{    
    NSError *error = nil;
    
    NSURLRequest *request = [self bodyRequestWithURL:url 
                                          httpMethod:httpMethod
                                          parameters:parameters
                          shouldBeCalledUnauthorized:allowUnauthed
                                               error:&error];
    
    if (request) {
        [self startPreparedRequest:request 
                        completion:completionHandler];
    } else {
        completionHandler(nil, error);
    }
}

- (id)parseResponse:(NSHTTPURLResponse *)response
   withResponseData:(NSData *)responseData
    connectionError:(NSError *)connectionError 
              error:(NSError **)error 
{   
    
    if (([response statusCode] != 200 && [response statusCode] != 201) || response == nil || connectionError != nil) {
        
		if (connectionError == nil) {
            id errorResponse = [jsonDecoder objectWithData:responseData];
            
            if (error != NULL) {
                NSString *errorDomain = NSURLErrorDomain;
                if ([[response allHeaderFields] objectForKey:kReadmillAPIHeaderKey]) {
                    errorDomain = kReadmillDomain;
                }
                *error = [NSError errorWithDomain:errorDomain
                                             code:[response statusCode]
                                         userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                                   [errorResponse valueForKey:@"error"], NSLocalizedFailureReasonErrorKey, nil]];
            }
		} else {
			if (error != NULL) {
				*error = connectionError;
			}
		}
		return nil;
		
	} else {
		// All was OK in the URL, let's try and parse the JSON.
		NSError *parseError = nil;
        // Length > 1 hack to avoid JSONKit error on whitespace
        if (responseData && [responseData length] > 1) {
            id parsedJsonValue = [jsonDecoder objectWithData:responseData
                                                       error:&parseError];
            if (parseError != nil) {
                if (error != NULL) {
                    *error = parseError;
                }
            } else {
                return parsedJsonValue;
            }
        }
        return nil;
	}	
}
- (void)startPreparedRequest:(NSURLRequest *)request 
                  completion:(ReadmillAPICompletionHandler)completionBlock 
{    
    NSAssert(request != nil, @"Request is nil!");
    static NSString * const LocationHeader = @"Location";

    dispatch_queue_t currentQueue = dispatch_get_current_queue();
    // This block will be called when the asynchronous operation finishes
    ReadmillURLConnectionCompletionHandler connectionCompletionHandler = ^(NSHTTPURLResponse *response, 
                                                                           NSData *responseData, 
                                                                           NSError *connectionError) {
        
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        
        NSError *error = nil;

        // If we created something (book, reading etc) we receive a 201 Created response.
        // We issue a GET request with the URL found in the "Location" header.
        NSString *locationHeader = [[response allHeaderFields] valueForKey:LocationHeader];
        if ([response statusCode] == 201 && locationHeader != nil) {
            
            NSURL *locationURL = [NSURL URLWithString:locationHeader];
            NSURLRequest *newRequest = [self getRequestWithURL:locationURL 
                                                    parameters:nil 
                                    shouldBeCalledUnauthorized:NO
                                                         error:&error];
            
            if (newRequest) {
                [self startPreparedRequest:newRequest 
                                completion:completionBlock];
            } else {
                if (completionBlock) {
                    dispatch_async(currentQueue, ^{
                        completionBlock(nil, error);
                    });
                }
            }
        } else {
            // Parse the response
            id jsonResponse = [self parseResponse:response 
                                 withResponseData:responseData 
                                  connectionError:connectionError
                                            error:&error];
            
            // Execute the completionBlock
            if (completionBlock) {
                dispatch_async(currentQueue, ^{
                    completionBlock(jsonResponse, error);
                });
            }
        }
        [pool release];
    };
    
    ReadmillURLConnection *connection = [[ReadmillURLConnection alloc] initWithRequest:request 
                                                                     completionHandler:connectionCompletionHandler];
    [queue addOperation:connection];
    [connection release];
}
    
- (id)sendPreparedRequest:(NSURLRequest *)request 
                    error:(NSError **)error 
{    
    NSHTTPURLResponse *response = nil;
    NSError *connectionError = nil;
     
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request
                                                 returningResponse:&response
                                                             error:&connectionError];
    return [self parseResponse:response 
              withResponseData:responseData
               connectionError:connectionError 
                         error:error];

}

#pragma mark -
#pragma mark - Cancel operations

- (void)cancelAllOperations 
{
    [queue cancelAllOperations];
}

@end


