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
#import "ReadmillUser.h"
#import "ReadmillRead.h"
#import "ReadmillBook.h"
#import "ReadmillURLExtensions.h"

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
    
    NSString *ISBN, *bookTitle, *author;
    id <ReadmillConnectBookUIDelegate> delegate;
    
}
// TODO desc
- (id)initWithUser:(ReadmillUser *)aUser ISBN:(NSString *)ISBN title:(NSString *)title author:(NSString *)author;

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

// TODO
@property (nonatomic, readonly, retain) NSString *ISBN;
@property (nonatomic, readonly, retain) NSString *bookTitle;
@property (nonatomic, readonly, retain) NSString *author;
@end
