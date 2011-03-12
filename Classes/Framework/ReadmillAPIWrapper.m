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
#import "ReadmillAPIConstants.h"
#import "CJSONDeserializer.h"

@interface ReadmillAPIWrapper ()

-(id)sendPreparedRequest:(NSURLRequest *)request error:(NSError **)error;
-(id)sendPutRequestToURL:(NSURL *)url withParameters:(NSDictionary *)parameters canBeCalledUnauthorized:(BOOL)allowUnauthed error:(NSError **)error;
-(id)sendPostRequestToURL:(NSURL *)url withParameters:(NSDictionary *)parameters canBeCalledUnauthorized:(BOOL)allowUnauthed error:(NSError **)error;
-(id)sendGetRequestToURL:(NSURL *)url withParameters:(NSDictionary *)parameters shouldBeCalledUnauthorized:(BOOL)stripAuth error:(NSError **)error;
-(id)sendBodyRequestToURL:(NSURL *)url httpMethod:(NSString *)httpMethod withParameters:(NSDictionary *)parameters canBeCalledUnauthorized:(BOOL)allowUnauthed error:(NSError **)error;

-(BOOL)refreshAccessToken:(NSError **)error;

-(NSString *)oAuthBaseURL;

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

-(id)initWithStagingEndPoint {
    if ((self = [self init])) {
        [self setApiEndPoint:kStagingAPIEndPoint];
    }
    return self;
}

-(id)initWithPropertyListRepresentation:(NSDictionary *)plist {
    
    if ((self = [self init])) {
        
        [self setAuthorizedRedirectURL:[plist valueForKey:@"authorizedRedirectURL"]];
        [self setRefreshToken:[plist valueForKey:@"refreshToken"]];
        [self setApiEndPoint:[plist valueForKey:@"apiEndPoint"]];
		[self setAccessToken:[plist valueForKey:@"accessToken"]];
		//[self setAccessTokenExpiryDate:[plist valueForKey:@"accessTokenExpiryDate"]];
    }
    return self;
}

-(NSDictionary *)propertyListRepresentation {
    return [NSDictionary dictionaryWithObjectsAndKeys:
            [self authorizedRedirectURL], @"authorizedRedirectURL",
            [self refreshToken], @"refreshToken", 
            [self apiEndPoint], @"apiEndPoint",
			//[self accessTokenExpiryDate], @"accessTokenExpiryDate",
			[self accessToken], @"accessToken",
			nil];
	 
}



@synthesize refreshToken;
@synthesize accessToken;
@synthesize authorizedRedirectURL;
@synthesize accessTokenExpiryDate;
@synthesize apiEndPoint;

-(void)dealloc {
    [self setRefreshToken:nil];
    [self setAccessToken:nil];
    [self setAuthorizedRedirectURL:nil];
    [self setAccessTokenExpiryDate:nil];
    [self setApiEndPoint:nil];
    
    [super dealloc];
}

#pragma mark -
#pragma mark API Methods

// Books

-(NSArray *)allBooks:(NSError **)error {
    
    NSArray *apiResponse = [self sendGetRequestToURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@books.json", [self apiEndPoint]]] 
                                      withParameters:nil
                          shouldBeCalledUnauthorized:YES
                                               error:error];
    return apiResponse;
    
}


-(NSArray *)booksMatchingTitle:(NSString *)searchString error:(NSError **)error {
    
    if ([searchString length] == 0) {
        return [self allBooks:error];
    } else {
        
        NSArray *apiResponse = [self sendGetRequestToURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@books.json", [self apiEndPoint]]] 
                                          withParameters:[NSDictionary dictionaryWithObject:searchString forKey:@"q[title]"]
                              shouldBeCalledUnauthorized:YES
                                                   error:error];
        return apiResponse;
        
    }
}

- (NSDictionary *)bookWithRelativePath:(NSString *)pathToBook error:(NSError **)error {
    
    NSDictionary *apiResponse = [self sendGetRequestToURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@.json", [self apiEndPoint], pathToBook]] 
                                           withParameters:nil
                               shouldBeCalledUnauthorized:YES
                                                    error:error];
    return apiResponse;
    
}

