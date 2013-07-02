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
#import "ReadmillRequestOperation.h"

#define kTimeoutInterval 30.0

typedef void (^ReadmillAPICompletionHandler)(id result, NSError *error);

typedef NSUInteger ReadmillBookId;
typedef NSUInteger ReadmillReadingId;
typedef NSUInteger ReadmillHighlightId;
typedef NSUInteger ReadmillCommentId;
typedef NSUInteger ReadmillUserId;
typedef NSUInteger ReadmillLibraryItemId;
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

/*!
 @enum ReadmillPriceSegment
 @brief   Price segment for a book.
 @constant   ReadmillPriceSegmentUnknown The price segment is unknown.
 @constant   ReadmillPriceSegmentFree Book is free.
 */
typedef enum {
    
    ReadmillPriceSegmentUnknown = 1,
    ReadmillPriceSegmentFree = 2
    
} ReadmillPriceSegment;

// State strings
static NSString * const ReadmillReadingStateInterestingKey = @"interesting";
static NSString * const ReadmillReadingStateReadingKey = @"reading";
static NSString * const ReadmillReadingStateFinishedKey = @"finished";
static NSString * const ReadmillReadingStateAbandonedKey = @"abandoned";

// General 

static NSString * const kReadmillDomain = @"com.readmill";
static NSString * const kReadmillAPIClientIdKey = @"client_id";
static NSString * const kReadmillAPIClientSecretKey = @"client_secret";
static NSString * const kReadmillAPIAccessTokenKey = @"access_token";

static NSString * const kReadmillAPIItemsKey = @"items";

#pragma mark API Keys - Book

static NSString * const kReadmillAPIBookKey = @"book";
static NSString * const kReadmillAPIBookAuthorKey = @"author";
static NSString * const kReadmillAPIBookLanguageKey = @"language";
static NSString * const kReadmillAPIBookSummaryKey = @"story";
static NSString * const kReadmillAPIBookTitleKey = @"title";
static NSString * const kReadmillAPIBookIdentifierKey = @"identifier";
static NSString * const kReadmillAPIBookCoverImageURLKey = @"cover_url";
static NSString * const kReadmillAPIBookCoverMetadataKey = @"cover_metadata";
static NSString * const kReadmillAPIBookCoverMetadataOriginalWidthKey = @"original_width";
static NSString * const kReadmillAPIBookCoverMetadataOriginalHeightKey = @"original_height";
static NSString * const kReadmillAPIBookMetaDataURLKey = @"metadata_uri";
static NSString * const kReadmillAPIBookPermalinkURLKey = @"permalink_url";
static NSString * const kReadmillAPIBookIdKey = @"id";
static NSString * const kReadmillAPIBookRootEditionIdKey = @"root_edition";
static NSString * const kReadmillAPIBookDatePublishedKey = @"published_at";
static NSString * const kReadmillAPIBookFeaturedKey = @"featured";
static NSString * const kReadmillAPIBookReadingsCountKey = @"readings_count";
static NSString * const kReadmillAPIBookActiveAndFinishedReadingsCountKey = @"active_and_finished_readings_count";
static NSString * const kReadmillAPIBookRecommendedReadingsCountKey = @"recommended_readings_count";
static NSString * const kReadmillAPIBookAverageDurationKey = @"average_duration";
static NSString * const kReadmillAPIBookAssetsKey = @"assets";

static NSString * const kReadmillAPIBookFilterPriceSegmentsKey = @"price_segments";
static NSString * const kReadmillAPIBookFilterPriceSegmentsFree = @"free";

static NSString * const kReadmillAPIBookOrderKey = @"order";
static NSString * const kReadmillAPIBookOrderByCreatedAt = @"created_at";
static NSString * const kReadmillAPIBookOrderByHotnessScore = @"hotness_score";

static NSString * const kReadmillAPIBookCountKey = @"count";
static NSString * const kReadmillAPIBookCoverSizeKey = @"size";

static NSString * const kReadmillAPIBookPriceSegmentKey = @"price_segment";
static NSString * const kReadmillAPIBookPriceSegmentFree = @"free";

#pragma mark API Keys - User

static NSString * const kReadmillAPIUserKey = @"user";
static NSString * const kReadmillAPIUserAvatarURLKey = @"avatar_url";
static NSString * const kReadmillAPIUserBooksAbandonedCountKey = @"books_abandoned_count";
static NSString * const kReadmillAPIUserBooksFinishedCountKey = @"books_finished_count";
static NSString * const kReadmillAPIUserBooksInterestingCountKey = @"books_interesting_count";
static NSString * const kReadmillAPIUserBooksReadingCountKey = @"books_reading_count";
static NSString * const kReadmillAPIUserCityKey = @"city";
static NSString * const kReadmillAPIUserCountryKey = @"country";
static NSString * const kReadmillAPIUserDescriptionKey = @"description";
static NSString * const kReadmillAPIUserFirstNameKey = @"firstname";
static NSString * const kReadmillAPIUserFollowerCountKey = @"followers_count";
static NSString * const kReadmillAPIUserFollowingCountKey = @"followings_count";
static NSString * const kReadmillAPIUserFullNameKey = @"fullname";
static NSString * const kReadmillAPIUserIdKey = @"id";
static NSString * const kReadmillAPIUserLastNameKey = @"lastname";
static NSString * const kReadmillAPIUserPermalinkURLKey = @"permalink_url";
static NSString * const kReadmillAPIUserReadmillUserNameKey = @"username";
static NSString * const kReadmillAPIUserReadmillEmailKey = @"email";
static NSString * const kReadmillAPIUserWebsiteKey = @"website";
static NSString * const kReadmillAPIUserAuthenticationToken = @"authentication_token";

