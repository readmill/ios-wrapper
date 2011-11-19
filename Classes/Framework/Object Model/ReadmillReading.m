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

#import "ReadmillReading.h"
#import "ReadmillDictionaryExtensions.h"
#import "ReadmillStringExtensions.h"
#import "ReadmillUser.h"

@interface ReadmillReading ()

@property (readwrite, copy) NSDate *dateAbandoned;
@property (readwrite, copy) NSDate *dateCreated;
@property (readwrite, copy) NSDate *dateFinished;
@property (readwrite, copy) NSDate *dateModified;
@property (readwrite, copy) NSDate *dateStarted;

@property (readwrite) NSTimeInterval *estimatedTimeLeft;
@property (readwrite) NSTimeInterval *timeSpent;

@property (readwrite, copy) NSString *closingRemark;

@property (readwrite, copy) NSURL *permalinkURL;
@property (readwrite, copy) NSURL *uri;
@property (readwrite, copy) NSURL *commentsURI;
@property (readwrite, copy) NSURL *periodsURI;
@property (readwrite, copy) NSURL *locationsURI;
@property (readwrite, copy) NSURL *highlightsURI;

@property (readwrite) BOOL isPrivate;

@property (readwrite) ReadmillReadingState state;

@property (readwrite) ReadmillBookId bookId;
@property (readwrite) ReadmillUserId userId;
@property (readwrite) ReadmillReadingId readingId;

@property (readwrite) ReadmillReadingProgress progress;

@property (readwrite, retain) ReadmillUser *user;
@property (readwrite, retain) ReadmillAPIWrapper *apiWrapper;

@property (nonatomic, readwrite) NSUInteger highlightCount;

@end

@implementation ReadmillReading

- (id)init {
    return [self initWithAPIDictionary:nil apiWrapper:nil];
}

-(id)initWithAPIDictionary:(NSDictionary *)apiDict apiWrapper:(ReadmillAPIWrapper *)wrapper {
    if ((self = [super init])) {
        // Initialization code here.
        
        [self setApiWrapper:wrapper];
        [self updateWithAPIDictionary:apiDict];
    }
    
    return self;
}

-(void)updateWithAPIDictionary:(NSDictionary *)apiDict {
    
    NSDictionary *cleanedDict = [apiDict dictionaryByRemovingNullValues];
    
    NSDictionary *userDictionary = [apiDict objectForKey:kReadmillAPIReadingUserKey];
    if (userDictionary) {
        [self setUser:[[[ReadmillUser alloc] initWithAPIDictionary:userDictionary
                                                        apiWrapper:self.apiWrapper] autorelease]];
    }
    [self setDateAbandoned:[[cleanedDict objectForKey:kReadmillAPIReadingDateAbandonedKey] dateWithRFC3339Formatting]];
    [self setDateCreated:[[cleanedDict objectForKey:kReadmillAPIReadingDateCreatedKey] dateWithRFC3339Formatting]];
    [self setDateFinished:[[cleanedDict objectForKey:kReadmillAPIReadingDateFinishedKey] dateWithRFC3339Formatting]];
    [self setDateModified:[[cleanedDict objectForKey:kReadmillAPIReadingDateModifiedKey] dateWithRFC3339Formatting]];
    [self setDateStarted:[[cleanedDict objectForKey:kReadmillAPIReadingDateStartedKey] dateWithRFC3339Formatting]];
    [self setClosingRemark:[cleanedDict objectForKey:kReadmillAPIReadingClosingRemarkKey]];
    
    [self setIsPrivate:([[cleanedDict objectForKey:kReadmillAPIReadingIsPrivateKey] unsignedIntegerValue] == 1)];
    
    [self setState:[[cleanedDict objectForKey:kReadmillAPIReadingStateKey] unsignedIntegerValue]];
    
    if ([self user]) {
        [self setUserId:[user userId]];
    } else {
        [self setUserId:[[[cleanedDict objectForKey:kReadmillAPIReadingUserKey] objectForKey:kReadmillAPIUserIdKey] unsignedIntegerValue]];
    }
    [self setBookId:[[[cleanedDict objectForKey:kReadmillAPIReadingBookKey] objectForKey:kReadmillAPIBookIdKey] unsignedIntegerValue]];
    [self setReadingId:[[cleanedDict objectForKey:kReadmillAPIReadingIdKey] unsignedIntegerValue]];
    
    [self setEstimatedTimeLeft:[[cleanedDict objectForKey:kReadmillAPIReadingEstimatedTimeLeftKey] doubleValue]];
    [self setTimeSpent:[[cleanedDict objectForKey:kReadmillAPIReadingDurationKey] doubleValue]];
 
    [self setProgress:[[cleanedDict objectForKey:kReadmillAPIReadingProgressKey] floatValue]];
    
    [self setPermalinkURL:[NSURL URLWithString:[cleanedDict objectForKey:kReadmillAPIReadingPermalinkURLKey]]];
    [self setUri:[NSURL URLWithString:[cleanedDict objectForKey:kReadmillAPIReadingURIKey]]];
    [self setCommentsURI:[NSURL URLWithString:[cleanedDict objectForKey:kReadmillAPIReadingCommentsKey]]];
    [self setPeriodsURI:[NSURL URLWithString:[cleanedDict objectForKey:kReadmillAPIReadingPeriodsKey]]];
    [self setLocationsURI:[NSURL URLWithString:[cleanedDict objectForKey:kReadmillAPIReadingLocationsKey]]];
    [self setHighlightsURI:[NSURL URLWithString:[cleanedDict objectForKey:kReadmillAPIReadingHighlightsKey]]];
    
    [self setHighlightCount:[[cleanedDict objectForKey:kReadmillAPIReadingHighlightsCountKey] unsignedIntegerValue]];
    
    NSLog(@"update");
}

