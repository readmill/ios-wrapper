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

#import "ReadmillReadingSession.h"
#import "ReadmillArchiverExtensions.h"
#import "ReadmillPing.h"
#import "ReadmillErrorExtensions.h"

@implementation ReadmillReadingSessionArchive

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
- (void)dealloc {
    [lastSessionDate release];
    [sessionIdentifier release];
    [super dealloc];
}
@end

@interface ReadmillReadingSession ()
@property (readwrite, retain) ReadmillAPIWrapper *apiWrapper;
@property (readwrite) ReadmillReadingId readingId;
@end

@implementation ReadmillReadingSession

- (id)init {
    return [self initWithAPIWrapper:nil readingId:0];
}

-(id)initWithAPIWrapper:(ReadmillAPIWrapper *)wrapper readingId:(ReadmillReadingId)sessionReadingId {
    
    if ((self = [super init])) {
        // Initialization code here.
        [self setApiWrapper:wrapper];
        [self setReadingId:sessionReadingId];
        [ReadmillReadingSession pingArchived:wrapper];
    }
    return self;
}

-(NSString *)description {
    return [NSString stringWithFormat:@"%@ reading %d", [super description], [self readingId]]; 
}

@synthesize apiWrapper;
@synthesize readingId;

- (void)updateReadmillReadingSession {
    ReadmillReadingSessionArchive *archive = [NSKeyedUnarchiver unarchiveReadmillReadingSession];
    [archive setLastSessionDate:[NSDate date]];
    [NSKeyedArchiver archiveReadmillReadingSession:archive];
}

- (NSString *)generateSessionIdentifier {
    ReadmillReadingSessionArchive *archive = [NSKeyedUnarchiver unarchiveReadmillReadingSession];
    
    // Do we have a saved archive that was generated less than 30 minutes ago?
    if (archive == nil || [[NSDate date] timeIntervalSinceDate:[archive lastSessionDate]] > 30 * 60) {
        archive = [[[ReadmillReadingSessionArchive alloc] initWithSessionIdentifier:[[NSProcessInfo processInfo] globallyUniqueString]] autorelease];
        [NSKeyedArchiver archiveReadmillReadingSession:archive];
        NSLog(@"archive nil or date generated more than 30 minutes ago, generated one: %@", archive);
    } else {
        NSLog(@"had an archive, with time since last ping: %f", [[NSDate date] timeIntervalSinceDate:[archive lastSessionDate]]);
    }
    return [archive sessionIdentifier];
}
- (void)archiveFailedPing:(ReadmillPing *)ping {    
    // Grab all archived pings
    
    NSArray *unarchivedPings = [NSKeyedUnarchiver unarchiveReadmillPings];
    NSMutableArray *failedPings = [[NSMutableArray alloc] init];
    if (nil != unarchivedPings) {
        [failedPings addObjectsFromArray:unarchivedPings];
    }
    // Add the new one
    [failedPings addObject:ping];
    // Archive all pings
    [NSKeyedArchiver archiveReadmillPings:failedPings];
    
    NSLog(@"Failed ping: %@\n All pings: %@", ping, failedPings);
    [failedPings release];
}
+ (void)pingArchived:(ReadmillAPIWrapper *)wrapper {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSLog(@"Ping archived pings.");
    NSArray *unarchivedPings = nil;
    unarchivedPings = [NSKeyedUnarchiver unarchiveReadmillPings];
    if (nil != unarchivedPings && 0 < [unarchivedPings count]) {
        NSMutableArray *failedPings = [[NSMutableArray alloc] init];
        for (ReadmillPing *ping in unarchivedPings) {
            NSError *error = nil;
            [wrapper pingReadingWithId:[ping readingId] 
                       withProgress:[ping progress] 
                  sessionIdentifier:[ping sessionIdentifier] 
                           duration:[ping duration]
                     occurrenceTime:[ping occurrenceTime]
                           latitude:[ping latitude] 
                          longitude:[ping longitude]
                              error:&error];
            if (!error) {
                NSLog(@"Sent archived ping: %@", ping);
            } else {
                if (![error isReadmillClientError]) {
                    // No client error so ping could not be delivered correctly
                    [failedPings addObject:ping];
                } else {
                    NSLog(@"Failed to send archived ping: %@, error: %@", ping, error);
                
                }
            }
        }
        [NSKeyedArchiver archiveReadmillPings:failedPings];
        [failedPings release];
    } else {
        NSLog(@"No archived pings.");
    }
    [pool drain];
}
#pragma mark -
#pragma mark Threaded Messages

