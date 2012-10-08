//
//  ReadmillPingTests.m
//  ReadmillAPI
//
//  Created by Martin Hwasser on 1/18/12.
//  Copyright (c) 2012 Readmill Network LTD. All rights reserved.
//

#import "ReadmillPingTests.h"
#import "ReadmillPing.h"
#import "ReadmillReadingSession.h"
#import "ReadmillAPIWrapper+Internal.h"
#import "ReadmillRequestOperation.h"

@implementation ReadmillPingTests

- (void)setUp
{
    ReadmillAPIConfiguration *apiConf = [ReadmillAPIConfiguration configurationForStagingWithClientID:@"a" 
                                                                                         clientSecret:@"b"
                                                                                          redirectURL:nil];
    ReadmillAPIWrapper *wrapper = [[ReadmillAPIWrapper alloc] initWithAPIConfiguration:apiConf];
    mockWrapper = [[OCMockObject partialMockForObject:wrapper] retain];
    
    
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"reading47783"
                                                                      ofType:@"json"];
    
    NSData *data = [NSData dataWithContentsOfFile:path];    
    NSDictionary *readingDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    reading = [[ReadmillReading alloc] initWithAPIDictionary:readingDictionary
                                                  apiWrapper:mockWrapper];
    [super setUp];
}

- (void)tearDown
{
    // Tear-down code here.
    [mockWrapper release];
    [reading release];
    [super tearDown];
}

- (void)testReadingSessionSendPing
{
    ReadmillReadingSession *session = [reading createReadingSession];
    
    ReadmillPingDuration duration = 4711;
    CLLocationDegrees lat = 0.4711;
    CLLocationDegrees lng = 0.17;
    
    [[mockWrapper expect] pingReadingWithId:[reading readingId]
                               withProgress:[reading progress]
                          sessionIdentifier:[session sessionIdentifier]
                                   duration:duration
                             occurrenceTime:[OCMArg isNotNil]
                                   latitude:lat
                                  longitude:lng
                          completionHandler:OCMOCK_ANY];
    
    [session pingWithProgress:[reading progress] 
                 pingDuration:duration
                     latitude:lat
                    longitude:lng
                     delegate:nil];
    
    [mockWrapper verify];
}

- (void)testReadingSessionPingFail
{
    ReadmillReadingSession *session = [reading createReadingSession];
    
    id mockReadingSession = [OCMockObject partialMockForObject:session];
    id mockPingDelegate = [OCMockObject mockForProtocol:@protocol(ReadmillPingDelegate)];

    ReadmillPingDuration duration = 4711;
    
    // Expect startPreparedRequest:completion: to be called and inject our own handler
    [[[mockWrapper expect] andDo:^(NSInvocation *invocation) {
        ReadmillAPICompletionHandler completionBlock;
        [invocation getArgument:&completionBlock atIndex:3];
        completionBlock(nil, [NSError errorWithDomain:NSURLErrorDomain code:400 userInfo:nil]);
    }] startPreparedRequest:OCMOCK_ANY completion:OCMOCK_ANY];
    
    // Expect the session to archive the failed ping
    [[mockReadingSession expect] archiveFailedPing:[OCMArg checkWithBlock:^BOOL(ReadmillPing *ping) {
        if ([ping readingId] != [reading readingId]) {
            return NO;
        } else if ([ping progress] != [reading progress]) {
            return NO;
        } else if (1 < [[ping occurrenceTime] timeIntervalSinceDate:[NSDate date]]) {
            return NO;
        } else if ([ping duration] != duration) {
            return NO;
        }
        return YES;
    }]];
    
    // Ping failed so delegate should not be notified of successful ping
    [[mockPingDelegate reject] readmillReadingSessionDidPingSuccessfully:session];
    // Ping failed so delegate should be notified of successful ping
    [[mockPingDelegate expect] readmillReadingSession:session didFailToPingWithError:OCMOCK_ANY];

    // Do the actual ping
    [mockReadingSession pingWithProgress:[reading progress] 
                            pingDuration:duration
                                delegate:mockPingDelegate];
    [mockWrapper verify];
    [mockReadingSession verify];
    // Timeout since the delegate callback is asynchronous
    [mockPingDelegate verifyWithTimeout:1];
}
- (void)testReadingSessionPingSuccess
{
    ReadmillReadingSession *session = [reading createReadingSession];
    
    id mockReadingSession = [OCMockObject partialMockForObject:session];
    id mockPingDelegate = [OCMockObject mockForProtocol:@protocol(ReadmillPingDelegate)];
    
    ReadmillPingDuration duration = 4711;
    
    // Expect startPreparedRequest:completion: to be called and inject our own handler
    [[[mockWrapper expect] andDo:^(NSInvocation *invocation) {
        ReadmillAPICompletionHandler completionBlock;
        [invocation getArgument:&completionBlock atIndex:3];
        // Return empty dictionary and nil error
        completionBlock([NSDictionary dictionary], nil);
    }] startPreparedRequest:OCMOCK_ANY completion:OCMOCK_ANY];
    
    // Ping succeeded so don't archive
    [[mockReadingSession reject] archiveFailedPing:OCMOCK_ANY];
    // Ping succeeded so try to ping archived
    [[mockReadingSession expect] pingArchived];
    
    // Ping succeeded so delegate should be notified of successful ping
    [[mockPingDelegate expect] readmillReadingSessionDidPingSuccessfully:session];
    // Ping succeeded so delegate should not be notified of failed ping
    [[mockPingDelegate reject] readmillReadingSession:session didFailToPingWithError:OCMOCK_ANY];
    
        // Do the actual ping
    [mockReadingSession pingWithProgress:[reading progress] 
                            pingDuration:duration
                                delegate:mockPingDelegate];
    [mockWrapper verify];
    [mockReadingSession verify];
    // Timeout since the delegate callback is asynchronous
    [mockPingDelegate verifyWithTimeout:1];
}


@end
