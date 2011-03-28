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
    self = [super initWithImage:[UIImage imageNamed:@"001a.png"]];
    if (self) {
        
        //Add more images which will be used for the animation
        [self setAnimationImages:[NSArray arrayWithObjects:
                                              [UIImage imageNamed:@"001a.png"],
                                              [UIImage imageNamed:@"002a.png"],
                                              [UIImage imageNamed:@"003a.png"],
                                              [UIImage imageNamed:@"004a.png"],
                                              [UIImage imageNamed:@"005a.png"],
                                              [UIImage imageNamed:@"006a.png"],
                                              [UIImage imageNamed:@"007a.png"],
                                              [UIImage imageNamed:@"008a.png"],
                                              [UIImage imageNamed:@"009a.png"],
                                              [UIImage imageNamed:@"010a.png"],
                                              [UIImage imageNamed:@"011a.png"],
                                              [UIImage imageNamed:@"012a.png"],
                                              [UIImage imageNamed:@"013a.png"],
                                              [UIImage imageNamed:@"014a.png"],
                                              [UIImage imageNamed:@"015a.png"],
                                              [UIImage imageNamed:@"016a.png"],
                                              [UIImage imageNamed:@"017a.png"],
                                              [UIImage imageNamed:@"018a.png"],
                                              [UIImage imageNamed:@"019a.png"],
                                              [UIImage imageNamed:@"020a.png"],
                                              [UIImage imageNamed:@"021a.png"],
                                              [UIImage imageNamed:@"022a.png"],
                                              [UIImage imageNamed:@"023a.png"],
                                              [UIImage imageNamed:@"024a.png"],
                                              [UIImage imageNamed:@"025a.png"],
                                              [UIImage imageNamed:@"026a.png"],
                                              [UIImage imageNamed:@"027a.png"],
                                              [UIImage imageNamed:@"028a.png"],
                                              [UIImage imageNamed:@"029a.png"],
                                              [UIImage imageNamed:@"030a.png"],
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
