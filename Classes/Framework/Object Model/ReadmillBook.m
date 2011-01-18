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

- (void)dealloc 
{
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

#pragma mark -
#pragma mark NSCoding

-(void)encodeWithCoder:(NSCoder *)encoder
{	
    [encoder encodeObject:title forKey:@"title"];
    [encoder encodeObject:coverImageURL forKey:@"coverImageURL"];
    [encoder encodeObject:metaDataURL forKey:@"metaDataURL"];
    [encoder encodeObject:permalinkURL forKey:@"permalinkURL"];
    [encoder encodeObject:author forKey:@"author"];
    [encoder encodeObject:summary forKey:@"summary"];
    [encoder encodeObject:isbn forKey:@"isbn"];
    [encoder encodeObject:language forKey:@"language"];
    [encoder encodeObject:[NSNumber numberWithInt:bookId] forKey:@"bookId"];
    [encoder encodeObject:[NSNumber numberWithInt:rootEditionId] forKey:@"rootEditionId"];
    [encoder encodeObject:datePublished forKey:@"datePublished"];
}

-(id)initWithCoder:(NSCoder *)decoder
{
    self.title = [decoder decodeObjectForKey:@"title"];
    self.coverImageURL = [decoder decodeObjectForKey:@"coverImageURL"];
    self.metaDataURL = [decoder decodeObjectForKey:@"metaDataURL"];
    self.permalinkURL = [decoder decodeObjectForKey:@"permalinkURL"];
    self.author = [decoder decodeObjectForKey:@"author"];
    self.summary = [decoder decodeObjectForKey:@"summary"];
    self.language = [decoder decodeObjectForKey:@"language"];
    self.isbn = [decoder decodeObjectForKey:@"isbn"];
    self.bookId = [[decoder decodeObjectForKey:@"bookId"] intValue];
    self.rootEditionId = [[decoder decodeObjectForKey:@"rootEditionId"] intValue];
    self.datePublished = [decoder decodeObjectForKey:@"datePublished"];
    return self;
}

@end
