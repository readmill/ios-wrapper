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

#import "Readmill_SignedInViewController.h"
#import "ReadmillReadingSession.h"
#import "ReadmillUIPresenter.h"
#define kPingDuration 300

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
    
    [[self user] findBookWithISBN:nil
                            title:@"New York Trilogy, The"
                         delegate:self];
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
    
    ReadmillUIPresenter *readmillUIPresenter = [[ReadmillUIPresenter alloc] init];    
    [readmillUIPresenter presentInViewController:self animated:YES];
    
    
    ReadmillConnectBookUI *readmillConnectBookUI = [[ReadmillConnectBookUI alloc] initWithUser:[self user] 
                                                                                          ISBN:@"0340896981" 
                                                                                         title:@"One Day"
                                                                                        author:@"David Nicholls"];
        
        
    [readmillConnectBookUI setDelegate:self];
    
    [readmillUIPresenter setAndDisplayContentViewController:readmillConnectBookUI];
    [readmillConnectBookUI release];
    [readmillUIPresenter release];
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

-(void)connect:(ReadmillConnectBookUI *)connectionUI didSucceedToLinkToBook:(ReadmillBook *)aBook withReading:(ReadmillReading *)aReading {
    
    [self setRead:aReading];
    
    ReadmillReadingSession *session = [aReading createReadingSession];
    [session pingWithProgress:0 pingDuration:kPingDuration delegate:nil];
    
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
        
        ReadmillViewReadingUI *popup = [[ReadmillViewReadingUI alloc] initWithReading:[self read]];
        [popup setDelegate:self];
        
        ReadmillUIPresenter *presenter = [[ReadmillUIPresenter alloc] initWithContentViewController:popup];
        
        [presenter presentInViewController:self animated:YES];
        [presenter release];
    }
}

#pragma mark STEP 2: Handle delegate methods.

-(void)viewReadingUIWillCloseWithNoAction:(ReadmillViewReadingUI *)readingUI {
    
    // The user decided not to update their read status in Readmill.
}

#pragma mark STEP 3: Successfully updated read status. 

-(void)viewReadingUI:(ReadmillViewReadingUI *)readUI didFinishReading:(ReadmillReading *)aReading {
    
    // The read object will now be updated with a statue of ReadingStateFinished and possibly an updated closing remark. 
}

-(void)viewReadingUI:(ReadmillViewReadingUI *)readUI didFailToFinishReading:(ReadmillReading *)aReading withError:(NSError *)error {
    
    // There was an error when trying to update status.
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Could Not Finish Read"
                                                    message:[error localizedDescription]
                                                   delegate:nil
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:nil];
    
    [[alert autorelease] show];
}

#pragma mark ReadmillBookFindingDelegate

-(void)readmillUser:(ReadmillUser *)user didFindBook:(ReadmillBook *)book {
    NSLog(@"book: %@", [book description]);
}

/*!
 @param user The user object that was performing the request.
 @brief   Delegate method informing the target that Readmill could not find any books matching the previously given search criteria. 
 */
-(void)readmillUserFoundNoBook:(ReadmillUser *)user {
    NSLog(@"found no books");
}

/*!
 @param user The user object that was performing the request
 @param error An NSError object describing the error that occurred. 
 @brief   Delegate method informing the target that and error occurred attempting to search for or create book(s). 
 */
-(void)readmillUser:(ReadmillUser *)user failedToFindBookWithError:(NSError *)error {
    NSLog(@"error: %@", error);
}

@end
