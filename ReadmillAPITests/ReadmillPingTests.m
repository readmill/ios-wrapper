//
//  ReadmillPingTests.m
//  ReadmillAPI
//
//  Created by Martin Hwasser on 1/18/12.
//  Copyright (c) 2012 Readmill Network LTD. All rights reserved.
//

#import "ReadmillPingTests.h"
#import "ReadmillAPI.h"
#import "ReadmillPing.h"
#import "ReadmillReadingSession+Internal.h"
#import "ReadmillAPIWrapper+Internal.h"
#import "ReadmillURLConnection.h"
#import "JSONKit.h"
#import "OCMock.h"

@implementation ReadmillPingTests

- (void)setUp
{
    ReadmillAPIConfiguration *apiConf = [ReadmillAPIConfiguration configurationForStagingWithClientID:@"a" 
                                                                                         clientSecret:@"b"
                                                                                          redirectURL:nil];
    ReadmillAPIWrapper *wrapper = [[ReadmillAPIWrapper alloc] initWithAPIConfiguration:apiConf];
    mockWrapper = [[OCMockObject partialMockForObject:wrapper] retain];
    
    
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"reading22533"
                                                                      ofType:@"json"];
    
    NSData *data = [NSData dataWithContentsOfFile:path];    
    NSDictionary *readingDictionary = [[data objectFromJSONData] retain];
    
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
    
    [[mockWrapper expect] pingReadingWithId:[reading readingId]
                               withProgress:[reading progress]
                          sessionIdentifier:[session sessionIdentifier]
                                   duration:duration
                             occurrenceTime:[OCMArg isNotNil]
                                   latitude:0
                                  longitude:0
                          completionHandler:OCMOCK_ANY];
    
    [session pingWithProgress:[reading progress] 
                 pingDuration:duration
                     delegate:nil];
    
    [mockWrapper verify];
}

- (void)testReadingSessionArchivesPingOnFail
{
    ReadmillReadingSession *session = [reading createReadingSession];
    
    id mockReadingSession = [OCMockObject partialMockForObject:session];
    ReadmillPingDuration duration = 4711;
    
    [[[mockWrapper expect] andDo:^(NSInvocation *invocation) {
        ReadmillAPICompletionHandler handler;
        [invocation getArgument:&handler atIndex:3];
        handler(nil, [NSError errorWithDomain:NSURLErrorDomain code:400 userInfo:nil]);
    }] startPreparedRequest:OCMOCK_ANY completion:OCMOCK_ANY];
    
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
    
    [mockReadingSession pingWithProgress:[reading progress] 
                            pingDuration:duration
                                delegate:nil];
    [mockWrapper verify];
    [mockReadingSession verify];
}

@end
