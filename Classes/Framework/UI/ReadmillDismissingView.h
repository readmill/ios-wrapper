//
//  ReadmillDismissingView.h
//  Readmill
//
//  Created by Martin Hwasser on 3/22/11.
//  Copyright 2011 Readmill. All rights reserved.
//

#if defined(__IPHONE_OS_VERSION_MIN_REQUIRED)
#import <UIKit/UIKit.h>

@protocol ReadmillDismissingViewDelegate
- (void)dismissView;
@end

@interface ReadmillDismissingView : UIView {
    id<ReadmillDismissingViewDelegate> delegate;
}
@property (nonatomic, assign) id<ReadmillDismissingViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame delegate:(id<ReadmillDismissingViewDelegate>)target;
- (void)addToView:(UIView *)aView;

@end

#endif
