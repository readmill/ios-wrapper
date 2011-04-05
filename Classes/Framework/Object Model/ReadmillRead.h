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

#import <Foundation/Foundation.h>
#import "ReadmillAPIWrapper.h"
#import "ReadmillReadSession.h"

@class ReadmillRead;

@protocol ReadmillReadUpdatingDelegate <NSObject>

/*!
 @param read The read object that updated its metadata with the Readmill service successfully. 
 @brief   Delegate method informing the target that the given metadata update succeeded. 
 */
-(void)readmillReadDidUpdateMetadataSuccessfully:(ReadmillRead *)read;

/*!
 @param read The read object that failed to update its metadata with the Readmill service successfully.
 @param error The error that occurred.
 @brief   Delegate method informing the target that the given metadata update failed. 
 */
-(void)readmillRead:(ReadmillRead *)read didFailToUpdateMetadataWithError:(NSError *)error;

@end

@interface ReadmillRead : NSObject {
@private
    
    NSDate *dateAbandoned;
    NSDate *dateCreated;
    NSDate *dateFinished;
    NSDate *dateModified;
    NSDate *dateStarted;
    NSNumber *timeSpent, *estimatedTimeLeft;
    
    NSString *closingRemark;
    
    BOOL isPrivate;
    
    ReadmillReadState state;
    
    ReadmillBookId bookId;
    ReadmillUserId userId;
    ReadmillReadId readId;
    
    ReadmillAPIWrapper *apiWrapper;
    
    ReadmillReadProgress progress;
}

/*!
 @param apiDict An API read dictionary.
 @param wrapper The ReadmillAPIWrapper object to be used.
 @result The created read.
 @brief   Create a read with the given API dictionary and ReadmillAPIWrapper object. 
 
 Typically, you would get a ReadmillRead object using the convenience methods in ReadmillUser. 
 
 This is the designated initializer of this class.
 */
-(id)initWithAPIDictionary:(NSDictionary *)apiDict apiWrapper:(ReadmillAPIWrapper *)wrapper;

/*!
 @param apiDict An API read dictionary. 
 @brief  Update this read with an NSDictionary from a ReadmillAPIWrapper object.
 
 Typically, there's no need to call this method.
 */
-(void)updateWithAPIDictionary:(NSDictionary *)apiDict;

#pragma mark -
#pragma mark Updating

/*!
 @param newState The new read state.
 @param delegate The delegate object to be informed of success or failure. 
 @brief   Update the read state of this read. 
 */
-(void)updateState:(ReadmillReadState)newState delegate:(id <ReadmillReadUpdatingDelegate>)delegate;

/*!
 @param isPrivate The new privacy setting.
 @param delegate The delegate object to be informed of success or failure. 
 @brief   Update the privacy of this read. 
 */
-(void)updateIsPrivate:(BOOL)isPrivate delegate:(id <ReadmillReadUpdatingDelegate>)delegate;

/*!
 @param newRemark The new closing remark.
 @param delegate The delegate object to be informed of success or failure. 
 @brief   Update the closing remark of this read. 
 
 The closing remark is typically asked for when a user finishes reading a book.
 */
-(void)updateClosingRemark:(NSString *)newRemark delegate:(id <ReadmillReadUpdatingDelegate>)delegate;

/*!
 @param newState The new read state
 @param delegate The delegate object to be informed of success or failure. 
 @brief   Update the read state of this read. 
 */
-(void)updateWithState:(ReadmillReadState)newState isPrivate:(BOOL)readIsPrivate closingRemark:(NSString *)newRemark delegate:(id <ReadmillReadUpdatingDelegate>)delegate;

#pragma mark -
#pragma mark Sessions

/*!
 @result The created read session.
 @brief   Create a new reading session for this read. 
 */
-(ReadmillReadSession *)createReadSession;

/*!
 @param sessionId The existing session identifier to use. 
 @result The created read session.
 @brief   Create a reading session for the existing session identifier. 
 */
-(ReadmillReadSession *)createReadSessionWithExistingSessionId:(NSString *)sessionId;

#pragma mark -
#pragma mark Properties

/*!
 @property  dateAbandoned
 @brief The date the user abandoned this book, if any.
 */
@property (readonly, copy) NSDate *dateAbandoned;

/*!
 @property  dateCreated
 @brief The date this read object was created, typically the date the user first interacted with the book.
 */
@property (readonly, copy) NSDate *dateCreated;

/*!
 @property  dateFinished
 @brief The date the user finished reading this book, if any.
 */
@property (readonly, copy) NSDate *dateFinished;

/*!
 @property  dateModified
 @brief The last change date of this read.
 */
@property (readonly, copy) NSDate *dateModified;

/*!
 @property  dateStarted
 @brief The date the user started reading this book.
 */
@property (readonly, copy) NSDate *dateStarted;

/*!
 @property  estimatedTimeLeft
 @brief The estimated time left for a read.
 */
@property (readonly, copy) NSNumber *estimatedTimeLeft;

/*!
 @property  timeSpent
 @brief The time spent on a read.
 */
@property (readonly, copy) NSNumber *timeSpent;

/*!
 @property  closingRemark
 @brief The closing remark for this read, if any. Typically asked for and set when 
 the user is finished reading a book.
 */
@property (readonly, copy) NSString *closingRemark;

/*!
 @property  isPrivate
 @brief The current privacy setting of this read.
 */
@property (readonly) BOOL isPrivate;

/*!
 @property  state
 @brief The current state of the read.
 */
@property (readonly) ReadmillReadState state;

/*!
 @property  bookId
 @brief The Readmill id of the book this read is for.
 */
@property (readonly) ReadmillBookId bookId;

/*!
 @property  userId
 @brief The id of the Readmill user this read is for.
 */
@property (readonly) ReadmillUserId userId;

/*!
 @property  readId
 @brief The id of this read in Readmill.
 */
@property (readonly) ReadmillReadId readId;

/*!
 @property  progress
 @brief The progress of this read in Readmill.
 */
@property (readonly) ReadmillReadProgress progress;

/*!
 @property  apiWrapper
 @brief The ReadmillAPIWrapper object this read uses.
 */
@property (readonly, retain) ReadmillAPIWrapper *apiWrapper;



@end
