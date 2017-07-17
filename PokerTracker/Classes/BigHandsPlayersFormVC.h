//
//  BigHandsPlayersFormVC.h
//  PokerTracker
//
//  Created by Rick Medved on 3/19/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TemplateVC.h"


@interface BigHandsPlayersFormVC : TemplateVC {
    NSManagedObjectContext *managedObjectContext;
	NSManagedObject *mo;
	int playersHand;
	int selectedNumber;
	UIViewController *callBackViewController;
	
	IBOutlet UIButton *chipsButton;
	IBOutlet UIButton *action1Button;
	IBOutlet UIButton *action2Button;
	IBOutlet UIButton *action3Button;
	IBOutlet UIButton *action4Button;
	IBOutlet UIButton *bet1Button;
	IBOutlet UIButton *bet2Button;
	IBOutlet UIButton *bet3Button;
	IBOutlet UIButton *bet4Button;

}

-(void)chipsClicked:(id)sender;
-(void)action1ButtonClicked:(id)sender;
-(void)action2ButtonClicked:(id)sender;
-(void)action3ButtonClicked:(id)sender;
-(void)action4ButtonClicked:(id)sender;
-(void)bet1ButtonClicked:(id)sender;
-(void)bet2ButtonClicked:(id)sender;
-(void)bet3ButtonClicked:(id)sender;
-(void)bet4ButtonClicked:(id)sender;


@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSManagedObject *mo;
@property (nonatomic, strong) UIViewController *callBackViewController;
@property (nonatomic) int playersHand;
@property (nonatomic) int selectedNumber;

@property (nonatomic, strong) UIButton *chipsButton;
@property (nonatomic, strong) UIButton *action1Button;
@property (nonatomic, strong) UIButton *action2Button;
@property (nonatomic, strong) UIButton *action3Button;
@property (nonatomic, strong) UIButton *action4Button;
@property (nonatomic, strong) UIButton *bet1Button;
@property (nonatomic, strong) UIButton *bet2Button;
@property (nonatomic, strong) UIButton *bet3Button;
@property (nonatomic, strong) UIButton *bet4Button;






@end
