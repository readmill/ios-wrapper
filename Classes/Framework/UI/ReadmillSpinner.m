//
//  ReadmillSpinner.m
//  Readmill
//
//  Created by Martin Hwasser on 3/28/11.
//  Copyright 2011 Readmill. All rights reserved.
//

#import "ReadmillSpinner.h"


@implementation ReadmillSpinner

- (id)init {
    self = [super initWithImage:[UIImage imageNamed:@"001c.png"]];
    if (self) {
        
        //Add more images which will be used for the animation
        [self setAnimationImages:[NSArray arrayWithObjects:
                                              [UIImage imageNamed:@"001c.png"],
                                              [UIImage imageNamed:@"002c.png"],
                                              [UIImage imageNamed:@"003c.png"],
                                              [UIImage imageNamed:@"004c.png"],
                                              [UIImage imageNamed:@"005c.png"],
                                              [UIImage imageNamed:@"006c.png"],
                                              [UIImage imageNamed:@"007c.png"],
                                              [UIImage imageNamed:@"008c.png"],
                                              [UIImage imageNamed:@"009c.png"],
                                              [UIImage imageNamed:@"010c.png"],
                                              [UIImage imageNamed:@"011c.png"],
                                              [UIImage imageNamed:@"012c.png"],
                                              [UIImage imageNamed:@"013c.png"],
                                              [UIImage imageNamed:@"014c.png"],
                                              [UIImage imageNamed:@"015c.png"],
                                              [UIImage imageNamed:@"016c.png"],
                                              [UIImage imageNamed:@"017c.png"],
                                              [UIImage imageNamed:@"018c.png"],
                                              [UIImage imageNamed:@"019c.png"],
                                              [UIImage imageNamed:@"020c.png"],
                                              [UIImage imageNamed:@"021c.png"],
                                              [UIImage imageNamed:@"022c.png"],
                                              [UIImage imageNamed:@"023c.png"],
                                              [UIImage imageNamed:@"024c.png"],
                                              [UIImage imageNamed:@"025c.png"],
                                              [UIImage imageNamed:@"026c.png"],
                                              [UIImage imageNamed:@"027c.png"],
                                              [UIImage imageNamed:@"028c.png"],
                                              [UIImage imageNamed:@"029c.png"],
                                              [UIImage imageNamed:@"030c.png"],
                                              nil]];
        
        //Set the duration of the animation (play with it
        //until it looks nice for you)
        [self setAnimationDuration:1.0];
        [self setAnimationRepeatCount:0];
        [self setHidden:YES];

    }
    return self;
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
    [super dealloc];
}

@end
