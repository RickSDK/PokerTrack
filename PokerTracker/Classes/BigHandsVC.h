//
//  BigHandsVC.h
//  PokerTracker
//
//  Created by Rick Medved on 10/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TemplateVC.h"


@interface BigHandsVC : TemplateVC {
}

@property (nonatomic) BOOL showMainMenuButton;


- (IBAction) deleteButtonPressed: (id) sender;

@property (nonatomic) int touchesCount;
@property (nonatomic, strong) IBOutlet UIView *bottomView;

@end
