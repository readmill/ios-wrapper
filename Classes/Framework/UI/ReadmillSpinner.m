//
//  ReadmillSpinner.m
//  Readmill
//
//  Created by Martin Hwasser on 3/28/11.
//  Copyright 2011 Readmill. All rights reserved.
//

#import "ReadmillSpinner.h"
#import <QuartzCore/QuartzCore.h>


@implementation ReadmillSpinner

- (id)initWithSpinnerType:(ReadmillSpinnerType)type 
{    
    self = [super init];
    if (self) {
        NSBundle *resourceBundle = [self resourceBundle];
        NSString *filePath = nil;
        switch (type) {
            case ReadmillSpinnerTypeDefault:
            {
                filePath = [resourceBundle pathForResource:@"green/spinner_green_32x32" ofType:@"png"];
            }
            break;
            case ReadmillSpinnerTypeSmallGray:
            {
                filePath = [resourceBundle pathForResource:@"gray/spinner_gray_16x16" ofType:@"png"];    
            }
            break;
            case ReadmillSpinnerTypeSmallWhite:
            {
                filePath = [resourceBundle pathForResource:@"white/spinner_white_16x16" ofType:@"png"];    
            }
            break;
            default:
                NSLog(@"Invalid ReadmillSpinnerType.");
            break;
        }
        
        [self setImage:[UIImage imageWithContentsOfFile:filePath]];
                
        CGRect frame = [self frame];
        frame.size = [[self image] size];
        [self setFrame:frame];
        [self setHidden:YES];

    }
    return self;
}

- (id)initAndStartSpinning:(ReadmillSpinnerType)type 
{
    self = [self initWithSpinnerType:type];
    if (self) {
        [self startAnimating];
    }
    return self;
}

- (id)initAndStartSpinning 
{
    return [self initAndStartSpinning:ReadmillSpinnerTypeDefault];
}

- (id)init 
{
    return [self initWithSpinnerType:ReadmillSpinnerTypeDefault];
}

- (NSBundle *)resourceBundle 
{
    NSBundle *resourceBundle = [[NSBundle alloc] initWithPath:[[NSBundle mainBundle] pathForResource:@"Readmill" 
                                                                                              ofType:@"bundle"]];
    NSAssert(resourceBundle != nil, @"Please move the Readmill.bundle into the Resource Directory of your Application!");
    return [resourceBundle autorelease];
}

- (void)startAnimating
{
    [self setHidden:NO];
    CABasicAnimation *fullRotation; 
    fullRotation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    fullRotation.fromValue = [NSNumber numberWithFloat:0]; 
    fullRotation.toValue = [NSNumber numberWithFloat:(2 * M_PI)];
    fullRotation.duration = 1.0; 
    fullRotation.repeatCount = HUGE_VALF;
    fullRotation.removedOnCompletion = NO;
    [self.layer addAnimation:fullRotation forKey:@"spinner"];
}

/*
- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetAllowsAntialiasing(context, true);
    CGContextSetShouldAntialias(context, true);

 
}*/

- (void)stopAnimating 
{
    [self.layer removeAllAnimations];
    [self setHidden:YES];
}
- (void)dealloc
{
    [self stopAnimating];
    [super dealloc];
}

@end
