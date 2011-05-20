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
    NSString *sessionIdentifier;
    ReadmillReadingId readId;
    ReadmillReadingProgress progress;
    ReadmillPingDuration duration;
    CLLocationDegrees latitude, longitude;
    NSDate *occurrenceTime;
}

@property (nonatomic, retain, readonly) NSString *sessionIdentifier;
@property (nonatomic, retain, readonly) NSDate *occurrenceTime;

@property (nonatomic, readonly) ReadmillReadingId readId;
@property (nonatomic, readonly) ReadmillReadingProgress progress;
@property (nonatomic, readonly) ReadmillPingDuration duration;
@property (nonatomic, readonly) CLLocationDegrees latitude;
@property (nonatomic, readonly) CLLocationDegrees longitude;

- (id)initWithReadId:(ReadmillReadingId)aReadId 
        readProgress:(ReadmillReadingProgress)aProgress 
   sessionIdentifier:(NSString *)aSessionIdentifier 
            duration:(ReadmillPingDuration)aDuration 
      occurrenceTime:(NSDate *)anOccurrenceTime
            latitude:(CLLocationDegrees)latitude
           longitude:(CLLocationDegrees)longitude;

@end
