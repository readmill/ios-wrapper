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

#import "ReadmillRead.h"
#import "ReadmillDictionaryExtensions.h"

@interface ReadmillRead ()

@property (readwrite, copy) NSDate *dateAbandoned;
@property (readwrite, copy) NSDate *dateCreated;
@property (readwrite, copy) NSDate *dateFinished;
@property (readwrite, copy) NSDate *dateModified;
@property (readwrite, copy) NSDate *dateStarted;

@property (readwrite, copy) NSNumber *estimatedTimeLeft;
@property (readwrite, copy) NSNumber *timeSpent;

@property (readwrite, copy) NSString *closingRemark;

@property (readwrite) BOOL isPrivate;

@property (readwrite) ReadmillReadState state;

@property (readwrite) ReadmillBookId bookId;
@property (readwrite) ReadmillUserId userId;
@property (readwrite) ReadmillReadId readId;

@property (readwrite) ReadmillReadProgress progress;

@property (readwrite, retain) ReadmillAPIWrapper *apiWrapper;

@end

@implementation ReadmillRead

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
    [formatter setDateFormat:@"%Y-%m-%dT%H:%M:%SZ"];
    
    [self setDateAbandoned:[formatter dateFromString:[cleanedDict valueForKey:kReadmillAPIReadDateAbandonedKey]]];
    [self setDateCreated:[formatter dateFromString:[cleanedDict valueForKey:kReadmillAPIReadDateCreatedKey]]];
    [self setDateFinished:[formatter dateFromString:[cleanedDict valueForKey:kReadmillAPIReadDateFinishedKey]]];
    [self setDateModified:[formatter dateFromString:[cleanedDict valueForKey:kReadmillAPIReadDateModifiedKey]]];
    [self setDateStarted:[formatter dateFromString:[cleanedDict valueForKey:kReadmillAPIReadDateStarted]]];
    
    [self setClosingRemark:[cleanedDict valueForKey:kReadmillAPIReadClosingRemarkKey]];
    
    [self setIsPrivate:([[cleanedDict valueForKey:kReadmillAPIReadIsPrivateKey] unsignedIntegerValue] == 1)];
    
    [self setState:[[cleanedDict valueForKey:kReadmillAPIReadStateKey] unsignedIntegerValue]];
    
    [self setUserId:[[[cleanedDict valueForKey:kReadmillAPIReadUserKey] valueForKey:kReadmillAPIUserIdKey] unsignedIntegerValue]];
    [self setBookId:[[[cleanedDict valueForKey:kReadmillAPIReadBookKey] valueForKey:kReadmillAPIBookIdKey] unsignedIntegerValue]];
    [self setReadId:[[cleanedDict valueForKey:kReadmillAPIReadIdKey] unsignedIntegerValue]];
    
    [self setEstimatedTimeLeft:[cleanedDict valueForKey:kReadmillAPIReadEstimatedTimeLeft]];
    [self setTimeSpent:[cleanedDict valueForKey:kReadmillAPIReadDuration]];
 
    [self setProgress:[[cleanedDict valueForKey:kReadmillAPIReadProgress] unsignedIntegerValue]];
}

-(NSString *)description {
    return [NSString stringWithFormat:@"%@ id %d: Read of book %d by %d", [super description], [self readId], [self bookId], [self userId]];
}

-(ReadmillReadSession *)createReadSession {
    return [[[ReadmillReadSession alloc] initWithAPIWrapper:[self apiWrapper] readId:[self readId]] autorelease];
}

-(ReadmillReadSession *)createReadSessionWithExistingSessionId:(NSString *)sessionId {
    return [[[ReadmillReadSession alloc] initWithAPIWrapper:[self apiWrapper] readId:[self readId] sessionId:sessionId] autorelease];
}

@synthesize dateAbandoned;
@synthesize dateCreated;
@synthesize dateFinished;
@synthesize dateModified;
@synthesize dateStarted;
@synthesize estimatedTimeLeft;
@synthesize timeSpent;

@synthesize closingRemark;
@synthesize isPrivate;
@synthesize state;

@synthesize bookId;
@synthesize userId;
@synthesize readId;

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
    [self setEstimatedTimeLeft:nil];
    [self setTimeSpent:nil];
    
    [super dealloc];
}

#pragma mark -
#pragma mark Threaded Methods

-(void)updateState:(ReadmillReadState)newState delegate:(id <ReadmillReadUpdatingDelegate>)delegate {
    [self updateWithState:newState isPrivate:[self isPrivate] closingRemark:[self closingRemark] delegate:delegate];
}

-(void)updateIsPrivate:(BOOL)readIsPrivate delegate:(id <ReadmillReadUpdatingDelegate>)delegate {
    [self updateWithState:[self state] isPrivate:readIsPrivate closingRemark:[self closingRemark] delegate:delegate];
}

-(void)updateClosingRemark:(NSString *)newRemark delegate:(id <ReadmillReadUpdatingDelegate>)delegate {
    [self updateWithState:[self state] isPrivate:[self isPrivate] closingRemark:newRemark delegate:delegate];
}

-(void)updateWithState:(ReadmillReadState)newState isPrivate:(BOOL)readIsPrivate closingRemark:(NSString *)newRemark delegate:(id <ReadmillReadUpdatingDelegate>)delegate {
    
    NSDictionary *properties = [NSDictionary dictionaryWithObjectsAndKeys:
                                delegate, @"delegate",
                                [NSThread currentThread], @"callbackThread",
                                [NSNumber numberWithUnsignedInteger:newState], @"state",
                                [NSNumber numberWithBool:readIsPrivate], @"privacy",
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
    id <ReadmillReadUpdatingDelegate> readUpdatingDelegate = [properties valueForKey:@"delegate"];
    BOOL privacy = [[properties valueForKey:@"privacy"] boolValue];
    ReadmillReadState newState = [[properties valueForKey:@"state"] unsignedIntegerValue];
    NSString *remark = [properties valueForKey:@"remark"];    
    
    NSError *error = nil;
    [[self apiWrapper] updateReadWithId:[self readId]
                              withState:newState
                                private:privacy
                          closingRemark:remark
                                  error:&error];
    
    if (error == nil) {
        NSDictionary *newDetails = [[self apiWrapper] readWithId:[self readId]
                                                   forUserWithId:[self userId]
                                                           error:&error];
        if (newDetails != nil && error == nil) {
            [self updateWithAPIDictionary:newDetails];
        }
    }
    
    if (error == nil && readUpdatingDelegate != nil) {
        
       [(NSObject *)readUpdatingDelegate performSelector:@selector(readmillReadDidUpdateMetadataSuccessfully:)
                                                onThread:callbackThread
                                              withObject:self
                                           waitUntilDone:YES];
        
    } else if (error != nil && readUpdatingDelegate != nil) {
        
        NSInvocation *failedInvocation = [NSInvocation invocationWithMethodSignature:
                                          [(NSObject *)readUpdatingDelegate 
                                           methodSignatureForSelector:@selector(readmillRead:didFailToUpdateMetadataWithError:)]];
        
        [failedInvocation setSelector:@selector(readmillRead:didFailToUpdateMetadataWithError:)];
        
        [failedInvocation setArgument:&self atIndex:2];
        [failedInvocation setArgument:&error atIndex:3];
        
        [failedInvocation performSelector:@selector(invokeWithTarget:)
                                 onThread:callbackThread
                               withObject:readUpdatingDelegate
                            waitUntilDone:YES]; 
    }
    
    [pool drain];
    
    [self release];
    
}


@end
