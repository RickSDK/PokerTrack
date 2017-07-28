//
//  GoalsVC.m
//  PokerTracker
//
//  Created by Rick Medved on 11/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GoalsVC.h"
#import "ProjectFunctions.h"
#import "NSDate+ATTDate.h"
#import "MoneyPickerVC.h"
#import "MultiLineDetailCellWordWrap.h"
#import "CoreDataLib.h"
#import "NSArray+ATTArray.h"
#import "BankrollsVC.h"
#import "PokerTrackerAppDelegate.h"


@implementation GoalsVC
@synthesize managedObjectContext;
@synthesize mainTableView, selectedObjectForEdit, profitButton, hourlyButton;
@synthesize chart1ImageView, chart2ImageView;
@synthesize monthlyProfits, hourlyProfits, bankrollButton, bankRollSegment;
@synthesize activityBGView, activityIndicator, coreDataLocked;

- (void)viewDidLoad {
	[super viewDidLoad];
	[self setTitle:NSLocalizedString(@"Goals", nil)];
	[self changeNavToIncludeType:15];
	
	self.monthlyProfits = [[NSMutableArray alloc] init];
	self.hourlyProfits = [[NSMutableArray alloc] init];
	chart1ImageView = [[UIImageView alloc] init];
	chart2ImageView = [[UIImageView alloc] init];
	self.selectedObjectForEdit=0;
	
	self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:
											   [ProjectFunctions UIBarButtonItemWithIcon:[NSString fontAwesomeIconStringForEnum:FAHome] target:self action:@selector(mainMenuButtonClicked:)],
											   [ProjectFunctions UIBarButtonItemWithIcon:[NSString fontAwesomeIconStringForEnum:FAInfoCircle] target:self action:@selector(popupButtonClicked)],
											   nil];
	
	self.popupView.titleLabel.text = self.title;
	self.popupView.textView.text = @"Track your goals! Choose a monthly amount and an hourly amount. Then check here to see which months you hit your goals.";
	self.popupView.textView.hidden=NO;

	self.profitGoalLabel.text=[NSString stringWithFormat:@"%@ %@ %@", NSLocalizedString(@"month", nil), NSLocalizedString(@"Profit", nil), NSLocalizedString(@"Goals", nil)];
	self.hourlyGoalLabel.text=[NSString stringWithFormat:@"%@ %@ %@", NSLocalizedString(@"Hourly", nil), NSLocalizedString(@"Profit", nil), NSLocalizedString(@"Goals", nil)];
	
	int numBanks = [[ProjectFunctions getUserDefaultValue:@"numBanks"] intValue];
	
	self.bankrollButton.alpha=1;
	self.bankRollSegment.alpha=1;
	
	if(numBanks==0) {
		self.bankrollButton.alpha=0;
		self.bankRollSegment.alpha=0;
	}
}

