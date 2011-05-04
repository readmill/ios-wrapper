//
//  ReadmillPing.h
//  Readmill
//
//  Created by Martin Hwasser on 4/5/11.
//  Copyright 2011 Readmill. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ReadmillAPI/ReadmillAPIWrapper.h>

@interface ReadmillPing : NSObject <NSCoding> {
    NSDate *date;
    NSString *sessionIdentifier;
    ReadmillReadId readId;
    ReadmillReadProgress progress;
    ReadmillPingDuration duration;
    CLLocationDegrees latitude, longitude;
    NSDate *occurenceTime;
}

@property (nonatomic, retain, readonly) NSString *sessionIdentifier;
@property (nonatomic, retain, readonly) NSDate *occurrenceTime;

@property (nonatomic, readonly) ReadmillReadId readId;
@property (nonatomic, readonly) ReadmillReadProgress progress;
@property (nonatomic, readonly) ReadmillPingDuration duration;
@property (nonatomic, readonly) CLLocationDegrees latitude;
@property (nonatomic, readonly) CLLocationDegrees longitude;

- (id)initWithReadId:(ReadmillReadId)aReadId 
        readProgress:(ReadmillReadProgress)aProgress 
   sessionIdentifier:(NSString *)aSessionIdentifier 
            duration:(ReadmillPingDuration)aDuration 
      occurrenceTime:(NSDate *)anOccurrenceTime
            latitude:(CLLocationDegrees)latitude
           longitude:(CLLocationDegrees)longitude;

@end
