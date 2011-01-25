//
//  ReadmillReadSession.h
//  Readmill Framework
//
//  Created by Readmill on 13/01/2011.
//  Copyright 2011 Readmill. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ReadmillAPIWrapper.h"

@class ReadmillReadSession;

@protocol ReadmillPingDelegate <NSObject>

-(void)readmillReadSessionDidPingSuccessfully:(ReadmillReadSession *)session;
-(void)readmillReadSession:(ReadmillReadSession *)session didFailToPingWithError:(NSError *)error;

@end

@interface ReadmillReadSession : NSObject {
@private
    
    NSDate *lastPingDate;
    NSString *sessionIdentifier;
    ReadmillAPIWrapper *apiWrapper;
    ReadmillReadId readId;
    
}

-(id)initWithAPIWrapper:(ReadmillAPIWrapper *)wrapper readId:(ReadmillReadId)sessionReadId;
-(id)initWithAPIWrapper:(ReadmillAPIWrapper *)wrapper readId:(ReadmillReadId)sessionReadId sessionId:(NSString *)sessionId;

@property (readonly, copy) NSDate *lastPingDate;
@property (readonly, copy) NSString *sessionIdentifier;
@property (readonly, retain) ReadmillAPIWrapper *apiWrapper;
@property (readonly) ReadmillReadId readId;

-(void)pingWithProgress:(ReadmillReadProgress)progress delegate:(id <ReadmillPingDelegate>)delegate;

@end
