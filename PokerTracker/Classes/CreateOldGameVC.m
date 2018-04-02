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
//#import "GamesVC.h"
#import "MainMenuVC.h"
#import "CoreDataLib.h"
#import "ListPicker.h"
#import "NSArray+ATTArray.h"
//#import "GameGraphVC.h"
#import "UpgradeVC.h"
#import "EditSegmentVC.h"
#import "MoneyPickerVC.h"
#import "DatePickerViewController.h"
#import "NSString+ATTString.h"


@implementation CreateOldGameVC

-(IBAction) gameTypeSegmentPressed: (id) sender
{
	[self.gameTypeSegmentBar gameSegmentChanged];
	[self setSegmentForType];
}

-(void)gotoListPicker:(NSString *)databaseField initialDateValue:(NSString *)initialDateValue
{
	EditSegmentVC *localViewController = [[EditSegmentVC alloc] initWithNibName:@"EditSegmentVC" bundle:nil];
	localViewController.callBackViewController=self;
	localViewController.managedObjectContext = self.managedObjectContext;
	localViewController.initialDateValue = initialDateValue;
	localViewController.databaseField = databaseField;
	[self.navigationController pushViewController:localViewController animated:YES];
}

- (IBAction) actioButtonPressed: (UIButton *) button {
	self.selectedObjectForEdit=(int)button.tag;

	UIButton *buttonObj = [self.buttons objectAtIndex:self.selectedObjectForEdit-10];
	
	if(self.selectedObjectForEdit==10 || self.selectedObjectForEdit==11) {
		DatePickerViewController *localViewController = [[DatePickerViewController alloc] initWithNibName:@"DatePickerViewController" bundle:nil];
		localViewController.callBackViewController=self;
		localViewController.managedObjectContext = self.managedObjectContext;
		localViewController.initialValueString = [buttonObj titleForState:UIControlStateNormal];
		[self.navigationController pushViewController:localViewController animated:YES];
	} else if(self.selectedObjectForEdit==12) {
		EditSegmentVC *localViewController = [[EditSegmentVC alloc] initWithNibName:@"EditSegmentVC" bundle:nil];
		localViewController.callBackViewController=self;
		localViewController.managedObjectContext = self.managedObjectContext;
		localViewController.initialDateValue = [buttonObj titleForState:UIControlStateNormal];
		localViewController.databaseField = @"location";
		[self.navigationController pushViewController:localViewController animated:YES];
	}else {
		MoneyPickerVC *localViewController = [[MoneyPickerVC alloc] initWithNibName:@"MoneyPickerVC" bundle:nil];
		localViewController.callBackViewController=self;
		localViewController.managedObjectContext = self.managedObjectContext;
		localViewController.initialDateValue = [buttonObj titleForState:UIControlStateNormal];
		[self.navigationController pushViewController:localViewController animated:YES];
	}

}

- (IBAction) gameSegmentPressed: (id) sender 
{
	self.selectedObjectForEdit=4;
	if(self.gameNameSegmentBar.selectedSegmentIndex==3) {
		self.gameNameSegmentBar.selectedSegmentIndex=0;
		[self gotoListPicker:@"gametype" initialDateValue:@""];
	}
}
- (IBAction) stakesSegmentPressed: (id) sender 
{
	self.selectedObjectForEdit=5;
	if(self.blindTypeSegmentBar.selectedSegmentIndex==4) {
		self.blindTypeSegmentBar.selectedSegmentIndex=0;
		[self gotoListPicker:@"stakes" initialDateValue:@""];
	}
}
- (IBAction) limitSegmentPressed: (id) sender 
{
	self.selectedObjectForEdit=6;
	if(self.limitTypeSegmentBar.selectedSegmentIndex==3) {
		self.limitTypeSegmentBar.selectedSegmentIndex=0;
		[self gotoListPicker:@"limit" initialDateValue:@""];
	}
}

