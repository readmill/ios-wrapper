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
#import "ReadmillRequestOperation.h"

@interface ReadmillAPIWrapper ()

@property (readwrite, copy) NSString *refreshToken;
@property (readwrite, copy) NSString *accessToken;
@property (readwrite, copy) NSString *authorizedRedirectURL;
@property (readwrite, copy) NSDate *accessTokenExpiryDate;
@property (nonatomic, readwrite, retain) NSOperationQueue *queue;
@property (nonatomic, readwrite, retain) ReadmillAPIConfiguration *apiConfiguration;

@end

@implementation ReadmillAPIWrapper

- (id)init
{
    if ((self = [super init])) {
        // Initialization code here.
        queue = [[NSOperationQueue alloc] init];
        [queue setMaxConcurrentOperationCount:10];
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
@synthesize queue;

- (void)dealloc
{
    [self setAccessToken:nil];
    [self setAuthorizedRedirectURL:nil];
    [self setAccessTokenExpiryDate:nil];
    [self setApiConfiguration:nil];
    [self setQueue:nil];
    [super dealloc];
}

#pragma mark -
#pragma mark API endpoints

- (NSString *)apiEndPoint
{
    NSLog(@"apicon: %@", self.apiConfiguration);
    
    return [[self.apiConfiguration apiBaseURL] absoluteString];
}

- (NSString *)booksEndpoint
{
    return @"books";
}

- (NSString *)readingsEndpoint
{
    return @"readings";
}

- (NSString *)usersEndpoint
{
    return @"users";
}

- (NSString *)highlightsEndpoint
{
    return @"highlights";
}

- (NSString *)likesEndpoint
{
    return @"likes/highlight";
}

- (NSString *)libraryEndPoint
{
    return @"me/library";
}

#pragma mark -
#pragma mark - Post To

- (NSArray *)postToArrayWithConnections:(NSArray *)connections
{
    NSMutableArray *connectionsArray = [NSMutableArray array];
    for (id connection in connections) {
        [connectionsArray addObject:[NSDictionary dictionaryWithObject:connection
                                                                forKey:@"id"]];
    }
    return connectionsArray;
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

- (void)readingForUserWithId:(ReadmillUserId)userId
          matchingIdentifier:(NSString *)identifier
                       title:(NSString *)title
                      author:(NSString *)author
           completionHandler:(ReadmillAPICompletionHandler)completion
{
    NSString *endpoint = [NSString stringWithFormat:@"%@/%d/readings/match",
                          [self usersEndpoint],
                          userId];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setValue:identifier forKey:kReadmillAPIBookIdentifierKey];
    [parameters setValue:title forKey:kReadmillAPIBookTitleKey];
    [parameters setValue:author forKey:kReadmillAPIBookAuthorKey];
    
    [self sendGetRequestToEndpoint:endpoint
                    withParameters:parameters
        shouldBeCalledUnauthorized:NO
                 completionHandler:completion];
    
}

- (void)findOrCreateReadingWithBookId:(ReadmillBookId)bookId
                                state:(NSString *)readingState
                            isPrivate:(BOOL)isPrivate
                          connections:(NSArray *)connections
                    completionHandler:(ReadmillAPICompletionHandler)completionHandler
{
    NSMutableDictionary *readingParameters = [NSMutableDictionary dictionary];
    
    [readingParameters setValue:readingState
                         forKey:kReadmillAPIReadingStateKey];
    [readingParameters setValue:isPrivate ? @"true" : @"false"
                         forKey:kReadmillAPIReadingPrivateKey];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithObject:readingParameters
                                                                         forKey:kReadmillAPIReadingKey];
    
    if (connections != nil) {
        [readingParameters setValue:[self postToArrayWithConnections:connections]
                             forKey:kReadmillAPIReadingPostToKey];
    }
    
    NSString *endpoint = [NSString stringWithFormat:@"%@/%d/readings",
                          [self booksEndpoint],
                          bookId];
    
    [self sendPostRequestToEndpoint:endpoint
                     withParameters:parameters
                  completionHandler:completionHandler];
}

- (void)findOrCreateReadingWithBookId:(ReadmillBookId)bookId
                                state:(NSString *)readingState
                            isPrivate:(BOOL)isPrivate
                    completionHandler:(ReadmillAPICompletionHandler)completionHandler
{
    [self findOrCreateReadingWithBookId:bookId
                                  state:readingState
                              isPrivate:isPrivate
                            connections:nil
                      completionHandler:completionHandler];
}

- (void)updateReadingWithId:(ReadmillReadingId)readingId
                 parameters:(NSDictionary *)parameters
          completionHandler:(ReadmillAPICompletionHandler)completionHandler
{
    NSString *endpoint = [NSString stringWithFormat:@"%@/%d",
                          [self readingsEndpoint],
                          readingId];
    [self sendPutRequestToEndpoint:endpoint
                    withParameters:parameters
                 completionHandler:completionHandler];
}

- (void)updateReadingWithId:(ReadmillReadingId)readingId
                  withState:(NSString *)readingState
                  isPrivate:(BOOL)isPrivate
              closingRemark:(NSString *)remark
          completionHandler:(ReadmillAPICompletionHandler)completionHandler
{
    NSMutableDictionary *readingParameters = [[NSMutableDictionary alloc] init];
    
    [readingParameters setValue:readingState
                         forKey:kReadmillAPIReadingStateKey];
    [readingParameters setValue:isPrivate ? @"true" : @"false"
                         forKey:kReadmillAPIReadingPrivateKey];
    
    if ([remark length] > 0) {
        [readingParameters setValue:remark
                             forKey:kReadmillAPIReadingClosingRemarkKey];
    }
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObject:readingParameters
                                                           forKey:kReadmillAPIReadingKey];
    [readingParameters release];
    
    [self updateReadingWithId:readingId parameters:parameters completionHandler:completionHandler];
}

