//
//  ReadmillSpinner.h
//  Readmill
//
//  Created by Martin Hwasser on 3/28/11.
//  Copyright 2011 Readmill. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    ReadmillSpinnerTypeDefault = 1,
    ReadmillSpinnerTypeSmallGray = 2,
    ReadmillSpinnerTypeSmallWhite = 3
} ReadmillSpinnerType;

@interface ReadmillSpinner : UIImageView

- (id)initWithSpinnerType:(ReadmillSpinnerType)type;
- (id)initAndStartSpinning;
- (id)initAndStartSpinning:(ReadmillSpinnerType)type;

@end