- (NSDictionary *)bookWithId:(ReadmillBookId)bookId error:(NSError **)error {
    
    NSDictionary *apiResponse = [self sendGetRequestToURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@books/%d.json", [self apiEndPoint], bookId]] 
                                           withParameters:nil
                               shouldBeCalledUnauthorized:YES
                                                    error:error];
    return apiResponse;
    
}

- (NSArray *)booksMatchingISBN:(NSString *)isbn error:(NSError **)error {
    
    if ([isbn length] == 0) {
        return [self allBooks:error];
    } else {
        
        NSArray *apiResponse = [self sendGetRequestToURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@books.json", [self apiEndPoint]]] 
                                          withParameters:[NSDictionary dictionaryWithObject:isbn forKey:@"q[isbn]"]
                              shouldBeCalledUnauthorized:YES
                                                   error:error];
        return apiResponse;
        
    }
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
    
    NSString *pathToBook = [self sendPostRequestToURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@books.json", [self apiEndPoint]]]
                                            withParameters:parameters
                                   canBeCalledUnauthorized:NO
                                                     error:error];
    
    DLog(@"pathToBook: %@", pathToBook);
    NSDictionary *apiResponse = [self bookWithRelativePath:pathToBook error:error];
    DLog(@"book apiresponse: %@", apiResponse);
    return apiResponse;
}

// Reads

-(NSDictionary *)createReadWithBookId:(ReadmillBookId)bookId 
                                state:(ReadmillReadState)readState
                              private:(BOOL)isPrivate 
                                error:(NSError **)error {
    
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    NSString *readScope = @"read[%@]";
    [parameters setValue:[NSNumber numberWithInteger:readState] forKey:[NSString stringWithFormat:readScope, kReadmillAPIReadStateKey]];
    [parameters setValue:[NSNumber numberWithInteger:isPrivate ? 1 : 0] forKey:[NSString stringWithFormat:readScope, kReadmillAPIReadIsPrivateKey]];
    [parameters setValue:kReadmillClientId forKey:[NSString stringWithFormat:readScope, kReadmillAPIClientIdKey]];
    
    
    NSString *pathToRead = [self sendPostRequestToURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@books/%d/reads.json", [self apiEndPoint], bookId]]
                                            withParameters:parameters
                                   canBeCalledUnauthorized:NO
                                                     error:error];
    
    NSDictionary *apiResponse = [self readWithRelativePath:pathToRead error:error];
    DLog(@"params: %@", parameters);
    DLog(@"createRead: %@", apiResponse);
    return apiResponse;
    
}

-(void)updateReadWithId:(ReadmillReadId)readId 
              withState:(ReadmillReadState)readState
                private:(BOOL)isPrivate 
          closingRemark:(NSString *)remark 
                  error:(NSError **)error {
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    NSString *readScope = @"read[%@]";

    [parameters setValue:[NSNumber numberWithInteger:readState] forKey:[NSString stringWithFormat:readScope, kReadmillAPIReadStateKey]];
    [parameters setValue:[NSNumber numberWithInteger:isPrivate ? 1 : 0] forKey:[NSString stringWithFormat:readScope, kReadmillAPIReadIsPrivateKey]];
    [parameters setValue:kReadmillClientId forKey:[NSString stringWithFormat:readScope, kReadmillAPIClientIdKey]];
    
    if ([remark length] > 0) {
        [parameters setValue:remark forKey:[NSString stringWithFormat:readScope, kReadmillAPIReadClosingRemarkKey]];
    }
    
    [self sendPutRequestToURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@reads/%d.json", [self apiEndPoint], readId]]
               withParameters:parameters
      canBeCalledUnauthorized:NO
                        error:error];
}


-(NSArray *)publicReadsForUserWithId:(ReadmillUserId)userId error:(NSError **)error {
    
    NSArray *apiResponse = [self sendGetRequestToURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@users/%d/reads.json", [self apiEndPoint], userId]] 
                                           withParameters:nil
                               shouldBeCalledUnauthorized:NO
                                                    error:error];
    return apiResponse;
}

-(NSArray *)publicReadsForUserWithName:(NSString *)userName error:(NSError **)error {
    
    if ([userName length] == 0) {
        return nil;
    } else {
        
        NSArray *apiResponse = [self sendGetRequestToURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@users/%@/reads.json", [self apiEndPoint], userName]] 
                                               withParameters:nil
                                   shouldBeCalledUnauthorized:NO
                                                        error:error];
        return apiResponse;
    }
}
 
