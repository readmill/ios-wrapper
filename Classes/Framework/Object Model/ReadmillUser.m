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

#import "ReadmillUser.h"
#import "NSDictionary+ReadmillAdditions.h"
#import "ReadmillBook.h"
#import "ReadmillReading.h"

@interface ReadmillUser ()

@property (readwrite, copy) NSString *city;
@property (readwrite, copy) NSString *country;
@property (readwrite, copy) NSString *userDescription;
@property (readwrite, copy) NSString *firstName;
@property (readwrite, copy) NSString *lastName;
@property (readwrite, copy) NSString *fullName;
@property (readwrite, copy) NSString *userName;
@property (readwrite, copy) NSString *authenticationToken;

@property (readwrite, copy) NSURL *avatarURL;
@property (readwrite, copy) NSURL *permalinkURL;
@property (readwrite, copy) NSURL *websiteURL;

@property (readwrite) ReadmillUserId userId;

@property (readwrite) NSUInteger followerCount;
@property (readwrite) NSUInteger followingCount;
@property (readwrite) NSUInteger booksAbandonedCount;
@property (readwrite) NSUInteger booksFinishedCount;
@property (readwrite) NSUInteger booksInterestingCount;
@property (readwrite) NSUInteger booksReadingCount;

@property (readwrite, retain) ReadmillAPIWrapper *apiWrapper;

@end

@implementation ReadmillUser

+ (NSURL *)clientAuthorizationURLWithRedirectURL:(NSURL *)redirectURL apiConfiguration:(ReadmillAPIConfiguration *)apiConfiguration 
{
    ReadmillAPIWrapper *api = [[[ReadmillAPIWrapper alloc] initWithAPIConfiguration:apiConfiguration] 
                               autorelease];
    return [api clientAuthorizationURLWithRedirectURLString:[redirectURL absoluteString]];
}

+ (void)authenticateCallbackURL:(NSURL *)callbackURL 
                baseCallbackURL:(NSURL *)baseCallbackURL
                       delegate:(id <ReadmillUserAuthenticationDelegate>)authenticationDelegate 
               apiConfiguration:(ReadmillAPIConfiguration *)apiConfiguration 
{    
    ReadmillAPIWrapper *apiWrapper = [[[ReadmillAPIWrapper alloc] initWithAPIConfiguration:apiConfiguration] autorelease];
    
    ReadmillUser *user = [[ReadmillUser alloc] initWithAPIDictionary:nil
                                                          apiWrapper:apiWrapper];
    [user authenticateCallbackURL:callbackURL 
                  baseCallbackURL:baseCallbackURL
                         delegate:authenticationDelegate];
    
    [user autorelease];
}

+ (void)authenticateWithPropertyListRepresentation:(NSDictionary *)plistRep delegate:(id <ReadmillUserAuthenticationDelegate>)authenticationDelegate 
{ 
    ReadmillUser *user = [[ReadmillUser alloc] initWithPropertyListRepresentation:plistRep];
    [user verifyAuthentication:authenticationDelegate];
    [user release];
}

- (id)init 
{
    return [self initWithAPIDictionary:nil apiWrapper:[[[ReadmillAPIWrapper alloc] init] autorelease]];
}

- (id)initWithAPIDictionary:(NSDictionary *)apiDict apiWrapper:(ReadmillAPIWrapper *)wrapper 
{
    if ((self = [super init])) {
        [self setApiWrapper:wrapper];
        [self updateWithAPIDictionary:apiDict];
    }
    
    return self;
}

- (id)initWithPropertyListRepresentation:(NSDictionary *)plistRep 
{
    if ((self = [super init])) {
        [self setApiWrapper:[[[ReadmillAPIWrapper alloc] initWithPropertyListRepresentation:plistRep] autorelease]];
    }
    return self;
}

+ (NSSet *)keyPathsForValuesAffectingPropertyListRepresentation
{
    return [NSSet setWithObject:@"apiWrapper.propertyListRepresentation"];
}

- (NSDictionary *)propertyListRepresentation 
{
    return [[self apiWrapper] propertyListRepresentation]; 
}

- (NSString *)description 
{
    return [NSString stringWithFormat:@"%@: %@ (%@)", [super description], [self fullName], [self userName]];
}

