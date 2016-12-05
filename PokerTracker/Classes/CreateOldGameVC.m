//
//  CreateOldGameVC.m
//  PokerTracker
//
//  Created by Rick Medved on 10/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CreateOldGameVC.h"
#import "ProjectFunctions.h"
#import "NSDate+ATTDate.h"
#import "GamesVC.h"
#import "MainMenuVC.h"
#import "CoreDataLib.h"
#import "ListPicker.h"
#import "NSArray+ATTArray.h"
#import "GameGraphVC.h"
#import "UpgradeVC.h"


@implementation CreateOldGameVC
@synthesize gameTypeSegmentBar, gameNameSegmentBar, blindTypeSegmentBar, limitTypeSegmentBar;
@synthesize datePicker, hoursPlayed, buyinAmount, cashOutAmount, keyboardButton, TourneyTypeSegmentBar;
@synthesize managedObjectContext, mo;
@synthesize activityIndicatorServer, textViewBG, activityLabel, selectedObjectForEdit;
@synthesize buyinMoneyLabel, cashoutMoneyLabel;

- (IBAction) keyboardPressed: (id) sender 
{
	[hoursPlayed resignFirstResponder];
	[buyinAmount resignFirstResponder];
	[cashOutAmount resignFirstResponder];
}

-(IBAction) gameTypeSegmentPressed: (id) sender
{
	[self setSegmentForType];
}

-(void)gotoListPicker:(int)selectedObject
{
	NSArray *optionList = [NSArray arrayWithObjects:@"1", @"2", @"3", @"4", @"GameType", @"Stakes", @"Limit", @"Tournament", nil];
	NSString *option = [NSString stringWithFormat:@"%@", [optionList stringAtIndex:selectedObject]];
	NSString *entityName = [option uppercaseString];
	NSArray *valueList = [CoreDataLib getEntityNameList:entityName mOC:managedObjectContext];
	
	ListPicker *localViewController = [[ListPicker alloc] initWithNibName:@"ListPicker" bundle:nil];
	localViewController.callBackViewController=self;
	localViewController.managedObjectContext = managedObjectContext;
	localViewController.initialDateValue = [NSString stringWithFormat:@"%@", [valueList stringAtIndex:0]];
	localViewController.titleLabel = option;
	localViewController.selectionList = valueList;
	localViewController.selectedList = 0;
	localViewController.allowEditing=YES;
	[self.navigationController pushViewController:localViewController animated:YES];
}
	  

- (IBAction) gameSegmentPressed: (id) sender 
{
	self.selectedObjectForEdit=4;
	if(gameNameSegmentBar.selectedSegmentIndex==3) {
		gameNameSegmentBar.selectedSegmentIndex=0;
		[self gotoListPicker:4];
	}
}
- (IBAction) stakesSegmentPressed: (id) sender 
{
	self.selectedObjectForEdit=5;
	if(blindTypeSegmentBar.selectedSegmentIndex==4) {
		blindTypeSegmentBar.selectedSegmentIndex=0;
		[self gotoListPicker:5];
	}
}
- (IBAction) limitSegmentPressed: (id) sender 
{
	self.selectedObjectForEdit=6;
	if(limitTypeSegmentBar.selectedSegmentIndex==3) {
		limitTypeSegmentBar.selectedSegmentIndex=0;
		[self gotoListPicker:6];
	}
}


-(void)setSegmentForType
{
	if(gameTypeSegmentBar.selectedSegmentIndex==0) {
		self.TourneyTypeSegmentBar.alpha=0;
		self.blindTypeSegmentBar.alpha=1;
		self.buyinAmount.text = [ProjectFunctions getUserDefaultValue:@"buyinDefault"];
	} else {
		self.TourneyTypeSegmentBar.alpha=1;
		self.blindTypeSegmentBar.alpha=2;
		self.buyinAmount.text = [ProjectFunctions getUserDefaultValue:@"tournbuyinDefault"];
	}

		
}


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if(alertView.tag==104) {
		if(buttonIndex != alertView.cancelButtonIndex) {
			UpgradeVC *detailViewController = [[UpgradeVC alloc] initWithNibName:@"UpgradeVC" bundle:nil];
			detailViewController.managedObjectContext = managedObjectContext;
			[self.navigationController pushViewController:detailViewController animated:YES];
		}
		return;
	}
	
   GameGraphVC *detailViewController = [[GameGraphVC alloc] initWithNibName:@"GameGraphVC" bundle:nil];
	detailViewController.managedObjectContext=managedObjectContext;
	detailViewController.showMainMenuFlg = YES;
	detailViewController.mo = self.mo;
	[self.navigationController pushViewController:detailViewController animated:YES];

}

-(void)refreshWebRequest
{
	@autoreleasepool {
		if([ProjectFunctions uploadUniverseStats:managedObjectContext])
			[ProjectFunctions showAlertPopupWithDelegate:@"Success" message:@"Server data synced" delegate:self];

		
		self.textViewBG.alpha=0;
		self.activityLabel.alpha=0;
		[NSThread sleepForTimeInterval:0.01];
		[activityIndicatorServer stopAnimating];
	}
}

