/*
 Copyright (c) 2011 Readmill LTD
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */

#if defined(__IPHONE_OS_VERSION_MIN_REQUIRED)
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "ReadmillDismissingView.h"

static NSString * const ReadmillUIPresenterShouldDismissViewNotification = @"ReadmillUIPresenterShouldDismissViewNotification";
static NSString * const ReadmillUIPresenterDidAnimateOut = @"ReadmillUIPresenterDidAnimateOut";
static NSString * const ReadmillUIPresenterDidAnimateIn = @"ReadmillUIPresenterDidAnimateIn";

@interface ReadmillUIPresenter : UIViewController <ReadmillDismissingViewDelegate> {
@private
    
    UIView *contentContainerView;
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
 @property isVisible
 @brief   Yes if presenter is visible on screen, else NO
 */
@property (nonatomic, readonly) BOOL isVisible;


/*!
 @param theParentViewController The view controller that this presenter should be displayed in.
 @param animated Whether to animate the view onto the screen.
 @brief   Present a view controller onto the screen.
 */
-(void)presentInViewController:(UIViewController *)theParentViewController animated:(BOOL)animated;

/*!
 @param theParentViewController The view controller that this presenter should be displayed in.
 @brief   Present a view controller onto the screen with an animation.
 */
-(void)presentInViewController:(UIViewController *)theParentViewController;

/*!
 @param animated Whether to animate the view off the screen.
 @brief   Remove a presented view controller.
 */
-(void)dismissPresenterAnimated:(BOOL)animated;

/*!
 @brief   Remove a presented view controller with an animation.
 */
-(void)dismissPresenter;

/*!
 @param aContentViewController Sets the contentViewController.
 @brief   Sets and displays the view of the contentViewController. To use when the view of the contentViewController needs loading time.
 */
- (void)setAndDisplayContentViewController:(UIViewController *)aContentViewController;
@end

#endif
