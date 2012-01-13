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
#import "ReadmillAPIConfiguration.h"

typedef void (^ReadmillAPICompletionHandler)(id result, NSError *error);

typedef NSUInteger ReadmillBookId;
typedef NSUInteger ReadmillReadingId;
typedef NSUInteger ReadmillHighlightId;
typedef NSUInteger ReadmillUserId;
typedef float ReadmillReadingProgress; // float, 0-1 (%)
typedef NSUInteger ReadmillPingDuration; // Integer, seconds
typedef double CLLocationDegrees;


/*!
 @enum ReadmillReadingState
 @brief   States for a user's interest in a book.
 @constant   ReadingStateInteresting The user has marked the book as interesting.
 @constant   ReadingStateReading The user has started reading the book.
 @constant   ReadingStateFinished The user has finished reading the book.
 @constant   ReadingStateAbandoned The user has abandoned the book and will not finish it.
 */
typedef enum {
    
    ReadingStateInteresting = 1,
    ReadingStateReading = 2,
    ReadingStateFinished = 3,
    ReadingStateAbandoned = 4
    
} ReadmillReadingState;

// General 

static NSString * const kReadmillDomain = @"com.readmill";
static NSString * const kReadmillAPIClientIdKey = @"client_id";
static NSString * const kReadmillAPIClientSecretKey = @"client_secret";
static NSString * const kReadmillAPIAccessTokenKey = @"access_token";

#pragma mark API Keys - Book

static NSString * const kReadmillAPIBookKey = @"book";
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

static NSString * const kReadmillAPIUserKey = @"user";
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
static NSString * const kReadmillAPIUserAuthenticationToken = @"authentication_token";

#pragma mark API Keys - Reading

static NSString * const kReadmillAPIReadingKey = @"reading";
static NSString * const kReadmillAPIReadingDateAbandonedKey = @"abandoned_at";
static NSString * const kReadmillAPIReadingDateCreatedKey = @"created_at";
static NSString * const kReadmillAPIReadingDateFinishedKey = @"finished_at";
static NSString * const kReadmillAPIReadingDateModifiedKey = @"touched_at";
static NSString * const kReadmillAPIReadingDateStartedKey = @"started_at";
static NSString * const kReadmillAPIReadingClosingRemarkKey = @"closing_remark";
static NSString * const kReadmillAPIReadingPrivateKey = @"private";
static NSString * const kReadmillAPIReadingStateKey = @"state";
static NSString * const kReadmillAPIReadingBookKey = @"book";
static NSString * const kReadmillAPIReadingIdKey = @"id";
static NSString * const kReadmillAPIReadingEstimatedTimeLeftKey = @"estimated_time_left";;
static NSString * const kReadmillAPIReadingDurationKey = @"duration";
static NSString * const kReadmillAPIReadingProgressKey = @"progress";
static NSString * const kReadmillAPIReadingPermalinkURLKey = @"permalink_url";
static NSString * const kReadmillAPIReadingURIKey = @"uri";
static NSString * const kReadmillAPIReadingCommentsKey = @"comments";
static NSString * const kReadmillAPIReadingPeriodsKey = @"periods";
static NSString * const kReadmillAPIReadingLocationsKey = @"locations";
static NSString * const kReadmillAPIReadingHighlightsKey = @"highlights";
static NSString * const kReadmillAPIReadingHighlightsCountKey = @"highlights_count";

#pragma mark API Keys - Highlights

static NSString * const kReadmillAPIHighlightPreKey = @"pre";
static NSString * const kReadmillAPIHighlightPostKey = @"post";
static NSString * const kReadmillAPIHighlightContentKey = @"content";
static NSString * const kReadmillAPIHighlightIdKey = @"id";
static NSString * const kReadmillAPIHighlightPositionKey = @"position";
static NSString * const kReadmillAPIHighlightPostToKey = @"post_to";
static NSString * const kReadmillAPIHighlightCommentKey = @"comment";
static NSString * const kReadmillAPIHighlightCommentsCountKey = @"comments_count";
static NSString * const kReadmillAPIHighlightPermalinkURLKey = @"permalink_url";
static NSString * const kReadmillAPIHighlightReadingIdKey = @"reading_id";
static NSString * const kReadmillAPIHighlightHighlightedAtKey = @"highlighted_at";

#pragma mark API Keys - Comments

static NSString * const kReadmillAPICommentIdKey = @"id";
static NSString * const kReadmillAPICommentPostedAtKey = @"posted_at";
static NSString * const kReadmillAPICommentContentKey = @"content";

#pragma mark API Keys - Pings

