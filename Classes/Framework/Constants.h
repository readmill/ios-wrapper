//
//  Constants.h
//  Readmill Framework
//
//  Created by Work on 10/01/2011.
//  Copyright 2011 KennettNet Software Limited. All rights reserved.
//

#import <Cocoa/Cocoa.h>


static NSString * const kLiveAPIEndPoint = @"http://api.readmill.com/";
static NSString * const kStagingAPIEndPoint = @"http://api.stage-readmill.com/";

// OAuth

static NSString * const kLiveAuthorizationUri = @"http://readmill.com/";
static NSString * const kStagingAuthorizationUri = @"http://stage-readmill.com/";

static NSString * const kClientSecret = @"750452e5fc0c20531e94f44215475094";
static NSString * const kClientId = @"99dce8a929298cb95e534e86861db6de";

// API Keys - Book

static NSString * const kReadmillAPIBookAuthorKey = @"author";
static NSString * const kReadmillAPIBookLanguageKey = @"language";
static NSString * const kReadmillAPIBookSummaryKey = @"story";
static NSString * const kReadmillAPIBookTitleKey = @"title";
static NSString * const kReadmillAPIBookISBNKey = @"isbn";

static NSString * const kReadmillAPIBookCoverImageURLKey = @"cover_url";
static NSString * const kReadmillAPIBookMetaDataURLKey = @"metadata_uri";
static NSString * const kReadmillAPIBookPermalinkURLKey = @"permalink_url";

static NSString * const kReadmillAPIBookIdKey = @"id";
static NSString * const kReadmillAPIBookRootEditionIdKey = @"root_edition";
static NSString * const kReadmillAPIBookDatePublishedKey = @"published_at";

// API Keys - User

static NSString * const kReadmillAPIUserAvatarURLKey = @"avatar_url";
static NSString * const kReadmillAPIUserAbandonedBooksKey = @"books_abandoned";
static NSString * const kReadmillAPIUserFinishedBooksKey = @"books_finished";
static NSString * const kReadmillAPIUserInterestingBooksKey = @"books_interesting";
static NSString * const kReadmillAPIUserOpenBooksKey = @"books_open";
static NSString * const kReadmillAPIUserCityKey = @"city";
static NSString * const kReadmillAPIUserCountryKey = @"country";
static NSString * const kReadmillAPIUserDescriptionKey = @"description";
static NSString * const kReadmillAPIUserFirstNameKey = @"firstname";
static NSString * const kReadmillAPIUserFollowerCountKey = @"followers";
static NSString * const kReadmillAPIUserFollowingCountKey = @"followings";
static NSString * const kReadmillAPIUserFullNameKey = @"fullname";
static NSString * const kReadmillAPIUserIdKey = @"id";
static NSString * const kReadmillAPIUserLastNameKey = @"lastname";
static NSString * const kReadmillAPIUserPermalinkURLKey = @"permalink_url";
static NSString * const kReadmillAPIUserReadmillUserNameKey = @"username";
static NSString * const kReadmillAPIUserWebsiteKey = @"website";

// API Keys - Read

static NSString * const kReadmillAPIReadDateAbandonedKey = @"abandoned_at";
static NSString * const kReadmillAPIReadDateCreatedKey = @"created_at";
static NSString * const kReadmillAPIReadDateFinishedKey = @"finished_at";
static NSString * const kReadmillAPIReadDateModifiedKey = @"touched_at";
static NSString * const kReadmillAPIReadDateStarted = @"started_at";
static NSString * const kReadmillAPIReadClosingRemarkKey = @"closing_remark";
static NSString * const kReadmillAPIReadIsPrivateKey = @"private";
static NSString * const kReadmillAPIReadStateKey = @"state";
static NSString * const kReadmillAPIReadBookKey = @"book";
static NSString * const kReadmillAPIReadUserKey = @"user";
static NSString * const kReadmillAPIReadIdKey = @"id";
