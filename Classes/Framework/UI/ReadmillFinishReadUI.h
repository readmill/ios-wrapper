//
//  ReadmillConnectBookUI.h
//  Readmill Framework
//
//  Created by Readmill on 26/01/2011.
//  Copyright 2011 Readmill. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ReadmillRead.h"

@class ReadmillFinishReadUI;

@protocol ReadmillFinishReadUIDelegate <NSObject>

-(void)finishReadUIWillCloseWithNoAction:(ReadmillFinishReadUI *)readUI;
-(void)finishReadUI:(ReadmillFinishReadUI *)readUI didFinishRead:(ReadmillRead *)aRead;
-(void)finishReadUI:(ReadmillFinishReadUI *)readUI didFailToFinishRead:(ReadmillRead *)aRead withError:(NSError *)error;

@end

@interface ReadmillFinishReadUI : UIViewController <UIWebViewDelegate, ReadmillReadUpdatingDelegate> {
@private
    
    ReadmillRead *read;
    UIActivityIndicatorView *activityIndicator;
    
    id <ReadmillFinishReadUIDelegate> delegate;
    
}

-(id)initWithRead:(ReadmillRead *)aRead;

@property (nonatomic, readonly, retain) ReadmillRead *read;
@property (nonatomic, readwrite, retain) id <ReadmillFinishReadUIDelegate> delegate;

@end