- (void)updateReadingWithId:(ReadmillReadingId)readingId
                      state:(NSString *)readingState
              closingRemark:(NSString *)closingRemark
                recommended:(BOOL)recommended
                connections:(NSArray *)connections
          completionHandler:(ReadmillAPICompletionHandler)completionHandler
{
    NSMutableDictionary *readingParameters = [[NSMutableDictionary alloc] init];
    
    [readingParameters setValue:readingState
                         forKey:kReadmillAPIReadingStateKey];
    [readingParameters setValue:[NSNumber numberWithUnsignedInteger:recommended]
                         forKey:kReadmillAPIReadingRecommendedKey];
    if ([closingRemark length] > 0) {
        [readingParameters setValue:closingRemark
                             forKey:kReadmillAPIReadingClosingRemarkKey];
    }
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithObject:readingParameters
                                                                         forKey:kReadmillAPIReadingKey];
    [readingParameters release];
    
    if (connections != nil) {
        [readingParameters setValue:[self postToArrayWithConnections:connections]
                             forKey:kReadmillAPIHighlightPostToKey];
    }
    
    [self updateReadingWithId:readingId parameters:parameters completionHandler:completionHandler];
}

- (void)finishReadingWithId:(ReadmillReadingId)readingId
              closingRemark:(NSString *)closingRemark
                recommended:(BOOL)recommended
                connections:(NSArray *)connections
          completionHandler:(ReadmillAPICompletionHandler)completionHandler
{
    [self updateReadingWithId:readingId
                        state:ReadmillReadingStateFinishedKey
                closingRemark:closingRemark
                  recommended:recommended
                  connections:connections
            completionHandler:completionHandler];
}

- (void)abandonReadingWithId:(ReadmillReadingId)readingId
               closingRemark:(NSString *)closingRemark
                 connections:(NSArray *)connections
           completionHandler:(ReadmillAPICompletionHandler)completionHandler
{
    [self updateReadingWithId:readingId
                        state:ReadmillReadingStateAbandonedKey
                closingRemark:closingRemark
                  recommended:NO
                  connections:connections
            completionHandler:completionHandler];
}

- (void)publicReadingsForUserWithId:(ReadmillUserId)userId completionHandler:(ReadmillAPICompletionHandler)completionHandler
{
    NSString *endpoint = [NSString stringWithFormat:@"%@/%d/readings",
                          [self usersEndpoint],
                          userId];
    [self sendGetRequestToEndpoint:endpoint
                    withParameters:nil
        shouldBeCalledUnauthorized:YES
                 completionHandler:completionHandler];
}

- (void)readingsForUserWithId:(ReadmillUserId)userId completionHandler:(ReadmillAPICompletionHandler)completionHandler
{
    NSString *endpoint = [NSString stringWithFormat:@"%@/%d/readings",
                          [self usersEndpoint],
                          userId];
    [self sendGetRequestToEndpoint:endpoint
                    withParameters:nil
        shouldBeCalledUnauthorized:NO
                 completionHandler:completionHandler];
}