static NSString * const kReadmillAPIUserAvatarSizeKey = @"size";
static NSString * const kReadmillAPIUserAvatarSizeSmall = @"small"; // 30x30
static NSString * const kReadmillAPIUserAvatarSizeMedium = @"medium"; // 50x50
static NSString * const kReadmillAPIUserAvatarSizeMediumLarge = @"medium-large"; // 100x100
static NSString * const kReadmillAPIUserAvatarSizeLarge = @"large"; // 280x280

#pragma mark API Keys - Images

static NSString * const kReadmillAPIImageWidthKey = @"width";
static NSString * const kReadmillAPIImageHeightKey = @"height";
static NSString * const kReadmillAPIImageOperationKey = @"operation";
static NSString * const kReadmillAPIImageOperationCrop = @"crop";
static NSString * const kReadmillAPIImageOperationShrinkWidth = @"shrink-w";
static NSString * const kReadmillAPIImageFormatKey = @"format";
static NSString * const kReadmillAPIImageFormatPNG = @"png";
static NSString * const kReadmillAPIImageFormatJPEG = @"jpg";


#pragma mark API Keys - Following

static NSString * const kReadmillAPIFollowingCountKey = @"count";
static NSString * const kReadmillAPIFollowingFromDateKey = @"from";
static NSString * const kReadmillAPIFollowingToDateKey = @"to";
static NSString * const kReadmillAPIFollowingFilterKey = @"filter";

static NSString * const kReadmillAPIFollowingOrderKey = @"order";
static NSString * const kReadmillAPIFollowingOrderByCreatedAt = @"created_at";


#pragma mark API Keys - Reading

static NSString * const kReadmillAPIReadingKey = @"reading";
static NSString * const kReadmillAPIReadingDateEndedKey = @"ended_at";
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
static NSString * const kReadmillAPIReadingRecommendedKey = @"recommended";
static NSString * const kReadmillAPIReadingPostToKey = @"post_to";
static NSString * const kReadmillAPIReadingPositionKey = @"position";
static NSString * const kReadmillAPIReadingPositionUpdatedAtKey = @"position_updated_at";
static NSString * const kReadmillAPIReadingCountKey = @"count";
static NSString * const kReadmillAPIReadingFromDateKey = @"from";
static NSString * const kReadmillAPIReadingToDateKey = @"to";
static NSString * const kReadmillAPIReadingHighlightsCountFromKey = @"highlights_count[from]";
static NSString * const kReadmillAPIReadingHighlightsCountToKey = @"highlights_count[to]";

static NSString * const kReadmillAPIReadingOrderKey = @"order";
static NSString * const kReadmillAPIReadingOrderTouchedAt = @"touched_at";
static NSString * const kReadmillAPIReadingOrderCreatedAt = @"created_at";
static NSString * const kReadmillAPIReadingOrderPopular = @"popular";
static NSString * const kReadmillAPIReadingOrderFriendsFirst = @"friends_first";

static NSString * const kReadmillAPIReadingFilterKey = @"filter";
static NSString * const kReadmillAPIReadingFilterFollowings = @"followings";

static NSString * const kReadmillAPIReadingStatesKey = @"states";
static NSString * const kReadmillAPIReadingStateInteresting = @"interesting";
static NSString * const kReadmillAPIReadingStateReading = @"reading";
static NSString * const kReadmillAPIReadingStateFinished = @"finished";
static NSString * const kReadmillAPIReadingStateAbandoned = @"abandoned";


#pragma mark API Keys - Highlights

static NSString * const kReadmillAPIHighlightKey = @"highlight";
static NSString * const kReadmillAPIHighlightPreKey = @"pre";
static NSString * const kReadmillAPIHighlightMidKey = @"mid";
static NSString * const kReadmillAPIHighlightPostKey = @"post";
static NSString * const kReadmillAPIHighlightContentKey = @"content";
static NSString * const kReadmillAPIHighlightLocatorsKey = @"locators";
static NSString * const kReadmillAPIHighlightIdKey = @"id";
static NSString * const kReadmillAPIHighlightPositionKey = @"position";
static NSString * const kReadmillAPIHighlightPostToKey = @"post_to";
static NSString * const kReadmillAPIHighlightCommentKey = @"comment";
static NSString * const kReadmillAPIHighlightCommentsCountKey = @"comments_count";
static NSString * const kReadmillAPIHighlightLikesCountKey = @"likes_count";
static NSString * const kReadmillAPIHighlightPermalinkURLKey = @"permalink_url";
static NSString * const kReadmillAPIHighlightReadingIdKey = @"reading_id";
static NSString * const kReadmillAPIHighlightHighlightedAtKey = @"highlighted_at";

