//
//  OCMockObject+RMAdditions.h
//  ReadmillAPI
//
//  Created by Martin Hwasser on 1/18/12.
//  Copyright (c) 2012 Readmill Network LTD. All rights reserved.
//

#import "OCMockObject.h"

@interface OCMockObject (RMAdditions)

- (void)verifyWithTimeout:(NSTimeInterval)timeout;

@end
