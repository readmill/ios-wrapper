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
    
    NSDate *date = [NSDate date];
    
    void (^theBlock)(NSInvocation *) = ^(NSInvocation *invocation) {
        NSDictionary *allParameters;
        [invocation getArgument:&allParameters atIndex:3];
        NSDictionary *highlightParameters = [allParameters valueForKey:kReadmillAPIHighlightKey];
        STAssertNotNil([highlightParameters valueForKey:kReadmillAPIHighlightLocatorsKey], @"Highlight locators nil");
        STAssertNotNil([allParameters valueForKey:kReadmillAPIHighlightCommentKey], @"Comment is missing");        
        NSDate *highlightDate = [[highlightParameters valueForKey:kReadmillAPIHighlightHighlightedAtKey] dateWithRFC3339Formatting];
        STAssertTrue([highlightDate timeIntervalSinceDate:date] < 1, @"Difference between dates");
    };

    // Inject our block 
    [[[mockWrapper expect] andDo:theBlock] sendPostRequestToURL:OCMOCK_ANY
                                                 withParameters:OCMOCK_ANY
                                     shouldBeCalledUnauthorized:NO
                                              completionHandler:OCMOCK_ANY];

    // Create the highlight
    [mockWrapper createHighlightForReadingWithId:4711 
                                 highlightedText:@"abc"
                                        locators:locators 
                                        progress:progress 
                                   highlightedAt:date 
                                         comment:@"a comment" 
                                     connections:nil 
                               completionHandler:nil];
    [mockWrapper verify];
}

@end
