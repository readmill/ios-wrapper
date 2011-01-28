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
#import "Readmill_SigningInViewController.h"

@class Readmill_SignedInViewController;

@interface Readmill_FrameworkAppDelegate : NSObject <UIApplicationDelegate, ReadmillUserAuthenticationDelegate> {
    
@private
    
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet Readmill_SignedInViewController *signedInViewController;
@property (nonatomic, retain) IBOutlet Readmill_SigningInViewController *signingInViewController;


@end
