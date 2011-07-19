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
#import "ReadmillAPIConstants.h"
#import "CJSONDeserializer.h"

#define kTimeoutInterval 10.0

@interface ReadmillAPIWrapper ()

- (id)sendPreparedRequest:(NSURLRequest *)request error:(NSError **)error;
- (id)sendPutRequestToURL:(NSURL *)url withParameters:(NSDictionary *)parameters canBeCalledUnauthorized:(BOOL)allowUnauthed error:(NSError **)error;
- (id)sendPostRequestToURL:(NSURL *)url withParameters:(NSDictionary *)parameters canBeCalledUnauthorized:(BOOL)allowUnauthed error:(NSError **)error;
- (id)sendGetRequestToURL:(NSURL *)url withParameters:(NSDictionary *)parameters shouldBeCalledUnauthorized:(BOOL)stripAuth error:(NSError **)error;
- (id)sendBodyRequestToURL:(NSURL *)url httpMethod:(NSString *)httpMethod withParameters:(NSDictionary *)parameters canBeCalledUnauthorized:(BOOL)allowUnauthed error:(NSError **)error;

- (BOOL)refreshAccessToken:(NSError **)error;

- (NSString *)oAuthBaseURL;

@property (readwrite, copy) NSString *refreshToken;
@property (readwrite, copy) NSString *accessToken;
@property (readwrite, copy) NSString *authorizedRedirectURL;
@property (readwrite, copy) NSDate *accessTokenExpiryDate;
@property (readwrite, copy) NSString *apiEndPoint;

@end

@implementation ReadmillAPIWrapper

- (id)init {
    if ((self = [super init])) {
        // Initialization code here.
        
        [self setApiEndPoint:kLiveAPIEndPoint];
    }
    return self;
}

- (id)initWithStagingEndPoint {
    if ((self = [self init])) {
        [self setApiEndPoint:kStagingAPIEndPoint];
    }
    return self;
}

- (id)initWithPropertyListRepresentation:(NSDictionary *)plist {
    
    if ((self = [self init])) {
        
        [self setAuthorizedRedirectURL:[plist valueForKey:@"authorizedRedirectURL"]];
        [self setRefreshToken:[plist valueForKey:@"refreshToken"]];
        [self setApiEndPoint:[plist valueForKey:@"apiEndPoint"]];
		[self setAccessToken:[plist valueForKey:@"accessToken"]];
        [self setAccessTokenExpiryDate:[plist valueForKey:@"accessTokenExpiryDate"]];
    }
    return self;
}

- (NSDictionary *)propertyListRepresentation {
    return [NSDictionary dictionaryWithObjectsAndKeys:
            
            [self authorizedRedirectURL], @"authorizedRedirectURL",
            [self refreshToken], @"refreshToken", 
            [self apiEndPoint], @"apiEndPoint",
			[self accessToken], @"accessToken",
            [self accessTokenExpiryDate], @"accessTokenExpiryDate",
			nil];
	 
}

@synthesize refreshToken;
@synthesize accessToken;
@synthesize authorizedRedirectURL;
@synthesize accessTokenExpiryDate;
@synthesize apiEndPoint;

- (void)dealloc {
    [self setRefreshToken:nil];
    [self setAccessToken:nil];
    [self setAuthorizedRedirectURL:nil];
    [self setAccessTokenExpiryDate:nil];
    [self setApiEndPoint:nil];
    
    [super dealloc];
}

#pragma mark -
#pragma mark API endpoints

- (NSString *)booksEndpoint {
    return [NSString stringWithFormat:@"%@books", [self apiEndPoint]];
}
- (NSString *)readingsEndpoint {
    return [NSString stringWithFormat:@"%@readings", [self apiEndPoint]];
}
- (NSString *)usersEndpoint {
    return [NSString stringWithFormat:@"%@users", [self apiEndPoint]];
}


#pragma mark -
#pragma mark API Methods


// Books

- (NSArray *)allBooks:(NSError **)error {
    
    NSArray *apiResponse = [self sendGetRequestToURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@.json", [self booksEndpoint]]] 
                                      withParameters:nil
                          shouldBeCalledUnauthorized:YES
                                               error:error];
    return apiResponse;
    
}