- (NSDictionary *)readWithRelativePath:(NSString *)pathToRead error:(NSError **)error {
    NSDictionary *apiResponse = [self sendGetRequestToURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@.json", [self apiEndPoint], pathToRead]]
                                           withParameters:nil
                               shouldBeCalledUnauthorized:NO
                                                    error:error];
    return apiResponse;
}

-(NSDictionary *)readWithId:(ReadmillReadId)readId forUserWithId:(ReadmillUserId)userId error:(NSError **)error {
    
    NSDictionary *apiResponse = [self sendGetRequestToURL:[NSURL URLWithString:
                                                           [NSString stringWithFormat:@"%@users/%d/reads/%d.json", 
                                                            [self apiEndPoint], 
                                                            userId,
                                                            readId]] 
                                           withParameters:nil
                               shouldBeCalledUnauthorized:NO
                                                    error:error];
    return apiResponse;
    
}

-(NSDictionary *)readWithId:(ReadmillReadId)readId forUserWithName:(NSString *)userName error:(NSError **)error {
    
    if ([userName length] == 0) {
        return nil;
    } else {
        
        NSDictionary *apiResponse = [self sendGetRequestToURL:[NSURL URLWithString:
                                                               [NSString stringWithFormat:@"%@users/%@/reads/%d.json", 
                                                                [self apiEndPoint], 
                                                                userName,
                                                                readId]] 
                                               withParameters:nil
                                   shouldBeCalledUnauthorized:NO
                                                        error:error];
        return apiResponse;
    }
}


//Pings     

-(void)pingReadWithId:(ReadmillReadId)readId 
         withProgress:(ReadmillReadProgress)progress 
    sessionIdentifier:(NSString *)sessionId
             duration:(ReadmillPingDuration)duration
       occurrenceTime:(NSDate *)occurrenceTime 
                error:(NSError **)error {
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    NSString *pingScope = @"ping[%@]";
    [parameters setValue:[NSNumber numberWithInteger:progress] forKey:[NSString stringWithFormat:pingScope, @"progress"]];
    [parameters setValue:[NSNumber numberWithInteger:duration] forKey:[NSString stringWithFormat:pingScope, @"duration"]];
    
    if ([sessionId length] > 0) {
        [parameters setValue:sessionId forKey:[NSString stringWithFormat:pingScope, @"identifier"]];
    }
    
    if (occurrenceTime != nil) {
        // 2011-01-06T11:47:14Z
        NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
		[formatter setDateFormat:@"YYYY'-'MM'-'dd'T'HH':'mm':'ss'Z'"];
		[parameters setValue:[formatter stringFromDate:occurrenceTime] forKey:[NSString stringWithFormat:pingScope, @"occurred_at"]];
        [formatter release];
        formatter = nil;
    }
	
    [self sendPostRequestToURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@reads/%d/pings.json", [self apiEndPoint], readId]] 
                withParameters:parameters
       canBeCalledUnauthorized:NO
                         error:error];
    
}

// Users

-(NSDictionary *)userWithId:(ReadmillUserId)userId error:(NSError **)error {
    
    NSDictionary *apiResponse = [self sendGetRequestToURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@users/%d.json", [self apiEndPoint], userId]] 
                                           withParameters:nil
                               shouldBeCalledUnauthorized:YES
                                                    error:error];
    return apiResponse;
    
}

-(NSDictionary *)userWithName:(NSString *)userName error:(NSError **)error {
    
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

-(NSDictionary *)currentUser:(NSError **)error {
    /*
    if (![self ensureAccessTokenIsCurrent:error]) {
        return nil;
    }*/
    /*
	if (![self canReachReadmill]) {
		if (accessTokenExpiryDate != nil && [(NSDate *)[NSDate date] compare:[self accessTokenExpiryDate]] == NSOrderedAscending) {
			return nil;
		}
	}*/
	if (![self ensureAccessTokenIsCurrent:error]) {
			return nil;
    }
    DLog(@"accessToken: %@", [self accessToken]);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@oauth/echo.json?access_token=%@",
                                                                                             [self oAuthBaseURL],
                                                                                             [self accessToken]]]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                       timeoutInterval:10.0];
    [request setHTTPMethod:@"GET"];
    
    return [self sendPreparedRequest:request error:error];
}

#pragma mark -
#pragma mark OAuth

