//
//  DismissingView.m
//  Readmill
//
//  Created by Martin Hwasser on 3/22/11.
//  Copyright 2011 Readmill. All rights reserved.
//

#import "DismissingView.h"


@implementation DismissingView

@synthesize target;
@synthesize selector;

- (id)initWithFrame:(CGRect)frame selector:(SEL)aSelector target:(id)aTarget {
    self = [super initWithFrame:frame];
    if (self) {
        self.opaque = NO;
        self.backgroundColor = [UIColor clearColor];
        self.selector = aSelector;
        self.target = aTarget;
    }
    return self;
}

- (void)addToView:(UIView *)view {
    UIView *front = [view.subviews lastObject];
    [view addSubview:self];
    [view bringSubviewToFront:front];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [target performSelector:selector withObject:self];
    [self removeFromSuperview];
}
@end