/*
 Copyright (c) 2011 Readmill LTD
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */

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
 @param apiDict The NSDictionary object describing the book.
 @result The updated book.
 @brief   Update a ReadmillBook object from a book dictionary from a ReadmillAPIWrapper object.
 */
- (void)updateWithAPIDictionary:(NSDictionary *)apiDict;

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
