//
//  GameDetailsVC.m
//  PokerTracker
//
//  Created by Rick Medved on 10/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GameDetailsVC.h"
#import "UIColor+ATTColor.h"
#import "DatePickerViewController.h"
#import "SelectionCell.h"
#import "NSDate+ATTDate.h"
#import "NSString+ATTString.h"
#import "NSArray+ATTArray.h"
#import "MoneyPickerVC.h"
#import "ListPicker.h"
#import "CoreDataLib.h"
#import "GamesVC.h"
#import "ProjectFunctions.h"
#import "TextEnterVC.h"
#import "MinuteEnterVC.h"
#import "MultiLineDetailCellWordWrap.h"
#import "ActionCell.h"
#import "GameGraphVC.h"
#import "MainMenuVC.h"


@implementation GameDetailsVC
@synthesize managedObjectContext;
@synthesize formDataArray, selectedFieldIndex, mainTableView, labelValues, labelTypes, changesMade;
@synthesize doneButton, topProgressLabel, saveEditButton, viewEditable;
@synthesize mo, buttonForm;
@synthesize activityIndicatorServer, textViewBG, activityLabel;
@synthesize graphButton, dateLabel, amountLabel, timeLabel;


- (IBAction) graphButtonPressed: (id) sender
{
	GameGraphVC *detailViewController = [[GameGraphVC alloc] initWithNibName:@"GameGraphVC" bundle:nil];
	detailViewController.managedObjectContext=managedObjectContext;
	detailViewController.mo=mo;
	[self.navigationController pushViewController:detailViewController animated:YES];
}

