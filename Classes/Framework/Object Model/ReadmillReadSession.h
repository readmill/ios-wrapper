/*
 Copyright (c) 2011 Readmill LTD
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */

#import <Foundation/Foundation.h>
#import "ReadmillAPIWrapper.h"

@class ReadmillReadSession;

@protocol ReadmillPingDelegate <NSObject>

/*!
 @param session The session object that pinged the Readmill service successfully. 
 @brief   Delegate method informing the target that the given ping was successful. 
 */
-(void)readmillReadSessionDidPingSuccessfully:(ReadmillReadSession *)session;

/*!
 @param session The session object that failed to ping the Readmill service successfully. 
 @param error The error that occurred.
 @brief   Delegate method informing the target that the given ping failed. 
 */
-(void)readmillReadSession:(ReadmillReadSession *)session didFailToPingWithError:(NSError *)error;

@end

@interface ReadmillReadSession : NSObject {
@private
    
    ReadmillAPIWrapper *apiWrapper;
    ReadmillReadingId readId;
    
}

/*!
 @param wrapper The ReadmillAPIWrapper to be used by the session. 
 @param sessionReadId The read id this session is for. 
 @result The created read session.
 @brief   Create a new reading session for the given read id. 

 A new session identifier will be generated automatically.
 
 Note: The typical way to obtain a ReadmillReadSession is to use the -createReadSession 
       convenience method in the ReadmillRead class.
 */
-(id)initWithAPIWrapper:(ReadmillAPIWrapper *)wrapper readId:(ReadmillReadingId)sessionReadId;

/*!
 @property  apiWrapper
 @brief The ReadmillAPIWrapper object this session uses.  
 */
@property (readonly, retain) ReadmillAPIWrapper *apiWrapper;

/*!
 @property  readId
 @brief The id of the read this session is attached to.  
 */
@property (readonly) ReadmillReadingId readId;

/*!
 @param progress The user's progress through the book, as in float percentage. 
 @param pingDuration The duration between pings, as in integer seconds. 
 @param delegate The delegate object to be informed of success for failure.
 @brief   "Ping" this session, informing the Readmill service that the user is reading the book at the moment with the given progress.
 
 This should be called periodically while the user is reading, every few minutes or so.
 */
-(void)pingWithProgress:(ReadmillReadingProgress)progress 
           pingDuration:(ReadmillPingDuration)duration 
               delegate:(id <ReadmillPingDelegate>)delegate;

/*!
 @param progress The user's progress through the book, as in float percentage. 
 @param pingDuration The duration between pings, as in integer seconds. 
 @param latitude The current latitude.
 @param longitude The currnet longitude.
 @param delegate The delegate object to be informed of success for failure.
 @brief   "Ping" this session, informing the Readmill service that the user is reading the book at the moment with the given progress.
 
 This should be called periodically while the user is reading, every few minutes or so.
 */
-(void)pingWithProgress:(ReadmillReadingProgress)progress 
           pingDuration:(ReadmillPingDuration)duration 
               latitude:(CLLocationDegrees)latitude 
              longitude:(CLLocationDegrees)longitude 
               delegate:(id <ReadmillPingDelegate>)delegate;

/*!
 @param wrapper The ReadmillAPIWrapper to be used by the session.
 @brief Try to send all saved "Pings" that have been archived.
 
 This is a static method which a ReadmillReadSession always calls upon instantiation. 
 This should be called whenever there may be archived pings and a connection to Readmill
 is possible to ensure progress data is synchronized.
 */
+ (void)pingArchived:(ReadmillAPIWrapper *)wrapper;

@end


@interface ReadmillReadSessionArchive : NSObject <NSCoding> {
    NSDate *lastSessionDate;
    NSString *sessionIdentifier;
}

@property (readwrite, copy) NSDate *lastSessionDate;
@property (readwrite, copy) NSString *sessionIdentifier;

@end