- (NSArray *)booksFromSearch:(NSString *)searchString error:(NSError **)error {
    
    NSArray *apiResponse = [self sendGetRequestToURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@.json", [self booksEndpoint]]] 
                                           withParameters:[NSDictionary dictionaryWithObject:searchString forKey:@"q"]
                               shouldBeCalledUnauthorized:NO 
                                                    error:error];
    return apiResponse;

}
- (NSDictionary *)bookWithURLString:(NSString *)urlString error:(NSError **)error {
    
    NSRange range = [urlString rangeOfString:@".json"];
    if (range.location == NSNotFound) {
        urlString = [urlString stringByAppendingString:@".json"];
    }
    NSDictionary *apiResponse = [self sendGetRequestToURL:[NSURL URLWithString:urlString]
                                           withParameters:nil 
                               shouldBeCalledUnauthorized:NO 
                                                    error:error];
    return apiResponse;
}

- (NSDictionary *)bookWithId:(ReadmillBookId)bookId error:(NSError **)error {
    
    NSDictionary *apiResponse = [self sendGetRequestToURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%d.json", [self booksEndpoint], bookId]] 
                                           withParameters:nil
                               shouldBeCalledUnauthorized:YES
                                                    error:error];
    return apiResponse;
    
}

- (NSDictionary *)bookMatchingTitle:(NSString *)searchString error:(NSError **)error {
    
    NSDictionary *apiResponse = [self sendGetRequestToURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/match.json", [self booksEndpoint]]] 
                                      withParameters:[NSDictionary dictionaryWithObject:searchString forKey:@"q[title]"]
                          shouldBeCalledUnauthorized:YES
                                               error:error];
    
    return apiResponse;
}
- (NSDictionary *)bookMatchingISBN:(NSString *)isbn error:(NSError **)error {
    
    NSDictionary *apiResponse = [self sendGetRequestToURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/match.json", [self booksEndpoint]]] 
                                           withParameters:[NSDictionary dictionaryWithObject:isbn forKey:@"q[isbn]"]
                               shouldBeCalledUnauthorized:YES
                                                    error:error];
    return apiResponse;
}


- (NSDictionary *)addBookWithTitle:(NSString *)bookTitle author:(NSString *)bookAuthor isbn:(NSString *)bookIsbn error:(NSError **)error; {
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    NSString *bookScope = @"book[%@]";
    if ([bookTitle length] > 0) {
        [parameters setValue:bookTitle forKey:[NSString stringWithFormat:bookScope, kReadmillAPIBookTitleKey]];
    }
    
    if ([bookAuthor length] > 0) {
        [parameters setValue:bookAuthor forKey:[NSString stringWithFormat:bookScope, kReadmillAPIBookAuthorKey]];
    }
    
    if ([bookIsbn length] > 0) {
        [parameters setValue:bookIsbn forKey:[NSString stringWithFormat:bookScope, kReadmillAPIBookISBNKey]];
    }
    
    NSDictionary *apiResponse = [self sendPostRequestToURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@.json", [self booksEndpoint]]]
                                            withParameters:parameters
                                   canBeCalledUnauthorized:NO
                                                     error:error];
    
    return apiResponse;
}

// Readings

