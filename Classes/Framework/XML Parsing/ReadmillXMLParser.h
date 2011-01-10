//
//  ReadmillXMLParser.h
//  Readmill Framework
//
//  Created by Work on 10/01/2011.
//  Copyright 2011 KennettNet Software Limited. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ReadmillXMLParser : NSObject {
@private
    
}

+(NSDictionary *)dictionaryForXMLData:(NSData *)data error:(NSError **)error;

@end
