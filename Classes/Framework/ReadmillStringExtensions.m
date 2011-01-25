//
//  Extensions.m
//  Readmill Framework
//
//  Created by Readmill on 10/01/2011.
//  Copyright 2011 Readmill. All rights reserved.
//

#import "ReadmillStringExtensions.h"


@implementation NSString (ReadmillStringExtensions)

-(NSString *)urlEncodedString {
	
	CFStringRef str = CFURLCreateStringByAddingPercentEscapes(NULL,
															  (CFStringRef)self,
															  NULL,
															  (CFStringRef)@"!*'();:@&=+$,/?%#[]",
															  kCFStringEncodingUTF8);
	
	NSString *unencodedString = [NSString stringWithString:(NSString *)str];	
	
	CFRelease(str);
	
	return unencodedString;
}

@end
