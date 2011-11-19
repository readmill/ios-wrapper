//
//  ReadmillSpinner.m
//  Readmill
//
//  Created by Martin Hwasser on 3/28/11.
//  Copyright 2011 Readmill. All rights reserved.
//

#import "ReadmillSpinner.h"


@implementation ReadmillSpinner

- (id)initWithSpinnerType:(ReadmillSpinnerType)type 
{    
    resourceBundle = [[NSBundle alloc] initWithPath:[[NSBundle mainBundle] pathForResource:@"Readmill" ofType:@"bundle"]];
    
    NSInteger numberOfImages = 0;
    NSString *filenameFormat = nil;
    
    if (type == ReadmillSpinnerTypeDefault) {
        numberOfImages = 30;
        filenameFormat = @"green/spinnergreen%d";
    } else if (type == ReadmillSpinnerTypeSmallGray) {
        numberOfImages = 30;
        filenameFormat = @"gray/spinner_1616_gray_%d";
    }
    
    self = [super init];
    if (self) {
        NSAssert(resourceBundle != nil, @"Please move the Readmill.bundle into the Resource Directory of your Application!");
        
        NSMutableArray *images = [[NSMutableArray alloc] initWithCapacity:numberOfImages];
        
        for (NSInteger i = 1; i <= numberOfImages; i++) {
            NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
            NSString *filename = [NSString stringWithFormat:filenameFormat, i];
            NSString *filePath = [resourceBundle pathForResource:filename ofType:@"png"];
            [images addObject:[UIImage imageWithContentsOfFile:filePath]];
            [pool drain];
        }
        
        [self setAnimationImages:images];
        [images release];
        
        [self setAnimationDuration:1.0];            
        [self setAnimationRepeatCount:0];
        [self setHidden:YES];
        
        CGRect frame = [self frame];
        frame.size = [[[self animationImages] lastObject] size];
        [self setFrame:frame];
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
    [resourceBundle release];
    [super dealloc];
}

@end
