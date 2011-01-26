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

/*!
 @enum ReadmillReadState
 @brief   States for a user's interest in a book.
 @constant   ReadStateInteresting The user has marked the book as interesting.
 @constant   ReadStateReading The user has started reading the book.
 @constant   ReadStateFinished The user has finished reading the book.
 @constant   ReadStateAbandoned The user has abandoned the book and will not finish it.
 */
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

#pragma mark API Keys - Book

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

#pragma mark API Keys - User

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

#pragma mark API Keys - Read

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

#pragma mark -

/*!
 @class ReadmillAPIWrapper
 @brief    Class for interacting with the Readmill API.
 
 The ReadmillAPIWrapper class provides methods to interact directly with the Readmill API.
 The ReadmillUser/ReadmillBook/etc classes are normally more appropriate to use in an eBook
 reader type of application. 
 */

@interface ReadmillAPIWrapper : NSObject {
@private
    
    NSString *accessToken;
    NSString *refreshToken;
    NSString *authorizedRedirectURL;
    NSDate *accessTokenExpiryDate;
    NSString *apiEndPoint;
}

#pragma mark Initialization and Serialization 

/*!
 @result The created ReamillAPIWrapper object.
 @brief   Create a Readmill API object with the default endpoint URL (the live server).
 
 This method will create a Readmill API object with the default endpoint URL (the live
 server). This is the designated initialiser. 
 */
-(id)init;

/*!
 @result The created ReamillAPIWrapper object.
 @brief   Create a Readmill API object with the staging endpoint URL.
 
 This method will create a Readmill API object with the staging endpoint URL.
 This is typically only used when testing the API. 
 */
-(id)initWithStagingEndPoint;

/*!
 @param plist The saved credentials. 
 @result The created ReamillAPIWrapper object.
 @brief   Create a Readmill API object with the saved authentication details.
 
 This method will create a Readmill API object with the given authentication details
 as obtained through -propertyListRepresentation in a previous session.
 
 IMPORTANT: The saved details will IMMEDIATELY become invalid for use in the future. 
 Best practice would be to remove them from NSUserDefaults (or wherever they same from)
 as soon as you start using the Readmill API, as creating a Readmill API object with invalid 
 credentials will break the authentication and starting the authentication process (sending the 
 user to the Readmill site) will be required.
 */
-(id)initWithPropertyListRepresentation:(NSDictionary *)plist;

/*!
 @result A set of saved credentials appropriate for storing in NSUserDefaults.
 @brief   Obtain a set of saved credentials appropriate for storing in NSUserDefaults.
 
The object returned here is appropriate for saving in a property list, NSUserDefaults, or 
 elsewhere, and you can create a new Readmill API object by passing this to 
 -initWithPropertyListRepresentation:.
 
 This value is key-value observing compliant. 
 
 IMPORTANT: These details will change over the course of time. It's very important that you 
 always save the most up-to-date credentials if you plan on using them later, as older 
 credentials become invalid as soon as they're replaced by new ones.
 
 Best practice is to save these to NSUserDefaults every time they change using key-value
 observing, or save them when the application is about to quit.
 
 */
-(NSDictionary *)propertyListRepresentation;

#pragma mark -
#pragma mark Properties

/*!
 @property  accessToken
 @brief The current access token. The TTL of this is typically an hour.  
 */
@property (readonly, copy) NSString *accessToken;

/*!
 @property  refreshToken
 @brief The current refresh token. This is used to fetch a new access token when the existing one has expired.  
 */
@property (readonly, copy) NSString *refreshToken;

/*!
 @property  accessTokenExpiryDate
 @brief The date the current access token will expire. This can be nil, especially if there's no valid access token.  
 */
@property (readonly, copy) NSDate *accessTokenExpiryDate;

/*!
 @property  authorizedRedirectURL
 @brief The redirect URL used to obtain the current access token. This is required for security reasons.  
 */
@property (readonly, copy) NSString *authorizedRedirectURL;

#pragma mark -
#pragma mark Authentication

/*!
 @param authCode The authorizationCode provided by Readmill. 
 @param redirectURLString The original redirect URL, without any of the additional parameters 
 @param error An (optional) error pointer that will contain an NSError object if an error occurs. 
 @result YES if the current access token is valid and current, or if a new one was fetched successfully.
 @brief   Refresh the current access token if it's invalid or expired.
 
 IMPORTANT: All of the other methods in the ReadmillAPIWrapper object will call this automatically if 
 needed. There's normally no need to call this yourself except for debugging purposes. 
 */
