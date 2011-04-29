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
#import "ReadmillURLExtensions.h"

@interface ReadmillConnectBookUI ()

@property (nonatomic, readwrite, retain) ReadmillUser *user;
@property (nonatomic, readwrite, retain) ReadmillBook *book;

@property (nonatomic, readwrite, retain) NSString *ISBN;
@property (nonatomic, readwrite, retain) NSString *bookTitle;
@property (nonatomic, readwrite, retain) NSString *author;
@end

@implementation ReadmillConnectBookUI

-(id)initWithUser:(ReadmillUser *)aUser ISBN:(NSString *)anISBN title:(NSString *)aTitle author:(NSString *)anAuthor {
    
    if ((self = [super init])) {
        [self setUser:aUser];
        [self setISBN:anISBN];
        [self setBookTitle:aTitle];
        [self setAuthor:anAuthor];
        
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

@synthesize ISBN;
@synthesize bookTitle;
@synthesize author;

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
    
    UIWebView *webView = [[[UIWebView alloc] initWithFrame:CGRectMake(0.0, 0.0, 648.0, 440.0)] autorelease];
    [[[webView subviews] lastObject] setScrollEnabled:NO];
    //[[[webView subviews] lastObject] setBackgroundColor:[UIColor clearColor]];
    [webView setDelegate:self];
    [webView setHidden:YES];
    
    UIView *containerView = [[[UIView alloc] initWithFrame:[webView frame]] autorelease];

    [containerView addSubview:webView];
    [containerView setHidden:YES];
    [self setView:containerView];
    
    NSURL *url = [[[self user] apiWrapper] URLForConnectingBookWithISBN:[self ISBN] 
                                                                  title:[self bookTitle] 
                                                                 author:[self author]];
    
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
	
    [webView sizeToFit];

    [webView setAlpha:0.0];
    [webView setHidden:NO];
    [self.view setHidden:NO];
    [webView setBackgroundColor:[UIColor clearColor]];
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
    
	NSURL *URL = [request URL];
    if ([[URL absoluteString] hasPrefix:@"readmill"]) {
		
        // Can be...
        // readmill://connect?skip=true
        // readmill://connect?uri=location to read
        // readmill://connect?error?message=something
        
        // Immediately remove the popover
        [[NSNotificationCenter defaultCenter] postNotificationName:ReadmillUIPresenterShouldDismissViewNotification
                                                            object:self];
        
        NSString *action = [URL host];
        NSDictionary *parameters = [URL queryAsDictionary];
        if ([action isEqualToString:@"connect"]) {
            NSString *uri = @"uri";
            if ([[parameters valueForKey:@"skip"] isEqualToString:@"true"]) {
                [[self delegate] connect:self didSkipLinkingToBook:[self book]];
            } else if ((uri = [parameters valueForKey:uri])) {
                
                // The uri parameter is the full URL to the read we want to connect to. 
                NSError *error = nil;
                NSURL *url = [NSURL URLWithString:uri];
                NSLog(@"url: %@", url);
                NSDictionary *apiResponse = [[[self user] apiWrapper] readWithURL:url error:&error];
                if (nil == error) {
                    ReadmillRead *read = [[ReadmillRead alloc] initWithAPIDictionary:apiResponse apiWrapper:[[self user] apiWrapper]];
                    [[self delegate] connect:self didSucceedToLinkToBook:[self book] withRead:read];
                    [read release];
                } else {
                    NSLog(@"Error: %@", error);
                }
            }
        } else if ([action isEqualToString:@"error"]) {
            NSString *http_status = [parameters valueForKey:@"http_status"];
            NSInteger code = 0;
            if (http_status != nil) {
                code = [http_status integerValue];
            }
            NSError *error = [[NSError alloc] initWithDomain:kReadmillErrorDomain code:code userInfo:parameters];
            [[self delegate] connect:self didFailToLinkToBook:[self book] withError:[error autorelease]];
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