-(void)authorizeWithAuthorizationCode:(NSString *)authCode fromRedirectURL:(NSString *)redirectURLString error:(NSError **)error {
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@oauth/token.json", [self oAuthBaseURL]]]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                       timeoutInterval:10.0];
    
    NSString *parameterString = [NSString stringWithFormat:@"client_id=%@&client_secret=%@&grant_type=authorization_code&code=%@&redirect_uri=%@",
                                 [kReadmillClientId urlEncodedString],
                                 [kReadmillClientSecret urlEncodedString],
                                 [authCode urlEncodedString],
                                 [redirectURLString urlEncodedString]];
    
    [request setHTTPMethod:@"POST"];
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-type"];
	[request setHTTPBody:[parameterString dataUsingEncoding:NSUTF8StringEncoding]];
	
    NSDictionary *response = [self sendPreparedRequest:request error:error];
	DLog(@"response in authorizeWithAuthorizationCode: %@", response);

	if (response != nil) {
        NSTimeInterval accessTokenTTL = [[response valueForKey:@"expires_in"] doubleValue];
    
        [self willChangeValueForKey:@"propertyListRepresentation"];
		[self setAccessTokenExpiryDate:[[NSDate date] dateByAddingTimeInterval:accessTokenTTL]];
		
        [self setRefreshToken:[response valueForKey:@"refresh_token"]];
        [self setAccessToken:[response valueForKey:@"access_token"]];
        [self setAuthorizedRedirectURL:redirectURLString];
        
        [self didChangeValueForKey:@"propertyListRepresentation"];
    }
}

-(BOOL)refreshAccessToken:(NSError **)error {
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@oauth/token.json", [self oAuthBaseURL]]]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                       timeoutInterval:10.0];
    
    NSString *parameterString = [NSString stringWithFormat:@"client_id=%@&client_secret=%@&grant_type=refresh_token&refresh_token=%@&redirect_uri=%@",
                                 [kReadmillClientId urlEncodedString],
                                 [kReadmillClientSecret urlEncodedString],
                                 [[self refreshToken] urlEncodedString],
                                 [[self authorizedRedirectURL] urlEncodedString]];
    
    [request setHTTPMethod:@"POST"];
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-type"];
	[request setHTTPBody:[parameterString dataUsingEncoding:NSUTF8StringEncoding]];
	
    NSDictionary *response = [self sendPreparedRequest:request error:error];
    DLog(@"response in refreshAccessToken: %@", response);
	if (response != nil) {
        
        NSTimeInterval accessTokenTTL = [[response valueForKey:@"expires_in"] doubleValue];

        [self willChangeValueForKey:@"propertyListRepresentation"];
		[self setAccessTokenExpiryDate:[[NSDate date] dateByAddingTimeInterval:accessTokenTTL]];

        [self setRefreshToken:[response valueForKey:@"refresh_token"]];
        [self setAccessToken:[response valueForKey:@"access_token"]];
        
        [self didChangeValueForKey:@"propertyListRepresentation"];
        
        return YES;
    } else {
        return NO;
    }
}


-(NSURL *)clientAuthorizationURLWithRedirectURLString:(NSString *)redirect {
    
    NSString *baseURL = [self oAuthBaseURL];
    
    NSString *urlString = [NSString stringWithFormat:@"%@oauth/authorize?response_type=code&client_id=%@", baseURL, kReadmillClientId];
    
    if ([redirect length] > 0) {
        urlString = [NSString stringWithFormat:@"%@&redirect_uri=%@", urlString, [redirect urlEncodedString]];
    }
    
    return [NSURL URLWithString:urlString];
}

-(NSString *)oAuthBaseURL {
    
    if ([[self apiEndPoint] isEqualToString:kLiveAPIEndPoint]) {
        return kLiveAuthorizationUri;
    } else {
        return kStagingAuthorizationUri;
    }
    
}

#pragma mark -
#pragma mark UI URLs

-(NSURL *)connectBookUIURLForBookWithId:(ReadmillBookId)bookId {
    
    if (![self ensureAccessTokenIsCurrent:nil]) {
        return nil;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"%@books/%d/reads/new?access_token=%@", [self apiEndPoint], bookId, [self accessToken]];
    return [NSURL URLWithString:urlString];
}

