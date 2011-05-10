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
#import "ReadmillRead.h"

@class ReadmillFinishReadUI;

@protocol ReadmillFinishReadUIDelegate <NSObject>

/*!
 @param readUI The ReadmillFinishReadUI object sending the message.
 @brief   Called when finishing a read was skipped by the user.
 */
-(void)finishReadUIWillCloseWithNoAction:(ReadmillFinishReadUI *)readUI;

/*!
 @param readUI The ReadmillFinishReadUI object sending the message.
 @param aRead The read that was finished.
 @brief   Called when finishing a read completed successfully.
 */
-(void)finishReadUI:(ReadmillFinishReadUI *)readUI didFinishRead:(ReadmillRead *)aRead;

/*!
 @param readUI The ReadmillFinishReadUI object sending the message.
 @param aRead The read that was not finished.
 @param error The error that occurred.
 @brief   Called when finishing a read failed with an error.
 */
-(void)finishReadUI:(ReadmillFinishReadUI *)readUI didFailToFinishRead:(ReadmillRead *)aRead withError:(NSError *)error;

@end

@interface ReadmillFinishReadUI : UIViewController <UIWebViewDelegate> {
@private
    
    ReadmillRead *read;
    //UIActivityIndicatorView *activityIndicator;
    
    id <ReadmillFinishReadUIDelegate> delegate;
    
}

/*!
 @param aRead The ReadmillRead to finish.
 @result The initialized ReadmillFinishReadUI object.
 @brief   Initialize a ReadmillFinishReadUI.
 */
-(id)initWithRead:(ReadmillRead *)aRead;

/*!
 @property read
 @brief The ReadmillRead object being finished.
 */
@property (nonatomic, readonly, retain) ReadmillRead *read;

/*!
 @property delegate 
 @brief The delegate object to be informed of success or failure.
 */
@property (nonatomic, readwrite, assign) id <ReadmillFinishReadUIDelegate> delegate;

@end
