//
//  ReadmillURLConnection.h
//  ReadmillAPI
//
//  Created by Martin Hwasser on 9/23/11.
//  Copyright (c) 2011 KennettNet Software Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^ReadmillURLConnectionCompletionHandler)(NSHTTPURLResponse *response, NSData *responseData, NSError *error);

@interface ReadmillURLConnection : NSOperation {
    
@private
    NSMutableData *responseData;
    NSError *connectionError;
    NSHTTPURLResponse *response;
    NSURLRequest *request;
    NSURLConnection *connection;
    BOOL isExecuting, isFinished;
}
@property (nonatomic, copy) NSError *connectionError;
@property (nonatomic, retain) NSMutableData *responseData;
@property (nonatomic, retain) NSURLConnection *connection;
@property (nonatomic, copy) NSHTTPURLResponse *response;
@property (nonatomic, copy) NSURLRequest *request;
@property (nonatomic, assign) BOOL isExecuting, isFinished;

- (id)initWithRequest:(NSURLRequest *)request completionHandler:(ReadmillURLConnectionCompletionHandler)completionHandler;

@end