/*
 Copyright (c) 2011 Readmill LTD
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */

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
