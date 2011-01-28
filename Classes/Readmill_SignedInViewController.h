//
//  Readmill_FrameworkViewController.h
//  Readmill Framework
//
//  Created by Readmill on 26/01/2011.
//  Copyright 2011 Readmill. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ReadmillConnectBookUI.h"
#import "ReadmillFinishReadUI.h"
#import "ReadmillBook.h"
#import "ReadmillRead.h"

@interface Readmill_SignedInViewController : UIViewController <ReadmillConnectBookUIDelegate, ReadmillFinishReadUIDelegate, ReadmillBookFindingDelegate> {
@private
    ReadmillRead *read;
    ReadmillUser *user;
}

@property (nonatomic, retain) IBOutlet UILabel *welcomeLabel;


@property (nonatomic, readwrite, retain) ReadmillUser *user;
@property (nonatomic, readwrite, retain) ReadmillRead *read;

-(IBAction)linkToBookButtonWasPushed;
-(IBAction)finishReadButtonWasPushed;


@end
