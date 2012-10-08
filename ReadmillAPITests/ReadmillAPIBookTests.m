//
//  ReadmillAPIBookTests.m
//  ReadmillAPI
//
//  Created by Martin Hwasser on 10/8/12.
//  Copyright (c) 2012 Readmill Network LTD. All rights reserved.
//

#import "ReadmillAPIBookTests.h"
#import "ReadmillBook.h"

/* JSON Data 
{
    "book": {
        "id": 23,
        "title": "Metamorphosis",
        "author": "Franz Kafka",
        "identifier": "1435726197",
        "story": "Classic story of self-discovery, told in a unique manner by Kafka.",
        "published_at": "2008-06-25",
        "language": "en",
        "permalink": "metamorphosis",
        "permalink_url": "http://stage-readmill.com/books/metamorphosis",
        "cover_url": "https://readmill-staging-assets.s3.amazonaws.com/covers/87eaa1acb1962e72d5972f0721484b0b-medium.png?1343832985",
        "assets": {
            "items": [
                      {
                          "asset": {
                              "vendor": "feedbooks",
                              "uri": "http://www.feedbooks.com/book/8.epub",
                              "acquisition_type": "direct"
                          }
                      },
                      {
                          "asset": {
                              "vendor": "feedbooks",
                              "uri": "http://www.feedbooks.com/book/8",
                              "acquisition_type": "direct"
                          }
                      }
                      ]
        }
    },
    "status": 200
}
*/

@implementation ReadmillAPIBookTests

- (void)setUp
{
    [super setUp];
    
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"book23"
                                                                      ofType:@"json"];
    
    NSData *data = [NSData dataWithContentsOfFile:path];
    self.apiResponse = [[data objectFromJSONData] retain];
}

- (void)tearDown
{
    // Tear-down code here.
    [_apiResponse release];
    [super tearDown];
}

- (void)testCreateBook
{
    ReadmillBook *book = [[[ReadmillBook alloc] initWithAPIDictionary:self.apiResponse] autorelease];
    STAssertTrue(book.bookId == 23, @"BookId is wrong: %d", [book bookId]);
    STAssertTrue([book.title isEqualToString:@"Metamorphosis"],
                 @"Title is is wrong: %@", [book title]);
    STAssertTrue([book.author isEqualToString:@"Franz Kafka"],
                 @"Author is is wrong: %@", [book author]);
    STAssertTrue([book.identifier isEqualToString:@"1435726197"], @"Identifier is wrong: %@", book.identifier);
    STAssertTrue([book.language isEqualToString:@"en"], @"Language is wrong: %@", book.language);
    STAssertTrue([book.permalinkURL.absoluteString isEqualToString:@"http://stage-readmill.com/books/metamorphosis"],
                  @"PermalinkURL is wrong: %@", book.permalinkURL);
}

@end
