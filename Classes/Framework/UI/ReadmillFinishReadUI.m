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

#import "ReadmillFinishReadUI.h"
#import "ReadmillUser.h"
#import "ReadmillStringExtensions.h"
#import "ReadmillUIPresenter.h"

@interface ReadmillFinishReadUI ()

@property (nonatomic, readwrite, retain) ReadmillRead *read;

@end

@implementation ReadmillFinishReadUI

-(id)initWithRead:(ReadmillRead *)aRead {
    
    if ((self = [super init])) {
        [self setRead:aRead];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(willBeDismissed:)
                                                     name:ReamillUIPresenterWillDismissViewFromCloseButtonNotification
                                                   object:nil];
    }
    return self;
}

-(void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self setRead:nil];
    [self setDelegate:nil];
    [super dealloc];
}

@synthesize read;
@synthesize delegate;

-(void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

-(void)willBeDismissed:(NSNotification *)notification {
    [[self delegate] finishReadUIWillCloseWithNoAction:self];
}

#pragma mark - View lifecycle

// Implement loadView to create a view hierarchy programmatically, without using a nib.
-(void)loadView {
    
    UIWebView *webView = [[[UIWebView alloc] initWithFrame:CGRectMake(0.0, 0.0, 600.0, 578.0)] autorelease];
    [[[webView subviews] lastObject] setScrollEnabled:NO];
    [webView setDelegate:self];
    [webView setHidden:YES];
    
    UIView *containerView = [[[UIView alloc] initWithFrame:[webView frame]] autorelease];
    
    activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [activityIndicator setCenter:CGPointMake(floorf([containerView frame].size.width / 2), floorf([containerView frame].size.height / 2))];
    [activityIndicator setHidesWhenStopped:YES];
    [activityIndicator startAnimating];
    
    [containerView addSubview:webView];
    [containerView addSubview:activityIndicator];
    
    [self setView:containerView];
    
    NSURL *url = [[[self read] apiWrapper] editReadUIURLForReadWithId:[[self read] readId]];
    
    [webView loadRequest:[NSURLRequest requestWithURL:url]];
}

-(void)viewDidAppear:(BOOL)animated {
    [[self view] setFrame:CGRectMake(0.0, 0.0, 600.0, 578.0)];
}

-(void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [self setView:nil];
    [activityIndicator release];
    activityIndicator = nil;
    
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
	return YES;
}

#pragma mark -
#pragma mark UIWebViewDelegate

-(void)webViewDidStartLoad:(UIWebView *)webView {
	
    [activityIndicator startAnimating];
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

-(void)webViewDidFinishLoad:(UIWebView *)webView {
	
    [activityIndicator stopAnimating];
    [webView setHidden:NO];
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
	
    [activityIndicator stopAnimating];
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	
	if ([error code] != -999) {
        // ^ Load failed because the user clicked a new link to load
        
        [[self delegate] finishReadUI:self didFailToFinishRead:[self read] withError:error];
        [[NSNotificationCenter defaultCenter] postNotificationName:ReamillUIPresenterShouldDismissViewNotification
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
        
        if ([parameters containsObject:@"close-window"]) {
            [[self delegate] finishReadUIWillCloseWithNoAction:self];
            [[NSNotificationCenter defaultCenter] postNotificationName:ReamillUIPresenterShouldDismissViewNotification
                                                                object:self];
        } else if ([parameters containsObject:@"finish-with-remark"]) {
        
            NSUInteger indexOfParameter = [parameters indexOfObjectIdenticalTo:@"finish-with-remark"];
            NSString *remark = nil;
            
            // Remark is the parameter after this
            
            if ([parameters count] >= indexOfParameter) {
                remark = [parameters objectAtIndex:indexOfParameter + 1];
            }
        
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
            [activityIndicator startAnimating];
            
            [[self read] updateWithState:ReadStateFinished
                               isPrivate:[[self read] isPrivate]
                           closingRemark:remark
                                delegate:self];
        }         
        
		return NO;
	} else {
		return YES;
	}
}

#pragma mark -
#pragma mark ReadmillFinishReadUIDelegate

-(void)readmillReadDidUpdateMetadataSuccessfully:(ReadmillRead *)read {
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [[self delegate] finishReadUI:self didFinishRead:[self read]];
    [[NSNotificationCenter defaultCenter] postNotificationName:ReamillUIPresenterShouldDismissViewNotification
                                                        object:self];
}

-(void)readmillRead:(ReadmillRead *)read didFailToUpdateMetadataWithError:(NSError *)error {
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [[self delegate] finishReadUI:self didFailToFinishRead:[self read] withError:error];
    [[NSNotificationCenter defaultCenter] postNotificationName:ReamillUIPresenterShouldDismissViewNotification
                                                        object:self];
}

@end
