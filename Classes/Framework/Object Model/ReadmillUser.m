//
//  ReadmillUser.m
//  Readmill Framework
//
//  Created by Work on 12/01/2011.
//  Copyright 2011 KennettNet Software Limited. All rights reserved.
//

#import "ReadmillUser.h"
#import "ReadmillDictionaryExtensions.h"

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
    
    [self performSelectorOnMainThread:@selector(attemptAuthenticationWithProperties:)
                           withObject:properties
                        waitUntilDone:NO];
    
}

-(void)verifyAuthentication:(id <ReadmillUserAuthenticationDelegate>)authenticationDelegate {
    
    NSDictionary *properties = [NSDictionary dictionaryWithObjectsAndKeys:
                                authenticationDelegate, @"delegate",
                                [NSThread currentThread], @"callbackThread",
                                nil];
    
    [self performSelectorOnMainThread:@selector(verifyAuthenticationWithProperties:)
                           withObject:properties
                        waitUntilDone:NO];

}


#pragma mark -
#pragma mark Threaded Methods

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


@end