- (void)updateWithAPIDictionary:(NSDictionary *)apiDict 
{
    NSDictionary *cleanedDict = [apiDict dictionaryByRemovingNullValues];
    cleanedDict = [cleanedDict valueForKey:kReadmillAPIUserKey];
    
    [self setCity:[cleanedDict valueForKey:kReadmillAPIUserCityKey]];
    [self setCountry:[cleanedDict valueForKey:kReadmillAPIUserCountryKey]];
    [self setUserDescription:[cleanedDict valueForKey:kReadmillAPIUserDescriptionKey]];
    [self setFirstName:[cleanedDict valueForKey:kReadmillAPIUserFirstNameKey]];
    [self setLastName:[cleanedDict valueForKey:kReadmillAPIUserLastNameKey]];
    [self setFullName:[cleanedDict valueForKey:kReadmillAPIUserFullNameKey]];
    [self setUserName:[cleanedDict valueForKey:kReadmillAPIUserReadmillUserNameKey]];
    
    if ([cleanedDict valueForKey:kReadmillAPIUserAvatarURLKey]) {
        [self setAvatarURL:[NSURL URLWithString:[cleanedDict valueForKey:kReadmillAPIUserAvatarURLKey]]];
    }
    
    if ([cleanedDict valueForKey:kReadmillAPIUserPermalinkURLKey]) {
        [self setPermalinkURL:[NSURL URLWithString:[cleanedDict valueForKey:kReadmillAPIUserPermalinkURLKey]]];
    }
    
    if ([cleanedDict valueForKey:kReadmillAPIUserWebsiteKey]) {
        [self setWebsiteURL:[NSURL URLWithString:[cleanedDict valueForKey:kReadmillAPIUserWebsiteKey]]];
    }
    
    [self setUserId:[[cleanedDict valueForKey:kReadmillAPIUserIdKey] unsignedIntegerValue]];
    
    [self setFollowerCount:[[cleanedDict valueForKey:kReadmillAPIUserFollowerCountKey] unsignedIntegerValue]];
    [self setFollowingCount:[[cleanedDict valueForKey:kReadmillAPIUserFollowingCountKey] unsignedIntegerValue]];
    [self setBooksAbandonedCount:[[cleanedDict valueForKey:kReadmillAPIUserBooksAbandonedCountKey] unsignedIntegerValue]];
    [self setBooksFinishedCount:[[cleanedDict valueForKey:kReadmillAPIUserBooksFinishedCountKey] unsignedIntegerValue]];
    [self setBooksInterestingCount:[[cleanedDict valueForKey:kReadmillAPIUserBooksInterestingCountKey] unsignedIntegerValue]];
    [self setBooksReadingCount:[[cleanedDict valueForKey:kReadmillAPIUserBooksReadingCountKey] unsignedIntegerValue]];
    
    [self setAuthenticationToken:[cleanedDict valueForKey:kReadmillAPIUserAuthenticationToken]];
}

- (void)dealloc 
{
    // Clean-up code here.
    
    [self setApiWrapper:nil];
    
    [self setAvatarImageData:nil];
    [self setCity:nil];
    [self setCountry:nil];
    [self setUserDescription:nil];
    [self setFirstName:nil];
    [self setLastName:nil];
    [self setFullName:nil];
    [self setUserName:nil];
    [self setAuthenticationToken:nil];
    [self setAvatarURL:nil];
    [self setPermalinkURL:nil];
    [self setWebsiteURL:nil];
    
    [super dealloc];
}

#pragma mark -
#pragma mark Threaded Methods

- (void)authenticateCallbackURL:(NSURL *)callbackURL 
                baseCallbackURL:(NSURL *)baseCallbackURL 
                       delegate:(id <ReadmillUserAuthenticationDelegate>)authenticationDelegate 
{    
    NSString *callbackURLString = [callbackURL absoluteString];
    NSRange codePrefixRange = [callbackURLString rangeOfString:@"code="];
    if (codePrefixRange.location == NSNotFound) {
        NSError *error = [NSError errorWithDomain:kReadmillDomain
                                             code:0
                                         userInfo:nil];
        [authenticationDelegate readmillAuthenticationDidFailWithError:error];
        return;
    }
    
    NSString *code = [callbackURLString substringFromIndex:codePrefixRange.location + codePrefixRange.length];
    
    NSRange codeSuffixRange = [code rangeOfString:@"&"];
    
    if (codeSuffixRange.location != NSNotFound) {
        code = [code substringToIndex:codeSuffixRange.location];
    }
    
    if ([code length] == 0) {
        [authenticationDelegate readmillAuthenticationDidFailWithError:[NSError errorWithDomain:kReadmillDomain
                                                                                           code:0
                                                                                       userInfo:nil]];
        return;
    }
    
    // The block to be called when authorization request returns
    ReadmillAPICompletionHandler authorizationHandler = ^(id result, NSError *error) {
        if (!error && result) {
            // Authorization succeeded, now try to fetch & update the user
            [self verifyAuthentication:authenticationDelegate];
        } else {
            [authenticationDelegate readmillAuthenticationDidFailWithError:error];   
        }
    };
    
    [[self apiWrapper] authorizeWithAuthorizationCode:code
                                      fromRedirectURL:[baseCallbackURL absoluteString]
                                    completionHandler:authorizationHandler];
}

