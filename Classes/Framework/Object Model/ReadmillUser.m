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
#import "ReadmillDictionaryExtensions.h"
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

@property (readwrite, copy) NSURL *avatarURL;
@property (readwrite, copy) NSURL *permalinkURL;
@property (readwrite, copy) NSURL *websiteURL;

@property (readwrite) ReadmillUserId userId;

@property (readwrite) NSUInteger followerCount;
@property (readwrite) NSUInteger followingCount;
@property (readwrite) NSUInteger abandonedBookCount;
@property (readwrite) NSUInteger finishedBookCount;
@property (readwrite) NSUInteger interestingBookCount;
@property (readwrite) NSUInteger openBookCount;

@property (readwrite, retain) ReadmillAPIWrapper *apiWrapper;

@end

@implementation ReadmillUser

+(NSURL *)clientAuthorizationURLWithRedirectURL:(NSURL *)redirect onStagingServer:(BOOL)onStaging {
    
    ReadmillAPIWrapper *api = nil;
    
    if (onStaging) {
        api = [[[ReadmillAPIWrapper alloc] initWithStagingEndPoint] autorelease];
    } else {
        api = [[[ReadmillAPIWrapper alloc] init] autorelease];
    }
    
    return [api clientAuthorizationURLWithRedirectURLString:[redirect absoluteString]];
}

+(void)authenticateCallbackURL:(NSURL *)callbackURL baseCallbackURL:(NSURL *)baseCallbackURL delegate:(id <ReadmillUserAuthenticationDelegate>)authenticationDelegate onStagingServer:(BOOL)onStaging {
    
    ReadmillAPIWrapper *api = nil;
    
    if (onStaging) {
        api = [[[ReadmillAPIWrapper alloc] initWithStagingEndPoint] autorelease];
    } else {
        api = [[[ReadmillAPIWrapper alloc] init] autorelease];
    }
    
    ReadmillUser *user = [[ReadmillUser alloc] initWithAPIDictionary:nil apiWrapper:api];
    [user authenticateCallbackURL:callbackURL baseCallbackURL:baseCallbackURL delegate:authenticationDelegate];
    
    [user autorelease];
    
}

+(void)authenticateWithPropertyListRepresentation:(NSDictionary *)plistRep delegate:(id <ReadmillUserAuthenticationDelegate>)authenticationDelegate {
 
    ReadmillUser *user = [[ReadmillUser alloc] initWithPropertyListRepresentation:plistRep];
    [user verifyAuthentication:authenticationDelegate];
    [user release];
}

- (id)init {
    return [self initWithAPIDictionary:nil apiWrapper:[[[ReadmillAPIWrapper alloc] init] autorelease]];
}

-(id)initWithAPIDictionary:(NSDictionary *)apiDict apiWrapper:(ReadmillAPIWrapper *)wrapper {
    if ((self = [super init])) {
        // Initialization code here.
        
        [self setApiWrapper:wrapper];
        [self updateWithAPIDictionary:apiDict];
    }
    
    return self;
}

-(id)initWithPropertyListRepresentation:(NSDictionary *)plistRep {
    if ((self = [super init])) {
        // Initialization code here.
        
        [self setApiWrapper:[[[ReadmillAPIWrapper alloc] initWithPropertyListRepresentation:plistRep] autorelease]];
    }
    return self;
}

+(NSSet *)keyPathsForValuesAffectingPropertyListRepresentation {
    return [NSSet setWithObject:@"apiWrapper.propertyListRepresentation"];
}

-(NSDictionary *)propertyListRepresentation {
    return [[self apiWrapper] propertyListRepresentation]; 
}

-(NSString *)description {
    return [NSString stringWithFormat:@"%@: %@ (%@)", [super description], [self fullName], [self userName]];
}