-(void)authorizeWithAuthorizationCode:(NSString *)authCode fromRedirectURL:(NSString *)redirectURLString error:(NSError **)error;

/*!
 @param error An (optional) error pointer that will contain an NSError object if an error occurs. 
 @result YES if the current access token is valid and current, or if a new one was fetched successfully.
 @brief   Refresh the current access token if it's invalid or expired.
 
IMPORTANT: All of the other methods in the ReadmillAPIWrapper object will call this automatically if 
 needed. There's normally no need to call this yourself except for debugging purposes. 
 */
-(BOOL)ensureAccessTokenIsCurrent:(NSError **)error;

/*!
 @param redirect The URL Readmill should return to once authorization succeeds. 
 @result An NSURL pointing to the Readmill authorization page with the appropriate parameters.  
 @brief   Obtain an authorization URL containing the parameters to have Readmill redirect a 
 successful authorization back to the given URL.
 */
-(NSURL *)clientAuthorizationURLWithRedirectURLString:(NSString *)redirect;

/*!
 @param bookId The Readmill id of the book to link to. 
 @result An NSURL pointing to the Readmill book link page with the appropriate parameters.  
 @brief   Obtain a book link URL containing the parameters to have Readmill present a UI to the user 
 for linking the book to their Readmill account.
 */
-(NSURL *)connectBookUIURLForBookWithId:(ReadmillBookId)bookId;

/*!
 @param readId The Readmill id of the read to edit. 
 @result An NSURL pointing to the Readmill read edit page with the appropriate parameters.  
 @brief   Obtain a read edit URL containing the parameters to have Readmill present a UI to the user 
 for editing their read of this book in their Readmill account.
 */
-(NSURL *)editReadUIURLForBookWithId:(ReadmillReadId)readId;

#pragma mark -
#pragma mark Books

/*!
 @param error An (optional) error pointer that will contain an NSError object if an error occurs. 
 @result An NSArray containing all of the books in the Readmill system as NSDictionary objects. See the API Keys - Book section of this header for keys. 
 @brief   Get a list of the books in the Readmill system. 
 
 IMPORTANT: This list may be enormous. Avoid if you possibly can!
 */
-(NSArray *)allBooks:(NSError **)error;

/*!
 @param searchString A title to search for. Only full matches will be returned (i.e., searching for "the" will only return a book called "the", not one called "the killer").
 @param error An (optional) error pointer that will contain an NSError object if an error occurs. 
 @result An NSArray containing the matching books in the Readmill system as NSDictionary objects. See the API Keys - Book section of this header for keys. 
 @brief   Get a list of the books with the given title in the Readmill system. 
 */
-(NSArray *)booksMatchingTitle:(NSString *)searchString error:(NSError **)error;

/*!
 @param isbn An ISBN to search for. Only full matches will be returned (i.e., searching for "123" will only return a book with the ISBN "123", not one with "123456").
 @param error An (optional) error pointer that will contain an NSError object if an error occurs. 
 @result An NSArray containing the matching books in the Readmill system as NSDictionary objects. See the API Keys - Book section of this header for keys. 
 @brief   Get a list of the books with the given ISBN in the Readmill system. 
 */
-(NSArray *)booksMatchingISBN:(NSString *)isbn error:(NSError **)error;

/*!
 @param bookTitle The new book's title.
 @param bookAuthor The new book's author.
 @param bookIsbn The new book's ISBN.
 @param error An (optional) error pointer that will contain an NSError object if an error occurs. 
 @result The created book in the Readmill system as an NSDictionary object. See the API Keys - Book section of this header for keys. 
 @brief   Create a book with the given title, author and ISBN in the Readmill system. 
 
 IMPORTANT: This will add a book to Readmill even if it already exists. Please search for a book before creating a new one, or use the 
 -findOrCreateBookWithISBN:title:author:delegate: convenience method in the ReadmillUser object, which does this for you. 
 */
-(NSDictionary *)addBookWithTitle:(NSString* )bookTitle author:(NSString *)bookAuthor isbn:(NSString *)bookIsbn error:(NSError **)error;

#pragma mark -
#pragma mark Reads

/*!
 @param bookId The id of the book to create a read for.
 @param readState The initial read state.
 @param isPrivate The intial read privacy.
 @param error An (optional) error pointer that will contain an NSError object if an error occurs. 
 @result The created read in the Readmill system as an NSDictionary object. See the API Keys - Read section of this header for keys. 
 @brief   Create a read for the current user for the given book Id. 
 
 IMPORTANT: This will add a read to Readmill even if it already exists. Please search for a read before creating a new one, or use the 
 -findOrCreateReadForBook:delegate: convenience method in the ReadmillUser object, which does this for you. 
 */
