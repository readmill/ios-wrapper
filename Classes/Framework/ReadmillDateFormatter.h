//
//  ReadmillDateFormatter.h
//  ReadmillAPI
//
//  Created by Martin Hwasser on 11/2/11.
//  Copyright (c) 2011 Readmill Network Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ReadmillDateFormatter : NSDateFormatter

+ (ReadmillDateFormatter *)formatterWithRFC3339Format;
@end
