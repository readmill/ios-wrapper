//
//  ReadmillArchiverExtensions.h
//  Readmill
//
//  Created by Martin Hwasser on 4/11/11.
//  Copyright 2011 Readmill. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ReadmillReadingSession.h"

@interface NSKeyedArchiver (ReadmillArchiverExtension)
+ (NSString *)readmillReadingSessionArchivePath;
+ (NSString *)readmillPingArchivePath;
+ (BOOL)archiveReadmillReadingSession:(ReadmillReadingSessionArchive *)archive;
+ (BOOL)archiveReadmillPings:(NSArray *)readmillPings;
@end

@interface NSKeyedUnarchiver (ReadmillArchiverExtension) 
+ (ReadmillReadingSessionArchive *)unarchiveReadmillReadingSession;
+ (NSArray *)unarchiveReadmillPings;
@end