-(void)executeThreadedJob:(SEL)aSelector
{
	[self performSelectorInBackground:aSelector withObject:nil];
	
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if([self respondsToSelector:@selector(edgesForExtendedLayout)])
        [self setEdgesForExtendedLayout:UIRectEdgeBottom];
}


- (void) saveButtonClicked:(id)sender {
	[hoursPlayed resignFirstResponder];
	[buyinAmount resignFirstResponder];
	[cashOutAmount resignFirstResponder];
	
	if(![ProjectFunctions isOkToProceed:self.managedObjectContext delegate:self])
		return;

	int buyin = [buyinAmount.text intValue];
	if(buyin==0) {
		[ProjectFunctions showAlertPopup:@"Buyin must be greater than 0" message:@""];
		return;
	}

		
	NSArray *ttValues = [ProjectFunctions getArrayForSegment:3];
	
		
	NSString *tournamentType = [ttValues objectAtIndex:TourneyTypeSegmentBar.selectedSegmentIndex];
	
	NSString *limit = [limitTypeSegmentBar titleForSegmentAtIndex:limitTypeSegmentBar.selectedSegmentIndex];
	NSString *game = [gameNameSegmentBar titleForSegmentAtIndex:gameNameSegmentBar.selectedSegmentIndex];
	NSString *blinds = [blindTypeSegmentBar titleForSegmentAtIndex:blindTypeSegmentBar.selectedSegmentIndex];
	
	float hours = [hoursPlayed.text floatValue];
	int cashout = [cashOutAmount.text intValue];
	if(hours<0.5)
		hours=3;
	int min = (int)(hours*60);
	int winnings = cashout-buyin;
	
	[ProjectFunctions updateBankroll:winnings bankrollName:[ProjectFunctions getUserDefaultValue:@"bankrollDefault"] MOC:managedObjectContext];
    
	NSDate *startTime = datePicker.date;
	NSDate *endTime = [startTime dateByAddingTimeInterval:60*min];
	NSString *year = [startTime convertDateToStringWithFormat:@"yyyy"];
	NSString *startTimeString = [startTime convertDateToStringWithFormat:nil];
	NSString *endTimeString = [endTime convertDateToStringWithFormat:nil];

	NSString *location = [ProjectFunctions getUserDefaultValue:@"locationDefault"];
	NSString *bankroll = [ProjectFunctions getUserDefaultValue:@"bankrollDefault"];
	NSString *gameName = [NSString stringWithFormat:@"%@ %@ %@",  game, blinds, limit];
	NSString *gameType = @"Cash";
	if(gameTypeSegmentBar.selectedSegmentIndex==1) {
		gameName = [NSString stringWithFormat:@"%@ %@ %@",  game, tournamentType, limit];
		gameType = @"Tournament";
	}

	NSMutableArray *formDataArray = [[NSMutableArray alloc] init];
	[formDataArray addObject:startTimeString];
	[formDataArray addObject:endTimeString];
	[formDataArray addObject:[NSString stringWithFormat:@"%d",  (int)hours]];
	[formDataArray addObject:[NSString stringWithFormat:@"%d",  buyin]];
	[formDataArray addObject:@"0"]; // rebuy
	[formDataArray addObject:@"0"]; // food
	[formDataArray addObject:[NSString stringWithFormat:@"%d",  cashout]];
	[formDataArray addObject:[NSString stringWithFormat:@"%d",  winnings]];
	[formDataArray addObject:gameName];
	[formDataArray addObject:game];
	[formDataArray addObject:blinds];
	[formDataArray addObject:limit];
	[formDataArray addObject:location];
	[formDataArray addObject:bankroll];
	[formDataArray addObject:@"0"]; // num rebuys
	[formDataArray addObject:@"Old Game"]; // Notes
	[formDataArray addObject:@"0"]; // break minutes
	[formDataArray addObject:@"0"]; // tokes
	[formDataArray addObject:[NSString stringWithFormat:@"%d",  min]]; // minutes
	[formDataArray addObject:year];
	[formDataArray addObject:gameType];
	[formDataArray addObject:@"Completed"];
	[formDataArray addObject:tournamentType];
	[formDataArray addObject:@"0"]; // user_id
	[formDataArray addObject:[startTime convertDateToStringWithFormat:@"EEEE"]];
	[formDataArray addObject:[startTime convertDateToStringWithFormat:@"MMMM"]];
	[formDataArray addObject:[ProjectFunctions getDayTimeFromDate:startTime]];

	NSLog(@"inserting");
	self.mo = [NSEntityDescription insertNewObjectForEntityForName:@"GAME" inManagedObjectContext:managedObjectContext];
	[ProjectFunctions updateGameInDatabase:managedObjectContext mo:self.mo valueList:formDataArray];

	[ProjectFunctions updateGamesOnDevice:self.managedObjectContext];

	if([ProjectFunctions shouldSyncGameResultsWithServer:managedObjectContext]) {
		[activityIndicatorServer startAnimating];
		self.textViewBG.alpha=1;
		self.activityLabel.alpha=1;
		[self executeThreadedJob:@selector(refreshWebRequest)];
	} else {
		[ProjectFunctions showAlertPopupWithDelegate:@"Game Over!" message:@"Game data has been saved" delegate:self];
	}


}





