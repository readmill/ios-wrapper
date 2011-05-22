//
//  ReadmillArchiverExtensions.m
//  Readmill
//
//  Created by Martin Hwasser on 4/11/11.
//  Copyright 2011 Readmill. All rights reserved.
//

#import "ReadmillArchiverExtensions.h"


@implementation NSKeyedArchiver (ReadmillArchiverExtension)

+ (NSString *)readmillReadingSessionArchivePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *libraryDirectory = [paths objectAtIndex:0];
    return [libraryDirectory stringByAppendingPathComponent:@"ReadmillReadingSession.archive"];       
}
+ (NSString *)readmillPingArchivePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *libraryDirectory = [paths objectAtIndex:0];
    return [libraryDirectory stringByAppendingPathComponent:@"ReadmillFailedPings.archive"];       
}
+ (BOOL)archiveReadmillReadingSession:(ReadmillReadingSessionArchive *)archive {
    BOOL result = [self archiveRootObject:archive toFile:[NSKeyedArchiver readmillReadingSessionArchivePath]];
    return result;
}
+ (BOOL)archiveReadmillPings:(NSArray *)readmillPings {
    BOOL result = [self archiveRootObject:readmillPings toFile:[self readmillPingArchivePath]];
    return result;
}

@end
@implementation NSKeyedUnarchiver (ReadmillArchiverExtension)

+ (ReadmillReadingSessionArchive *)unarchiveReadmillReadingSession {
    ReadmillReadingSessionArchive *archive = nil;
    archive = [self unarchiveObjectWithFile:[NSKeyedArchiver readmillReadingSessionArchivePath]];
    return archive;
}
+ (NSArray *)unarchiveReadmillPings {
    NSArray *readmillPings = nil;
    readmillPings = [self unarchiveObjectWithFile:[NSKeyedArchiver readmillPingArchivePath]];
    return readmillPings;
}

@end