//
//  ReadmillAPIWrapper+Internal.h
//  ReadmillAPI
//
//  Created by Martin Hwasser on 1/18/12.
//  Copyright (c) 2012 Readmill Network LTD. All rights reserved.
//

#import "ReadmillAPIWrapper.h"

@interface ReadmillAPIWrapper (Internal)

- (NSURL *)urlWithEndpoint:(NSString *)endpoint;

- (id)sendPreparedRequest:(NSURLRequest *)request error:(NSError **)error;

- (NSURLRequest *)putRequestWithEndpoint:(NSString *)endpoint
                              parameters:(NSDictionary *)parameters
                                   error:(NSError **)error;

- (NSURLRequest *)deleteRequestWithEndpoint:(NSString *)endpoint
                                 parameters:(NSDictionary *)parameters
                                      error:(NSError **)error;

- (NSURLRequest *)postRequestWithEndpoint:(NSString *)endpoint
                               parameters:(NSDictionary *)parameters
                                    error:(NSError **)error;

- (NSURLRequest *)getRequestWithURL:(NSURL *)url
                         parameters:(NSDictionary *)parameters
         shouldBeCalledUnauthorized:(BOOL)allowUnauthed
                        cachePolicy:(NSURLRequestCachePolicy)cachePolicy
                              error:(NSError **)error;

- (NSURLRequest *)getRequestWithEndpoint:(NSString *)endpoint
                              parameters:(NSDictionary *)parameters
              shouldBeCalledUnauthorized:(BOOL)allowUnauthed
                             cachePolicy:(NSURLRequestCachePolicy)cachePolicy
                                   error:(NSError **)error;

- (NSURLRequest *)getRequestWithEndpoint:(NSString *)endpoint
                              parameters:(NSDictionary *)parameters
              shouldBeCalledUnauthorized:(BOOL)allowUnauthed
                                   error:(NSError **)error;

- (NSURLRequest *)bodyRequestWithEndpoint:(NSString *)endpoint
                               httpMethod:(NSString *)httpMethod
                               parameters:(NSDictionary *)parameters
               shouldBeCalledUnauthorized:(BOOL)allowUnauthed
                                    error:(NSError **)error;

- (ReadmillRequestOperation *)sendPutRequestToEndpoint:(NSString *)endpoint
                                        withParameters:(NSDictionary *)parameters
                                     completionHandler:(ReadmillAPICompletionHandler)completionHandler;

- (ReadmillRequestOperation *)sendDeleteRequestToEndpoint:(NSString *)endpoint
                                           withParameters:(NSDictionary *)parameters
                                        completionHandler:(ReadmillAPICompletionHandler)completionHandler;

- (ReadmillRequestOperation *)sendPostRequestToEndpoint:(NSString *)endpoint
                                         withParameters:(NSDictionary *)parameters
                                      completionHandler:(ReadmillAPICompletionHandler)completionHandler;

- (ReadmillRequestOperation *)sendGetRequestToEndpoint:(NSString *)endpoint
                                        withParameters:(NSDictionary *)parameters
                            shouldBeCalledUnauthorized:(BOOL)allowUnauthed
                                           cachePolicy:(NSURLRequestCachePolicy)cachePolicy
                                     completionHandler:(ReadmillAPICompletionHandler)completionHandler;

- (ReadmillRequestOperation *)sendGetRequestToEndpoint:(NSString *)endpoint
                                        withParameters:(NSDictionary *)parameters
                            shouldBeCalledUnauthorized:(BOOL)allowUnauthed
                                     completionHandler:(ReadmillAPICompletionHandler)completionHandler;

- (ReadmillRequestOperation *)sendBodyRequestToEndpoint:(NSString *)endpoint
                                             httpMethod:(NSString *)httpMethod
                                         withParameters:(NSDictionary *)parameters
                             shouldBeCalledUnauthorized:(BOOL)allowUnauthed
                                      completionHandler:(ReadmillAPICompletionHandler)completionHandler;

- (ReadmillRequestOperation *)startPreparedRequest:(NSURLRequest *)request
                                        completion:(ReadmillAPICompletionHandler)completionBlock;

- (ReadmillRequestOperation *)startPreparedRequest:(NSURLRequest *)request
                                        completion:(ReadmillAPICompletionHandler)completionBlock
                                     queuePriority:(NSOperationQueuePriority)queuePriority;

- (id)parseResponse:(NSHTTPURLResponse *)response
   withResponseData:(NSData *)responseData
    connectionError:(NSError *)connectionError
              error:(NSError **)error;

@end