#pragma mark API Keys - Comments

static NSString * const kReadmillAPICommentKey = @"comment";
static NSString * const kReadmillAPICommentIdKey = @"id";
static NSString * const kReadmillAPICommentPostedAtKey = @"posted_at";
static NSString * const kReadmillAPICommentContentKey = @"content";
static NSString * const kReadmillAPICommentUserKey = @"user";

#pragma mark API Keys - Periods

static NSString * const kReadmillAPIPingKey = @"ping";
static NSString * const kReadmillAPIPingProgressKey = @"progress";
static NSString * const kReadmillAPIPingDurationKey = @"duration";
static NSString * const kReadmillAPIPingIdentifierKey = @"identifier";
static NSString * const kReadmillAPIPingOccurredAtKey = @"occurred_at";
static NSString * const kReadmillAPIPingLatitudeKey = @"lat";
static NSString * const kReadmillAPIPingLongitudeKey = @"lng";

#pragma mark Library

static NSString * const kReadmillAPILibraryLocalIdsKey = @"local_ids";

@class ReadmillRequestOperation;

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
    ReadmillAPIConfiguration *apiConfiguration;
}

@property (nonatomic, retain, readonly) NSOperationQueue *queue;

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
 @brief   Refresh the current access token if it's invalid or expired.
 
 IMPORTANT: All of the other methods in the ReadmillAPIWrapper object will call this automatically if 
 needed. There's normally no need to call this yourself except for debugging purposes. 
 */
- (void)authorizeWithAuthorizationCode:(NSString *)authCode
                       fromRedirectURL:(NSString *)redirectURLString
                     completionHandler:(ReadmillAPICompletionHandler)completion;

/*!
 @param parameters The finalized POST parameters.
 @param completionHandler An (optional) block to be executed on completion.
 @brief   Refresh the current access token if it's invalid or expired.
  */
- (void)authorizeWithParameters:(NSDictionary *)parameters
              completionHandler:(ReadmillAPICompletionHandler)completionHandler;


/*!
 @param redirect The URL Readmill should return to once authorization succeeds. 
 @result An NSURL pointing to the Readmill authorization page with the appropriate parameters.  
 @brief   Obtain an authorization URL containing the parameters to have Readmill redirect a 
 successful authorization back to the given URL.
 */
- (NSURL *)clientAuthorizationURLWithRedirectURLString:(NSString *)redirect;


#pragma mark -
#pragma mark Books

/*!
 @param identifier The identifier to search for. 
 @param title The title to search for.
 @param author The author to search for. 
 @param completionHandler An (optional) block that will return the result (id) and an error pointer.
 @result A Readmill book as an NSDictionary object. See the API Keys - Book section of this header for keys. 
 @brief   Get a specific book in the Readmill system. If identifier is included, a match against identifier is tried first. 
          If that fails, a match against title and author is attempted.
 */
- (ReadmillRequestOperation *)bookMatchingIdentifier:(NSString *)identifier
                                               title:(NSString *)title
                                              author:(NSString *)author
                                   completionHandler:(ReadmillAPICompletionHandler)completionHandler;
/*!
 @param bookId The Readmill id of the book to retrieve.
 @param completionHandler An (optional) block that will return the result (id) and an error pointer.
 @result A Readmill book as an NSDictionary object. See the API Keys - Book section of this header for keys. 
 @brief   Get a specific book in the Readmill system. 
 */
- (ReadmillRequestOperation *)bookWithId:(ReadmillBookId)bookId
                       completionHandler:(ReadmillAPICompletionHandler)completionHandler;

/*!
 @param bookTitle The new book's title.
 @param bookAuthor The new book's author, or comma-separated list of authors.
 @param bookIdentifier The new book's identifier.
 @param completionHandler An (optional) block that will return the result (id) and an NSError pointer.
 @result The created book in the Readmill system as an NSDictionary object. See the API Keys - Book section of this header for keys. 
 @brief   Create a book with the given title, author and identifier in the Readmill system.
*/
- (ReadmillRequestOperation *)findOrCreateBookWithTitle:(NSString *)bookTitle
                                                 author:(NSString *)bookAuthor
                                             identifier:(NSString *)bookIdentifier
                                      completionHandler:(ReadmillAPICompletionHandler)completionHandler;
/*!
@param parameters The parameters for the request.
@param completionHandler An (optional) block that will return the result (id) and an error pointer.
@return A `ReadmillRequestOperation` object associated with the action.
@brief   Find books given the argument passed to parameters.
*/
- (ReadmillRequestOperation *)booksWithParameters:(NSDictionary *)parameters
                                completionHandler:(ReadmillAPICompletionHandler)completionHandler;


