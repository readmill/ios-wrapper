//
//  ReadmillBook.m
//  Readmill Framework
//
//  Created by Work on 12/01/2011.
//  Copyright 2011 KennettNet Software Limited. All rights reserved.
//

#import "ReadmillBook.h"
#import "ReadmillDictionaryExtensions.h"

@interface ReadmillBook ()

@property (readwrite, copy) NSString *author;
@property (readwrite, copy) NSString *isbn;
@property (readwrite, copy) NSString *language;
@property (readwrite, copy) NSString *summary;
@property (readwrite, copy) NSString *title;

@property (readwrite, copy) NSURL *coverImageURL;
@property (readwrite, copy) NSURL *metaDataURL;
@property (readwrite, copy) NSURL *permalinkURL;

@property (readwrite) ReadmillBookId bookId;
@property (readwrite) ReadmillBookId rootEditionId;

@property (readwrite, copy) NSDate *datePublished;

@end

@implementation ReadmillBook


- (id)init {
    return [self initWithAPIDictionary:nil];
}

-(id)initWithAPIDictionary:(NSDictionary *)apiDict {
    
    if ((self = [super init])) {
        
        // Clean out null values from JSON
        
        NSDictionary *cleanedDict = [apiDict dictionaryByRemovingNullValues];
        
        [self setAuthor:[cleanedDict valueForKey:kReadmillAPIBookAuthorKey]];
        [self setLanguage:[cleanedDict valueForKey:kReadmillAPIBookLanguageKey]];
        [self setSummary:[cleanedDict valueForKey:kReadmillAPIBookSummaryKey]];
        [self setTitle:[cleanedDict valueForKey:kReadmillAPIBookTitleKey]];
        [self setIsbn:[cleanedDict valueForKey:kReadmillAPIBookISBNKey]];
        
        if ([cleanedDict valueForKey:kReadmillAPIBookCoverImageURLKey]) {
            [self setCoverImageURL:[NSURL URLWithString:[cleanedDict valueForKey:kReadmillAPIBookCoverImageURLKey]]];
        }
        
        if ([cleanedDict valueForKey:kReadmillAPIBookMetaDataURLKey]) {
            [self setMetaDataURL:[NSURL URLWithString:[cleanedDict valueForKey:kReadmillAPIBookMetaDataURLKey]]];
        }
        
        if ([cleanedDict valueForKey:kReadmillAPIBookPermalinkURLKey]) {
            [self setPermalinkURL:[NSURL URLWithString:[cleanedDict valueForKey:kReadmillAPIBookPermalinkURLKey]]];
        }
        
        [self setBookId:[[cleanedDict valueForKey:kReadmillAPIBookIdKey] unsignedIntegerValue]];
        [self setRootEditionId:[[cleanedDict valueForKey:kReadmillAPIBookRootEditionIdKey] unsignedIntegerValue]];
        
        [self setDatePublished:[[[NSDate alloc] initWithString:[cleanedDict valueForKey:kReadmillAPIBookDatePublishedKey]] autorelease]];
        
    }
    return self;
}

-(NSString *)description {
    
    return [NSString stringWithFormat:@"%@ id %d: %@ by %@ [ISBN %@]", [super description], [self bookId], [self title], [self author], [self isbn]];
}

@synthesize author;
@synthesize isbn;
@synthesize language;
@synthesize summary;
@synthesize title;

@synthesize coverImageURL;
@synthesize metaDataURL;
@synthesize permalinkURL;

@synthesize bookId;
@synthesize rootEditionId;

@synthesize datePublished;

- (void)dealloc {
    // Clean-up code here.
    
    [self setAuthor:nil];
    [self setIsbn:nil];
    [self setLanguage:nil];
    [self setSummary:nil];
    [self setTitle:nil];
    [self setCoverImageURL:nil];
    [self setMetaDataURL:nil];
    [self setPermalinkURL:nil];
    [self setDatePublished:nil];
    
    [super dealloc];
}

@end
