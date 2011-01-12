//
//  Readmill_FrameworkAppDelegate.h
//  Readmill Framework
//
//  Created by Work on 10/01/2011.
//  Copyright 2011 KennettNet Software Limited. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ReadmillAPIWrapper.h"

@interface Readmill_FrameworkAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
    ReadmillAPIWrapper *api;
}

@property (assign) IBOutlet NSWindow *window;

@end
