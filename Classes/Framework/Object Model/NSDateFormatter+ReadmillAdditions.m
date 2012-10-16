//
//  NSDateFormatter+ReadmillAdditions.m
//  ReadmillAPI
//
//  Created by Martin Hwasser on 10/16/12.
//  Copyright (c) 2012 Readmill Network LTD. All rights reserved.
//

#import "NSDateFormatter+ReadmillAdditions.h"

@implementation NSDateFormatter (ReadmillAdditions)

+ (NSDateFormatter *)readmillDateFormatter
{
    static NSDateFormatter *sRFC3339DateFormatter;
    @synchronized (sRFC3339DateFormatter) {
        
        // If the date formatter isn't already set up, do that now and cache it
        // for subsequence reuse.
        if (sRFC3339DateFormatter == nil) {
            NSLocale *enUSPOSIXLocale;
            
            sRFC3339DateFormatter = [[NSDateFormatter alloc] init];
            
            enUSPOSIXLocale = [[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"] autorelease];
            
            [sRFC3339DateFormatter setLocale:enUSPOSIXLocale];
            [sRFC3339DateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"];
            [sRFC3339DateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        }
        return sRFC3339DateFormatter;
    }
}

@end
