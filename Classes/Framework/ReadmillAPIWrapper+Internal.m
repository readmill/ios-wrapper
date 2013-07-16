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

static NSString *const kReadmillAPIHeaderKey = @"X-Readmill-API";

@implementation ReadmillAPIWrapper (Internal)


#pragma mark -
#pragma mark Creating requests

- (NSURL *)urlWithEndpoint:(NSString *)endpoint
{
    return [[[self apiConfiguration] apiBaseURL] URLByAppendingPathComponent:endpoint];
}

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
    
    url = [url URLByAddingQueryParameters:finalParameters];
    [finalParameters release];
    
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url
                                                                cachePolicy:cachePolicy
                                                            timeoutInterval:kTimeoutInterval];
    
	[request setHTTPMethod:@"GET"];
    [request setValue:@"application/json" forHTTPHeaderField:@"accept"];
    [request setTimeoutInterval:kTimeoutInterval];
    return [request autorelease];
}

- (NSURLRequest *)getRequestWithEndpoint:(NSString *)endpoint
                              parameters:(NSDictionary *)parameters
              shouldBeCalledUnauthorized:(BOOL)calledUnauthorized
                             cachePolicy:(NSURLRequestCachePolicy)cachePolicy
                                   error:(NSError **)error
{
    return [self getRequestWithURL:[self urlWithEndpoint:endpoint]
                        parameters:parameters
        shouldBeCalledUnauthorized:calledUnauthorized
                       cachePolicy:cachePolicy
                             error:error];
}

- (NSURLRequest *)getRequestWithEndpoint:(NSString *)endpoint
                              parameters:(NSDictionary *)parameters
              shouldBeCalledUnauthorized:(BOOL)allowUnauthed
                                   error:(NSError **)error
{
    return [self getRequestWithEndpoint:endpoint
                             parameters:parameters
             shouldBeCalledUnauthorized:allowUnauthed
                            cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                  error:error];
}

- (NSURLRequest *)putRequestWithEndpoint:(NSString *)endpoint
                              parameters:(NSDictionary *)parameters
                                   error:(NSError **)error
{
    return [self bodyRequestWithEndpoint:endpoint
                              httpMethod:@"PUT"
                              parameters:parameters
              shouldBeCalledUnauthorized:NO
                                   error:error];
}

- (NSURLRequest *)deleteRequestWithEndpoint:(NSString *)endpoint
                                 parameters:(NSDictionary *)parameters
                                      error:(NSError **)error
{
    return [self bodyRequestWithEndpoint:endpoint
                              httpMethod:@"DELETE"
                              parameters:parameters
              shouldBeCalledUnauthorized:NO
                                   error:error];
}

- (NSURLRequest *)postRequestWithEndpoint:(NSString *)endpoint
                               parameters:(NSDictionary *)parameters
                                    error:(NSError **)error
{
    return [self bodyRequestWithEndpoint:endpoint
                              httpMethod:@"POST"
                              parameters:parameters
              shouldBeCalledUnauthorized:NO
                                   error:error];
}

- (NSURLRequest *)bodyRequestWithEndpoint:(NSString *)endpoint
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
    
    NSURL *url = [[[self apiConfiguration] apiBaseURL] URLByAppendingPathComponent:endpoint];
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
	[request setHTTPMethod:httpMethod];
	[request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
	[request setHTTPBody:[NSJSONSerialization dataWithJSONObject:finalParameters options:0 error:nil]];
    [request setValue:@"application/json" forHTTPHeaderField:@"accept"];
    [request setTimeoutInterval:kTimeoutInterval];
    
    [finalParameters release];
    return [request autorelease];
}

#pragma mark -
#pragma mark - Sending requests

- (ReadmillRequestOperation *)sendGetRequestToEndpoint:(NSString *)endpoint
                                        withParameters:(NSDictionary *)parameters
                            shouldBeCalledUnauthorized:(BOOL)allowUnauthed
                                           cachePolicy:(NSURLRequestCachePolicy)cachePolicy
                                     completionHandler:(ReadmillAPICompletionHandler)completionHandler
{
    NSError *error = nil;
    NSURLRequest *request = [self getRequestWithEndpoint:endpoint
                                              parameters:parameters
                              shouldBeCalledUnauthorized:allowUnauthed
                                             cachePolicy:cachePolicy
                                                   error:&error];
    
    if (request) {
        return [self startPreparedRequest:request
                               completion:completionHandler];
    } else {
        completionHandler(nil, error);
        return nil;
    }
}

- (ReadmillRequestOperation *)sendGetRequestToEndpoint:(NSString *)endpoint
                                        withParameters:(NSDictionary *)parameters
                            shouldBeCalledUnauthorized:(BOOL)allowUnauthed
                                     completionHandler:(ReadmillAPICompletionHandler)completionHandler
{
    NSError *error = nil;
    NSURLRequest *request = [self getRequestWithEndpoint:endpoint
                                              parameters:parameters
                              shouldBeCalledUnauthorized:allowUnauthed
                                             cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                   error:&error];
    
    if (request) {
        return [self startPreparedRequest:request
                               completion:completionHandler];
    } else {
        completionHandler(nil, error);
        return nil;
    }
}

