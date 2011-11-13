//
//  ReadmillAPITests.m
//  ReadmillAPITests
//
//  Created by Martin Hwasser on 4/16/11.
//  Copyright 2011 Readmill. All rights reserved.
//

#import "ReadmillAPITests.h"
#import "ReadmillAPI.h"

@implementation ReadmillAPITests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
    ReadmillAPIConfiguration *apiConfiguration;
    apiConfiguration = [ReadmillAPIConfiguration configurationForStagingWithClientID:@"e09c966d93341f0518b6e18a49644a43" 
                                                                        clientSecret:@"a96949a97ab737b326a0e2fed334c49c"
                                                                         redirectURL:nil];
    
    apiWrapper = [[ReadmillAPIWrapper alloc] initWithAPIConfiguration:apiConfiguration];
}

- (void)tearDown
{
    // Tear-down code here.
    [apiWrapper release];
    
    [super tearDown];
}

- (void)testUser
{
    [apiWrapper userWithId:49 
         completionHandler:^(id userDictionary, NSError *error) {
             ReadmillUser *user = [[ReadmillUser alloc] initWithAPIDictionary:userDictionary 
                                                                apiWrapper:apiWrapper];
             STAssertEquals([user fullName], @"Martin Hwasser", @"User name is wrong!");
             [user release];          
      }];
}
- (void)testFindBookWithId 
{    
    [apiWrapper bookMatchingTitle:@"The Metamorphosis" 
                completionHandler:^(id result, NSError *error) {
                    //
                    STAssertNotNil(result, @"Book is nil!");
                }];
}
- (void)testFindBookWithTitle 
{    
    NSString *bookTitle = @"Alice's Adventures in Wonderland";
    [apiWrapper bookMatchingTitle:bookTitle 
                completionHandler:^(id books, NSError *error) {
                    // Did we find at least one book?
                    NSLog(@"books: %@", books);
                    STAssertTrue([books count] > 0, [NSString stringWithFormat:@"Didn't find %@", bookTitle]);
                    ReadmillBook *book = [[ReadmillBook alloc] initWithAPIDictionary:[books objectAtIndex:0]];
                    
                    // Test that we got the book and that the mapping was correct.
                    STAssertTrue([bookTitle isEqualToString:[book title]], @"Not the same name.");
                    
                    [book release]; 
                }];    
}
- (void)testFindReading
{    
    [apiWrapper publicReadingsForUserWithId:49 
                          completionHandler:^(id readings, NSError *error) {
                              STAssertTrue(0 < [readings count], @"No readings for user.");
                          }];
}
@end