-(void)updateWithAPIDictionary:(NSDictionary *)apiDict {
    NSDictionary *cleanedDict = [apiDict dictionaryByRemovingNullValues];
    
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
    [self setAbandonedBookCount:[[cleanedDict valueForKey:kReadmillAPIUserAbandonedBooksKey] unsignedIntegerValue]];
    [self setFinishedBookCount:[[cleanedDict valueForKey:kReadmillAPIUserFinishedBooksKey] unsignedIntegerValue]];
    [self setInterestingBookCount:[[cleanedDict valueForKey:kReadmillAPIUserInterestingBooksKey] unsignedIntegerValue]];
    [self setOpenBookCount:[[cleanedDict valueForKey:kReadmillAPIUserOpenBooksKey] unsignedIntegerValue]];
}

@synthesize city;
@synthesize country;
@synthesize userDescription;
@synthesize firstName;
@synthesize lastName;
@synthesize fullName;
@synthesize userName;

@synthesize avatarURL;
@synthesize permalinkURL;
@synthesize websiteURL;

@synthesize userId;

@synthesize followerCount;
@synthesize followingCount;
@synthesize abandonedBookCount;
@synthesize finishedBookCount;
@synthesize interestingBookCount;
@synthesize openBookCount;

@synthesize apiWrapper;

- (void)dealloc {
    // Clean-up code here.
    
    [self setApiWrapper:nil];
    
    [self setCity:nil];
    [self setCountry:nil];
    [self setUserDescription:nil];
    [self setFirstName:nil];
    [self setLastName:nil];
    [self setFullName:nil];
    [self setUserName:nil];
    [self setAvatarURL:nil];
    [self setPermalinkURL:nil];
    [self setWebsiteURL:nil];
    
    [super dealloc];
}

#pragma mark -
#pragma mark Threaded Methods