static NSString * const kReadmillAPIPingProgressKey = @"progress";
static NSString * const kReadmillAPIPingDurationKey = @"duration";
static NSString * const kReadmillAPIPingIdentifierKey = @"identifier";
static NSString * const kReadmillAPIPingOccurredAtKey = @"occurred_at";
static NSString * const kReadmillAPIPingLatitudeKey = @"lat";
static NSString * const kReadmillAPIPingLongitudeKey = @"lng";

#pragma mark API Filtering & Ordering

static NSString * const kReadmillAPIFilterKey = @"filter";
static NSString * const kReadmillAPIFilterByFollowings = @"followings";
static NSString * const kReadmillAPIOrderKey = @"order";
static NSString * const kReadmillAPIOrderByPopular = @"popular";

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
    NSString *authorizedRedirectURL;
    NSDate *accessTokenExpiryDate;
    NSOperationQueue *queue;
    ReadmillAPIConfiguration *apiConfiguration;
    
    
    // This will be removed soon, in favor of non-expiring tokens
    NSString *refreshToken DEPRECATED_ATTRIBUTE;
}

#pragma mark Initialization and Serialization 

/*!
 @result The created ReadmillAPIWrapper object.
 @brief   Create a Readmill API object with the specified API configuration.
 */
- (id)initWithAPIConfiguration:(ReadmillAPIConfiguration *)configuration;

/*!
 @param plist The saved credentials. 
 @result The created ReadmillAPIWrapper object.
 @brief   Create a Readmill API object with the saved authentication details.
 
 This method will create a Readmill API object with the given authentication details
 as obtained through -propertyListRepresentation in a previous session.
 
 IMPORTANT: The saved details will IMMEDIATELY become invalid for use in the future. 
 Best practice would be to remove them from NSUserDefaults (or wherever they came from)
 as soon as you start using the Readmill API, as creating a Readmill API object with invalid 
 credentials will break the authentication and starting the authentication process (sending the 
 user to the Readmill site) will be required.
 */
- (id)initWithPropertyListRepresentation:(NSDictionary *)plist;

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
- (NSDictionary *)propertyListRepresentation;

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
@property (readonly, copy) NSString *refreshToken DEPRECATED_ATTRIBUTE;

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

/*!
 @property  apiConfiguration
 @brief An object representing the configuration for the API.
 */
@property (nonatomic, readonly, retain) ReadmillAPIConfiguration *apiConfiguration;

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
- (void)authorizeWithAuthorizationCode:(NSString *)authCode fromRedirectURL:(NSString *)redirectURLString completionHandler:(ReadmillAPICompletionHandler)completion;

/*!
 @param error An (optional) error pointer that will contain an NSError object if an error occurs. 
 @result YES if the current access token is valid and current, or if a new one was fetched successfully.
 @brief   Refresh the current access token if it's invalid or expired.
 
IMPORTANT: All of the other methods in the ReadmillAPIWrapper object will call this automatically if 
 needed. There's normally no need to call this yourself except for debugging purposes. 
 */
//- (BOOL)ensureAccessTokenIsCurrent:(NSError **)error;

/*!
 @param redirect The URL Readmill should return to once authorization succeeds. 
 @result An NSURL pointing to the Readmill authorization page with the appropriate parameters.  
 @brief   Obtain an authorization URL containing the parameters to have Readmill redirect a 
 successful authorization back to the given URL.
 */
- (NSURL *)clientAuthorizationURLWithRedirectURLString:(NSString *)redirect;


#pragma mark -
#pragma mark UI Presenter 

/*!
 @param ISBN The ISBN number of the book to link to. 
 @param title The title of the book to link to. 
 @param author The author of the book to link to, or a comma-separated list of authors.
 @result An NSURL pointing to the Readmill book link page with the appropriate parameters.  
 @brief   Obtain a book link URL containing the parameters to have Readmill present a UI to the user 
 for linking the book to their Readmill account.
 */
- (NSURL *)URLForConnectingBookWithISBN:(NSString *)ISBN title:(NSString *)title author:(NSString *)author;

/*!
 @param readingId The ReadmillReadingId of the reading to view. 
 @result An NSURL pointing to the Readmill reading.  
 @brief   Obtain a reading link URL containing the parameters to have Readmill present a UI to the user 
 for editing their reading of this book in their Readmill account.
 */
- (NSURL *)URLForViewingReadingWithId:(ReadmillReadingId)readingId;


#pragma mark -
#pragma mark Books