- (void)verifyAuthentication:(id <ReadmillUserAuthenticationDelegate>)authenticationDelegate 
{
    [[self apiWrapper] currentUserWithCompletionHandler:^(id result, NSError *error) {
        if (result && !error) {
            [self updateWithAPIDictionary:result];
            [authenticationDelegate readmillAuthenticationDidSucceedWithLoggedInUser:self];
        } else {
            [authenticationDelegate readmillAuthenticationDidFailWithError:error];
        }
    }];
}

#pragma mark -

- (void)findOrCreateBookWithIdentifier:(NSString *)identifier
                                 title:(NSString *)title
                                author:(NSString *)author
                      createIfNotFound:(BOOL)createIfNotFound
                              delegate:(id <ReadmillBookFindingDelegate>)delegate 
{
    if (!([identifier length] || ([author length] && [title length]))) {
        // Need at least ISBN or (author and title)
        NSError *error = [NSError errorWithDomain:kReadmillDomain 
                                             code:0 
                                         userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                                   @"Insufficient arguments. Need either identifier or author & title.", NSLocalizedDescriptionKey, nil]];

        return [delegate readmillUser:self failedToFindBookWithError:error];
    }
    
    __block typeof(self) bself = self;
    ReadmillAPICompletionHandler completionBlock = ^(NSDictionary *bookDictionary, NSError *error) {
        
        if (error) {
            [delegate readmillUser:bself failedToFindBookWithError:error];
        } else {
            if (bookDictionary == nil) {
                [delegate readmillUserFoundNoBook:bself];
            } else {
                ReadmillBook *book = [[[ReadmillBook alloc] initWithAPIDictionary:bookDictionary] autorelease];
                [delegate readmillUser:bself didFindBook:book];    
            }
        }
    };
    
    [[self apiWrapper] findOrCreateBookWithTitle:title 
                                          author:author
                                      identifier:identifier
                               completionHandler:completionBlock];    
}

- (void)findBookWithTitle:(NSString *)title
                   author:(NSString *)author 
                 delegate:(id<ReadmillBookFindingDelegate>)delegate
{
    [self findBookWithIdentifier:nil
                           title:title
                          author:author
                        delegate:delegate];
}
- (void)findBookWithIdentifier:(NSString *)identifier
                         title:(NSString *)title
                        author:(NSString *)author
                      delegate:(id <ReadmillBookFindingDelegate>)delegate 
{    
    [self findOrCreateBookWithIdentifier:identifier
                                   title:title
                                  author:author
                        createIfNotFound:NO
                                delegate:delegate];
}

- (void)findOrCreateBookWithIdentifier:(NSString *)identifier
                                 title:(NSString *)title
                                author:(NSString *)author
                              delegate:(id <ReadmillBookFindingDelegate>)delegate
{
    [self findOrCreateBookWithIdentifier:identifier
                                   title:title
                                  author:author
                        createIfNotFound:YES
                                delegate:delegate];
}

#pragma mark -

- (void)findOrCreateReadingForBook:(ReadmillBook *)book 
                             state:(ReadmillReadingState)readingState
                         isPrivate:(BOOL)isPrivate 
                       connections:(NSArray *)connections
                          delegate:(id <ReadmillReadingFindingDelegate>)delegate 
{    
    __block typeof (self) bself = self;
    ReadmillAPICompletionHandler completionBlock = ^(id apiResponse, NSError *error) {
        NSDictionary *readingDictionary = [apiResponse valueForKey:kReadmillAPIReadingKey];
        NSLog(@"readingdict: %@", readingDictionary);
        if (error || !readingDictionary) {
            [delegate readmillUser:bself failedToFindReadingForBook:book 
                         withError:error];
        } else {
            
            ReadmillReading *reading = [[[ReadmillReading alloc] initWithAPIDictionary:readingDictionary
                                                                            apiWrapper:bself->_apiWrapper] autorelease];
            [book updateWithAPIDictionary:[readingDictionary valueForKey:kReadmillAPIReadingBookKey]];
            
            [delegate readmillUser:bself
                    didFindReading:reading
                           forBook:book];
        }
    };
    
    NSLog(@"book: %@", book);
    
    [[self apiWrapper] findOrCreateReadingWithBookId:[book bookId]
                                               state:[ReadmillReading readingStateStringFromState:readingState]
                                           isPrivate:isPrivate 
                                         connections:connections
                                   completionHandler:completionBlock];
}

- (void)findOrCreateReadingForBook:(ReadmillBook *)book 
                             state:(ReadmillReadingState)readingState
                         isPrivate:(BOOL)isPrivate
                          delegate:(id<ReadmillReadingFindingDelegate>)readingFindingDelegate
{
    [self findOrCreateReadingForBook:book 
                               state:readingState 
                           isPrivate:isPrivate
                         connections:nil 
                            delegate:readingFindingDelegate];
}

@end
