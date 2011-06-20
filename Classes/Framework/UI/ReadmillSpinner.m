//
//  ReadmillSpinner.m
//  Readmill
//
//  Created by Martin Hwasser on 3/28/11.
//  Copyright 2011 Readmill. All rights reserved.
//

#import "ReadmillSpinner.h"


@implementation ReadmillSpinner

- (id)initWithSpinnerType:(ReadmillSpinnerType)type {
    if (type == ReadmillSpinnerTypeDefault) {
        self = [super initWithImage:[UIImage imageNamed:@"spinnergreen1.png"]];
        
        NSMutableArray *images = [[NSMutableArray alloc] init];
        for (NSInteger i = 1; i <= 30; i++) {
            NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
            NSString *filename = [NSString stringWithFormat:@"spinnergreen%d.png", i];
            [images addObject:[UIImage imageNamed:filename]];
            [pool drain];
        }
        [self setAnimationImages:images];
        [images release];
        
    } else if (type == ReadmillSpinnerTypeSmallGray) {
        self = [super initWithImage:[UIImage imageNamed:@"spinnersmallgray1.png"]];
        NSMutableArray *images = [[NSMutableArray alloc] init];
        for (NSInteger i = 1; i <= 30; i++) {
            NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
            NSString *filename = [NSString stringWithFormat:@"spinner_1616_grey_%d.png", i];
            [images addObject:[UIImage imageNamed:filename]];
            [pool drain];
        }
        [self setAnimationImages:images];
        [images release];

    }
    if (self) {
        
        //Add more images which will be used for the animation
        [self setAnimationDuration:1.0];            

        [self setAnimationRepeatCount:0];
        [self setHidden:YES];

    }
    return self;
}
- (id)initAndStartSpinning:(ReadmillSpinnerType)type {
    self = [self initWithSpinnerType:type];
    if (self) {
        [self startAnimating];
    }
    return self;
}
- (id)initAndStartSpinning {
    return [self initAndStartSpinning:ReadmillSpinnerTypeDefault];
}
- (id)init {
    return [self initWithSpinnerType:ReadmillSpinnerTypeDefault];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
- (void)startAnimating {
    [self setHidden:NO];
    [super startAnimating];
}
- (void)stopAnimating {
    [super stopAnimating];
    [self setHidden:YES];
}
- (void)dealloc
{
    [self setAnimationImages:nil];
    [super dealloc];
}

@end
