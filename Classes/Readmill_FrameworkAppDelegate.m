//
//  Readmill_FrameworkAppDelegate.m
//  Readmill Framework
//
//  Created by Readmill on 10/01/2011.
//  Copyright 2011 Readmill. All rights reserved.
//

#import "Readmill_FrameworkAppDelegate.h"
#import "ReadmillAPIWrapper.h"
#import "ReadmillBook.h"
#import "ReadmillUser.h"
#import "ReadmillRead.h"
#import "ReadmillReadSession.h"

@implementation Readmill_FrameworkAppDelegate

@synthesize window;
@synthesize user;

-(void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    
    [[NSAppleEventManager sharedAppleEventManager] setEventHandler:self 
                                                       andSelector:@selector(getUrl:withReplyEvent:) 
                                                     forEventClass:kInternetEventClass 
                                                        andEventID:kAEGetURL];

    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"readmill"] != nil) {
        
        [ReadmillUser authenticateWithPropertyListRepresentation:[[NSUserDefaults standardUserDefaults] valueForKey:@"readmill"]
                                                        delegate:self];
    } else {
    
        [[NSWorkspace sharedWorkspace] openURL:[ReadmillUser clientAuthorizationURLWithRedirectURL:[NSURL URLWithString:@"readmillTestAuth://authorize"]
                                                                                   onStagingServer:YES]];
    }
    
    // Winnie the Pooh book: 11 read: 28
    // User: Name danielkennett id = 7
    
}

-(void)applicationWillTerminate:(NSNotification *)notification {
    [[NSUserDefaults standardUserDefaults] setValue:[[self user] propertyListRepresentation] forKey:@"readmill"];
}

- (void)getUrl:(NSAppleEventDescriptor *)event withReplyEvent:(NSAppleEventDescriptor *)replyEvent {

    NSURL *url = [NSURL URLWithString:[[event paramDescriptorForKeyword:keyDirectObject] stringValue]];
    
    [ReadmillUser authenticateCallbackURL:url
                          baseCallbackURL:[NSURL URLWithString:@"readmillTestAuth://authorize"]
                                 delegate:self
                          onStagingServer:YES];
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