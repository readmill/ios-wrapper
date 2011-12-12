//
//  ReadmillErrorExtensions.h
//  ReadmillAPI
//
//  Created by Martin Hwasser on 5/13/11.
//  Copyright 2011 Readmill Network Limited. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSError (ReadmillAdditions)

- (BOOL)isReadmillDomain;
- (BOOL)isClientError;

@end