/*!
 @param parameters The query to search for.
 @param parameters The parameters for the request.
 @param completionHandler An (optional) block that will return the result (id) and an error pointer.
 @return A `ReadmillRequestOperation` object associated with the action.
 @brief   Search books given the argument passed to parameters.
 */
- (ReadmillRequestOperation *)searchBooksUsingQuery:(NSString *)query
                                         parameters:(NSDictionary *)parameters
                                  completionHandler:(ReadmillAPICompletionHandler)completionHandler;


/*!
 @param bookId The id of the book you'd like to get the cover for.
 @param size Size of the cover you would like to retrieve.
 @result The URL that points to the cover of desired size for book with id.
 @brief Get the cover URL for a book with specified id and cover size.
 */
- (NSURL *)coverURLForBookWithId:(ReadmillBookId)bookId
                            size:(NSString *)size;

/*!
 @param bookId The id of the book you'd like to get the cover for.
 @param parameters The parameters for the request.
 @result The URL that points to the cover of desired size for book with id.
 @brief Get the cover URL for a book with specified id and parameters.
 */
- (NSURL *)coverURLForBookWithId:(ReadmillBookId)bookId
                      parameters:(NSDictionary *)parameters;

#pragma mark -
#pragma mark Readings

/*!
 @param userId The id of the user to find a reading for.
 @param bookId The id of the book.
 @param completionHandler An (optional) block that will return the result (id) and an error pointer.
 @brief   Find a reading for user matching the arguments.
 */
- (ReadmillRequestOperation *)readingForUserWithId:(ReadmillUserId)userId
                                matchingBookWithId:(ReadmillBookId)bookId
                                 completionHandler:(ReadmillAPICompletionHandler)completion;


/*!
 @param userId The id of the user to find a reading for.
 @param identifier The identifier of the book.
 @param title The title of the book.
 @param author The author of the book.
 @param completionHandler An (optional) block that will return the result (id) and an error pointer.
 @brief   Find a reading for user matching the arguments.
*/
- (ReadmillRequestOperation *)readingForUserWithId:(ReadmillUserId)userId
                                matchingIdentifier:(NSString *)identifier
                                             title:(NSString *)title
                                            author:(NSString *)author
                                 completionHandler:(ReadmillAPICompletionHandler)completion;

/*!
 @param bookId The id of the book to create a reading for.
 @param readingState The initial reading state if a new reading is created.
 @param isPrivate The intial reading privacy if a new reading is created.
 @param connections (optional) An array consisting of connections (dictionary) to post to. 
    Example: post_to : [{ id : 25 }, { email : martin@readmill.com }]
    IMPORTANT: Passing nil connections uses default connections.
 @param completionHandler An (optional) block that will return the result (id) and an error pointer.
 @result The created reading in the Readmill system as an NSDictionary object. See the API Keys - Read section of this header for keys. 
 @brief   Create a reading for the current user for the given book Id. 
 
 IMPORTANT: The state and privacy options may not match the passed arguments if a reading already existed.
 */
- (ReadmillRequestOperation *)findOrCreateReadingWithBookId:(ReadmillBookId)bookId 
                                                      state:(NSString *)readingState
                                                  isPrivate:(BOOL)isPrivate
                                                connections:(NSArray *)connections
                                          completionHandler:(ReadmillAPICompletionHandler)completionHandler;

/*!
 @param bookId The id of the book to create a reading for.
 @param readingState The initial reading state if a new reading is created.
 @param isPrivate The intial reading privacy if a new reading is created.
 @param completionHandler An (optional) block that will return the result (id) and an error pointer.
 @result The created reading in the Readmill system as an NSDictionary object. See the API Keys - Read section of this header for keys. 
 @brief   Create a reading for the current user for the given book Id. 
 
 IMPORTANT: The state and privacy options may not match the passed arguments if a reading already existed.
 */
- (ReadmillRequestOperation *)findOrCreateReadingWithBookId:(ReadmillBookId)bookId 
                                                      state:(NSString *)readingState
                                                  isPrivate:(BOOL)isPrivate
                                          completionHandler:(ReadmillAPICompletionHandler)completionHandler;

/*!
 @param readingId The id of the reading to update.
 @param toPrivate The new reading privacy.
 @param completionHandler An (optional) block that will return the result (id) and an error pointer.
 @return A `ReadmillRequestOperation` object associated with the action.
 @brief   Update a reading with the given Id with a new state, privacy and closing remark.
 */
- (ReadmillRequestOperation *)updateReadingWithId:(ReadmillReadingId)readingId
                                        toPrivate:(BOOL)toPrivate
                                completionHandler:(ReadmillAPICompletionHandler)completionHandler;

/*!
 @param readingId The id of the reading to update.
 @param readingState The new reading state.
 @param isPrivate The new reading privacy.
 @param closingRemark The new reading remark.
 @param completionHandler An (optional) block that will return the result (id) and an error pointer.
 @return A `ReadmillRequestOperation` object associated with the action.
 @brief   Update a reading with the given Id with a new state, privacy and closing remark. 
*/
- (ReadmillRequestOperation *)updateReadingWithId:(ReadmillReadingId)readingId
                                        withState:(NSString *)readingState
                                        isPrivate:(BOOL)isPrivate
                                    closingRemark:(NSString *)closingRemark
                                completionHandler:(ReadmillAPICompletionHandler)completionHandler;

