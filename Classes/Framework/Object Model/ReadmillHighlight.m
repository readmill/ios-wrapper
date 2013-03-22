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

#import "ReadmillHighlight.h"
#import "NSString+ReadmillAdditions.h"
#import "NSDictionary+ReadmillAdditions.h"

@interface ReadmillHighlight ()

@property(readwrite, nonatomic) ReadmillHighlightId highlightId;
@property(readwrite, nonatomic) float position;
@property(readwrite, nonatomic) NSString *content;
@property(readwrite, nonatomic) NSDate *highlightedAt;
@property(readwrite, nonatomic) NSURL *permalinkURI;
@property(readwrite, nonatomic) ReadmillUserId userId;
@property(readwrite, nonatomic) NSUInteger commentsCount;
@property(readwrite, nonatomic) NSUInteger likesCount;
@property(readwrite, nonatomic) ReadmillReadingId readingId;
@property(readwrite, nonatomic) ReadmillAPIWrapper *apiWrapper;

@end

@implementation ReadmillHighlight

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
    return [NSString stringWithFormat:@"%@ id %d: Highlight by %d from reading %d", [super description], [self highlightId], [self readingId], [self userId]];
}

- (void)updateWithAPIDictionary:(NSDictionary *)apiDict
{
    NSDictionary *cleanedDict = [apiDict dictionaryByRemovingNullValues];
    cleanedDict = [cleanedDict valueForKey:kReadmillAPIHighlightKey];
    
    [self setHighlightId:[[cleanedDict valueForKey:kReadmillAPIHighlightIdKey] unsignedIntegerValue]];
    [self setPosition:[[cleanedDict valueForKey:kReadmillAPIHighlightPositionKey] floatValue]];
    [self setContent:[cleanedDict valueForKey:kReadmillAPIHighlightContentKey]];

    NSString *highlightedAtString = [cleanedDict valueForKey:kReadmillAPIHighlightHighlightedAtKey];
    [self setHighlightedAt:[highlightedAtString dateWithRFC3339Formatting]];

    if ([cleanedDict valueForKey:kReadmillAPIHighlightPermalinkURLKey]) {
        [self setPermalinkURI:[NSURL URLWithString:[cleanedDict valueForKey:kReadmillAPIHighlightPermalinkURLKey]]];
    }
    
    [self setUserId:[[cleanedDict valueForKeyPath:@"user.id"] unsignedIntegerValue]];
    [self setCommentsCount:[[cleanedDict valueForKey:kReadmillAPIHighlightCommentsCountKey] unsignedIntegerValue]];
    [self setLikesCount:[[cleanedDict valueForKey:kReadmillAPIHighlightLikesCountKey] unsignedIntegerValue]];
    [self setReadingId:[[cleanedDict valueForKeyPath:@"reading.id"] unsignedIntegerValue]];
}

- (void)dealloc
{
    // Clean-up code.
    [self setApiWrapper:nil];
    [self setContent:nil];
    [self setHighlightedAt:nil];
    [self setPermalinkURI:nil];
    [super dealloc];
}

@end
