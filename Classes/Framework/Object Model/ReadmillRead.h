//
//  ReadmillRead.h
//  Readmill Framework
//
//  Created by Readmill on 13/01/2011.
//  Copyright 2011 Readmill. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ReadmillAPIWrapper.h"
#import "ReadmillReadSession.h"

@class ReadmillRead;

@protocol ReadmillReadUpdatingDelegate <NSObject>

-(void)readmillReadDidUpdateMetadataSuccessfully:(ReadmillRead *)read;
-(void)readmillRead:(ReadmillRead *)read didFailToUpdateMetadataWithError:(NSError *)error;

@end

@interface ReadmillRead : NSObject {
@private
    
    NSDate *dateAbandoned;
    NSDate *dateCreated;
    NSDate *dateFinished;
    NSDate *dateModified;
    NSDate *dateStarted;
    
    NSString *closingRemark;
    
    BOOL isPrivate;
    
    ReadmillReadState state;
    
    ReadmillBookId bookId;
    ReadmillUserId userId;
    ReadmillReadId readId;
    
    ReadmillAPIWrapper *apiWrapper;
}

-(id)initWithAPIDictionary:(NSDictionary *)apiDict apiWrapper:(ReadmillAPIWrapper *)wrapper;

-(void)updateWithAPIDictionary:(NSDictionary *)apiDict;

-(void)updateState:(ReadmillReadState)newState delegate:(id <ReadmillReadUpdatingDelegate>)delegate;
-(void)updateIsPrivate:(BOOL)isPrivate delegate:(id <ReadmillReadUpdatingDelegate>)delegate;
-(void)updateClosingRemark:(NSString *)newRemark delegate:(id <ReadmillReadUpdatingDelegate>)delegate;
-(void)updateWithState:(ReadmillReadState)newState isPrivate:(BOOL)readIsPrivate closingRemark:(NSString *)newRemark delegate:(id <ReadmillReadUpdatingDelegate>)delegate;

-(ReadmillReadSession *)createReadSession;
-(ReadmillReadSession *)createReadSessionWithExistingSessionId:(NSString *)sessionId;

@property (readonly, copy) NSDate *dateAbandoned;
@property (readonly, copy) NSDate *dateCreated;
@property (readonly, copy) NSDate *dateFinished;
@property (readonly, copy) NSDate *dateModified;
@property (readonly, copy) NSDate *dateStarted;

@property (readonly, copy) NSString *closingRemark;

@property (readonly) BOOL isPrivate;

@property (readonly) ReadmillReadState state;

@property (readonly) ReadmillBookId bookId;
@property (readonly) ReadmillUserId userId;
@property (readonly) ReadmillReadId readId;

@property (readonly, retain) ReadmillAPIWrapper *apiWrapper;

@end