/*!
 @param readingId The id of the reading to finish.
 @param closingRemark (optional) A closing remark.
 @param recommended (optional) Whether reading should be recommended or not.
 @param connections (optional) An array consisting of connections (dictionary) to post to. Example: post_to : [{ id : 25 }, { email : martin@readmill.com }]
    IMPORTANT: Passing nil connections uses default connections.
 @param completionHandler An (optional) block that will return the result (id) and an error pointer.
 @return A `ReadmillRequestOperation` object associated with the action.
 @brief   Finish a reading with the given Id with an optional closing remark and do/dont recommend.
 */
- (ReadmillRequestOperation *)finishReadingWithId:(ReadmillReadingId)readingId
                                    closingRemark:(NSString *)closingRemark
                                      recommended:(BOOL)recommended
                                      connections:(NSArray *)connections
                                completionHandler:(ReadmillAPICompletionHandler)completionHandler;

/*!
 @param readingId The id of the reading to abandon.
 @param closingRemark (optional) A closing remark.
 @param connections (optional) An array consisting of connections (dictionary) to post to. 
    Example: post_to : [{ id : 25 }, { email : martin@readmill.com }]
    IMPORTANT: Passing nil connections uses default connections.
 @param completionHandler An (optional) block that will return the result (id) and an error pointer.
 @return A `ReadmillRequestOperation` object associated with the action.
 @brief   Abandon a reading with the given Id with an optional closing remark.
 */
- (ReadmillRequestOperation *)abandonReadingWithId:(ReadmillReadingId)readingId
                                     closingRemark:(NSString *)closingRemark
                                       connections:(NSArray *)connections
                                 completionHandler:(ReadmillAPICompletionHandler)completionHandler;

/*!
 @param userId The user Id of the user you'd like readings for.
 @param completionHandler An (optional) block that will return the result (id) and an error pointer.
 @result A list of readings in the Readmill system as NSDictionary objects. See the API Keys - Read section of this header for keys. 
 @brief   Get a list of readings for a given user Id. 
*/
- (ReadmillRequestOperation *)publicReadingsForUserWithId:(ReadmillUserId)userId 
                                        completionHandler:(ReadmillAPICompletionHandler)completionHandler;
 
/*!
 @param userId The user Id of the user you'd like readings for.
 @param parameters Extra parameters to pass with the request.
 @param completionHandler An (optional) block that will return the result (id) and an error pointer.
 @result A list of readings in the Readmill system as NSDictionary objects. See the API Keys - Read section of this header for keys. 
 @brief   Get a list of readings for a given user Id. 
 */
- (ReadmillRequestOperation *)readingsForUserWithId:(ReadmillUserId)userId
                                         parameters:(NSDictionary *)parameters
                                  completionHandler:(ReadmillAPICompletionHandler)completionHandler;


/*!
 @param readingId The Id of the reading you'd like to get details for.
 @param completionHandler An (optional) block that will return the result (id) and an error pointer.
 @result A specific reading in the Readmill system as an NSDictionary object. See the API Keys - Read section of this header for keys. 
 @brief   Get a specific reading by its id.
 */

- (ReadmillRequestOperation *)readingWithId:(ReadmillReadingId)readingId 
                          completionHandler:(ReadmillAPICompletionHandler)completionHandler;

/*!
 @param bookId The bookId for which to get readings
 @param parameters Extra parameters to pass with the request.
 @param completionHandler An (optional) block that will return the result (id) and an error pointer.
 @brief Get all readings for the book with the specifiedId
 */
- (ReadmillRequestOperation *)readingsForBookWithId:(ReadmillBookId)bookId
                                         parameters:(NSDictionary *)parameters
                                  completionHandler:(ReadmillAPICompletionHandler)completionHandler;

/*!
 @param bookId The bookId for which to get readings
 @param completionHandler An (optional) block that will return the result (id) and an error pointer.
 @brief   Get all readings for the book with the specifiedId
 */
- (ReadmillRequestOperation *)readingsForBookWithId:(ReadmillBookId)bookId 
                                  completionHandler:(ReadmillAPICompletionHandler)completionHandler;

/*!
 @param bookId The bookId for which to get readings
 @param parameters An (optional) parameter dictionary.
 @param completionHandler An (optional) block that will return the result (id) and an error pointer.
 @brief   Get the readings for the book with the specified bookId, filtered by followed people.
 */
- (ReadmillRequestOperation *)readingsFilteredByFriendsForBookWithId:(ReadmillBookId)bookId
                                                          parameters:(NSDictionary *)parameters
                                                   completionHandler:(ReadmillAPICompletionHandler)completionHandler;

