//
//  ReadmillErrorExtensions.h
//  ReadmillFramework
//
//  Created by Martin Hwasser on 5/13/11.
//  Copyright 2011 KennettNet Software Limited. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSError (ReadmillErrorExtensions)

- (BOOL)isReadmillClientError;
@end
