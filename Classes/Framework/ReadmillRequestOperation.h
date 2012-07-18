//
//  ReadmillURLConnection.h
//  ReadmillAPI
//
//  Created by Martin Hwasser on 9/23/11.
//  Copyright (c) 2011 Readmill Network Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void (^ReadmillRequestOperationCompletionBlock)(NSHTTPURLResponse *response, NSData *responseData, NSError *error);
typedef void (^ReadmillRequestOperationProgressBlock)(NSInteger bytes, long long totalBytes, long long totalBytesExpected);

@interface ReadmillRequestOperation : NSOperation <NSURLConnectionDataDelegate>

@property (nonatomic, copy) NSError *connectionError;
@property (nonatomic, readonly, retain) NSMutableData *responseData;
@property (nonatomic, retain) NSURLConnection *connection;
@property (nonatomic, copy) NSHTTPURLResponse *response;
@property (nonatomic, copy) NSURLRequest *request;
@property (nonatomic, assign) BOOL isExecuting, isFinished;
@property (nonatomic, readonly, copy) ReadmillRequestOperationCompletionBlock completionHandler;
@property (nonatomic, readonly, copy) ReadmillRequestOperationProgressBlock uploadProgressBlock;
@property (nonatomic, readonly, copy) ReadmillRequestOperationProgressBlock downloadProgressBlock;

@property (nonatomic, readonly) CGFloat uploadProgress;

- (id)initWithRequest:(NSURLRequest *)request completionHandler:(ReadmillRequestOperationCompletionBlock)completionHandler;

- (void)setUploadProgressBlock:(void (^)(NSInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite))block;
- (void)setDownloadProgressBlock:(void (^)(NSInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead))block;

- (void)setShouldExecuteAsBackgroundTaskWithExpirationHandler:(void (^)(void))handler;

@end
