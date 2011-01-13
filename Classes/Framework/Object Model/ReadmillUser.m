//
//  ReadmillUser.m
//  Readmill Framework
//
//  Created by Work on 12/01/2011.
//  Copyright 2011 KennettNet Software Limited. All rights reserved.
//

#import "ReadmillUser.h"
#import "ReadmillDictionaryExtensions.h"
#import "Constants.h"

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

@end

@implementation ReadmillUser

- (id)init {
    return [self initWithAPIDictionary:nil];
}

-(id)initWithAPIDictionary:(NSDictionary *)apiDict {
    if ((self = [super init])) {
        // Initialization code here.
        
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
    
    return self;
}

-(NSString *)description {
    return [NSString stringWithFormat:@"%@: %@ (%@)", [super description], [self fullName], [self userName]];
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

@end
