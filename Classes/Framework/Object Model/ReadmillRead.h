//
//  ReadmillRead.h
//  Readmill Framework
//
//  Created by Work on 13/01/2011.
//  Copyright 2011 KennettNet Software Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ReadmillAPIWrapper.h"

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