- (void)readingWithId:(ReadmillReadingId)readingId completionHandler:(ReadmillAPICompletionHandler)completionHandler
{
    NSString *endpoint = [NSString stringWithFormat:@"%@/%d",
                          [self readingsEndpoint],
                          readingId];
    [self sendGetRequestToEndpoint:endpoint
                    withParameters:nil
        shouldBeCalledUnauthorized:NO
                 completionHandler:completionHandler];
}

- (void)readingsForBookWithId:(ReadmillBookId)bookId completionHandler:(ReadmillAPICompletionHandler)completionHandler
{
    NSString *endpoint = [NSString stringWithFormat:@"%@/%d/readings",
                          [self booksEndpoint],
                          bookId];
    [self sendGetRequestToEndpoint:endpoint
                    withParameters:nil
        shouldBeCalledUnauthorized:NO
                 completionHandler:completionHandler];
}

- (void)readingsFilteredByFriendsForBookWithId:(ReadmillBookId)bookId
                             completionHandler:(ReadmillAPICompletionHandler)completionHandler
{
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                kReadmillAPIFilterByFollowings, kReadmillAPIFilterKey, // Filter by followings
                                [NSNumber numberWithInteger:1], @"highlights_count[from]", nil]; // At least 1 highlight
    
    NSString *endpoint = [NSString stringWithFormat:@"%@/%d/readings",
                          [self booksEndpoint],
                          bookId];
    [self sendGetRequestToEndpoint:endpoint
                    withParameters:parameters
        shouldBeCalledUnauthorized:NO
                       cachePolicy:NSURLRequestReturnCacheDataElseLoad
                 completionHandler:completionHandler];
}

- (void)readingsOrderedByPopularForBookWithId:(ReadmillBookId)bookId
                            completionHandler:(ReadmillAPICompletionHandler)completionHandler
{
    NSString *endpoint = [NSString stringWithFormat:@"%@/%d/readings",
                          [self booksEndpoint],
                          bookId];
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                kReadmillAPIOrderByPopular, kReadmillAPIOrderKey, // Order by popularity (based on comments > highlights > followers)
                                [NSNumber numberWithInteger:1], @"highlights_count[from]", nil]; // At least 1 highlight
    
    [self sendGetRequestToEndpoint:endpoint
                    withParameters:parameters
        shouldBeCalledUnauthorized:YES
                       cachePolicy:NSURLRequestReturnCacheDataElseLoad
                 completionHandler:completionHandler];
}

- (void)periodsForReadingWithId:(ReadmillReadingId)readingId
              completionHandler:(ReadmillAPICompletionHandler)completionHandler
{
    NSString *endpoint = [NSString stringWithFormat:@"%@/%d/periods",
                          [self readingsEndpoint],
                          readingId];
    
    NSDictionary *parameters = @{ @"count" : @100 };
    
    [self sendGetRequestToEndpoint:endpoint
                    withParameters:parameters
        shouldBeCalledUnauthorized:NO
                       cachePolicy:NSURLRequestReturnCacheDataElseLoad
                 completionHandler:completionHandler];
}

- (ReadmillRequestOperation *)positionForReadingWithId:(ReadmillReadingId)readingId
                                     completionHandler:(ReadmillAPICompletionHandler)completionHandler
{
    NSString *endpoint = [NSString stringWithFormat:@"%@/%d/position",
                          [self readingsEndpoint],
                          readingId];
    
    return [self sendGetRequestToEndpoint:endpoint
                           withParameters:nil
               shouldBeCalledUnauthorized:NO
                        completionHandler:completionHandler];
}

- (ReadmillRequestOperation *)updatePosition:(double)position
                            forReadingWithId:(ReadmillReadingId)readingId
                           completionHandler:(ReadmillAPICompletionHandler)completionHandler
{
    NSString *endpoint = [NSString stringWithFormat:@"%@/%d/position",
                          [self readingsEndpoint],
                          readingId];
    
    NSDictionary *parameters = @{ kReadmillAPIReadingPositionKey :
                                @ { kReadmillAPIReadingPositionKey : @(position) }};
    return [self sendPutRequestToEndpoint:endpoint
                           withParameters:parameters
                        completionHandler:completionHandler];
}


#pragma mark -
#pragma mark - Book

- (void)bookWithId:(ReadmillBookId)bookId completionHandler:(ReadmillAPICompletionHandler)completion
{
    NSString *endpoint = [NSString stringWithFormat:@"%@/%d", [self booksEndpoint], bookId];
    [self sendGetRequestToEndpoint:endpoint
                    withParameters:nil
        shouldBeCalledUnauthorized:YES
                 completionHandler:completion];
}

