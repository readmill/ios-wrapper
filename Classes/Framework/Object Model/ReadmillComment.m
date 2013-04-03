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

#import "ReadmillComment.h"
#import "ReadmillUser.h"
#import "NSDictionary+ReadmillAdditions.h"
#import "NSString+ReadmillAdditions.h"

@interface ReadmillComment ()

@property(readwrite) ReadmillCommentId commentId;
@property(readwrite, copy) NSString *content;
@property(readwrite, copy) NSDate *postedAt;
@property(readwrite) ReadmillReadingId readingId;
@property(readwrite) ReadmillHighlightId highlightId;
@property(readwrite, retain) ReadmillUser *user;
@property(readwrite, retain) ReadmillAPIWrapper *apiWrapper;

@end

@implementation ReadmillComment

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
    return [NSString stringWithFormat:@"%@ id %d: Comment by %d for highlight %d in reading %d", [super description], [self commentId], [[self user] userId], [self highlightId], [self readingId]];
}

- (void)updateWithAPIDictionary:(NSDictionary *)apiDict
{
    NSDictionary *cleanedDict = [apiDict dictionaryByRemovingNullValues];
    cleanedDict = [cleanedDict valueForKey:kReadmillAPICommentKey];
    
    [self setCommentId:[[cleanedDict valueForKey:kReadmillAPICommentIdKey] unsignedIntegerValue]];
    [self setContent:[cleanedDict valueForKey:kReadmillAPICommentContentKey]];
    
    NSString *postedAtString = [cleanedDict valueForKey:kReadmillAPICommentPostedAtKey];
    [self setPostedAt:[postedAtString dateWithRFC3339Formatting]];
    
    [self setReadingId:[[cleanedDict valueForKeyPath:@"reading.id"] unsignedIntegerValue]];
    [self setHighlightId:[[cleanedDict valueForKeyPath:@"highlight.id"] unsignedIntegerValue]];
    
    [self setUser:[[[ReadmillUser alloc] initWithAPIDictionary:cleanedDict apiWrapper:self.apiWrapper] autorelease]];
}

- (void)dealloc
{
    // Clean-up code.
    [self setApiWrapper:nil];
    [self setContent:nil];
    [self setPostedAt:nil];
    [self setUser:nil];
    [super dealloc];
}

@end
