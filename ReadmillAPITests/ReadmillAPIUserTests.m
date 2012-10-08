//
//  ReadmillAPIUserTests.m
//  ReadmillAPI
//
//  Created by Martin Hwasser on 10/8/12.
//  Copyright (c) 2012 Readmill Network LTD. All rights reserved.
//

#import "ReadmillAPIUserTests.h"

/* User JSON
{
    "user": {
        "id": 49,
        "username": "martinhwasser",
        "firstname": "Martin",
        "lastname": "Hwasser",
        "fullname": "Martin Hwasser",
        "country": "Sweden",
        "city": "Stockholm",
        "created_at": "2011-02-07T08:58:57Z",
        "website": "http://readmill.com",
        "description": "A weak spot for fable-like short stories and sharp thrillers.",
        "permalink_url": "https://readmill.com/martinhwasser",
        "books_interesting_count": 6,
        "books_reading_count": 4,
        "books_finished_count": 23,
        "books_abandoned_count": 3,
        "avatar_url": "https://readmill-assets.s3.amazonaws.com/avatars/a17ce8654460b79e93f58fa1fcb4a9ad-medium.png?1305149769",
        "followers_count": 96,
        "followings_count": 115
    },
    "status": 200
}
*/

@implementation ReadmillAPIUserTests

- (void)setUp
{
    [super setUp];
    
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"user49"
                                                                      ofType:@"json"];
    
    NSData *data = [NSData dataWithContentsOfFile:path];
    self.apiResponse = [data objectFromJSONData];
}

- (void)tearDown
{
    // Tear-down code here.
    [_apiResponse release];
    [super tearDown];
}

- (void)testCreateUser
{
    ReadmillUser *user = [[ReadmillUser alloc] initWithAPIDictionary:self.apiResponse
                                                          apiWrapper:nil];
    
    STAssertTrue([user userId] == 49, @"userId is wrong: %d", [user userId]);
    STAssertTrue([[user userName] isEqualToString:@"martinhwasser"], @"userName is wrong: %@", [user userName]);
    STAssertTrue([[user country] isEqualToString:@"Sweden"], @"country is wrong: %@", [user country]);
    STAssertTrue([[user fullName] isEqualToString:@"Martin Hwasser"], @"fullName is wrong: %@", [user fullName]);
    STAssertTrue([[user city] isEqualToString:@"Stockholm"], @"city is wrong: %@", [user city]);
    STAssertTrue([[user userDescription] isEqualToString:@"A weak spot for fable-like short stories and sharp thrillers."], @"description is wrong: %@", [user userDescription]);
    STAssertTrue([user followerCount] == 96, @"followerCount is wrong: %d", [user followerCount]);
    STAssertTrue([user followingCount] == 115, @"followingCount is wrong: %d", [user followingCount]);
    STAssertTrue([user booksInterestingCount] == 6, @"booksInterestingCount is wrong: %d", [user booksInterestingCount]);
    STAssertTrue([user booksAbandonedCount] == 3, @"booksAbandoned is wrong: %d", [user booksAbandonedCount]);
    STAssertTrue([user booksFinishedCount] == 23, @"booksFinishedCount is wrong: %d", [user booksFinishedCount]);
    STAssertTrue([user booksReadingCount] == 4, @"booksReadingCount is wrong: %d", [user booksReadingCount]);
}

@end
