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

@class ReadmillUser;

@interface ReadmillComment : NSObject

/*!
 @property commentId
 @brief The Readmill id of the current comment.
 */
@property(readonly) ReadmillCommentId commentId;

/*!
 @property content
 @brief Content of the current highlight.
 */
@property(readonly, copy) NSString *content;

/*!
 @property postedAt
 @brief Post date of the current highlight.
 */
@property(readonly, copy) NSDate *postedAt;

/*!
 @property readingId
 @brief The Readmil reading id for the current comment.
 */
@property(readonly) ReadmillReadingId readingId;

/*!
 @property highlightId
 @brief The Readmil highlight id for the current comment.
 */
@property(readonly) ReadmillHighlightId highlightId;

/*!
 @property user
 @brief The ReadmillUser object for the user who made the current highlight.
 */
@property(readonly, retain) ReadmillUser *user;

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
 @brief   Create a new comment for the given API comment dictionary and wrapper.
 */
- (id)initWithAPIDictionary:(NSDictionary *)apiDict apiWrapper:(ReadmillAPIWrapper *)wrapper;

/*!
 @param apiDict An API user dictionary.
 @brief  Update this comment with an NSDictionary from a ReadmillAPIWrapper object.
 */
- (void)updateWithAPIDictionary:(NSDictionary *)apiDict;

@end
