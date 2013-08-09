//
//  ReadmillClosingRemark.m
//  ReadmillAPI
//
//  Created by Tomaz Nedeljko on 8/8/13.
//  Copyright (c) 2013 Readmill Network LTD. All rights reserved.
//

#import "ReadmillClosingRemark.h"
#import "ReadmillUser.h"
#import "NSDictionary+ReadmillAdditions.h"
#import "NSString+ReadmillAdditions.h"

@interface ReadmillClosingRemark ()

@property(readwrite) ReadmillClosingRemarkId closingRemarkId;
@property(readwrite, copy) NSString *content;
@property(readwrite, copy) NSDate *createdAt;
@property(readwrite) NSUInteger likesCount;
@property(readwrite) NSUInteger commentsCount;
@property(readwrite) BOOL recommended;
@property(readwrite) ReadmillReadingId readingId;
@property(readwrite, retain) ReadmillUser *user;
@property(readwrite, retain) ReadmillAPIWrapper *apiWrapper;

@end

@implementation ReadmillClosingRemark

#pragma mark -
#pragma mark Initialization and Serialization

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

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ id %d: Closing remark by %d in reading %d", [super description], [self closingRemarkId], [[self user] userId], [self readingId]];
}

- (void)updateWithAPIDictionary:(NSDictionary *)apiDict
{
    NSDictionary *cleanedDict = [apiDict dictionaryByRemovingNullValues];
    cleanedDict = [cleanedDict valueForKey:kReadmillAPIClosingRemarkKey];
    
    [self setClosingRemarkId:[[cleanedDict valueForKey:kReadmillAPIClosingRemarkIdKey] unsignedIntegerValue]];
    [self setContent:[cleanedDict valueForKey:kReadmillAPIClosingRemarkContentKey]];
    [self setLikesCount:[[cleanedDict valueForKey:kReadmillAPIClosingRemarkLikesCountKey] unsignedIntegerValue]];
    [self setCommentsCount:[[cleanedDict valueForKey:kReadmillAPIClosingRemarkCommentsCountKey] unsignedIntegerValue]];
    [self setRecommended:[[cleanedDict valueForKey:kReadmillAPIClosingRemarkRecommendedKey] boolValue]];
    
    NSString *createdAtString = [cleanedDict valueForKey:kReadmillAPIClosingRemarkCreatedAtKey];
    [self setCreatedAt:[createdAtString dateWithRFC3339Formatting]];
    
    [self setReadingId:[[cleanedDict valueForKeyPath:@"reading.id"] unsignedIntegerValue]];
    
    [self setUser:[[[ReadmillUser alloc] initWithAPIDictionary:cleanedDict apiWrapper:self.apiWrapper] autorelease]];
}

- (void)dealloc
{
    // Clean-up code.
    [self setApiWrapper:nil];
    [self setContent:nil];
    [self setCreatedAt:nil];
    [self setUser:nil];
    [super dealloc];
}

@end
