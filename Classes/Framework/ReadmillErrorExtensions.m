//
//  ReadmillErrorExtensions.m
//  ReadmillFramework
//
//  Created by Martin Hwasser on 5/13/11.
//  Copyright 2011 KennettNet Software Limited. All rights reserved.
//

#import "ReadmillErrorExtensions.h"
#import "ReadmillAPIWrapper.h"

@implementation NSError (ReadmillErrorExtensions)

- (BOOL)isReadmillClientError {
    if ([[self domain] isEqualToString:kReadmillDomain]) {
        // The request was well-formed but was unable to be followed due to semantic errors.
        // E.g book is finished/deleted
        if (400 <= [self code] && [self code] < 500) {
            return YES;
        }
    }
    return NO;
}
@end
