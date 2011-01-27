//
//  Readmill_FrameworkViewController.m
//  Readmill Framework
//
//  Created by Work on 26/01/2011.
//  Copyright 2011 KennettNet Software Limited. All rights reserved.
//

#import "Readmill_FrameworkViewController.h"
#import "ReadmillReadSession.h"
#import "ReadmillUIPresenter.h"

@implementation Readmill_FrameworkViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [self setRead:nil];
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

@synthesize read;

-(IBAction)readBook {
    
    ReadmillUser *user = [(NSObject *)[[UIApplication sharedApplication] delegate] valueForKey:@"user"];
    ReadmillBook *book = [[[ReadmillBook alloc] initWithAPIDictionary:[[user apiWrapper] bookWithId:5 error:nil]] autorelease];
    
    ReadmillConnectBookUI *popup = [[ReadmillConnectBookUI alloc] initWithUser:user
                                                                     book:book];
    [popup setDelegate:self];
        
    ReadmillUIPresenter *presenter = [[ReadmillUIPresenter alloc] initWithContentViewController:popup];
    
    [presenter presentInView:[self view] animated:YES];
    [presenter release];
    
}

-(void)connect:(ReadmillConnectBookUI *)connectionUI didSucceedToLinkToBook:(ReadmillBook *)aBook withRead:(ReadmillRead *)aRead {
    [self setRead:aRead];
    
    ReadmillReadSession *session = [aRead createReadSession];
    [session pingWithProgress:0 delegate:nil];
    
    NSLog(@"[%@ %@]: Read %d, Session %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), [read readId], [session sessionIdentifier]);
}

-(void)connect:(ReadmillConnectBookUI *)connectionUI didSkipLinkingToBook:(ReadmillBook *)aBook {
    NSLog(@"[%@ %@]: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), @"Skipped");
}

-(void)connect:(ReadmillConnectBookUI *)connectionUI didFailToLinkToBook:(ReadmillBook *)aBook withError:(NSError *)error {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Could Not Link To Book"
                                                    message:[error localizedDescription]
                                                   delegate:nil
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:nil];
    
    [[alert autorelease] show];
    
}

#pragma mark -

-(IBAction)editRead {
    
    if ([self read] == nil) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Read To Finish"
                                                        message:nil
                                                       delegate:nil
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:nil];
        
        [[alert autorelease] show];

    } else {
        ReadmillFinishReadUI *popup = [[ReadmillFinishReadUI alloc] initWithRead:[self read]];
        [popup setDelegate:self];
        
        ReadmillUIPresenter *presenter = [[ReadmillUIPresenter alloc] initWithContentViewController:popup];
        
        [presenter presentInView:[self view] animated:YES];
        [presenter release];

    }
    
}

-(void)finishReadUIWillCloseWithNoAction:(ReadmillFinishReadUI *)readUI {
    NSLog(@"[%@ %@]: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), @"Skipped");
}

-(void)finishReadUI:(ReadmillFinishReadUI *)readUI didFinishRead:(ReadmillRead *)aRead {
    NSLog(@"[%@ %@]: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd),  @"Finished");
}

-(void)finishReadUI:(ReadmillFinishReadUI *)readUI didFailToFinishRead:(ReadmillRead *)aRead withError:(NSError *)error {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Could Not Finish Read"
                                                    message:[error localizedDescription]
                                                   delegate:nil
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:nil];
    
    [[alert autorelease] show];

}


#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

@end
