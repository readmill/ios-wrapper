//
//  RMDateFormatter.m
//  ReadmillAPI
//
//  Created by Martin Hwasser on 11/2/11.
//  Copyright (c) 2011 KennettNet Software Limited. All rights reserved.
//

#import "RMDateFormatter.h"

@implementation RMDateFormatter


+ (RMDateFormatter *)formatterWithRFC3339Format {
    
    static RMDateFormatter *sRFC3339DateFormatter;
    @synchronized (sRFC3339DateFormatter) {
        
        // If the date formatters aren't already set up, do that now and cache them
        // for subsequence reuse.
        
        if (sRFC3339DateFormatter == nil) {
            NSLog(@"FORMATTER NIL");
            NSLocale *enUSPOSIXLocale;
            
            sRFC3339DateFormatter = [[RMDateFormatter alloc] init];
            
            enUSPOSIXLocale = [[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"] autorelease];
            
            [sRFC3339DateFormatter setLocale:enUSPOSIXLocale];
            [sRFC3339DateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"];
            [sRFC3339DateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        }
        return sRFC3339DateFormatter;
    }
}
@end
