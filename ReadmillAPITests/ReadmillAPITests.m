//
//  ReadmillAPITests.m
//  ReadmillAPITests
//
//  Created by Martin Hwasser on 4/16/11.
//  Copyright 2011 Readmill. All rights reserved.
//

#import "ReadmillAPITests.h"
#import <ReadmillAPI/ReadmillBook.h>
#import <ReadmillAPI/ReadmillUser.h>

@implementation ReadmillAPITests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
    wrapper = [[ReadmillAPIWrapper alloc] initWithStagingEndPoint];
}

- (void)tearDown
{
    // Tear-down code here.
    [wrapper release];
    
    [super tearDown];
}

- (void)testUser
{
    NSDictionary *userDict = [wrapper userWithId:18 
                                           error:nil];
    
    NSLog(@"user: %@", userDict);

    STAssertNotNil(userDict, @"User is nil!");
    
    ReadmillUser *user = [[ReadmillUser alloc] initWithAPIDictionary:userDict apiWrapper:wrapper];
    
    [user release];
}
- (void)testFindBookWithId {
    
    NSDictionary *bookDict = [wrapper bookWithId:1 
                                           error:nil];
    STAssertNotNil(bookDict, @"Book is nil!");
}
- (void)testFindBookWithTitle {
    
    NSString *bookTitle = @"Alice's Adventures in Wonderland";
    NSArray *books = [wrapper booksMatchingTitle:bookTitle
                                           error:nil];
    
    // Did we find at least one book?
    STAssertTrue([books count] > 0, [NSString stringWithFormat:@"Didn't find %@", bookTitle]);
    
    ReadmillBook *book = [[ReadmillBook alloc] initWithAPIDictionary:[books objectAtIndex:0]];
        
    // Test that we got the book and that the mapping was correct.
    STAssertTrue([bookTitle isEqualToString:[book title]], @"Not the same name.");
    
    [book release];
}
- (void)testFindRead {
    
    // Alice in wonderland
    NSArray *reads = [wrapper publicReadingsForUserWithId:18 
                                                    error:nil];
    
    NSLog(@"reads: %@", reads);
    STAssertTrue(0 < [reads count], @"No reads for user.");
}
@end
