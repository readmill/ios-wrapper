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
#import "ReadmillStringExtensions.h"
#import "ReadmillURLExtensions.h"
#import "ReadmillErrorExtensions.h"
#import "NSDate+ReadmillDateExtensions.h"
#import "ReadmillURLConnection.h"
#import "JSONKit.h"

#define kTimeoutInterval 10.0

@interface ReadmillAPIWrapper ()

- (id)sendPreparedRequest:(NSURLRequest *)request error:(NSError **)error;
/*
- (id)sendPutRequestToURL:(NSURL *)url withParameters:(NSDictionary *)parameters canBeCalledUnauthorized:(BOOL)allowUnauthed error:(NSError **)error;
- (id)sendPostRequestToURL:(NSURL *)url withParameters:(NSDictionary *)parameters canBeCalledUnauthorized:(BOOL)allowUnauthed error:(NSError **)error;
- (id)sendGetRequestToURL:(NSURL *)url withParameters:(NSDictionary *)parameters canBeCalledUnauthorized:(BOOL)allowUnauthed error:(NSError **)error;
- (id)sendBodyRequestToURL:(NSURL *)url httpMethod:(NSString *)httpMethod withParameters:(NSDictionary *)parameters canBeCalledUnauthorized:(BOOL)allowUnauthed error:(NSError **)error;
*/

- (NSURLRequest *)putRequestWithURL:(NSURL *)url parameters:(NSDictionary *)parameters canBeCalledUnauthorized:(BOOL)allowUnauthed error:(NSError **)error;
- (NSURLRequest *)postRequestWithURL:(NSURL *)url parameters:(NSDictionary *)parameters canBeCalledUnauthorized:(BOOL)allowUnauthed error:(NSError **)error;
- (NSURLRequest *)getRequestWithURL:(NSURL *)url parameters:(NSDictionary *)parameters canBeCalledUnauthorized:(BOOL)allowUnauthed error:(NSError **)error;
- (NSURLRequest *)bodyRequestWithURL:(NSURL *)url httpMethod:(NSString *)httpMethod parameters:(NSDictionary *)parameters canBeCalledUnauthorized:(BOOL)allowUnauthed error:(NSError **)error;
- (NSURLRequest *)JSONPostRequestWithURL:(NSURL *)url parameters:(NSDictionary *)parameters canBeCalledUnauthorized:(BOOL)allowUnauthed error:(NSError **)error;

- (void)sendPutRequestToURL:(NSURL *)url withParameters:(NSDictionary *)parameters canBeCalledUnauthorized:(BOOL)allowUnauthed completionHandler:(ReadmillAPICompletionHandler)completionHandler;
- (void)sendPostRequestToURL:(NSURL *)url withParameters:(NSDictionary *)parameters canBeCalledUnauthorized:(BOOL)allowUnauthed completionHandler:(ReadmillAPICompletionHandler)completionHandler;
- (void)sendGetRequestToURL:(NSURL *)url withParameters:(NSDictionary *)parameters canBeCalledUnauthorized:(BOOL)allowUnauthed completionHandler:(ReadmillAPICompletionHandler)completionHandler;
- (void)sendJSONPostRequestToURL:(NSURL *)url withParameters:(NSDictionary *)parameters canBeCalledUnauthorized:(BOOL)allowUnauthed completionHandler:(ReadmillAPICompletionHandler)completionHandler;
- (void)sendBodyRequestToURL:(NSURL *)url httpMethod:(NSString *)httpMethod withParameters:(NSDictionary *)parameters canBeCalledUnauthorized:(BOOL)allowUnauthed completionHandler:(ReadmillAPICompletionHandler)completionHandler;
- (void)startPreparedRequest:(NSURLRequest *)request completion:(ReadmillAPICompletionHandler)completionBlock;

- (BOOL)refreshAccessToken:(NSError **)error;

@property (readwrite, copy) NSString *refreshToken;
@property (readwrite, copy) NSString *accessToken;
@property (readwrite, copy) NSString *authorizedRedirectURL;
@property (readwrite, copy) NSDate *accessTokenExpiryDate;
@property (nonatomic, readwrite, retain) ReadmillAPIConfiguration *apiConfiguration;
@end

@implementation ReadmillAPIWrapper

