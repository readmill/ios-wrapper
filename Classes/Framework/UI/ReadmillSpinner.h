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
    ReadmillSpinnerTypeSmallGray = 2
} ReadmillSpinnerType;

@interface ReadmillSpinner : UIImageView {
    NSArray *greenImages, *smallGrayImages;
}
- (id)initWithSpinnerType:(ReadmillSpinnerType)type;
- (id)initAndStartSpinning;
- (id)initAndStartSpinning:(ReadmillSpinnerType)type;

@property (nonatomic, retain) NSArray *greenImages, *smallGrayImages;
@end
