//
//  Readmill_FrameworkViewController.m
//  Readmill Framework
//
//  Created by Readmill on 26/01/2011.
//  Copyright 2011 Readmill. All rights reserved.
//

#import "Readmill_SignedInViewController.h"
#import "ReadmillReadSession.h"
#import "ReadmillUIPresenter.h"

@implementation Readmill_SignedInViewController

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)dealloc {
    [self setUser:nil];
    [self setRead:nil];
    [super dealloc];
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

-(void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

-(void)viewDidLoad {
    
    [super viewDidLoad];
    
    // Observer the user's credentials so they can be stored as they change. See -observeValueForKeyPath for more information.
    
    [self addObserver:self
           forKeyPath:@"user.propertyListRepresentation"
              options:NSKeyValueObservingOptionInitial
              context:nil];
    
    [self addObserver:self
           forKeyPath:@"user.userName"
              options:NSKeyValueObservingOptionInitial
              context:nil];
    
}


-(void)viewDidUnload {
    
    [super viewDidUnload];
    
    [self removeObserver:self forKeyPath:@"user.propertyListRepresentation"];
    [self removeObserver:self forKeyPath:@"user.userName"];
}

@synthesize welcomeLabel;
@synthesize read;
@synthesize user;

#pragma mark Storing Readmill Authentication Credentials 

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
/*
        Readmill's authentication credentials change from time-to-time, and will always change almost immediately after 
        authenticating with Readmill for the first time in your application. Therefore, the reccommended way to deal with this 
        is to observe the propertyListRepresentation property on ReadmillUser (or ReadmillAPIWrapper if you're using direct
        API access) and save it every time it changes.
*/
    
    if ([keyPath isEqualToString:@"user.propertyListRepresentation"]) {
        if ([[self user] propertyListRepresentation] != nil) {
            
            [[NSUserDefaults standardUserDefaults] setValue:[[self user] propertyListRepresentation]
                                                     forKey:@"readmill"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
    
    
    if ([keyPath isEqualToString:@"user.userName"]) {
        [[self welcomeLabel] setText:[NSString stringWithFormat:@"Welcome, %@!", [[self user] userName]]];
    }
}

#pragma mark -
#pragma mark Linking to a Book

#pragma mark STEP 1: Find a book in Readmill.

-(IBAction)linkToBookButtonWasPushed {
    
    [[self user] findOrCreateBookWithISBN:@"0340896981"
                                    title:@"One Day"
                                   author:@"David Nicholls"
                                 delegate:self];
    
}

#pragma mark STEP 2: Handle book finding delegate methods.

-(void)readmillUserFoundNoBooks:(ReadmillUser *)user {
    
    // STEP 2.1: This shouldn't be called when using findOrCreateBook..., but we'll include it for completeness.
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Books Found!"
                                                    message:@""
                                                   delegate:nil
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:nil];
    
    [[alert autorelease] show];
}

-(void)readmillUser:(ReadmillUser *)user failedToFindBooksWithError:(NSError *)error {
    
    // STEP 2.2: Maybe we're not connected to the internet?
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Couldn't Find Book"
                                                    message:[error localizedDescription]
                                                   delegate:nil
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:nil];
    
    [[alert autorelease] show];

}

#pragma mark STEP 3: We successfully found a book - ask the user if they want to link to it.

-(void)readmillUser:(ReadmillUser *)user didFindBooks:(NSArray *)books {
    
    ReadmillBook *book = [books lastObject];
    
    ReadmillConnectBookUI *popup = [[ReadmillConnectBookUI alloc] initWithUser:[self user]
                                                                          book:book];
    [popup setDelegate:self];
    
    ReadmillUIPresenter *presenter = [[ReadmillUIPresenter alloc] initWithContentViewController:popup];
    
    [presenter presentInViewController:self animated:YES];
    [presenter release];
}

#pragma mark STEP 4: Handle book connection delegate methods. 

-(void)connect:(ReadmillConnectBookUI *)connectionUI didSkipLinkingToBook:(ReadmillBook *)aBook {
    
    // STEP 4.1 The user opted to not link ther book to Readmill.
    
}

-(void)connect:(ReadmillConnectBookUI *)connectionUI didFailToLinkToBook:(ReadmillBook *)aBook withError:(NSError *)error {
    
    // STEP 2.2: Maybe we're not connected to the internet?
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Couldn't Link Book"
                                                    message:[error localizedDescription]
                                                   delegate:nil
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:nil];
    
    [[alert autorelease] show];
    
}

#pragma mark STEP 5: We successfully linked a book. Create a session object and store it.

-(void)connect:(ReadmillConnectBookUI *)connectionUI didSucceedToLinkToBook:(ReadmillBook *)aBook withRead:(ReadmillRead *)aRead {
    
    [self setRead:aRead];
    
    ReadmillReadSession *session = [aRead createReadSession];
    [session pingWithProgress:0 delegate:nil];
    
}

#pragma mark -
#pragma mark Finishing A Read

#pragma mark STEP 1: Ask the user if they'd like to update their read status in Readmill.

-(IBAction)finishReadButtonWasPushed {
    
    if ([self read] == nil) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Read To Finish"
                                                        message:nil
                                                       delegate:nil
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:nil];
        
        [[alert autorelease] show];

    } else {
        
        // Present the Readmill UI.
        
        ReadmillFinishReadUI *popup = [[ReadmillFinishReadUI alloc] initWithRead:[self read]];
        [popup setDelegate:self];
        
        ReadmillUIPresenter *presenter = [[ReadmillUIPresenter alloc] initWithContentViewController:popup];
        
        [presenter presentInViewController:self animated:YES];
        [presenter release];
    }
}

#pragma mark STEP 2: Handle delegate methods.

-(void)finishReadUIWillCloseWithNoAction:(ReadmillFinishReadUI *)readUI {
    
    // The user decided not to update their read status in Readmill.
}

#pragma mark STEP 3: Successfully updated read status. 

-(void)finishReadUI:(ReadmillFinishReadUI *)readUI didFinishRead:(ReadmillRead *)aRead {
    
    // The read object will now be updated with a statue of ReadStateFinished and possibly an updated closing remark. 
}

-(void)finishReadUI:(ReadmillFinishReadUI *)readUI didFailToFinishRead:(ReadmillRead *)aRead withError:(NSError *)error {
    
    // There was an error when trying to update status.
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Could Not Finish Read"
                                                    message:[error localizedDescription]
                                                   delegate:nil
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:nil];
    
    [[alert autorelease] show];
}

@end
