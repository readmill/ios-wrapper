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
#import "ReadmillReading.h"

@class ReadmillViewReadingUI;

@protocol ReadmillViewReadingUIDelegate <NSObject>

/*!
 @param readingUI The ReadmillViewReadingUI object sending the message.
 @brief   Called when finishing a reading was skipped by the user.
 */
-(void)viewReadingUIWillCloseWithNoAction:(ReadmillViewReadingUI *)readingUI;

/*!
 @param readingUI The ReadmillViewReadingUI object sending the message.
 @param aReading The reading that was finished.
 @brief   Called when finishing a reading completed successfully.
 */
-(void)viewReadingUI:(ReadmillViewReadingUI *)readingUI didFinishReading:(ReadmillReading *)aReading;

/*!
 @param readingUI The ReadmillViewReadingUI object sending the message.
 @param aReading The reading that was not finished.
 @param error The error that occurred.
 @brief   Called when finishing a reading failed with an error.
 */
-(void)viewReadingUI:(ReadmillViewReadingUI *)readingUI didFailToFinishReading:(ReadmillReading *)aReading withError:(NSError *)error;

@end

@interface ReadmillViewReadingUI : UIViewController <UIWebViewDelegate> {
@private
    
    ReadmillReading *reading;
    
    id <ReadmillViewReadingUIDelegate> delegate;
    
}

/*!
 @param aReading The ReadmillReading to finish.
 @result The initialized ReadmillViewReadingUI object.
 @brief   Initialize a ReadmillViewReadingUI.
 */
-(id)initWithReading:(ReadmillReading *)aReading;

/*!
 @property reading
 @brief The ReadmillReading object being finished.
 */
@property (nonatomic, readonly, retain) ReadmillReading *reading;

/*!
 @property delegate 
 @brief The delegate object to be informed of success or failure.
 */
@property (nonatomic, readwrite, assign) id <ReadmillViewReadingUIDelegate> delegate;

@end