-(void)authenticateCallbackURL:(NSURL *)callbackURL 
               baseCallbackURL:(NSURL *)baseCallbackURL 
                      delegate:(id <ReadmillUserAuthenticationDelegate>)authenticationDelegate {
    
    
    NSString *callbackURLString = [callbackURL absoluteString];
    
    NSRange codePrefixRange = [callbackURLString rangeOfString:@"code="];
    
    if (codePrefixRange.location == NSNotFound) {
        [authenticationDelegate readmillAuthenticationDidFailWithError:[NSError errorWithDomain:kReadmillDomain
                                                                                             code:0
                                                                                       userInfo:nil]];
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
    
    NSDictionary *properties = [NSDictionary dictionaryWithObjectsAndKeys:
                                code, @"code",
                                baseCallbackURL, @"callbackURL",
                                authenticationDelegate, @"delegate",
                                [NSThread currentThread], @"callbackThread",
                                nil];
    
    [self performSelectorInBackground:@selector(attemptAuthenticationWithProperties:)
                           withObject:properties];
    
    
}

-(void)attemptAuthenticationWithProperties:(NSDictionary *)properties {
    
    [self retain];
    
    NSAutoreleasePool *pool;
    pool = [[NSAutoreleasePool alloc] init];
    
    NSThread *callbackThread = [properties valueForKey:@"callbackThread"];
    id <ReadmillUserAuthenticationDelegate> authenticationDelegate = [properties valueForKey:@"delegate"];
    NSString *authenticationCode = [NSString stringWithString:[properties valueForKey:@"code"]];
    NSURL *callbackURL = [[[properties valueForKey:@"callbackURL"] copy] autorelease];
    
    NSError *error = nil;
    
    [[self apiWrapper] authorizeWithAuthorizationCode:authenticationCode
                                      fromRedirectURL:[callbackURL absoluteString]
                                                error:&error];
    
    if (error == nil) {
        [self updateWithAPIDictionary:[[self apiWrapper] currentUser:&error]];
    }
    
    if (error == nil && authenticationDelegate != nil) {
        
        [(NSObject *)authenticationDelegate performSelector:@selector(readmillAuthenticationDidSucceedWithLoggedInUser:)
                                                   onThread:callbackThread
                                                 withObject:self
                                              waitUntilDone:YES]; 
        
    } else if (error != nil && authenticationDelegate != nil) {
        [(NSObject *)authenticationDelegate performSelector:@selector(readmillAuthenticationDidFailWithError:)
                                                   onThread:callbackThread
                                                 withObject:error
                                              waitUntilDone:YES];
    }
    
    [pool drain];
    
    [self release];
}

-(void)verifyAuthentication:(id <ReadmillUserAuthenticationDelegate>)authenticationDelegate {
    
    NSDictionary *properties = [NSDictionary dictionaryWithObjectsAndKeys:
                                authenticationDelegate, @"delegate",
                                [NSThread currentThread], @"callbackThread",
                                nil];
    
    [self performSelectorInBackground:@selector(verifyAuthenticationWithProperties:)
                           withObject:properties];

}



-(void)verifyAuthenticationWithProperties:(NSDictionary *)properties {
    [self retain];
    NSAutoreleasePool *pool;
    pool = [[NSAutoreleasePool alloc] init];
    
    NSThread *callbackThread = [properties valueForKey:@"callbackThread"];
	
    id <ReadmillUserAuthenticationDelegate> authenticationDelegate = [properties valueForKey:@"delegate"];
    NSError *error = nil;
    [self updateWithAPIDictionary:[[self apiWrapper] currentUser:&error]];
	
    if (error == nil && authenticationDelegate != nil) {
        
        [(NSObject *)authenticationDelegate performSelector:@selector(readmillAuthenticationDidSucceedWithLoggedInUser:)
                                                   onThread:callbackThread
                                                 withObject:self
                                              waitUntilDone:YES]; 
        
    } else if (error != nil && authenticationDelegate != nil) {
        [(NSObject *)authenticationDelegate performSelector:@selector(readmillAuthenticationDidFailWithError:)
                                                   onThread:callbackThread
                                                 withObject:error
                                              waitUntilDone:YES];
    }
    
    [pool drain];
    
    [self release];
}


#pragma mark -

-(void)findBooksWithISBN:(NSString *)isbn
                   title:(NSString *)title 
                delegate:(id <ReadmillBookFindingDelegate>)bookfindingDelegate {
    
    NSDictionary *properties = [NSDictionary dictionaryWithObjectsAndKeys:
                                bookfindingDelegate, @"delegate",
                                [NSThread currentThread], @"callbackThread",
                                isbn, kReadmillAPIBookISBNKey, 
                                title, kReadmillAPIBookTitleKey,
                                nil];
    
    [self performSelectorInBackground:@selector(findBooksWithProperties:)
                           withObject:properties];
}

-(void)findOrCreateBookWithISBN:(NSString *)isbn 
                          title:(NSString *)title 
                         author:(NSString *)author
                       delegate:(id <ReadmillBookFindingDelegate>)bookfindingDelegate {
    
	
    NSDictionary *properties = [NSDictionary dictionaryWithObjectsAndKeys:
                                bookfindingDelegate, @"delegate",
                                [NSThread currentThread], @"callbackThread",
                                title, kReadmillAPIBookTitleKey,
                                isbn, kReadmillAPIBookISBNKey, 
                                author, kReadmillAPIBookAuthorKey,
                                [NSNumber numberWithBool:YES], @"createIfNotFound",
                                nil];
    	
    [self performSelectorInBackground:@selector(findBooksWithProperties:)
                           withObject:properties];
    
}

-(void)findBooksWithProperties:(NSDictionary *)properties {
    [self retain];
    
    NSAutoreleasePool *pool;
    pool = [[NSAutoreleasePool alloc] init];
    
    NSThread *callbackThread = [properties valueForKey:@"callbackThread"];
    id <ReadmillBookFindingDelegate> bookFindingDelegate = [properties valueForKey:@"delegate"];
    
    NSError *error = nil;
    NSArray *bookDicts = nil;
    
    NSString *isbn = [properties valueForKey:kReadmillAPIBookISBNKey];
    NSString *title = [properties valueForKey:kReadmillAPIBookTitleKey];
    NSString *author = [properties valueForKey:kReadmillAPIBookAuthorKey];

    BOOL createIfNotFound = [[properties valueForKey:@"createIfNotFound"] boolValue];


    // Search by ISBN
    if ([isbn length] > 0) {
        bookDicts = [[self apiWrapper] booksMatchingISBN:isbn
                                                   error:&error];
    } 
    
    // Search by title
    if ([title length] > 0 && [bookDicts count] == 0 && error == nil) {
        bookDicts = [[self apiWrapper] booksMatchingTitle:title 
                                                    error:&error];
    }
    
    // Create if not found
	if ([bookDicts count] == 0 && error == nil && createIfNotFound == YES) {
        
        NSDictionary *bookDict = [[self apiWrapper] addBookWithTitle:title
                                                              author:author
                                                                isbn:isbn
                                                               error:&error];
        
        if (bookDict != nil) {
            bookDicts = [NSArray arrayWithObject:bookDict];
            
        }
    }
    
    
    if (error == nil && bookFindingDelegate != nil && bookDicts == nil) {
        
        [(NSObject *)bookFindingDelegate performSelector:@selector(readmillUserFoundNoBooks:)
                                                onThread:callbackThread
                                              withObject:self
                                           waitUntilDone:YES]; 
        
    } else if (error == nil && bookFindingDelegate != nil && [bookDicts count] > 0) {
        
        NSMutableArray *books = [NSMutableArray arrayWithCapacity:[bookDicts count]];
        
        for (NSDictionary *bookDict in bookDicts) {
            [books addObject:[[[ReadmillBook alloc] initWithAPIDictionary:bookDict] autorelease]];
        }
        NSInvocation *successInvocation = [NSInvocation invocationWithMethodSignature:
                                           [(NSObject *)bookFindingDelegate methodSignatureForSelector:@selector(readmillUser:didFindBooks:)]];
        [successInvocation setSelector:@selector(readmillUser:didFindBooks:)];
        
        NSArray *bookArray = [NSArray arrayWithArray:books];
        
        [successInvocation setArgument:&self atIndex:2];
        [successInvocation setArgument:&bookArray atIndex:3];
        
        [successInvocation performSelector:@selector(invokeWithTarget:)
                                  onThread:callbackThread
                                withObject:bookFindingDelegate
                             waitUntilDone:YES]; 
        
    } else if (error != nil && bookFindingDelegate != nil) {
        NSInvocation *failedInvocation = [NSInvocation invocationWithMethodSignature:
                                          [(NSObject *)bookFindingDelegate methodSignatureForSelector:@selector(readmillUser:failedToFindBooksWithError:)]];
        [failedInvocation setSelector:@selector(readmillUser:failedToFindBooksWithError:)];
        
        [failedInvocation setArgument:&self atIndex:2];
        [failedInvocation setArgument:&error atIndex:3];
        
        [failedInvocation performSelector:@selector(invokeWithTarget:)
                                 onThread:callbackThread
                               withObject:bookFindingDelegate
                            waitUntilDone:YES]; 
        
        
    }
    
    [pool drain];
    
    [self release];
}

-(void)createBookWithISBN:(NSString *)isbn
                    title:(NSString *)title
                   author:(NSString *)author
                 delegate:(id <ReadmillBookFindingDelegate>)bookfindingDelegate {
    
    
    NSDictionary *properties = [NSDictionary dictionaryWithObjectsAndKeys:
                                bookfindingDelegate, @"delegate",
                                [NSThread currentThread], @"callbackThread",
                                isbn, kReadmillAPIBookISBNKey, 
                                title, kReadmillAPIBookTitleKey,
                                author, kReadmillAPIBookAuthorKey,
                                nil];
    
    [self performSelectorInBackground:@selector(createBookWithProperties:)
                           withObject:properties];
    
}

-(void)createBookWithProperties:(NSDictionary *)properties {
    
    [self retain];
    
    NSAutoreleasePool *pool;
    pool = [[NSAutoreleasePool alloc] init];
    
    NSThread *callbackThread = [properties valueForKey:@"callbackThread"];
    id <ReadmillBookFindingDelegate> bookFindingDelegate = [properties valueForKey:@"delegate"];
    
    NSError *error = nil;
    NSDictionary *bookDict = [[self apiWrapper] addBookWithTitle:[properties valueForKey:kReadmillAPIBookTitleKey]
                                                          author:[properties valueForKey:kReadmillAPIBookAuthorKey]
                                                            isbn:[properties valueForKey:kReadmillAPIBookISBNKey]
                                                           error:&error];
    
    if (error == nil && bookFindingDelegate != nil && bookDict == nil) {
        
        [(NSObject *)bookFindingDelegate performSelector:@selector(readmillUserFoundNoBooks:)
                                                onThread:callbackThread
                                              withObject:self
                                           waitUntilDone:YES]; 
        
    } else if (error == nil && bookFindingDelegate != nil && bookDict != nil) {
        
        NSInvocation *successInvocation = [NSInvocation invocationWithMethodSignature:
                                           [(NSObject *)bookFindingDelegate methodSignatureForSelector:@selector(readmillUser:didFindBooks:)]];
        [successInvocation setSelector:@selector(readmillUser:didFindBooks:)];
        
        NSArray *bookArray = [NSArray arrayWithObject:[[[ReadmillBook alloc] initWithAPIDictionary:bookDict] autorelease]];
        
        [successInvocation setArgument:&self atIndex:2];
        [successInvocation setArgument:&bookArray atIndex:3];
        
        [successInvocation performSelector:@selector(invokeWithTarget:)
                                  onThread:callbackThread
                                withObject:bookFindingDelegate
                             waitUntilDone:YES]; 
        
    } else if (error != nil && bookFindingDelegate != nil) {
        
        NSInvocation *failedInvocation = [NSInvocation invocationWithMethodSignature:
                                           [(NSObject *)bookFindingDelegate methodSignatureForSelector:@selector(readmillUser:failedToFindBooksWithError:)]];
        [failedInvocation setSelector:@selector(readmillUser:failedToFindBooksWithError:)];
        
        [failedInvocation setArgument:&self atIndex:2];
        [failedInvocation setArgument:&error atIndex:3];
        
        [failedInvocation performSelector:@selector(invokeWithTarget:)
                                 onThread:callbackThread
                               withObject:bookFindingDelegate
                            waitUntilDone:YES]; 
        
        
    }
    
    [pool drain];
    
    [self release];
}

#pragma mark -

-(void)findReadingForBook:(ReadmillBook *)book delegate:(id <ReadmillReadingFindingDelegate>)readingFindingDelegate {
    
    NSDictionary *properties = [NSDictionary dictionaryWithObjectsAndKeys:
                                readingFindingDelegate, @"delegate",
                                [NSThread currentThread], @"callbackThread",
                                book, @"book", 
                                nil];
    
    [self performSelectorInBackground:@selector(findReadingWithProperties:)
                           withObject:properties];
    
}

-(void)findOrCreateReadingForBook:(ReadmillBook *)book state:(ReadmillReadingState)readingState createdReadingIsPrivate:(BOOL)isPrivate delegate:(id <ReadmillReadingFindingDelegate>)readingFindingDelegate {
    
    NSDictionary *properties = [NSDictionary dictionaryWithObjectsAndKeys:
                                readingFindingDelegate, @"delegate",
                                [NSThread currentThread], @"callbackThread",
                                book, @"book", 
                                [NSNumber numberWithBool:YES], @"createIfNotFound",
								[NSNumber numberWithInteger:readingState],kReadmillAPIReadingStateKey,
                                [NSNumber numberWithBool:isPrivate], kReadmillAPIReadingIsPrivateKey,
                                nil];
    
    [self performSelectorInBackground:@selector(findReadingWithProperties:)
                           withObject:properties];
}

-(void)findReadingWithProperties:(NSDictionary *)properties {
    [self retain];
    
    NSAutoreleasePool *pool;
    pool = [[NSAutoreleasePool alloc] init];
    
    NSThread *callbackThread = [properties valueForKey:@"callbackThread"];
    id <ReadmillReadingFindingDelegate> readingFindingDelegate = [properties valueForKey:@"delegate"];
    ReadmillBook *book = [properties valueForKey:@"book"];
    BOOL createIfNotFound = [[properties valueForKey:@"createIfNotFound"] boolValue];
    BOOL isPrivate = [[properties valueForKey:kReadmillAPIReadingIsPrivateKey] boolValue];
	ReadmillReadingState readingState = [[properties valueForKey:kReadmillAPIReadingStateKey] integerValue];
    
    NSError *error = nil;
    NSMutableArray *matchingReadings = [NSMutableArray array];
    
    NSArray *readingsForUser = [[self apiWrapper] publicReadingsForUserWithId:[self userId] error:&error];
    
    if (error == nil) {
        for (NSDictionary *reading in readingsForUser) {
            if ([[[reading valueForKey:kReadmillAPIReadingBookKey]
                  valueForKey:kReadmillAPIBookIdKey] unsignedIntegerValue] == [book bookId]) {
                
                [matchingReadings addObject:reading];
            }
        }
    }
    if ([matchingReadings count] == 0 && createIfNotFound == YES) {
		
        NSDictionary *readingDict = [[self apiWrapper] createReadingWithBookId:[book bookId]
                                                                   state:readingState
                                                                 private:isPrivate
                                                                   error:&error];
        if (readingDict != nil) {
            [matchingReadings addObject:readingDict];
        }
    }
    
    if (error == nil && readingFindingDelegate != nil && [matchingReadings count] == 0) {
        
        NSInvocation *noReadingsInvocation = [NSInvocation invocationWithMethodSignature:
                                           [(NSObject *)readingFindingDelegate
                                            methodSignatureForSelector:@selector(readmillUser:foundNoReadingsForBook:)]];
        
        [noReadingsInvocation setSelector:@selector(readmillUser:foundNoReadingsForBook:)];
        
        [noReadingsInvocation setArgument:&self atIndex:2];
        [noReadingsInvocation setArgument:&book atIndex:3];
        
        [noReadingsInvocation performSelector:@selector(invokeWithTarget:)
                                  onThread:callbackThread
                                withObject:readingFindingDelegate
                             waitUntilDone:YES]; 
        
    } else if (error == nil && readingFindingDelegate != nil && [matchingReadings count] > 0) {
        
        NSMutableArray *mutableReadings = [NSMutableArray arrayWithCapacity:[matchingReadings count]];
        
        for (NSDictionary *dict in matchingReadings) {
            ReadmillReading *reading = [[[ReadmillReading alloc] initWithAPIDictionary:dict apiWrapper:[self apiWrapper]] autorelease];
            [mutableReadings addObject:reading];
        }
        
        NSArray *readings = [NSArray arrayWithArray:mutableReadings];
        
        NSInvocation *successInvocation = [NSInvocation invocationWithMethodSignature:
                                           [(NSObject *)readingFindingDelegate
                                            methodSignatureForSelector:@selector(readmillUser:didFindReadings:forBook:)]];
        
        [successInvocation setSelector:@selector(readmillUser:didFindReadings:forBook:)];
        
        [successInvocation setArgument:&self atIndex:2];
        [successInvocation setArgument:&readings atIndex:3];
        [successInvocation setArgument:&book atIndex:4];
        
        [successInvocation performSelector:@selector(invokeWithTarget:)
                                  onThread:callbackThread
                                withObject:readingFindingDelegate
                             waitUntilDone:YES]; 
        
    } else if (error != nil && readingFindingDelegate != nil) {
        
        NSInvocation *failedInvocation = [NSInvocation invocationWithMethodSignature:
                                          [(NSObject *)readingFindingDelegate 
                                           methodSignatureForSelector:@selector(readmillUser:failedToFindReadingForBook:withError:)]];
        
        [failedInvocation setSelector:@selector(readmillUser:failedToFindReadingForBook:withError:)];
        
        [failedInvocation setArgument:&self atIndex:2];
        [failedInvocation setArgument:&book atIndex:3];
        [failedInvocation setArgument:&error atIndex:4];
        
        [failedInvocation performSelector:@selector(invokeWithTarget:)
                                 onThread:callbackThread
                               withObject:readingFindingDelegate
                            waitUntilDone:YES]; 
    }

    
    [pool drain];
    
    [self release];
    
}


-(void)createReadingForBook:(ReadmillBook *)book state:(ReadmillReadingState)readingState isPrivate:(BOOL)isPrivate delegate:(id <ReadmillReadingFindingDelegate>)readingFindingDelegate {
    
    NSDictionary *properties = [NSDictionary dictionaryWithObjectsAndKeys:
                                readingFindingDelegate, @"delegate",
                                [NSThread currentThread], @"callbackThread",
                                book, @"book", 
                                [NSNumber numberWithBool:isPrivate], kReadmillAPIReadingIsPrivateKey,
								[NSNumber numberWithInteger:readingState], kReadmillAPIReadingStateKey,
                                nil];
    
    [self performSelectorInBackground:@selector(createReadingWithProperties:)
                           withObject:properties];
}

-(void)createReadingWithProperties:(NSDictionary *)properties {
    
    [self retain];
    
    NSAutoreleasePool *pool;
    pool = [[NSAutoreleasePool alloc] init];
    
    NSThread *callbackThread = [properties valueForKey:@"callbackThread"];
    id <ReadmillReadingFindingDelegate> readingFindingDelegate = [properties valueForKey:@"delegate"];
    ReadmillBook *book = [properties valueForKey:@"book"];
    BOOL isPrivate = [[properties valueForKey:kReadmillAPIReadingIsPrivateKey] boolValue];
	ReadmillReadingState readingState = [[properties valueForKey:kReadmillAPIReadingStateKey] integerValue];
    
    NSError *error = nil;
    NSDictionary *readingDict = [[self apiWrapper] createReadingWithBookId:[book bookId]
                                                               state:readingState
                                                             private:isPrivate
                                                               error:&error];
    
    if (error == nil && readingFindingDelegate != nil && readingDict == nil) {
        
        NSInvocation *noReadingsInvocation = [NSInvocation invocationWithMethodSignature:
                                           [(NSObject *)readingFindingDelegate
                                            methodSignatureForSelector:@selector(readmillUser:foundNoReadingsForBook:)]];
        
        [noReadingsInvocation setSelector:@selector(readmillUser:foundNoReadingsForBook:)];
        
        [noReadingsInvocation setArgument:&self atIndex:2];
        [noReadingsInvocation setArgument:&book atIndex:3];
        
        [noReadingsInvocation performSelector:@selector(invokeWithTarget:)
                                  onThread:callbackThread
                                withObject:readingFindingDelegate
                             waitUntilDone:YES]; 
        
    } else if (error == nil && readingFindingDelegate != nil && readingDict != nil) {
        
        NSInvocation *successInvocation = [NSInvocation invocationWithMethodSignature:
                                           [(NSObject *)readingFindingDelegate
                                            methodSignatureForSelector:@selector(readmillUser:didFindReadings:forBook:)]];
        
        [successInvocation setSelector:@selector(readmillUser:didFindReadings:forBook:)];
        
        ReadmillReading *reading = [[[ReadmillReading alloc] initWithAPIDictionary:readingDict
                                                               apiWrapper:[self apiWrapper]] autorelease];
        
        NSArray *readingArray = [NSArray arrayWithObject:reading];
        
        [successInvocation setArgument:&self atIndex:2];
        [successInvocation setArgument:&readingArray atIndex:3];
        [successInvocation setArgument:&book atIndex:4];
        
        [successInvocation performSelector:@selector(invokeWithTarget:)
                                  onThread:callbackThread
                                withObject:readingFindingDelegate
                             waitUntilDone:YES]; 
        
    } else if (error != nil && readingFindingDelegate != nil) {
        
        NSInvocation *failedInvocation = [NSInvocation invocationWithMethodSignature:
                                          [(NSObject *)readingFindingDelegate 
                                           methodSignatureForSelector:@selector(readmillUser:failedToFindReadingForBook:withError:)]];
        
        [failedInvocation setSelector:@selector(readmillUser:failedToFindBooksWithError:)];
        
        [failedInvocation setArgument:&self atIndex:2];
        [failedInvocation setArgument:&book atIndex:3];
        [failedInvocation setArgument:&error atIndex:4];
        
        [failedInvocation performSelector:@selector(invokeWithTarget:)
                                 onThread:callbackThread
                               withObject:readingFindingDelegate
                            waitUntilDone:YES]; 
    }
    
    [pool drain];
    
    [self release];
}

@end
