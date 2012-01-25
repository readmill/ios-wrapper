//
//  ReadmillReadingSession+Internal.m
//  ReadmillAPI
//
//  Created by Martin Hwasser on 1/18/12.
//  Copyright (c) 2012 Readmill Network LTD. All rights reserved.
//

#import "ReadmillReadingSession+Internal.h"
#import "ReadmillPing.h"
#import "NSKeyedArchiver+ReadmillAdditions.h"

@implementation ReadmillReadingSession (Internal)

- (void)refreshSessionDate
{
    ReadmillReadingSessionArchive *archive = [NSKeyedUnarchiver unarchiveReadmillReadingSession];
    [archive setLastSessionDate:[NSDate date]];
    [NSKeyedArchiver archiveReadmillReadingSession:archive];
}

+ (void)archiveFailedPing:(ReadmillPing *)ping 
{    
    @synchronized (self) {
        // Grab all archived pings    
        NSArray *unarchivedPings = [NSKeyedUnarchiver unarchiveReadmillPings];
        NSMutableArray *failedPings = [[NSMutableArray alloc] init];
        if (nil != unarchivedPings) {
            [failedPings addObjectsFromArray:unarchivedPings];
        }
        // Add the new one
        [failedPings addObject:ping];
        // Archive all pings
        [NSKeyedArchiver archiveReadmillPings:failedPings];
        
        [failedPings release];
    }
}

- (void)archiveFailedPing:(ReadmillPing *)ping
{
    [[self class] archiveFailedPing:ping];
}

@end
