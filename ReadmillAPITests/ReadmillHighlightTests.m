//
//  ReadmillHighlightTests.m
//  ReadmillAPI
//
//  Created by Martin Hwasser on 1/19/12.
//  Copyright (c) 2012 Readmill Network LTD. All rights reserved.
//

#import "ReadmillHighlightTests.h"
#import "ReadmillAPIWrapper+Internal.h"
#import "NSString+ReadmillAdditions.h"

@implementation ReadmillHighlightTests

- (void)setUp
{
    ReadmillAPIConfiguration *apiConf = [ReadmillAPIConfiguration configurationForStagingWithClientID:@"a" 
                                                                                         clientSecret:@"b"
                                                                                          redirectURL:nil];
    ReadmillAPIWrapper *wrapper = [[ReadmillAPIWrapper alloc] initWithAPIConfiguration:apiConf];
    mockWrapper = [[OCMockObject partialMockForObject:wrapper] retain];

    [super setUp];
}
- (void)tearDown
{
    [super tearDown];
}

- (void)testPostHighlightParameters
{    
    ReadmillReadingProgress progress = 0.4711;
    NSDictionary *locators = [NSDictionary dictionaryWithObjectsAndKeys:
                              @"pre", kReadmillAPIHighlightPreKey,
                              @"mid", kReadmillAPIHighlightMidKey,
                              @"post", kReadmillAPIHighlightPostKey, nil];
    
    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:-100];
    NSString *comment = @"a comment";
    
    NSArray *connections = @[@1, @2, @3];
    
    void (^theBlock)(NSInvocation *) = ^(NSInvocation *invocation) {
        // Get the input parameters
        NSDictionary *allParameters;
        [invocation getArgument:&allParameters atIndex:3];
        
        NSDictionary *highlightParameters = [allParameters valueForKey:kReadmillAPIHighlightKey];
        STAssertNotNil([highlightParameters valueForKey:kReadmillAPIHighlightLocatorsKey], @"Highlight locators nil");
        STAssertNotNil([allParameters valueForKey:kReadmillAPIHighlightCommentKey], @"Comment is missing");
        
        NSDate *highlightDate = [[highlightParameters valueForKey:kReadmillAPIHighlightHighlightedAtKey] dateWithRFC3339Formatting];
        NSTimeInterval timeInterval = [date timeIntervalSinceDate:highlightDate];
        // The time difference can be off by a few seconds since date comparison
        // uses subseconds, but dateFromString (dateWithRFC3339Formatting does not)
        STAssertTrue(timeInterval < 1, @"Difference between dates: %f", timeInterval);
        
        // Check that comment is outside of the highlight scope inside comment[content]
        NSString *commentParameter = [[allParameters valueForKey:kReadmillAPIHighlightCommentKey] valueForKey:kReadmillAPICommentContentKey];
        STAssertTrue([commentParameter isEqualToString:comment], @"Comment is wrong: %@", commentParameter);
        
        // Check the count (since we're doing some other stuff like making it a dictionary)
        NSArray *postToParameters = [highlightParameters valueForKey:kReadmillAPIHighlightPostToKey];
        STAssertTrue([postToParameters count] == [connections count], @"Connection count is wrong: %d", [postToParameters count]);
    };

    // Inject our block 
    [[[mockWrapper expect] andDo:theBlock] sendPostRequestToEndpoint:OCMOCK_ANY
                                                      withParameters:OCMOCK_ANY
                                                   completionHandler:OCMOCK_ANY];

    // Create the highlight
    [mockWrapper createHighlightForReadingWithId:4711 
                                 highlightedText:@"abc"
                                        locators:locators 
                                        position:progress 
                                   highlightedAt:date 
                                         comment:comment
                                     connections:connections
                                isCopyRestricted:NO
                               completionHandler:nil];
    [mockWrapper verify];
}

@end
