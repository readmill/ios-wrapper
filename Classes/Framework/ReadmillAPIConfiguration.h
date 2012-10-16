//
//  ReadmillAPIConfiguration.h
//  ReadmillAPI
//
//  Created by Martin Hwasser on 10/31/11.
//  Copyright (c) 2011 Readmill Network Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

// API base URL
static NSString * const kReadmillLiveAPIBaseURLString = @"https://api.readmill.com/v2/";
static NSString * const kReadmillStagingAPIBaseURLString = @"http://api.stage-readmill.com/v2/";

// OAuth URL
static NSString * const kReadmillLiveAuthorizationURLString = @"https://m.readmill.com/";
static NSString * const kReadmillStagingAuthorizationURLString = @"http://m.stage-readmill.com/";

@interface ReadmillAPIConfiguration : NSObject <NSCoding>

@property (nonatomic, retain, readonly) NSURL *accessTokenURL;
@property (nonatomic, retain, readonly) NSURL *apiBaseURL;
@property (nonatomic, retain, readonly) NSURL *authURL;
@property (nonatomic, retain, readonly) NSURL *redirectURL;

@property (nonatomic, copy, readonly) NSString *clientID;
@property (nonatomic, copy, readonly) NSString *clientSecret;

@property (nonatomic, readonly) BOOL isConfiguredForProduction;

+ (id)configurationForProductionWithClientID:(NSString *)clientID
                                clientSecret:(NSString *)clientSecret
                                 redirectURL:(NSURL *)redirectURL;

+ (id)configurationForStagingWithClientID:(NSString *)clientID
                             clientSecret:(NSString *)clientSecret
                              redirectURL:(NSURL *)redirectURL;

@end