- (NSDictionary *)createReadingWithBookId:(ReadmillBookId)bookId 
                                    state:(ReadmillReadingState)readingState
                                  private:(BOOL)isPrivate 
                                    error:(NSError **)error {
    
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    NSString *readingScope = @"reading[%@]";
    [parameters setValue:[NSNumber numberWithInteger:readingState] forKey:[NSString stringWithFormat:readingScope, kReadmillAPIReadingStateKey]];
    [parameters setValue:[NSNumber numberWithInteger:isPrivate ? 1 : 0] forKey:[NSString stringWithFormat:readingScope, kReadmillAPIReadingIsPrivateKey]];
    [parameters setValue:kReadmillClientId forKey:[NSString stringWithFormat:readingScope, kReadmillAPIClientIdKey]];
    
    
    NSDictionary *apiResponse = [self sendPostRequestToURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%d/readings.json", [self booksEndpoint], bookId]]
                                            withParameters:parameters
                                   canBeCalledUnauthorized:NO
                                                     error:error];
    
    return apiResponse;
    
}
- (void)updateReadingWithId:(ReadmillReadingId)readingId 
              withState:(ReadmillReadingState)readingState
                private:(BOOL)isPrivate 
          closingRemark:(NSString *)remark 
                  error:(NSError **)error {
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    NSString *readingScope = @"reading[%@]";

    [parameters setValue:[NSNumber numberWithInteger:readingState] forKey:[NSString stringWithFormat:readingScope, kReadmillAPIReadingStateKey]];
    [parameters setValue:[NSNumber numberWithInteger:isPrivate ? 1 : 0] forKey:[NSString stringWithFormat:readingScope, kReadmillAPIReadingIsPrivateKey]];
    [parameters setValue:kReadmillClientId forKey:[NSString stringWithFormat:readingScope, kReadmillAPIClientIdKey]];
    
    if ([remark length] > 0) {
        [parameters setValue:remark forKey:[NSString stringWithFormat:readingScope, kReadmillAPIReadingClosingRemarkKey]];
    }
    
    [self sendPutRequestToURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%d.json", [self readingsEndpoint], readingId]]
               withParameters:parameters
      canBeCalledUnauthorized:NO
                        error:error];
}


- (NSArray *)publicReadingsForUserWithId:(ReadmillUserId)userId error:(NSError **)error {
    
    NSArray *apiResponse = [self sendGetRequestToURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%d/readings.json", [self usersEndpoint], userId]] 
                                           withParameters:nil
                               shouldBeCalledUnauthorized:NO
                                                    error:error];
    return apiResponse;
}

- (NSArray *)publicReadingsForUserWithName:(NSString *)userName error:(NSError **)error {
    
    if ([userName length] == 0) {
        return nil;
    } else {
        
        NSArray *apiResponse = [self sendGetRequestToURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@/readings.json", [self usersEndpoint], userName]] 
                                               withParameters:nil
                                   shouldBeCalledUnauthorized:NO
                                                        error:error];
        return apiResponse;
    }
}

- (NSDictionary *)readingWithId:(ReadmillReadingId)readingId error:(NSError **)error {
    
    NSDictionary *apiResponse = [self sendGetRequestToURL:[NSURL URLWithString:
                                                           [NSString stringWithFormat:@"%@/%d.json", 
                                                            [self readingsEndpoint], 
                                                            readingId]] 
                                           withParameters:nil
                               shouldBeCalledUnauthorized:NO
                                                    error:error];
    return apiResponse;    
}

- (NSDictionary *)readingWithId:(ReadmillReadingId)readingId forUserWithId:(ReadmillUserId)userId error:(NSError **)error {
    
    NSDictionary *apiResponse = [self sendGetRequestToURL:[NSURL URLWithString:
                                                           [NSString stringWithFormat:@"%@/%d/readings/%d.json", 
                                                            [self usersEndpoint], 
                                                            userId,
                                                            readingId]] 
                                           withParameters:nil
                               shouldBeCalledUnauthorized:NO
                                                    error:error];
    return apiResponse;
}

- (NSDictionary *)readingWithId:(ReadmillReadingId)readingId forUserWithName:(NSString *)userName error:(NSError **)error {
    
    if ([userName length] == 0) {
        return nil;
    } else {
        
        NSDictionary *apiResponse = [self sendGetRequestToURL:[NSURL URLWithString:
                                                               [NSString stringWithFormat:@"%@/%@/readings/%d.json", 
                                                                [self usersEndpoint], 
                                                                userName,
                                                                readingId]] 
                                               withParameters:nil
                                   shouldBeCalledUnauthorized:NO
                                                        error:error];
        return apiResponse;
    }
}

- (NSDictionary *)readingWithURLString:(NSString *)urlString error:(NSError **)error {
    NSRange range = [urlString rangeOfString:@".json"];
    if (range.location == NSNotFound) {
        urlString = [urlString stringByAppendingString:@".json"];
    }
    NSDictionary *apiResponse = [self sendGetRequestToURL:[NSURL URLWithString:urlString]
                                           withParameters:nil 
                               shouldBeCalledUnauthorized:NO 
                                                    error:error];
    return apiResponse;
}

//Pings     

