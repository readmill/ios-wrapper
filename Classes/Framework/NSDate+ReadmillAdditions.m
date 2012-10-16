//
//  NSDate+ReadmillDateExtensions.m
//  ReadmillAPI
//
//  Created by Martin Hwasser on 10/27/11.
//  Copyright (c) 2011 Readmill Network Limited. All rights reserved.
//

#import "NSDate+ReadmillAdditions.h"
#import "NSDateFormatter+ReadmillAdditions.h"

@implementation NSDate (ReadmillAdditions)

- (NSString *)stringWithRFC3339Format 
{    
    NSDateFormatter *formatter = [NSDateFormatter readmillDateFormatter];
    NSString *dateString = [formatter stringFromDate:self];
    return dateString;
}

@end