- (void)bookMatchingTitle:(NSString *)title
                   author:(NSString *)author
        completionHandler:(ReadmillAPICompletionHandler)completion
{
    [self bookMatchingIdentifier:nil
                           title:title
                          author:author
               completionHandler:completion];
}

- (void)bookMatchingIdentifier:(NSString *)identifier
             completionHandler:(ReadmillAPICompletionHandler)completion
{
    [self bookMatchingIdentifier:identifier
                           title:nil
                          author:nil
               completionHandler:completion];
}

- (void)bookMatchingIdentifier:(NSString *)identifier
                         title:(NSString *)title
                        author:(NSString *)author
             completionHandler:(ReadmillAPICompletionHandler)completion
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setValue:identifier forKey:kReadmillAPIBookIdentifierKey];
    [parameters setValue:author forKey:kReadmillAPIBookAuthorKey];
    [parameters setValue:title forKey:kReadmillAPIBookTitleKey];
    
    [self sendGetRequestToEndpoint:[NSString stringWithFormat:@"%@/match", [self booksEndpoint]]
                    withParameters:parameters
        shouldBeCalledUnauthorized:NO
                 completionHandler:completion];
}

- (void)findOrCreateBookWithTitle:(NSString *)bookTitle
                           author:(NSString *)bookAuthor
                       identifier:(NSString *)bookIdentifier
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
    
    if ([bookIdentifier length] > 0) {
        [bookParameters setValue:bookIdentifier
                          forKey:kReadmillAPIBookIdentifierKey];
    }
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObject:bookParameters
                                                           forKey:kReadmillAPIBookKey];
    [bookParameters release];
    
    [self sendPostRequestToEndpoint:[NSString stringWithFormat:@"%@", [self booksEndpoint]]
                     withParameters:parameters
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
                                                           forKey:kReadmillAPIPingKey];
    [pingParameters release];
    
    NSString *endpoint = [NSString stringWithFormat:@"%@/%d/%@",
                          [self readingsEndpoint],
                          readingId,
                          kReadmillAPIPingKey];
    
    [self sendPostRequestToEndpoint:endpoint
                     withParameters:parameters
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
                             parameters:(NSDictionary *)parameters
                      completionHandler:(ReadmillAPICompletionHandler)completionHandler
{
    NSString *endpoint = [NSString stringWithFormat:@"%@/%d/highlights", [self readingsEndpoint], readingId];
    [self sendPostRequestToEndpoint:endpoint
                     withParameters:parameters
                  completionHandler:completionHandler];
}

- (void)createHighlightForReadingWithId:(ReadmillReadingId)readingId
                        highlightedText:(NSString *)highlightedText
                               locators:(NSDictionary *)locators
                               position:(ReadmillReadingProgress)position
                          highlightedAt:(NSDate *)highlightedAt
                                comment:(NSString *)comment
                            connections:(NSArray *)connections
                       isCopyRestricted:(BOOL)isCopyRestricted
                      completionHandler:(ReadmillAPICompletionHandler)completionHandler
{
    NSAssert(0 < readingId, @"readingId: %d is invalid.", readingId);
    NSAssert(highlightedText != nil && [highlightedText length], @"Highlighted text can't be nil.");
    NSAssert(locators != nil && [locators count], @"Locators can't be nil.");
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    
    NSMutableDictionary *highlightParameters = [[NSMutableDictionary alloc] init];
    [highlightParameters setValue:locators
                           forKey:kReadmillAPIHighlightLocatorsKey];
    [highlightParameters setValue:highlightedText
                           forKey:kReadmillAPIHighlightContentKey];
    [highlightParameters setValue:[NSNumber numberWithFloat:position]
                           forKey:kReadmillAPIHighlightPositionKey];
    [highlightParameters setValue:[NSNumber numberWithBool:isCopyRestricted]
                           forKey:@"copy_restricted"];
    
    if (comment != nil && 0 < [comment length]) {
        NSDictionary *commentContentDictionary = [NSDictionary dictionaryWithObject:comment
                                                                             forKey:kReadmillAPIHighlightContentKey];
        [parameters setValue:commentContentDictionary forKey:kReadmillAPIHighlightCommentKey];
    }
    
    if (connections != nil) {
        [highlightParameters setValue:[self postToArrayWithConnections:connections]
                               forKey:kReadmillAPIHighlightPostToKey];
    }
    
    if (!highlightedAt) {
        highlightedAt = [NSDate date];
    }
    // 2011-01-06T11:47:14Z
    [highlightParameters setValue:[highlightedAt stringWithRFC3339Format]
                           forKey:kReadmillAPIHighlightHighlightedAtKey];
    [parameters setObject:highlightParameters forKey:kReadmillAPIHighlightKey];
    [highlightParameters release];
    
    NSString *endpoint = [NSString stringWithFormat:@"%@/%d/highlights", [self readingsEndpoint], readingId];
    
    [self sendPostRequestToEndpoint:endpoint
                     withParameters:[parameters autorelease]
                  completionHandler:completionHandler];
}

- (void)highlightsForReadingWithId:(ReadmillReadingId)readingId
                 completionHandler:(ReadmillAPICompletionHandler)completionHandler
{
    NSString *endpoint = [NSString stringWithFormat:@"%@/%d/highlights", [self readingsEndpoint], readingId];
    [self sendGetRequestToEndpoint:endpoint
                    withParameters:nil
        shouldBeCalledUnauthorized:NO
                 completionHandler:completionHandler];
}

- (void)deleteHighlightWithId:(NSUInteger)highlightId
            completionHandler:(ReadmillAPICompletionHandler)completionHandler
{
    NSString *endpoint = [NSString stringWithFormat:@"%@/%d", [self highlightsEndpoint], highlightId];
    [self sendDeleteRequestToEndpoint:endpoint
                       withParameters:nil
                    completionHandler:completionHandler];
}

#pragma mark - Highlight comments

- (void)createCommentForHighlightWithId:(ReadmillHighlightId)highlightId
                                comment:(NSString *)comment
                            commentedAt:(NSDate *)date
                      completionHandler:(ReadmillAPICompletionHandler)completionHandler
{
    NSString *endpoint = [NSString stringWithFormat:@"%@/%d/comments", [self highlightsEndpoint], highlightId];
    
    NSDictionary *commentDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                       comment, kReadmillAPICommentContentKey,
                                       [date stringWithRFC3339Format], kReadmillAPICommentPostedAtKey, nil];
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObject:commentDictionary
                                                           forKey:@"comment"];
    
    [self sendPostRequestToEndpoint:endpoint
                     withParameters:parameters
                  completionHandler:completionHandler];
}

