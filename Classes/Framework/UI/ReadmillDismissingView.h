//
//  ReadmillDismissingView.h
//  Readmill
//
//  Created by Martin Hwasser on 3/22/11.
//  Copyright 2011 Readmill. All rights reserved.
//

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
