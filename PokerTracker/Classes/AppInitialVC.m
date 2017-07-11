//
//  AppInitialVC.m
//  PokerTracker
//
//  Created by Rick Medved on 3/19/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "AppInitialVC.h"
#import "ProjectFunctions.h"
#import "MoneyPickerVC.h"
#import "MainMenuVC.h"


@implementation AppInitialVC
@synthesize managedObjectContext, enterButton, bankrollButton, liteLabel, welcomeLabel, topLabel;



-(void)bankrollButtonClicked:(id)sender
{
	enterButton.enabled=YES;
	MoneyPickerVC *detailViewController = [[MoneyPickerVC alloc] initWithNibName:@"MoneyPickerVC" bundle:nil];
	detailViewController.managedObjectContext = managedObjectContext;
	detailViewController.callBackViewController = self;
	detailViewController.titleLabel = @"Default Bankroll";
	detailViewController.initialDateValue = [ProjectFunctions getUserDefaultValue:@"defaultBankroll"];
	[self.navigationController pushViewController:detailViewController animated:YES];
}
-(void)enterButtonClicked:(id)sender
{
	MainMenuVC *detailViewController = [[MainMenuVC alloc] initWithNibName:@"MainMenuVC" bundle:nil];
	detailViewController.managedObjectContext = managedObjectContext;
	[self.navigationController pushViewController:detailViewController animated:YES];
}

-(void)helpButtonClicked:(id)sender {
	[ProjectFunctions showAlertPopup:@"Help Screen" message:@"Click on the yellow button, enter any amount and then click 'Enter'"];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	[self setTitle:([ProjectFunctions isPokerZilla])?@"PokerZilla":@"Poker Track Pro"];
	UIBarButtonItem *moreButton = [[UIBarButtonItem alloc] initWithTitle:@"Help" style:UIBarButtonItemStylePlain target:self action:@selector(helpButtonClicked:)];
	self.navigationItem.leftBarButtonItem = moreButton;
	
	self.welcomeLabel.text = NSLocalizedString(@"Welcome", nil);
	self.topLabel.text = NSLocalizedString(@"Welcome2", nil);
	liteLabel.alpha=0;
	[self setReturningValue:@"100"];
}



-(void) setReturningValue:(NSString *) value {
	int bankroll = [value intValue];
	if(bankroll<=0)
		value=@"1";
	
	[ProjectFunctions setUserDefaultValue:value forKey:@"defaultBankroll"];
	[ProjectFunctions setUserDefaultValue:value forKey:[NSString stringWithFormat:@"%@BankrollAmount", @"Default"]];
	[bankrollButton setTitle:[ProjectFunctions convertIntToMoneyString:[value intValue]] forState:UIControlStateNormal];


}





@end
