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

#import "ReadmillConnectBookUI.h"
#import "ReadmillUser.h"
#import "ReadmillUIPresenter.h"

@interface ReadmillConnectBookUI ()

@property (nonatomic, readwrite, retain) ReadmillUser *user;
@property (nonatomic, readwrite, retain) ReadmillBook *book;

@end

@implementation ReadmillConnectBookUI

-(id)initWithUser:(ReadmillUser *)aUser book:(ReadmillBook *)bookToConnectTo {
    
    if ((self = [super init])) {
        [self setUser:aUser];
        [self setBook:bookToConnectTo];
        
    }
    return self;
}

-(void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self setUser:nil];
    [self setBook:nil];
    [self setDelegate:nil];
    [super dealloc];
}

@synthesize user;
@synthesize delegate;
@synthesize book;

-(void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

-(void)willBeDismissed:(NSNotification *)notification {
    [[self delegate] connect:self didSkipLinkingToBook:[self book]];
}

#pragma mark - View lifecycle

// Implement loadView to create a view hierarchy programmatically, without using a nib.
-(void)loadView {
    
    UIWebView *webView = [[[UIWebView alloc] initWithFrame:CGRectMake(0.0, 0.0, 600.0, 400.0)] autorelease];
    [[[webView subviews] lastObject] setScrollEnabled:NO];
    [webView setDelegate:self];
    [webView setHidden:YES];
    
    UIView *containerView = [[[UIView alloc] initWithFrame:[webView frame]] autorelease];

    [containerView addSubview:webView];
    [containerView setHidden:YES];
    [self setView:containerView];
    
    NSURL *url = [[[self user] apiWrapper] connectBookUIURLForBookWithId:[[self book] bookId]];
    
    [webView loadRequest:[NSURLRequest requestWithURL:url]];
}

-(void)viewDidAppear:(BOOL)animated {
    //[[self view] setFrame:CGRectMake(0.0, 0.0, 600.0, 400.0)];
}

-(void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [self setView:nil];

    
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
	return YES;
}

#pragma mark -
#pragma mark UIWebViewDelegate

-(void)webViewDidStartLoad:(UIWebView *)webView {
	
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

-(void)webViewDidFinishLoad:(UIWebView *)webView {
	
    [webView setAlpha:0.0];
    [webView setHidden:NO];
    [self.view setHidden:NO];
    [webView setBackgroundColor:[UIColor whiteColor]];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [UIView setAnimationDuration:0.2];
    [webView setAlpha:1.0];
    [UIView commitAnimations];
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
	
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	
	if ([error code] != -999) {
        // ^ Load failed because the user clicked a new link to load
        
        [[self delegate] connect:self 
             didFailToLinkToBook:[self book]
                       withError:error];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:ReadmillUIPresenterShouldDismissViewNotification
                                                            object:self];
        
	}
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	
    if ([[[request URL] absoluteString] hasPrefix:@"callback"]) {
		
        // Can be...
        // callback://skip
        // callback://connect/public
        // callback://connect/private
        
        NSArray *parameters = [[[[request URL] absoluteURL] absoluteString] componentsSeparatedByString:@"/"];
        
        if ([parameters containsObject:@"skip"]) {
            [[self delegate] connect:self didSkipLinkingToBook:[self book]];
            [[NSNotificationCenter defaultCenter] postNotificationName:ReadmillUIPresenterShouldDismissViewNotification
                                                                object:self];
        } else if ([parameters containsObject:@"connect"]) {
            
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
            
            [[self user] findOrCreateReadForBook:[self book]
										   state:ReadStateReading
                            createdReadIsPrivate:[parameters containsObject:@"private"]
                                        delegate:self];
            
        }
		
		return NO;
	} else {
		return YES;
	}
}

#pragma mark -
#pragma mark ReadmillReadFindingDelegate

-(void)readmillUser:(ReadmillUser *)user didFindReads:(NSArray *)reads forBook:(ReadmillBook *)aBook {
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [[self delegate] connect:self didSucceedToLinkToBook:aBook withRead:[reads lastObject]];
    [[NSNotificationCenter defaultCenter] postNotificationName:ReadmillUIPresenterShouldDismissViewNotification
                                                        object:self];
}

-(void)readmillUser:(ReadmillUser *)user foundNoReadsForBook:(ReadmillBook *)aBook {
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [[self delegate] connect:self didSkipLinkingToBook:aBook];
    [[NSNotificationCenter defaultCenter] postNotificationName:ReadmillUIPresenterShouldDismissViewNotification
                                                        object:self];
}

-(void)readmillUser:(ReadmillUser *)user failedToFindReadForBook:(ReadmillBook *)aBook withError:(NSError *)error {
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [[self delegate] connect:self didFailToLinkToBook:aBook withError:error];
    [[NSNotificationCenter defaultCenter] postNotificationName:ReadmillUIPresenterShouldDismissViewNotification
                                                        object:self];
}


@end
