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

@interface Readmill_FrameworkViewController : UIViewController <ReadmillConnectBookUIDelegate, ReadmillFinishReadUIDelegate> {
@private
    ReadmillRead *read;
}

@property (nonatomic, readwrite, retain) ReadmillRead *read;

-(IBAction)readBook;
-(IBAction)editRead;


@end