/*!
 @param searchString The string to use when searching for a book.
 @param completionHandler An (optional) block that will return the result (id) and an NSError pointer.
 @result An NSArray containing the matching books in the Readmill system as NSDictionary objects. See the API Keys - Book section of this header for keys. 
 @brief   Get a list of books matching the search string in the Readmill system. 
 */
- (void)booksFromSearch:(NSString *)searchString completionHandler:(ReadmillAPICompletionHandler)completionHandler;

/*!
 @param searchString A title to search for. Only full matches will be returned (i.e., searching for "the" will only return a book called "the", not one called "the killer").
 @param completionHandler An (optional) block that will return the result (id) and an NSError pointer.
 @result A Readmill book as an NSDictionary object. See the API Keys - Book section of this header for keys. 
 @brief   Get a specific book in the Readmill system. 
 */
- (void)bookMatchingTitle:(NSString *)title completionHandler:(ReadmillAPICompletionHandler)completionHandler;

/*!
 @param isbn An ISBN to search for. Only full matches will be returned (i.e., searching for "123" will only return a book with the ISBN "123", not one with "123456").
 @param completionHandler An (optional) block that will return the result (id) and an error pointer.
 @result A Readmill book as an NSDictionary object. See the API Keys - Book section of this header for keys. 
 @brief   Get a specific book in the Readmill system. 
 */
- (void)bookMatchingISBN:(NSString *)isbn completionHandler:(ReadmillAPICompletionHandler)completionHandler;

/*!
 @param bookId The Readmill id of the book to retrieve.
 @param completionHandler An (optional) block that will return the result (id) and an error pointer.
 @result A Readmill book as an NSDictionary object. See the API Keys - Book section of this header for keys. 
 @brief   Get a specific book in the Readmill system. 
 */
- (void)bookWithId:(ReadmillBookId)bookId completionHandler:(ReadmillAPICompletionHandler)completionHandler;

/*!
 @param bookTitle The new book's title.
 @param bookAuthor The new book's author, or comma-separated list of authors.
 @param bookIsbn The new book's ISBN.
 @param completionHandler An (optional) block that will return the result (id) and an NSError pointer.
 @result The created book in the Readmill system as an NSDictionary object. See the API Keys - Book section of this header for keys. 
 @brief   Create a book with the given title, author and ISBN in the Readmill system. 
 
 IMPORTANT: This will add a book to Readmill even if it already exists. Please search for a book before creating a new one, or use the 
 -findOrCreateBookWithISBN:title:author:delegate: convenience method in the ReadmillUser object, which does this for you. 
 */
- (void)addBookWithTitle:(NSString* )bookTitle
                  author:(NSString *)bookAuthor
                    isbn:(NSString *)bookIsbn 
       completionHandler:(ReadmillAPICompletionHandler)completionHandler;

#pragma mark -
#pragma mark Readings

/*!
 @param bookId The id of the book to create a reading for.
 @param readingState The initial reading state.
 @param isPrivate The intial reading privacy.
 @param completionHandler An (optional) block that will return the result (id) and an error pointer.
 @result The created reading in the Readmill system as an NSDictionary object. See the API Keys - Read section of this header for keys. 
 @brief   Create a reading for the current user for the given book Id. 
 
 IMPORTANT: This will add a reading to Readmill even if it already exists. Please search for a reading before creating a new one, or use the 
 -findOrCreateReadingForBook:delegate: convenience method in the ReadmillUser object, which does this for you. 
 */
- (void)createReadingWithBookId:(ReadmillBookId)bookId 
                          state:(ReadmillReadingState)readingState 
                      isPrivate:(BOOL)isPrivate
              completionHandler:(ReadmillAPICompletionHandler)completionHandler;

/*!
 @param readingId The id of the reading to update.
 @param readingState The new reading state.
 @param isPrivate The new reading privacy.
 @param completionHandler An (optional) block that will return the result (id) and an error pointer.
 @brief   Update a reading with the given Id with a new state, privacy and closing remark. 
*/
- (void)updateReadingWithId:(ReadmillReadingId)readingId
                  withState:(ReadmillReadingState)readingState
                  isPrivate:(BOOL)isPrivate
              closingRemark:(NSString *)remark
          completionHandler:(ReadmillAPICompletionHandler)completionHandler;

/*!
 @param userId The user Id of the user you'd like readings for.
 @param completionHandler An (optional) block that will return the result (id) and an error pointer.
 @result A list of readings in the Readmill system as NSDictionary objects. See the API Keys - Read section of this header for keys. 
 @brief   Get a list of readings for a given user Id. 
*/
- (void)publicReadingsForUserWithId:(ReadmillUserId)userId 
                  completionHandler:(ReadmillAPICompletionHandler)completionHandler;
 
