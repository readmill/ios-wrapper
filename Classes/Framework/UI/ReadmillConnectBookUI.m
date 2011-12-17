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
#import "NSURL+ReadmillURLParameters.h"
#import "UIApplication+ReadmillNetworkActivity.h"
#import "ReadmillSpinner.h"

@interface ReadmillConnectBookUI ()
@property (nonatomic, readwrite, retain) UIWebView *webView;
@property (nonatomic, readwrite, retain) ReadmillUser *user;
@property (nonatomic, readwrite, retain) ReadmillBook *book;

@property (nonatomic, retain) ReadmillSpinner *spinner;
@end

@implementation ReadmillConnectBookUI

@synthesize user;
@synthesize delegate;
@synthesize book;

@synthesize spinner;
@synthesize webView;

- (id)initWithUser:(ReadmillUser *)aUser 
              ISBN:(NSString *)anISBN 
             title:(NSString *)aTitle
            author:(NSString *)anAuthor 
{
    if ((self = [super init])) {
        [self setUser:aUser];
        
        NSMutableDictionary *bookDictionary = [NSMutableDictionary dictionary];
        [bookDictionary setValue:anISBN forKey:kReadmillAPIBookISBNKey];
        [bookDictionary setValue:aTitle forKey:kReadmillAPIBookTitleKey];
        [bookDictionary setValue:anAuthor forKey:kReadmillAPIBookAuthorKey];
        [self setBook:[[[ReadmillBook alloc] initWithAPIDictionary:bookDictionary] autorelease]];
    }
    return self;
}
- (id)initWithUser:(ReadmillUser *)aUser 
              book:(ReadmillBook *)aBook
{
    self = [super init];
    if (self) {
        [self setUser:aUser];
        [self setBook:aBook];
    }
    return self;
}
- (void)cleanupWebView 
{
    [webView setDelegate:nil];
    if ([webView isLoading]) {
        [[UIApplication sharedApplication] readmill_popNetworkActivity];
    }
    [webView stopLoading];
    // This is a hack to avoid a memory leak (as of iOS5.0 where
    // the heap keeps growing
    [webView loadHTMLString:@"" baseURL:nil];
    [self setWebView:nil];
}

- (void)dealloc 
{    
    [self setUser:nil];
    [self setBook:nil];
    [self setDelegate:nil];
    [self setSpinner:nil];
    [self cleanupWebView];
    [self setView:nil];

    [super dealloc];
}


- (void)didReceiveMemoryWarning 
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)willBeDismissed:(NSNotification *)notification 
{
    [[self delegate] connect:self didSkipLinkingToBook:[self book]];
}

#pragma mark - View lifecycle

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView 
{    
    webView = [[UIWebView alloc] initWithFrame:CGRectMake(0.0, 0.0, 648.0, 440.0)];
    [[[webView subviews] lastObject] setScrollEnabled:NO];
    [webView setDelegate:self];
    [webView setHidden:YES];
    // Hack to avoid blurry text in landscape
    [webView setOpaque:NO];

    UIView *containerView = [[UIView alloc] initWithFrame:[webView frame]];
    [containerView setBackgroundColor:[UIColor whiteColor]];
    [containerView addSubview:webView];
    [self setView:containerView];
    [containerView release];
    
    spinner = [[ReadmillSpinner alloc] initAndStartSpinning];
    [spinner setCenter:[self.view center]];
    [self.view addSubview:spinner];
    
    NSURL *url = [[[self user] apiWrapper] URLForConnectingBookWithISBN:[book isbn] 
                                                                  title:[book title] 
                                                                 author:[book author]];

    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url
                                                  cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData 
                                              timeoutInterval:30];
    [webView loadRequest:request];
    [request release];
}

- (void)viewDidUnload 
{
    [super viewDidUnload];

    [self setSpinner:nil];
    [self cleanupWebView];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
    // Return YES for supported orientations
	return NO;
}

#pragma mark -
#pragma mark UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView 
{	
    [[UIApplication sharedApplication] readmill_pushNetworkActivity];
}

- (void)webViewDidFinishLoad:(UIWebView *)aWebView 
{	
    [aWebView sizeToFit];
    
    [aWebView setAlpha:0.0];
    [aWebView setHidden:NO];
    [self.view setHidden:NO];
    [aWebView setBackgroundColor:[UIColor clearColor]];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [UIView setAnimationDuration:0.2];
    [aWebView setAlpha:1.0];
    [UIView commitAnimations];
    
    [spinner setHidden:YES];
    [[UIApplication sharedApplication] readmill_popNetworkActivity];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error 
{	    
    [spinner setHidden:YES];
    [[UIApplication sharedApplication] readmill_popNetworkActivity];
	
	if ([error code] != -999) {
        // ^ Load failed because the user clicked a new link to load
        [[self delegate] connect:self 
             didFailToLinkToBook:[self book]
                       withError:error];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:ReadmillUIPresenterShouldDismissViewNotification
                                                            object:self];
        
	}
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType 
{    
	NSURL *URL = [request URL];
    if ([[URL scheme] isEqualToString:@"readmill"]) {
        
        // Dismiss right away
        [[NSNotificationCenter defaultCenter] postNotificationName:ReadmillUIPresenterShouldDismissViewNotification
                                                            object:self];
		
        // Can be...
        // readmill://dismiss
        // readmill://change?uri="uri to reading"
        // readmill://error
                
        NSString *action = [URL host];
        NSDictionary *parameters = [URL queryAsDictionary];

        if ([action isEqualToString:@"dismiss"]) {
            [[self delegate] connect:self didSkipLinkingToBook:[self book]];
        }
        else if ([action isEqualToString:@"change"]) {            
            NSString *uri = @"uri";
            // The uri parameter is the full URL to the reading we want to connect to. 
            if ((uri = [parameters valueForKey:uri])) {
                              
                __block typeof(self) bself = self;
                
                [bself retain];
                ReadmillAPICompletionHandler completionHandler = ^(id result, NSError *error) {
                    
                    if (result && error == nil) {
                        NSDictionary *bookDictionary = [result valueForKey:kReadmillAPIBookKey];
                        [bself->book updateWithAPIDictionary:bookDictionary];
                        
                        ReadmillReading *reading = [[ReadmillReading alloc] initWithAPIDictionary:result 
                                                                                       apiWrapper:[bself->user apiWrapper]];
                        
                        [bself->delegate connect:bself
                          didSucceedToLinkToBook:bself->book
                                     withReading:reading];
                        
                        [reading release]; 
                        
                    } else {
                        
                        NSError *error = [NSError errorWithDomain:kReadmillDomain code:0 userInfo:parameters];
                        [bself->delegate connect:bself
                             didFailToLinkToBook:bself->book
                                       withError:error];
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [bself release];
                    });
                };

                [[[self user] apiWrapper] readingWithURLString:uri 
                                             completionHandler:completionHandler];
                
            }
        } else if ([action isEqualToString:@"error"]) {
            
            NSError *error = [NSError errorWithDomain:kReadmillDomain code:0 userInfo:parameters];
            [[self delegate] connect:self
                 didFailToLinkToBook:[self book] 
                           withError:error];
        }
        
        return NO;
    } else {
        return YES;
    }
}

@end
