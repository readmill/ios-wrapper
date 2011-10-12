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
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"YYYY'-'MM'-'dd'T'HH':'mm':'ss'Z'"];
        [self setDatePublished:[formatter dateFromString:[cleanedDict valueForKey:kReadmillAPIBookDatePublishedKey]]];
        [formatter release];
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

-(void)encodeWithCoder:(NSCoder *)encoder {	
    
    [encoder encodeObject:[self title] forKey:@"title"];
    [encoder encodeObject:[self coverImageURL] forKey:@"coverImageURL"];
    [encoder encodeObject:[self metaDataURL] forKey:@"metaDataURL"];
    [encoder encodeObject:[self permalinkURL] forKey:@"permalinkURL"];
    [encoder encodeObject:[self author] forKey:@"author"];
    [encoder encodeObject:[self summary] forKey:@"summary"];
    [encoder encodeObject:[self isbn] forKey:@"isbn"];
    [encoder encodeObject:[self language] forKey:@"language"];
    [encoder encodeObject:[NSNumber numberWithInt:[self bookId]] forKey:@"bookId"];
    [encoder encodeObject:[NSNumber numberWithInt:[self rootEditionId]] forKey:@"rootEditionId"];
    [encoder encodeObject:[self datePublished] forKey:@"datePublished"];
}

-(id)initWithCoder:(NSCoder *)decoder {
    
    if ((self = [super init])) { 
        [self setTitle:[decoder decodeObjectForKey:@"title"]];
        [self setCoverImageURL:[decoder decodeObjectForKey:@"coverImageURL"]];
        [self setMetaDataURL:[decoder decodeObjectForKey:@"metaDataURL"]];
        [self setPermalinkURL:[decoder decodeObjectForKey:@"permalinkURL"]];
        [self setAuthor:[decoder decodeObjectForKey:@"author"]];
        [self setSummary:[decoder decodeObjectForKey:@"summary"]];
        [self setLanguage:[decoder decodeObjectForKey:@"language"]];
        [self setIsbn:[decoder decodeObjectForKey:@"isbn"]];
        [self setBookId:[[decoder decodeObjectForKey:@"bookId"] intValue]];
        [self setRootEditionId:[[decoder decodeObjectForKey:@"rootEditionId"] intValue]];
        [self setDatePublished:[decoder decodeObjectForKey:@"datePublished"]];
    }
    return self;
}

@end
