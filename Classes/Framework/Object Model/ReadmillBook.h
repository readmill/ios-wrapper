//
//  ReadmillBook.h
//  Readmill Framework
//
//  Created by Readmill on 12/01/2011.
//  Copyright 2011 Readmill. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ReadmillAPIWrapper.h"

@interface ReadmillBook : NSObject {
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

-(id)initWithAPIDictionary:(NSDictionary *)apiDict;

@property (readonly, copy) NSString *author;
@property (readonly, copy) NSString *isbn;
@property (readonly, copy) NSString *language;
@property (readonly, copy) NSString *summary;
@property (readonly, copy) NSString *title;

@property (readonly, copy) NSURL *coverImageURL;
@property (readonly, copy) NSURL *metaDataURL;
@property (readonly, copy) NSURL *permalinkURL;

@property (readonly) ReadmillBookId bookId;
@property (readonly) ReadmillBookId rootEditionId;

@property (readonly, copy) NSDate *datePublished;



@end
