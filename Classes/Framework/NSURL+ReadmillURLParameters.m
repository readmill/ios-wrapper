//
//  ReadmillURLExtensions.m
//  Readmill
//
//  Created by Martin Hwasser on 4/9/11.
//  Copyright 2011 Readmill. All rights reserved.
//

#import "NSURL+ReadmillURLParameters.h"
#import "NSString+ReadmillAdditions.h"
#import "NSDictionary+ReadmillAdditions.h"

@implementation NSURL (ReadmillURLParameters)

+ (NSURL *)URLWithParameters:(NSDictionary *)parameters
{
    return [NSURL URLWithString:[parameters urlParameterString]];
}

- (NSDictionary *)queryAsDictionary
{
    NSArray *parameters = [[self query] componentsSeparatedByString:@"&"];
    NSMutableDictionary *parametersDictionary = [NSMutableDictionary dictionaryWithCapacity:[parameters count]];
    for (NSString *parameter in parameters) {
        @autoreleasepool {
            NSArray *kvp = [parameter componentsSeparatedByString:@"="];
            if (kvp.count >= 2) {
                NSString *key = [[kvp objectAtIndex:0] urlDecodedString];
                NSString *value = [[kvp objectAtIndex:1] urlDecodedString];
                [parametersDictionary setValue:value forKey:key];
            }
        }
    }
    return parametersDictionary;
}

- (NSURL *)URLByAddingQueryParameters:(NSDictionary *)parameters
{
    // Note:this ensures duplicate parameters aren't added
    NSMutableDictionary *allParameters = [NSMutableDictionary dictionary];
    [allParameters addEntriesFromDictionary:[self queryAsDictionary]];
    [allParameters addEntriesFromDictionary:parameters];

    NSMutableArray *queryParameters = [NSMutableArray arrayWithCapacity:[allParameters count]];

    [allParameters enumerateKeysAndObjectsUsingBlock:^ (id key, id obj, BOOL *stop) {
        NSMutableString *parameter = [NSMutableString string];
        [parameter appendString:[key urlEncodedString]];
        [parameter appendString:@"="];
        if ([obj isKindOfClass:[NSString class]]) {
			[parameter appendString:[obj urlEncodedString]];
		} else if ([obj isKindOfClass:[NSNumber class]]) {
            [parameter appendString:[[obj stringValue] urlEncodedString]];
        }
        
        [queryParameters addObject:parameter];
	}];

    NSMutableString *absoluteURLString = [[self.absoluteString mutableCopy] autorelease];

    NSString *newQuery = [@"?" stringByAppendingString:[queryParameters componentsJoinedByString:@"&"]];

    if (self.query != nil) {
        NSRange queryRange = [absoluteURLString rangeOfString:self.query];
        queryRange.location--; // Note:remove the '?'
        queryRange.length++;
        [absoluteURLString replaceCharactersInRange:queryRange withString:newQuery];
    } else {
        // Insert before #fragment
        NSString *fragment = self.fragment;
        if (fragment != nil) {
            NSRange range = [absoluteURLString rangeOfString:fragment];
            range.location--; // Note:remove the '#'
            [absoluteURLString insertString:newQuery atIndex:range.location];
        } else {
            [absoluteURLString appendString:newQuery];
        }
    }
    return [NSURL URLWithString:absoluteURLString];
}

@end