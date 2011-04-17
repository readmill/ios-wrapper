//
//  ReadmillPing.m
//  Readmill
//
//  Created by Martin Hwasser on 4/5/11.
//  Copyright 2011 Readmill. All rights reserved.
//

#import "ReadmillPing.h"


@implementation ReadmillPing
@synthesize sessionIdentifier;
@synthesize occurrenceTime;
@synthesize readId;
@synthesize duration;
@synthesize progress;

- (id)initWithReadId:(ReadmillReadId)aReadId 
        readProgress:(ReadmillReadProgress)aProgress 
   sessionIdentifier:(NSString *)aSessionIdentifier 
            duration:(ReadmillPingDuration)aDuration 
      occurrenceTime:(NSDate *)anOccurrenceTime {
    
    self = [super init];
    if (self) {
        self.readId = aReadId;
        self.progress = aProgress;
        self.duration = aDuration;
        
        [self setSessionIdentifier:aSessionIdentifier];
        [self setOccurrenceTime:anOccurrenceTime];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder 
{ 
    [coder encodeInteger:readId forKey:@"readId"];
    [coder encodeInteger:progress forKey:@"progress"];
    [coder encodeObject:sessionIdentifier forKey:@"sessionIdentifier"];
    [coder encodeInteger:duration forKey:@"duration"];
    [coder encodeObject:occurrenceTime forKey:@"occurrenceTime"];     
} 

- (id)initWithCoder:(NSCoder *)coder 
{ 
    self.readId = [coder decodeIntegerForKey:@"readId"];
    self.progress = [coder decodeIntegerForKey:@"progress"];
    self.sessionIdentifier = [coder decodeObjectForKey:@"sessionIdentifier"];
    self.duration = [coder decodeIntegerForKey:@"duration"];
    self.occurrenceTime = [coder decodeObjectForKey:@"occurrenceTime"];
    return self; 
}
- (NSString *)description {
    return [NSString stringWithFormat:@"%@ readId: %d, progress: %d, sessionIdentifier: %@, duration: %d, occurrenceTime:%@", 
            [super description], [self readId], [self progress], [self sessionIdentifier], [self duration], [self occurrenceTime]];

}

@end
