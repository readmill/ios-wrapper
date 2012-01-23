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
#import "NSKeyedArchiver+ReadmillAdditions.h"
#import "ReadmillPing.h"
#import "NSError+ReadmillAdditions.h"
#import "ReadmillReadingSession+Internal.h"

@implementation ReadmillReadingSessionArchive

@synthesize lastSessionDate;
@synthesize sessionIdentifier;

- (id)initWithSessionIdentifier:(NSString *)aSessionIdentifier 
{
    if ((self = [super init])) {
        [self setSessionIdentifier:aSessionIdentifier];
        [self setLastSessionDate:[NSDate date]];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder 
{   
    [coder encodeObject:lastSessionDate forKey:@"lastSessionDate"];
    [coder encodeObject:sessionIdentifier forKey:@"sessionIdentifier"];
} 

- (id)initWithCoder:(NSCoder *)coder 
{
    if ((self = [super init])) {
        [self setLastSessionDate:[coder decodeObjectForKey:@"lastSessionDate"]];
        [self setSessionIdentifier:[coder decodeObjectForKey:@"sessionIdentifier"] ];
    }
    return self; 
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ sessionIdentifier %@ withDate %@", [super description], [self sessionIdentifier], [self lastSessionDate]]; 
}

- (void)dealloc 
{
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

- (id)init 
{
    NSLog(@"ReadmillReadingSession needs to be instantiated with a ReadmillAPIWrapper and a readingId.");
    return [self initWithAPIWrapper:nil readingId:0];
}

- (id)initWithAPIWrapper:(ReadmillAPIWrapper *)wrapper readingId:(ReadmillReadingId)sessionReadingId
{    
    if ((self = [super init])) {
        [self setApiWrapper:wrapper];
        [self setReadingId:sessionReadingId];
    }
    return self;
}

- (NSString *)description 
{
    return [NSString stringWithFormat:@"%@ reading %d", [super description], [self readingId]]; 
}

@synthesize apiWrapper;
@synthesize readingId;

- (NSString *)sessionIdentifier 
{
    ReadmillReadingSessionArchive *archive = [NSKeyedUnarchiver unarchiveReadmillReadingSession];

    if (![self isReadingSessionIdentifierValid]) {
        archive = [[[ReadmillReadingSessionArchive alloc] initWithSessionIdentifier:[[NSProcessInfo processInfo] globallyUniqueString]] autorelease];
        [NSKeyedArchiver archiveReadmillReadingSession:archive];
    }
    return [archive sessionIdentifier];
}

+ (BOOL)isReadingSessionIdentifierValid 
{
    ReadmillReadingSessionArchive *archive = [NSKeyedUnarchiver unarchiveReadmillReadingSession];
    
    // Do we have a saved archive that was generated less than 30 minutes ago?
    NSTimeInterval timeIntervalSinceLastSession = [[NSDate date] timeIntervalSinceDate:[archive lastSessionDate]];
    if (archive == nil || timeIntervalSinceLastSession > 30 * 60) {
        return NO;
    } 
    return YES;
}

- (BOOL)isReadingSessionIdentifierValid
{
    return [ReadmillReadingSession isReadingSessionIdentifierValid];
}

+ (void)pingArchived:(ReadmillAPIWrapper *)wrapper 
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSLog(@"Ping archived pings.");
    NSArray *unarchivedPings = nil;
    unarchivedPings = [NSKeyedUnarchiver unarchiveReadmillPings];
    if (nil != unarchivedPings && 0 < [unarchivedPings count])  {
        // Empty the archive
        [NSKeyedArchiver archiveReadmillPings:[NSArray array]];
        for (ReadmillPing *ping in unarchivedPings) {
            
            [wrapper pingReadingWithId:[ping readingId] 
                          withProgress:[ping progress] 
                     sessionIdentifier:[ping sessionIdentifier] 
                              duration:[ping duration]
                        occurrenceTime:[ping occurrenceTime]
                              latitude:[ping latitude] 
                             longitude:[ping longitude]
                     completionHandler:^(id result, NSError *error) {
                         if (error) {
                             if ([[error domain] isEqualToString:NSURLErrorDomain] || // NSURL internet connection
                                 ([error isReadmillDomain] && ![error isClientError])) { // Client error on Readmill
                                 // No client error so ping could not be delivered correctly
                                 [self archiveFailedPing:ping];
                             } else {
                                 NSLog(@"Failed to send archived ping: %@, error: %@", ping, error);
                             }
                         } else {
                             NSLog(@"Sent archived ping.");
                         }
                     }];
        }
    } else {
        NSLog(@"No archived pings.");
    }
    [pool drain];
}

- (void)archiveFailedPing:(ReadmillPing *)ping
{
    [[self class] archiveFailedPing:ping];
}
- (void)pingArchived
{
    NSAssert([self apiWrapper] != nil, @"No apiWrapper!");
    [[self class] pingArchived:[self apiWrapper]];
}

#pragma mark -
#pragma mark Threaded Messages

- (void)pingWithProgress:(ReadmillReadingProgress)progress 
            pingDuration:(ReadmillPingDuration)pingDuration 
                delegate:(id <ReadmillPingDelegate>)pingDelegate 
{
    [self pingWithProgress:progress 
              pingDuration:pingDuration 
                  latitude:0.0
                 longitude:0.0
                  delegate:pingDelegate];
}

- (void)pingWithProgress:(ReadmillReadingProgress)progress
            pingDuration:(ReadmillPingDuration)pingDuration 
                latitude:(CLLocationDegrees)latitude 
               longitude:(CLLocationDegrees)longitude 
                delegate:(id<ReadmillPingDelegate>)pingDelegate 
{    
    // Create the ping so we can archive it if the ping fails
    ReadmillPing *ping = [[ReadmillPing alloc] initWithReadingId:[self readingId] 
                                                 readingProgress:progress 
                                               sessionIdentifier:[self sessionIdentifier]
                                                        duration:pingDuration
                                                  occurrenceTime:[NSDate date] 
                                                        latitude:latitude 
                                                       longitude:longitude];
    
    dispatch_queue_t currentQueue = dispatch_get_current_queue();
    
    ReadmillAPICompletionHandler completionHandler = ^(id result, NSError *error) {
        if (error == nil) {
            dispatch_async(currentQueue, ^{
                [pingDelegate readmillReadingSessionDidPingSuccessfully:self];  
            });
            
            // Since we succeeded to ping, try to send any archived pings
            [self pingArchived];
            
        } else {
            dispatch_async(currentQueue, ^{
                [pingDelegate readmillReadingSession:self 
                              didFailToPingWithError:error];  
            });
            
            if ([[error domain] isEqualToString:NSURLErrorDomain] || // NSURL internet connection
                ([error isReadmillDomain] && ![error isClientError])) { // Client error on Readmill
                // No client error so ping could not be delivered correctly
                [self archiveFailedPing:ping];
            }
        }
    };
    
    [[self apiWrapper] pingReadingWithId:[ping readingId]
                            withProgress:[ping progress]
                       sessionIdentifier:[ping sessionIdentifier]
                                duration:[ping duration]
                          occurrenceTime:[ping occurrenceTime]
                                latitude:[ping latitude]
                               longitude:[ping longitude]
                       completionHandler:completionHandler];
    
    // Update the session date since
    [self refreshSessionDate];
    [ping release];    
}

- (void)dealloc 
{
    [self setApiWrapper:nil];    
    [super dealloc];
}
@end

