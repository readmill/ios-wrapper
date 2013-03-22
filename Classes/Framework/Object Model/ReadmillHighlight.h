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

@interface ReadmillHighlight : NSObject

#pragma mark -
#pragma mark Properties

/*!
 @property position
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
@property (readonly, retain) ReadmillAPIWrapper *apiWrapper;

#pragma mark -
#pragma mark Initialization and Serialization

/*!
 @param apiDict An API user dictionary.
 @param wrapper The ReadmillAPIWrapper to be used by the user.
 @result The created highlight.
 @brief   Create a new highlight for the given API highlight dictionary and wrapper.
 */
- (id)initWithAPIDictionary:(NSDictionary *)apiDict apiWrapper:(ReadmillAPIWrapper *)wrapper;

/*!
 @param apiDict An API user dictionary.
 @brief  Update this highlight with an NSDictionary from a ReadmillAPIWrapper object.
 */
- (void)updateWithAPIDictionary:(NSDictionary *)apiDict;

@end
