//
//  ReadmillURLConnection.m
//  ReadmillAPI
//
//  Created by Martin Hwasser on 9/23/11.
//  Copyright (c) 2011 Readmill Network Limited. All rights reserved.
//

#import "ReadmillURLConnection.h"
#import "UIApplication+ReadmillNetworkActivity.h"

@interface ReadmillURLConnection ()

- (void)finish;

@property (nonatomic, readwrite, copy) ReadmillURLConnectionCompletionHandler completionHandler;
@property (nonatomic, readwrite, retain) NSMutableData *responseData;
@end

@implementation ReadmillURLConnection

- (id)initWithRequest:(NSURLRequest *)aRequest completionHandler:(ReadmillURLConnectionCompletionHandler)aCompletionHandler 
{
    self = [super init];
    if (self) {
        // Initialization
        
        completionHandler = [aCompletionHandler copy];
        [self setRequest:aRequest];
    }
    return self;
}
- (void)dealloc 
{
    [self setCompletionHandler:nil], completionHandler = nil;
    [self setConnection:nil], connection = nil;
    [self setConnectionError:nil], connectionError = nil;
    [self setResponse:nil], response = nil;
    [self setResponseData:nil], responseData = nil;
    [self setRequest:nil], request = nil;
    [super dealloc];
}

@synthesize completionHandler;
@synthesize connectionError;
@synthesize responseData;
@synthesize connection;
@synthesize response;
@synthesize request;
@synthesize isFinished, isExecuting;

- (BOOL)isConcurrent 
{
    return YES;
}

- (void)start 
{
    if (![NSThread isMainThread]) {
        return [self performSelectorOnMainThread:@selector(start) withObject:nil waitUntilDone:NO];
    }
    
    NSLog(@"operation for <%@> started.", [request URL]);
    
    [self willChangeValueForKey:@"isExecuting"];
    isExecuting = YES;
    [self didChangeValueForKey:@"isExecuting"];
    
    NSURLConnection *aConnection = [[NSURLConnection alloc] initWithRequest:request 
                                                                   delegate:self];
    
    self.connection = aConnection;
    [aConnection release];
    
    if (connection == nil) {
        [self finish];
    } else {
        [[UIApplication sharedApplication] readmill_pushNetworkActivity];
    }
}

- (void)finish 
{
    NSLog(@"Operation finished with status code: %d, error: %@, data size: %u", response.statusCode, connectionError, [responseData length]);

    [[UIApplication sharedApplication] readmill_popNetworkActivity];
    
    completionHandler(self.response, self.responseData, self.connectionError);        

    [self willChangeValueForKey:@"isExecuting"];
    [self willChangeValueForKey:@"isFinished"];
    
    isExecuting = NO;
    isFinished = YES;
    
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
    [responseData appendData:data];
}

- (void)connection:(NSURLConnection *)conn didReceiveResponse:(NSURLResponse *)aResponse 
{
    self.response = (NSHTTPURLResponse *)aResponse;
    
    NSMutableData *data = [[NSMutableData alloc] init];
    self.responseData = data;
    [data release];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection 
{
    [self finish];
}
@end