- (id)init {
    if ((self = [super init])) {
        // Initialization code here.
        queue = [[NSOperationQueue alloc] init];
        [queue setMaxConcurrentOperationCount:3];
    }
    return self;
}

- (id)initWithAPIConfiguration:(ReadmillAPIConfiguration *)configuration {
    self = [self init];
    if (self) {
        [self setApiConfiguration:configuration];
    }
    return self;
}

- (id)initWithPropertyListRepresentation:(NSDictionary *)plist {
    
    if ((self = [self init])) {
        
        [self setAuthorizedRedirectURL:[plist valueForKey:@"authorizedRedirectURL"]];
        [self setRefreshToken:[plist valueForKey:@"refreshToken"]];
		[self setAccessToken:[plist valueForKey:@"accessToken"]];
        [self setAccessTokenExpiryDate:[plist valueForKey:@"accessTokenExpiryDate"]];
        [self setApiConfiguration:[NSKeyedUnarchiver unarchiveObjectWithData:[plist valueForKey:@"apiConfiguration"]]];
    }
    return self;
}

- (NSDictionary *)propertyListRepresentation {
    return [NSDictionary dictionaryWithObjectsAndKeys:
            
            [self authorizedRedirectURL], @"authorizedRedirectURL",
            [self refreshToken], @"refreshToken", 
            [NSKeyedArchiver archivedDataWithRootObject:[self apiConfiguration]], @"apiConfiguration",
			[self accessToken], @"accessToken",
            [self accessTokenExpiryDate], @"accessTokenExpiryDate",
			nil];
}

@synthesize refreshToken;
@synthesize accessToken;
@synthesize authorizedRedirectURL;
@synthesize accessTokenExpiryDate;
@synthesize apiConfiguration;

- (void)dealloc {
    [self setRefreshToken:nil];
    [self setAccessToken:nil];
    [self setAuthorizedRedirectURL:nil];
    [self setAccessTokenExpiryDate:nil];
    [self setApiConfiguration:nil];
    [queue release];
    [super dealloc];
}

#pragma mark -
#pragma mark API endpoints

- (NSString *)apiEndPoint {
    return [[apiConfiguration apiBaseURL] absoluteString];
}
- (NSString *)booksEndpoint {
    return [NSString stringWithFormat:@"%@books", [self apiEndPoint]];
}
- (NSString *)readingsEndpoint {
    return [NSString stringWithFormat:@"%@readings", [self apiEndPoint]];
}
- (NSString *)usersEndpoint {
    return [NSString stringWithFormat:@"%@users", [self apiEndPoint]];
}
- (NSString *)highlightsEndpoint {
    return [NSString stringWithFormat:@"%@highlights", [self apiEndPoint]];
}

#pragma mark -
#pragma mark API Methods


// Readings

#pragma mark - Readings

- (void)createReadingWithBookId:(ReadmillBookId)bookId state:(ReadmillReadingState)readingState private:(BOOL)isPrivate 
              completionHandler:(ReadmillAPICompletionHandler)completionHandler {
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    [parameters setValue:[NSNumber numberWithInteger:readingState] forKey:@"state"];
    [parameters setValue:[NSNumber numberWithInteger:isPrivate ? 1 : 0] forKey:@"is_private"];
    [parameters setValue:[[self apiConfiguration] clientID] forKey:@"client_id"];
    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%d/readings", [self booksEndpoint], bookId]];
    [self sendPostRequestToURL:URL
                withParameters:parameters
       canBeCalledUnauthorized:NO
             completionHandler:completionHandler];
}

- (void)updateReadingWithId:(ReadmillReadingId)readingId 
                  withState:(ReadmillReadingState)readingState
                    private:(BOOL)isPrivate 
              closingRemark:(NSString *)remark 
          completionHandler:(ReadmillAPICompletionHandler)completionHandler {
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    NSString *readingScope = @"reading[%@]";

    [parameters setValue:[NSNumber numberWithInteger:readingState] 
                  forKey:[NSString stringWithFormat:readingScope, kReadmillAPIReadingStateKey]];
    [parameters setValue:[NSNumber numberWithInteger:isPrivate ? 1 : 0] 
                  forKey:[NSString stringWithFormat:readingScope, kReadmillAPIReadingIsPrivateKey]];
    [parameters setValue:[[self apiConfiguration] clientID]
                  forKey:[NSString stringWithFormat:readingScope, kReadmillAPIClientIdKey]];
    
    if ([remark length] > 0) {
        [parameters setValue:remark 
                      forKey:[NSString stringWithFormat:readingScope, kReadmillAPIReadingClosingRemarkKey]];
    }
    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%d", 
                                       [self readingsEndpoint], 
                                       readingId]];
    [self sendPutRequestToURL:URL 
               withParameters:parameters 
      canBeCalledUnauthorized:NO 
            completionHandler:completionHandler];
}

