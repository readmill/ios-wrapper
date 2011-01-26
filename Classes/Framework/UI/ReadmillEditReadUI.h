//
//  ReadmillConnectBookUI.h
//  Readmill Framework
//
//  Created by Work on 26/01/2011.
//  Copyright 2011 KennettNet Software Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ReadmillRead.h"

@class ReadmillEditReadUI;

@protocol ReadmillEditReadUIDelegate <NSObject>

-(void)editReadUIWillClose:(ReadmillEditReadUI *)readUI;

@end

@interface ReadmillEditReadUI : UIViewController <UIWebViewDelegate> {
@private
    
    ReadmillRead *read;
    UIActivityIndicatorView *activityIndicator;
    
    id <ReadmillEditReadUIDelegate> delegate;
    
}

-(id)initWithRead:(ReadmillRead *)aRead;

@property (nonatomic, readonly, retain) ReadmillRead *read;
@property (nonatomic, readwrite, retain) id <ReadmillEditReadUIDelegate> delegate;

@end
