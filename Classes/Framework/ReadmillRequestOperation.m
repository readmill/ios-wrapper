//
//  ReadmillURLConnection.m
//  ReadmillAPI
//
//  Created by Martin Hwasser on 9/23/11.
//  Copyright (c) 2011 Readmill Network Limited. All rights reserved.
//

#import "ReadmillRequestOperation.h"
#import "UIApplication+ReadmillNetworkActivity.h"

@interface ReadmillRequestOperation ()

- (void)finish;

@property (nonatomic, readwrite, copy) ReadmillRequestOperationCompletionBlock completionHandler;
@property (nonatomic, readwrite, retain) NSMutableData *responseData;
@property (nonatomic, readwrite, copy) ReadmillRequestOperationProgressBlock uploadProgressBlock;
@property (nonatomic, readwrite, copy) ReadmillRequestOperationProgressBlock downloadProgressBlock;
@property (nonatomic, readwrite) float uploadProgress;

#if defined(__IPHONE_OS_VERSION_MIN_REQUIRED)
@property (nonatomic) UIBackgroundTaskIdentifier backgroundTaskIdentifier;
#endif

@end

@implementation ReadmillRequestOperation

- (id)initWithRequest:(NSURLRequest *)request
    completionHandler:(ReadmillRequestOperationCompletionBlock)completionHandler 
{
    self = [super init];
    if (self) {
        // Initialization
        _completionHandler = [completionHandler copy];
        [self setRequest:request];
    }
    return self;
}


- (void)dealloc 
{
    [self setCompletionHandler:nil];
    [self setConnection:nil];
    [self setConnectionError:nil];
    [self setResponse:nil];
    [self setResponseData:nil];
    [self setRequest:nil];
    [self setUploadProgressBlock:nil];
    [self setDownloadProgressBlock:nil];

    #if defined(__IPHONE_OS_VERSION_MIN_REQUIRED)
    if (_backgroundTaskIdentifier) {
        [[UIApplication sharedApplication] endBackgroundTask:_backgroundTaskIdentifier];
        [self setBackgroundTaskIdentifier:UIBackgroundTaskInvalid];
    }
    #endif

    [super dealloc];
}

@synthesize completionHandler = _completionHandler;
@synthesize connectionError = _connectionError;
@synthesize responseData = _responseData;
@synthesize connection = _connection;
@synthesize response = _response;
@synthesize request = _request;
@synthesize isFinished = _isFinished;
@synthesize isExecuting = _isExecuting;
@synthesize uploadProgressBlock = _uploadProgressBlock;
@synthesize downloadProgressBlock = _downloadProgressBlock;
@synthesize uploadProgress = _uploadProgress;

#if defined(__IPHONE_OS_VERSION_MIN_REQUIRED)
@synthesize backgroundTaskIdentifier = _backgroundTaskIdentifier;
#endif

- (BOOL)isConcurrent 
{
    return YES;
}

- (void)start 
{
    if (![NSThread isMainThread]) {
        return [self performSelectorOnMainThread:@selector(start) withObject:nil waitUntilDone:NO];
    }
        
    [self willChangeValueForKey:@"isExecuting"];
    _isExecuting = YES;
    [self didChangeValueForKey:@"isExecuting"];
    
    NSURLConnection *aConnection = [[NSURLConnection alloc] initWithRequest:self.request 
                                                                   delegate:self
                                                           startImmediately:NO];
    
    self.connection = aConnection;
    [aConnection release];

    #if defined(__IPHONE_OS_VERSION_MIN_REQUIRED)
    [[UIApplication sharedApplication] readmill_pushNetworkActivity];
    #endif

    if (self.connection == nil || [self isCancelled]) {
        [self cancelConnectionIfCancelled];
    } else {
        [self.connection start];
    }
}

- (void)finish 
{
    if (self.connectionError) {
        DLog(@"Operation for url: %@ finished with status code: %d, error: %@, data size: %u", 
              [self.request URL], [self.response statusCode], [self.connectionError localizedDescription], [self.responseData length]);
    } else {
        DLog(@"Operation for url: %@ finished with status code: %d, data size: %u", 
              [self.request URL], [self.response statusCode], [self.responseData length]);
    }

    #if defined(__IPHONE_OS_VERSION_MIN_REQUIRED)
    [[UIApplication sharedApplication] readmill_popNetworkActivity];
    #endif
    
    if (self.completionHandler) {
        self.completionHandler(self.response, self.responseData, self.connectionError);        
    }

    [self willChangeValueForKey:@"isExecuting"];
    [self willChangeValueForKey:@"isFinished"];
    
    _isExecuting = NO;
    _isFinished = YES;
    
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)err 
{
    self.connectionError = err;
    [self finish];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data 
{    
    [self.responseData appendData:data];
    if (self.downloadProgressBlock) {
        self.downloadProgressBlock((long long)[data length], [self.responseData length], self.response.expectedContentLength);
    }
    
    [self cancelConnectionIfCancelled];
}

- (void)connection:(NSURLConnection *)conn didReceiveResponse:(NSURLResponse *)aResponse 
{
    self.response = (NSHTTPURLResponse *)aResponse;
    
    NSMutableData *data = [[NSMutableData alloc] init];
    self.responseData = data;
    [data release];
}

- (void)cancelConnectionIfCancelled
{
    if ([self isCancelled]) {
        [self.connection cancel];
        
        NSDictionary *userInfo = nil;
        if ([self.request URL]) {
            userInfo = [NSDictionary dictionaryWithObject:[self.request URL] 
                                                   forKey:NSURLErrorFailingURLErrorKey];
        }
        [self performSelector:@selector(connection:didFailWithError:) 
                   withObject:self.connection
                   withObject:[NSError errorWithDomain:NSURLErrorDomain 
                                                  code:NSURLErrorCancelled 
                                              userInfo:userInfo]];
    }
}

- (void)connection:(NSURLConnection *)connection
   didSendBodyData:(NSInteger)bytesWritten
 totalBytesWritten:(NSInteger)totalBytesWritten
totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    if (self.uploadProgressBlock) {
        self.uploadProgressBlock(bytesWritten, totalBytesWritten, totalBytesExpectedToWrite);
    }
    self.uploadProgress = 1.0 * totalBytesWritten / totalBytesExpectedToWrite;

    [self cancelConnectionIfCancelled];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection 
{
    [self finish];
}

#if defined(__IPHONE_OS_VERSION_MIN_REQUIRED)
- (void)setShouldExecuteAsBackgroundTaskWithExpirationHandler:(void (^)(void))handler 
{
    if (!self.backgroundTaskIdentifier) {
        __block __typeof(&*self) weakSelf = self;
        UIApplication *application = [UIApplication sharedApplication];
        self.backgroundTaskIdentifier = [application beginBackgroundTaskWithExpirationHandler:^{
            __strong __typeof(&*weakSelf) strongSelf = weakSelf;
            if (handler) {
                handler();
            }
            
            if (strongSelf) {
                [strongSelf cancel];
                
                [application endBackgroundTask:strongSelf.backgroundTaskIdentifier];
                strongSelf.backgroundTaskIdentifier = UIBackgroundTaskInvalid;
            }
        }];
    }
}
#endif

@end

