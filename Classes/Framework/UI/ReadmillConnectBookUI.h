//
//  ReadmillConnectBookUI.h
//  Readmill Framework
//
//  Created by Readmill on 26/01/2011.
//  Copyright 2011 Readmill. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ReadmillUser.h"
#import "ReadmillRead.h"
#import "ReadmillBook.h"

@class ReadmillConnectBookUI;

@protocol ReadmillConnectBookUIDelegate <NSObject>

-(void)connect:(ReadmillConnectBookUI *)connectionUI didSucceedToLinkToBook:(ReadmillBook *)aBook withRead:(ReadmillRead *)aRead;
-(void)connect:(ReadmillConnectBookUI *)connectionUI didSkipLinkingToBook:(ReadmillBook *)aBook;
-(void)connect:(ReadmillConnectBookUI *)connectionUI didFailToLinkToBook:(ReadmillBook *)aBook withError:(NSError *)error;

@end

@interface ReadmillConnectBookUI : UIViewController <UIWebViewDelegate, ReadmillReadFindingDelegate> {
@private
    
    ReadmillUser *user;
    ReadmillBook *book;
    UIActivityIndicatorView *activityIndicator;
    
    id <ReadmillConnectBookUIDelegate> delegate;
    
}

-(id)initWithUser:(ReadmillUser *)aUser book:(ReadmillBook *)bookToConnectTo;

@property (nonatomic, readonly, retain) ReadmillUser *user;
@property (nonatomic, readonly, retain) ReadmillBook *book;
@property (nonatomic, readwrite, retain) id <ReadmillConnectBookUIDelegate> delegate;

@end
