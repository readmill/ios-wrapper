//
//  Readmill_FrameworkAppDelegate.h
//  Readmill Framework
//
//  Created by Readmill on 26/01/2011.
//  Copyright 2011 Readmill. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ReadmillUser.h"
#import "ReadmillRead.h"
#import "ReadmillReadSession.h"

@class Readmill_FrameworkViewController;

@interface Readmill_FrameworkAppDelegate : NSObject <UIApplicationDelegate,
ReadmillUserAuthenticationDelegate, 
ReadmillBookFindingDelegate,
ReadmillReadFindingDelegate,
ReadmillReadUpdatingDelegate,
ReadmillPingDelegate> {
    
@private

    ReadmillUser *user;
    
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet Readmill_FrameworkViewController *viewController;
@property (readwrite, retain) ReadmillUser *user;

@end