- (IBAction) doneButtonPressed: (id) sender 
{
	self.selectedFieldIndex = kCashOut;
	
	MoneyPickerVC *detailViewController = [[MoneyPickerVC alloc] initWithNibName:@"MoneyPickerVC" bundle:nil];
	detailViewController.managedObjectContext=managedObjectContext;
	detailViewController.callBackViewController = self;
	detailViewController.initialDateValue = [NSString stringWithFormat:@"%@", [self.formDataArray stringAtIndex:kCashOut]];
	detailViewController.titleLabel = [NSString stringWithFormat:@"%@", [self.labelValues stringAtIndex:kCashOut]];
	[self.navigationController pushViewController:detailViewController animated:YES];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if(buttonForm==99) {
		UIViewController *mainMenu = [self.navigationController.viewControllers objectAtIndex:1];
		[self.navigationController popToViewController:mainMenu animated:YES];

	} 
	if(buttonForm==0) {
		if(buttonIndex==1)
			[self.navigationController popViewControllerAnimated:YES];
	}
	if(buttonForm==101) {
		if(buttonIndex==1 && mo != nil) {
			[managedObjectContext deleteObject:mo];
			[managedObjectContext save:nil];
			[ProjectFunctions updateGamesOnDevice:self.managedObjectContext];

			[self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
		}
	}
}

- (void) cancelButtonClicked:(id)sender {
	if(changesMade)
		[ProjectFunctions showConfirmationPopup:@"Warning" message:@"Your changes have not been saved! Do you want to exit without saving?" delegate:self tag:1];
	else
		[self.navigationController popViewControllerAnimated:YES];
}

-(void)refreshWebRequest
{
	@autoreleasepool {
    
		if([ProjectFunctions uploadUniverseStats:managedObjectContext])
			[ProjectFunctions showAlertPopupWithDelegate:@"Success" message:@"Server data synced" delegate:self];

		
		self.textViewBG.alpha=0;
		self.activityLabel.alpha=0;
		[activityIndicatorServer stopAnimating];
	}
}

-(void)executeThreadedJob:(SEL)aSelector
{
	[self performSelectorInBackground:aSelector withObject:nil];
	
}

- (void) saveButtonClicked:(id)sender {
	if(!viewEditable) {
		[saveEditButton setTitle:@"Save"];
		self.viewEditable = YES;
		self.saveEditButton.enabled=NO;
		self.changesMade=NO;
		[mainTableView reloadData];
		return;
	}
	self.saveEditButton.enabled=NO;
	self.changesMade=NO;
	
	NSDate *startTime = [(NSString *)[self.formDataArray stringAtIndex:kStartTime] convertStringToDateFinalSolution];
	[self.formDataArray replaceObjectAtIndex:24 withObject:[startTime convertDateToStringWithFormat:@"EEEE"]];
	[self.formDataArray replaceObjectAtIndex:25 withObject:[startTime convertDateToStringWithFormat:@"MMMM"]];
	[self.formDataArray replaceObjectAtIndex:26 withObject:[ProjectFunctions getDayTimeFromDate:startTime]];
	
	int year = [[startTime convertDateToStringWithFormat:@"yyyy"] intValue];
	int seconds = [[(NSString *)[self.formDataArray stringAtIndex:kEndTime] convertStringToDateWithFormat:nil] timeIntervalSinceDate:startTime];
	int minutes = (int)(seconds/60);
	[self.formDataArray replaceObjectAtIndex:2 withObject:[NSString stringWithFormat:@"%d",  minutes/60]];
	[self.formDataArray replaceObjectAtIndex:kminutes withObject:[NSString stringWithFormat:@"%d",  minutes]];
	[self.formDataArray replaceObjectAtIndex:kYear withObject:[NSString stringWithFormat:@"%d",  year]];
	if([[mo valueForKey:@"Type"] isEqualToString:@"Tournament"])
		[self.formDataArray replaceObjectAtIndex:kTourneyType withObject:[self.formDataArray stringAtIndex:kBlinds]]; //<-- tournament type

	int oldProfit = [[mo valueForKey:@"winnings"] intValue];
	int newprofit = [[self.formDataArray stringAtIndex:7] intValue];
	if(oldProfit != newprofit) {
		int netProfit = newprofit-oldProfit;
        [ProjectFunctions updateBankroll:netProfit bankrollName:[mo valueForKey:@"bankroll"] MOC:managedObjectContext];
	}

	[ProjectFunctions updateGameInDatabase:self.managedObjectContext mo:mo valueList:self.formDataArray];
	
	self.buttonForm=99;
	if([ProjectFunctions shouldSyncGameResultsWithServer:managedObjectContext]) {
		[activityIndicatorServer startAnimating];
		self.textViewBG.alpha=1;
		self.activityLabel.alpha=1;
		[self executeThreadedJob:@selector(refreshWebRequest)];
	} else {
		[ProjectFunctions showAlertPopupWithDelegate:@"Game Updated!" message:@"Game data has been saved" delegate:self];
	}

	
}


-(void)mainMenuButtonClicked:(id)sender {
	[self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if([self respondsToSelector:@selector(edgesForExtendedLayout)])
        [self setEdgesForExtendedLayout:UIRectEdgeBottom];
}



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[self setTitle:@"Game Details"];

	self.labelTypes = [[NSMutableArray alloc] init];
	self.labelValues = [[NSMutableArray alloc] init];
	self.formDataArray = [[NSMutableArray alloc] init];

	self.selectedFieldIndex=0;
	self.changesMade=NO;
	self.buttonForm=0;
	
	dateLabel.text = [[mo valueForKey:@"startTime"] convertDateToStringWithFormat:@"MMM d, yyyy"];
	timeLabel.text = [[mo valueForKey:@"startTime"] convertDateToStringWithFormat:@"hh:mm a"];
	amountLabel.text = [ProjectFunctions displayMoney:mo column:@"winnings"];
	
	if(viewEditable) {
		self.navigationItem.leftBarButtonItem = [ProjectFunctions navigationButtonWithTitle:@"Main Menu" selector:@selector(mainMenuButtonClicked:) target:self];

		
	} else if([[mo valueForKey:@"user_id"] intValue]==0) {
		self.navigationItem.leftBarButtonItem = [ProjectFunctions navigationButtonWithTitle:@"Back" selector:@selector(cancelButtonClicked:) target:self];

	}
	
	if([[mo valueForKey:@"user_id"] intValue]>0) {
//		saveEditButton = [ProjectFunctions navigationButtonWithTitle:@"Main Menu" selector:@selector(mainMenuButtonClicked:) target:self];
		saveEditButton = [[UIBarButtonItem alloc] initWithTitle:@"Main Menu" style:UIBarButtonItemStylePlain target:self action:@selector(mainMenuButtonClicked:)];
		self.navigationItem.rightBarButtonItem = saveEditButton;
	} else {
		NSString *buttonName = (viewEditable)?@"Save":@"Edit";
//		saveEditButton = [ProjectFunctions navigationButtonWithTitle:buttonName selector:@selector(saveButtonClicked:) target:self];

		saveEditButton = [[UIBarButtonItem alloc] initWithTitle:buttonName style:UIBarButtonItemStylePlain target:self action:@selector(saveButtonClicked:)];
		self.navigationItem.rightBarButtonItem = saveEditButton;
		self.changesMade=YES;
	}
	self.saveEditButton.enabled=YES;
	
	[super viewDidLoad];
	
	NSString *gameType = [NSString stringWithFormat:@"%@", [mo valueForKey:@"Type"]];
	NSString *foodName = @"Food & Drinks";
	NSString *stakesName = @"Stakes";
	NSString *tokesName = @"Dealer Tokes";
	NSString *foodType = @"Money";
	NSString *breakMinutes = @"Minutes on Break";
	if([gameType isEqualToString:@"Tournament"]) {
		foodName = @"Number of Players";
		stakesName = @"Tournament Type";
		tokesName = @"Place Finished";
		foodType = @"Min";
		breakMinutes = @"Spots Paid";
	}
	
	// Used to set up the inital Form
	NSArray *data = [NSArray arrayWithObjects:
					 [NSArray arrayWithObjects:@"Start Time",		@"Time",	[[NSDate date] convertDateToStringWithFormat:nil], nil],
					 [NSArray arrayWithObjects:@"End Time",			@"Time",	[[[NSDate date] dateByAddingTimeInterval:60*60*3] convertDateToStringWithFormat:nil], nil],
					 [NSArray arrayWithObjects:@"Hours Played",		@"None",	@"3", nil],
					 [NSArray arrayWithObjects:@"Buy-in Amount",	@"Money",	@"0", nil],
					 [NSArray arrayWithObjects:@"Re-buy Amount",	@"Money",	@"0", nil],
					 [NSArray arrayWithObjects:foodName,			foodType,	@"0", nil],
					 [NSArray arrayWithObjects:@"Cash Out Amount",	@"Money",	@"0", nil],
					 [NSArray arrayWithObjects:@"Profit",			@"None",	@"0", nil],
					 [NSArray arrayWithObjects:@"Name",				@"None",	@"0", nil],
					 [NSArray arrayWithObjects:@"Game",				@"List",	@"0", nil],
					 [NSArray arrayWithObjects:stakesName,			@"List",	@"0", nil],
					 [NSArray arrayWithObjects:@"Limit",			@"List",	@"0", nil],
					 [NSArray arrayWithObjects:@"Location",			@"List",	@"0", nil],
					 [NSArray arrayWithObjects:@"Bankroll",			@"List",	@"0", nil],
					 [NSArray arrayWithObjects:@"Number of Rebuys",	@"List",	@"0", nil],
					 [NSArray arrayWithObjects:@"Notes",			@"Text",	@"", nil],
					 [NSArray arrayWithObjects:breakMinutes,		@"Min",		@"", nil],
					 [NSArray arrayWithObjects:tokesName,			@"Min",		@"", nil],
					 nil];
	
	for(NSArray *line in data)
		[self.labelValues addObject:[line stringAtIndex:0]];
	
	
	for(NSArray *line in data)
		[self.labelTypes addObject:[line stringAtIndex:1]];
	
	for(NSArray *line in data)
		[self.formDataArray addObject:[line stringAtIndex:2]];
	
	[self.formDataArray addObject:@"0"]; //<-- minutes
	[self.formDataArray addObject:@"0"]; //<-- year
	[self.formDataArray addObject:@""]; //<--  Type
	[self.formDataArray addObject:@""]; //<-- status
	[self.formDataArray addObject:@""]; //<-- tournament type
	[self.formDataArray addObject:@"0"]; //<-- user_id
	[self.formDataArray addObject:@""]; //<-- weekday
	[self.formDataArray addObject:@""]; //<-- month
	[self.formDataArray addObject:@""]; //<-- dayTime
	
	self.changesMade=NO;
	self.textViewBG.alpha=0;
	self.activityLabel.alpha=0;
		
	NSArray *keyList = [ProjectFunctions getColumnListForEntity:@"GAME" type:@"column"];
	NSArray *typeList = [ProjectFunctions getColumnListForEntity:@"GAME" type:@"type"];
		
		
	int i=0;
	for(NSString *key in keyList) {
		NSString *type = [typeList stringAtIndex:i];
		NSString *value = [mo valueForKey:key];
		if([type isEqualToString:@"date"]) {
			NSDate *thisDate = [mo valueForKey:key];
			value = [thisDate convertDateToStringWithFormat:nil];
		}
		if([type isEqualToString:@"int"]) {
			
			value = [NSString stringWithFormat:@"%d", [[mo valueForKey:key] intValue]];
		}
		if(value==nil)
			value = @"";
		if(i<[self.formDataArray count])
			[self.formDataArray replaceObjectAtIndex:i withObject:value];
		i++;
	} // for
	if([gameType isEqualToString:@"Tournament"]) {
		[self.formDataArray replaceObjectAtIndex:kBlinds withObject:[mo valueForKey:@"tournamentType"]];
		[self.formDataArray replaceObjectAtIndex:kFood withObject:[mo valueForKey:@"tournamentSpots"]];
		[self.formDataArray replaceObjectAtIndex:kdealertokes withObject:[mo valueForKey:@"tournamentFinish"]];
	}
	

	
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return CGFLOAT_MIN;
}


-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return nil;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if(indexPath.section==0 && mo != nil) {
		return [MultiLineDetailCellWordWrap cellHeightWithNoMainTitleForData:[NSArray arrayWithObject:[mo valueForKey:@"notes"]]
																   tableView:tableView
														labelWidthProportion:0.4]+135;
	}
	
	return 44;
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if(section==0)
		return 1;
	
    return [self.labelValues count]+1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	NSString *cellIdentifier = [NSString stringWithFormat:@"cellIdentifierSection%dRow%d", (int)indexPath.section, (int)indexPath.row];
	if(indexPath.section==0) {
		NSString *type = [self.formDataArray stringAtIndex:kType];
		NSArray *titles = nil;
		if([type isEqualToString:@"Tournament"])
			titles = [NSArray arrayWithObjects:@"Game Type", @"BuyIn", @"Rebuy", @"Cash Out", @"Number Players", @"Place Finished", @"Net Profit", @"Notes", nil];
		else 
			titles = [NSArray arrayWithObjects:@"Game Type", @"BuyIn", @"Rebuy", @"Cash Out", @"Gross Earnings", @"Take-Home", @"Net Profit", @"Notes", nil];
		MultiLineDetailCellWordWrap *cell = (MultiLineDetailCellWordWrap *) [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
		if (cell == nil) {
			cell = [[MultiLineDetailCellWordWrap alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier withRows:[titles count] labelProportion:0.4];
		}
		float buyIn = [[self.formDataArray stringAtIndex:kbuyIn] floatValue];
		float rebuyAmount = [[self.formDataArray stringAtIndex:kRebuy] floatValue];
		int numRebuys = [[self.formDataArray stringAtIndex:kNumRebuys] intValue];
		NSString *rebuyText = [ProjectFunctions convertIntToMoneyString:rebuyAmount];
		if(numRebuys==1)
			rebuyText = [NSString stringWithFormat:@"%@ (1 rebuy)", rebuyText];
		if(numRebuys>1)
			rebuyText = [NSString stringWithFormat:@"%@ (%d rebuys)", rebuyText, numRebuys];
		int foodMoney = [[self.formDataArray stringAtIndex:kFood] intValue];
		int tokesMoney = [[self.formDataArray stringAtIndex:kdealertokes] intValue];
		float cashout = [[self.formDataArray stringAtIndex:kCashOut] floatValue];
		
		NSDate *startDate = [[self.formDataArray stringAtIndex:kStartTime] convertStringToDateWithFormat:nil];
		NSDate *endDate = [[self.formDataArray stringAtIndex:kEndTime] convertStringToDateWithFormat:nil];
		int totalSeconds = [endDate timeIntervalSinceDate:startDate];
		int breakMinutes = [[self.formDataArray stringAtIndex:kbreakMinutes] intValue];
		int breakSeconds = breakMinutes*60;
		if([[mo valueForKey:@"Type"] isEqualToString:@"Tournament"])
			breakSeconds=0;

		totalSeconds -= breakSeconds;
		
		[self.formDataArray replaceObjectAtIndex:2 withObject:[NSString stringWithFormat:@"%.1f",  (float)totalSeconds/3600]];
		float netProfit = cashout+foodMoney-buyIn-rebuyAmount;
		if([type isEqualToString:@"Tournament"])
			netProfit = cashout-buyIn-rebuyAmount;
		float grossEarnings = netProfit+tokesMoney;
		float takeHome = netProfit-foodMoney;
		
		
		NSString *hourlyText = [ProjectFunctions convertNumberToMoneyString:netProfit];
		if(totalSeconds>0)
			hourlyText = [NSString stringWithFormat:@"%@ (%@%d/hr)", hourlyText, [ProjectFunctions getMoneySymbol], (int)netProfit*3600/totalSeconds];
		
		NSMutableArray *colors = [[NSMutableArray alloc] init];
		[colors addObject:[UIColor blackColor]];
		[colors addObject:[UIColor blackColor]];
		[colors addObject:[UIColor blackColor]];
		[colors addObject:[UIColor blackColor]];
		if(grossEarnings>=0 && [type isEqualToString:@"Cash"])
			[colors addObject:[UIColor colorWithRed:0 green:.5 blue:0 alpha:1]];
		else 
			[colors addObject:[UIColor redColor]];
		if(takeHome>=0 && [type isEqualToString:@"Cash"])
			[colors addObject:[UIColor colorWithRed:0 green:.5 blue:0 alpha:1]];
		else 
			[colors addObject:[UIColor redColor]];
		if(netProfit>=0) {
			[colors addObject:[UIColor colorWithRed:0 green:.5 blue:0 alpha:1]];
		} else { 
			[colors addObject:[UIColor redColor]];
		}
		[colors addObject:[UIColor blackColor]];
		
		NSString *grossEarningsText = [ProjectFunctions convertIntToMoneyString:grossEarnings];
		NSString *takeHomeText = [ProjectFunctions convertIntToMoneyString:takeHome];
		if([type isEqualToString:@"Tournament"]) {
			grossEarningsText = [self.formDataArray stringAtIndex:kFood];
			takeHomeText = [self.formDataArray stringAtIndex:kdealertokes];
		}
		NSArray *values = [NSArray arrayWithObjects:
						   [mo valueForKey:@"Type"],
						   [ProjectFunctions convertTextToMoneyString:[self.formDataArray stringAtIndex:kbuyIn]],
						   rebuyText, 
						   [ProjectFunctions convertTextToMoneyString:[self.formDataArray stringAtIndex:kCashOut]],
						   grossEarningsText, 
						   takeHomeText, 
						   hourlyText, 
						   [NSString stringWithFormat:@"%@", [self.formDataArray stringAtIndex:kNotes]],
						   nil];
		cell.mainTitle = [[mo valueForKey:@"startTime"] convertDateToStringWithFormat:@"EEEE hh:mm a"];
		cell.alternateTitle = [NSString stringWithFormat:@"%@", [mo valueForKey:@"location"]];
		cell.titleTextArray = titles;
		cell.fieldTextArray = values;
		cell.fieldColorArray = colors;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		return cell;
	}
	if(indexPath.row<[self.labelValues count]) {
	SelectionCell *cell = (SelectionCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (cell == nil) {
		cell = [[SelectionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
	}
    cell.textLabel.text = [NSString stringWithFormat:@"%@", [self.labelValues stringAtIndex:(int)indexPath.row]];
	cell.selection.text = [NSString stringWithFormat:@"%@", [self.formDataArray stringAtIndex:(int)indexPath.row]];
	cell.backgroundColor = [UIColor ATTFaintBlue];
	cell.selectionStyle = UITableViewCellSelectionStyleGray;
	if(viewEditable)
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	else
		cell.accessoryType = UITableViewCellAccessoryNone;
	
	NSString *type = [NSString stringWithFormat:@"%@", [self.labelTypes stringAtIndex:(int)indexPath.row]];
	
	if([type isEqualToString:@"Text"]) {
		cell.backgroundColor = [UIColor whiteColor];
	}
	
	if([type isEqualToString:@"List"]) {
		cell.backgroundColor = [UIColor ATTSilver];
	}
	
	if([type isEqualToString:@"Time"]) {
		cell.backgroundColor = [UIColor colorWithRed:1 green:1 blue:.9 alpha:1];
	}
	
	if([type isEqualToString:@"Game"]) {
		cell.backgroundColor = [UIColor colorWithRed:.9 green:.9 blue:1 alpha:1];
	}
	
	if([type isEqualToString:@"Money"]) {
		cell.backgroundColor = [UIColor colorWithRed:.9 green:1 blue:.9 alpha:1]; 
		cell.selection.text = [NSString stringWithFormat:@"%@", [ProjectFunctions convertTextToMoneyString:[self.formDataArray stringAtIndex:(int)indexPath.row]]];
	}
	
	if([type isEqualToString:@"None"]) {
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
	
	if([[self.labelValues stringAtIndex:(int)indexPath.row] isEqualToString:@"Profit"]) {
		cell.selection.text = [NSString stringWithFormat:@"%@", [ProjectFunctions convertIntToMoneyString:[[self.formDataArray stringAtIndex:(int)indexPath.row] intValue]]];
		if([[self.formDataArray stringAtIndex:(int)indexPath.row] intValue]>=0)
			cell.selection.textColor = [UIColor ATTGreen];
		else
 			cell.selection.textColor = [UIColor redColor];
	}
	

    return cell;
	}
	ActionCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (cell == nil) {
		cell = [[ActionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
	}
	cell.backgroundColor = [UIColor colorWithRed:1 green:0.2 blue:0 alpha:1];
	cell.textLabel.text = @"Delete Game";
	cell.textLabel.textColor = [UIColor whiteColor];
	return cell;
	
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here -- for example, create and push another view controller.
	if(!viewEditable) {
		[ProjectFunctions showAlertPopup:@"Not in edit mode" message:@"Press edit above to make changes"];
		return;
	}
	if(indexPath.section==0)
		return;
	
	if(indexPath.row==[self.labelValues count]) {
		self.buttonForm=101;
		[ProjectFunctions showConfirmationPopup:@"Warning!" message:@"Are you sure you want to delete this game?" delegate:self tag:101];
		return;
	}
	selectedFieldIndex = (int)indexPath.row;
	NSString *type = [NSString stringWithFormat:@"%@", [self.labelTypes stringAtIndex:(int)indexPath.row]];
	NSString *labelValue = [NSString stringWithFormat:@"%@", [self.labelValues stringAtIndex:(int)indexPath.row]];
	NSString *dataValue = [NSString stringWithFormat:@"%@", [self.formDataArray stringAtIndex:(int)indexPath.row]];
	
	if([type isEqualToString:@"Time"]) {
		DatePickerViewController *localViewController = [[DatePickerViewController alloc] init];
		localViewController.labelString = labelValue;
		[localViewController setCallBackViewController:self];
		localViewController.initialDateValue = nil;
		localViewController.allowClearField = NO;
		localViewController.dateOnlyMode = NO;
		localViewController.refusePastDates = NO;
		localViewController.initialValueString = dataValue;
		[self.navigationController pushViewController:localViewController animated:YES];
	} 
	
	
	if([type isEqualToString:@"Money"]) {
		MoneyPickerVC *localViewController = [[MoneyPickerVC alloc] initWithNibName:@"MoneyPickerVC" bundle:nil];
		localViewController.managedObjectContext=managedObjectContext;
		localViewController.callBackViewController = self;
		localViewController.initialDateValue = dataValue;
		localViewController.titleLabel = labelValue;
		[self.navigationController pushViewController:localViewController animated:YES];
	}	
	if([type isEqualToString:@"List"]) {
		ListPicker *localViewController = [[ListPicker alloc] initWithNibName:@"ListPicker" bundle:nil];
		localViewController.callBackViewController=self;
		localViewController.managedObjectContext = managedObjectContext;
		if(indexPath.row==kBlinds && [[mo valueForKey:@"Type"] isEqualToString:@"Tournament"])
			localViewController.selectionList = [ProjectFunctions getArrayForSegment:3];
		else if(indexPath.row==kNumRebuys)
			localViewController.selectionList = [NSArray arrayWithObjects:@"0", @"1", @"2", @"3", @"4", @"5", nil];
		else
			localViewController.selectionList = [CoreDataLib getFieldList:labelValue mOC:managedObjectContext addAllTypesFlg:NO];

		localViewController.initialDateValue = dataValue;
		localViewController.titleLabel = labelValue;
		localViewController.selectedList = (int)indexPath.row;

		if(indexPath.row==kNumRebuys || (indexPath.row==kBlinds && [[mo valueForKey:@"Type"] isEqualToString:@"Tournament"]))
			localViewController.allowEditing=NO;
		else
			localViewController.allowEditing=YES;
		
		[self.navigationController pushViewController:localViewController animated:YES];
	}	
	if([type isEqualToString:@"Text"]) {
		TextEnterVC *localViewController = [[TextEnterVC alloc] initWithNibName:@"TextEnterVC" bundle:nil];
		[localViewController setCallBackViewController:self];
		localViewController.managedObjectContext=managedObjectContext;
		localViewController.initialDateValue = dataValue;
		localViewController.titleLabel = labelValue;
		[self.navigationController pushViewController:localViewController animated:YES];
	}	
	if([type isEqualToString:@"Min"]) {
		MinuteEnterVC *localViewController = [[MinuteEnterVC alloc] initWithNibName:@"MinuteEnterVC" bundle:nil];
		[localViewController setCallBackViewController:self];
		localViewController.initialDateValue = dataValue;
		localViewController.sendTitle = labelValue;
        localViewController.managedObjectContext=self.managedObjectContext;
		[self.navigationController pushViewController:localViewController animated:YES];
	}	
}


-(void) setReturningValue:(NSString *) value2 {
	NSString *value = [ProjectFunctions getUserDefaultValue:@"returnValue"];
//    NSString *value = (NSString *)value2;

	if(selectedFieldIndex==kEndTime  && [[(NSString *)value convertStringToDateWithFormat:nil] compare:[[self.formDataArray stringAtIndex:kStartTime] convertStringToDateWithFormat:nil]] != NSOrderedDescending) {
		[ProjectFunctions showAlertPopup:@"Error" message:@"End time must be after start time!"];
		return;
	}
	
	if(selectedFieldIndex==kStartTime  && [[[self.formDataArray stringAtIndex:kEndTime] convertStringToDateWithFormat:nil] compare:[(NSString *)value convertStringToDateWithFormat:nil]] != NSOrderedDescending) {
		[ProjectFunctions showAlertPopup:@"Error" message:@"Start time must be before end time!"];
		return;
	}
	
	if(selectedFieldIndex>kEndTime && [[self.formDataArray stringAtIndex:kEndTime] isEqualToString:[self.formDataArray stringAtIndex:kStartTime]]) {
		[ProjectFunctions showAlertPopup:@"Error" message:@"Start and end times cannot be the same!"];
		return;
	}
	
	[self.formDataArray replaceObjectAtIndex:selectedFieldIndex withObject:value];
	self.saveEditButton.enabled=YES;
	self.changesMade=YES;
	
	[ProjectFunctions updateNewvalueIfNeeded:(NSString *)value type:[self.labelValues stringAtIndex:selectedFieldIndex] mOC:self.managedObjectContext];
	
	
	
	if(selectedFieldIndex==kStartTime || selectedFieldIndex==kEndTime || selectedFieldIndex==kbreakMinutes) {
		int seconds = [[(NSString *)[self.formDataArray stringAtIndex:kEndTime] convertStringToDateWithFormat:nil] timeIntervalSinceDate:[(NSString *)[self.formDataArray stringAtIndex:kStartTime] convertStringToDateWithFormat:nil]];
		
		
		if(![[mo valueForKey:@"Type"] isEqualToString:@"Tournament"])
			seconds -= [[self.formDataArray stringAtIndex:kbreakMinutes] intValue]*60;
		
		float hours = (float)seconds/3600;
		[self.formDataArray replaceObjectAtIndex:kHoursPlayed withObject:[NSString stringWithFormat:@"%.1f", hours]];
	}
	
	if(selectedFieldIndex==kGameMode) {
		NSArray *items = [(NSString *)value componentsSeparatedByString:@" "];
		if([items count]>2) {
			[self.formDataArray replaceObjectAtIndex:kGame withObject:[items stringAtIndex:0]];
			[self.formDataArray replaceObjectAtIndex:kBlinds withObject:[items stringAtIndex:1]];
			[self.formDataArray replaceObjectAtIndex:kLimit withObject:[items stringAtIndex:2]];
		}
	}
	
	if(selectedFieldIndex==kGame || selectedFieldIndex==kBlinds || selectedFieldIndex==kLimit) {
		[self.formDataArray replaceObjectAtIndex:kGameMode withObject:[NSString stringWithFormat:@"%@ %@ %@", [self.formDataArray stringAtIndex:kGame], [self.formDataArray stringAtIndex:kBlinds], [self.formDataArray stringAtIndex:kLimit]]];
	}
	
	int foodAmount = [[self.formDataArray stringAtIndex:kFood] intValue];
	if([[self.formDataArray stringAtIndex:kType] isEqualToString:@"Tournament"])
		foodAmount=0;
	
	int winnings = [[self.formDataArray stringAtIndex:kCashOut] intValue] + foodAmount - [[self.formDataArray stringAtIndex:kRebuy] intValue] - [[self.formDataArray stringAtIndex:kbuyIn] intValue];
	
	[self.formDataArray replaceObjectAtIndex:kWinnings withObject:[NSString stringWithFormat:@"%d", winnings]];
	self.viewEditable=YES;
	
	[saveEditButton setTitle:@"Save"];
	[mainTableView reloadData];
}





@end
