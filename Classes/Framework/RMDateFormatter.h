//
//  RMDateFormatter.h
//  ReadmillAPI
//
//  Created by Martin Hwasser on 11/2/11.
//  Copyright (c) 2011 KennettNet Software Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RMDateFormatter : NSDateFormatter

+ (RMDateFormatter *)formatterWithRFC3339Format;
@end
