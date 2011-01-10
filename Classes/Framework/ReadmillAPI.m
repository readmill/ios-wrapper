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
#import "ReadmillXMLParser.h"

@interface ReadmillAPI ()

-(NSDictionary *)sendPreparedRequest:(OAMutableURLRequest *)request error:(NSError **)error;
-(NSDictionary *)dictionaryForReadmillResponseData:(NSData *)data error:(NSError **)error;
-(NSDictionary *)sendPutRequestToURL:(NSURL *)url withParameters:(NSDictionary *)parameters error:(NSError **)error;
-(NSDictionary *)sendPostRequestToURL:(NSURL *)url withParameters:(NSDictionary *)parameters error:(NSError **)error;
-(NSDictionary *)sendGetRequestToURL:(NSURL *)url withParameters:(NSDictionary *)parameters error:(NSError **)error;

@property (readwrite, copy) NSString *oAuthSecret;
@property (readwrite, copy) NSString *oAuthToken;

@end

@implementation ReadmillAPI

- (id)init {
    if ((self = [super init])) {
        // Initialization code here.
    }
    
    return self;
}

@synthesize oAuthToken;
@synthesize oAuthSecret;

// Books

-(NSArray *)allBooks:(NSError **)error {

    NSDictionary *apiResponse = [self sendGetRequestToURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@books", kLiveAPIEndPoint]] 
										   withParameters:nil
													error:error];
    return [apiResponse valueForKey:@"book"];

}


-(NSArray *)booksMatchingTitle:(NSString *)searchString error:(NSError **)error {
    
    if ([searchString length] == 0) {
        return [self allBooks:error];
    } else {
        
        NSDictionary *apiResponse = [self sendGetRequestToURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@books", kLiveAPIEndPoint]] 
                                               withParameters:[NSDictionary dictionaryWithObject:searchString forKey:@"q[title]"]
                                                        error:error];
        return [apiResponse valueForKey:@"book"];
        
    }
}

-(NSArray *)booksMatchingISBN:(NSString *)isbn error:(NSError **)error {
    
    if ([isbn length] == 0) {
        return [self allBooks:error];
    } else {
        
        NSDictionary *apiResponse = [self sendGetRequestToURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@books", kLiveAPIEndPoint]] 
                                               withParameters:[NSDictionary dictionaryWithObject:isbn forKey:@"q[isbn]"]
                                                        error:error];
        return [apiResponse valueForKey:@"book"];
        
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
    
    NSDictionary *apiResponse = [self sendPostRequestToURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@books", kLiveAPIEndPoint]]
                                                withParameters:parameters
                                                     error:error];
    return apiResponse;
}

// Reads

-(NSDictionary *)createReadWithBookId:(ReadmillBookId)bookId 
                                state:(ReadmillReadState)readState
                        applicationId:(NSString *)applicationId 
                              private:(BOOL)isPrivate 
                                error:(NSError **)error {


    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];

    [parameters setValue:[NSNumber numberWithInteger:readState] forKey:@"state"];
    [parameters setValue:[NSNumber numberWithInteger:isPrivate ? 1 : 0] forKey:@"is_private"];
    
    if ([applicationId length] > 0) {
        [parameters setValue:applicationId forKey:@"client_id"];
    }
    
    NSDictionary *apiResponse = [self sendPostRequestToURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@books/%d/reads", kLiveAPIEndPoint, bookId]]
                                                withParameters:parameters
                                                     error:error];
    return apiResponse;

}

-(NSDictionary *)updateReadWithId:(ReadmillReadId)readId 
                        withState:(ReadmillReadState)readState
                    applicationId:(NSString *)applicationId 
                          private:(BOOL)isPrivate 
                    closingRemark:(NSString *)remark 
                            error:(NSError **)error {

    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    [parameters setValue:[NSNumber numberWithInteger:readState] forKey:@"state"];
    [parameters setValue:[NSNumber numberWithInteger:isPrivate ? 1 : 0] forKey:@"is_private"];
    
    if ([applicationId length] > 0) {
        [parameters setValue:applicationId forKey:@"client_id"];
    }
    
    if ([remark length] > 0) {
        [parameters setValue:remark forKey:@"closing_remark"];
    }
    
    NSDictionary *apiResponse = [self sendPutRequestToURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@reads/%d", kLiveAPIEndPoint, readId]]
                                            withParameters:parameters
                                                     error:error];
    return apiResponse;

    
}


-(NSArray *)publicReadsForUserWithId:(ReadmillUserId)userId error:(NSError **)error {

    NSDictionary *apiResponse = [self sendGetRequestToURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@users/%d/reads", kLiveAPIEndPoint, userId]] 
                                           withParameters:nil
                                                    error:error];
    return [apiResponse valueForKey:@"read"];
}

