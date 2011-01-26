//
//  Readmill_FrameworkAppDelegate.m
//  Readmill Framework
//
//  Created by Work on 26/01/2011.
//  Copyright 2011 KennettNet Software Limited. All rights reserved.
//

#import "Readmill_FrameworkAppDelegate.h"

#import "Readmill_FrameworkViewController.h"

@implementation Readmill_FrameworkAppDelegate


@synthesize window;

@synthesize viewController;
@synthesize user;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"readmill"] != nil) {
        
        [ReadmillUser authenticateWithPropertyListRepresentation:[[NSUserDefaults standardUserDefaults] valueForKey:@"readmill"]
                                                        delegate:self];
    } else {
        
        [[UIApplication sharedApplication] openURL:[ReadmillUser clientAuthorizationURLWithRedirectURL:[NSURL URLWithString:@"readmillTestAuth://authorize"]
                                                                                   onStagingServer:YES]];
    }
    
    if ([launchOptions valueForKey:UIApplicationLaunchOptionsURLKey] != nil) {
        
        NSURL *url = [launchOptions valueForKey:UIApplicationLaunchOptionsURLKey];
        
        [ReadmillUser authenticateCallbackURL:url
                              baseCallbackURL:[NSURL URLWithString:@"readmillTestAuth://authorize"]
                                     delegate:self
                              onStagingServer:YES];

    }

    
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    return YES;
    
}

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
    [[NSUserDefaults standardUserDefaults] setValue:[[self user] propertyListRepresentation] forKey:@"readmill"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Save data if appropriate.
    [[NSUserDefaults standardUserDefaults] setValue:[[self user] propertyListRepresentation] forKey:@"readmill"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)dealloc {

    [window release];
    [viewController release];
    [super dealloc];
}

#pragma mark -
#pragma mark Authentication

-(void)readmillAuthenticationDidFailWithError:(NSError *)authenticationError {
    NSLog(@"[%@ %@]: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), authenticationError);
}

-(void)readmillAuthenticationDidSucceedWithLoggedInUser:(ReadmillUser *)loggedInUser {
    NSLog(@"[%@ %@]: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), loggedInUser);
    [self setUser:loggedInUser];
    
    [[self user] findOrCreateBookWithISBN:@"0340896981"
                                    title:@"One Day"
                                   author:@"David Nicholls"
                                 delegate:self];
    
}

#pragma mark -
#pragma mark Book finding

-(void)readmillUser:(ReadmillUser *)user didFindBooks:(NSArray *)books {
    NSLog(@"[%@ %@]: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), books);
    
    [[self user] findOrCreateReadForBook:[books lastObject]
                                delegate:self];
}

-(void)readmillUserFoundNoBooks:(ReadmillUser *)user {
    NSLog(@"[%@ %@]: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), @"No books!");
}

-(void)readmillUser:(ReadmillUser *)user failedToFindBooksWithError:(NSError *)error {
    NSLog(@"[%@ %@]: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), error);
}

#pragma mark -
#pragma mark Reads

-(void)readmillUser:(ReadmillUser *)user didFindReads:(NSArray *)reads forBook:(ReadmillBook *)book {
    NSLog(@"[%@ %@]: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), reads);
    
    [[reads lastObject] updateState:ReadStateReading delegate:self];
    ReadmillReadSession *session = [[reads lastObject] createReadSession];
    
    [session pingWithProgress:20 delegate:self];
    
}

-(void)readmillUser:(ReadmillUser *)user foundNoReadsForBook:(ReadmillBook *)book {
    NSLog(@"[%@ %@]: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), @"No reads!");   
}

-(void)readmillUser:(ReadmillUser *)user failedToFindReadForBook:(ReadmillBook *)book withError:(NSError *)error {
    NSLog(@"[%@ %@]: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), error);
}

#pragma mark -
#pragma mark Read updating

-(void)readmillReadDidUpdateMetadataSuccessfully:(ReadmillRead *)read {
    NSLog(@"[%@ %@]: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), read);
}

-(void)readmillRead:(ReadmillRead *)read didFailToUpdateMetadataWithError:(NSError *)error {
    NSLog(@"[%@ %@]: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), error);
}

#pragma mark -
#pragma mark Session Pinging

-(void)readmillReadSessionDidPingSuccessfully:(ReadmillReadSession *)session {
    NSLog(@"[%@ %@]: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), session);
}

-(void)readmillReadSession:(ReadmillReadSession *)session didFailToPingWithError:(NSError *)error {
    NSLog(@"[%@ %@]: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), error);
}


@end
