//
//  ReadmillAPIConfiguration.m
//  ReadmillAPI
//
//  Created by Martin Hwasser on 10/31/11.
//  Copyright (c) 2011 Readmill Network LTD. All rights reserved.
//

#import "ReadmillAPIConfiguration.h"

@interface ReadmillAPIConfiguration ()

@property (nonatomic, retain, readwrite) NSURL *accessTokenURL;
@property (nonatomic, retain, readwrite) NSURL *apiBaseURL;
@property (nonatomic, retain, readwrite) NSURL *authURL;
@property (nonatomic, retain, readwrite) NSURL *redirectURL;

@property (nonatomic, copy, readwrite) NSString *clientID;
@property (nonatomic, copy, readwrite) NSString *clientSecret;

@property (nonatomic, readwrite) BOOL isConfiguredForProduction;

@end

@implementation ReadmillAPIConfiguration

- (id)initWithClientID:(NSString *)clientID
          clientSecret:(NSString *)clientSecret
           redirectURL:(NSURL *)redirectURL
          onProduction:(BOOL)onProduction
{
    NSAssert(clientID, @"No Client ID supplied");
	NSAssert(clientSecret, @"No Client Secret supplied");
	
	if (self = [super init]) {
        
        NSString *authURLString = onProduction ? kReadmillLiveAuthorizationURLString : kReadmillStagingAuthorizationURLString;
        NSString *apiBaseURLString = onProduction ? kReadmillLiveAPIBaseURLString : kReadmillStagingAPIBaseURLString;
        
        _accessTokenURL = [[NSURL URLWithString:[NSString stringWithFormat:@"%@oauth/token.json", authURLString]] retain];

		_apiBaseURL = [[NSURL URLWithString:apiBaseURLString ] retain];
		_authURL = [[NSURL URLWithString:authURLString] retain];
		
		_clientID = [clientID copy];
		_clientSecret = [clientSecret copy];
		_redirectURL = [redirectURL retain];
        
	}
	return self;
}

+ (id)configurationForProductionWithClientID:(NSString *)clientID clientSecret:(NSString *)clientSecret redirectURL:(NSURL *)redirectURL 
{
	return [[[self alloc] initWithClientID:clientID
                              clientSecret:clientSecret
                               redirectURL:redirectURL
                              onProduction:YES] autorelease];
}

+ (id)configurationForStagingWithClientID:(NSString *)clientID clientSecret:(NSString *)clientSecret redirectURL:(NSURL *)redirectURL 
{
    return [[[self alloc] initWithClientID:clientID
                             clientSecret:clientSecret
                              redirectURL:redirectURL
                              onProduction:NO] autorelease];
}

- (void)dealloc 
{
    [_accessTokenURL release]; _accessTokenURL = nil;
	[_apiBaseURL release]; _apiBaseURL = nil;
	[_authURL release]; _authURL = nil;
	
	[_clientID release]; _clientID = nil;
	[_clientSecret release]; _clientSecret = nil;
	[_redirectURL release]; _redirectURL = nil;
	[super dealloc];
}


#pragma mark - 
#pragma mark - NSCoding

static NSString * const kReadmillAPIConfigurationAPIBaseURLKey = @"apiBaseURL";
static NSString * const kReadmillAPIConfigurationClientIDKey = @"clientID";
static NSString * const kReadmillAPIConfigurationClientSecretKey = @"clientSecret";
static NSString * const kReadmillAPIConfigurationRedirectURLKey = @"redirectURL";
static NSString * const kReadmillAPIConfigurationOnProductionKey = @"isConfiguredForProduction";

- (void)encodeWithCoder:(NSCoder *)aCoder 
{
    [aCoder encodeObject:[self clientID] forKey:kReadmillAPIConfigurationClientIDKey];
    [aCoder encodeObject:[self clientSecret] forKey:kReadmillAPIConfigurationClientSecretKey];
    [aCoder encodeObject:[[self redirectURL] absoluteString] forKey:kReadmillAPIConfigurationRedirectURLKey];
    [aCoder encodeBool:[self isConfiguredForProduction] forKey:kReadmillAPIConfigurationOnProductionKey];
}

- (id)initWithCoder:(NSCoder *)aDecoder 
{
    NSString *clientID = [aDecoder decodeObjectForKey:kReadmillAPIConfigurationClientIDKey];
    NSString *clientSecret = [aDecoder decodeObjectForKey:kReadmillAPIConfigurationClientSecretKey];
    NSString *redirectURLString = [aDecoder decodeObjectForKey:kReadmillAPIConfigurationRedirectURLKey];
    NSURL *redirectURL = redirectURLString ? [NSURL URLWithString:redirectURLString] : nil;
    NSString *apiBaseURLString = [aDecoder decodeObjectForKey:kReadmillAPIConfigurationAPIBaseURLKey];
    
    BOOL isConfiguredForProduction = [aDecoder decodeBoolForKey:kReadmillAPIConfigurationOnProductionKey];
    /*
     *  2012-10-16 @hwaxxer
     *  This is used for migrating existing api configuration objects that did not have 
     *  kReadmillAPIConfigurationOnProductionKey (prior to v2).
     *  It's easier to update URLs if the URLs are not serialized and instead depend only
     *  on whether the configuration is for production or staging.
     */
    if ([apiBaseURLString rangeOfString:@"stage"].location == NSNotFound) {
        isConfiguredForProduction = YES;
    }

    return [self initWithClientID:clientID
                     clientSecret:clientSecret
                      redirectURL:redirectURL
                     onProduction:isConfiguredForProduction];
}

- (NSString *)description 
{
    return [NSString stringWithFormat:@"ReadmillAPIConfiguration: %@, with endPoint: %@, clientID: %@",
            [super description], [self apiBaseURL], [self clientID]];
}

@end