-(NSString *)description {
    return [NSString stringWithFormat:@"%@ id %d: Reading of book %d by %d, reading state: %d", [super description], [self readingId], [self bookId], [self userId], [self state]];
}

-(ReadmillReadingSession *)createReadingSession {
    return [[[ReadmillReadingSession alloc] initWithAPIWrapper:[self apiWrapper] readingId:[self readingId]] autorelease];
}

@synthesize dateAbandoned;
@synthesize dateCreated;
@synthesize dateFinished;
@synthesize dateModified;
@synthesize dateStarted;
@synthesize estimatedTimeLeft;
@synthesize timeSpent;

@synthesize permalinkURL;
@synthesize uri;
@synthesize commentsURI;
@synthesize periodsURI;
@synthesize locationsURI;
@synthesize highlightsURI;

@synthesize closingRemark;
@synthesize isPrivate;
@synthesize state;

@synthesize bookId;
@synthesize userId;
@synthesize readingId;

@synthesize progress;

@synthesize user;
@synthesize apiWrapper;
     
@synthesize highlightCount;

#pragma mark -
#pragma mark - Dealloc

- (void)dealloc {
    // Clean-up code here.
    [self setApiWrapper:nil];
    [self setUser:nil];

    [self setDateAbandoned:nil];
    [self setDateCreated:nil];
    [self setDateFinished:nil];
    [self setDateModified:nil];
    [self setDateStarted:nil];
    [self setClosingRemark:nil];
    
    [self setUri:nil];
    [self setHighlightsURI:nil];
    [self setPeriodsURI:nil];
    [self setLocationsURI:nil];
    [self setCommentsURI:nil];
    [self setPermalinkURL:nil];
    
    [super dealloc];
}

#pragma mark -
#pragma mark Threaded Methods

-(void)updateState:(ReadmillReadingState)newState delegate:(id <ReadmillReadingUpdatingDelegate>)delegate 
{
    [self updateWithState:newState isPrivate:[self isPrivate] closingRemark:[self closingRemark] delegate:delegate];
}

-(void)updateIsPrivate:(BOOL)readingIsPrivate delegate:(id <ReadmillReadingUpdatingDelegate>)delegate 
{
    [self updateWithState:[self state] isPrivate:readingIsPrivate closingRemark:[self closingRemark] delegate:delegate];
}

-(void)updateClosingRemark:(NSString *)newRemark delegate:(id <ReadmillReadingUpdatingDelegate>)delegate 
{
    [self updateWithState:[self state] isPrivate:[self isPrivate] closingRemark:newRemark delegate:delegate];
}

-(void)updateWithState:(ReadmillReadingState)newState isPrivate:(BOOL)readingIsPrivate closingRemark:(NSString *)newRemark delegate:(id <ReadmillReadingUpdatingDelegate>)delegate 
{    
    NSDictionary *properties = [NSDictionary dictionaryWithObjectsAndKeys:
                                delegate, @"delegate",
                                [NSThread currentThread], @"callbackThread",
                                [NSNumber numberWithUnsignedInteger:newState], @"state",
                                [NSNumber numberWithBool:readingIsPrivate], @"privacy",
                                newRemark, @"remark",
                                nil];
    
    [self performSelectorInBackground:@selector(updateStateAndPrivacyWithProperties:)
                           withObject:properties];
}

-(void)updateStateAndPrivacyWithProperties:(NSDictionary *)properties 
{    
    [self retain];
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    NSThread *callbackThread = [properties valueForKey:@"callbackThread"];
    id <ReadmillReadingUpdatingDelegate> readingUpdatingDelegate = [properties valueForKey:@"delegate"];
    BOOL privacy = [[properties valueForKey:@"privacy"] boolValue];
    ReadmillReadingState newState = [[properties valueForKey:@"state"] unsignedIntegerValue];
    NSString *remark = [properties valueForKey:@"remark"];    
    
    [[self apiWrapper] updateReadingWithId:[self readingId]
                                 withState:newState
                                   private:privacy
                             closingRemark:remark
                         completionHandler:^(id result, NSError *error) {
                                    //
                             if (error == nil) {
                                 [[self apiWrapper] readingWithId:[self readingId]
                                                completionHandler:^(id newDetails, NSError *error) {
                                                    if (newDetails != nil && error == nil) {
                                                        [self updateWithAPIDictionary:newDetails];
                                                    }
                                                }];
                             }
                             
                             if (error == nil && readingUpdatingDelegate != nil) {
                                 
                                 [(NSObject *)readingUpdatingDelegate performSelector:@selector(readmillReadingDidUpdateMetadataSuccessfully:)
                                                                             onThread:callbackThread
                                                                           withObject:self
                                                                        waitUntilDone:YES];
                                 
                             } else if (error != nil && readingUpdatingDelegate != nil) {
                                 
                                 NSInvocation *failedInvocation = [NSInvocation invocationWithMethodSignature:
                                                                   [(NSObject *)readingUpdatingDelegate 
                                                                    methodSignatureForSelector:@selector(readmillReading:didFailToUpdateMetadataWithError:)]];
                                 
                                 [failedInvocation setSelector:@selector(readmillReading:didFailToUpdateMetadataWithError:)];
                                 
                                 ReadmillReading *aReading = self;
                                 [failedInvocation setArgument:&aReading atIndex:2];
                                 [failedInvocation setArgument:&error atIndex:3];
                                 
                                 [failedInvocation performSelector:@selector(invokeWithTarget:)
                                                          onThread:callbackThread
                                                        withObject:readingUpdatingDelegate
                                                     waitUntilDone:YES]; 
                             }
                                                            
                         }];
    
    [pool drain];
    [self release];
}


@end
