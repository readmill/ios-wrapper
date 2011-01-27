//
//  ReadmillUIPresenter.h
//  Readmill Framework
//
//  Created by Readmill on 27/01/2011.
//  Copyright 2011 Readmill. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString * const ReamillUIPresenterShouldDismissViewNotification = @"ReamillUIPresenterShouldDismissViewNotification";
static NSString * const ReamillUIPresenterWillDismissViewFromCloseButtonNotification = @"ReamillUIPresenterWillDismissViewFromCloseButtonNotification";

@interface ReadmillUIPresenter : UIViewController {
@private
    
    UIView *contentContainerView;
    UIView *closeButtonView;
    UIView *backgroundView;
    UIViewController *contentViewController;
    
}

@property (nonatomic, readonly, retain) UIViewController *contentViewController;

-(id)initWithContentViewController:(UIViewController *)aContentViewController;

-(void)presentInView:(UIView *)parentView animated:(BOOL)animated;
-(void)dismissPresenterAnimated:(BOOL)animated;

@end