/*!
 @param userId The user Id of the user you'd like readings for.
 @param completionHandler An (optional) block that will return the result (id) and an error pointer.
 @result A list of readings in the Readmill system as NSDictionary objects. See the API Keys - Read section of this header for keys. 
 @brief   Get a list of readings for a given user Id. 
 */
- (void)readingsForUserWithId:(ReadmillUserId)userId 
            completionHandler:(ReadmillAPICompletionHandler)completionHandler;


/*!
 @param readingId The Id of the reading you'd like to get details for.
 @param completionHandler An (optional) block that will return the result (id) and an error pointer.
 @result A specific reading in the Readmill system as an NSDictionary object. See the API Keys - Read section of this header for keys. 
 @brief   Get a specific reading by its id.
 */

- (void)readingWithId:(ReadmillReadingId)readingId 
    completionHandler:(ReadmillAPICompletionHandler)completionHandler;

/*!
 @param url The URL as a string of the reading you'd like to get details for.
 @param completionHandler An (optional) block that will return the result (id) and an error pointer.
 @brief   Get a specific reading by its URL.
 */
- (void)readingWithURLString:(NSString *)urlString 
           completionHandler:(ReadmillAPICompletionHandler)completionHandler;

/*!
 @param bookId The bookId for which to get readings
 @param completionHandler An (optional) block that will return the result (id) and an error pointer.
 @brief   Get all readings for the book with the specifiedId
 */
- (void)readingsForBookWithId:(ReadmillBookId)bookId 
            completionHandler:(ReadmillAPICompletionHandler)completionHandler;

/*!
 @param bookId The bookId for which to get readings
 @param completionHandler An (optional) block that will return the result (id) and an error pointer.
 @brief   Get the readings for the book with the specified bookId, filtered by followed people.
 */
- (void)readingsFilteredByFriendsForBookWithId:(ReadmillBookId)bookId 
                             completionHandler:(ReadmillAPICompletionHandler)completionHandler;

/*!
 @param bookId The bookId for which to get readings
 @param completionHandler An (optional) block that will return the result (id) and an error pointer.
 @brief   Get the most popular readings for the book with the specified bookId.
 */
- (void)readingsOrderedByPopularForBookWithId:(ReadmillBookId)bookId 
                            completionHandler:(ReadmillAPICompletionHandler)completionHandler;

#pragma mark -
#pragma mark Pings
  
/*!
 @param readingId The id of the reading you'd like to ping.
 @param progress The current progress through the book as a float percentage.
 @param sessionId A session id. The specific value of this is not important, but it should persist through a user's "session" of reading a book. 
 @param duration The forward-pointing duration of the ping. Aim to ping again after this duration has elapsed if the user is still reading. 
 @param occurrenceTime The time of the ping. Pass nil for "now". 
 @param completionHandler An (optional) block that will return the result (id) and an error pointer.
 @brief  Ping Readmill, informing it of the fact the user was reading a certain part of the book at the given time.
 */
- (void)pingReadingWithId:(ReadmillReadingId)readingId 
             withProgress:(ReadmillReadingProgress)progress
        sessionIdentifier:(NSString *)sessionId
                 duration:(ReadmillPingDuration)duration
           occurrenceTime:(NSDate *)occurrenceTime
        completionHandler:(ReadmillAPICompletionHandler)completionHandler;

/*!
 @param readingId The id of the reading you'd like to ping.
 @param progress The current progress through the book as a float percentage.
 @param sessionId A session id. The specific value of this is not important, but it should persist through a user's "session" of reading a book. 
 @param duration The forward-pointing duration of the ping. Aim to ping again after this duration has elapsed if the user is still reading. 
 @param occurrenceTime An NSDate object representing the date the resource was created, pass nil for "now". 
 @param latitude The latitude value
 @param longitude The longitude value
 @param completionHandler An (optional) block that will return the result (id) and an error pointer.
 @brief  Ping Readmill, informing it of the fact the user was reading a certain part of the book at the given time. 
 */
- (void)pingReadingWithId:(ReadmillReadingId)readingId 
             withProgress:(ReadmillReadingProgress)progress
        sessionIdentifier:(NSString *)sessionId
                 duration:(ReadmillPingDuration)duration
           occurrenceTime:(NSDate *)occurrenceTime 
                 latitude:(CLLocationDegrees)latitude
                longitude:(CLLocationDegrees)longitude
        completionHandler:(ReadmillAPICompletionHandler)completionHandler;

#pragma mark -
#pragma mark Highlights

