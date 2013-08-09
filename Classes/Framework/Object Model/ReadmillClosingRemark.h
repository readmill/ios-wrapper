//
//  ReadmillClosingRemark.h
//  ReadmillAPI
//
//  Created by Tomaz Nedeljko on 8/8/13.
//  Copyright (c) 2013 Readmill Network LTD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ReadmillAPIWrapper.h"

@class ReadmillUser;

@interface ReadmillClosingRemark : NSObject

/*!
 @property closingRemarkId
 @brief The Readmill id of the current closing remark.
 */
@property(readonly) ReadmillClosingRemarkId closingRemarkId;

/*!
 @property content
 @brief Content of the current closing remark.
 */
@property(readonly, copy) NSString *content;

/*!
 @property createdAt
 @brief Post date of the current closing remark.
 */
@property(readonly, copy) NSDate *createdAt;

/*!
 @property likesCount
 @brief Number of likes for the current closing remark.
 */
@property(readonly) NSUInteger likesCount;

/*!
 @property commentsCount
 @brief Number of comments for the current closing remark.
 */
@property(readonly) NSUInteger commentsCount;

/*!
 @property recommended
 @brief Determines whether the user recommended book with current closing remark.
 */
@property(readonly) BOOL recommended;

/*!
 @property readingId
 @brief The Readmil reading id for the current closing remark.
 */
@property(readonly) ReadmillReadingId readingId;

/*!
 @property user
 @brief The ReadmillUser object for the user who made the current closing remark.
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
 @result The created closing remark.
 @brief   Create a new closing remark for the given API comment dictionary and wrapper.
 */
- (id)initWithAPIDictionary:(NSDictionary *)apiDict apiWrapper:(ReadmillAPIWrapper *)wrapper;

/*!
 @param apiDict An API user dictionary.
 @brief  Update this closing remark with an NSDictionary from a ReadmillAPIWrapper object.
 */
- (void)updateWithAPIDictionary:(NSDictionary *)apiDict;

@end