- (void)publicReadingsForUserWithId:(ReadmillUserId)userId completionHandler:(ReadmillAPICompletionHandler)completionHandler 
{
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%d/readings", 
                                                        [self usersEndpoint], 
                                                            userId]];
    [self sendGetRequestToURL:URL   
               withParameters:nil
      canBeCalledUnauthorized:NO
            completionHandler:completionHandler];
}
- (void)readingWithId:(ReadmillReadingId)readingId completionHandler:(ReadmillAPICompletionHandler)completionHandler 
{    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%d", 
                                       [self readingsEndpoint], 
                                       readingId]];
    [self sendGetRequestToURL:URL 
               withParameters:nil
      canBeCalledUnauthorized:NO
            completionHandler:completionHandler];
}

- (void)readingWithURLString:(NSString *)urlString completionHandler:(ReadmillAPICompletionHandler)completionHandler {
    
    NSError *error = nil;
    NSURLRequest *request = [self getRequestWithURL:[NSURL URLWithString:urlString] 
                                         parameters:nil
                            canBeCalledUnauthorized:NO 
                                              error:&error];
    
    if (request) {
        [self startPreparedRequest:request completion:completionHandler];
    } else {
        completionHandler(nil, error);
    }
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
        completionHandler:(ReadmillAPICompletionHandler)completionHandler {
    

    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    NSString *pingScope = @"ping[%@]";
    [parameters setValue:[NSNumber numberWithFloat:progress] forKey:[NSString stringWithFormat:pingScope, @"progress"]];
    [parameters setValue:[NSNumber numberWithUnsignedInteger:duration] forKey:[NSString stringWithFormat:pingScope, @"duration"]];
    
    if ([sessionId length] > 0) {
        [parameters setValue:sessionId forKey:[NSString stringWithFormat:pingScope, @"identifier"]];
    }
    
    if (occurrenceTime == nil) {
        occurrenceTime = [NSDate date];
    }
    
    // 2011-01-06T11:47:14Z
    NSString *dateString = [occurrenceTime stringWithRFC3339Format];
    [parameters setValue:dateString forKey:[NSString stringWithFormat:pingScope, @"occurred_at"]];

    if (!(longitude == 0.0 && latitude == 0.0)) {
        // Do not send gps values if lat/lng were not specified.
        [parameters setValue:[NSNumber numberWithDouble:latitude] forKey:[NSString stringWithFormat:pingScope, @"lat"]];
        [parameters setValue:[NSNumber numberWithDouble:longitude] forKey:[NSString stringWithFormat:pingScope, @"lng"]];
    }

    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%d/pings.json", [self readingsEndpoint], readingId]];
    
    [self sendPostRequestToURL:URL withParameters:parameters canBeCalledUnauthorized:NO completionHandler:completionHandler];
}
- (void)pingReadingWithId:(ReadmillReadingId)readingId 
             withProgress:(ReadmillReadingProgress)progress 
        sessionIdentifier:(NSString *)sessionId
                 duration:(ReadmillPingDuration)duration
           occurrenceTime:(NSDate *)occurrenceTime
        completionHandler:(ReadmillAPICompletionHandler)completionHandler {
    
    [self pingReadingWithId:readingId 
               withProgress:progress 
          sessionIdentifier:sessionId 
                   duration:duration 
             occurrenceTime:occurrenceTime 
                   latitude:0.0
                  longitude:0.0 
          completionHandler:completionHandler];
}


- (void)createHighlightForReadingWithId:(ReadmillReadingId)readingId highlightedText:(NSString *)highlightedText pre:(NSString *)pre post:(NSString *)post approximatePosition:(ReadmillReadingProgress)position highlightedAt:(NSDate *)highlightedAt comment:(NSString *)comment connections:(NSArray *)connectionsOrNil completionHandler:(ReadmillAPICompletionHandler)completionHandler {
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    NSMutableDictionary *highlightParameters = [NSMutableDictionary dictionary];
    [highlightParameters setValue:highlightedText forKey:@"content"];
    [highlightParameters setValue:[NSNumber numberWithFloat:position] forKey:@"position"];
    [highlightParameters setValue:pre forKey:@"pre"];
    [highlightParameters setValue:post forKey:@"post"];
    
    if (comment != nil && [comment length] > 0) {
        [parameters setValue:comment forKey:@"comment"];
    }
    
    if (connectionsOrNil != nil) {
        // Create a list of JSON objects (i.e array of NSDicionaries
        NSMutableArray *connectionsArray = [NSMutableArray array];
        for (id connection in connectionsOrNil) {
            [connectionsArray addObject:[NSDictionary dictionaryWithObject:connection forKey:@"id"]];
        }
        [parameters setValue:connectionsArray forKey:@"post_to"];
    }

    if (!highlightedAt) {
        highlightedAt = [NSDate date];
    }
    // 2011-01-06T11:47:14Z
    [highlightParameters setValue:[highlightedAt stringWithRFC3339Format] forKey:@"highlighted_at"];
    [parameters setObject:highlightParameters forKey:@"highlight"];
    NSLog(@"all parameters: %@", parameters);
    
    NSURL *highlightsURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%d/highlights.json", 
                                                 [self readingsEndpoint], readingId]];
    
    [self sendJSONPostRequestToURL:highlightsURL 
                    withParameters:parameters 
           canBeCalledUnauthorized:NO
                 completionHandler:completionHandler];
}

