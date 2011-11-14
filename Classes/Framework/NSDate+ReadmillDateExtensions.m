//
//  NSDate+ReadmillDateExtensions.m
//  ReadmillAPI
//
//  Created by Martin Hwasser on 10/27/11.
//  Copyright (c) 2011 Readmill Network Limited. All rights reserved.
//

#import "NSDate+ReadmillDateExtensions.h"
#import "ReadmillDateFormatter.h"

@implementation NSDate (ReadmillDateExtensions)

- (NSString *)stringWithRFC3339Format {
    
    ReadmillDateFormatter *formatter = [ReadmillDateFormatter formatterWithRFC3339Format];
    NSString *dateString = [formatter stringFromDate:self];
    return dateString;
}
@end