- (void)pingReadingWithId:(ReadmillReadingId)readingId 
         withProgress:(ReadmillReadingProgress)progress 
    sessionIdentifier:(NSString *)sessionId
             duration:(ReadmillPingDuration)duration
       occurrenceTime:(NSDate *)occurrenceTime
             latitude:(CLLocationDegrees)latitude
            longitude:(CLLocationDegrees)longitude
                error:(NSError **)error {
    

    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    NSString *pingScope = @"ping[%@]";
    [parameters setValue:[NSNumber numberWithFloat:progress] forKey:[NSString stringWithFormat:pingScope, @"progress"]];
    [parameters setValue:[NSNumber numberWithUnsignedInteger:duration] forKey:[NSString stringWithFormat:pingScope, @"duration"]];
    
    if ([sessionId length] > 0) {
        [parameters setValue:sessionId forKey:[NSString stringWithFormat:pingScope, @"identifier"]];
    }
    
    if (occurrenceTime != nil) {
        // 2011-01-06T11:47:14Z
        NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
		[formatter setDateFormat:@"YYYY'-'MM'-'dd'T'HH':'mm':'ssZ'"];
		[parameters setValue:[formatter stringFromDate:occurrenceTime] forKey:[NSString stringWithFormat:pingScope, @"occurred_at"]];
        [formatter release];
        formatter = nil;
    }
    if (!(longitude == 0.0 && latitude == 0.0)) {
        // Do not send gps values if lat/lng were not specified.
        [parameters setValue:[NSNumber numberWithDouble:latitude] forKey:[NSString stringWithFormat:pingScope, @"lat"]];
        [parameters setValue:[NSNumber numberWithDouble:longitude] forKey:[NSString stringWithFormat:pingScope, @"lng"]];
    }

    [self sendPostRequestToURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%d/pings.json", [self readingsEndpoint], readingId]] 
                withParameters:parameters
       canBeCalledUnauthorized:NO
                         error:error];
    
}
- (void)pingReadingWithId:(ReadmillReadingId)readingId 
             withProgress:(ReadmillReadingProgress)progress 
        sessionIdentifier:(NSString *)sessionId
                 duration:(ReadmillPingDuration)duration
           occurrenceTime:(NSDate *)occurrenceTime
                    error:(NSError **)error {
    
    [self pingReadingWithId:readingId 
            withProgress:progress 
       sessionIdentifier:sessionId 
                duration:duration 
          occurrenceTime:occurrenceTime 
                latitude:0.0
               longitude:0.0 
                   error:error];
}

// Highlights

-(void)createHighlightForReadingWithId:(ReadmillReadingId)readingId highlightedText:(NSString *)highlightedText pre:(NSString *)pre post:(NSString *)post approximatePosition:(ReadmillReadingProgress)position comment:(NSString *)comment error:(NSError **)error {
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    NSString *scope = @"highlight[%@]";
    [parameters setValue:highlightedText forKey:[NSString stringWithFormat:scope, @"content"]];
    [parameters setValue:[NSNumber numberWithFloat:position] forKey:[NSString stringWithFormat:scope, @"position"]];
    [parameters setValue:pre forKey:[NSString stringWithFormat:scope, @"pre"]];
    [parameters setValue:post forKey:[NSString stringWithFormat:scope, @"post"]];
    
    if (nil == comment) {
        comment = @"";
    }
    [parameters setValue:comment forKey:@"comment"];

    // 2011-01-06T11:47:14Z
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY'-'MM'-'dd'T'HH':'mm':'ssZ'"];
    [parameters setValue:[formatter stringFromDate:[NSDate date]] forKey:[NSString stringWithFormat:scope, @"highlighted_at"]];
    [formatter release];
    
    NSLog(@"params: %@", parameters);
    
    NSURL *highlightsURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%d/highlights.json", 
                                                 [self readingsEndpoint], readingId]];

    
    [self sendPostRequestToURL:highlightsURL
                withParameters:parameters
       canBeCalledUnauthorized:NO
                         error:error];
}

