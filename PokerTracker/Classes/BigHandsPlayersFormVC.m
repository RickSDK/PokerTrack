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


-(void)doAction:(UIButton *)button title:(NSString *)title
{
	ListPicker *localViewController = [[ListPicker alloc] initWithNibName:@"ListPicker" bundle:nil];
	localViewController.callBackViewController=self;
	localViewController.managedObjectContext = managedObjectContext;
	if([button.titleLabel.text isEqualToString:@"-Select-"])
		localViewController.initialDateValue = @"Fold";
	else
		localViewController.initialDateValue = button.titleLabel.text;
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
	detailViewController.initialDateValue = chipsButton.titleLabel.text;
	detailViewController.titleLabel = @"Starting Chips";
	[self.navigationController pushViewController:detailViewController animated:YES];
}

-(void)doMoneyBet:(UIButton *)button title:(NSString *)title
{
	MoneyPickerVC *detailViewController = [[MoneyPickerVC alloc] initWithNibName:@"MoneyPickerVC" bundle:nil];
	detailViewController.managedObjectContext=managedObjectContext;
	detailViewController.callBackViewController = self;
	detailViewController.initialDateValue = button.titleLabel.text;
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

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/

-(void)selectButtonClicked:(id)sender {
	NSArray *values = [NSArray arrayWithObjects:
					   [NSString stringWithFormat:@"%d", playersHand],
					   chipsButton.titleLabel.text,
					   bet1Button.titleLabel.text,
					   action1Button.titleLabel.text,
					   bet2Button.titleLabel.text,
					   action2Button.titleLabel.text,
					   bet3Button.titleLabel.text,
					   action3Button.titleLabel.text,
					   bet4Button.titleLabel.text,
					   action4Button.titleLabel.text,
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

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if([self respondsToSelector:@selector(edgesForExtendedLayout)])
        [self setEdgesForExtendedLayout:UIRectEdgeBottom];
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	if(playersHand==0)
		[self setTitle:@"Your Hand"];
	else 
		[self setTitle:[NSString stringWithFormat:@"Player %d", playersHand+1]];
	
//	UIBarButtonItem *selectButton = [[UIBarButtonItem alloc] initWithTitle:@"Select" style:UIBarButtonItemStylePlain target:self action:@selector(selectButtonClicked:)];
//	self.navigationItem.rightBarButtonItem = selectButton;
	self.navigationItem.rightBarButtonItem = [ProjectFunctions UIBarButtonItemWithIcon:[NSString fontAwesomeIconStringForEnum:FACheck] target:self action:@selector(selectButtonClicked:)];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"playerNum = %d AND bighand = %@", playersHand, mo];
	
	NSArray *items = [CoreDataLib selectRowsFromEntity:@"PLAYER" predicate:predicate sortColumn:nil mOC:managedObjectContext ascendingFlg:NO];
	if([items count]>0) {
		NSManagedObject *playerVals = [items objectAtIndex:0];
		[action1Button setTitle:[playerVals valueForKey:@"preflopOdds"] forState:UIControlStateNormal];
		[bet1Button setTitle:[NSString stringWithFormat:@"%@", [playerVals valueForKey:@"preflopBet"]] forState:UIControlStateNormal];

		[action2Button setTitle:[playerVals valueForKey:@"flopOdds"] forState:UIControlStateNormal];
		[bet2Button setTitle:[NSString stringWithFormat:@"%@", [playerVals valueForKey:@"flopBet"]] forState:UIControlStateNormal];

		[action3Button setTitle:[playerVals valueForKey:@"turnOdds"] forState:UIControlStateNormal];
		[bet3Button setTitle:[NSString stringWithFormat:@"%@", [playerVals valueForKey:@"turnBet"]] forState:UIControlStateNormal];

		[action4Button setTitle:[playerVals valueForKey:@"result"] forState:UIControlStateNormal];
		[bet4Button setTitle:[NSString stringWithFormat:@"%@", [playerVals valueForKey:@"riverBet"]] forState:UIControlStateNormal];

	}
		
	
}

-(void) setReturningValue:(NSString *) value {
	if(selectedNumber==0) {
		[chipsButton setBackgroundImage:[UIImage imageNamed:@"greenChromeBut.png"] forState:UIControlStateNormal];
		[chipsButton setTitle:value forState:UIControlStateNormal];
	}
	if(selectedNumber==1) {
		[action1Button setBackgroundImage:[UIImage imageNamed:@"greenChromeBut.png"] forState:UIControlStateNormal];
		[action1Button setTitle:value forState:UIControlStateNormal];
	}
	if(selectedNumber==2) {
		[action2Button setBackgroundImage:[UIImage imageNamed:@"greenChromeBut.png"] forState:UIControlStateNormal];
		[action2Button setTitle:value forState:UIControlStateNormal];
	}
	if(selectedNumber==3) {
		[action3Button setBackgroundImage:[UIImage imageNamed:@"greenChromeBut.png"] forState:UIControlStateNormal];
		[action3Button setTitle:value forState:UIControlStateNormal];
	}
	if(selectedNumber==4) {
		[action4Button setBackgroundImage:[UIImage imageNamed:@"greenChromeBut.png"] forState:UIControlStateNormal];
		[action4Button setTitle:value forState:UIControlStateNormal];
	}
	if(selectedNumber==5) {
		[bet1Button setBackgroundImage:[UIImage imageNamed:@"greenChromeBut.png"] forState:UIControlStateNormal];
		[bet1Button setTitle:value forState:UIControlStateNormal];
	}
	if(selectedNumber==6) {
		[bet2Button setBackgroundImage:[UIImage imageNamed:@"greenChromeBut.png"] forState:UIControlStateNormal];
		[bet2Button setTitle:value forState:UIControlStateNormal];
	}
	if(selectedNumber==7) {
		[bet3Button setBackgroundImage:[UIImage imageNamed:@"greenChromeBut.png"] forState:UIControlStateNormal];
		[bet3Button setTitle:value forState:UIControlStateNormal];
	}
	if(selectedNumber==8) {
		[bet4Button setBackgroundImage:[UIImage imageNamed:@"greenChromeBut.png"] forState:UIControlStateNormal];
		[bet4Button setTitle:value forState:UIControlStateNormal];
	}
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}




@end