/*!
 @param bookId The bookId for which to get readings
 @param parameters An (optional) parameter dictionary.
 @param completionHandler An (optional) block that will return the result (id) and an error pointer.
 @brief   Get the most popular readings for the book with the specified bookId.
 */
- (ReadmillRequestOperation *)readingsOrderedByPopularForBookWithId:(ReadmillBookId)bookId
                                                         parameters:(NSDictionary *)parameters
                                                  completionHandler:(ReadmillAPICompletionHandler)completionHandler;

/*!
 @param bookId The bookId for which to get readings
 @param parameters An (optional) parameter dictionary.
 @param completionHandler An (optional) block that will return the result (id) and an error pointer.
 @brief Get the recent readings for the book with the specified bookId ordered by friends first.
 */
- (ReadmillRequestOperation *)readingsOrderedByFriendsFirstForBookWithId:(ReadmillBookId)bookId
                                                              parameters:(NSDictionary *)parameters
                                                       completionHandler:(ReadmillAPICompletionHandler)completionHandler;

/*!
 @param readingId The readingId for which to get periods
 @param completionHandler An (optional) block that will return the result (id) and an error pointer.
 @brief   Get the periods for the reading with the specified readingId
 */
- (ReadmillRequestOperation *)periodsForReadingWithId:(ReadmillReadingId)readingId
                                    completionHandler:(ReadmillAPICompletionHandler)completionHandler;


/*!
 @param readingId The readingId for which to get position
 @param completionHandler An (optional) block that will return the result (id) and an error pointer.
 @brief   Get the position of the reading with the specified readingId
 */
- (ReadmillRequestOperation *)positionForReadingWithId:(ReadmillReadingId)readingId
                                     completionHandler:(ReadmillAPICompletionHandler)completionHandler;

/*!
 @param position The new position (percentage value between 0 and 1)
 @param readingId The readingId to update
 @param completionHandler An (optional) block that will return the result (id) and an error pointer.
 @brief   Update the position of the reading with the specified readingId
 */
- (ReadmillRequestOperation *)updatePosition:(double)position
                            forReadingWithId:(ReadmillReadingId)readingId
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
- (ReadmillRequestOperation *)pingReadingWithId:(ReadmillReadingId)readingId 
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
- (ReadmillRequestOperation *)pingReadingWithId:(ReadmillReadingId)readingId 
                                   withProgress:(ReadmillReadingProgress)progress
                              sessionIdentifier:(NSString *)sessionId
                                       duration:(ReadmillPingDuration)duration
                                 occurrenceTime:(NSDate *)occurrenceTime 
                                       latitude:(CLLocationDegrees)latitude
                                      longitude:(CLLocationDegrees)longitude
                              completionHandler:(ReadmillAPICompletionHandler)completionHandler;

#pragma mark -
#pragma mark Highlights

- (ReadmillRequestOperation *)createHighlightForReadingWithId:(ReadmillReadingId)readingId
                                                   parameters:(NSDictionary *)parameters
                                            completionHandler:(ReadmillAPICompletionHandler)completionHandler;

/*!
 @param readingId The id of the reading you want to create a highlight in.
 @param highlightedText The highlighted (formatted) text
 @param locators An NSDictionary of locators used to find the particular highlight. 
    See https://github.com/Readmill/API/wiki/Highlights for examples.
 @param position The approximate position of the highlighted text in the book as float percentage.
 @param highlightedAt (optional) An NSDate object representing the date the resource was created, pass nil for "now". 
 @param comment (optional) A comment on the highlight
 @param connections (optional) An array consisting of connections (dictionary) to post to. 
    Example: post_to : [{ id : 25 }, { email : martin@readmill.com }]
    IMPORTANT: Passing nil connections uses default connections.
  @param isCopyRestricted A bool stating whether the highlight has restrictions
 @param completionHandler A block that will return the result (id) and an error pointer.
 @brief  Send a highlighted text snippet to Readmill.
 */
- (ReadmillRequestOperation *)createHighlightForReadingWithId:(ReadmillReadingId)readingId
                                              highlightedText:(NSString *)highlightedText
                                                     locators:(NSDictionary *)locators
                                                     position:(ReadmillReadingProgress)position
                                                highlightedAt:(NSDate *)highlightedAt
                                                      comment:(NSString *)comment
                                                  connections:(NSArray *)connections
                                             isCopyRestricted:(BOOL)isCopyRestricted
                                            completionHandler:(ReadmillAPICompletionHandler)completionHandler;

/*!
 @param readingId The id of the reading.
 @param completionHandler A block that will return the result (id) and an error pointer.
 @brief  Get the first hundred highlights for a particular reading in Readmill.
 */
- (ReadmillRequestOperation *)highlightsForReadingWithId:(ReadmillReadingId)readingId
                                       completionHandler:(ReadmillAPICompletionHandler)completionHandler;

/*!
 @param readingId The id of the reading.
 @param count Number of highlights to return.
 @param fromDate Date to return highlights from.
 @param toDate Date to return highlights to.
 @param completionHandler A block that will return the result (id) and an error pointer.
 @brief  Get a specified number of highlights for a particular reading in Readmill between two dates.
 */
