//
//  BigHandsPlayersFormVC.m
//  PokerTracker
//
//  Created by Rick Medved on 3/19/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "BigHandsPlayersFormVC.h"
#import "ListPicker.h"
#import "MoneyPickerVC.h"
#import "CoreDataLib.h"
#import "BigHandsFormVC.h"
#import "ProjectFunctions.h"


@implementation BigHandsPlayersFormVC
@synthesize managedObjectContext, mo, playersHand, selectedNumber, callBackViewController, chipsButton;
@synthesize action1Button, action2Button, action3Button, action4Button, bet1Button, bet2Button, bet3Button, bet4Button;


- (void)viewDidLoad {
	[super viewDidLoad];
	NSLog(@"playersHand: %d", playersHand);
	if(playersHand==1)
		[self setTitle:@"Your Hand"];
	else
		[self setTitle:[NSString stringWithFormat:@"Player %d", playersHand]];
	[self changeNavToIncludeType:37];
	
	self.navigationItem.rightBarButtonItem = [ProjectFunctions UIBarButtonItemWithIcon:[NSString fontAwesomeIconStringForEnum:FACheck] target:self action:@selector(selectButtonClicked:)];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"playerNum = %d AND bighand = %@", playersHand, mo];
	NSArray *items = [CoreDataLib selectRowsFromEntity:@"PLAYER" predicate:predicate sortColumn:nil mOC:managedObjectContext ascendingFlg:NO];
	NSLog(@"Num Records: %d", (int)items.count);
	if([items count]>0) {
		NSManagedObject *playerVals = [items objectAtIndex:0];
		
		int chips = [[playerVals valueForKey:@"chips"] intValue];
		[chipsButton setTitle:[ProjectFunctions convertNumberToMoneyString:chips] forState:UIControlStateNormal];
		[action1Button setTitle:[playerVals valueForKey:@"preflopOdds"] forState:UIControlStateNormal];
		[bet1Button setTitle:[NSString stringWithFormat:@"%@", [playerVals valueForKey:@"preflopBet"]] forState:UIControlStateNormal];
		
		[action2Button setTitle:[playerVals valueForKey:@"flopOdds"] forState:UIControlStateNormal];
		[bet2Button setTitle:[NSString stringWithFormat:@"%@", [playerVals valueForKey:@"flopBet"]] forState:UIControlStateNormal];
		
		[action3Button setTitle:[playerVals valueForKey:@"turnOdds"] forState:UIControlStateNormal];
		[bet3Button setTitle:[NSString stringWithFormat:@"%@", [playerVals valueForKey:@"turnBet"]] forState:UIControlStateNormal];
		
		[action4Button setTitle:[playerVals valueForKey:@"result"] forState:UIControlStateNormal];
		[bet4Button setTitle:[NSString stringWithFormat:@"%@", [playerVals valueForKey:@"riverBet"]] forState:UIControlStateNormal];
	}
	[BigHandObj createHand:self.playerHand suit1:self.cardSuit1Label label1:self.cardLabel1 suit2:self.cardSuit2Label label2:self.cardLabel2];
}

-(void)doAction:(UIButton *)button title:(NSString *)title
{
	ListPicker *localViewController = [[ListPicker alloc] initWithNibName:@"ListPicker" bundle:nil];
	localViewController.callBackViewController=self;
	localViewController.managedObjectContext = managedObjectContext;
	if([[button titleForState:UIControlStateNormal] isEqualToString:@"-Select-"])
		localViewController.initialDateValue = @"Fold";
	else
		localViewController.initialDateValue = [button titleForState:UIControlStateNormal];
	localViewController.titleLabel = title;
	localViewController.selectionList = [NSArray arrayWithObjects:@"Fold", @"Check", @"Call", @"Bet", @"Raise", @"All-In", @"Check-Fold", @"Check-Call", @"Check-Raise", @"Check-All-In", @"Call-Fold", @"Call-Call", @"Call-Raise", @"Call-All-In", @"Bet-Fold", @"Bet-Call", @"Bet-Raise", @"Bet-All-In", @"Raise-Fold", @"Raise-Call", @"Raise-Raise", @"Raise-All-In", nil];
	localViewController.allowEditing=NO;
	localViewController.hideNumRecords=YES;
	localViewController.messageText = @"If player used more than one action, just enter first and last actions";
	[self.navigationController pushViewController:localViewController animated:YES];
}

