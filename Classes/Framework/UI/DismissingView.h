//
//  DismissingView.h
//  Readmill
//
//  Created by Martin Hwasser on 3/22/11.
//  Copyright 2011 Readmill. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface DismissingView : UIView {
    
}
@property (nonatomic, retain) id target;
@property (nonatomic) SEL selector;

- (id)initWithFrame:(CGRect)frame selector:(SEL)selector target:(id)target ;
- (void)addToView:(UIView *)aView;

@end
