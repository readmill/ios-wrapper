//
//  ReadmillPing.h
//  Readmill
//
//  Created by Martin Hwasser on 4/5/11.
//  Copyright 2011 Readmill. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ReadmillAPIWrapper.h"

@interface ReadmillPing : NSObject <NSCoding> {
    NSDate *date;
    NSString *sessionIdentifier;
    ReadmillReadId readId;
    ReadmillReadProgress progress;
    ReadmillPingDuration duration;
    NSDate *occurenceTime;
}

@property (nonatomic, retain) NSString *sessionIdentifier;
@property (nonatomic, retain) NSDate *occurrenceTime;

@property (nonatomic, assign) ReadmillReadId readId;
@property (nonatomic, assign) ReadmillReadProgress progress;
@property (nonatomic, assign) ReadmillPingDuration duration;

- (id)initWithReadId:(ReadmillReadId)aReadId 
        readProgress:(ReadmillReadProgress)aProgress 
   sessionIdentifier:(NSString *)aSessionIdentifier 
            duration:(ReadmillPingDuration)aDuration 
      occurrenceTime:(NSDate *)anOccurrenceTime;

@end