-(void)pingWithProgress:(ReadmillReadingProgress)progress 
           pingDuration:(ReadmillPingDuration)pingDuration 
               delegate:(id <ReadmillPingDelegate>)delegate {
    
    
    
    NSDictionary *properties = [NSDictionary dictionaryWithObjectsAndKeys:
                                delegate, @"delegate",
                                [NSThread currentThread], @"callbackThread",
                                [NSNumber numberWithFloat:progress], @"progress",
                                [NSNumber numberWithUnsignedInteger:pingDuration], @"pingDuration",
                                nil];
    
    [self performSelectorInBackground:@selector(pingWithProperties:)
                           withObject:properties];
    
}

-(void)pingWithProgress:(ReadmillReadingProgress)progress
           pingDuration:(ReadmillPingDuration)pingDuration 
               latitude:(CLLocationDegrees)latitude 
              longitude:(CLLocationDegrees)longitude 
               delegate:(id<ReadmillPingDelegate>)delegate {
    
    
    
    NSDictionary *properties = [NSDictionary dictionaryWithObjectsAndKeys:
                                delegate, @"delegate",
                                [NSThread currentThread], @"callbackThread",
                                [NSNumber numberWithFloat:progress], @"progress",
                                [NSNumber numberWithUnsignedInteger:pingDuration], @"pingDuration",
                                [NSNumber numberWithDouble:latitude], @"latitude",
                                [NSNumber numberWithDouble:longitude], @"longitude",
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
    
    
    ReadmillReadingProgress progress = [[properties valueForKey:@"progress"] floatValue];
    ReadmillPingDuration pingDuration = [[properties valueForKey:@"pingDuration"] unsignedIntegerValue];
    
    NSString *sessionIdentifier = [self generateSessionIdentifier];

    // Should always be 0.0 if not specified
    CLLocationDegrees latitude = [[properties valueForKey:@"latitude"] doubleValue];
    CLLocationDegrees longitude = [[properties valueForKey:@"longitude"] doubleValue];
    
    // Create the ping so we can archive it if the ping fails
    ReadmillPing *ping = [[ReadmillPing alloc] initWithReadingId:[self readingId] 
                                                 readingProgress:progress 
                                               sessionIdentifier:sessionIdentifier 
                                                        duration:pingDuration
                                                  occurrenceTime:[NSDate date] 
                                                        latitude:latitude 
                                                       longitude:longitude];
    NSError *error = nil;
    [[self apiWrapper] pingReadingWithId:[ping readingId]
                            withProgress:[ping progress]
                       sessionIdentifier:[ping sessionIdentifier]
                                duration:[ping duration]
                          occurrenceTime:[ping occurrenceTime]
                                latitude:[ping latitude]
                               longitude:[ping longitude]
                                   error:&error];
    
    [self updateReadmillReadingSession];
    
    if (error == nil && pingDelegate != nil) {
        
        [(NSObject *)pingDelegate performSelector:@selector(readmillReadingSessionDidPingSuccessfully:)
                                                 onThread:callbackThread
                                               withObject:self
                                            waitUntilDone:YES];
        
        [ReadmillReadingSession pingArchived:[self apiWrapper]];
        
    } else if (error != nil && pingDelegate != nil) {
        
        NSInvocation *failedInvocation = [NSInvocation invocationWithMethodSignature:
                                          [(NSObject *)pingDelegate 
                                           methodSignatureForSelector:@selector(readmillReadingSession:didFailToPingWithError:)]];
        
        [failedInvocation setSelector:@selector(readmillReadingSession:didFailToPingWithError:)];
        
        [failedInvocation setArgument:&self atIndex:2];
        [failedInvocation setArgument:&error atIndex:3];
        
        [failedInvocation performSelector:@selector(invokeWithTarget:)
                                 onThread:callbackThread
                               withObject:pingDelegate
                            waitUntilDone:YES]; 
        
        if (![error isReadmillClientError]) {
            [self archiveFailedPing:ping];
        }
    }
    [ping release];
    [pool drain];
    
    [self release];
}
- (void)dealloc {
    // Clean-up code here.
    
    [self setApiWrapper:nil];    
    [super dealloc];
}
@end

