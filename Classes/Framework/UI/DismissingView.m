//
//  DismissingView.m
//  Readmill
//
//  Created by Martin Hwasser on 3/22/11.
//  Copyright 2011 Readmill. All rights reserved.
//

#import "DismissingView.h"


@implementation DismissingView

@synthesize delegate;

- (id)initWithFrame:(CGRect)frame delegate:(id<DismissingViewDelegate>)dismissingViewDelegate {
    self = [super initWithFrame:frame];
    if (self) {
        self.opaque = NO;
        self.backgroundColor = [UIColor clearColor];
        self.delegate = dismissingViewDelegate;
        self.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    }
    return self;
}

- (void)addToView:(UIView *)view {
    UIView *front = [view.subviews lastObject];
    [view addSubview:self];
    [view bringSubviewToFront:front];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [delegate dismissView];
    [self removeFromSuperview];
}
- (void)dealloc {
    [self removeFromSuperview];
    self.delegate = nil;
    [super dealloc];
}
@end