-(NSURL *)editReadUIURLForReadWithId:(ReadmillReadId)readId {
    
    if (![self ensureAccessTokenIsCurrent:nil]) {
        return nil;
    }

    NSString *urlString = [NSString stringWithFormat:@"%@reads/%d/edit?access_token=%@", [self apiEndPoint], readId, [self accessToken]];
    return [NSURL URLWithString:urlString];
}

#pragma mark -
#pragma mark Sending Requests

-(BOOL)ensureAccessTokenIsCurrent:(NSError **)error {
    if ([self accessTokenExpiryDate] == nil || [(NSDate *)[NSDate date] compare:[self accessTokenExpiryDate]] == NSOrderedDescending) {
        DLog(@"try to refreshAccessToken");
        return [self refreshAccessToken:error];
    } else {
        DLog(@"accessexpirydate not nil or new");
        return YES;
    }
}

-(id)sendGetRequestToURL:(NSURL *)url withParameters:(NSDictionary *)parameters shouldBeCalledUnauthorized:(BOOL)stripAuth error:(NSError **)error {
    
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
    
	for (NSString *key in [parameters allKeys]) {		
		
		id value = [parameters valueForKey:key];
		
		if (value) {
			[parameterString appendFormat:@"%@%@=%@",
			 first ? @"?" : @"&", 
			 key, 
			 [value isKindOfClass:[NSString class]] ? [value urlEncodedString] : [[value stringValue] urlEncodedString]];
			first = NO;
		}		
	}
	
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",
																								  [url absoluteString], 
																								  parameterString]]];
	[request setHTTPMethod:@"GET"];
	[request autorelease];
	
	return [self sendPreparedRequest:request error:error];
}

-(id)sendPutRequestToURL:(NSURL *)url withParameters:(NSDictionary *)parameters canBeCalledUnauthorized:(BOOL)allowUnauthed error:(NSError **)error {
    return [self sendBodyRequestToURL:url httpMethod:@"PUT" withParameters:parameters canBeCalledUnauthorized:allowUnauthed error:error];
}

-(id)sendPostRequestToURL:(NSURL *)url withParameters:(NSDictionary *)parameters canBeCalledUnauthorized:(BOOL)allowUnauthed error:(NSError **)error {
	return [self sendBodyRequestToURL:url httpMethod:@"POST" withParameters:parameters canBeCalledUnauthorized:allowUnauthed error:error];
}

-(id)sendBodyRequestToURL:(NSURL *)url httpMethod:(NSString *)httpMethod withParameters:(NSDictionary *)parameters canBeCalledUnauthorized:(BOOL)allowUnauthed error:(NSError **)error {
    
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
    
	for (NSString *key in [parameters allKeys]) {		
		
		id value = [parameters valueForKey:key];
		
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
    
	[request autorelease];
	return [self sendPreparedRequest:request error:error];	
}

-(id)sendPreparedRequest:(NSURLRequest *)request error:(NSError **)error {
    
	NSHTTPURLResponse *response = nil;
	NSError *connectionError = nil;
	
	NSData *responseData = [NSURLConnection sendSynchronousRequest:request
												 returningResponse:&response
															 error:&connectionError];
	DLog(@"request: %@", [[request URL] absoluteString]);
    NSString *jsonString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];

    DLog(@"statuscode: %d", [response statusCode]);
	DLog(@"response: %@", jsonString);
    [jsonString release];
	if (([response statusCode] != 200 && [response statusCode] != 201) || response == nil || connectionError != nil) {

		if (connectionError == nil) {
			
			id errorResponse = [[CJSONDeserializer deserializer] deserialize:responseData error:nil]; 
			
			if (error != NULL) {
				*error = [NSError errorWithDomain:@"com.readmill.api"
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
		
		// If we created something (book, read etc) we receive a 201 Created response.
        // The location of the created object is in the "location" header.
        if ([response statusCode] == 201) {
            DLog(@"statuscode: 201");
            DLog(@"headerfields: %@", [response allHeaderFields]);
            NSString *location = [[response allHeaderFields] valueForKey:@"Location"];
            // Strip the beginning '/'
            return [location substringFromIndex:1];
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

- (BOOL)canReachReadmill {
	Reachability *r = [Reachability reachabilityWithHostName:@"www.readmill.com"];
	NetworkStatus internetStatus = [r currentReachabilityStatus];
	return (internetStatus != NotReachable);
}

@end
