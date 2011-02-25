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
#import "ReadmillRead.h"

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
        [authenticationDelegate readmillAuthenticationDidFailWithError:[NSError errorWithDomain:kReadmillErrorDomain
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
        [authenticationDelegate readmillAuthenticationDidFailWithError:[NSError errorWithDomain:kReadmillErrorDomain
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
                                isbn, @"isbn", 
                                title, @"title",
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
                                title, @"title",
                                isbn, @"isbn", 
                                author, @"author",
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
    
    NSString *isbn = [properties valueForKey:@"isbn"];
    NSString *title = [properties valueForKey:@"title"];
    NSString *author = [properties valueForKey:@"author"];

    BOOL createIfNotFound = [[properties valueForKey:@"createIfNotFound"] boolValue];


    // Search by ISBN
    if ([isbn length] > 0) {
        bookDicts = [[self apiWrapper] booksMatchingISBN:isbn
                                                   error:&error];
    } 
    
    // Search by title
    if ([title length] > 0 && [bookDicts count] == 0 && error == nil) {
        bookDicts = [[self apiWrapper] booksMatchingTitle:title error:&error];
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
                                isbn, @"isbn", 
                                title, @"title",
                                author, @"author",
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
    NSDictionary *bookDict = [[self apiWrapper] addBookWithTitle:[properties valueForKey:@"title"]
                                                          author:[properties valueForKey:@"author"]
                                                            isbn:[properties valueForKey:@"isbn"]
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

-(void)findReadForBook:(ReadmillBook *)book delegate:(id <ReadmillReadFindingDelegate>)readFindingDelegate {
    
    NSDictionary *properties = [NSDictionary dictionaryWithObjectsAndKeys:
                                readFindingDelegate, @"delegate",
                                [NSThread currentThread], @"callbackThread",
                                book, @"book", 
                                nil];
    
    [self performSelectorInBackground:@selector(findReadWithProperties:)
                           withObject:properties];
    
}

-(void)findOrCreateReadForBook:(ReadmillBook *)book state:(ReadmillReadState)readState createdReadIsPrivate:(BOOL)isPrivate delegate:(id <ReadmillReadFindingDelegate>)readFindingDelegate {
    
    NSDictionary *properties = [NSDictionary dictionaryWithObjectsAndKeys:
                                readFindingDelegate, @"delegate",
                                [NSThread currentThread], @"callbackThread",
                                book, @"book", 
                                [NSNumber numberWithBool:YES], @"createIfNotFound",
								[NSNumber numberWithInteger:readState], @"state",
                                [NSNumber numberWithBool:isPrivate], @"isPrivate",
                                nil];
    
    [self performSelectorInBackground:@selector(findReadWithProperties:)
                           withObject:properties];
}

-(void)findReadWithProperties:(NSDictionary *)properties {
    [self retain];
    
    NSAutoreleasePool *pool;
    pool = [[NSAutoreleasePool alloc] init];
    
    NSThread *callbackThread = [properties valueForKey:@"callbackThread"];
    id <ReadmillReadFindingDelegate> readFindingDelegate = [properties valueForKey:@"delegate"];
    ReadmillBook *book = [properties valueForKey:@"book"];
    BOOL createIfNotFound = [[properties valueForKey:@"createIfNotFound"] boolValue];
    BOOL isPrivate = [[properties valueForKey:@"isPrivate"] boolValue];
	ReadmillReadState readState = [[properties valueForKey:@"state"] integerValue];
    
    NSError *error = nil;
    NSMutableArray *matchingReads = [NSMutableArray array];
    
    NSArray *readsForUser = [[self apiWrapper] publicReadsForUserWithId:[self userId] error:&error];
    
    if (error == nil) {
        for (NSDictionary *read in readsForUser) {
            if ([[[read valueForKey:kReadmillAPIReadBookKey]
                  valueForKey:kReadmillAPIBookIdKey] unsignedIntegerValue] == [book bookId]) {
                
                [matchingReads addObject:read];
            }
        }
    }
    if ([matchingReads count] == 0 && createIfNotFound == YES) {
		
        NSDictionary *readDict = [[self apiWrapper] createReadWithBookId:[book bookId]
                                                                   state:readState
                                                                 private:isPrivate
                                                                   error:&error];
        if (readDict != nil) {
            [matchingReads addObject:readDict];
        }
    }
    
    if (error == nil && readFindingDelegate != nil && [matchingReads count] == 0) {
        
        NSInvocation *noReadsInvocation = [NSInvocation invocationWithMethodSignature:
                                           [(NSObject *)readFindingDelegate
                                            methodSignatureForSelector:@selector(readmillUser:foundNoReadsForBook:)]];
        
        [noReadsInvocation setSelector:@selector(readmillUser:foundNoReadsForBook:)];
        
        [noReadsInvocation setArgument:&self atIndex:2];
        [noReadsInvocation setArgument:&book atIndex:3];
        
        [noReadsInvocation performSelector:@selector(invokeWithTarget:)
                                  onThread:callbackThread
                                withObject:readFindingDelegate
                             waitUntilDone:YES]; 
        
    } else if (error == nil && readFindingDelegate != nil && [matchingReads count] > 0) {
        
        NSMutableArray *mutableReads = [NSMutableArray arrayWithCapacity:[matchingReads count]];
        
        for (NSDictionary *dict in matchingReads) {
            ReadmillRead *read = [[[ReadmillRead alloc] initWithAPIDictionary:dict apiWrapper:[self apiWrapper]] autorelease];
            [mutableReads addObject:read];
        }
        
        NSArray *reads = [NSArray arrayWithArray:mutableReads];
        
        NSInvocation *successInvocation = [NSInvocation invocationWithMethodSignature:
                                           [(NSObject *)readFindingDelegate
                                            methodSignatureForSelector:@selector(readmillUser:didFindReads:forBook:)]];
        
        [successInvocation setSelector:@selector(readmillUser:didFindReads:forBook:)];
        
        [successInvocation setArgument:&self atIndex:2];
        [successInvocation setArgument:&reads atIndex:3];
        [successInvocation setArgument:&book atIndex:4];
        
        [successInvocation performSelector:@selector(invokeWithTarget:)
                                  onThread:callbackThread
                                withObject:readFindingDelegate
                             waitUntilDone:YES]; 
        
    } else if (error != nil && readFindingDelegate != nil) {
        
        NSInvocation *failedInvocation = [NSInvocation invocationWithMethodSignature:
                                          [(NSObject *)readFindingDelegate 
                                           methodSignatureForSelector:@selector(readmillUser:failedToFindReadForBook:withError:)]];
        
        [failedInvocation setSelector:@selector(readmillUser:failedToFindBooksWithError:)];
        
        [failedInvocation setArgument:&self atIndex:2];
        [failedInvocation setArgument:&book atIndex:3];
        [failedInvocation setArgument:&error atIndex:4];
        
        [failedInvocation performSelector:@selector(invokeWithTarget:)
                                 onThread:callbackThread
                               withObject:readFindingDelegate
                            waitUntilDone:YES]; 
    }

    
    [pool drain];
    
    [self release];
    
}


-(void)createReadForBook:(ReadmillBook *)book state:(ReadmillReadState)readState isPrivate:(BOOL)isPrivate delegate:(id <ReadmillReadFindingDelegate>)readFindingDelegate {
    
    NSDictionary *properties = [NSDictionary dictionaryWithObjectsAndKeys:
                                readFindingDelegate, @"delegate",
                                [NSThread currentThread], @"callbackThread",
                                book, @"book", 
                                [NSNumber numberWithBool:isPrivate], @"isPrivate",
								[NSNumber numberWithInteger:readState], @"state",
                                nil];
    
    [self performSelectorInBackground:@selector(createReadWithProperties:)
                           withObject:properties];
}

-(void)createReadWithProperties:(NSDictionary *)properties {
    
    [self retain];
    
    NSAutoreleasePool *pool;
    pool = [[NSAutoreleasePool alloc] init];
    
    NSThread *callbackThread = [properties valueForKey:@"callbackThread"];
    id <ReadmillReadFindingDelegate> readFindingDelegate = [properties valueForKey:@"delegate"];
    ReadmillBook *book = [properties valueForKey:@"book"];
    BOOL isPrivate = [[properties valueForKey:@"isPrivate"] boolValue];
	ReadmillReadState readState = [[properties valueForKey:@"state"] integerValue];
    
    NSError *error = nil;
    NSDictionary *readDict = [[self apiWrapper] createReadWithBookId:[book bookId]
                                                               state:readState
                                                             private:isPrivate
                                                               error:&error];
    
    if (error == nil && readFindingDelegate != nil && readDict == nil) {
        
        NSInvocation *noReadsInvocation = [NSInvocation invocationWithMethodSignature:
                                           [(NSObject *)readFindingDelegate
                                            methodSignatureForSelector:@selector(readmillUser:foundNoReadsForBook:)]];
        
        [noReadsInvocation setSelector:@selector(readmillUser:foundNoReadsForBook:)];
        
        [noReadsInvocation setArgument:&self atIndex:2];
        [noReadsInvocation setArgument:&book atIndex:3];
        
        [noReadsInvocation performSelector:@selector(invokeWithTarget:)
                                  onThread:callbackThread
                                withObject:readFindingDelegate
                             waitUntilDone:YES]; 
        
    } else if (error == nil && readFindingDelegate != nil && readDict != nil) {
        
        NSInvocation *successInvocation = [NSInvocation invocationWithMethodSignature:
                                           [(NSObject *)readFindingDelegate
                                            methodSignatureForSelector:@selector(readmillUser:didFindReads:forBook:)]];
        
        [successInvocation setSelector:@selector(readmillUser:didFindReads:forBook:)];
        
        ReadmillRead *read = [[[ReadmillRead alloc] initWithAPIDictionary:readDict
                                                               apiWrapper:[self apiWrapper]] autorelease];
        
        NSArray *readArray = [NSArray arrayWithObject:read];
        
        [successInvocation setArgument:&self atIndex:2];
        [successInvocation setArgument:&readArray atIndex:3];
        [successInvocation setArgument:&book atIndex:4];
        
        [successInvocation performSelector:@selector(invokeWithTarget:)
                                  onThread:callbackThread
                                withObject:readFindingDelegate
                             waitUntilDone:YES]; 
        
    } else if (error != nil && readFindingDelegate != nil) {
        
        NSInvocation *failedInvocation = [NSInvocation invocationWithMethodSignature:
                                          [(NSObject *)readFindingDelegate 
                                           methodSignatureForSelector:@selector(readmillUser:failedToFindReadForBook:withError:)]];
        
        [failedInvocation setSelector:@selector(readmillUser:failedToFindBooksWithError:)];
        
        [failedInvocation setArgument:&self atIndex:2];
        [failedInvocation setArgument:&book atIndex:3];
        [failedInvocation setArgument:&error atIndex:4];
        
        [failedInvocation performSelector:@selector(invokeWithTarget:)
                                 onThread:callbackThread
                               withObject:readFindingDelegate
                            waitUntilDone:YES]; 
    }
    
    [pool drain];
    
    [self release];
}

@end
