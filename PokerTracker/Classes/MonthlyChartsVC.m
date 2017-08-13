//
//  MonthlyChartsVC.m
//  PokerTracker
//
//  Created by Rick Medved on 11/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MonthlyChartsVC.h"
#import "ProjectFunctions.h"
#import "NSDate+ATTDate.h"
#import "MoneyPickerVC.h"
#import "MultiLineDetailCellWordWrap.h"
#import "CoreDataLib.h"
#import "NSArray+ATTArray.h"
#import "BankrollsVC.h"
#import "PokerTrackerAppDelegate.h"
#import "GrabphLib.h"

#define kLeftLabelRation	0.4

@implementation MonthlyChartsVC
@synthesize managedObjectContext;
@synthesize mainTableView, selectedObjectForEdit, profitButton, hourlyButton;
@synthesize chartMonth1ImageView, chartMonth2ImageView, chart3ImageView, chart4ImageView, chart5ImageView, chart6ImageView, chartYear1ImageView, chartYear2ImageView;
@synthesize yearlyProfits, yearHourlyProfits, monthlyProfits, hourlyProfits, showBreakdownFlg;
@synthesize activityBGView, activityIndicator, moneySegment;
@synthesize dayProfits, dayHourly, timeProfits, timeHourly, lockScreen, viewUnLoaded;

