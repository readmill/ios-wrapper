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

#import "ReadmillReadSession.h"
#import "ReadmillArchiverExtensions.h"
#import "ReadmillPing.h"

@implementation ReadmillReadSessionArchive

@synthesize lastSessionDate;
@synthesize sessionIdentifier;

- (id)initWithSessionIdentifier:(NSString *)aSessionIdentifier {
    if ((self = [super init])) {
        [self setSessionIdentifier:aSessionIdentifier];
        [self setLastSessionDate:[NSDate date]];
    }
    return self;
}
- (void)encodeWithCoder:(NSCoder *)coder {   
    [coder encodeObject:lastSessionDate forKey:@"lastSessionDate"];
    [coder encodeObject:sessionIdentifier forKey:@"sessionIdentifier"];
} 

- (id)initWithCoder:(NSCoder *)coder {
    self.lastSessionDate = [coder decodeObjectForKey:@"lastSessionDate"];
    self.sessionIdentifier = [coder decodeObjectForKey:@"sessionIdentifier"];
    return self; 
}
-(NSString *)description {
    return [NSString stringWithFormat:@"%@ sessionIdentifier %@ withDate %@", [super description], [self sessionIdentifier], [self lastSessionDate]]; 
}
@end



@interface ReadmillReadSession ()
- (void)pingArchived;
@property (readwrite, retain) ReadmillAPIWrapper *apiWrapper;
@property (readwrite) ReadmillReadId readId;
@end

@implementation ReadmillReadSession

- (id)init {
    return [self initWithAPIWrapper:nil readId:0];
}

-(id)initWithAPIWrapper:(ReadmillAPIWrapper *)wrapper readId:(ReadmillReadId)sessionReadId {
    
    if ((self = [super init])) {
        // Initialization code here.
        [self setApiWrapper:wrapper];
        [self setReadId:sessionReadId];
        [self pingArchived];
    }
    return self;
}

-(NSString *)description {
    return [NSString stringWithFormat:@"%@ read %d", [super description], [self readId]]; 
}

@synthesize apiWrapper;
@synthesize readId;

- (void)updateReadmillReadSession {
    ReadmillReadSessionArchive *archive = [NSKeyedUnarchiver unarchiveReadmillReadSession];
    [archive setLastSessionDate:[NSDate date]];
    [NSKeyedArchiver archiveReadmillReadSession:archive];
}

- (NSString *)generateSessionIdentifier {
    ReadmillReadSessionArchive *archive = [NSKeyedUnarchiver unarchiveReadmillReadSession];
    
    // Do we have a saved archive that was generated less than 30 minutes ago?
    if (archive == nil || [[NSDate date] timeIntervalSinceDate:[archive lastSessionDate]] > 30 * 60) {
        archive = [[[ReadmillReadSessionArchive alloc] initWithSessionIdentifier:[[NSProcessInfo processInfo] globallyUniqueString]] autorelease];
        [NSKeyedArchiver archiveReadmillReadSession:archive];
        DLog(@"archive nil or date generated more than 30 minutes ago, generated one: %@", archive);
    } else {
        DLog(@"had an archive, with time since last ping: %f", [[NSDate date] timeIntervalSinceDate:[archive lastSessionDate]]);
    }
    return [archive sessionIdentifier];
}
- (NSArray *)fetchFailedPings {
    NSArray *failedPings = [NSKeyedUnarchiver unarchiveReadmillPings];
    if (failedPings == nil) {
        return [NSArray array];
    }
    return failedPings;
}
- (void)archiveFailedPingWithReadId:(ReadmillReadId)aReadId readProgress:(ReadmillReadProgress)progress sessionIdentifier:(NSString *)sessionIdentifier duration:(ReadmillPingDuration)duration occurrenceTime:(NSDate *)occurrenceTime {
    
    ReadmillPing *ping = [[ReadmillPing alloc] initWithReadId:[self readId] 
                                                 readProgress:progress 
                                            sessionIdentifier:sessionIdentifier
                                                     duration:duration 
                                               occurrenceTime:occurrenceTime];
    // Grab all archived pings
    
    NSArray *unarchivedPings = [NSKeyedUnarchiver unarchiveReadmillPings];
    NSMutableArray *failedPings = [[NSMutableArray alloc] init];
    if (nil != unarchivedPings) {
        [failedPings addObjectsFromArray:unarchivedPings];
    }
    NSLog(@"archiveFailedPing: %@, failedPings: %@", ping, failedPings);
    // Add the new one
    [failedPings addObject:ping];
    [ping release];
    // Archive all pings
    [NSKeyedArchiver archiveReadmillPings:failedPings];
    [failedPings release];
}
- (BOOL)pingErrorWasUnprocessable:(NSError *)pingError {
    if ([[pingError domain] isEqualToString:kReadmillErrorDomain] && [pingError code] == 422) 
        return YES;
    return NO;
}
- (void)pingArchived {
    DLog(@"pingArchived");
    NSArray *unarchivedPings = [NSKeyedUnarchiver unarchiveReadmillPings];
    if (nil != unarchivedPings) {
        NSMutableArray *failedPings = [[NSMutableArray alloc] init];
        for (ReadmillPing *ping in unarchivedPings) {
            NSError *error = nil;
            [[self apiWrapper] pingReadWithId:[ping readId] 
                                 withProgress:[ping progress] 
                            sessionIdentifier:[ping sessionIdentifier] 
                                     duration:[ping duration]
                               occurrenceTime:[ping occurrenceTime] 
                                        error:&error];
            if (!error) {
                NSLog(@"Sent archived ping: %@", ping);
            } else {
                if ([self pingErrorWasUnprocessable:error]) {
                    NSLog(@"Error 422 (book is probably finished");
                    // The request was well-formed but was unable to be followed due to semantic errors.
                    // E.g book is finished 
                } else {
                    NSLog(@"Failed to send archived ping: %@, error: %@", ping, error);
                    [failedPings addObject:ping];
                }
            }
        }
        [NSKeyedArchiver archiveReadmillPings:failedPings];
        [failedPings release];
    } else {
        DLog(@"no pings");
    }
}
#pragma mark -
#pragma mark Threaded Messages

