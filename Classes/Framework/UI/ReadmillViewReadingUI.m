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

#import "ReadmillViewReadingUI.h"
#import "ReadmillUser.h"
#import "ReadmillStringExtensions.h"
#import "ReadmillURLExtensions.h"
#import "ReadmillUIPresenter.h"

@interface ReadmillViewReadingUI ()

@property (nonatomic, readwrite, retain) ReadmillReading *reading;

@end

@implementation ReadmillViewReadingUI

-(id)initWithReading:(ReadmillReading *)aReading {
    
    if ((self = [super init])) {
        [self setReading:aReading];
    }
    return self;
}

-(void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self setReading:nil];
    [self setDelegate:nil];
    [super dealloc];
}

@synthesize reading;
@synthesize delegate;

-(void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

-(void)willBeDismissed:(NSNotification *)notification {
    [[self delegate] viewReadingUIWillCloseWithNoAction:self];
}

#pragma mark - View lifecycle

// Implement loadView to create a view hierarchy programmatically, without using a nib.
-(void)loadView {
    
    UIWebView *webView = [[[UIWebView alloc] initWithFrame:CGRectMake(0.0, 0.0, 648.0, 440.0)] autorelease];
    [[[webView subviews] lastObject] setScrollEnabled:NO];
    [webView setDelegate:self];
    [webView setHidden:YES];
    
    UIView *containerView = [[[UIView alloc] initWithFrame:[webView frame]] autorelease];
    
    [containerView addSubview:webView];
    
    [self setView:containerView];
    
    NSURL *url = [[[self reading] apiWrapper] URLForViewingReadingWithId:[[self reading] readingId]];
    [webView loadRequest:[NSURLRequest requestWithURL:url]];
}

-(void)viewDidAppear:(BOOL)animated {
    //[[self view] setFrame:CGRectMake(0.0, 0.0, 600.0, 578.0)];
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
	
    //[activityIndicator startAnimating];
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

-(void)webViewDidFinishLoad:(UIWebView *)webView {
	
    [webView sizeToFit];
    [webView setAlpha:0.0];
    [webView setHidden:NO];
    [webView setBackgroundColor:[UIColor whiteColor]];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [UIView setAnimationDuration:0.2];
    [webView setAlpha:1.0];
    [UIView commitAnimations];

	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
	
    //[activityIndicator stopAnimating];
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	
	if ([error code] != -999) {
        // ^ Load failed because the user clicked a new link to load
        
        [[self delegate] viewReadingUI:self didFailToFinishReading:[self reading] withError:error];
        [[NSNotificationCenter defaultCenter] postNotificationName:ReadmillUIPresenterShouldDismissViewNotification
                                                            object:self];
	}
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	
    NSURL *URL = [request URL];
    if ([[URL scheme] isEqualToString:@"readmill"]) {
		
        // Can be...
        // readmill://change?uri="uri to reading"
        
        // Dismiss the presenter immediately
        [[NSNotificationCenter defaultCenter] postNotificationName:ReadmillUIPresenterShouldDismissViewNotification
                                                            object:self];

        // host == action, i.e. view 
        NSString *action = [URL host];
        
        NSDictionary *parameters = [URL queryAsDictionary];
        if ([action isEqualToString:@"change"]) {
                            
            NSError *error = nil;
            NSString *uri = @"uri";
            if ((uri = [parameters valueForKey:uri])) { 
                NSDictionary *readingDictionary = [[[self reading] apiWrapper] readingWithURLString:uri 
                                                                                     error:&error];
                
                if (nil == error) {
                    
                    // Update the reading with new data (closing remark, progress, state etc)
                    [[self reading] updateWithAPIDictionary:readingDictionary];
                    
                    // Notify the delegate that the reading was finished/abandoned
                    [[self delegate] viewReadingUI:self 
                                  didFinishReading:[self reading]];
                }
            }
                
        } else if ([action isEqualToString:@"error"]) {
            
            NSError *error = [NSError errorWithDomain:kReadmillDomain 
                                                 code:0 
                                             userInfo:parameters];
            
            [[self delegate] viewReadingUI:self 
                    didFailToFinishReading:[self reading] 
                                 withError:error];
        }    
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
		return NO;
	} else {
		return YES;
	}
}

@end
