//
//  ReadmillAPI.m
//  Readmill Framework
//
//  Created by Work on 10/01/2011.
//  Copyright 2011 KennettNet Software Limited. All rights reserved.
//

#import "ReadmillAPI.h"
#import "OAConsumer.h"
#import "OAToken.h"
#import "OAMutableURLRequest.h"
#import "ReadmillStringExtensions.h"
#import "Constants.h"
#import "CJSONDeserializer.h"

@interface ReadmillAPI ()

-(id)sendPreparedRequest:(NSURLRequest *)request error:(NSError **)error;
-(id)sendPutRequestToURL:(NSURL *)url withParameters:(NSDictionary *)parameters error:(NSError **)error;
-(id)sendPostRequestToURL:(NSURL *)url withParameters:(NSDictionary *)parameters error:(NSError **)error;
-(id)sendGetRequestToURL:(NSURL *)url withParameters:(NSDictionary *)parameters error:(NSError **)error;

-(void)refreshAccessToken:(NSError **)error;

-(OAConsumer *)oAuthConsumer;
-(OAToken *)oAuthToken;
-(NSString *)oAuthBaseURL;

@property (readwrite, copy) NSString *refreshToken;
@property (readwrite, copy) NSString *accessToken;
@property (readwrite, copy) NSString *authorizedRedirectURL;
@property (readwrite, copy) NSDate *accessTokenExpiryDate;
@property (readwrite, copy) NSString *apiEndPoint;

@end

@implementation ReadmillAPI

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
                                               error:error];
    return apiResponse;
    
}


-(NSArray *)booksMatchingTitle:(NSString *)searchString error:(NSError **)error {
    
    if ([searchString length] == 0) {
        return [self allBooks:error];
    } else {
        
        NSArray *apiResponse = [self sendGetRequestToURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@books.json", [self apiEndPoint]]] 
                                          withParameters:[NSDictionary dictionaryWithObject:searchString forKey:@"q[title]"]
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
                                                     error:error];
    return apiResponse;
    
}

-(NSDictionary *)updateReadWithId:(ReadmillReadId)readId 
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
    
    NSDictionary *apiResponse = [self sendPutRequestToURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@reads/%d.json", [self apiEndPoint], readId]]
                                           withParameters:parameters
                                                    error:error];
    return apiResponse;
    
    
}


-(NSArray *)publicReadsForUserWithId:(ReadmillUserId)userId error:(NSError **)error {
    
    NSDictionary *apiResponse = [self sendGetRequestToURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@users/%d/reads.json", [self apiEndPoint], userId]] 
                                           withParameters:nil
                                                    error:error];
    return [apiResponse valueForKey:@"read"];
}

-(NSArray *)publicReadsForUserWithName:(NSString *)userName error:(NSError **)error {
    
    if ([userName length] == 0) {
        return nil;
    } else {
        
        NSDictionary *apiResponse = [self sendGetRequestToURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@users/%@/reads.json", [self apiEndPoint], userName]] 
                                               withParameters:nil
                                                        error:error];
        return [apiResponse valueForKey:@"read"];
    }
}

//Pings     

-(NSDictionary *)pingReadWithId:(ReadmillReadId)readId 
                   withProgress:(ReadmillPingProgress)progress 
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
    
    NSDictionary *apiResponse = [self sendPostRequestToURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@reads/%d/pings.json", [self apiEndPoint], readId]] 
                                            withParameters:nil
                                                     error:error];
    return apiResponse;
    
}

// Users

-(NSDictionary *)userWithId:(ReadmillUserId)userId error:(NSError **)error {
    
    NSDictionary *apiResponse = [self sendGetRequestToURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@users/%d.json", [self apiEndPoint], userId]] 
                                           withParameters:nil
                                                    error:error];
    return apiResponse;
    
}

-(NSDictionary *)userWithName:(NSString *)userName error:(NSError **)error {
    
    if ([userName length] == 0) {
        return nil;
    } else {
        
        NSDictionary *apiResponse = [self sendGetRequestToURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@users/%@.json", [self apiEndPoint], userName]] 
                                               withParameters:nil
                                                        error:error];
        return apiResponse;
    }
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

-(void)refreshAccessToken:(NSError **)error {
    
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
        
        NSLog(@"%@ %@: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), @"Refreshed sucessfully");
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

-(OAConsumer *)oAuthConsumer {
    return [[[OAConsumer alloc] initWithKey:@"" secret:@""] autorelease];
}

-(OAToken *)oAuthToken {
    return [[[OAToken alloc] initWithKey:[self accessToken] secret:[self refreshToken]] autorelease];
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

-(void)ensureAccessTokenIsCurrent:(NSError **)error {
    
    if ([self accessTokenExpiryDate] == nil || [(NSDate *)[NSDate date] compare:[self accessTokenExpiryDate]] == NSOrderedDescending) {
        [self refreshAccessToken:error];
    }
}

-(id)sendPutRequestToURL:(NSURL *)url withParameters:(NSDictionary *)parameters error:(NSError **)error {
    
    [self ensureAccessTokenIsCurrent:error];
    
	NSMutableString *parameterString = [NSMutableString string];
	BOOL first = YES;
	
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
    
	OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url
																   consumer:[self oAuthConsumer]
																	  token:[self oAuthToken]
																	  realm:nil
														  signatureProvider:nil];
	[request setHTTPMethod:@"PUT"];
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-type"];
	[request setHTTPBody:[parameterString dataUsingEncoding:NSUTF8StringEncoding]];
	
	[request prepare]; 
	[request autorelease];
	
	return [self sendPreparedRequest:request error:error];	
    
}

-(id)sendPostRequestToURL:(NSURL *)url withParameters:(NSDictionary *)parameters error:(NSError **)error {
	
    [self ensureAccessTokenIsCurrent:error];
    
	NSMutableString *parameterString = [NSMutableString string];
	BOOL first = YES;
	
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
    
	
	OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url
																   consumer:[self oAuthConsumer]
																	  token:[self oAuthToken]
																	  realm:nil
														  signatureProvider:nil];
	[request setHTTPMethod:@"POST"];
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-type"];
	[request setHTTPBody:[parameterString dataUsingEncoding:NSUTF8StringEncoding]];
	
	[request prepare]; 
	[request autorelease];
	
	return [self sendPreparedRequest:request error:error];	
	
}

-(id)sendGetRequestToURL:(NSURL *)url withParameters:(NSDictionary *)parameters error:(NSError **)error {
	
    [self ensureAccessTokenIsCurrent:error];
    
	NSMutableString *parameterString = [NSMutableString string];
	BOOL first = YES;
	
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
	
	OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",
																								  [url absoluteString], 
																								  parameterString]]
                                                                   consumer:[self oAuthConsumer]
																	  token:[self oAuthToken]
																	  realm:nil
														  signatureProvider:nil];
	[request setHTTPMethod:@"GET"];
	
	[request prepare]; 
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
		id parsedJsonValue = [[CJSONDeserializer deserializer] deserialize:responseData error:&parseError];
		
        if (parseError != nil) {
			if (error != NULL) {
				*error = parseError;
			}
			return nil;
		} else {
			return parsedJsonValue;
		}
	}	
}


@end
