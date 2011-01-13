//
//  ReadmillReadSession.m
//  Readmill Framework
//
//  Created by Work on 13/01/2011.
//  Copyright 2011 KennettNet Software Limited. All rights reserved.
//

#import "ReadmillReadSession.h"

@interface ReadmillReadSession ()

@property (readwrite, copy) NSDate *lastPingDate;
@property (readwrite, copy) NSString *sessionIdentifier;
@property (readwrite, retain) ReadmillAPIWrapper *apiWrapper;
@property (readwrite) ReadmillReadId readId;

@end

@implementation ReadmillReadSession

- (id)init {
    return [self initWithAPIWrapper:nil readId:0];
}

-(id)initWithAPIWrapper:(ReadmillAPIWrapper *)wrapper readId:(ReadmillReadId)sessionReadId {
    return [self initWithAPIWrapper:wrapper readId:sessionReadId sessionId:[[NSProcessInfo processInfo] globallyUniqueString]];
}

-(id)initWithAPIWrapper:(ReadmillAPIWrapper *)wrapper readId:(ReadmillReadId)sessionReadId sessionId:(NSString *)sessionId {
    if ((self = [super init])) {
        // Initialization code here.
        
        [self setApiWrapper:wrapper];
        [self setReadId:sessionReadId];
        [self setLastPingDate:[NSDate date]];
        [self setSessionIdentifier:sessionId];
    }
    return self;
}

-(NSString *)description {
    return [NSString stringWithFormat:@"%@ id %@ for read %d", [super description], [self sessionIdentifier], [self readId]]; 
}

@synthesize lastPingDate;
@synthesize sessionIdentifier;
@synthesize apiWrapper;
@synthesize readId;

- (void)dealloc {
    // Clean-up code here.
    
    [self setApiWrapper:nil];
    [self setLastPingDate:nil];
    [self setSessionIdentifier:nil];
    
    [super dealloc];
}

#pragma mark -
#pragma mark Threaded Messages

-(void)pingWithProgress:(ReadmillReadProgress)progress delegate:(id <ReadmillPingDelegate>)delegate {
    
    NSDictionary *properties = [NSDictionary dictionaryWithObjectsAndKeys:
                                delegate, @"delegate",
                                [NSThread currentThread], @"callbackThread",
                                [NSNumber numberWithUnsignedInteger:progress], @"progress",
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
    NSUInteger progress = [[properties valueForKey:@"progress"] unsignedIntegerValue];
    
    NSDate *pingTime = [NSDate date];
    NSTimeInterval timeSinceLastPing = [pingTime timeIntervalSinceDate:[self lastPingDate]];
    
    NSError *error = nil;
    [[self apiWrapper] pingReadWithId:[self readId]
                         withProgress:progress
                    sessionIdentifier:[self sessionIdentifier]
                             duration:(NSUInteger)timeSinceLastPing
                       occurrenceTime:pingTime
                                error:&error];
    
    if (error != nil) {
        [self setLastPingDate:pingTime];
    }
    
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
    }
    
    [pool drain];
    
    [self release];
}

@end
