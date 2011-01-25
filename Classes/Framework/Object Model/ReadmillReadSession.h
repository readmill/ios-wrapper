//
//  ReadmillReadSession.h
//  Readmill Framework
//
//  Created by Readmill on 13/01/2011.
//  Copyright 2011 Readmill. All rights reserved.
//

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
    
    NSDate *lastPingDate;
    NSString *sessionIdentifier;
    ReadmillAPIWrapper *apiWrapper;
    ReadmillReadId readId;
}

/*!
 @param wrapper The ReadmillAPIWrapper to be used by the session. 
 @param sessionReadId The read id this session is for. 
 @result The created read session.
 @brief   Create a new reading session for the given read id. 

 A new session identifier will be generated automatically.
 
 Note: The typical way to obtain a ReadmillReadSession is to use the -createReadSession or 
 -createReadSessionWithExistingSessionId: convenience methods in the ReadmillRead class.
 */
-(id)initWithAPIWrapper:(ReadmillAPIWrapper *)wrapper readId:(ReadmillReadId)sessionReadId;

/*!
 @param wrapper The ReadmillAPIWrapper to be used by the session. 
 @param sessionReadId The read id this session is for. 
 @param sessionId The session identifier to use.
 @result The created read session.
 @brief   Create a new reading session for the given read id and session identifier. 
 
 This is the designated initializer for this class.
 
 Note: The typical way to obtain a ReadmillReadSession is to use the -createReadSession or 
 -createReadSessionWithExistingSessionId: convenience methods in the ReadmillRead class.
 */
-(id)initWithAPIWrapper:(ReadmillAPIWrapper *)wrapper readId:(ReadmillReadId)sessionReadId sessionId:(NSString *)sessionId;

/*!
 @property  lastPingDate
 @brief The date this session was last pinged.  
 */
@property (readonly, copy) NSDate *lastPingDate;

/*!
 @property  sessionIdentifier
 @brief The session identifier for this session.  
 */
@property (readonly, copy) NSString *sessionIdentifier;

/*!
 @property  apiWrapper
 @brief The ReadmillAPIWrapper object this session uses.  
 */
@property (readonly, retain) ReadmillAPIWrapper *apiWrapper;

/*!
 @property  readId
 @brief The id of the read this session is attached to.  
 */
@property (readonly) ReadmillReadId readId;

/*!
 @param progress The user's progress through the book, as in integer percentage. 
 @param delegate The delegate object to be informed of success for failure.
 @brief   "Ping" this session, informing the Readmill service that the user is reading the book at the moment with the given progress.
 
 This should be called periodically while the user is reading, every few minutes or so.
 */
-(void)pingWithProgress:(ReadmillReadProgress)progress delegate:(id <ReadmillPingDelegate>)delegate;

@end
