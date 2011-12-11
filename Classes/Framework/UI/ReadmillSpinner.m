//
//  ReadmillSpinner.m
//  Readmill
//
//  Created by Martin Hwasser on 3/28/11.
//  Copyright 2011 Readmill. All rights reserved.
//

#import "ReadmillSpinner.h"

@interface ReadmillSpinner ()

- (NSArray *)spinnerImagesDefault;
- (NSArray *)spinnerImagesSmallGray;

@end


@implementation ReadmillSpinner

- (id)initWithSpinnerType:(ReadmillSpinnerType)type 
{    
    self = [super init];
    if (self) {

        switch (type) {
            case ReadmillSpinnerTypeDefault:
                [self setAnimationImages:[self spinnerImagesDefault]];
                break;
            case ReadmillSpinnerTypeSmallGray:
                [self setAnimationImages:[self spinnerImagesSmallGray]];
                break;
            default:
                NSLog(@"Invalid ReadmillSpinnerType.");
                break;
        }
        
        CGRect frame = [self frame];
        frame.size = [[[self animationImages] lastObject] size];
        [self setFrame:frame];
        
        [self setAnimationDuration:1.0];            
        [self setAnimationRepeatCount:0];
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

- (NSArray *)imageArrayWithFormat:(NSString *)formatString count:(NSInteger)count
{
    NSBundle *resourceBundle = [self resourceBundle];
    
    NSMutableArray *images = [[NSMutableArray alloc] initWithCapacity:count];
    
    for (NSInteger i = 1; i <= count; i++) {
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        NSString *filename = [NSString stringWithFormat:formatString, i];
        NSString *filePath = [resourceBundle pathForResource:filename ofType:@"png"];
        [images addObject:[UIImage imageWithContentsOfFile:filePath]];
        [pool drain];
    }
    return [images autorelease];
}
- (NSArray *)spinnerImagesDefault
{
    static NSArray *spinnerImagesDefault = nil;
    
    if (!spinnerImagesDefault) {
        NSInteger numberOfImages = 30;
        NSString *filenameFormat = @"green/spinnergreen%d";
        spinnerImagesDefault = [[self imageArrayWithFormat:filenameFormat 
                                                     count:numberOfImages] copy];
    }
    return spinnerImagesDefault;
}

- (NSArray *)spinnerImagesSmallGray
{
    static NSArray *spinnerImagesSmallGray = nil;
    
    if (!spinnerImagesSmallGray) {
        NSInteger numberOfImages = 30;
        NSString *filenameFormat = @"gray/spinner_1616_gray_%d";
        spinnerImagesSmallGray = [[self imageArrayWithFormat:filenameFormat 
                                                       count:numberOfImages] copy];
    }
    return spinnerImagesSmallGray;
}

- (void)startAnimating
{
    [self setHidden:NO];
    [super startAnimating];
}
- (void)stopAnimating 
{
    [super stopAnimating];
    [self setHidden:YES];
}
- (void)dealloc
{
    [self stopAnimating];
    [self setAnimationImages:nil];
    [super dealloc];
}

@end
