//
//  NSDate+ReadmillDateExtensions.m
//  ReadmillAPI
//
//  Created by Martin Hwasser on 10/27/11.
//  Copyright (c) 2011 KennettNet Software Limited. All rights reserved.
//

#import "NSDate+ReadmillDateExtensions.h"
#import "RMDateFormatter.h"

@implementation NSDate (ReadmillDateExtensions)

- (NSString *)stringWithRFC3339Format {
    
    RMDateFormatter *formatter = [RMDateFormatter formatterWithRFC3339Format];
    NSString *dateString = [formatter stringFromDate:self];
    return dateString;
}
@end