- (NSArray *)highlightsForReadingWithId:(ReadmillReadingId)readingId error:(NSError **)error {
    NSArray *apiResponse = [self sendGetRequestToURL:[NSURL URLWithString:
                                                           [NSString stringWithFormat:@"%@/%d/highlights.json", 
                                                            [self readingsEndpoint], 
                                                            readingId]] 
                                           withParameters:nil
                               shouldBeCalledUnauthorized:NO
                                                    error:error];
    NSLog(@"api: %@", apiResponse);
    return apiResponse;    

}

// Users

- (NSDictionary *)userWithId:(ReadmillUserId)userId error:(NSError **)error {
    
    NSDictionary *apiResponse = [self sendGetRequestToURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@users/%d.json", [self apiEndPoint], userId]] 
                                           withParameters:nil
                               shouldBeCalledUnauthorized:YES
                                                    error:error];
    return apiResponse;
    
}

- (NSDictionary *)userWithName:(NSString *)userName error:(NSError **)error {
    
    if ([userName length] == 0) {
        return nil;
    } else {
        
        NSDictionary *apiResponse = [self sendGetRequestToURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@users/%@.json", [self apiEndPoint], userName]] 
                                               withParameters:nil
                                   shouldBeCalledUnauthorized:YES
                                                        error:error];
        return apiResponse;
    }
}

- (NSDictionary *)currentUser:(NSError **)error {
    
	if (![self ensureAccessTokenIsCurrent:error]) {
			return nil;
    }
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@me.json?access_token=%@&client_id=%@",
                                                                                             [self apiEndPoint],
                                                                                             [self accessToken],
                                                                                             [kReadmillClientId urlEncodedString]]]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                       timeoutInterval:kTimeoutInterval];
    [request setHTTPMethod:@"GET"];
    
    return [self sendPreparedRequest:request error:error];
}

#pragma mark -
#pragma mark OAuth

- (BOOL)authenticateWithParameters:(NSString *)parameterString error:(NSError **)error {
    @synchronized (self) {
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@oauth/token.json", [self oAuthBaseURL]]]
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
            NSLog(@"oauth response: %@", response);
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
                                 [kReadmillClientId urlEncodedString],
                                 [kReadmillClientSecret urlEncodedString],
                                 [authCode urlEncodedString],
                                 [redirectURLString urlEncodedString]];
    
    [self authenticateWithParameters:parameterString error:error];
}

- (BOOL)refreshAccessToken:(NSError **)error {
    
    NSString *parameterString = [NSString stringWithFormat:@"client_id=%@&client_secret=%@&grant_type=refresh_token&refresh_token=%@&redirect_uri=%@",
                                 [kReadmillClientId urlEncodedString],
                                 [kReadmillClientSecret urlEncodedString],
                                 [[self refreshToken] urlEncodedString],
                                 [[self authorizedRedirectURL] urlEncodedString]];
    
    return [self authenticateWithParameters:parameterString error:error];
}


- (NSURL *)clientAuthorizationURLWithRedirectURLString:(NSString *)redirect {
    
    NSString *baseURL = [self oAuthBaseURL];
    
    NSString *urlString = [NSString stringWithFormat:@"%@oauth/authorize?response_type=code&client_id=%@&mobile=1", baseURL, kReadmillClientId];
    
    if ([redirect length] > 0) {
        urlString = [NSString stringWithFormat:@"%@&redirect_uri=%@", urlString, [redirect urlEncodedString]];
    }
    
    return [NSURL URLWithString:urlString];
}

- (NSString *)oAuthBaseURL {
    
    if ([[self apiEndPoint] isEqualToString:kLiveAPIEndPoint]) {
        return kLiveAuthorizationUri;
    } else {
        return kStagingAuthorizationUri;
    }
    
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
    [parameters setValue:kReadmillClientId forKey:@"client_id"];
    [parameters setValue:[self accessToken] forKey:@"access_token"];
    
    NSURL *baseURL = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@ui/#!/connect/book", [self apiEndPoint]]];
    NSURL *URL = [baseURL URLByAddingParameters:parameters];
    [baseURL release];

    NSLog(@"url: %@", URL);
    return URL;
}
- (NSURL *)URLForViewingReadingWithId:(ReadmillReadingId)readingId {
    if (![self ensureAccessTokenIsCurrent:nil]) {
        return nil;
    }
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setValue:kReadmillClientId forKey:@"client_id"];
    [parameters setValue:[self accessToken] forKey:@"access_token"];
    
    NSURL *baseURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@ui/#!/view/reading/%d", [self apiEndPoint], readingId]];
    NSURL *URL = [baseURL URLByAddingParameters:parameters];
    
    return URL;
}

