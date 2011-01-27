//
//  ReadmillConnectBookUI.h
//  Readmill Framework
//
//  Created by Work on 26/01/2011.
//  Copyright 2011 KennettNet Software Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ReadmillRead.h"

@class ReadmillFinishReadUI;

@protocol ReadmillFinishReadUIDelegate <NSObject>

-(void)finishReadUIWillClose:(ReadmillFinishReadUI *)readUI;

@end

@interface ReadmillFinishReadUI : UIViewController <UIWebViewDelegate> {
@private
    
    ReadmillRead *read;
    UIActivityIndicatorView *activityIndicator;
    
    id <ReadmillFinishReadUIDelegate> delegate;
    
}

-(id)initWithRead:(ReadmillRead *)aRead;

@property (nonatomic, readonly, retain) ReadmillRead *read;
@property (nonatomic, readwrite, retain) id <ReadmillFinishReadUIDelegate> delegate;

@end