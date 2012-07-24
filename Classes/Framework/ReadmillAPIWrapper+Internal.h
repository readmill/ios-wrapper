//
//  ReadmillAPIWrapper+Internal.h
//  ReadmillAPI
//
//  Created by Martin Hwasser on 1/18/12.
//  Copyright (c) 2012 Readmill Network LTD. All rights reserved.
//

#import "ReadmillAPIWrapper.h"

@interface ReadmillAPIWrapper (Internal)

- (id)sendPreparedRequest:(NSURLRequest *)request error:(NSError **)error;

- (NSURLRequest *)putRequestWithURL:(NSURL *)url 
                         parameters:(NSDictionary *)parameters
                              error:(NSError **)error;

- (NSURLRequest *)deleteRequestWithURL:(NSURL *)url
                            parameters:(NSDictionary *)parameters
                                 error:(NSError **)error;

- (NSURLRequest *)postRequestWithURL:(NSURL *)url
                          parameters:(NSDictionary *)parameters
                               error:(NSError **)error;

- (NSURLRequest *)getRequestWithURL:(NSURL *)url
                         parameters:(NSDictionary *)parameters 
         shouldBeCalledUnauthorized:(BOOL)allowUnauthed 
                        cachePolicy:(NSURLRequestCachePolicy)cachePolicy
                              error:(NSError **)error;

- (NSURLRequest *)getRequestWithURL:(NSURL *)url
                         parameters:(NSDictionary *)parameters 
         shouldBeCalledUnauthorized:(BOOL)allowUnauthed
                              error:(NSError **)error;

- (NSURLRequest *)bodyRequestWithURL:(NSURL *)url
                          httpMethod:(NSString *)httpMethod 
                          parameters:(NSDictionary *)parameters
          shouldBeCalledUnauthorized:(BOOL)allowUnauthed
                               error:(NSError **)error;

- (void)sendPutRequestToURL:(NSURL *)url
             withParameters:(NSDictionary *)parameters 
          completionHandler:(ReadmillAPICompletionHandler)completionHandler;

- (void)sendDeleteRequestToURL:(NSURL *)url 
                withParameters:(NSDictionary *)parameters 
             completionHandler:(ReadmillAPICompletionHandler)completionHandler;

- (void)sendPostRequestToURL:(NSURL *)url
              withParameters:(NSDictionary *)parameters
           completionHandler:(ReadmillAPICompletionHandler)completionHandler;

- (void)sendGetRequestToURL:(NSURL *)url
             withParameters:(NSDictionary *)parameters 
 shouldBeCalledUnauthorized:(BOOL)allowUnauthed
                cachePolicy:(NSURLRequestCachePolicy)cachePolicy
          completionHandler:(ReadmillAPICompletionHandler)completionHandler;

- (void)sendGetRequestToURL:(NSURL *)url
             withParameters:(NSDictionary *)parameters 
 shouldBeCalledUnauthorized:(BOOL)allowUnauthed
          completionHandler:(ReadmillAPICompletionHandler)completionHandler;

- (void)sendBodyRequestToURL:(NSURL *)url 
                  httpMethod:(NSString *)httpMethod
              withParameters:(NSDictionary *)parameters 
  shouldBeCalledUnauthorized:(BOOL)allowUnauthed
           completionHandler:(ReadmillAPICompletionHandler)completionHandler;

- (void)startPreparedRequest:(NSURLRequest *)request completion:(ReadmillAPICompletionHandler)completionBlock;

- (void)startPreparedRequest:(NSURLRequest *)request
                  completion:(ReadmillAPICompletionHandler)completionBlock 
               queuePriority:(NSOperationQueuePriority)queuePriority;

- (id)parseResponse:(NSHTTPURLResponse *)response
   withResponseData:(NSData *)responseData
    connectionError:(NSError *)connectionError 
              error:(NSError **)error;

@end
