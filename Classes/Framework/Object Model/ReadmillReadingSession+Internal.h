//
//  ReadmillReadingSession+Internal.h
//  ReadmillAPI
//
//  Created by Martin Hwasser on 1/18/12.
//  Copyright (c) 2012 Readmill Network LTD. All rights reserved.
//

#import "ReadmillReadingSession.h"

@class ReadmillPing;
@interface ReadmillReadingSession (Internal)

- (void)refreshSessionDate;
+ (void)archiveFailedPing:(ReadmillPing *)ping;
- (void)archiveFailedPing:(ReadmillPing *)ping;

@end