- (void)highlightsForReadingWithId:(ReadmillReadingId)readingId completionHandler:(ReadmillAPICompletionHandler)completionHandler {
    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%d/highlights.json", 
                                       [self readingsEndpoint], 
                                       readingId]];

    [self sendGetRequestToURL:URL withParameters:nil canBeCalledUnauthorized:NO completionHandler:completionHandler];
}

- (void)createCommentForHighlightWithId:(ReadmillHighlightId)highlightId comment:(NSString *)comment commentedAt:(NSDate *)date completionHandler:(ReadmillAPICompletionHandler)completionHandler {
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%d/comments.json", 
                                       [self highlightsEndpoint], 
                                       highlightId]];
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                   comment, @"content",
                                                                   [date stringWithRFC3339Format], @"posted_at", nil]
                                                                   
                                                           forKey:@"comment"];
    
    [self sendJSONPostRequestToURL:URL 
                    withParameters:parameters
           canBeCalledUnauthorized:NO 
                 completionHandler:completionHandler];
    
}

- (void)commentsForHighlightWithId:(ReadmillHighlightId)highlightId completionHandler:(ReadmillAPICompletionHandler)completionHandler {

    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%d/comments.json", 
                                       [self highlightsEndpoint], 
                                       highlightId]];
    
    [self sendGetRequestToURL:URL withParameters:nil canBeCalledUnauthorized:NO completionHandler:completionHandler];
}
#pragma mark
#pragma Connections

- (void)connectionsForCurrentUserWithCompletionHandler:(ReadmillAPICompletionHandler)completionHandler {
    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@me/connections.json", [self apiEndPoint]]];
    
    [self sendGetRequestToURL:URL 
               withParameters:nil
      canBeCalledUnauthorized:NO 
            completionHandler:completionHandler];
}

#pragma mark
#pragma mark - Users

- (void)userWithId:(ReadmillUserId)userId completionHandler:(ReadmillAPICompletionHandler)completionHandler
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@users/%d.json", [self apiEndPoint], userId]];
    [self sendGetRequestToURL:url 
               withParameters:nil
      canBeCalledUnauthorized:YES
            completionHandler:completionHandler];
}
/*
- (NSDictionary *)userWithName:(NSString *)userName error:(NSError **)error {
    
    if ([userName length] == 0) {
        return nil;
    } else {
        
        NSDictionary *apiResponse = [self sendGetRequestToURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@users/%@.json", [self apiEndPoint], userName]] 
                                               withParameters:nil
                                   canBeCalledUnauthorized:YES
                                                        error:error];
        return apiResponse;
    }
}*/

