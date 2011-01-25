//
//  ReadmillAPI.h
//  Readmill Framework
//
//  Created by Readmill on 10/01/2011.
//  Copyright 2011 Readmill. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NSUInteger ReadmillBookId;
typedef NSUInteger ReadmillReadId;
typedef NSUInteger ReadmillUserId;
typedef NSUInteger ReadmillReadProgress; // Integer, 1-100 (%)
typedef NSUInteger ReadmillPingDuration; // Integer, seconds

typedef enum {
    
    ReadStateInteresting = 1,
    ReadStateReading = 2,
    ReadStateFinished = 3,
    ReadStateAbandoned = 4
    
} ReadmillReadState;

// General 

static NSString * const kReadmillErrorDomain = @"com.readmill";

// URLs

static NSString * const kLiveAPIEndPoint = @"http://api.readmill.com/";
static NSString * const kStagingAPIEndPoint = @"http://api.stage-readmill.com/";
static NSString * const kLiveAuthorizationUri = @"http://readmill.com/";
static NSString * const kStagingAuthorizationUri = @"http://stage-readmill.com/";

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

@interface ReadmillAPIWrapper : NSObject {
@private
    
    NSString *accessToken;
    NSString *refreshToken;
    NSString *authorizedRedirectURL;
    NSDate *accessTokenExpiryDate;
    NSString *apiEndPoint;
}


-(id)init;
-(id)initWithStagingEndPoint;
-(id)initWithPropertyListRepresentation:(NSDictionary *)plist;
-(NSDictionary *)propertyListRepresentation;

@property (readonly, copy) NSString *accessToken;
@property (readonly, copy) NSString *refreshToken;
@property (readonly, copy) NSDate *accessTokenExpiryDate;
@property (readonly, copy) NSString *authorizedRedirectURL;

// oAuth

-(void)authorizeWithAuthorizationCode:(NSString *)authCode fromRedirectURL:(NSString *)redirectURLString error:(NSError **)error;
-(BOOL)ensureAccessTokenIsCurrent:(NSError **)error;
-(NSURL *)clientAuthorizationURLWithRedirectURLString:(NSString *)redirect;

// Books

-(NSArray *)allBooks:(NSError **)error;
-(NSArray *)booksMatchingTitle:(NSString *)searchString error:(NSError **)error;
-(NSArray *)booksMatchingISBN:(NSString *)isbn error:(NSError **)error;
-(NSDictionary *)addBookWithTitle:(NSString* )bookTitle author:(NSString *)bookAuthor isbn:(NSString *)bookIsbn error:(NSError **)error;

// Reads

-(NSDictionary *)createReadWithBookId:(ReadmillBookId)bookId state:(ReadmillReadState)readState private:(BOOL)isPrivate error:(NSError **)error;
-(void)updateReadWithId:(ReadmillReadId)readId withState:(ReadmillReadState)readState private:(BOOL)isPrivate closingRemark:(NSString *)remark error:(NSError **)error;
-(NSArray *)publicReadsForUserWithId:(ReadmillUserId)userId error:(NSError **)error;
-(NSArray *)publicReadsForUserWithName:(NSString *)userName error:(NSError **)error;
-(NSDictionary *)readWithId:(ReadmillReadId)readId forUserWithId:(ReadmillUserId)userId error:(NSError **)error;
-(NSDictionary *)readWithId:(ReadmillReadId)readId forUserWithName:(NSString *)userName error:(NSError **)error;

//Pings     

-(void)pingReadWithId:(ReadmillReadId)readId withProgress:(ReadmillReadProgress)progress sessionIdentifier:(NSString *)sessionId duration:(ReadmillPingDuration)duration occurrenceTime:(NSDate *)occurrenceTime error:(NSError **)error;

// Users

-(NSDictionary *)userWithId:(ReadmillUserId)userId error:(NSError **)error;
-(NSDictionary *)userWithName:(NSString *)userName error:(NSError **)error;
-(NSDictionary *)currentUser:(NSError **)error;

@end
