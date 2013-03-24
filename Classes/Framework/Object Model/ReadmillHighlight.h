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

@class ReadmillHighlight;

@protocol ReadmillCommentsFindingDelegate <NSObject>

/*!
 @param user The user object that was performing the request.
 @param highlights An array of retrieved `ReadmillComment` objects.
 @param fromDate Beginning date range.
 @param toDate Ending date range.
 @brief Delegate method informing the target that Readmill found comments.
 */
- (void)readmillHighlight:(ReadmillHighlight *)highlight didFindComments:(NSArray *)comments fromDate:(NSDate *)fromDate toDate:(NSDate *)toDate;

/*!
 @param user The user object that was performing the request.
 @param fromDate Beginning date range.
 @param toDate Ending date range.
 @param error An NSError object describing the error that occurred.
 @brief Delegate method informing the target that an error occurred attempting to search for comments.
 */
- (void)readmillHighlight:(ReadmillHighlight *)highlight failedToFindCommentsFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate withError:(NSError *)error;

@end

@interface ReadmillHighlight : NSObject

#pragma mark -
#pragma mark Properties

/*!
 @property highlightId
 @brief The Readmill id of the current highlight.
 */
@property(readonly) ReadmillHighlightId highlightId;

/*!
 @property position
 @brief Position of the current highlight.
 */
@property(readonly) float position;

/*!
 @property content
 @brief Content of the current highlight.
 */
@property(readonly, copy) NSString *content;

/*!
 @property highlightedAt
 @brief Creation date of the current highlight.
 */
@property(readonly, copy) NSDate *highlightedAt;

/*!
 @property permalinkURI
 @brief The permalink URI the current highlight.
 */
@property(readonly, copy) NSURL *permalinkURI;

/*!
 @property userId
 @brief The Readmill id for the user who made the current highlight.
 */
@property(readonly) ReadmillUserId userId;

/*!
 @property commentsCount
 @brief Number of comments for the current highlight.
 */
@property(readonly) NSUInteger commentsCount;

/*!
 @property likesCount
 @brief Number of likes for the current highlight.
 */
@property(readonly) NSUInteger likesCount;

/*!
 @property readingId
 @brief The Readmil reading id for the current highlight.
 */
@property(readonly) ReadmillReadingId readingId;

/*!
 @property  apiWrapper
 @brief The ReadmillAPIWrapper object this user uses.
 */
@property(readonly, retain) ReadmillAPIWrapper *apiWrapper;

#pragma mark -
#pragma mark Initialization and Serialization

/*!
 @param apiDict An API user dictionary.
 @param wrapper The ReadmillAPIWrapper to be used by the user.
 @result The created comment.
 @brief Create a new comment for the given API highlight dictionary and wrapper.
 */
- (id)initWithAPIDictionary:(NSDictionary *)apiDict
                 apiWrapper:(ReadmillAPIWrapper *)wrapper;

/*!
 @param apiDict An API user dictionary.
 @brief Update this comment with an NSDictionary from a ReadmillAPIWrapper object.
 */
- (void)updateWithAPIDictionary:(NSDictionary *)apiDict;

#pragma mark -
#pragma mark Comments

- (void)findCommentsWithCount:(NSUInteger)count
                     fromDate:(NSDate *)fromDate
                       toDate:(NSDate *)toDate
                     delegate:(id <ReadmillCommentsFindingDelegate>)delegate;

@end