- (NSDictionary *)currentUser:(NSError **)error {
    
	if (![self ensureAccessTokenIsCurrent:error]) {
			return nil;
    }
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@me.json?access_token=%@&client_id=%@",
                                                                                             [self apiEndPoint],
                                                                                             [self accessToken],
                                                                                             [[[self apiConfiguration] clientID] urlEncodedString]]]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                       timeoutInterval:kTimeoutInterval];
    [request setHTTPMethod:@"GET"];
        
    return [self sendPreparedRequest:request error:error];
}
- (void)currentUserWithCompletionHandler:(ReadmillAPICompletionHandler)completionHandler {

    NSError *error = nil;
    if (![self ensureAccessTokenIsCurrent:&error]) {
        
        // Failed, fail completion block
        completionHandler(nil, error);
        
    } else {
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@me.json?access_token=%@&client_id=%@",
                                                                                                 [self apiEndPoint],
                                                                                                 [self accessToken],
                                                                                                 [[[self apiConfiguration] clientID] urlEncodedString]]]
                                                               cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                           timeoutInterval:kTimeoutInterval];
        [request setHTTPMethod:@"GET"];
        
        [self startPreparedRequest:request completion:completionHandler];        
    }
}
#pragma mark -
#pragma mark OAuth

- (BOOL)authenticateWithParameters:(NSString *)parameterString error:(NSError **)error {
    @synchronized (self) {
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[apiConfiguration accessTokenURL]
                                                               cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                           timeoutInterval:kTimeoutInterval];
    
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-type"];
        [request setHTTPBody:[parameterString dataUsingEncoding:NSUTF8StringEncoding]];
        [request setTimeoutInterval:kTimeoutInterval];
        
        NSDictionary *response = [self sendPreparedRequest:request 
                                                     error:error];
        
        if (response != nil) {
            NSLog(@"response: %@", response);
            NSTimeInterval accessTokenTTL = [[response valueForKey:@"expires_in"] doubleValue];        
            [self willChangeValueForKey:@"propertyListRepresentation"];
            [self setAccessTokenExpiryDate:[[NSDate date] dateByAddingTimeInterval:accessTokenTTL]];
            [self setRefreshToken:[response valueForKey:@"refresh_token"]];
            [self setAccessToken:[response valueForKey:@"access_token"]];
            [self didChangeValueForKey:@"propertyListRepresentation"];
            
            return YES;
        } else {
            if (nil != error) {
                NSLog(@"error: %@", *error);
            }
            return NO;
        }
    }
}
- (void)authorizeWithAuthorizationCode:(NSString *)authCode fromRedirectURL:(NSString *)redirectURLString error:(NSError **)error {

    [self setAuthorizedRedirectURL:redirectURLString];

    NSString *parameterString = [NSString stringWithFormat:@"client_id=%@&client_secret=%@&grant_type=authorization_code&code=%@&redirect_uri=%@",
                                 [[[self apiConfiguration] clientID] urlEncodedString],
                                 [[[self apiConfiguration] clientSecret] urlEncodedString],
                                 [authCode urlEncodedString],
                                 [redirectURLString urlEncodedString]];
    
    [self authenticateWithParameters:parameterString error:error];
}

- (BOOL)refreshAccessToken:(NSError **)error {
    
    NSString *parameterString = [NSString stringWithFormat:@"client_id=%@&client_secret=%@&grant_type=refresh_token&refresh_token=%@&redirect_uri=%@",
                                 [[[self apiConfiguration] clientID] urlEncodedString],
                                 [[[self apiConfiguration] clientSecret] urlEncodedString],
                                 [[self refreshToken] urlEncodedString],
                                 [[self authorizedRedirectURL] urlEncodedString]];
    
    return [self authenticateWithParameters:parameterString error:error];
}


- (NSURL *)clientAuthorizationURLWithRedirectURLString:(NSString *)redirect {
    
    NSString *baseURL = [[apiConfiguration authURL] absoluteString];
    
    NSString *urlString = [NSString stringWithFormat:@"%@oauth/authorize?response_type=code&client_id=%@", baseURL, [[self apiConfiguration] clientID]];
    
    if ([redirect length] > 0) {
        urlString = [NSString stringWithFormat:@"%@&redirect_uri=%@", urlString, [redirect urlEncodedString]];
    }
    
    return [NSURL URLWithString:urlString];
}

