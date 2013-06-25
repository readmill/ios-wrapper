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
#import "NSDictionary+ReadmillAdditions.h"
#import "NSString+ReadmillAdditions.h"

@interface ReadmillBookAsset ()
@property (readwrite, nonatomic, copy) NSString *acquisitionType, *vendor;
@property (readwrite, nonatomic, retain) NSURL *uri;
@end

@implementation ReadmillBookAsset
- (id)initWithAssetJSON:(NSDictionary *)JSON
{
    if (self = [super init]) {
        NSDictionary *assetJSON = [JSON valueForKey:@"asset"];

        _acquisitionType = [[assetJSON valueForKey:@"acquisition_type"] copy];
        _vendor = [[assetJSON valueForKey:@"vendor"] copy];
        NSString *uriString = [assetJSON valueForKey:@"uri"];
        _uri = [[NSURL URLWithString:uriString] retain];
    }
    return self;
}

- (void)dealloc
{
    [_uri release];
    [_vendor release];
    [_acquisitionType release];
    [super dealloc];
}

@end


@interface ReadmillBook ()

@property (readwrite, copy) NSString *author;
@property (readwrite, copy) NSString *identifier;
@property (readwrite, copy) NSString *language;
@property (readwrite, copy) NSString *summary;
@property (readwrite, copy) NSString *title;

@property (readwrite, copy) NSURL *coverImageURL;
@property (readwrite, copy) NSURL *metaDataURL;
@property (readwrite, copy) NSURL *permalinkURL;

@property (readwrite) ReadmillBookId bookId;
@property (readwrite) ReadmillBookId rootEditionId;

@property (readwrite) BOOL featured;
@property (readwrite) ReadmillPriceSegment priceSegment;
@property (readwrite) NSUInteger readingsCount;
@property (readwrite) NSUInteger activeAndFinishedReadingsCount;
@property (readwrite) NSUInteger recommendedReadingsCount;

@property (readwrite) NSUInteger averageDuration;

@property (readwrite, copy) NSDate *datePublished;

@property (nonatomic, readwrite, copy) NSArray *assets;

@end

@implementation ReadmillBook


- (id)init 
{
    return [self initWithAPIDictionary:nil];
}

- (id)initWithAPIDictionary:(NSDictionary *)apiDict 
{
    if ((self = [super init])) {
        
        // Clean out null values from JSON
        [self updateWithAPIDictionary:apiDict];
    }
    return self;
}

- (void)updateWithAPIDictionary:(NSDictionary *)apiDictionary
{
    NSDictionary *bookDictionary = [apiDictionary valueForKey:kReadmillAPIBookKey];
    NSDictionary *cleanedDict = [bookDictionary dictionaryByRemovingNullValues];    

    [self setAuthor:[cleanedDict valueForKey:kReadmillAPIBookAuthorKey]];
    [self setLanguage:[cleanedDict valueForKey:kReadmillAPIBookLanguageKey]];
    [self setSummary:[cleanedDict valueForKey:kReadmillAPIBookSummaryKey]];
    [self setTitle:[cleanedDict valueForKey:kReadmillAPIBookTitleKey]];
    [self setIdentifier:[cleanedDict valueForKey:kReadmillAPIBookIdentifierKey]];
    
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
    
    NSString *datePublishedString = [cleanedDict valueForKey:kReadmillAPIBookDatePublishedKey];
    [self setDatePublished:[datePublishedString dateWithRFC3339Formatting]];

    [self setFeatured:[[cleanedDict valueForKey:kReadmillAPIBookFeaturedKey] boolValue]];
    [self setReadingsCount:[[cleanedDict valueForKey:kReadmillAPIBookReadingsCountKey] unsignedIntegerValue]];
    [self setActiveAndFinishedReadingsCount:[[cleanedDict valueForKey:kReadmillAPIBookActiveAndFinishedReadingsCountKey] unsignedIntegerValue]];
    [self setRecommendedReadingsCount:[[cleanedDict valueForKey:kReadmillAPIBookRecommendedReadingsCountKey] unsignedIntegerValue]];

    [self setAverageDuration:[[cleanedDict valueForKey:kReadmillAPIBookAverageDurationKey] unsignedIntegerValue]];
    
    NSString *priceSegmentString = [cleanedDict valueForKey:kReadmillAPIBookPriceSegmentKey];
    [self setPriceSegment:[[self class] priceSegmentFromPriceSegmentString:priceSegmentString]];

    NSArray *assets = [cleanedDict valueForKey:kReadmillAPIBookAssetsKey];
    assets = [assets valueForKey:@"items"];
    NSMutableArray *m_assets = [NSMutableArray array];
    for (NSDictionary *assetJSON in assets) {
        ReadmillBookAsset *asset = [[ReadmillBookAsset alloc] initWithAssetJSON:assetJSON];
        [m_assets addObject:asset];
        [asset release];
    }
    self.assets = m_assets;
}

