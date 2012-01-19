//
//  OCMockObject+RMAdditions.m
//  ReadmillAPI
//
//  Created by Martin Hwasser on 1/18/12.
//  Copyright (c) 2012 Readmill Network LTD. All rights reserved.
//

#import "OCMockObject+RMAdditions.h"

@implementation OCMockObject (RMAdditions)

- (void)verifyWithTimeout:(NSTimeInterval)timeout
{
    NSTimeInterval i = 0;
    while (i < timeout) {
        @try {
            [self verify];
            return;
        }
        @catch (NSException *e) {}
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];
        i += 0.5;
    }    
    [self verify];
}

@end