-(NSArray *)publicReadsForUserWithName:(NSString *)userName error:(NSError **)error {
    
    if ([userName length] == 0) {
        return nil;
    } else {
        
        NSDictionary *apiResponse = [self sendGetRequestToURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@users/%@/reads", kLiveAPIEndPoint, userName]] 
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
    
    NSDictionary *apiResponse = [self sendPostRequestToURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@reads/%d/pings", kLiveAPIEndPoint, readId]] 
                                                withParameters:nil
                                                     error:error];
    return apiResponse;
    
}

// Users

-(NSDictionary *)userWithId:(ReadmillUserId)userId error:(NSError **)error {

    NSDictionary *apiResponse = [self sendGetRequestToURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@users/%d", kLiveAPIEndPoint, userId]] 
                                           withParameters:nil
                                                    error:error];
    return apiResponse;

}

-(NSDictionary *)userWithName:(NSString *)userName error:(NSError **)error {

    if ([userName length] == 0) {
        return nil;
    } else {
        
        NSDictionary *apiResponse = [self sendGetRequestToURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@users/%@", kLiveAPIEndPoint, userName]] 
                                               withParameters:nil
                                                        error:error];
        return apiResponse;
    }
}



- (void)dealloc {
    // Clean-up code here.
    
    [self setOAuthToken:nil];
    [self setOAuthSecret:nil];
    
    [super dealloc];
}

#pragma mark -
#pragma mark Sending Requests

-(NSDictionary *)sendPutRequestToURL:(NSURL *)url withParameters:(NSDictionary *)parameters error:(NSError **)error {
   
    OAConsumer *consumer = [[[OAConsumer alloc] initWithKey:@"" secret:@""] autorelease];
	OAToken *token = [[[OAToken alloc] initWithKey:[self oAuthSecret] secret:[self oAuthToken]] autorelease];
    
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
																   consumer:consumer
																	  token:token 
																	  realm:nil
														  signatureProvider:nil];
	[request setHTTPMethod:@"PUT"];
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-type"];
	[request setHTTPBody:[parameterString dataUsingEncoding:NSUTF8StringEncoding]];
	
	[request prepare]; 
	[request autorelease];
	
	return [self sendPreparedRequest:request error:error];	

}

-(NSDictionary *)sendPostRequestToURL:(NSURL *)url withParameters:(NSDictionary *)parameters error:(NSError **)error {
	
	OAConsumer *consumer = [[[OAConsumer alloc] initWithKey:@"" secret:@""] autorelease];
	OAToken *token = [[[OAToken alloc] initWithKey:[self oAuthSecret] secret:[self oAuthToken]] autorelease];
    
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
																   consumer:consumer
																	  token:token 
																	  realm:nil
														  signatureProvider:nil];
	[request setHTTPMethod:@"POST"];
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-type"];
	[request setHTTPBody:[parameterString dataUsingEncoding:NSUTF8StringEncoding]];
	
	[request prepare]; 
	[request autorelease];
	
	return [self sendPreparedRequest:request error:error];	
	
}

-(NSDictionary *)sendGetRequestToURL:(NSURL *)url withParameters:(NSDictionary *)parameters error:(NSError **)error {
	
	OAConsumer *consumer = [[[OAConsumer alloc] initWithKey:@"" secret:@""] autorelease];
	OAToken *token = [[[OAToken alloc] initWithKey:[self oAuthSecret] secret:[self oAuthToken]] autorelease];
	
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
																   consumer:consumer
																	  token:token 
																	  realm:nil
														  signatureProvider:nil];
	[request setHTTPMethod:@"GET"];
	
	[request prepare]; 
	[request autorelease];
	
	return [self sendPreparedRequest:request error:error];
}

-(NSDictionary *)sendPreparedRequest:(OAMutableURLRequest *)request error:(NSError **)error {
    
	NSHTTPURLResponse *response = nil;
	NSError *connectionError = nil;
	
	NSData *responseData = [NSURLConnection sendSynchronousRequest:request
												 returningResponse:&response
															 error:&connectionError];
	
	if (([response statusCode] != 200 && [response statusCode] != 201) || response == nil || connectionError != nil) {
		if (connectionError == nil) {
			
			NSDictionary *errorResponse = [self dictionaryForReadmillResponseData:responseData error:nil]; 
			
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
		// All was OK in the URL, let's try and parse the XML.
		
		NSError *parseError = nil;
		NSDictionary *dict = [self dictionaryForReadmillResponseData:responseData error:&parseError];
		
		if (parseError != nil) {
			if (error != NULL) {
				*error = parseError;
			}
			return nil;
		} else {
			return dict;
		}
	}	
}

-(NSDictionary *)dictionaryForReadmillResponseData:(NSData *)data error:(NSError **)error {
	return [ReadmillXMLParser dictionaryForXMLData:data error:error];
}


@end