-(void)mainMenuButtonClicked:(id)sender {
	[self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
}

- (IBAction) bankrollSegmentChanged: (id) sender
{
    [ProjectFunctions bankSegmentChangedTo:(int)self.bankRollSegment.selectedSegmentIndex];
    [self computeStats];
}

- (IBAction) bankrollPressed: (id) sender
{
	BankrollsVC *detailViewController = [[BankrollsVC alloc] initWithNibName:@"BankrollsVC" bundle:nil];
	detailViewController.managedObjectContext = managedObjectContext;
	detailViewController.callBackViewController = self;
	[self.navigationController pushViewController:detailViewController animated:YES];
    
}

- (IBAction) monthlyProfitGoalChanged: (id) sender
{
	self.selectedObjectForEdit=0;
	MoneyPickerVC *detailViewController = [[MoneyPickerVC alloc] initWithNibName:@"MoneyPickerVC" bundle:nil];
	detailViewController.managedObjectContext=managedObjectContext;
	detailViewController.callBackViewController = self;
	detailViewController.titleLabel = @"Monthly Goal";
	detailViewController.initialDateValue = [ProjectFunctions getUserDefaultValue:@"profitGoal"];
	[self.navigationController pushViewController:detailViewController animated:YES];
}

- (IBAction) hourlyGoalChanged: (id) sender
{
	self.selectedObjectForEdit=1;
	MoneyPickerVC *detailViewController = [[MoneyPickerVC alloc] initWithNibName:@"MoneyPickerVC" bundle:nil];
	detailViewController.managedObjectContext=managedObjectContext;
	detailViewController.callBackViewController = self;
	detailViewController.titleLabel = @"Hourly Goal";
	detailViewController.initialDateValue = [ProjectFunctions getUserDefaultValue:@"hourlyGoal"];
	[self.navigationController pushViewController:detailViewController animated:YES];
}

-(void)calculateStats {
	[self computeStats];
}

- (void)computeStats
{
	self.bankRollSegment.enabled=NO;
	self.bankrollButton.enabled=NO;
	self.mainTableView.alpha=.5;
	[self.webServiceView startWithTitle:@"Working..."];
	[self performSelectorInBackground:@selector(doTheHardWork) withObject:nil];
}

-(void)doTheHardWork
{
	@autoreleasepool {
		NSLog(@"Working...");
		[NSThread sleepForTimeInterval:0.5];
        NSManagedObjectContext *contextLocal = [[NSManagedObjectContext alloc] init];
        [contextLocal setUndoManager:nil];
        
        PokerTrackerAppDelegate *appDelegate = (PokerTrackerAppDelegate *)[[UIApplication sharedApplication] delegate];
        [contextLocal setPersistentStoreCoordinator:appDelegate.persistentStoreCoordinator];
        
		[self.monthlyProfits removeAllObjects];
		[hourlyProfits removeAllObjects];
		NSString *basicPred = [ProjectFunctions getBasicPredicateString:self.yearChangeView.statYear type:@"All"];
		NSArray *months = [ProjectFunctions namesOfAllMonths];
		for(NSString *month in months) {
			NSPredicate *predicate = [ProjectFunctions predicateForBasic:basicPred field:@"month" value:month];
			NSString *chart1 = [CoreDataLib getGameStat:contextLocal dataField:@"chart1" predicate:predicate];
			NSArray *values = [chart1 componentsSeparatedByString:@"|"];
			double winnings = [[values stringAtIndex:0] doubleValue];
			int gameCount = [[values stringAtIndex:1] intValue];
			int minutes = [[values stringAtIndex:2] intValue];
			
			int hours = minutes/60;
			int hourlyRate = 0;
			if(hours>0)
				hourlyRate = winnings/hours;
			[self.monthlyProfits addObject:[NSString stringWithFormat:@"%f|%d", winnings, gameCount]];
			[self.hourlyProfits addObject:[NSString stringWithFormat:@"%d|%d", hourlyRate, gameCount]];
		}
		int profitGoal = [[ProjectFunctions getUserDefaultValue:@"profitGoal"] intValue];
		int hourlyGoal = [[ProjectFunctions getUserDefaultValue:@"hourlyGoal"] intValue];
		[profitButton setTitle:[NSString stringWithFormat:@"%@", [ProjectFunctions convertIntToMoneyString:profitGoal]] forState:UIControlStateNormal];
		[hourlyButton setTitle:[NSString stringWithFormat:@"%@/hr", [ProjectFunctions convertIntToMoneyString:hourlyGoal]] forState:UIControlStateNormal];

		self.chart1ImageView.image = [ProjectFunctions graphGoalsChart:contextLocal displayYear:self.yearChangeView.statYear chartNum:1 goalFlg:YES];
		self.chart2ImageView.image = [ProjectFunctions graphGoalsChart:contextLocal displayYear:self.yearChangeView.statYear chartNum:2 goalFlg:YES];
		
		self.bankRollSegment.enabled=YES;
		self.bankrollButton.enabled=YES;
		
		self.mainTableView.alpha=1;
		[self.webServiceView stop];
		[mainTableView reloadData];
 	}
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if([self respondsToSelector:@selector(edgesForExtendedLayout)])
        [self setEdgesForExtendedLayout:UIRectEdgeBottom];

    [ProjectFunctions setBankSegment:self.bankRollSegment];
    [self computeStats];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if(indexPath.section ==0 || indexPath.section==2)
		return 150;
	
	return 20*13;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	NSArray *titles = [NSArray arrayWithObjects:
					   [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"month", nil), NSLocalizedString(@"Profit", nil)],
					   [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"month", nil), NSLocalizedString(@"Profit", nil)],
					   NSLocalizedString(@"Hourly", nil),
					   NSLocalizedString(@"Hourly", nil),
					   nil];
	return [ProjectFunctions getViewForHeaderWithText:[titles stringAtIndex:(int)section]];
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return 22;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if(section==0)
		return [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"month", nil), NSLocalizedString(@"Profit", nil)];
	if(section==2)
		return NSLocalizedString(@"Hourly", nil);
	return nil;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *CellIdentifier = [NSString stringWithFormat:@"cellIdentifierSection%dRow%d", (int)indexPath.section, (int)indexPath.row];
	
	if(indexPath.section==0) {
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
		}
		cell.backgroundView = chart1ImageView; 
		cell.backgroundColor = [UIColor clearColor];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		return cell;
	}
	
	if(indexPath.section==2) {
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
		}
		cell.backgroundView = chart2ImageView; 
		cell.backgroundColor = [UIColor whiteColor];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		return cell;
	}
	
	if(indexPath.section==1) {
		NSMutableArray *months = [[NSMutableArray alloc] initWithArray:[ProjectFunctions namesOfAllMonths]];
		[months addObject:@"Total"];
		int NumberOfRows=(int)[months count];
		MultiLineDetailCellWordWrap *cell = (MultiLineDetailCellWordWrap *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[MultiLineDetailCellWordWrap alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier withRows:NumberOfRows labelProportion:0.35];
		}
		cell.mainTitle = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"month", nil), NSLocalizedString(@"Profit", nil)];
	
		NSMutableArray *values = [[NSMutableArray alloc] init];
		NSMutableArray *colors = [[NSMutableArray alloc] init];
		int totalSuccess=0;
		int goalAmount = [[ProjectFunctions getUserDefaultValue:@"profitGoal"] intValue];
		
		for(NSString *item in self.monthlyProfits) {
			NSArray *components = [item componentsSeparatedByString:@"|"];
			double profits = [[components objectAtIndex:0] doubleValue];
			int games = [[components objectAtIndex:1] intValue];
			NSString *gameTxt = (games==1)?NSLocalizedString(@"Game", nil):NSLocalizedString(@"Games", nil);
			[values addObject:[NSString stringWithFormat:@"%@ (%d %@)", [ProjectFunctions convertIntToMoneyString:profits], games, gameTxt]];
			
			if(profits>0 && profits<goalAmount)
				[colors addObject:[UIColor blueColor]];
			else
				[colors addObject:[CoreDataLib getFieldColor:profits]];

			if(profits != 0)
				profits -= goalAmount;
			if(profits>0)
				totalSuccess++;
		}
		[values addObject:[NSString stringWithFormat:@"%d Successful Months", totalSuccess]];
		[colors addObject:[UIColor orangeColor]];

		if([months count]==[values count]) {
			cell.titleTextArray = months;
			cell.fieldTextArray = values;
			cell.fieldColorArray = colors;
		}
		
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		return cell;
	}
	
	if(indexPath.section==3) {
		NSMutableArray *months = [[NSMutableArray alloc] initWithArray:[ProjectFunctions namesOfAllMonths]];
		[months addObject:@"Total"];
		int NumberOfRows=(int)[months count];
		MultiLineDetailCellWordWrap *cell = (MultiLineDetailCellWordWrap *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[MultiLineDetailCellWordWrap alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier withRows:NumberOfRows labelProportion:0.4];
		}
		cell.mainTitle = NSLocalizedString(@"Hourly", nil);
		NSMutableArray *values = [[NSMutableArray alloc] init];
		NSMutableArray *colors = [[NSMutableArray alloc] init];
		int totalSuccess=0;
		int goalAmount = [[ProjectFunctions getUserDefaultValue:@"hourlyGoal"] intValue];
		for(NSString *item in self.hourlyProfits) {
			NSArray *components = [item componentsSeparatedByString:@"|"];
			int profits = [[components objectAtIndex:0] intValue];
			int games = [[components objectAtIndex:1] intValue];
			NSString *gameTxt = (games==1)?NSLocalizedString(@"Game", nil):NSLocalizedString(@"Games", nil);
			[values addObject:[NSString stringWithFormat:@"%@ (%d %@)", [ProjectFunctions convertIntToMoneyString:profits], games, gameTxt]];
			
			if(profits>0 && profits<goalAmount)
				[colors addObject:[UIColor blueColor]];
			else
				[colors addObject:[CoreDataLib getFieldColor:profits]];
				
			if(profits != 0)
				profits -= goalAmount;
			
			if(profits>0)
				totalSuccess++;
			
		}
		[values addObject:[NSString stringWithFormat:@"%d Successful Months", totalSuccess]];
		[colors addObject:[UIColor orangeColor]];
	
		if([months count]==[values count]) {
			cell.titleTextArray = months;
			cell.fieldTextArray = values;
			cell.fieldColorArray = colors;
		}
		
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		return cell;
	}
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
	}
	
	cell.backgroundColor = [UIColor whiteColor];
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	
	return cell;
}

-(void) setReturningValue:(NSString *) value2 {
	NSString *value = [ProjectFunctions getUserDefaultValue:@"returnValue"];
	if(selectedObjectForEdit==0) {
		[profitButton setTitle:value forState:UIControlStateNormal];
		[ProjectFunctions setUserDefaultValue:value forKey:@"profitGoal"];
	}
	if(selectedObjectForEdit==1) {
		[hourlyButton setTitle:value forState:UIControlStateNormal];
		[ProjectFunctions setUserDefaultValue:value forKey:@"hourlyGoal"];
	}
	[self computeStats];
}



@end
