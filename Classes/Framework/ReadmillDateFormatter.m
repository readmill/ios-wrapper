//
//  ReadmillDateFormatter.m
//  ReadmillAPI
//
//  Created by Martin Hwasser on 11/2/11.
//  Copyright (c) 2011 Readmill Network Limited. All rights reserved.
//

#import "ReadmillDateFormatter.h"

@implementation ReadmillDateFormatter


+ (ReadmillDateFormatter *)formatterWithRFC3339Format {
    
    static ReadmillDateFormatter *sRFC3339DateFormatter;
    @synchronized (sRFC3339DateFormatter) {
        
        // If the date formatters aren't already set up, do that now and cache them
        // for subsequence reuse.
        
        if (sRFC3339DateFormatter == nil) {
            NSLocale *enUSPOSIXLocale;
            
            sRFC3339DateFormatter = [[ReadmillDateFormatter alloc] init];
            
            enUSPOSIXLocale = [[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"] autorelease];
            
            [sRFC3339DateFormatter setLocale:enUSPOSIXLocale];
            [sRFC3339DateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"];
            [sRFC3339DateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        }
        return sRFC3339DateFormatter;
    }
}
@end