-(void)pingWithProgress:(ReadmillReadProgress)progress pingDuration:(ReadmillPingDuration)pingDuration delegate:(id <ReadmillPingDelegate>)delegate {
    
    
    
    NSDictionary *properties = [NSDictionary dictionaryWithObjectsAndKeys:
                                delegate, @"delegate",
                                [NSThread currentThread], @"callbackThread",
                                [NSNumber numberWithUnsignedInteger:progress], @"progress",
                                [NSNumber numberWithUnsignedInteger:pingDuration], @"pingDuration",
                                nil];
    
    [self performSelectorInBackground:@selector(pingWithProperties:)
                           withObject:properties];
    
}

-(void)pingWithProperties:(NSDictionary *)properties {
    
    [self retain];
    
    NSAutoreleasePool *pool;
    pool = [[NSAutoreleasePool alloc] init];
    
    NSThread *callbackThread = [properties valueForKey:@"callbackThread"];
    id <ReadmillPingDelegate> pingDelegate = [properties valueForKey:@"delegate"];
    ReadmillReadProgress progress = [[properties valueForKey:@"progress"] unsignedIntegerValue];
    ReadmillPingDuration pingDuration = [[properties valueForKey:@"pingDuration"] unsignedIntegerValue];
    NSDate *pingTime = [NSDate date];
    
    NSString *sessionIdentifier = [self generateSessionIdentifier];
    DLog(@"sessionIdentifier: %@", sessionIdentifier);
    
    NSError *error = nil;
    [[self apiWrapper] pingReadWithId:[self readId]
                         withProgress:progress
                    sessionIdentifier:sessionIdentifier
                             duration:pingDuration
                       occurrenceTime:pingTime
                                error:&error];
    

    [self updateReadmillReadSession];
    
    if (error == nil && pingDelegate != nil) {
        
        [(NSObject *)pingDelegate performSelector:@selector(readmillReadSessionDidPingSuccessfully:)
                                                 onThread:callbackThread
                                               withObject:self
                                            waitUntilDone:YES];
        
    } else if (error != nil && pingDelegate != nil) {
        
        NSInvocation *failedInvocation = [NSInvocation invocationWithMethodSignature:
                                          [(NSObject *)pingDelegate 
                                           methodSignatureForSelector:@selector(readmillReadSession:didFailToPingWithError:)]];
        
        [failedInvocation setSelector:@selector(readmillReadSession:didFailToPingWithError:)];
        
        [failedInvocation setArgument:&self atIndex:2];
        [failedInvocation setArgument:&error atIndex:3];
        
        [failedInvocation performSelector:@selector(invokeWithTarget:)
                                 onThread:callbackThread
                               withObject:pingDelegate
                            waitUntilDone:YES]; 
        
        if (![self pingErrorWasUnprocessable:error]) {
            [self archiveFailedPingWithReadId:[self readId]
                                 readProgress:progress
                            sessionIdentifier:sessionIdentifier
                                     duration:pingDuration
                               occurrenceTime:pingTime];
        }
    }
    
    [pool drain];
    
    [self release];
}
- (void)dealloc {
    // Clean-up code here.
    
    [self setApiWrapper:nil];    
    [super dealloc];
}
@end