#pragma mark -
#pragma mark UI URLs

- (NSURL *)URLForConnectingBookWithISBN:(NSString *)ISBN title:(NSString *)title author:(NSString *)author {
    if (![self ensureAccessTokenIsCurrent:nil]) {
        return nil;
    }
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setValue:ISBN forKey:@"isbn"];
    [parameters setValue:title forKey:@"title"];
    [parameters setValue:author forKey:@"author"];
    [parameters setValue:[[self apiConfiguration] clientID] forKey:@"client_id"];
    [parameters setValue:[self accessToken] forKey:@"access_token"];
    
    NSURL *baseURL = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@ui/#!/connect/book", [self apiEndPoint]]];
    NSURL *URL = [baseURL URLByAddingParameters:parameters];
    [baseURL release];

    return URL;
}
- (NSURL *)URLForViewingReadingWithId:(ReadmillReadingId)readingId {
    if (![self ensureAccessTokenIsCurrent:nil]) {
        return nil;
    }
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setValue:[[self apiConfiguration] clientID] forKey:@"client_id"];
    [parameters setValue:[self accessToken] forKey:@"access_token"];
    
    NSURL *baseURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@ui/#!/view/reading/%d", [self apiEndPoint], readingId]];
    NSURL *URL = [baseURL URLByAddingParameters:parameters];
    
    return URL;
}

#pragma mark -
#pragma mark Sending Requests

- (void)sendRequestToURL:(NSURL *)url completionHandler:(ReadmillAPICompletionHandler)completionHandler {

    [self sendGetRequestToURL:url 
               withParameters:nil 
      canBeCalledUnauthorized:NO 
            completionHandler:completionHandler];
}

- (BOOL)ensureAccessTokenIsCurrent:(NSError **)error {
    NSLog(@"now: %@, accessExpiry: %@", [NSDate date], [self accessTokenExpiryDate]);
    if ([self accessTokenExpiryDate] == nil || [(NSDate *)[NSDate date] compare:[self accessTokenExpiryDate]] == NSOrderedDescending) {
        return [self refreshAccessToken:error];
    } else {
        return YES;
    }
}

- (NSURLRequest *)getRequestWithURL:(NSURL *)url parameters:(NSDictionary *)parameters canBeCalledUnauthorized:(BOOL)allowUnauthed error:(NSError **)error {
    
    if (![self ensureAccessTokenIsCurrent:error]) {
        if (!allowUnauthed) {
            return nil;
        }
    }
    
    BOOL first = YES;
	
    NSMutableString *parameterString = [NSMutableString string];
    
    if ([[self accessToken] length] > 0 && !allowUnauthed) {
        [parameterString appendFormat:@"?access_token=%@", [self accessToken]];
        first = NO;
    }
    NSMutableDictionary *parametersWithClientId = [NSMutableDictionary dictionaryWithObject:[[self apiConfiguration] clientID] forKey:@"client_id"];
    [parametersWithClientId addEntriesFromDictionary:parameters];
    
	for (NSString *key in [parametersWithClientId allKeys]) {		
		
		id value = [parametersWithClientId valueForKey:key];
		
		if (value) {
			[parameterString appendFormat:@"%@%@=%@",
			 first ? @"?" : @"&", 
			 key, 
			 [value isKindOfClass:[NSString class]] ? [value urlEncodedString] : [[value stringValue] urlEncodedString]];
			first = NO;
		}		
	}
    NSURL *finalURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",
                                            [url absoluteString], 
                                            parameterString]];
    
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:finalURL];
    
	[request setHTTPMethod:@"GET"];
    [request setValue:@"application/json" forHTTPHeaderField:@"accept"];
	[request autorelease];
    [request setTimeoutInterval:kTimeoutInterval];
    return request;
}
- (void)sendGetRequestToURL:(NSURL *)url withParameters:(NSDictionary *)parameters canBeCalledUnauthorized:(BOOL)allowUnauthed completionHandler:(ReadmillAPICompletionHandler)completionHandler {
    
    NSError *error = nil;
    NSURLRequest *request = [self getRequestWithURL:url 
                                         parameters:parameters 
                            canBeCalledUnauthorized:allowUnauthed
                                              error:&error];
    
    if (request) {
        [self startPreparedRequest:request completion:completionHandler];
    } else {
        completionHandler(nil, error);
    }
}

