//
//  UIApplication+ReadmillNetworkActivity.m
//  ReadmillAPI
//
//  Created by Martin Hwasser on 12/2/11.
//  Copyright (c) 2011 Readmill Network LTD. All rights reserved.
//

#import "UIApplication+ReadmillNetworkActivity.h"

static NSInteger readmill_networkActivityCount = 0;

@implementation UIApplication (ReadmillNetworkActivity)

- (NSInteger)readmill_networkActivityCount 
{
    @synchronized(self) { 
        return readmill_networkActivityCount;
    }
}
- (void)readmill_refreshNetworkActivityIndicator
{
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(readmill_refreshNetworkActivityIndicator)
                               withObject:nil 
                            waitUntilDone:NO];
        return;
    }
    
    BOOL active = (self.readmill_networkActivityCount > 0);
    self.networkActivityIndicatorVisible = active;
}

- (void)readmill_pushNetworkActivity 
{
    @synchronized(self) {
        readmill_networkActivityCount++;
    }
    [self readmill_refreshNetworkActivityIndicator];
}

- (void)readmill_popNetworkActivity 
{
    @synchronized(self) {
        if (readmill_networkActivityCount > 0) {
            readmill_networkActivityCount--;
        } else {
            readmill_networkActivityCount = 0;
            DLog(@"%s Unbalanced network activity: count already 0.",
                  __PRETTY_FUNCTION__);
        }        
    }
    [self readmill_refreshNetworkActivityIndicator];
}

- (void)readmill_resetNetworkActivity 
{
    @synchronized(self) {
        readmill_networkActivityCount = 0;
    }
    [self readmill_refreshNetworkActivityIndicator];        
}


@end
