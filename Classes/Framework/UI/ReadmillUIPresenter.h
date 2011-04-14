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

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "ReadmillSpinner.h"
#import "DismissingView.h"

static NSString * const ReadmillUIPresenterShouldDismissViewNotification = @"ReadmillUIPresenterShouldDismissViewNotification";
static NSString * const ReadmillUIPresenterDidAnimateOut = @"ReadmillUIPresenterDidAnimateOut";
static NSString * const ReadmillUIPresenterDidAnimateIn = @"ReadmillUIPresenterDidAnimateIn";

@interface ReadmillUIPresenter : UIViewController {
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
@property (nonatomic, retain) UIViewController *contentViewController;

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
- (void)setAndDisplayContentViewController:(UIViewController *)aContentViewController;
@end