-(void)chipsClicked:(id)sender
{
	self.selectedNumber=0;
	MoneyPickerVC *detailViewController = [[MoneyPickerVC alloc] initWithNibName:@"MoneyPickerVC" bundle:nil];
	detailViewController.managedObjectContext=managedObjectContext;
	detailViewController.callBackViewController = self;
	detailViewController.initialDateValue = [chipsButton titleForState:UIControlStateNormal];
	detailViewController.titleLabel = @"Starting Chips";
	[self.navigationController pushViewController:detailViewController animated:YES];
}

-(void)doMoneyBet:(UIButton *)button title:(NSString *)title
{
	MoneyPickerVC *detailViewController = [[MoneyPickerVC alloc] initWithNibName:@"MoneyPickerVC" bundle:nil];
	detailViewController.managedObjectContext=managedObjectContext;
	detailViewController.callBackViewController = self;
	detailViewController.initialDateValue = [button titleForState:UIControlStateNormal];
	detailViewController.titleLabel = title;
	[self.navigationController pushViewController:detailViewController animated:YES];
}

-(void)action1ButtonClicked:(id)sender
{
	self.selectedNumber=1;
	[self doAction:action1Button title:@"Preflop Action"];
}
-(void)action2ButtonClicked:(id)sender
{
	self.selectedNumber=2;
	[self doAction:action2Button title:@"Postflop Action"];
}
-(void)action3ButtonClicked:(id)sender
{
	self.selectedNumber=3;
	[self doAction:action3Button title:@"Turn Action"];
}
-(void)action4ButtonClicked:(id)sender
{
	self.selectedNumber=4;
	[self doAction:action4Button title:@"River Action"];
}
-(void)bet1ButtonClicked:(id)sender
{
	self.selectedNumber=5;
	[self doMoneyBet:bet1Button title:@"Preflop Amount"];
}
-(void)bet2ButtonClicked:(id)sender
{
	self.selectedNumber=6;
	[self doMoneyBet:bet2Button title:@"Postflop Amount"];
}
-(void)bet3ButtonClicked:(id)sender
{
	self.selectedNumber=7;
	[self doMoneyBet:bet3Button title:@"Turn Amount"];
}
-(void)bet4ButtonClicked:(id)sender
{
	self.selectedNumber=8;
	[self doMoneyBet:bet4Button title:@"River Amount"];
}

-(void)selectButtonClicked:(id)sender {
	NSArray *values = [NSArray arrayWithObjects:
					   [NSString stringWithFormat:@"%d", playersHand],
					   [NSString stringWithFormat:@"%d", (int)[ProjectFunctions convertMoneyStringToDouble:[chipsButton titleForState:UIControlStateNormal]]],
					   [bet1Button titleForState:UIControlStateNormal],
					   [action1Button titleForState:UIControlStateNormal],
					   [bet2Button titleForState:UIControlStateNormal],
					   [action2Button titleForState:UIControlStateNormal],
					   [bet3Button titleForState:UIControlStateNormal],
					   [action3Button titleForState:UIControlStateNormal],
					   [bet4Button titleForState:UIControlStateNormal],
					   [action4Button titleForState:UIControlStateNormal],
					   mo,
					   nil];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"playerNum = %d AND bighand = %@", playersHand, mo];
	
	NSArray *items = [CoreDataLib selectRowsFromEntity:@"PLAYER" predicate:predicate sortColumn:nil mOC:managedObjectContext ascendingFlg:NO];
	if([items count]>0)
		[CoreDataLib updateManagedObjectForEntity:[items objectAtIndex:0] entityName:@"PLAYER" valueList:values mOC:managedObjectContext];
	else 
		[CoreDataLib insertManagedObjectForEntity:@"PLAYER" valueList:values mOC:managedObjectContext];
	
	[(BigHandsFormVC *)callBackViewController setupVisualView];

	[self.navigationController popViewControllerAnimated:YES];
}


-(void) setReturningValue:(NSString *) value {
	NSArray *buttons = [NSArray arrayWithObjects:
						chipsButton,
						action1Button,
						action2Button,
						action3Button,
						action4Button,
						bet1Button,
						bet2Button,
						bet3Button,
						bet4Button,
						nil];
	if(buttons.count>selectedNumber) {
		UIButton *button = [buttons objectAtIndex:selectedNumber];
		[ProjectFunctions newButtonLook:button mode:1];
		[button setTitle:value forState:UIControlStateNormal];
	}
}





@end
