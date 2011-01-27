//
//  ReadmillConnectBookUI.h
//  Readmill Framework
//
//  Created by Readmill on 26/01/2011.
//  Copyright 2011 Readmill. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ReadmillUser.h"
#import "ReadmillRead.h"
#import "ReadmillBook.h"

@class ReadmillConnectBookUI;

@protocol ReadmillConnectBookUIDelegate <NSObject>

/*!
 @param connectionUI The ReadmillConnectBookUI object sending the message.
 @param aBook The book that was linked to.
 @param aRead The created ReadmillRead object.
 @brief   Called when a user successfully linked to a Readmill book.
 */
-(void)connect:(ReadmillConnectBookUI *)connectionUI didSucceedToLinkToBook:(ReadmillBook *)aBook withRead:(ReadmillRead *)aRead;

/*!
 @param connectionUI The ReadmillConnectBookUI object sending the message.
 @param aBook The book that was not linked to.
 @brief   Called when a user skipped linking to a Readmill book.
 */
-(void)connect:(ReadmillConnectBookUI *)connectionUI didSkipLinkingToBook:(ReadmillBook *)aBook;

/*!
 @param connectionUI The ReadmillConnectBookUI object sending the message.
 @param aBook The book that was not linked to.
 @param error The error that occurred.
 @brief   Called when linking to a book failed with an error.
 */
-(void)connect:(ReadmillConnectBookUI *)connectionUI didFailToLinkToBook:(ReadmillBook *)aBook withError:(NSError *)error;

@end

@interface ReadmillConnectBookUI : UIViewController <UIWebViewDelegate, ReadmillReadFindingDelegate> {
@private
    
    ReadmillUser *user;
    ReadmillBook *book;
    UIActivityIndicatorView *activityIndicator;
    
    id <ReadmillConnectBookUIDelegate> delegate;
    
}

/*!
 @param aUser The Readmill user to connect.
 @param bookToConnectTo The book the user wishes to connect to. 
 @result The initialized ReadmillConnectBookUI object.
 @brief   Initialize a ReadmillConnectBookUI.
 */
-(id)initWithUser:(ReadmillUser *)aUser book:(ReadmillBook *)bookToConnectTo;

/*!
 @property user 
 @brief The user being linked.
 */
@property (nonatomic, readonly, retain) ReadmillUser *user;

/*!
 @property book 
 @brief The book being linked.
 */
@property (nonatomic, readonly, retain) ReadmillBook *book;

/*!
 @property delegate 
 @brief The delegate object to be informed of success or failure.
 */
@property (nonatomic, readwrite, retain) id <ReadmillConnectBookUIDelegate> delegate;

@end