- (void)viewDidLoad {
	[super viewDidLoad];
	[self setTitle:NSLocalizedString(@"Charts", nil)];
	[self changeNavToIncludeType:16];
	self.showBreakdownFlg=NO;
	
	yearlyProfits = [[NSMutableArray alloc] init];
	yearHourlyProfits = [[NSMutableArray alloc] init];
	monthlyProfits = [[NSMutableArray alloc] init];
	hourlyProfits = [[NSMutableArray alloc] init];
	dayProfits = [[NSMutableArray alloc] init];
	dayHourly = [[NSMutableArray alloc] init];
	timeProfits = [[NSMutableArray alloc] init];
	timeHourly = [[NSMutableArray alloc] init];
	
	chartMonth1ImageView = [[UIImageView alloc] init];
	chartMonth2ImageView = [[UIImageView alloc] init];
	chart3ImageView = [[UIImageView alloc] init];
	chart4ImageView = [[UIImageView alloc] init];
	chart5ImageView = [[UIImageView alloc] init];
	chart6ImageView = [[UIImageView alloc] init];
	chartYear1ImageView = [[UIImageView alloc] init];
	chartYear2ImageView = [[UIImageView alloc] init];
	self.selectedObjectForEdit=0;
	
	self.navigationItem.rightBarButtonItem = [ProjectFunctions navigationButtonWithTitle:NSLocalizedString(@"Main Menu", nil) selector:@selector(mainMenuButtonClicked:) target:self];
	
	[profitButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	[profitButton setBackgroundImage:[UIImage imageNamed:@"yellowButton.png"] forState:UIControlStateNormal];
	
	[hourlyButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	[hourlyButton setBackgroundImage:[UIImage imageNamed:@"yellowButton.png"] forState:UIControlStateNormal];
	
	[self.moneySegment setTitle:[NSString fontAwesomeIconStringForEnum:FAUsd] forSegmentAtIndex:0];
	[self.moneySegment setTitle:[NSString fontAwesomeIconStringForEnum:FAClockO] forSegmentAtIndex:1];
	[self.moneySegment changeSegment];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
	[self computeStatsAfterDelay:2];
}

-(void)mainMenuButtonClicked:(id)sender {
	[self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
}

-(void)bankrollSegmentChanged {
	[self computeStatsAfterDelay:0];
}

- (IBAction) moneySegmentChanged: (id) sender
{
	[self.moneySegment changeSegment];
	if(self.moneySegment.selectedSegmentIndex==0) {
		[self changeNavToIncludeType:16 title:@"Profit"];
	}
	if(self.moneySegment.selectedSegmentIndex==1) {
		[self changeNavToIncludeType:16 title:@"Hourly"];
	}
	[mainTableView reloadData];
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
	detailViewController.titleLabel = NSLocalizedString(@"Hourly", nil);
	detailViewController.initialDateValue = [ProjectFunctions getUserDefaultValue:@"hourlyGoal"];
	[self.navigationController pushViewController:detailViewController animated:YES];
}

-(void)yearChanged {
	[self computeStatsAfterDelay:0];
}

- (void)computeStatsAfterDelay:(int)delay
{
	self.moneySegment.enabled=NO;
	[activityIndicator startAnimating];
	activityBGView.alpha=1;
	self.lockScreen=YES;
	self.mainTableView.alpha=.5;
	[self performSelector:@selector(drawAllCharts) withObject:nil afterDelay:delay];
}

-(void)graphYearData:(NSManagedObjectContext *)context year:(int)year {
	NSLog(@"+++year: %d", year);
	NSMutableArray *years = [[NSMutableArray alloc] init];
	NSArray *items = [CoreDataLib selectRowsFromEntity:@"YEAR" predicate:nil sortColumn:@"name" mOC:context ascendingFlg:YES];
	for(NSManagedObject *mo in items) {
		[years addObject:[mo valueForKey:@"name"]];
	}
	[self graphEngineForItems:years field:@"year" context:context year:year graph1:self.chartYear1ImageView graph2:self.chartYear2ImageView];

}

-(void)graphMonthData:(NSManagedObjectContext *)context year:(int)year {
	NSArray *months = [ProjectFunctions namesOfAllMonths];
	[self graphEngineForItems:months field:@"month" context:context year:year graph1:self.chartMonth1ImageView graph2:self.chartMonth2ImageView];
}

-(void)graphEngineForItems:(NSArray *)items field:(NSString*)field context:(NSManagedObjectContext *)context year:(int)year graph1:(UIImageView *)graph1  graph2:(UIImageView *)graph2 {
	NSMutableArray *graphItemsProfit = [[NSMutableArray alloc] init];
	NSMutableArray *graphItemsHourly = [[NSMutableArray alloc] init];
	NSString *basicPred = [ProjectFunctions getBasicPredicateString:year type:@"All"];
	for(NSString *itemName in items) {
		NSString *predString = [NSString stringWithFormat:@"%@ AND %@ = %%@", basicPred, field];
		NSPredicate *predicate = nil;
		if(year==0 || [@"year" isEqualToString:field]) {
			NSString *predString = [NSString stringWithFormat:@"%@ = %%@", field];
			basicPred = [ProjectFunctions getBasicPredicateString:itemName.intValue type:@"All"];
			predString = [NSString stringWithFormat:@"%@ AND %@ = %%@", basicPred, field];
			predicate = [NSPredicate predicateWithFormat:predString, itemName];

		} else
			predicate = [NSPredicate predicateWithFormat:predString, itemName];
		
		NSArray *games = [CoreDataLib selectRowsFromEntity:@"GAME" predicate:predicate sortColumn:nil mOC:context ascendingFlg:NO];
		double totalProfit=0;
		double totalminutes=0;
		for(NSManagedObject *game in games) {
			totalProfit += [[game valueForKey:@"winnings"] doubleValue];
			totalminutes += [[game valueForKey:@"minutes"] intValue];
		}
		int hours = totalminutes/60;
		int hourlyRate = 0;
		if(hours>0)
			hourlyRate = totalProfit/hours;
		[graphItemsProfit addObject:[GraphObject graphObjectWithName:itemName amount:totalProfit rowId:1 reverseColorFlg:NO currentMonthFlg:(year==[itemName intValue])]];
		[graphItemsHourly addObject:[GraphObject graphObjectWithName:itemName amount:hourlyRate rowId:1 reverseColorFlg:NO currentMonthFlg:(year==[itemName intValue])]];
	}
	graph1.image = [GrabphLib graphBarsWithItems:graphItemsProfit];
	graph2.image = [GrabphLib graphBarsWithItems:graphItemsHourly];
}

-(void)drawAllCharts {
	NSManagedObjectContext *contextLocal = [[NSManagedObjectContext alloc] init];
	[contextLocal setUndoManager:nil];
	
	PokerTrackerAppDelegate *appDelegate = (PokerTrackerAppDelegate *)[[UIApplication sharedApplication] delegate];
	[contextLocal setPersistentStoreCoordinator:appDelegate.persistentStoreCoordinator];
	
	[self graphYearData:contextLocal year:self.yearChangeView.statYear];
	[self graphMonthData:contextLocal year:self.yearChangeView.statYear];
	NSArray *days = [ProjectFunctions namesOfAllWeekdays];
	[self graphEngineForItems:days field:@"weekday" context:contextLocal year:self.yearChangeView.statYear graph1:self.chart3ImageView graph2:self.chart4ImageView];
	NSArray *dayTimes = [ProjectFunctions namesOfAllDayTimes];
	[self graphEngineForItems:dayTimes field:@"daytime" context:contextLocal year:self.yearChangeView.statYear graph1:self.chart5ImageView graph2:self.chart6ImageView];
	
	activityBGView.alpha=0;
	
	self.lockScreen=NO;
	self.moneySegment.enabled=YES;
	[activityIndicator stopAnimating];
	self.mainTableView.alpha=1;
	[mainTableView reloadData];
	
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 1;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if(!showBreakdownFlg)
		return [ProjectFunctions chartHeightForSize:150];
	
	if(indexPath.section==0)
		return [yearlyProfits count]*18+44;
	if(indexPath.section==1)
		return 18*12+44;
	if(indexPath.section==2)
		return 18*7+44;

	return 18*4+44;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	NSArray *titles = [NSArray arrayWithObjects:
					   [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"year", nil), NSLocalizedString(@"Profit", nil)],
					   [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"month", nil), NSLocalizedString(@"Profit", nil)],
					   [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"day", nil), NSLocalizedString(@"Profit", nil)],
					   [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"daytime", nil), NSLocalizedString(@"Profit", nil)],
					   @"Hourly Breakdown",
					   nil];
	NSArray *titlesHourly = [NSArray arrayWithObjects:
					   [NSString stringWithFormat:@"%@ %@ (hourly)", NSLocalizedString(@"year", nil), NSLocalizedString(@"Profit", nil)],
					   [NSString stringWithFormat:@"%@ %@ (hourly)", NSLocalizedString(@"month", nil), NSLocalizedString(@"Profit", nil)],
					   [NSString stringWithFormat:@"%@ %@ (hourly)", NSLocalizedString(@"day", nil), NSLocalizedString(@"Profit", nil)],
					   [NSString stringWithFormat:@"%@ %@ (hourly)", NSLocalizedString(@"daytime", nil), NSLocalizedString(@"Profit", nil)],
							 @"Hourly Breakdown",
							 nil];
	if(moneySegment.selectedSegmentIndex==0)
		return [ProjectFunctions getViewForHeaderWithText:[titles stringAtIndex:(int)section]];
	else 
		return [ProjectFunctions getViewForHeaderWithText:[titlesHourly stringAtIndex:(int)section]];
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return 22;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	return CGFLOAT_MIN;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *CellIdentifier = [NSString stringWithFormat:@"cellIdentifierSection%dRow%d", (int)indexPath.section, (int)indexPath.row];
	
	if(!showBreakdownFlg) { // graphical charts
		UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];

		if(indexPath.section==0) {
			if(moneySegment.selectedSegmentIndex==0)
				cell.backgroundView = chartYear1ImageView;
			else 
				cell.backgroundView = chartYear2ImageView;
		} 
		if(indexPath.section==1) {
			if(moneySegment.selectedSegmentIndex==0)
				cell.backgroundView = chartMonth1ImageView;
			else 
				cell.backgroundView = chartMonth2ImageView;
		} 
		if(indexPath.section==2){
			if(moneySegment.selectedSegmentIndex==0)
				cell.backgroundView = chart3ImageView;
			else 
				cell.backgroundView = chart4ImageView; 
		}
		if(indexPath.section==3) {
			if(moneySegment.selectedSegmentIndex==0)
				cell.backgroundView = chart5ImageView;
			else 
				cell.backgroundView = chart6ImageView; 
			
		}
			
		cell.backgroundColor = [UIColor clearColor];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		return cell;
	} //------------------------ graphical charts----------------------
	

	// ----------- Text Breakdown---------------------
	NSMutableArray *titles = [[NSMutableArray alloc] init];
	NSMutableArray *values = [[NSMutableArray alloc] init];
	NSMutableArray *colors = [[NSMutableArray alloc] init];
	int totalSuccess=0;
	int totalProfits=0;
	NSString *mainTitle=@"";

	if(indexPath.section==0) {
		if(moneySegment.selectedSegmentIndex==0) {
			mainTitle = @"Net Profits by Year";
			for(NSString *item in yearlyProfits) {
				NSLog(@"item: %@", item);
				NSArray *components = [item componentsSeparatedByString:@"|"];
				[titles addObject:[components objectAtIndex:0]];
				double profits = [[components objectAtIndex:1] doubleValue];
				int games = [[components objectAtIndex:2] intValue];
				NSString *gameTxt = (games==1)?NSLocalizedString(@"Game", nil):NSLocalizedString(@"Games", nil);
				[values addObject:[NSString stringWithFormat:@"%@ (%d %@)", [ProjectFunctions convertIntToMoneyString:profits], games, gameTxt]];
				totalProfits+=profits;
				if(profits>0)
					totalSuccess++;
				[colors addObject:[CoreDataLib getFieldColor:profits]];
			} // <-- for
			[titles addObject:@"Totals:"];
			[values addObject:[NSString stringWithFormat:@"%@", [ProjectFunctions convertIntToMoneyString:totalProfits]]];
			[colors addObject:[CoreDataLib getFieldColor:totalProfits]];
		} else {
			mainTitle = @"Hourly Profits by Year";
			int count=0;
			int hourlyTotal=0;
			for(NSString *item in yearHourlyProfits) {
				NSArray *components = [item componentsSeparatedByString:@"|"];
				[titles addObject:[components objectAtIndex:0]];
				double profits = [[components objectAtIndex:1] doubleValue];
				int games = [[components objectAtIndex:2] intValue];
				NSString *gameTxt = (games==1)?NSLocalizedString(@"Game", nil):NSLocalizedString(@"Games", nil);
				[values addObject:[NSString stringWithFormat:@"%@/hr (%d %@)", [ProjectFunctions convertIntToMoneyString:profits], games, gameTxt]];
				
				hourlyTotal+=profits;
				count++;
				if(profits>0)
					totalSuccess++;
				[colors addObject:[CoreDataLib getFieldColor:profits]];
			} // <-- for
			if(count>0)
				hourlyTotal = hourlyTotal/count;
			[titles addObject:@"Totals:"];
			[values addObject:[NSString stringWithFormat:@"%@/hr", [ProjectFunctions convertIntToMoneyString:hourlyTotal]]];
			[colors addObject:[CoreDataLib getFieldColor:hourlyTotal]];
		} // <-- else
	} // <-- section==0
	
	if(indexPath.section==1) {
		if(moneySegment.selectedSegmentIndex==0) {
			mainTitle = @"Net Profits by Month";
			for(NSString *item in monthlyProfits) {
				NSArray *components = [item componentsSeparatedByString:@"|"];
				[titles addObject:[components objectAtIndex:0]];
				double profits = [[components objectAtIndex:1] doubleValue];
				int games = [[components objectAtIndex:2] intValue];
				NSString *gameTxt = (games==1)?NSLocalizedString(@"Game", nil):NSLocalizedString(@"Games", nil);
				[values addObject:[NSString stringWithFormat:@"%@ (%d %@)", [ProjectFunctions convertIntToMoneyString:profits], games, gameTxt]];
				totalProfits+=profits;
				if(profits>0)
					totalSuccess++;
				[colors addObject:[CoreDataLib getFieldColor:profits]];
			} // <-- for
			[titles addObject:@"Totals:"];
			[values addObject:[NSString stringWithFormat:@"%@", [ProjectFunctions convertIntToMoneyString:totalProfits]]];
			[colors addObject:[CoreDataLib getFieldColor:totalProfits]];
		} else {
			mainTitle = @"Hourly Profits by Month";
			int count=0;
			int hourlyTotal=0;
			for(NSString *item in hourlyProfits) {
				NSArray *components = [item componentsSeparatedByString:@"|"];
				[titles addObject:[components objectAtIndex:0]];
				double profits = [[components objectAtIndex:1] doubleValue];
				int games = [[components objectAtIndex:2] intValue];
				NSString *gameTxt = (games==1)?NSLocalizedString(@"Game", nil):NSLocalizedString(@"Games", nil);
				[values addObject:[NSString stringWithFormat:@"%@/hr (%d %@)", [ProjectFunctions convertIntToMoneyString:profits], games, gameTxt]];
				
				hourlyTotal+=profits;
				count++;
				if(profits>0)
					totalSuccess++;
				[colors addObject:[CoreDataLib getFieldColor:profits]];
			} // <-- for
			if(count>0)
				hourlyTotal = hourlyTotal/count;
			[titles addObject:@"Totals:"];
			[values addObject:[NSString stringWithFormat:@"%@/hr", [ProjectFunctions convertIntToMoneyString:hourlyTotal]]];
			[colors addObject:[CoreDataLib getFieldColor:hourlyTotal]];
		} // <-- else
	} // <-- section==0

	if(indexPath.section==2) {
		if(moneySegment.selectedSegmentIndex==0) {
			mainTitle = @"Net Profits by Day";
			for(NSString *item in dayProfits) {
				NSArray *components = [item componentsSeparatedByString:@"|"];
				[titles addObject:[components objectAtIndex:0]];
				double profits = [[components objectAtIndex:1] doubleValue];
				int games = [[components objectAtIndex:2] intValue];
				NSString *gameTxt = (games==1)?NSLocalizedString(@"Game", nil):NSLocalizedString(@"Games", nil);
				[values addObject:[NSString stringWithFormat:@"%@ (%d %@)", [ProjectFunctions convertIntToMoneyString:profits], games, gameTxt]];
				totalProfits+=profits;
				if(profits>0)
					totalSuccess++;
				[colors addObject:[CoreDataLib getFieldColor:profits]];
			} // <-- for
			[titles addObject:@"Totals:"];
			[values addObject:[NSString stringWithFormat:@"%@", [ProjectFunctions convertIntToMoneyString:totalProfits]]];
			[colors addObject:[CoreDataLib getFieldColor:totalProfits]];
		} else {
			mainTitle = @"Hourly Profits by Day";
			int count=0;
			int hourlyTotal=0;
			for(NSString *item in dayHourly) {
				NSArray *components = [item componentsSeparatedByString:@"|"];
				[titles addObject:[components objectAtIndex:0]];
				double profits = [[components objectAtIndex:1] doubleValue];
				int games = [[components objectAtIndex:2] intValue];
				NSString *gameTxt = (games==1)?NSLocalizedString(@"Game", nil):NSLocalizedString(@"Games", nil);
				[values addObject:[NSString stringWithFormat:@"%@/hr (%d %@)", [ProjectFunctions convertIntToMoneyString:profits], games, gameTxt]];
				
				hourlyTotal+=profits;
				count++;
				if(profits>0)
					totalSuccess++;
				[colors addObject:[CoreDataLib getFieldColor:profits]];
			} // <-- for
			if(count>0)
				hourlyTotal = hourlyTotal/count;
			[titles addObject:@"Totals:"];
			[values addObject:[NSString stringWithFormat:@"%@/hr", [ProjectFunctions convertIntToMoneyString:hourlyTotal]]];
			[colors addObject:[CoreDataLib getFieldColor:hourlyTotal]];
		} // <-- else
	} // <-- section==1

	if(indexPath.section==3) {
		if(moneySegment.selectedSegmentIndex==0) {
			mainTitle = @"Net Profits by Time";
			for(NSString *item in timeProfits) {
				NSArray *components = [item componentsSeparatedByString:@"|"];
				[titles addObject:[components objectAtIndex:0]];
				double profits = [[components objectAtIndex:1] doubleValue];
				int games = [[components objectAtIndex:2] intValue];
				NSString *gameTxt = (games==1)?NSLocalizedString(@"Game", nil):NSLocalizedString(@"Games", nil);
				[values addObject:[NSString stringWithFormat:@"%@ (%d %@)", [ProjectFunctions convertIntToMoneyString:profits], games, gameTxt]];
				totalProfits+=profits;
				if(profits>0)
					totalSuccess++;
				[colors addObject:[CoreDataLib getFieldColor:profits]];
			} // <-- for
			[titles addObject:@"Totals:"];
			[values addObject:[NSString stringWithFormat:@"%@", [ProjectFunctions convertIntToMoneyString:totalProfits]]];
			[colors addObject:[CoreDataLib getFieldColor:totalProfits]];
		} else {
			mainTitle = @"Hourly Profits by Time";
			int count=0;
			int hourlyTotal=0;
			for(NSString *item in timeHourly) {
				NSArray *components = [item componentsSeparatedByString:@"|"];
				[titles addObject:[components objectAtIndex:0]];
				double profits = [[components objectAtIndex:1] doubleValue];
				int games = [[components objectAtIndex:2] intValue];
				NSString *gameTxt = (games==1)?NSLocalizedString(@"Game", nil):NSLocalizedString(@"Games", nil);
				[values addObject:[NSString stringWithFormat:@"%@/hr (%d %@)", [ProjectFunctions convertIntToMoneyString:profits], games, gameTxt]];
				
				hourlyTotal+=profits;
				count++;
				if(profits>0)
					totalSuccess++;
				[colors addObject:[CoreDataLib getFieldColor:profits]];
			} // <-- for
			if(count>0)
				hourlyTotal = hourlyTotal/count;
			[titles addObject:@"Totals:"];
			[values addObject:[NSString stringWithFormat:@"%@/hr", [ProjectFunctions convertIntToMoneyString:hourlyTotal]]];
			[colors addObject:[CoreDataLib getFieldColor:hourlyTotal]];
		} // <-- else
	} // <-- section==2
	
	
	int NumberOfRows=(int)[titles count];
	MultiLineDetailCellWordWrap *cell = [[MultiLineDetailCellWordWrap alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier withRows:NumberOfRows labelProportion:0.35];
	cell.mainTitle = mainTitle;
	
	if([titles count]==[values count] && [titles count]==[colors count]) {
		cell.titleTextArray = titles;
		cell.fieldTextArray = values;
		cell.fieldColorArray = colors;
	}
	
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
	[self computeStatsAfterDelay:0];
}




@end
