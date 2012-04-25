//
//  ReadmillArchiverExtensions.m
//  Readmill
//
//  Created by Martin Hwasser on 4/11/11.
//  Copyright 2011 Readmill. All rights reserved.
//

#import "NSKeyedArchiver+ReadmillAdditions.h"
#import "ReadmillReadingSession.h"

static NSString * const ReadmillFailedPingsArchiveFileName = @"ReadmillFailedPings.archive";
static NSString * const ReadmillReadingSessionArchiveFileName = @"ReadmillReadingSession.archive";

@implementation NSKeyedArchiver (ReadmillAdditions)

+ (NSString *)readmillReadingSessionArchivePath 
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *libraryDirectory = [paths objectAtIndex:0];
    return [libraryDirectory stringByAppendingPathComponent:ReadmillReadingSessionArchiveFileName];       
}
+ (NSString *)readmillPingArchivePath 
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *libraryDirectory = [paths objectAtIndex:0];
    return [libraryDirectory stringByAppendingPathComponent:ReadmillFailedPingsArchiveFileName];       
}
+ (BOOL)archiveReadmillReadingSession:(ReadmillReadingSessionArchive *)archive 
{
    BOOL result = [self archiveRootObject:archive toFile:[NSKeyedArchiver readmillReadingSessionArchivePath]];
    return result;
}
+ (BOOL)archiveReadmillPings:(NSArray *)readmillPings 
{
    BOOL result = [self archiveRootObject:readmillPings toFile:[self readmillPingArchivePath]];
    return result;
}

@end
@implementation NSKeyedUnarchiver (ReadmillArchiverExtension)

+ (ReadmillReadingSessionArchive *)unarchiveReadmillReadingSession 
{
    ReadmillReadingSessionArchive *archive = nil;
    archive = [self unarchiveObjectWithFile:[NSKeyedArchiver readmillReadingSessionArchivePath]];
    return archive;
}
+ (NSArray *)unarchiveReadmillPings 
{
    NSArray *readmillPings = nil;
    readmillPings = [self unarchiveObjectWithFile:[NSKeyedArchiver readmillPingArchivePath]];
    return readmillPings;
}

@end