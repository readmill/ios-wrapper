//
//  ReadmillAPIWrapper+Internal.m
//  ReadmillAPI
//
//  Created by Martin Hwasser on 1/18/12.
//  Copyright (c) 2012 Readmill Network LTD. All rights reserved.
//

#import "ReadmillAPIWrapper+Internal.h"
#import "ReadmillRequestOperation.h"
#import "NSURL+ReadmillURLParameters.h"
#import "JSONKit.h"

static NSString *const kReadmillAPIHeaderKey = @"X-Readmill-API";

@implementation ReadmillAPIWrapper (Internal)


#pragma mark -
#pragma mark - JSONDecoder 

- (JSONDecoder *)jsonDecoder 
{
    static JSONDecoder *jsonDecoder = nil;
    if (!jsonDecoder) {
        jsonDecoder = [[JSONDecoder alloc] init];
    }
    return jsonDecoder;
}

#pragma mark -
#pragma mark Creating requests

- (NSURLRequest *)getRequestWithURL:(NSURL *)url 
                         parameters:(NSDictionary *)parameters 
         shouldBeCalledUnauthorized:(BOOL)calledUnauthorized 
                        cachePolicy:(NSURLRequestCachePolicy)cachePolicy
                              error:(NSError **)error 
{    
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
                              error:(NSError **)error 
{
    return [self bodyRequestWithURL:url 
                         httpMethod:@"PUT"
                         parameters:parameters
         shouldBeCalledUnauthorized:NO
                              error:error];
}

- (NSURLRequest *)deleteRequestWithURL:(NSURL *)url
                            parameters:(NSDictionary *)parameters 
                                 error:(NSError **)error
{
    return [self bodyRequestWithURL:url 
                         httpMethod:@"DELETE"
                         parameters:parameters
         shouldBeCalledUnauthorized:NO
                              error:error];
}

- (NSURLRequest *)postRequestWithURL:(NSURL *)url
                          parameters:(NSDictionary *)parameters
                               error:(NSError **)error 
{
    return [self bodyRequestWithURL:url
                         httpMethod:@"POST"
                         parameters:parameters 
         shouldBeCalledUnauthorized:NO
                              error:error];
}

- (NSURLRequest *)bodyRequestWithURL:(NSURL *)url 
                          httpMethod:(NSString *)httpMethod
                          parameters:(NSDictionary *)parameters
          shouldBeCalledUnauthorized:(BOOL)allowUnauthed
                               error:(NSError **)error 
{    
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
          completionHandler:(ReadmillAPICompletionHandler)completionHandler 
{
    NSError *error = nil;
    NSURLRequest *request = [self putRequestWithURL:url 
                                         parameters:parameters 
                                              error:&error];
    
    if (request) {
        [self startPreparedRequest:request 
                        completion:completionHandler];
    } else {
        return completionHandler(nil, error);
    }
}

- (void)sendDeleteRequestToURL:(NSURL *)url
                withParameters:(NSDictionary *)parameters
             completionHandler:(ReadmillAPICompletionHandler)completionHandler
{
    NSError *error = nil;
    NSURLRequest *request = [self deleteRequestWithURL:url 
                                            parameters:parameters 
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
           completionHandler:(ReadmillAPICompletionHandler)completionHandler 
{
    NSError *error = nil;
    NSURLRequest *request = [self postRequestWithURL:url 
                                          parameters:parameters 
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

#pragma mark -
#pragma mark - Parsing response

- (id)parseResponse:(NSHTTPURLResponse *)response
   withResponseData:(NSData *)responseData
    connectionError:(NSError *)connectionError 
              error:(NSError **)error 
{   
    /* 
     * TODO - Error if not X-Readmill-API header (needs to be implemented for oauth route first)
     */
    BOOL isReadmillResponse = [[response allHeaderFields] objectForKey:kReadmillAPIHeaderKey] != nil;
    if (([response statusCode] != 200 && [response statusCode] != 201) || response == nil || connectionError != nil) {
        
		if (connectionError == nil) {
            if (error != NULL) {
                NSString *errorDomain = NSURLErrorDomain;
                if (isReadmillResponse) {
                    errorDomain = kReadmillDomain;
                }
                
                *error = [NSError errorWithDomain:errorDomain
                                             code:[response statusCode]
                                         userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                                   @"An unknown error occurred", NSLocalizedFailureReasonErrorKey, nil]];
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
            
            id result = nil;
            if ([response.MIMEType isEqualToString:@"application/json"]) {
                result = [[self jsonDecoder] objectWithData:responseData
                                                      error:&parseError];
            } else {
                result = responseData;
            }
            if (parseError != nil) {
                if (error != NULL) {
                    *error = parseError;
                }
            } else {
                return result;
            }
        }
        return nil;
	}	
}

- (void)startPreparedRequest:(NSURLRequest *)request
                  completion:(ReadmillAPICompletionHandler)completionBlock 
               queuePriority:(NSOperationQueuePriority)queuePriority
{    
    
    ReadmillRequestOperation *operation = [self operationWithRequest:request
                                                          completion:completionBlock];
    [operation setQueuePriority:queuePriority];
    [queue addOperation:operation];
}

- (void)startPreparedRequest:(NSURLRequest *)request 
                  completion:(ReadmillAPICompletionHandler)completionBlock
{
    [self startPreparedRequest:request 
                    completion:completionBlock
                 queuePriority:NSOperationQueuePriorityNormal];
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

@end