- (ReadmillRequestOperation *)highlightsForReadingWithId:(ReadmillReadingId)readingId
                                                   count:(NSUInteger)count
                                                fromDate:(NSDate *)fromDate
                                                  toDate:(NSDate *)toDate
                                       completionHandler:(ReadmillAPICompletionHandler)completionHandler;

/*!
 @param highlightId The id of the highlight.
 @param completionHandler A block that will return the result (id) and an error pointer.
 @brief  Deletes the particular highlight in Readmill.
 */
- (ReadmillRequestOperation *)highlightWithId:(ReadmillHighlightId)highlightId
                            completionHandler:(ReadmillAPICompletionHandler)completionHandler;

/*!
 @param highlightId The id of the highlight.
 @param completionHandler A block that will return the result (id) and an error pointer.
 @brief  Deletes the particular highlight in Readmill.
 */
- (ReadmillRequestOperation *)deleteHighlightWithId:(ReadmillHighlightId)highlightId
                                  completionHandler:(ReadmillAPICompletionHandler)completionHandler;

/*!
 @param userId The id of the user to retrieve highlights for.
 @param count Number of highlights to retrieve.
 @param fromDate Starting date to filter highlights from.
 @param toDate Ending date to filter highlights to.
 @param completionHandler A block that will return the result (id) and an error pointer.
 @brief Get all highlights for a particular Readmill user.
 */
- (ReadmillRequestOperation *)highlightsForUserWithId:(ReadmillUserId)userId
                                                count:(NSUInteger)count
                                             fromDate:(NSDate *)fromDate
                                               toDate:(NSDate *)toDate
                                    completionHandler:(ReadmillAPICompletionHandler)completionHandler;

#pragma mark Comments

/*!
 @param highlightId The id of the highlight you want to create a comment for.
 @param comment The comment text to post.
 @param commentedAt An NSDate object representing the date the resource was created, pass nil for "now"
 @param completionHandler A block that will return the result and an error pointer.
 @brief  Add a comment to a particular highlight in Readmill.
 */
- (ReadmillRequestOperation *)createCommentForHighlightWithId:(ReadmillHighlightId)highlightId
                                                      comment:(NSString *)comment
                                                  commentedAt:(NSDate *)date
                                            completionHandler:(ReadmillAPICompletionHandler)completionHandler;

/*!
 @param highlightId The id of the highlight.
 @param completionHandler A block that will return the result (id) and an error pointer.
 @brief  Get all comments for a particular highlight in Readmill.
 */
- (ReadmillRequestOperation *)commentsForHighlightWithId:(ReadmillHighlightId)highlightId
                                       completionHandler:(ReadmillAPICompletionHandler)completionHandler;

/*!
 @param userId The id of the highlight to retrieve comments for.
 @param count Number of comments to retrieve.
 @param fromDate Starting date to filter comments from.
 @param toDate Ending date to filter comments to.
 @param completionHandler A block that will return the result (id) and an error pointer.
 @brief Get all comments for a particular Readmill highlight.
 */
- (ReadmillRequestOperation *)commentsForHighlightWithId:(ReadmillHighlightId)highlightId
                                                   count:(NSUInteger)count
                                                fromDate:(NSDate *)fromDate
                                                  toDate:(NSDate *)toDate
                                       completionHandler:(ReadmillAPICompletionHandler)completionHandler;

#pragma mark Likes

/*!
 @param highlightId The id of the highlight.
 @param completionHandler A block that will return the result (id) and an error pointer.
 @brief  Get all users that liked the particular highlight in Readmill.
 */
- (ReadmillRequestOperation *)likesForHighlightWithId:(ReadmillHighlightId)highlightId
                                    completionHandler:(ReadmillAPICompletionHandler)completion;

/*!
 @param highlightId The id of the highlight.
 @param completionHandler A block that will return the result (id) and an error pointer.
 @brief  Like the particular highlight on Readmill.
 */
- (ReadmillRequestOperation *)likeHighlightWithId:(ReadmillHighlightId)highlightId
                                completionHandler:(ReadmillAPICompletionHandler)completion;

/*!
 @param highlightId The id of the highlight.
 @param completionHandler A block that will return the result (id) and an error pointer.
 @brief  Unlike the particular highlight on Readmill.
 */
- (ReadmillRequestOperation *)unlikeHighlightWithId:(ReadmillHighlightId)highlightId
                                  completionHandler:(ReadmillAPICompletionHandler)completion;


#pragma mark -
#pragma mark Service connections (Facebook / Twitter etc)

/*!
 @param error An (optional) error pointer that will contain an NSError object if an error occurs. 
 @brief  Get the service connections (Facebook/Twitter etc) for the current user in Readmill.
 */
- (ReadmillRequestOperation *)connectionsForCurrentUserWithCompletionHandler:(ReadmillAPICompletionHandler)completionHandler;

#pragma mark -
#pragma mark Users

/*!
 @param userId The id of the user you'd like to get details for.
 @param completionHandler A block that will return the result and an error pointer.
 @brief   Get a specific user by their id. 
 */