- (void)viewDidLoad {
	
    [super viewDidLoad];
	[self setTitle:@"Enter Game"];
	self.datePicker.date = [NSDate date];
	
	self.navigationItem.rightBarButtonItem = [ProjectFunctions navigationButtonWithTitle:@"Save" selector:@selector(saveButtonClicked:) target:self];

	self.buyinAmount.text = [ProjectFunctions getUserDefaultValue:@"buyinDefault"];
	if([[ProjectFunctions getUserDefaultValue:@"gameTypeDefault"] isEqualToString:@"Tournament"]) {
		self.gameTypeSegmentBar.selectedSegmentIndex=1;
		self.buyinAmount.text = [ProjectFunctions getUserDefaultValue:@"tournbuyinDefault"];
	}
	self.hoursPlayed.text = @"3";
	self.cashOutAmount.text = @"0";
    
    buyinMoneyLabel.text = [ProjectFunctions getMoneySymbol];
    cashoutMoneyLabel.text = [ProjectFunctions getMoneySymbol];;

	[ProjectFunctions initializeSegmentBar:gameNameSegmentBar defaultValue:[ProjectFunctions getUserDefaultValue:@"gameNameDefault"]];
	[ProjectFunctions initializeSegmentBar:blindTypeSegmentBar defaultValue:[ProjectFunctions getUserDefaultValue:@"blindDefault"]];
	[ProjectFunctions initializeSegmentBar:limitTypeSegmentBar defaultValue:[ProjectFunctions getUserDefaultValue:@"limitDefault"]];
	[ProjectFunctions initializeSegmentBar:TourneyTypeSegmentBar defaultValue:[ProjectFunctions getUserDefaultValue:@"tourneyTypeDefault"]];
	

	self.gameNameSegmentBar.selectedSegmentIndex = [ProjectFunctions getSegmentValueForSegment:0 currentValue:[ProjectFunctions getUserDefaultValue:@"gameNameDefault"] startGameScreen:NO];
//	self.blindTypeSegmentBar.selectedSegmentIndex = [ProjectFunctions getSegmentValueForSegment:1 currentValue:[ProjectFunctions getUserDefaultValue:@"blindDefault"] startGameScreen:NO];
	self.limitTypeSegmentBar.selectedSegmentIndex = [ProjectFunctions getSegmentValueForSegment:2 currentValue:[ProjectFunctions getUserDefaultValue:@"limitDefault"] startGameScreen:NO];
	self.TourneyTypeSegmentBar.selectedSegmentIndex = [ProjectFunctions getSegmentValueForSegment:3 currentValue:[ProjectFunctions getUserDefaultValue:@"tourneyTypeDefault"] startGameScreen:NO];

	[self setSegmentForType];
	
	self.textViewBG.alpha=0;
	self.activityLabel.alpha=0;
	
	hoursPlayed.keyboardType = UIKeyboardTypeDecimalPad;
	buyinAmount.keyboardType = UIKeyboardTypeDecimalPad;
	cashOutAmount.keyboardType = UIKeyboardTypeDecimalPad;
	
	[ProjectFunctions makeSegment:self.gameTypeSegmentBar color:[UIColor colorWithRed:.8 green:.7 blue:0 alpha:1]];
	[ProjectFunctions makeSegment:self.gameNameSegmentBar color:[UIColor colorWithRed:0 green:.2 blue:0 alpha:1]];
	[ProjectFunctions makeSegment:self.blindTypeSegmentBar color:[UIColor colorWithRed:0 green:.2 blue:0 alpha:1]];
	[ProjectFunctions makeSegment:self.limitTypeSegmentBar color:[UIColor colorWithRed:0 green:.2 blue:0 alpha:1]];
	[ProjectFunctions makeSegment:self.TourneyTypeSegmentBar color:[UIColor colorWithRed:0 green:.2 blue:0 alpha:1]];

	[ProjectFunctions populateSegmentBar:self.blindTypeSegmentBar mOC:self.managedObjectContext];

}

-(void)setSegmentBarToNewvalue:(UISegmentedControl *)segmentBar value:(NSString *)value
{
	[segmentBar setTitle:value forSegmentAtIndex:0];
	segmentBar.selectedSegmentIndex=0;
}

-(void) setReturningValue:(NSString *) value2 {
	
	NSString *value = [NSString stringWithFormat:@"%@", [ProjectFunctions getUserDefaultValue:@"returnValue"]];
	if(selectedObjectForEdit==4)
		[self setSegmentBarToNewvalue:gameNameSegmentBar value:value];
	if(selectedObjectForEdit==5)
		[self setSegmentBarToNewvalue:blindTypeSegmentBar value:value];
	if(selectedObjectForEdit==6)
		[self setSegmentBarToNewvalue:limitTypeSegmentBar value:value];
	if(selectedObjectForEdit==7)
		[self setSegmentBarToNewvalue:TourneyTypeSegmentBar value:value];
	
	
}





@end
