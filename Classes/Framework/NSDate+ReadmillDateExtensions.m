//
//  NSDate+ReadmillDateExtensions.m
//  ReadmillFramework
//
//  Created by Martin Hwasser on 10/27/11.
//  Copyright (c) 2011 KennettNet Software Limited. All rights reserved.
//

#import "NSDate+ReadmillDateExtensions.h"

@implementation NSDate (ReadmillDateExtensions)

- (NSString *)stringWithRFC822Format {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY'-'MM'-'dd'T'HH':'mm':'ssZ'"];
    NSString *dateString = [formatter stringFromDate:self];
    [formatter release];
    return dateString;
}
@end
