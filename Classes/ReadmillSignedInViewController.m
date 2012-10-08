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

#import "ReadmillSignedInViewController.h"
#import "ReadmillReadingSession.h"
#import "ReadmillUIPresenter.h"
#import "ReadmillExampleAppDelegate.h"
#import <QuartzCore/QuartzCore.h>

#define kPingDuration 300

@implementation ReadmillSignedInViewController

- (void)dealloc 
{
    [self setBook:nil];
    [self setConnectButton:nil];
    [self setAuthorTextField:nil];
    [self setTitleTextField:nil];
    [self setIsbnTextField:nil];
    [self setUser:nil];
    [self setReading:nil];
    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return NO;
}

- (void)didReceiveMemoryWarning 
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

- (void)viewDidLoad 
{    
    [super viewDidLoad];
    
    // Observer the user's credentials so they can be stored as they change. See -observeValueForKeyPath for more information.
    
    [user addObserver:self
           forKeyPath:@"propertyListRepresentation"
              options:NSKeyValueObservingOptionInitial
              context:nil];
    
    [user addObserver:self
           forKeyPath:@"fullName"
              options:NSKeyValueObservingOptionInitial
              context:nil];
    

    [[self navigationItem] setHidesBackButton:YES];
    [[self navigationController] setNavigationBarHidden:NO animated:YES];

    [[[self textView] layer] setBorderColor:[UIColor blackColor].CGColor];
    [[[self textView] layer] setBorderWidth:1];
}


- (void)viewDidUnload 
{    
    [super viewDidUnload];
    
    [user removeObserver:self forKeyPath:@"propertyListRepresentation"];
    [user removeObserver:self forKeyPath:@"userName"];
    
    [self setConnectButton:nil];
    [self setTitleTextField:nil], [self setAuthorTextField:nil], [self setIsbnTextField:nil];
    [self setTextView:nil];
}

@synthesize connectButton;
@synthesize reading;
@synthesize book;
@synthesize user;
@synthesize titleTextField, authorTextField, isbnTextField;
@synthesize textView;

#pragma mark Storing Readmill Authentication Credentials 

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context 
{    
   /*
    * Readmill's authentication credentials change from time-to-time, and will always 
    * change almost immediately after 
    * authenticating with Readmill for the first time in your application. Therefore, 
    * the reccommended way to deal with this is to observe the propertyListRepresentation
    * property on ReadmillUser (or ReadmillAPIWrapper if you're using direct API
    * access) and save it every time it changes.
    */
    
    if ([keyPath isEqualToString:@"propertyListRepresentation"]) {
        if ([[self user] propertyListRepresentation] != nil) {
            
            [[NSUserDefaults standardUserDefaults] setValue:[[self user] propertyListRepresentation]
                                                     forKey:@"readmill"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
    
    
    if ([keyPath isEqualToString:@"fullName"]) {
        [[self navigationItem] setTitle:[NSString stringWithFormat:@"Hi, %@", [[self user] fullName]]];
    }
}

- (IBAction)signOutButtonClicked:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setValue:nil
                                             forKey:@"readmill"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    ReadmillExampleAppDelegate *delegate = (ReadmillExampleAppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate authenticate];
    [[self navigationController] popToRootViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark - Finding a book

- (IBAction)findBookButtonClicked:(id)sender
{
    [user findOrCreateBookWithIdentifier:[isbnTextField text]
                                   title:[titleTextField text]
                                  author:[authorTextField text]
                                delegate:self];
}
#pragma mark -
#pragma mark Linking to a Book

- (IBAction)findOrCreateReadingButtonClicked:(id)sender
{
    if (!book) {
        [textView setText:[[textView text] stringByAppendingString:@"\nYou need to find a book before creating a reading."]];
        return;
    } 
    [user findOrCreateReadingForBook:book 
                               state:ReadingStateReading
                           isPrivate:NO
                            delegate:self];
}

#pragma mark STEP 5: We successfully linked a book. Create a session object and store it.

- (void)ping:(NSTimer *)timer 
{
    static ReadmillReadingSession *session = nil;
    if (!session) {
        //session = [reading createReadingSession];
        session = [[ReadmillReadingSession alloc] initWithAPIWrapper:[user apiWrapper]
                                                           readingId:[[self reading] readingId]];
    }
    [session pingWithProgress:0.2 
                 pingDuration:kPingDuration
                     delegate:self];
}

#pragma mark ReadmillBookFindingDelegate

- (void)readmillUser:(ReadmillUser *)readmillUser didFindBook:(ReadmillBook *)aBook 
{
    [self setBook:aBook];
    NSLog(@"didFindBook: %@", [book description]);
    [textView setText:[book description]];
}

/*!
 @param user The user object that was performing the request.
 @brief   Delegate method informing the target that Readmill could not find any books matching the previously given search criteria. 
 */
- (void)readmillUserFoundNoBook:(ReadmillUser *)user
{
    NSLog(@"readmillUserFoundNoBook");
    [textView setText:@"Couldn't find any existing books. To create a new book, you'd\nuse findOrCreateBook"];
}

/*!
 @param user The user object that was performing the request
 @param error An NSError object describing the error that occurred. 
 @brief   Delegate method informing the target that and error occurred attempting to search for or create book(s). 
 */
- (void)readmillUser:(ReadmillUser *)user failedToFindBookWithError:(NSError *)error 
{
    NSLog(@"failedToFindBookWithError: %@", error);
    [textView setText:[error localizedDescription]];
}

#pragma mark ReadmillReadingFindingDelegate 

- (void)readmillUser:(ReadmillUser *)aUser didFindReading:(ReadmillReading *)aReading forBook:(ReadmillBook *)book
{
    NSLog(@"Found reading: %@", aReading);
    [textView setText:[aReading description]];
}
- (void)readmillUser:(ReadmillUser *)user failedToFindReadingForBook:(ReadmillBook *)book withError:(NSError *)error
{
    NSLog(@"failedToFindReadingForBook: %@", error);
}
- (void)readmillUser:(ReadmillUser *)user foundNoReadingForBook:(ReadmillBook *)book
{
    NSLog(@"No readings found.");
}

#pragma mark ReadmillReadingUpdatingDelegate

- (void)readmillReading:(ReadmillReading *)reading didFailToUpdateMetadataWithError:(NSError *)error
{
    NSLog(@"Failed to update metadata: %@", error);
}
- (void)readmillReadingDidUpdateMetadataSuccessfully:(ReadmillReading *)aReading
{
    NSLog(@"Reading metadata updated: %@", aReading);
    [textView setText:[aReading description]];
}

#pragma mark ReadmillPingDelegate

- (void)readmillReadingSession:(ReadmillReadingSession *)session didFailToPingWithError:(NSError *)error
{
    NSLog(@"didFailToPingWithError: %@", error);
}
- (void)readmillReadingSessionDidPingSuccessfully:(ReadmillReadingSession *)session
{
    NSLog(@"readmillReadingSessionDidPingSuccessfully");
}
@end