- (ReadmillRequestOperation *)sendPutRequestToEndpoint:(NSString *)endpoint
                                        withParameters:(NSDictionary *)parameters
                                     completionHandler:(ReadmillAPICompletionHandler)completionHandler
{
    NSError *error = nil;
    NSURLRequest *request = [self putRequestWithEndpoint:endpoint
                                              parameters:parameters
                                                   error:&error];
    
    if (request) {
        return [self startPreparedRequest:request
                               completion:completionHandler];
    } else {
        completionHandler(nil, error);
        return nil;
    }
}

- (ReadmillRequestOperation *)sendDeleteRequestToEndpoint:(NSString *)endpoint
                                           withParameters:(NSDictionary *)parameters
                                        completionHandler:(ReadmillAPICompletionHandler)completionHandler
{
    NSError *error = nil;
    NSURLRequest *request = [self deleteRequestWithEndpoint:endpoint
                                                 parameters:parameters
                                                      error:&error];
    
    if (request) {
        return [self startPreparedRequest:request
                               completion:completionHandler];
    } else {
        completionHandler(nil, error);
        return nil;
    }
}

- (ReadmillRequestOperation *)sendPostRequestToEndpoint:(NSString *)endpoint
                                         withParameters:(NSDictionary *)parameters
                                      completionHandler:(ReadmillAPICompletionHandler)completionHandler
{
    NSError *error = nil;
    NSURLRequest *request = [self postRequestWithEndpoint:endpoint
                                               parameters:parameters
                                                    error:&error];
    
    if (request) {
        return [self startPreparedRequest:request
                               completion:completionHandler];
    } else {
        completionHandler(nil, error);
        return nil;
    }
}

- (ReadmillRequestOperation *)sendBodyRequestToEndpoint:(NSString *)endpoint
                       httpMethod:(NSString *)httpMethod
                   withParameters:(NSDictionary *)parameters
       shouldBeCalledUnauthorized:(BOOL)allowUnauthed
                completionHandler:(ReadmillAPICompletionHandler)completionHandler
{
    NSError *error = nil;
    
    NSURLRequest *request = [self bodyRequestWithEndpoint:endpoint
                                               httpMethod:httpMethod
                                               parameters:parameters
                               shouldBeCalledUnauthorized:allowUnauthed
                                                    error:&error];
    
    if (request) {
        return [self startPreparedRequest:request
                               completion:completionHandler];
    } else {
        completionHandler(nil, error);
        return nil;
    }
}

#pragma mark -
#pragma mark - Parsing response

- (id)parseResponse:(NSHTTPURLResponse *)response
   withResponseData:(NSData *)responseData
    connectionError:(NSError *)connectionError
              error:(NSError **)error
{
    id result = nil;
    NSError *parseError = nil;
    
    if (responseData) {
        if ([response.MIMEType isEqualToString:@"application/json"]) {
            result = [NSJSONSerialization JSONObjectWithData:responseData
                                                     options:0
                                                       error:&parseError];
        }
    }
    
    if (([response statusCode] != 200 && [response statusCode] != 201) // Not OK statusCode
        || response == nil || result == nil // Response or result == nil
        || connectionError != nil || parseError != nil) { // Errors NOT nil
        
        // No need to find out what went wrong
        if (error == NULL) return nil;
        
        if (connectionError != nil) {
            // There was a connection error
            *error = connectionError;
        } else if (parseError != nil) {
            // There was a problem parsing the JSON
            *error = parseError;
        } else {
            /*
             *  No connection error and no parsing error.
             *  (i.e. resource does not exist, or malformed request)
             *
             *  It's a valid Readmill response if there's a JSON status code
             *  equal to the response code.
             */
            BOOL isReadmillResponse = [[result valueForKey:@"status"] integerValue] == response.statusCode;
            
            // Unknown case
            NSString *localizedFailureReasonString = @"An unknown error occurred.";
            NSString *errorDomain = NSURLErrorDomain;
            
            if (isReadmillResponse) {
                // Belongs to Readmill
                errorDomain = kReadmillDomain;
                NSString *errorString = [[result valueForKey:@"error"] description];
                if (errorString) {
                    // We have an error string in the response JSON
                    localizedFailureReasonString = errorString;
                }
                
                if (response.statusCode == 409) {
                    
                }
            }
            
            *error = [NSError errorWithDomain:errorDomain
                                         code:[response statusCode]
                                     userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                               localizedFailureReasonString, NSLocalizedFailureReasonErrorKey, nil]];
		}
    }
    return result;
}

- (ReadmillRequestOperation *)startPreparedRequest:(NSURLRequest *)request
                                        completion:(ReadmillAPICompletionHandler)completionBlock
                                     queuePriority:(NSOperationQueuePriority)queuePriority
{
    
    ReadmillRequestOperation *operation = [self operationWithRequest:request
                                                          completion:completionBlock];
    [operation setQueuePriority:queuePriority];
    [self.queue addOperation:operation];
    
    return operation;
}

- (ReadmillRequestOperation *)startPreparedRequest:(NSURLRequest *)request
                                        completion:(ReadmillAPICompletionHandler)completionBlock
{
    return [self startPreparedRequest:request
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
