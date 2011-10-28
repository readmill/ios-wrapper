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
@property (readwrite, copy) NSURL *comments;
@property (readwrite, copy) NSURL *periods;
@property (readwrite, copy) NSURL *locations;
@property (readwrite, copy) NSURL *highlights;

@property (readwrite) BOOL isPrivate;

@property (readwrite) ReadmillReadingState state;

@property (readwrite) ReadmillBookId bookId;
@property (readwrite) ReadmillUserId userId;
@property (readwrite) ReadmillReadingId readingId;

@property (readwrite) ReadmillReadingProgress progress;

@property (readwrite, retain) ReadmillAPIWrapper *apiWrapper;

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
    
    NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
    [formatter setDateFormat:@"YYYY'-'MM'-'dd'T'HH':'mm':'ss'Z'"];
    
    [self setDateAbandoned:[formatter dateFromString:[cleanedDict valueForKey:kReadmillAPIReadingDateAbandonedKey]]];
    [self setDateCreated:[formatter dateFromString:[cleanedDict valueForKey:kReadmillAPIReadingDateCreatedKey]]];
    [self setDateFinished:[formatter dateFromString:[cleanedDict valueForKey:kReadmillAPIReadingDateFinishedKey]]];
    [self setDateModified:[formatter dateFromString:[cleanedDict valueForKey:kReadmillAPIReadingDateModifiedKey]]];
    [self setDateStarted:[formatter dateFromString:[cleanedDict valueForKey:kReadmillAPIReadingDateStarted]]];
        
    [self setClosingRemark:[cleanedDict valueForKey:kReadmillAPIReadingClosingRemarkKey]];
    
    [self setIsPrivate:([[cleanedDict valueForKey:kReadmillAPIReadingIsPrivateKey] unsignedIntegerValue] == 1)];
    
    [self setState:[[cleanedDict valueForKey:kReadmillAPIReadingStateKey] unsignedIntegerValue]];
    
    [self setUserId:[[[cleanedDict valueForKey:kReadmillAPIReadingUserKey] valueForKey:kReadmillAPIUserIdKey] unsignedIntegerValue]];
    [self setBookId:[[[cleanedDict valueForKey:kReadmillAPIReadingBookKey] valueForKey:kReadmillAPIBookIdKey] unsignedIntegerValue]];
    [self setReadingId:[[cleanedDict valueForKey:kReadmillAPIReadingIdKey] unsignedIntegerValue]];
    
    [self setEstimatedTimeLeft:[[cleanedDict valueForKey:kReadmillAPIReadingEstimatedTimeLeft] doubleValue]];
    [self setTimeSpent:[[cleanedDict valueForKey:kReadmillAPIReadingDuration] doubleValue]];
 
    [self setProgress:[[cleanedDict valueForKey:kReadmillAPIReadingProgress] floatValue]];
    

    [self setPermalinkURL:[NSURL URLWithString:[cleanedDict objectForKey:kReadmillAPIReadingPermalinkURLKey]]];
    [self setUri:[NSURL URLWithString:[cleanedDict objectForKey:kReadmillAPIReadingURIKey]]];
    [self setComments:[NSURL URLWithString:[cleanedDict objectForKey:kReadmillAPIReadingCommentsKey]]];
    [self setPeriods:[NSURL URLWithString:[cleanedDict objectForKey:kReadmillAPIReadingPeriodsKey]]];
    [self setLocations:[NSURL URLWithString:[cleanedDict objectForKey:kReadmillAPIReadingLocationsKey]]];
    [self setHighlights:[NSURL URLWithString:[cleanedDict objectForKey:kReadmillAPIReadingHighlightsKey]]];
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
@synthesize comments;
@synthesize periods;
@synthesize locations;
@synthesize highlights;

@synthesize closingRemark;
@synthesize isPrivate;
@synthesize state;

@synthesize bookId;
@synthesize userId;
@synthesize readingId;

@synthesize progress;

@synthesize apiWrapper;

- (void)dealloc {
    // Clean-up code here.
    
    [self setApiWrapper:nil];
    
    [self setDateAbandoned:nil];
    [self setDateCreated:nil];
    [self setDateFinished:nil];
    [self setDateModified:nil];
    [self setDateStarted:nil];
    [self setClosingRemark:nil];
    
    [super dealloc];
}

#pragma mark -
#pragma mark Threaded Methods

-(void)updateState:(ReadmillReadingState)newState delegate:(id <ReadmillReadingUpdatingDelegate>)delegate {
    [self updateWithState:newState isPrivate:[self isPrivate] closingRemark:[self closingRemark] delegate:delegate];
}

-(void)updateIsPrivate:(BOOL)readingIsPrivate delegate:(id <ReadmillReadingUpdatingDelegate>)delegate {
    [self updateWithState:[self state] isPrivate:readingIsPrivate closingRemark:[self closingRemark] delegate:delegate];
}

-(void)updateClosingRemark:(NSString *)newRemark delegate:(id <ReadmillReadingUpdatingDelegate>)delegate {
    [self updateWithState:[self state] isPrivate:[self isPrivate] closingRemark:newRemark delegate:delegate];
}

-(void)updateWithState:(ReadmillReadingState)newState isPrivate:(BOOL)readingIsPrivate closingRemark:(NSString *)newRemark delegate:(id <ReadmillReadingUpdatingDelegate>)delegate {
    
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

-(void)updateStateAndPrivacyWithProperties:(NSDictionary *)properties {
    
    [self retain];
    
    NSAutoreleasePool *pool;
    pool = [[NSAutoreleasePool alloc] init];
    
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