- (void)commentsForHighlightWithId:(ReadmillHighlightId)highlightId
                 completionHandler:(ReadmillAPICompletionHandler)completionHandler
{
    NSString *endpoint = [NSString stringWithFormat:@"%@/%d/comments",
                          [self highlightsEndpoint],
                          highlightId];
    
    [self sendGetRequestToEndpoint:endpoint
                    withParameters:nil
        shouldBeCalledUnauthorized:NO
                 completionHandler:completionHandler];
}

#pragma mark -
#pragma mark - Likes


- (void)likesForHighlightWithId:(ReadmillHighlightId)highlightId completionHandler:(ReadmillAPICompletionHandler)completion
{
    NSString *endpoint = [NSString stringWithFormat:@"%@/%d", [self likesEndpoint], highlightId];
    
    [self sendGetRequestToEndpoint:endpoint
                    withParameters:nil
        shouldBeCalledUnauthorized:NO
                 completionHandler:completion];
}

- (void)likeHighlightWithId:(ReadmillHighlightId)highlightId completionHandler:(ReadmillAPICompletionHandler)completion
{
    NSString *endpoint = [NSString stringWithFormat:@"%@/%d", [self likesEndpoint], highlightId];
    
    [self sendPostRequestToEndpoint:endpoint
                     withParameters:nil
                  completionHandler:completion];
}

- (void)unlikeHighlightWithId:(ReadmillHighlightId)highlightId completionHandler:(ReadmillAPICompletionHandler)completion
{
    NSString *endpoint = [NSString stringWithFormat:@"%@/%d", [self likesEndpoint], highlightId];
    
    [self sendDeleteRequestToEndpoint:endpoint
                       withParameters:nil
                    completionHandler:completion];
}

#pragma mark -
#pragma Connections

- (void)connectionsForCurrentUserWithCompletionHandler:(ReadmillAPICompletionHandler)completionHandler
{
    NSString *endpoint = @"me/connections";
    [self sendGetRequestToEndpoint:endpoint
                    withParameters:nil
        shouldBeCalledUnauthorized:NO
                 completionHandler:completionHandler];
}


#pragma mark
#pragma mark - Users

