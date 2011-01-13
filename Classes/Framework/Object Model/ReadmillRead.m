//
//  ReadmillRead.m
//  Readmill Framework
//
//  Created by Work on 13/01/2011.
//  Copyright 2011 KennettNet Software Limited. All rights reserved.
//

#import "ReadmillRead.h"
#import "ReadmillDictionaryExtensions.h"

@interface ReadmillRead ()

@property (readwrite, copy) NSDate *dateAbandoned;
@property (readwrite, copy) NSDate *dateCreated;
@property (readwrite, copy) NSDate *dateFinished;
@property (readwrite, copy) NSDate *dateModified;
@property (readwrite, copy) NSDate *dateStarted;

@property (readwrite, copy) NSString *closingRemark;

@property (readwrite) BOOL isPrivate;

@property (readwrite) ReadmillReadState state;

@property (readwrite) ReadmillBookId bookId;
@property (readwrite) ReadmillUserId userId;
@property (readwrite) ReadmillReadId readId;

@end

@implementation ReadmillRead

- (id)init {
    return [self initWithAPIDictionary:nil];
}

-(id)initWithAPIDictionary:(NSDictionary *)apiDict {
    if ((self = [super init])) {
        // Initialization code here.
        
        NSDictionary *cleanedDict = [apiDict dictionaryByRemovingNullValues];
        
        [self setDateAbandoned:[NSDate dateWithString:[cleanedDict valueForKey:kReadmillAPIReadDateAbandonedKey]]];
        [self setDateCreated:[NSDate dateWithString:[cleanedDict valueForKey:kReadmillAPIReadDateCreatedKey]]];
        [self setDateFinished:[NSDate dateWithString:[cleanedDict valueForKey:kReadmillAPIReadDateFinishedKey]]];
        [self setDateModified:[NSDate dateWithString:[cleanedDict valueForKey:kReadmillAPIReadDateModifiedKey]]];
        [self setDateStarted:[NSDate dateWithString:[cleanedDict valueForKey:kReadmillAPIReadDateStarted]]];
        
        [self setClosingRemark:[cleanedDict valueForKey:kReadmillAPIReadClosingRemarkKey]];
        
        [self setIsPrivate:([[cleanedDict valueForKey:kReadmillAPIReadIsPrivateKey] unsignedIntegerValue] == 1)];
        
        [self setState:[[cleanedDict valueForKey:kReadmillAPIReadStateKey] unsignedIntegerValue]];
        
        [self setUserId:[[[cleanedDict valueForKey:kReadmillAPIReadUserKey] valueForKey:kReadmillAPIUserIdKey] unsignedIntegerValue]];
        [self setBookId:[[[cleanedDict valueForKey:kReadmillAPIReadBookKey] valueForKey:kReadmillAPIBookIdKey] unsignedIntegerValue]];
        [self setReadId:[[cleanedDict valueForKey:kReadmillAPIReadIdKey] unsignedIntegerValue]];
        
    }
    
    return self;
}

-(NSString *)description {
    return [NSString stringWithFormat:@"%@: Read of book %d by %d", [super description], [self bookId], [self userId]];
}

@synthesize dateAbandoned;
@synthesize dateCreated;
@synthesize dateFinished;
@synthesize dateModified;
@synthesize dateStarted;

@synthesize closingRemark;
@synthesize isPrivate;
@synthesize state;

@synthesize bookId;
@synthesize userId;
@synthesize readId;

- (void)dealloc {
    // Clean-up code here.
    
    [self setDateAbandoned:nil];
    [self setDateCreated:nil];
    [self setDateFinished:nil];
    [self setDateModified:nil];
    [self setDateStarted:nil];
    [self setClosingRemark:nil];
    
    [super dealloc];
}

@end
