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
#import "NSString+ReadmillAdditions.h"
#import "NSURL+ReadmillURLParameters.h"
#import "ReadmillUIPresenter.h"
#import "UIApplication+ReadmillNetworkActivity.h"

@interface ReadmillViewReadingUI () 
{
    UIWebView *webView;
}

@property (nonatomic, readwrite, retain) ReadmillReading *reading;
@property (nonatomic, retain) UIWebView *webView;
@end

@implementation ReadmillViewReadingUI

-(id)initWithReading:(ReadmillReading *)aReading 
{    
    if ((self = [super init])) {
        [self setReading:aReading];
    }
    return self;
}

-(void)dealloc 
{    
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    [self setReading:nil];
    [self setDelegate:nil];
    
    [webView setDelegate:nil];
    if ([webView isLoading]) {
        [[UIApplication sharedApplication] readmill_popNetworkActivity];
        [webView stopLoading];   
    }
    [self setWebView:nil];
    
    [self setView:nil];
    [super dealloc];
}

@synthesize reading;
@synthesize delegate;
@synthesize webView;

- (void)didReceiveMemoryWarning 
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)willBeDismissed:(NSNotification *)notification 
{
    [[self delegate] viewReadingUIWillCloseWithNoAction:self];
}

#pragma mark - View lifecycle

// Implement loadView to create a view hierarchy programmatically, without using a nib.
-(void)loadView 
{    
    webView = [[UIWebView alloc] initWithFrame:CGRectMake(0.0, 0.0, 648.0, 440.0)];
    [[[webView subviews] lastObject] setScrollEnabled:NO];
    [webView setDelegate:self];
    [webView setHidden:YES];
    
    UIView *containerView = [[[UIView alloc] initWithFrame:[webView frame]] autorelease];
    
    [containerView addSubview:webView];
    
    [self setView:containerView];
    
    NSURL *url = [[[self reading] apiWrapper] URLForViewingReadingWithId:[[self reading] readingId]];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url 
                                                  cachePolicy:NSURLRequestReloadIgnoringCacheData 
                                              timeoutInterval:30];
    [webView loadRequest:request];
    [request release];
}

-(void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [self setView:nil];
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
    // Return YES for supported orientations
	return YES;
}

#pragma mark -
#pragma mark UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)aWebView 
{
	[[UIApplication sharedApplication] readmill_pushNetworkActivity];
}

- (void)webViewDidFinishLoad:(UIWebView *)aWebView 
{	
    [aWebView sizeToFit];
    [aWebView setAlpha:0.0];
    [aWebView setHidden:NO];
    [aWebView setBackgroundColor:[UIColor whiteColor]];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [UIView setAnimationDuration:0.2];
    [aWebView setAlpha:1.0];
    [UIView commitAnimations];

	[[UIApplication sharedApplication] readmill_popNetworkActivity];
}

- (void)webView:(UIWebView *)aWebView didFailLoadWithError:(NSError *)error 
{	
	[[UIApplication sharedApplication] readmill_popNetworkActivity];
	
	if ([error code] != -999) {
        // ^ Load failed because the user clicked a new link to load
        
        [[self delegate] viewReadingUI:self didFailToFinishReading:[self reading] withError:error];
        [[NSNotificationCenter defaultCenter] postNotificationName:ReadmillUIPresenterShouldDismissViewNotification
                                                            object:self];
	}
}

- (BOOL)webView:(UIWebView *)aWebView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType 
{	
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
                            
            NSString *uri = @"uri";
            if ((uri = [parameters valueForKey:uri])) { 

                __block typeof(self) bself = self;
                [bself retain];

                [[[self reading] apiWrapper] readingWithURLString:uri
                                                completionHandler:^(id result, NSError *error) {
                                                   
                                                    if (result && error == nil) {
                                                        // Update the reading with new data (closing remark, progress, state etc)
                                                        [bself->reading updateWithAPIDictionary:result];
                                                        
                                                        // Notify the delegate that the reading was finished/abandoned
                                                        [bself->delegate viewReadingUI:bself
                                                                      didFinishReading:bself->reading];

                                                    } else {
                                                        [bself->delegate viewReadingUI:bself
                                                                didFailToFinishReading:bself->reading 
                                                                             withError:error];
                                                    }
                                                    [bself release];
                                                }];
            }                
        } else if ([action isEqualToString:@"error"]) {
            
            NSError *error = [NSError errorWithDomain:kReadmillDomain 
                                                 code:0 
                                             userInfo:parameters];
            
            [[self delegate] viewReadingUI:self 
                    didFailToFinishReading:[self reading] 
                                 withError:error];
        }    

		return NO;
	} else {
		return YES;
	}
}

@end
