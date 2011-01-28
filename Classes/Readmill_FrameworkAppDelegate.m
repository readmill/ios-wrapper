//
//  Readmill_FrameworkAppDelegate.m
//  Readmill Framework
//
//  Created by Readmill on 26/01/2011.
//  Copyright 2011 Readmill. All rights reserved.
//

#import "Readmill_FrameworkAppDelegate.h"
#import "Readmill_SignedInViewController.h"

@implementation Readmill_FrameworkAppDelegate

@synthesize window;
@synthesize signedInViewController;
@synthesize signingInViewController;

-(BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"readmill"] == nil) {
        
        // We don't have saved credentials. Boot the user out to Readmill for authentication with a callback URL this application is set up to handle. 
        
        [[UIApplication sharedApplication] openURL:[ReadmillUser clientAuthorizationURLWithRedirectURL:[NSURL URLWithString:@"readmillTestAuth://authorize"]
                                                                                       onStagingServer:YES]];
        
    } else {
        
        // We have saved credentials. Attempt to authorise them - delegates for this are handled below. 

        [ReadmillUser authenticateWithPropertyListRepresentation:[[NSUserDefaults standardUserDefaults] valueForKey:@"readmill"]
                                                        delegate:self];
    }
    
    // If we were launched with a URL, attempt to authenticate from it - delegates for this are handled below, the same as authenticating with values from NSUserDefaults.
    
    if ([launchOptions valueForKey:UIApplicationLaunchOptionsURLKey] != nil) {
        
        NSURL *url = [launchOptions valueForKey:UIApplicationLaunchOptionsURLKey];
        
        [ReadmillUser authenticateCallbackURL:url
                              baseCallbackURL:[NSURL URLWithString:@"readmillTestAuth://authorize"]
                                     delegate:self
                              onStagingServer:YES];

    }
    
    [[self window] setRootViewController:[self signingInViewController]];
    [[self window] makeKeyAndVisible];
    
    return YES;
    
}

#pragma mark -
#pragma mark Authentication Delegates

-(void)readmillAuthenticationDidFailWithError:(NSError *)authenticationError {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Authentication Failed!"
                                                    message:[authenticationError localizedDescription]
                                                   delegate:nil
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:nil];
    
    [[alert autorelease] show];

    // Clear any saved credentials and start again next time.
    
    [[NSUserDefaults standardUserDefaults] setValue:nil forKey:@"readmill"];
}

-(void)readmillAuthenticationDidSucceedWithLoggedInUser:(ReadmillUser *)loggedInUser {
     
    // Authentication was successful. 
    
    [[self signedInViewController] setUser:loggedInUser];    
    [[self window] setRootViewController:[self signedInViewController]];
}

#pragma mark -

-(BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    [ReadmillUser authenticateCallbackURL:url
                          baseCallbackURL:[NSURL URLWithString:@"readmillTestAuth://authorize"]
                                 delegate:self
                          onStagingServer:YES];
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
    
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Save data if appropriate.
    
}

- (void)dealloc {

    [window release];
    [signedInViewController release];
    [super dealloc];
}



@end
