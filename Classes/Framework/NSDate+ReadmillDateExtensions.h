//
//  NSDate+ReadmillDateExtensions.h
//  ReadmillAPI
//
//  Created by Martin Hwasser on 10/27/11.
//  Copyright (c) 2011 Readmill Network Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (ReadmillDateExtensions)

- (NSString *)stringWithRFC3339Format;
@end
