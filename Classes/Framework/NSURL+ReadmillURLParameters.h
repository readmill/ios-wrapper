//
//  ReadmillURLExtensions.h
//  Readmill
//
//  Created by Martin Hwasser on 4/9/11.
//  Copyright 2011 Readmill. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSURL (ReadmillURLParameters)
+ (NSURL *)URLWithParameters:(NSDictionary *)parameters;
- (NSURL *)URLByAddingParameters:(NSDictionary *)parameters;
- (NSDictionary *)queryAsDictionary;
@end
