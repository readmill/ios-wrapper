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

/*!
 @param aContentViewController The view controller to be presented to the user. Should be smaller than the screen.
 @result The initialized ReadmillUIPresenter.
 @brief   Initialize a ReadmillUIPresenter.
 */
-(id)initWithContentViewController:(UIViewController *)aContentViewController;

/*!
 @property contentViewController
 @brief   The view controller being presented.
*/
@property (nonatomic, readonly, retain) UIViewController *contentViewController;

/*!
 @param theParentViewController The view controller that this presenter should be displayed in.
 @param animated Whether to animate the view onto the screen.
 @brief   Present a view controller onto the screen.
 
 The behaviour of this is largely the same as calling -presentModalViewController:animated:, with a presentation style of 
 UIModalPresentationFormSheet. However, this method places a "close" button at the top left of the presented view and 
 allows for views of any size and shape.
 */
-(void)presentInViewController:(UIViewController *)theParentViewController animated:(BOOL)animated;

/*!
 @param animated Whether to animate the view off the screen.
 @brief   Remove a presented view controller.
 */
-(void)dismissPresenterAnimated:(BOOL)animated;

@end
