//
//  ReadmillConnectBookUI.m
//  Readmill Framework
//
//  Created by Readmill on 26/01/2011.
//  Copyright 2011 Readmill. All rights reserved.
//

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
        
        //[self setModalInPopover:YES];
        [self setModalPresentationStyle:UIModalPresentationFormSheet];
        [self setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
        [self setContentSizeForViewInPopover:CGSizeMake(600.0, 400.0)];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(willBeDismissed:)
                                                     name:ReamillUIPresenterWillDismissViewFromCloseButtonNotification
                                                   object:nil];
        
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
    
    activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [activityIndicator setCenter:CGPointMake(floorf([containerView frame].size.width / 2), floorf([containerView frame].size.height / 2))];
    [activityIndicator setHidesWhenStopped:YES];
    [activityIndicator startAnimating];
    
    [containerView addSubview:webView];
    [containerView addSubview:activityIndicator];
    
    [self setView:containerView];
    
    NSURL *url = [[[self user] apiWrapper] connectBookUIURLForBookWithId:[[self book] bookId]];
    
    [webView loadRequest:[NSURLRequest requestWithURL:url]];
}

-(void)viewDidAppear:(BOOL)animated {
    [[self view] setFrame:CGRectMake(0.0, 0.0, 600.0, 400.0)];
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
        
        [[self delegate] connect:self 
             didFailToLinkToBook:[self book]
                       withError:error];
        
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
        
        if ([parameters containsObject:@"skip"]) {
            [[self delegate] connect:self didSkipLinkingToBook:[self book]];
            [[NSNotificationCenter defaultCenter] postNotificationName:ReamillUIPresenterShouldDismissViewNotification
                                                                object:self];
        } else if ([parameters containsObject:@"connect"]) {
            
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
            [activityIndicator startAnimating];
            
            [[self user] findOrCreateReadForBook:[self book]
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
    [[NSNotificationCenter defaultCenter] postNotificationName:ReamillUIPresenterShouldDismissViewNotification
                                                        object:self];
}

-(void)readmillUser:(ReadmillUser *)user foundNoReadsForBook:(ReadmillBook *)aBook {
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [[self delegate] connect:self didSkipLinkingToBook:aBook];
    [[NSNotificationCenter defaultCenter] postNotificationName:ReamillUIPresenterShouldDismissViewNotification
                                                        object:self];
}

-(void)readmillUser:(ReadmillUser *)user failedToFindReadForBook:(ReadmillBook *)aBook withError:(NSError *)error {
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [[self delegate] connect:self didFailToLinkToBook:aBook withError:error];
    [[NSNotificationCenter defaultCenter] postNotificationName:ReamillUIPresenterShouldDismissViewNotification
                                                        object:self];
}


@end
