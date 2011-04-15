//
//  DismissingView.h
//  Readmill
//
//  Created by Martin Hwasser on 3/22/11.
//  Copyright 2011 Readmill. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DismissingViewDelegate
- (void)dismissView;
@end

@interface DismissingView : UIView {
    id<DismissingViewDelegate> delegate;
}
@property (nonatomic, assign) id<DismissingViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame delegate:(id<DismissingViewDelegate>)target;
- (void)addToView:(UIView *)aView;

@end
