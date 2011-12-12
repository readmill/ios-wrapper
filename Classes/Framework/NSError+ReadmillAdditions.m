//
//  ReadmillErrorExtensions.m
//  ReadmillAPI
//
//  Created by Martin Hwasser on 5/13/11.
//  Copyright 2011 Readmill Network Limited. All rights reserved.
//

#import "NSError+ReadmillAdditions.h"
#import "ReadmillAPIWrapper.h"

@implementation NSError (ReadmillAdditions)

- (BOOL)isReadmillDomain
{
    return [[self domain] isEqualToString:kReadmillDomain];
}
- (BOOL)isClientError 
{
    // The request was well-formed but was unable to be followed due to semantic errors.
    // E.g book is finished/deleted
    if (400 <= [self code] && [self code] < 500) {
        return YES;
    }
    return NO;
}
@end