- (void)userWithId:(ReadmillUserId)userId
 completionHandler:(ReadmillAPICompletionHandler)completionHandler
{
    NSString *endpoint = [NSString stringWithFormat:@"%@users/%d", [self apiEndPoint], userId];
    [self sendGetRequestToEndpoint:endpoint
                    withParameters:nil
        shouldBeCalledUnauthorized:YES
                 completionHandler:completionHandler];
}

- (void)currentUserWithCompletionHandler:(ReadmillAPICompletionHandler)completionHandler
{    
    [self sendGetRequestToEndpoint:@"me"
                    withParameters:nil
        shouldBeCalledUnauthorized:NO
                 completionHandler:completionHandler];
}


#pragma mark -
#pragma mark - Library

- (NSString *)endpointForLibraryItemWithId:(ReadmillLibraryItemId)itemId
{
    return [NSString stringWithFormat:@"%@/%d", [self libraryEndPoint], itemId];
}

- (void)libraryItemWithId:(ReadmillLibraryItemId)libraryItemId completionHandler:(ReadmillAPICompletionHandler)completionHandler
{
    [self sendGetRequestToEndpoint:[self endpointForLibraryItemWithId:libraryItemId]
                    withParameters:nil
        shouldBeCalledUnauthorized:NO
                 completionHandler:completionHandler];
}

- (void)updateLibraryItemWithId:(ReadmillLibraryItemId)libraryItemId
                     parameters:(NSDictionary *)parameters
              completionHandler:(ReadmillAPICompletionHandler)completionHandler
{
    [self sendPutRequestToEndpoint:[self endpointForLibraryItemWithId:libraryItemId]
                    withParameters:parameters
                 completionHandler:completionHandler];
}

- (void)libraryChangesWithLocalIds:(NSArray *)localIds
                 completionHandler:(ReadmillAPICompletionHandler)completionHandler
{
    NSDictionary *parameters = [NSDictionary dictionaryWithObject:[localIds componentsJoinedByString:@","]
                                                           forKey:kReadmillAPILibraryLocalIdsKey];
    
    NSString *endpoint = [[self libraryEndPoint] stringByAppendingPathComponent:@"compare"];
    [self sendGetRequestToEndpoint:endpoint
                    withParameters:parameters
        shouldBeCalledUnauthorized:NO
                 completionHandler:completionHandler];
}

#pragma mark -
#pragma mark - Operation

- (ReadmillRequestOperation *)operationWithRequest:(NSURLRequest *)request
                                        completion:(ReadmillAPICompletionHandler)completionBlock
{
    NSAssert(request != nil, @"Request is nil!");
    static NSString * const LocationHeader = @"Location";
    
    dispatch_queue_t currentQueue = dispatch_get_current_queue();
    // This block will be called when the asynchronous operation finishes
    ReadmillRequestOperationCompletionBlock connectionCompletionHandler = ^(NSHTTPURLResponse *response,
                                                                            NSData *responseData,
                                                                            NSError *connectionError) {
        
        @autoreleasepool {
            NSError *error = nil;
            
            // If we created something (201) or tried to create an existing
            // resource (409), we issue a GET request with the URL found
            // in the "Location" header that contains the resource.
            NSString *locationHeader = [[response allHeaderFields] valueForKey:LocationHeader];
            if ([response statusCode] == 409 && locationHeader != nil) {
                
                NSURL *locationURL = [NSURL URLWithString:locationHeader];
                NSURLRequest *newRequest = [self getRequestWithURL:locationURL
                                                        parameters:nil
                                        shouldBeCalledUnauthorized:NO
                                                       cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                             error:&error];
                
                if (newRequest) {
                    // It's important that we return this resource ASAP
                    [self startPreparedRequest:newRequest
                                    completion:completionBlock
                                 queuePriority:NSOperationQueuePriorityVeryHigh];
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
                
                if (connectionError || error) {
                    // Remove cached requests for errors
                    [[NSURLCache sharedURLCache] removeCachedResponseForRequest:request];
                }
                
                // Execute the completionBlock
                if (completionBlock) {
                    dispatch_async(currentQueue, ^{
                        completionBlock(jsonResponse, error);
                    });
                }
            }
        }
    };
    ReadmillRequestOperation *operation = [[[ReadmillRequestOperation alloc] initWithRequest:request
                                                                           completionHandler:connectionCompletionHandler] autorelease];
    
    return operation;
}


#pragma mark -
#pragma mark - Cancel operations

- (void)cancelAllOperations
{
    [queue cancelAllOperations];
}

@end


