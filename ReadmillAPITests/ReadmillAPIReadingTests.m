//
//  ReadmillAPITests.m
//  ReadmillAPITests
//
//  Created by Martin Hwasser on 4/16/11.
//  Copyright 2011 Readmill. All rights reserved.
//

#import "ReadmillAPIReadingTests.h"
#import "JSONKit.h"
#import "ReadmillAPI.h"
//#import "OCMock.h"

#define kTimeoutInterval 30

@implementation ReadmillAPIReadingTests

- (void)setUp
{
    [super setUp];
    
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"reading22533"
                                                                      ofType:@"json"];
    
    NSData *data = [NSData dataWithContentsOfFile:path];    
    readingDictionary = [data objectFromJSONData];
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testCreateReading
{        
    ReadmillReading *reading = [[[ReadmillReading alloc] initWithAPIDictionary:readingDictionary 
                                                                    apiWrapper:nil] autorelease];
     
    STAssertTrue([reading readingId] == 22533, @"ReadingId is wrong: %d", [reading readingId]);
}
- (void)testUser
{
    ReadmillReading *reading = [[[ReadmillReading alloc] initWithAPIDictionary:readingDictionary 
                                                                    apiWrapper:nil] autorelease];
    
    ReadmillUser *user = [reading user];
    STAssertNotNil(user, @"User is nil!");
    STAssertTrue([[user fullName] isEqualToString:@"Yanni Fx"], @"User name wrong: %@.", [user fullName]);
}
@end