- (void)sendPutRequestToURL:(NSURL *)url withParameters:(NSDictionary *)parameters canBeCalledUnauthorized:(BOOL)allowUnauthed completionHandler:(ReadmillAPICompletionHandler)completionHandler {
    NSError *error = nil;
    NSURLRequest *request = [self putRequestWithURL:url 
                                         parameters:parameters 
                            canBeCalledUnauthorized:allowUnauthed
                                              error:&error];
    
    if (request) {
        [self startPreparedRequest:request completion:completionHandler];
    } else {
        return completionHandler(nil, error);
    }

}
- (void)sendPostRequestToURL:(NSURL *)url withParameters:(NSDictionary *)parameters canBeCalledUnauthorized:(BOOL)allowUnauthed completionHandler:(ReadmillAPICompletionHandler)completionHandler {

    NSError *error = nil;
    NSURLRequest *request = [self postRequestWithURL:url 
                                          parameters:parameters 
                             canBeCalledUnauthorized:allowUnauthed
                                               error:&error];
    
    if (request) {
        [self startPreparedRequest:request completion:completionHandler];
    } else {
        return completionHandler(nil, error);
    }
}


- (NSURLRequest *)putRequestWithURL:(NSURL *)url parameters:(NSDictionary *)parameters canBeCalledUnauthorized:(BOOL)allowUnauthed error:(NSError **)error {
    return [self bodyRequestWithURL:url httpMethod:@"PUT" parameters:parameters canBeCalledUnauthorized:allowUnauthed error:error];
}
- (NSURLRequest *)postRequestWithURL:(NSURL *)url parameters:(NSDictionary *)parameters canBeCalledUnauthorized:(BOOL)allowUnauthed error:(NSError **)error {
    return [self bodyRequestWithURL:url httpMethod:@"POST" parameters:parameters canBeCalledUnauthorized:allowUnauthed error:error];
}
- (NSURLRequest *)bodyRequestWithURL:(NSURL *)url httpMethod:(NSString *)httpMethod parameters:(NSDictionary *)parameters canBeCalledUnauthorized:(BOOL)allowUnauthed error:(NSError **)error {
    
    if (![self ensureAccessTokenIsCurrent:error]) {
        if (!allowUnauthed) {
            return nil;
        }
    }
    
    BOOL first = YES;
	
    NSMutableString *parameterString = [NSMutableString string];
    
    if ([[self accessToken] length] > 0) {
        [parameterString appendFormat:@"access_token=%@", [self accessToken]];
        first = NO;
    }
    NSMutableDictionary *parametersWithClientId = [NSMutableDictionary dictionaryWithObject:[[self apiConfiguration] clientID] forKey:@"client_id"];
    [parametersWithClientId addEntriesFromDictionary:parameters];
    
	for (NSString *key in [parametersWithClientId allKeys]) {		
		
		id value = [parametersWithClientId valueForKey:key];
		
		if (value) {
			[parameterString appendFormat:@"%@%@=%@",
             first ? @"" : @"&", 
             key, 
             [value isKindOfClass:[NSString class]] ? [value urlEncodedString] : [[value stringValue] urlEncodedString]];
			first = NO;
		}		
	}
    
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
	[request setHTTPMethod:httpMethod];
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-type"];
	[request setHTTPBody:[parameterString dataUsingEncoding:NSUTF8StringEncoding]];
    [request setValue:@"application/json" forHTTPHeaderField:@"accept"];
    [request setTimeoutInterval:kTimeoutInterval];
	[request autorelease];

    return request;
}

- (void)sendBodyRequestToURL:(NSURL *)url httpMethod:(NSString *)httpMethod withParameters:(NSDictionary *)parameters canBeCalledUnauthorized:(BOOL)allowUnauthed completionHandler:(ReadmillAPICompletionHandler)completionHandler {
    
    NSError *error = nil;
    
    NSURLRequest *request = [self bodyRequestWithURL:url httpMethod:httpMethod parameters:parameters canBeCalledUnauthorized:allowUnauthed error:&error];
    
    if (request) {
        [self startPreparedRequest:request completion:completionHandler];
    } else {
        completionHandler(nil, error);
    }
}

