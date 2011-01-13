//
//  ReadmillAPI.h
//  Readmill Framework
//
//  Created by Work on 10/01/2011.
//  Copyright 2011 KennettNet Software Limited. All rights reserved.
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