#pragma mark -
#pragma mark Sending Requests

- (BOOL)ensureAccessTokenIsCurrent:(NSError **)error {
    NSLog(@"now: %@, accessExpiry: %@", [NSDate date], [self accessTokenExpiryDate]);
    if ([self accessTokenExpiryDate] == nil || [(NSDate *)[NSDate date] compare:[self accessTokenExpiryDate]] == NSOrderedDescending) {
        return [self refreshAccessToken:error];
    } else {
        return YES;
    }
}

- (id)sendGetRequestToURL:(NSURL *)url withParameters:(NSDictionary *)parameters shouldBeCalledUnauthorized:(BOOL)stripAuth error:(NSError **)error {
    
    if (![self ensureAccessTokenIsCurrent:error]) {
        if (!stripAuth) {
            return nil;
        }
    }
    
	BOOL first = YES;
	
    NSMutableString *parameterString = [NSMutableString string];
    
    if ([[self accessToken] length] > 0 && !stripAuth) {
        [parameterString appendFormat:@"?access_token=%@", [self accessToken]];
        first = NO;
    }
    NSMutableDictionary *parametersWithClientId = [NSMutableDictionary dictionaryWithObject:kReadmillClientId forKey:@"client_id"];
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
	
	return [self sendPreparedRequest:request error:error];
}

- (id)sendPutRequestToURL:(NSURL *)url withParameters:(NSDictionary *)parameters canBeCalledUnauthorized:(BOOL)allowUnauthed error:(NSError **)error {
    return [self sendBodyRequestToURL:url httpMethod:@"PUT" withParameters:parameters canBeCalledUnauthorized:allowUnauthed error:error];
}

- (id)sendPostRequestToURL:(NSURL *)url withParameters:(NSDictionary *)parameters canBeCalledUnauthorized:(BOOL)allowUnauthed error:(NSError **)error {
	return [self sendBodyRequestToURL:url httpMethod:@"POST" withParameters:parameters canBeCalledUnauthorized:allowUnauthed error:error];
}

- (id)sendBodyRequestToURL:(NSURL *)url httpMethod:(NSString *)httpMethod withParameters:(NSDictionary *)parameters canBeCalledUnauthorized:(BOOL)allowUnauthed error:(NSError **)error {
    
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
    NSMutableDictionary *parametersWithClientId = [NSMutableDictionary dictionaryWithObject:kReadmillClientId forKey:@"client_id"];
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
	return [self sendPreparedRequest:request error:error];	
}

- (id)sendPreparedRequest:(NSURLRequest *)request error:(NSError **)error {
    NSLog(@"request: %@", request);
    
	NSHTTPURLResponse *response = nil;
	NSError *connectionError = nil;
	
	NSData *responseData = [NSURLConnection sendSynchronousRequest:request
												 returningResponse:&response
															 error:&connectionError];

	if (([response statusCode] != 200 && [response statusCode] != 201) || response == nil || connectionError != nil) {

		if (connectionError == nil) {
			
			id errorResponse = [[CJSONDeserializer deserializer] deserialize:responseData error:nil]; 
			
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

		// If we created something (book, reading etc) we receive a 201 Created response.
        // The location of the created object is in the "location" header.
        
        if ([[response allHeaderFields] valueForKey:@"Location"] != nil) {
            if ([response statusCode] == 201 || [response statusCode] == 200) {
                
                NSString *location = [[response allHeaderFields] valueForKey:@"Location"];
                NSLog(@"location: %@", location);
                // Strip the beginning '/'
                return [self sendGetRequestToURL:[NSURL URLWithString:location] 
                                  withParameters:nil 
                      shouldBeCalledUnauthorized:NO 
                                           error:error];
            }
        }
        
        // Return the parsed JSON
        if ([[jsonString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] > 0) {
            id parsedJsonValue = [[CJSONDeserializer deserializer] deserialize:responseData error:&parseError];
		
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
@end
