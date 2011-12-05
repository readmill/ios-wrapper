//
//  ReadmillAPIConfiguration.h
//  ReadmillAPI
//
//  Created by Martin Hwasser on 10/31/11.
//  Copyright (c) 2011 Readmill Network Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString * const kLiveAPIEndPoint = @"https://api.readmill.com/";
static NSString * const kLiveAuthorizationUri = @"https://m.readmill.com/";

static NSString * const kStagingAPIEndPoint = @"http://api.stage-readmill.com/";
static NSString * const kStagingAuthorizationUri = @"http://m.stage-readmill.com/";

@interface ReadmillAPIConfiguration : NSObject <NSCoding> {

    NSURL *accessTokenURL;
    NSURL *apiBaseURL;
	NSURL *authURL;
	
	NSString *clientID;
	NSString *clientSecret;
	NSURL *redirectURL;
}

@property (nonatomic, retain) NSURL *accessTokenURL;
@property (nonatomic, retain) NSURL *apiBaseURL;
@property (nonatomic, retain) NSURL *authURL;

@property (nonatomic, copy) NSString *clientID;
@property (nonatomic, copy) NSString *clientSecret;
@property (nonatomic, retain) NSURL *redirectURL;


+ (id)configurationForProductionWithClientID:(NSString *)clientID
                                clientSecret:(NSString *)clientSecret
                                 redirectURL:(NSURL *)redirectURL;

+ (id)configurationForStagingWithClientID:(NSString *)clientID
                             clientSecret:(NSString *)clientSecret
                              redirectURL:(NSURL *)redirectURL;


- (id)initWithClientID:(NSString *)clientID
          clientSecret:(NSString *)clientSecret
           redirectURL:(NSURL *)redirectURL
            apiBaseURL:(NSURL *)apiBaseURL
               authURL:(NSURL *)authURL;

@end
