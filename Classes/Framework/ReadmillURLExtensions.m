//
//  ReadmillURLExtensions.m
//  Readmill
//
//  Created by Martin Hwasser on 4/9/11.
//  Copyright 2011 Readmill. All rights reserved.
//

#import "ReadmillURLExtensions.h"
#import "ReadmillStringExtensions.h"

@implementation NSURL (ReadmillURLExtensions)

+ (NSURL *)URLWithParameters:(NSDictionary *)parameters {
    NSMutableString *parameterString = [NSMutableString string];
    BOOL first = YES;
    for (NSString *key in [parameters allKeys]) {		
		
		id value = [parameters valueForKey:key];
		
		if (value) {
			[parameterString appendFormat:@"%@%@=%@",
             first ? @"?" : @"&", 
             key, 
             [value isKindOfClass:[NSString class]] ? [value urlEncodedString] : [[value stringValue] urlEncodedString]];
			first = NO;
		}		
	}
    return [NSURL URLWithString:parameterString];
}
- (NSURL *)URLByAddingParameters:(NSDictionary *)parameters {

    NSString *URLString = [self absoluteString];
    return [NSURL URLWithString:[URLString stringByAppendingString:[[NSURL URLWithParameters:parameters] absoluteString]]];
}
- (NSDictionary *)queryAsDictionary {
    NSArray *parameters = [[self query] componentsSeparatedByString:@"&"];
    NSMutableDictionary *parametersDictionary = [NSMutableDictionary dictionaryWithCapacity:[parameters count]];
    for (NSString *parameter in parameters) {
        NSArray *kvp = [parameter componentsSeparatedByString:@"="];
        NSString *key = [[kvp objectAtIndex:0] urlDecodedString];
        NSString *value = [[kvp objectAtIndex:1] urlDecodedString];
        [parametersDictionary setValue:value forKey:key];
    }
    return parametersDictionary;
}
@end