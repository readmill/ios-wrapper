//
//  Constants.h
//  Readmill Framework
//
//  Created by Work on 10/01/2011.
//  Copyright 2011 KennettNet Software Limited. All rights reserved.
//

#import <Cocoa/Cocoa.h>


static NSString * const kLiveAPIEndPoint = @"http://api.readmill.com/";
static NSString * const kStagingAPIEndPoint = @"http://api.stage-readmill.com/";

static NSString * const kXMLParseError = @"com.readmill.xmlParseError";
static NSString * const kXMLParseErrorDescription = @"The response from the server was invalid. Please try again.";

// OAuth

static NSString * const kLiveAuthorizationUri = @"http://readmill.com/";
static NSString * const kStagingAuthorizationUri = @"http://stage-readmill.com/";

static NSString * const kClientSecret = @"750452e5fc0c20531e94f44215475094";
static NSString * const kClientId = @"99dce8a929298cb95e534e86861db6de";

static NSTimeInterval const kAccessTokenTTL = 3600.0; 

