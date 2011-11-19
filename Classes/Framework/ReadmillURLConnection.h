//
//  ReadmillURLConnection.h
//  ReadmillAPI
//
//  Created by Martin Hwasser on 9/23/11.
//  Copyright (c) 2011 Readmill Network Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
typedef void (^ReadmillURLConnectionCompletionHandler)(NSHTTPURLResponse *response, NSData *responseData, NSError *error);

@interface ReadmillURLConnection : NSOperation {
    
@private
    NSMutableData *responseData;
    NSError *connectionError;
    NSHTTPURLResponse *response;
    NSURLRequest *request;
    NSURLConnection *connection;
    ReadmillURLConnectionCompletionHandler completionHandler;
    BOOL isExecuting, isFinished;
}
@property (nonatomic, copy) NSError *connectionError;
@property (nonatomic, retain) NSMutableData *responseData;
@property (nonatomic, retain) NSURLConnection *connection;
@property (nonatomic, copy) NSHTTPURLResponse *response;
@property (nonatomic, copy) NSURLRequest *request;
@property (nonatomic, assign) BOOL isExecuting, isFinished;
@property (nonatomic, readonly, copy) ReadmillURLConnectionCompletionHandler completionHandler;

- (id)initWithRequest:(NSURLRequest *)request completionHandler:(ReadmillURLConnectionCompletionHandler)completionHandler;

@end
