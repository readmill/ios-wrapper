//
//  Readmill_FrameworkAppDelegate.m
//  Readmill Framework
//
//  Created by Work on 10/01/2011.
//  Copyright 2011 KennettNet Software Limited. All rights reserved.
//

#import "Readmill_FrameworkAppDelegate.h"
#import "ReadmillAPIWrapper.h"
#import "ReadmillBook.h"

@implementation Readmill_FrameworkAppDelegate

@synthesize window;

-(void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    
    [[NSAppleEventManager sharedAppleEventManager] setEventHandler:self 
                                                       andSelector:@selector(getUrl:withReplyEvent:) 
                                                     forEventClass:kInternetEventClass 
                                                        andEventID:kAEGetURL];

    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"readmill"] != nil) {
        
        api = [[ReadmillAPIWrapper alloc] initWithPropertyListRepresentation:[[NSUserDefaults standardUserDefaults] valueForKey:@"readmill"]];
        
    } else {
    
        api = [[ReadmillAPIWrapper alloc] initWithStagingEndPoint];
        [[NSWorkspace sharedWorkspace] openURL:[api clientAuthorizationURLWithRedirectURLString:@"readmillTestAuth://authorize"]];
    }
    
    // Winnie the Pooh book: 11 read: 28
    // User: Name danielkennett id = 7
    
    NSError *err;
    
    NSArray *bookObjects = [api allBooks:&err];
    
    if (err == nil) {
        
        NSMutableArray *books = [NSMutableArray arrayWithCapacity:[bookObjects count]];
        
        for (NSDictionary *bookDict in bookObjects) {
            
            ReadmillBook *book = [[[ReadmillBook alloc] initWithAPIDictionary:bookDict] autorelease];
            [books addObject:book];
        }
        
        NSLog(@"%@", books);
        
    } else {
        NSLog(@"%@ %@: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), err);
    }
                                                            
    
}

-(void)applicationWillTerminate:(NSNotification *)notification {
    [[NSUserDefaults standardUserDefaults] setValue:[api propertyListRepresentation] forKey:@"readmill"];
}

- (void)getUrl:(NSAppleEventDescriptor *)event withReplyEvent:(NSAppleEventDescriptor *)replyEvent {
	NSString *code = [[[[event paramDescriptorForKeyword:keyDirectObject] stringValue] substringFromIndex:34] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    NSError *err = nil;
    [api authorizeWithAuthorizationCode:code fromRedirectURL:@"readmillTestAuth://authorize" error:&err];    
    
    NSLog(@"%@ %@: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), err);
    
    [[NSUserDefaults standardUserDefaults] setValue:[api propertyListRepresentation] forKey:@"readmill"];
}

@end