- (NSURLRequest *)JSONPostRequestWithURL:(NSURL *)URL parameters:(NSDictionary *)parameters canBeCalledUnauthorized:(BOOL)allowUnauthed error:(NSError **)error {
    
    if (![self ensureAccessTokenIsCurrent:error]) {
        if (!allowUnauthed) {
            return nil;
        }
    }
    
    NSMutableDictionary *allParameters = [NSMutableDictionary dictionaryWithObject:[[self apiConfiguration] clientID] 
                                                                            forKey:@"client_id"];
    
    if ([[self accessToken] length] > 0) {
        [allParameters setValue:[self accessToken] forKey:@"access_token"];
    }
    
    [allParameters addEntriesFromDictionary:parameters];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:URL];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-type"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[allParameters JSONData]];
    [request setValue:@"application/json" forHTTPHeaderField:@"accept"];
    [request setTimeoutInterval:kTimeoutInterval];
    [request autorelease];
    
    return request;
}

- (void)sendJSONPostRequestToURL:(NSURL *)url withParameters:(NSDictionary *)parameters canBeCalledUnauthorized:(BOOL)allowUnauthed completionHandler:(ReadmillAPICompletionHandler)completionHandler {
    
    NSError *error= nil;
    NSURLRequest *request = [self JSONPostRequestWithURL:url parameters:parameters canBeCalledUnauthorized:allowUnauthed error:&error];
    
    if (request) {
        [self startPreparedRequest:request completion:completionHandler];
    } else {
        completionHandler(nil, error);
    }
}
- (id)parseResponse:(NSHTTPURLResponse *)response withResponseData:(NSData *)responseData connectionError:(NSError *)connectionError error:(NSError **)error {
    
    if (([response statusCode] != 200 && [response statusCode] != 201) || response == nil || connectionError != nil) {
        
		if (connectionError == nil) {
            id errorResponse = [[JSONDecoder decoder] objectWithData:responseData];
            
            if (error != NULL) {
                *error = [NSError errorWithDomain:kReadmillDomain
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
        
        // Do we have an empty response?
        NSString *jsonString = [[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding] autorelease];
        
        // Return the parsed JSON
        if ([[jsonString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] > 0) {
            id parsedJsonValue = [[JSONDecoder decoder] objectWithData:responseData error:&parseError];
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
- (void)startPreparedRequest:(NSURLRequest *)request completion:(ReadmillAPICompletionHandler)completionBlock {
    
    NSAssert(request != nil, @"Request is nil!");

    // This block will be called when the asynchronous operation finishes
    ReadmillURLConnectionCompletionHandler connectionCompletionHandler = ^(NSHTTPURLResponse *response, 
                                                                           NSData *responseData, 
                                                                           NSError *connectionError) {
        
        NSError *error = nil;

        // If we created something (book, reading etc) we receive a 201 Created response.
        // We issue a GET request with the URL found in the "Location" header.
        NSString *locationHeader = [[response allHeaderFields] valueForKey:@"Location"];
        if ([response statusCode] == 201 && locationHeader != nil) {
            
            NSURL *locationURL = [NSURL URLWithString:locationHeader];
            NSURLRequest *newRequest = [self getRequestWithURL:locationURL 
                                                    parameters:nil 
                                       canBeCalledUnauthorized:NO
                                                         error:&error];
            
            if (newRequest) {
                [self startPreparedRequest:newRequest 
                                completion:completionBlock];
            } else {
                if (completionBlock) {
                    // Always return on main thread
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        completionBlock(nil, error);
                    }];
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
                // Always return on main thread
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                     completionBlock(jsonResponse, error);   
                }];
            }
        }
    };
    
    ReadmillURLConnection *connection = [[ReadmillURLConnection alloc] initWithRequest:request 
                                                                     completionHandler:connectionCompletionHandler];
    [queue addOperation:connection];
    [connection release];
}
    
- (id)sendPreparedRequest:(NSURLRequest *)request error:(NSError **)error {
    
    NSHTTPURLResponse *response = nil;
    NSError *connectionError = nil;
     
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request
                                                 returningResponse:&response
                                                             error:&connectionError];
     
    
    return [self parseResponse:response withResponseData:responseData connectionError:connectionError error:error];

}
@end


