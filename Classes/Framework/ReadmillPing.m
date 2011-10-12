//
//  ReadmillPing.m
//  Readmill
//
//  Created by Martin Hwasser on 4/5/11.
//  Copyright 2011 Readmill. All rights reserved.
//

#import "ReadmillPing.h"
@interface ReadmillPing ()
@property (nonatomic, readwrite, retain) NSString *sessionIdentifier;
@property (nonatomic, readwrite, retain) NSDate *occurrenceTime;
@end

@implementation ReadmillPing
@synthesize sessionIdentifier;
@synthesize occurrenceTime;
@synthesize readingId, progress, duration, latitude, longitude;

- (id)initWithReadingId:(ReadmillReadingId)aReadingId 
        readingProgress:(ReadmillReadingProgress)aProgress 
      sessionIdentifier:(NSString *)aSessionIdentifier 
               duration:(ReadmillPingDuration)aDuration 
         occurrenceTime:(NSDate *)anOccurrenceTime
               latitude:(CLLocationDegrees)lat
              longitude:(CLLocationDegrees)lng {
    
    self = [super init];
    if (self) {
        readingId = aReadingId;
        progress = aProgress;
        duration = aDuration;
        latitude = lat;
        longitude = lng;
        
        self.sessionIdentifier = aSessionIdentifier;
        self.occurrenceTime = anOccurrenceTime;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder 
{ 
    [coder encodeInteger:readingId forKey:@"readingId"];
    [coder encodeFloat:progress forKey:@"progress"];
    [coder encodeObject:sessionIdentifier forKey:@"sessionIdentifier"];
    [coder encodeInteger:duration forKey:@"duration"];
    [coder encodeObject:occurrenceTime forKey:@"occurrenceTime"];     
    [coder encodeDouble:latitude forKey:@"latitude"];
    [coder encodeDouble:longitude forKey:@"longitude"];
} 

- (id)initWithCoder:(NSCoder *)coder 
{ 
    self = [super init];
    if (self) {
        readingId = [coder decodeIntegerForKey:@"readingId"];
        progress = [coder decodeFloatForKey:@"progress"];
        duration = [coder decodeIntegerForKey:@"duration"];
        latitude = [coder decodeDoubleForKey:@"latitude"];
        longitude = [coder decodeDoubleForKey:@"longitude"];
        
        self.sessionIdentifier = [coder decodeObjectForKey:@"sessionIdentifier"];
        self.occurrenceTime = [coder decodeObjectForKey:@"occurrenceTime"];
    }
    return self; 
}
- (NSString *)description {
    return [NSString stringWithFormat:@"%@ readingId: %d, progress: %f, sessionIdentifier: %@, duration: %d, occurrenceTime:%@, lat: %f, lng: %f", 
            [super description], [self readingId], [self progress], [self sessionIdentifier], [self duration], [self occurrenceTime], latitude, longitude];

}
- (void)dealloc {
    [sessionIdentifier release];
    [occurrenceTime release];
    [super dealloc];
}
@end