- (ReadmillRequestOperation *)userWithId:(ReadmillUserId)userId
                       completionHandler:(ReadmillAPICompletionHandler)completionHandler;

/*!
 @param completionHandler A block that will return the result (id) and an NSError object if an error occurs. 
 @result The current authenticated user as an NSDictionary object. See the API Keys - User section of this header for keys. 
 @brief   Get the currently logged in user. 
 */
- (ReadmillRequestOperation *)currentUserWithCompletionHandler:(ReadmillAPICompletionHandler)completionHandler;

/*!
 @param userId The id of the user you'd like to get the avatar for.
 @param parameters The parameters for the request.
 @result The URL that points to avatar of desired size for user with id.
 @brief Get the avatar URL for a user with specified id and avatar parameters.
 */
- (NSURL *)avatarURLForUserWithId:(ReadmillUserId)userId
                       parameters:(NSDictionary *)parameters;

#pragma mark -
#pragma mark Followings

/*!
 @param userId Id of the user to get followers for.
 @param parameters The parameters for the request.
 @param completionHandler An (optional) block that will return the result (id) and an error pointer.
 @return A `ReadmillRequestOperation` object associated with the action.
 @brief Find followers for a specific Readmill user.
 */
- (ReadmillRequestOperation *)followersForUserWithId:(ReadmillUserId)userId
                                          parameters:(NSDictionary *)parameters
                                   completionHandler:(ReadmillAPICompletionHandler)completionHandler;

/*!
 @param userId Id of the user to get followings for.
 @param parameters The parameters for the request.
 @param completionHandler An (optional) block that will return the result (id) and an error pointer.
 @return A `ReadmillRequestOperation` object associated with the action.
 @brief Find followings for a specific Readmill user.
 */
- (ReadmillRequestOperation *)followingsForUserWithId:(ReadmillUserId)userId
                                           parameters:(NSDictionary *)parameters
                                    completionHandler:(ReadmillAPICompletionHandler)completionHandler;

/*!
 @param userId Id of the user to follow.
 @param completionHandler An (optional) block that will return the result (id) and an error pointer.
 @return A `ReadmillRequestOperation` object associated with the action.
 @brief Follow a specific Readmill user.
 */
- (ReadmillRequestOperation *)followUserWithId:(ReadmillUserId)userId
                             completionHandler:(ReadmillAPICompletionHandler)completionHandler;

/*!
 @param userId Id of the user to unfollow.
 @param completionHandler An (optional) block that will return the result (id) and an error pointer.
 @return A `ReadmillRequestOperation` object associated with the action.
 @brief Unfollow a specific Readmill user.
 */
- (ReadmillRequestOperation *)unfollowUserWithId:(ReadmillUserId)userId
                               completionHandler:(ReadmillAPICompletionHandler)completionHandler;

#pragma mark - 
#pragma mark - Library

// http://developers.readmill.com/api/docs/v2/library

/*!
 @param libraryItemId The id of the library item to get.
 @param completionHandler A block that will return the result (id) and an NSError object if an error occurs.
 @brief Get a library item.
 */
- (ReadmillRequestOperation *)libraryItemWithId:(ReadmillLibraryItemId)libraryItemId
                              completionHandler:(ReadmillAPICompletionHandler)completionHandler;

/*!
 @param libraryItemId The id of the library item to update.
 @param parameters An NSDictionary containing the changes you wish to make.
 @param completionHandler A block that will return the result (id) and an NSError object if an error occurs.
 @brief Update a library item.
 @example parameters = @ { @"library_item" : @ { @"state" : "archived" } }
 */
- (ReadmillRequestOperation *)updateLibraryItemWithId:(ReadmillLibraryItemId)libraryItemId
                                           parameters:(NSDictionary *)parameters
                                    completionHandler:(ReadmillAPICompletionHandler)completionHandler;

/*!
 @param libraryItemId The id of the library item to delete.
 @param completionHandler A block that will return the result (id) and an NSError object if an error occurs.
 @brief Delete a library item.
 */
- (ReadmillRequestOperation *)deleteLibraryItemWithId:(ReadmillLibraryItemId)libraryItemId
                                    completionHandler:(ReadmillAPICompletionHandler)completionHandler;

/*!
 @param localIds An array containing library item ids already stored locally.
 @param completionHandler A block that will return the result (id) and an NSError object if an error occurs.
 @brief Returns a list of actions to be made on the client to be synchronized with the users cloud storage, 
        also called Library. There are only two different actions, delete and download.
 */
- (ReadmillRequestOperation *)libraryChangesWithLocalIds:(NSArray *)localIds
                                       completionHandler:(ReadmillAPICompletionHandler)completionHandler;


#pragma mark - 
#pragma mark - Cancel operations
/*!
 @brief Cancels all queued requests to the server.
 */
- (void)cancelAllOperations;

- (ReadmillRequestOperation *)operationWithRequest:(NSURLRequest *)request
                                     completion:(ReadmillAPICompletionHandler)completion;


@end
