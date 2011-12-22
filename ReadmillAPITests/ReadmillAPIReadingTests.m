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
#import "OCMock.h"

#define kTimeoutInterval 30

@implementation ReadmillAPIReadingTests 

- (void)setUp
{
    [super setUp];
    
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"reading22533"
                                                                      ofType:@"json"];
    
    NSData *data = [NSData dataWithContentsOfFile:path];    
    readingDictionary = [[data objectFromJSONData] retain];
}

- (void)tearDown
{
    // Tear-down code here.
    [readingDictionary release];
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
    /*
     "user": {
     "id": 922,
     "username": "yannifx",
     "firstname": "Yanni",
     "fullname": "Yanni Fx",
     "avatar_url": "https://readmill.com/assets/default-avatar-medium-1e82437e138e4a39da3bb38d10645f25.png",
     "followers": 3,
     "followings": 1,
     "uri": "https://api.readmill.com/users/922",
     "permalink_url": "https://readmill.com/yannifx"
     },

     */
    ReadmillReading *reading = [[[ReadmillReading alloc] initWithAPIDictionary:readingDictionary 
                                                                    apiWrapper:nil] autorelease];
    
    ReadmillUser *user = [reading user];
    STAssertNotNil(user, @"User is nil!");
    STAssertTrue([user userId] == 922, @"User id wrong: %d", [user userId]);
    STAssertTrue([[user userName] isEqualToString:@"yannifx"], @"Wrong userName");
    STAssertTrue([[user firstName] isEqualToString:@"Yanni"], @"Wrong firstName");
    STAssertTrue([[user fullName] isEqualToString:@"Yanni Fx"], @"User name wrong: %@.", [user fullName]);
    STAssertTrue([[user avatarURL] isEqual:[NSURL URLWithString:@"https://readmill.com/assets/default-avatar-medium-1e82437e138e4a39da3bb38d10645f25.png"]], @"Wrong avatar url");
    STAssertTrue([user followerCount] == 3, @"Follower count is wrong");
    STAssertTrue([user followingCount] == 1, @"Following count is wrong");
    STAssertTrue([[user permalinkURL] isEqual:[NSURL URLWithString:@"https://readmill.com/yannifx"]], @"permalink is wrong");
}

- (void)testUpdateReading
{
    id mockReading = [OCMockObject mockForClass:[ReadmillReading class]];
    
    [[[mockReading expect] andCall:@selector(readmillReading:didFailToUpdateMetadataWithError:) onObject:nil] updateWithState:ReadingStateInteresting
                                                                                                                    isPrivate:NO 
                                                                                                                closingRemark:nil
                                                                                                                     delegate:nil];
    
    ReadmillReading *reading = [[[ReadmillReading alloc] initWithAPIDictionary:readingDictionary 
                                                                    apiWrapper:nil] autorelease];
    [reading updateState:ReadingStateInteresting delegate:nil];
    
    [mockReading verify];
}


@end