-(NSDictionary *)createReadWithBookId:(ReadmillBookId)bookId state:(ReadmillReadState)readState private:(BOOL)isPrivate error:(NSError **)error;

/*!
 @param readId The id of the read to update.
 @param readState The new read state.
 @param isPrivate The new read privacy.
 @param error An (optional) error pointer that will contain an NSError object if an error occurs. 
 @brief   Update a read with the given Id with a new state, privacy and closing remark. 
 */
-(void)updateReadWithId:(ReadmillReadId)readId withState:(ReadmillReadState)readState private:(BOOL)isPrivate closingRemark:(NSString *)remark error:(NSError **)error;

/*!
 @param userId The user Id of the user you'd like reads for.
 @param error An (optional) error pointer that will contain an NSError object if an error occurs. 
 @result A list of reads in the Readmill system as NSDictionary objects. See the API Keys - Read section of this header for keys. 
 @brief   Get a list of reads for a given user Id. 
 */
-(NSArray *)publicReadsForUserWithId:(ReadmillUserId)userId error:(NSError **)error;

/*!
 @param userName The user name of the user you'd like reads for.
 @param error An (optional) error pointer that will contain an NSError object if an error occurs. 
 @result A list of reads in the Readmill system as NSDictionary objects. See the API Keys - Read section of this header for keys. 
 @brief   Get a list of reads for a given user name. 
 */
-(NSArray *)publicReadsForUserWithName:(NSString *)userName error:(NSError **)error;

/*!
 @param readId The Id of the read you'd like to get details for.
 @param userId The user Id of the user the requested read belongs to.
 @param error An (optional) error pointer that will contain an NSError object if an error occurs. 
 @result A specific read in the Readmill system as an NSDictionary object. See the API Keys - Read section of this header for keys. 
 @brief   Get a specific read by its id and user id. 
 */
-(NSDictionary *)readWithId:(ReadmillReadId)readId forUserWithId:(ReadmillUserId)userId error:(NSError **)error;

/*!
 @param readId The Id of the read you'd like to get details for.
 @param userName The user name of the user the requested read belongs to.
 @param error An (optional) error pointer that will contain an NSError object if an error occurs. 
 @result A specific read in the Readmill system as an NSDictionary object. See the API Keys - Read section of this header for keys. 
 @brief   Get a specific read by its id and user name. 
 */
-(NSDictionary *)readWithId:(ReadmillReadId)readId forUserWithName:(NSString *)userName error:(NSError **)error;

#pragma mark -
#pragma mark Pings
  
/*!
 @param readId The id of the read you'd like to ping.
 @param progress The current progress through the book as an integer percentage.
 @param sessionId A session id. The specific value of this is not important, but it should persist through a user's "session" of reading a book. 
 @param duration The forward-pointing duration of the ping. Aim to ping again after this duration has elapsed if the user is still reading. 
 @param occurrenceTime The time of the ping. Pass nil for "now". 
 @param error An (optional) error pointer that will contain an NSError object if an error occurs. 
 @brief  Ping Readmill, informing it of the fact the user was reading a certain part of the book at the given time.
 */
-(void)pingReadWithId:(ReadmillReadId)readId withProgress:(ReadmillReadProgress)progress sessionIdentifier:(NSString *)sessionId duration:(ReadmillPingDuration)duration occurrenceTime:(NSDate *)occurrenceTime error:(NSError **)error;

#pragma mark -
#pragma mark Users

/*!
 @param userId The id of the user you'd like to get details for.
 @param error An (optional) error pointer that will contain an NSError object if an error occurs. 
 @result A specific user in the Readmill system as an NSDictionary object. See the API Keys - User section of this header for keys. 
 @brief   Get a specific user by their id. 
 */
-(NSDictionary *)userWithId:(ReadmillUserId)userId error:(NSError **)error;

/*!
 @param userName The username of the user you'd like to get details for.
 @param error An (optional) error pointer that will contain an NSError object if an error occurs. 
 @result A specific user in the Readmill system as an NSDictionary object. See the API Keys - User section of this header for keys. 
 @brief   Get a specific user by their Readmill username. 
 */
-(NSDictionary *)userWithName:(NSString *)userName error:(NSError **)error;

/*!
 @param error An (optional) error pointer that will contain an NSError object if an error occurs. 
 @result The current authenticated user as an NSDictionary object. See the API Keys - User section of this header for keys. 
 @brief   Get the currently logged in user. 
 */
-(NSDictionary *)currentUser:(NSError **)error;

@end
