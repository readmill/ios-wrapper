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

-(NSString *)urlDecodedString {
    
    CFStringRef str = CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL,
                                                                              (CFStringRef)self,
                                                                              CFSTR(""),
                                                                              kCFStringEncodingUTF8);
    
    NSString *decodedString = [NSString stringWithString:(NSString *)str];
    
    CFRelease(str);
    
    return decodedString;
}

@end
