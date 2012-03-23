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
#import "ReadmillReadingSession.h"

@class ReadmillReading;
@class ReadmillUser;

@protocol ReadmillReadingUpdatingDelegate <NSObject>

/*!
 @param reading The reading object that updated its metadata with the Readmill service successfully. 
 @brief   Delegate method informing the target that the given metadata update succeeded. 
 */
-(void)readmillReadingDidUpdateMetadataSuccessfully:(ReadmillReading *)reading;

/*!
 @param reading The reading object that failed to update its metadata with the Readmill service successfully.
 @param error The error that occurred.
 @brief   Delegate method informing the target that the given metadata update failed. 
 */
-(void)readmillReading:(ReadmillReading *)reading didFailToUpdateMetadataWithError:(NSError *)error;

@end

@interface ReadmillReading : NSObject {
@private
    
    NSDate *dateAbandoned;
    NSDate *dateCreated;
    NSDate *dateFinished;
    NSDate *dateModified;
    NSDate *dateStarted;
    
    NSTimeInterval timeSpent, estimatedTimeLeft;
    
    NSString *closingRemark;
    
    BOOL isPrivate;
    
    ReadmillReadingState state;
    
    ReadmillBookId bookId;
    ReadmillUserId userId;
    ReadmillReadingId readingId;
    
    ReadmillAPIWrapper *apiWrapper;
    
    ReadmillReadingProgress progress;
    
    NSUInteger highlightCount;
    
    // URLs
    NSURL *permalinkURL;
    NSURL *uri;
    NSURL *commentsURI;
    NSURL *periodsURI;
    NSURL *locationsURI;
    NSURL *highlightsURI;
    
    ReadmillUser *user;
}

/*!
 @param apiDict An API reading dictionary.
 @param wrapper The ReadmillAPIWrapper object to be used.
 @result The created reading.
 @brief   Create a reading with the given API dictionary and ReadmillAPIWrapper object. 
 
 Typically, you would get a ReadmillReading object using the convenience methods in ReadmillUser. 
 
 This is the designated initializer of this class.
 */
-(id)initWithAPIDictionary:(NSDictionary *)apiDict apiWrapper:(ReadmillAPIWrapper *)wrapper;

/*!
 @param apiDict An API reading dictionary. 
 @brief  Update this reading with an NSDictionary from a ReadmillAPIWrapper object.
 
 Typically, there's no need to call this method.
 */
-(void)updateWithAPIDictionary:(NSDictionary *)apiDict;

#pragma mark -
#pragma mark Updating

/*!
 @param newState The new reading state.
 @param delegate The delegate object to be informed of success or failure. 
 @brief   Update the reading state of this reading. 
 */
-(void)updateState:(ReadmillReadingState)newState delegate:(id <ReadmillReadingUpdatingDelegate>)delegate;

/*!
 @param isPrivate The new privacy setting.
 @param delegate The delegate object to be informed of success or failure. 
 @brief   Update the privacy of this reading. 
 */
-(void)updateIsPrivate:(BOOL)isPrivate delegate:(id <ReadmillReadingUpdatingDelegate>)delegate;

/*!
 @param newRemark The new closing remark.
 @param delegate The delegate object to be informed of success or failure. 
 @brief   Update the closing remark of this reading. 
 
 The closing remark is typically asked for when a user finishes reading a book.
 */
-(void)updateClosingRemark:(NSString *)newRemark delegate:(id <ReadmillReadingUpdatingDelegate>)delegate;

/*!
 @param newState The new reading state
 @param isPrivate The new privacy setting.
 @param newRemark The new closing remark.
 @param delegate The delegate object to be informed of success or failure. 
 @brief   Update the reading state of this reading. 
 */
-(void)updateWithState:(ReadmillReadingState)newState isPrivate:(BOOL)readingIsPrivate closingRemark:(NSString *)newRemark delegate:(id <ReadmillReadingUpdatingDelegate>)delegate;

#pragma mark -
#pragma mark Sessions

/*!
 @result The created reading session.
 @brief   Create a new reading session for this reading. 
 */
-(ReadmillReadingSession *)createReadingSession;

#pragma mark -
#pragma mark Properties

/*!
 @property  dateAbandoned
 @brief The date the user abandoned this book, if any.
 */
@property (readonly, copy) NSDate *dateAbandoned;

/*!
 @property  dateCreated
 @brief The date this reading object was created, typically the date the user first interacted with the book.
 */
@property (readonly, copy) NSDate *dateCreated;

/*!
 @property  dateFinished
 @brief The date the user finished reading this book, if any.
 */
@property (readonly, copy) NSDate *dateFinished;

/*!
 @property  dateModified
 @brief The last change date of this reading.
 */
@property (readonly, copy) NSDate *dateModified;

/*!
 @property  dateStarted
 @brief The date the user started reading this book.
 */
@property (readonly, copy) NSDate *dateStarted;

/*!
 @property  estimatedTimeLeft
 @brief The estimated time left for a reading, in seconds.
 */
@property (readonly) NSTimeInterval estimatedTimeLeft;

/*!
 @property  timeSpent
 @brief The time spent on a reading, in seconds.
 */
@property (readonly) NSTimeInterval timeSpent;

/*!
 @property  closingRemark
 @brief The closing remark for this reading, if any. Typically asked for and set when 
 the user is finished reading a book.
 */
@property (readonly, copy) NSString *closingRemark;

/*!
 @property  isPrivate
 @brief The current privacy setting of this reading.
 */
@property (readonly) BOOL isPrivate;

/*!
 @property  isRecommended
 @brief The current recommended of this reading.
 */
@property (readonly) BOOL isRecommended;

/*!
 @property  state
 @brief The current state of the reading.
 */
@property (readonly) ReadmillReadingState state;

/*!
 @property  bookId
 @brief The Readmill id of the book this reading is for.
 */
@property (readonly) ReadmillBookId bookId;

/*!
 @property  userId
 @brief The id of the Readmill user this reading is for.
 */
@property (readonly) ReadmillUserId userId;

/*!
 @property  readingId
 @brief The id of this reading in Readmill.
 */
@property (readonly) ReadmillReadingId readingId;

/*!
 @property  progress
 @brief The progress of this reading in Readmill.
 */
@property (readonly) ReadmillReadingProgress progress;

/*!
 @property  user
 @brief The ReadmillUser of this reading.
 */
@property (readonly, retain) ReadmillUser *user;

/*!
 @property  apiWrapper
 @brief The ReadmillAPIWrapper object this reading uses.
 */
@property (readonly, retain) ReadmillAPIWrapper *apiWrapper;

/*!
 @property  permalinkURL
 @brief The permalink of the reading.
 */
@property (readonly, copy) NSURL *permalinkURL;

/*!
 @property  uri
 @brief The URI of the reading.
 */
@property (readonly, copy) NSURL *uri;

/*!
 @property  commentsURI
 @brief The URI to the comments of the readingURI.
 */
@property (readonly, copy) NSURL *commentsURI;

/*!
 @property  periodsURI
 @brief The URI to the periods of the reading.
 */
@property (readonly, copy) NSURL *periodsURI;

/*!
 @property  locationsURI
 @brief The URI to the locations of the reading.
 */
@property (readonly, copy) NSURL *locationsURI;

/*!
 @property  highlightsURI
 @brief The URI to the highlights of the reading.
 */
@property (readonly, copy) NSURL *highlightsURI;

/*!
 @property  highlightsCount
 @brief The number of highlights for the reading.
 */
@property (readonly, nonatomic) NSUInteger highlightCount;

@end