/*!
 @param readingId The id of the reading you want to create a highlight in.
 @param highlightedText The highlighted text
 @param pre (optional) The text before the highlightText (needed in case the highlightedText is very short)
 @param post (optional) The text after the highlightedText (needed in case the highlightedText is very short)
 @param position The approximate position of the highlighted text in the book as float percentage.
 @param highlightedAt An NSDate object representing the date the resource was created, pass nil for "now". 
 @param comment (optional) A comment on the highlight
 @param connections (optional) An array consisting of connection IDs (NSString) to post to (unique for user 
                               /me/connections/). Use nil for default connections.
 @param completionHandler A block that will return the result (id) and an error pointer.
 @brief  Send a highlighted text snippet to Readmill.
 */
- (void)createHighlightForReadingWithId:(ReadmillReadingId)readingId 
                        highlightedText:(NSString *)highlightedText
                                    pre:(NSString *)preOrNil
                                   post:(NSString *)postOrNil
                    approximatePosition:(ReadmillReadingProgress)position
                          highlightedAt:(NSDate *)highlightedAtOrNil
                                comment:(NSString *)commentOrNil
                            connections:(NSArray *)connectionsOrNil
                      completionHandler:(ReadmillAPICompletionHandler)completionHandler;

/*!
 @param readingId The id of the reading.
 @param completionHandler A block that will return the result (id) and an error pointer.
 @brief  Get all highlights for a particular reading in Readmill.
 */
- (void)highlightsForReadingWithId:(ReadmillReadingId)readingId completionHandler:(ReadmillAPICompletionHandler)completionHandler;

/*!
 @param highlightId The id of the highlight.
 @param completionHandler A block that will return the result (id) and an error pointer.
 @brief  Deletes the particular highlight in Readmill.
 */
- (void)deleteHighlightWithId:(NSUInteger)highlightId completionHandler:(ReadmillAPICompletionHandler)completionHandler;

#pragma mark Comments

/*!
 @param highlightId The id of the highlight you want to create a comment for.
 @param comment The comment text to post.
 @param commentedAt An NSDate object representing the date the resource was created, pass nil for "now"
 @param completionHandler A block that will return the result and an error pointer.
 @brief  Add a comment to a particular highlight in Readmill.
 */
- (void)createCommentForHighlightWithId:(ReadmillHighlightId)highlightId comment:(NSString *)comment commentedAt:(NSDate *)date completionHandler:(ReadmillAPICompletionHandler)completionHandler;

/*!
 @param highlightId The id of the highlight.
 @param completionHandler A block that will return the result (id) and an error pointer.
 @brief  Get all comments for a particular highlight in Readmill.
 */
- (void)commentsForHighlightWithId:(ReadmillHighlightId)highlightId completionHandler:(ReadmillAPICompletionHandler)completionHandler;

#pragma mark -
#pragma mark Service connections (Facebook / Twitter etc)

/*!
 @param error An (optional) error pointer that will contain an NSError object if an error occurs. 
 @brief  Get the service connections (Facebook/Twitter etc) for the current user in Readmill.
 */
- (void)connectionsForCurrentUserWithCompletionHandler:(ReadmillAPICompletionHandler)completionHandler;

#pragma mark -
#pragma mark Users

/*!
 @param userId The id of the user you'd like to get details for.
 @param completionHandler A block that will return the result and an error pointer.
 @brief   Get a specific user by their id. 
 */
- (void)userWithId:(ReadmillUserId)userId
 completionHandler:(ReadmillAPICompletionHandler)completionHandler;

/*!
 @param error An (optional) error pointer that will contain an NSError object if an error occurs. 
 @result The current authenticated user as an NSDictionary object. See the API Keys - User section of this header for keys. 
 @brief   Get the currently logged in user. 
 */
- (NSDictionary *)currentUser:(NSError **)error;

/*!
 @param completionHandler A block that will return the result (id) and an NSError object if an error occurs. 
 @result The current authenticated user as an NSDictionary object. See the API Keys - User section of this header for keys. 
 @brief   Get the currently logged in user. 
 */
- (void)currentUserWithCompletionHandler:(ReadmillAPICompletionHandler)completionHandler;

#pragma mark -
#pragma mark Unprepared requests
/*!
 @param url The URL to which the request will be sent
 @param completionHandler A block that will return any result (id) and an NSError object if an error occurs.
 @brief Send a request to the specified URL.
 */
- (void)sendRequestToURL:(NSURL *)url completionHandler:(ReadmillAPICompletionHandler)completionHandler;

#pragma mark - 
#pragma mark - Cancel operations
/*!
 @brief Cancels all queued requests to the server.
 */
- (void)cancelAllOperations;


@end
