//
//  ReadmillAPI.m
//  Readmill Framework
//
//  Created by Work on 10/01/2011.
//  Copyright 2011 KennettNet Software Limited. All rights reserved.
//

#import "ReadmillAPIWrapper.h"
#import "ReadmillStringExtensions.h"
#import "Constants.h"
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
        
    }
    return self;
}

-(NSDictionary *)propertyListRepresentation {
    return [NSDictionary dictionaryWithObjectsAndKeys:
            [self authorizedRedirectURL], @"authorizedRedirectURL",
            [self refreshToken], @"refreshToken", 
            [self apiEndPoint], @"apiEndPoint", nil];
}



@synthesize refreshToken;
@synthesize accessToken;
@synthesize authorizedRedirectURL;
@synthesize accessTokenExpiryDate;
@synthesize apiEndPoint;

-(void)dealloc {
    
    [self removeObserver:self forKeyPath:@"accessToken"];
    
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

-(NSArray *)booksMatchingISBN:(NSString *)isbn error:(NSError **)error {
    
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


-(NSDictionary *)addBookWithTitle:(NSString *)bookTitle author:(NSString *)bookAuthor isbn:(NSString *)bookIsbn error:(NSError **)error; {
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    if ([bookTitle length] > 0) {
        [parameters setValue:bookTitle forKey:@"title"];
    }
    
    if ([bookAuthor length] > 0) {
        [parameters setValue:bookAuthor forKey:@"author"];
    }
    
    if ([bookIsbn length] > 0) {
        [parameters setValue:bookIsbn forKey:@"isbn"];
    }
    
    NSDictionary *apiResponse = [self sendPostRequestToURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@books.json", [self apiEndPoint]]]
                                            withParameters:parameters
                                   canBeCalledUnauthorized:NO
                                                     error:error];
    return apiResponse;
}

// Reads

-(NSDictionary *)createReadWithBookId:(ReadmillBookId)bookId 
                                state:(ReadmillReadState)readState
                              private:(BOOL)isPrivate 
                                error:(NSError **)error {
    
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    [parameters setValue:[NSNumber numberWithInteger:readState] forKey:@"state"];
    [parameters setValue:[NSNumber numberWithInteger:isPrivate ? 1 : 0] forKey:@"is_private"];
    [parameters setValue:kClientId forKey:@"client_id"];
    
    
    NSDictionary *apiResponse = [self sendPostRequestToURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@books/%d/reads.json", [self apiEndPoint], bookId]]
                                            withParameters:parameters
                                   canBeCalledUnauthorized:NO
                                                     error:error];
    return apiResponse;
    
}

-(void)updateReadWithId:(ReadmillReadId)readId 
              withState:(ReadmillReadState)readState
                private:(BOOL)isPrivate 
          closingRemark:(NSString *)remark 
                  error:(NSError **)error {
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    [parameters setValue:[NSNumber numberWithInteger:readState] forKey:@"state"];
    [parameters setValue:[NSNumber numberWithInteger:isPrivate ? 1 : 0] forKey:@"is_private"];
    [parameters setValue:kClientId forKey:@"client_id"];
    
    if ([remark length] > 0) {
        [parameters setValue:remark forKey:@"closing_remark"];
    }
    
    [self sendPutRequestToURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@reads/%d.json", [self apiEndPoint], readId]]
               withParameters:parameters
      canBeCalledUnauthorized:NO
                        error:error];
    
    
}


-(NSArray *)publicReadsForUserWithId:(ReadmillUserId)userId error:(NSError **)error {
    
    NSDictionary *apiResponse = [self sendGetRequestToURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@users/%d/reads.json", [self apiEndPoint], userId]] 
                                           withParameters:nil
                               shouldBeCalledUnauthorized:YES
                                                    error:error];
    return [apiResponse valueForKey:@"read"];
}

-(NSArray *)publicReadsForUserWithName:(NSString *)userName error:(NSError **)error {
    
    if ([userName length] == 0) {
        return nil;
    } else {
        
        NSDictionary *apiResponse = [self sendGetRequestToURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@users/%@/reads.json", [self apiEndPoint], userName]] 
                                               withParameters:nil
                                   shouldBeCalledUnauthorized:YES
                                                        error:error];
        return [apiResponse valueForKey:@"read"];
    }
}

-(NSDictionary *)readWithId:(ReadmillReadId)readId forUserWithId:(ReadmillUserId)userId error:(NSError **)error {
    
    NSDictionary *apiResponse = [self sendGetRequestToURL:[NSURL URLWithString:
                                                           [NSString stringWithFormat:@"%@users/%d/reads/%d.json", 
                                                            [self apiEndPoint], 
                                                            userId,
                                                            readId]] 
                                           withParameters:nil
                               shouldBeCalledUnauthorized:YES
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
                                   shouldBeCalledUnauthorized:YES
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
    
    [parameters setValue:[NSNumber numberWithInteger:progress] forKey:@"progress"];
    [parameters setValue:[NSNumber numberWithInteger:duration] forKey:@"duration"];
    
    if ([sessionId length] > 0) {
        [parameters setValue:sessionId forKey:@"identifier"];
    }
    
    if (occurrenceTime != nil) {
        // 2011-01-06T11:47:14Z
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] initWithDateFormat:@"%Y-%m-%dT%H:%M:%SZ" allowNaturalLanguage:NO];
        [parameters setValue:[formatter stringFromDate:occurrenceTime] forKey:@"occurred_at"];
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
    
    if (![self ensureAccessTokenIsCurrent:error]) {
        return nil;
    }
    
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
                                 [kClientId urlEncodedString],
                                 [kClientSecret urlEncodedString],
                                 [authCode urlEncodedString],
                                 [redirectURLString urlEncodedString]];
    
    [request setHTTPMethod:@"POST"];
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-type"];
	[request setHTTPBody:[parameterString dataUsingEncoding:NSUTF8StringEncoding]];
	
    NSDictionary *response = [self sendPreparedRequest:request error:error];
    
	if (response != nil) {
        
        NSTimeInterval accessTokenTTL = [[response valueForKey:@"expires_in"] doubleValue];
        [self setAccessTokenExpiryDate:[[NSDate date] dateByAddingTimeInterval:accessTokenTTL]];
        
        [self setRefreshToken:[response valueForKey:@"refresh_token"]];
        [self setAccessToken:[response valueForKey:@"access_token"]];
        
        [self setAuthorizedRedirectURL:redirectURLString];
    }
}

-(BOOL)refreshAccessToken:(NSError **)error {
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@oauth/token.json", [self oAuthBaseURL]]]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                       timeoutInterval:10.0];
    
    NSString *parameterString = [NSString stringWithFormat:@"client_id=%@&client_secret=%@&grant_type=refresh_token&refresh_token=%@&redirect_uri=%@",
                                 [kClientId urlEncodedString],
                                 [kClientSecret urlEncodedString],
                                 [[self refreshToken] urlEncodedString],
                                 [[self authorizedRedirectURL] urlEncodedString]];
    
    [request setHTTPMethod:@"POST"];
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-type"];
	[request setHTTPBody:[parameterString dataUsingEncoding:NSUTF8StringEncoding]];
	
    NSDictionary *response = [self sendPreparedRequest:request error:error];
    
	if (response != nil) {
        
        NSTimeInterval accessTokenTTL = [[response valueForKey:@"expires_in"] doubleValue];
        [self setAccessTokenExpiryDate:[[NSDate date] dateByAddingTimeInterval:accessTokenTTL]];
        
        [self setRefreshToken:[response valueForKey:@"refresh_token"]];
        [self setAccessToken:[response valueForKey:@"access_token"]];
        
        return YES;
    } else {
        return NO;
    }
}


-(NSURL *)clientAuthorizationURLWithRedirectURLString:(NSString *)redirect {
    
    NSString *baseURL = [self oAuthBaseURL];
    
    NSString *urlString = [NSString stringWithFormat:@"%@oauth/authorize?response_type=code&client_id=%@", baseURL, kClientId];
    
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
#pragma mark Sending Requests

-(BOOL)ensureAccessTokenIsCurrent:(NSError **)error {
    
    if ([self accessTokenExpiryDate] == nil || [(NSDate *)[NSDate date] compare:[self accessTokenExpiryDate]] == NSOrderedDescending) {
        return [self refreshAccessToken:error];
    } else {
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
        [parameterString appendFormat:@"access_token=%@", [self accessToken]];
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