- (NSString *)averageReadingTimeDescription
{
    NSUInteger averageDuration = self.averageDuration;
    NSString *string = nil;
    
    if (NSLocationInRange(averageDuration, NSMakeRange(1, 1800))) {
        string = NSLocalizedString(@"30 minutes", nil);
    } else if (NSLocationInRange(averageDuration, NSMakeRange(1800, 3600))) {
        string = NSLocalizedString(@"1 hour", nil);
    } else if (averageDuration > 0) {
        NSUInteger lowerBoundsHours = (NSUInteger)(averageDuration/3600);
        string = [NSString stringWithFormat:NSLocalizedString(@"%d–%d hours", nil), lowerBoundsHours, lowerBoundsHours+1];
    }
    return string;
}

-(NSString *)description 
{    
    return [NSString stringWithFormat:@"%@ id %d: %@ by %@ [ISBN %@]", [super description], [self bookId], [self title], [self author], [self identifier]];
}

- (void)dealloc 
{
    [self setAuthor:nil];
    [self setIdentifier:nil];
    [self setLanguage:nil];
    [self setSummary:nil];
    [self setTitle:nil];
    [self setCoverImageURL:nil];
    [self setMetaDataURL:nil];
    [self setPermalinkURL:nil];
    [self setDatePublished:nil];
    [self setAssets:nil];

    [super dealloc];
}

+ (ReadmillPriceSegment)priceSegmentFromPriceSegmentString:(NSString *)priceSegmentString
{
    ReadmillPriceSegment priceSegment = ReadmillPriceSegmentUnknown;
    if (priceSegmentString == kReadmillAPIBookPriceSegmentFree) {
        priceSegmentString = ReadmillPriceSegmentFree;
    }
    return priceSegment;
}

#pragma mark -
#pragma mark NSCoding

-(void)encodeWithCoder:(NSCoder *)encoder 
{	    
    [encoder encodeObject:[self title] forKey:@"title"];
    [encoder encodeObject:[self coverImageURL] forKey:@"coverImageURL"];
    [encoder encodeObject:[self metaDataURL] forKey:@"metaDataURL"];
    [encoder encodeObject:[self permalinkURL] forKey:@"permalinkURL"];
    [encoder encodeObject:[self author] forKey:@"author"];
    [encoder encodeObject:[self summary] forKey:@"summary"];
    [encoder encodeObject:[self identifier] forKey:@"identifier"];
    [encoder encodeObject:[self language] forKey:@"language"];
    [encoder encodeObject:[NSNumber numberWithInt:[self bookId]] forKey:@"bookId"];
    [encoder encodeObject:[NSNumber numberWithInt:[self rootEditionId]] forKey:@"rootEditionId"];
    [encoder encodeObject:[self datePublished] forKey:@"datePublished"];
}

- (id)initWithCoder:(NSCoder *)decoder 
{    
    if ((self = [super init])) { 
        [self setTitle:[decoder decodeObjectForKey:@"title"]];
        [self setCoverImageURL:[decoder decodeObjectForKey:@"coverImageURL"]];
        [self setMetaDataURL:[decoder decodeObjectForKey:@"metaDataURL"]];
        [self setPermalinkURL:[decoder decodeObjectForKey:@"permalinkURL"]];
        [self setAuthor:[decoder decodeObjectForKey:@"author"]];
        [self setSummary:[decoder decodeObjectForKey:@"summary"]];
        [self setLanguage:[decoder decodeObjectForKey:@"language"]];
        [self setIdentifier:[decoder decodeObjectForKey:@"identifier"]];
        [self setBookId:[[decoder decodeObjectForKey:@"bookId"] intValue]];
        [self setRootEditionId:[[decoder decodeObjectForKey:@"rootEditionId"] intValue]];
        [self setDatePublished:[decoder decodeObjectForKey:@"datePublished"]];
    }
    return self;
}

@end