-(void)setSegmentForType
{
	if(self.gameTypeSegmentBar.selectedSegmentIndex==0) {
		self.TourneyTypeSegmentBar.alpha=0;
		self.blindTypeSegmentBar.alpha=1;
		[self.button4 setTitle:[ProjectFunctions getUserDefaultValue:@"buyinDefault"] forState:UIControlStateNormal];
		[self setTitle:[NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Cash", nil), NSLocalizedString(@"Game", nil)]];
		self.button6.enabled=YES;
		self.button7.enabled=YES;
	} else {
		self.TourneyTypeSegmentBar.alpha=1;
		self.blindTypeSegmentBar.alpha=0;
		[self.button4 setTitle:[ProjectFunctions getUserDefaultValue:@"tournbuyinDefault"] forState:UIControlStateNormal];
		[self setTitle:NSLocalizedString(@"Tournament", nil)];
		[self.button6 setTitle:@"0" forState:UIControlStateNormal];
		[self.button7 setTitle:@"0" forState:UIControlStateNormal];
		self.button6.enabled=NO;
		self.button7.enabled=NO;
	}
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if(alertView.tag==104) {
		if(buttonIndex != alertView.cancelButtonIndex) {
			UpgradeVC *detailViewController = [[UpgradeVC alloc] initWithNibName:@"UpgradeVC" bundle:nil];
			detailViewController.managedObjectContext = self.managedObjectContext;
			[self.navigationController pushViewController:detailViewController animated:YES];
		}
		return;
	}
	

}

-(void)refreshWebRequest
{
	@autoreleasepool {
		if([ProjectFunctions uploadUniverseStats:self.managedObjectContext])
			[ProjectFunctions showAlertPopupWithDelegate:@"Success" message:@"Server data synced" delegate:self];

		
		[self.webServiceView stop];
	}
}

-(void)executeThreadedJob:(SEL)aSelector
{
	[self performSelectorInBackground:aSelector withObject:nil];
	
}

- (void) saveButtonClicked:(id)sender {
	
	if(![ProjectFunctions isOkToProceed:self.managedObjectContext delegate:self])
		return;
	
	

	double buyin = [[self.button4 titleForState:UIControlStateNormal] doubleValue];
	if(buyin==0) {
		[ProjectFunctions showAlertPopup:@"Buyin must be greater than 0" message:@""];
		return;
	}

		
	NSArray *ttValues = [ProjectFunctions getArrayForSegment:3];
	
	NSString *tournamentType = [ttValues objectAtIndex:self.TourneyTypeSegmentBar.selectedSegmentIndex];
	
	NSString *limit = [self.limitTypeSegmentBar titleForSegmentAtIndex:self.limitTypeSegmentBar.selectedSegmentIndex];
	NSString *game = [self.gameNameSegmentBar titleForSegmentAtIndex:self.gameNameSegmentBar.selectedSegmentIndex];
	NSString *blinds = [self.blindTypeSegmentBar titleForSegmentAtIndex:self.blindTypeSegmentBar.selectedSegmentIndex];
	
	double cashout = [[self.button5 titleForState:UIControlStateNormal] doubleValue];
	int tips = [[self.button6 titleForState:UIControlStateNormal] intValue];
	int food = [[self.button7 titleForState:UIControlStateNormal] intValue];
	int rebuys = [[self.button8 titleForState:UIControlStateNormal] intValue];
	double winnings = cashout-buyin;
	
	[ProjectFunctions updateBankroll:winnings bankrollName:[ProjectFunctions getUserDefaultValue:@"bankrollDefault"] MOC:self.managedObjectContext];
    
	NSDate *startDate = [[self.button1 titleForState:UIControlStateNormal] convertStringToDateWithFormat:nil];
	NSDate *endDate = [[self.button2 titleForState:UIControlStateNormal] convertStringToDateWithFormat:nil];
	int minutes = [endDate timeIntervalSinceDate:startDate]/60;

	NSString *location = [self.button3 titleForState:UIControlStateNormal];
	NSString *bankroll = [ProjectFunctions getUserDefaultValue:@"bankrollDefault"];
	NSString *gameName = [NSString stringWithFormat:@"%@ %@ %@",  game, blinds, limit];
	NSString *gameType = @"Cash";
	if(self.gameTypeSegmentBar.selectedSegmentIndex==1) {
		gameName = [NSString stringWithFormat:@"%@ %@ %@",  game, tournamentType, limit];
		gameType = @"Tournament";
	}

	NSMutableArray *formDataArray = [[NSMutableArray alloc] init];
	[formDataArray addObject:[self.button1 titleForState:UIControlStateNormal]];
	[formDataArray addObject:[self.button2 titleForState:UIControlStateNormal]];
	[formDataArray addObject:[NSString stringWithFormat:@"%d",  3]];
	[formDataArray addObject:[NSString stringWithFormat:@"%f",  buyin]];
	[formDataArray addObject:@"0"]; // rebuy
	[formDataArray addObject:[NSString stringWithFormat:@"%d",  food]]; // food
	[formDataArray addObject:[NSString stringWithFormat:@"%f",  cashout]];
	[formDataArray addObject:[NSString stringWithFormat:@"%f",  winnings]];
	[formDataArray addObject:gameName];
	[formDataArray addObject:game];
	[formDataArray addObject:blinds];
	[formDataArray addObject:limit];
	[formDataArray addObject:location];
	[formDataArray addObject:bankroll];
	[formDataArray addObject:[NSString stringWithFormat:@"%d",  rebuys]]; // num rebuys
	[formDataArray addObject:@"Old Game"]; // Notes
	[formDataArray addObject:@"0"]; // break minutes
	[formDataArray addObject:[NSString stringWithFormat:@"%d",  tips]]; // tokes
	[formDataArray addObject:[NSString stringWithFormat:@"%d",  minutes]]; // minutes
	[formDataArray addObject:@"2017"];
	[formDataArray addObject:gameType];
	[formDataArray addObject:@"Completed"];
	[formDataArray addObject:tournamentType];
	[formDataArray addObject:@"0"]; // user_id
	[formDataArray addObject:[ProjectFunctions getWeekDayFromDate:startDate]];
	[formDataArray addObject:[ProjectFunctions getMonthFromDate:startDate]];
	[formDataArray addObject:[ProjectFunctions getDayTimeFromDate:startDate]];

	NSLog(@"inserting");
	NSManagedObject *mo = [NSEntityDescription insertNewObjectForEntityForName:@"GAME" inManagedObjectContext:self.managedObjectContext];
	[ProjectFunctions updateGameInDatabase:self.managedObjectContext mo:mo valueList:formDataArray];
	[ProjectFunctions scrubDataForObj:mo context:self.managedObjectContext];

	[ProjectFunctions updateGamesOnDevice:self.managedObjectContext];
	[ProjectFunctions findMinAndMaxYear:self.managedObjectContext];

	if([ProjectFunctions shouldSyncGameResultsWithServer:self.managedObjectContext]) {
		[self.webServiceView startWithTitle:@"Updating Net Tracker..."];
		[self executeThreadedJob:@selector(refreshWebRequest)];
	} else {
		[ProjectFunctions showAlertPopupWithDelegate:@"Game Over!" message:@"Game data has been saved" delegate:self];
		[self.navigationController popViewControllerAnimated:YES];
	}

}

- (void)viewDidLoad {
	
    [super viewDidLoad];
	[self setTitle:NSLocalizedString(@"Game", nil)];
	
	self.navigationItem.rightBarButtonItem = [ProjectFunctions UIBarButtonItemWithIcon:[NSString fontAwesomeIconStringForEnum:FAFloppyO] target:self action:@selector(saveButtonClicked:)];

	
	NSDate *startDate = [NSDate date];
	NSDate *endDate = [startDate dateByAddingTimeInterval:60*60*3];
	[self.button1 setTitle:[startDate convertDateToStringWithFormat:nil] forState:UIControlStateNormal];
	[self.button2 setTitle:[endDate convertDateToStringWithFormat:nil] forState:UIControlStateNormal];

	self.buttons = [NSArray arrayWithObjects:self.button1, self.button2, self.button3, self.button4,
					self.button5, self.button6, self.button7, self.button8, nil];

	[ProjectFunctions initializeSegmentBar:self.gameNameSegmentBar defaultValue:[ProjectFunctions getUserDefaultValue:@"gameNameDefault"] field:@"gametype"];
	[ProjectFunctions initializeSegmentBar:self.blindTypeSegmentBar defaultValue:[ProjectFunctions getUserDefaultValue:@"blindDefault"] field:@"stakes"];
	[ProjectFunctions initializeSegmentBar:self.limitTypeSegmentBar defaultValue:[ProjectFunctions getUserDefaultValue:@"limitDefault"] field:@"limit"];
	[ProjectFunctions initializeSegmentBar:self.TourneyTypeSegmentBar defaultValue:[ProjectFunctions getUserDefaultValue:@"tourneyTypeDefault"] field:@"tournamentType"];
	
	self.gameNameSegmentBar.selectedSegmentIndex = 0;
	self.limitTypeSegmentBar.selectedSegmentIndex = 0;
	self.TourneyTypeSegmentBar.selectedSegmentIndex = 0;

	[self setSegmentForType];
	
	[self.gameTypeSegmentBar turnIntoGameSegment];
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

-(void) setReturningValue:(NSString *) value {
	NSLog(@"+++setReturningValue, %@ %d", value, self.selectedObjectForEdit);
	if(self.selectedObjectForEdit>=10) {
		UIButton *buttonObj = [self.buttons objectAtIndex:self.selectedObjectForEdit-10];
		[buttonObj setTitle:value forState:UIControlStateNormal];
	}
	if(self.selectedObjectForEdit==4)
		[self setSegmentBarToNewvalue:self.gameNameSegmentBar value:value];
	if(self.selectedObjectForEdit==5)
		[self setSegmentBarToNewvalue:self.blindTypeSegmentBar value:value];
	if(self.selectedObjectForEdit==6)
		[self setSegmentBarToNewvalue:self.limitTypeSegmentBar value:value];
	if(self.selectedObjectForEdit==7)
		[self setSegmentBarToNewvalue:self.TourneyTypeSegmentBar value:value];
	
	
}





@end
