//
//  ReadmillConnectBookUI.h
//  Readmill Framework
//
//  Created by Readmill on 26/01/2011.
//  Copyright 2011 Readmill. All rights reserved.
//

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

@interface ReadmillFinishReadUI : UIViewController <UIWebViewDelegate, ReadmillReadUpdatingDelegate> {
@private
    
    ReadmillRead *read;
    UIActivityIndicatorView *activityIndicator;
    
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
@property (nonatomic, readwrite, retain) id <ReadmillFinishReadUIDelegate> delegate;

@end
