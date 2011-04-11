//
//  ReadmillArchiverExtensions.h
//  Readmill
//
//  Created by Martin Hwasser on 4/11/11.
//  Copyright 2011 Readmill. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ReadmillReadSession.h"

@interface NSKeyedArchiver (ReadmillArchiverExtension)
+ (NSString *)readmillReadSessionArchivePath;
+ (NSString *)readmillPingArchivePath;
+ (BOOL)archiveReadmillReadSession:(ReadmillReadSessionArchive *)archive;
+ (BOOL)archiveReadmillPings:(NSArray *)readmillPings;
@end

@interface NSKeyedUnarchiver (ReadmillArchiverExtension) 
+ (ReadmillReadSessionArchive *)unarchiveReadmillReadSession;
+ (NSArray *)unarchiveReadmillPings;
@end