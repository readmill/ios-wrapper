//
//  ReadmillBook.h
//  Readmill Framework
//
//  Created by Readmill on 12/01/2011.
//  Copyright 2011 Readmill. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ReadmillAPIWrapper.h"

@interface ReadmillBook : NSObject <NSCoding> {
@private
    
    NSString *author;
    NSString *isbn;
    NSString *language;
    NSString *summary;
    NSString *title;
    
    NSURL *coverImageURL;
    NSURL *metaDataURL;
    NSURL *permalinkURL;
    
    ReadmillBookId bookId;
    ReadmillBookId rootEditionId;
    
    NSDate *datePublished;
}

/*!
 @param apiDict The NSDictionary object describing the book.
 @result The created book.
 @brief   Create a new ReadmillBook object from a book dictionary from a ReadmillAPIWrapper object.
 
 Note: The typical way of getting a ReadmillBook object is via the various convenience methods in the ReadmillUser class.
 */
-(id)initWithAPIDictionary:(NSDictionary *)apiDict;

/*!
 @property  author
 @brief The book's author. 
 */
@property (readonly, copy) NSString *author;

/*!
 @property  isbn
 @brief The book's ISBN.  
 */
@property (readonly, copy) NSString *isbn;

/*!
 @property  language
 @brief The book's language.
 */
@property (readonly, copy) NSString *language;

/*!
 @property  summary
 @brief The book's summary, typically in the form of a blurb.
 */
@property (readonly, copy) NSString *summary;

/*!
 @property  title
 @brief The book's title.
 */
@property (readonly, copy) NSString *title;

/*!
 @property  title
 @brief The book's publish date.
 */
@property (readonly, copy) NSDate *datePublished;

/*!
 @property  coverImageURL
 @brief A URL to an image of the book's cover.
 */
@property (readonly, copy) NSURL *coverImageURL;

/*!
 @property  metaDataURL
 @brief A URL to the book's metadata.
 */
@property (readonly, copy) NSURL *metaDataURL;

/*!
 @property  permalinkURL
 @brief A URL to the book in Readmill. Appropriate for linking the user to the book in their web browser.
 */
@property (readonly, copy) NSURL *permalinkURL;

/*!
 @property  bookId
 @brief The book's id in the Readmill system.
 */
@property (readonly) ReadmillBookId bookId;

/*!
 @property  rootEditionId
 @brief The id of the root edition of the book, if any.
 */
@property (readonly) ReadmillBookId rootEditionId;

@end
