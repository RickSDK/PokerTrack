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

#define kLeftLabelRation	0.4

@implementation MonthlyChartsVC
@synthesize managedObjectContext;
@synthesize mainTableView, selectedObjectForEdit, profitButton, hourlyButton;
@synthesize displayYear, yearLabel, leftYear, rightYear;
@synthesize chart1ImageView, chart2ImageView, chart3ImageView, chart4ImageView, chart5ImageView, chart6ImageView, chart7ImageView, chart8ImageView;
@synthesize yearlyProfits, yearHourlyProfits, monthlyProfits, hourlyProfits, showBreakdownFlg;
@synthesize activityBGView, activityIndicator, yearToolbar, moneySegment;
@synthesize dayProfits, dayHourly, timeProfits, timeHourly, lockScreen, viewUnLoaded;
@synthesize bankRollSegment, bankrollButton;

-(void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
    self.viewUnLoaded=YES;
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if([self respondsToSelector:@selector(edgesForExtendedLayout)])
        [self setEdgesForExtendedLayout:UIRectEdgeBottom];

    [ProjectFunctions setBankSegment:self.bankRollSegment];
    self.viewUnLoaded=NO;
	[self computeStats];
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

-(void)yearChanged:(UIButton *)barButton
{
	self.displayYear = [barButton.titleLabel.text intValue];
    yearLabel.text = barButton.titleLabel.text;
	[ProjectFunctions resetTheYearSegmentBar:mainTableView displayYear:displayYear MoC:self.managedObjectContext leftButton:leftYear rightButton:rightYear displayYearLabel:yearLabel];
	
	[self computeStats];
}

- (IBAction) yearGoesUp: (id) sender 
{
	[self yearChanged:rightYear];
}
- (IBAction) yearGoesDown: (id) sender
{
	[self yearChanged:leftYear];
}

- (IBAction) moneySegmentChanged: (id) sender
{
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

-(void)doTheHardWord
{
	@autoreleasepool {
    
        NSManagedObjectContext *contextLocal = [[NSManagedObjectContext alloc] init];
        [contextLocal setUndoManager:nil];
        
        PokerTrackerAppDelegate *appDelegate = (PokerTrackerAppDelegate *)[[UIApplication sharedApplication] delegate];
        [contextLocal setPersistentStoreCoordinator:appDelegate.persistentStoreCoordinator];

	NSString *basicPred2 = [ProjectFunctions getBasicPredicateString:0 type:@"All"];

	[yearlyProfits removeAllObjects];
	[yearHourlyProfits removeAllObjects];

	int endYear = [[[NSDate date] convertDateToStringWithFormat:@"yyyy"] intValue];

        NSArray *years = [CoreDataLib selectRowsFromEntity:@"YEAR" predicate:nil sortColumn:@"name" mOC:contextLocal ascendingFlg:YES];
        NSManagedObject *m2 = [years objectAtIndex:0];
        int startYear = [[m2 valueForKey:@"name"] intValue];

	for(int i=startYear; i<=endYear; i++) {
		NSString *predString = [NSString stringWithFormat:@"%@ AND year = '%d'", basicPred2, i];
		NSPredicate *predicate = [NSPredicate predicateWithFormat:predString];
            NSString *chart1 = [CoreDataLib getGameStat:contextLocal dataField:@"chart1" predicate:predicate];
            NSArray *values = [chart1 componentsSeparatedByString:@"|"];
            int winnings = [[values stringAtIndex:0] intValue];
            int gameCount = [[values stringAtIndex:1] intValue];
            int minutes = [[values stringAtIndex:2] intValue];
            
		int hours = minutes/60;
		int hourlyRate = 0;
		if(hours>0)
			hourlyRate = winnings/hours;
		[yearlyProfits addObject:[NSString stringWithFormat:@"%d|%d|%d", i, winnings, gameCount]];
		[yearHourlyProfits addObject:[NSString stringWithFormat:@"%d|%d|%d", i, hourlyRate, gameCount]];
	}
	
	
	NSString *basicPred = [ProjectFunctions getBasicPredicateString:displayYear type:@"All"];
	[monthlyProfits removeAllObjects];
	[hourlyProfits removeAllObjects];
		NSArray *months = [ProjectFunctions namesOfAllMonths];
	int i=0;
	for(NSString *month in months) {
		NSString *predString = [NSString stringWithFormat:@"%@ AND month = '%@'", basicPred, month];
		NSPredicate *predicate = [NSPredicate predicateWithFormat:predString];
            NSString *chart1 = [CoreDataLib getGameStat:contextLocal dataField:@"chart1" predicate:predicate];
            NSArray *values = [chart1 componentsSeparatedByString:@"|"];
            int winnings = [[values stringAtIndex:0] intValue];
            int gameCount = [[values stringAtIndex:1] intValue];
            int minutes = [[values stringAtIndex:2] intValue];

		int hours = minutes/60;
		int hourlyRate = 0;
		if(hours>0)
			hourlyRate = winnings/hours;
		[monthlyProfits addObject:[NSString stringWithFormat:@"%@|%d|%d", [months objectAtIndex:i], winnings, gameCount]];
		[hourlyProfits addObject:[NSString stringWithFormat:@"%@|%d|%d", [months objectAtIndex:i], hourlyRate, gameCount]];
		i++;
	}
	
	[dayProfits removeAllObjects];
	[dayHourly removeAllObjects];
	NSArray *days = [ProjectFunctions namesOfAllWeekdays];
	i=0;
	for(NSString *month in days) {
		NSString *predString = [NSString stringWithFormat:@"%@ AND weekday = '%@'", basicPred, month];
		NSPredicate *predicate = [NSPredicate predicateWithFormat:predString];
            NSString *chart1 = [CoreDataLib getGameStat:contextLocal dataField:@"chart1" predicate:predicate];
            NSArray *values = [chart1 componentsSeparatedByString:@"|"];
            int winnings = [[values stringAtIndex:0] intValue];
            int gameCount = [[values stringAtIndex:1] intValue];
            int minutes = [[values stringAtIndex:2] intValue];

		int hours = minutes/60;
		int hourlyRate = 0;
		if(hours>0)
			hourlyRate = winnings/hours;
		[dayProfits addObject:[NSString stringWithFormat:@"%@|%d|%d", [days objectAtIndex:i], winnings, gameCount]];
		[dayHourly addObject:[NSString stringWithFormat:@"%@|%d|%d", [days objectAtIndex:i], hourlyRate, gameCount]];
		i++;
	}
	
	[timeProfits removeAllObjects];
	[timeHourly removeAllObjects];
	NSArray *daytimes = [ProjectFunctions namesOfAllDayTimes];
	i=0;
	for(NSString *month in daytimes) {
		NSString *predString = [NSString stringWithFormat:@"%@ AND daytime = '%@'", basicPred, month];
		NSPredicate *predicate = [NSPredicate predicateWithFormat:predString];
            NSString *chart1 = [CoreDataLib getGameStat:contextLocal dataField:@"chart1" predicate:predicate];
            NSArray *values = [chart1 componentsSeparatedByString:@"|"];
            int winnings = [[values stringAtIndex:0] intValue];
            int gameCount = [[values stringAtIndex:1] intValue];
            int minutes = [[values stringAtIndex:2] intValue];

		int hours = minutes/60;
		int hourlyRate = 0;
		if(hours>0)
			hourlyRate = winnings/hours;
		[timeProfits addObject:[NSString stringWithFormat:@"%@|%d|%d", [daytimes objectAtIndex:i], winnings, gameCount]];
		[timeHourly addObject:[NSString stringWithFormat:@"%@|%d|%d", [daytimes objectAtIndex:i], hourlyRate, gameCount]];
		i++;
	}

            if(viewUnLoaded)
                return;

		self.chart3ImageView.image = [ProjectFunctions graphDaysChart:contextLocal yearStr:yearLabel.text chartNum:1 goalFlg:NO];
		self.chart5ImageView.image = [ProjectFunctions graphDaytimeChart:contextLocal yearStr:yearLabel.text chartNum:1 goalFlg:NO];
		
 	self.chart2ImageView.image = [ProjectFunctions graphGoalsChart:contextLocal yearStr:yearLabel.text chartNum:2 goalFlg:NO];
 	self.chart4ImageView.image = [ProjectFunctions graphDaysChart:contextLocal yearStr:yearLabel.text chartNum:2 goalFlg:NO];
 	self.chart6ImageView.image = [ProjectFunctions graphDaytimeChart:contextLocal yearStr:yearLabel.text chartNum:2 goalFlg:NO];
 	self.chart8ImageView.image = [ProjectFunctions graphYearlyChart:contextLocal yearStr:yearLabel.text chartNum:2 goalFlg:NO];
		
		self.lockScreen=NO;
		self.bankRollSegment.enabled=YES;
		self.moneySegment.enabled=YES;
		[ProjectFunctions resetTheYearSegmentBar:mainTableView displayYear:displayYear MoC:contextLocal leftButton:leftYear rightButton:rightYear displayYearLabel:yearLabel];
		
		[activityIndicator stopAnimating];
		
		[self performSelectorOnMainThread:@selector(updateDisplay) withObject:nil waitUntilDone:NO];

	}
}

-(void)drawFirstCharts
{
    @autoreleasepool {
    
        [NSThread sleepForTimeInterval:0.1];
        
        NSManagedObjectContext *contextLocal = [[NSManagedObjectContext alloc] init];
        [contextLocal setUndoManager:nil];
        
        PokerTrackerAppDelegate *appDelegate = (PokerTrackerAppDelegate *)[[UIApplication sharedApplication] delegate];
        [contextLocal setPersistentStoreCoordinator:appDelegate.persistentStoreCoordinator];
        
            self.chart7ImageView.image = [ProjectFunctions graphYearlyChart:contextLocal yearStr:yearLabel.text chartNum:1 goalFlg:NO];
            self.chart1ImageView.image = [ProjectFunctions graphGoalsChart:contextLocal yearStr:yearLabel.text chartNum:1 goalFlg:NO];
            activityBGView.alpha=0;
        

 
        mainTableView.alpha=1;
        [mainTableView reloadData];
        
	[self performSelectorInBackground:@selector(doTheHardWord) withObject:nil];


	}

}

-(void)updateDisplay
{
    mainTableView.alpha=1;
    [mainTableView reloadData];
}

- (void)computeStats
{
    NSLog(@"computeStats");
    
    self.bankRollSegment.enabled=NO;
    self.moneySegment.enabled=NO;
    self.leftYear.enabled=NO;
    self.rightYear.enabled=NO;
	[activityIndicator startAnimating];
	activityBGView.alpha=1;
    self.lockScreen=YES;
	[self performSelectorInBackground:@selector(drawFirstCharts) withObject:nil];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	[self setTitle:@"Charts"];
	
	self.showBreakdownFlg=NO;
    
    yearLabel.text = [NSString stringWithFormat:@"%d", displayYear];

    [self.mainTableView setBackgroundView:nil];

	yearlyProfits = [[NSMutableArray alloc] init];
	yearHourlyProfits = [[NSMutableArray alloc] init];
	monthlyProfits = [[NSMutableArray alloc] init];
	hourlyProfits = [[NSMutableArray alloc] init];
	dayProfits = [[NSMutableArray alloc] init];
	dayHourly = [[NSMutableArray alloc] init];
	timeProfits = [[NSMutableArray alloc] init];
	timeHourly = [[NSMutableArray alloc] init];

	chart1ImageView = [[UIImageView alloc] init];
	chart2ImageView = [[UIImageView alloc] init];
	chart3ImageView = [[UIImageView alloc] init];
	chart4ImageView = [[UIImageView alloc] init];
	chart5ImageView = [[UIImageView alloc] init];
	chart6ImageView = [[UIImageView alloc] init];
	chart7ImageView = [[UIImageView alloc] init];
	chart8ImageView = [[UIImageView alloc] init];
	self.selectedObjectForEdit=0;
	
	
	self.navigationItem.rightBarButtonItem = [ProjectFunctions navigationButtonWithTitle:NSLocalizedString(@"Main Menu", nil) selector:@selector(mainMenuButtonClicked:) target:self];
	
	[yearToolbar insertSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"greenGradWide.png"]] atIndex:0];
	[yearToolbar setTintColor:[UIColor colorWithRed:0 green:.5 blue:0 alpha:1]];

	self.displayYear = [[[NSDate date] convertDateToStringWithFormat:@"yyyy"] intValue];

//	[ProjectFunctions addColorToButton:self.leftYear color:[UIColor colorWithRed:1 green:.8 blue:0 alpha:1]];
//	[ProjectFunctions addColorToButton:self.rightYear color:[UIColor colorWithRed:1 green:.8 blue:0 alpha:1]];

	[ProjectFunctions resetTheYearSegmentBar:mainTableView displayYear:displayYear MoC:managedObjectContext leftButton:leftYear rightButton:rightYear displayYearLabel:yearLabel];
	
	[profitButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	[profitButton setBackgroundImage:[UIImage imageNamed:@"yellowButton.png"] forState:UIControlStateNormal];
	
	[hourlyButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	[hourlyButton setBackgroundImage:[UIImage imageNamed:@"yellowButton.png"] forState:UIControlStateNormal];
	
    int numBanks = [[ProjectFunctions getUserDefaultValue:@"numBanks"] intValue];
    
    self.bankrollButton.alpha=1;
    self.bankRollSegment.alpha=1;
    
    if(numBanks==0) {
        self.bankrollButton.alpha=0;
        self.bankRollSegment.alpha=0;
    }
	
	[ProjectFunctions makeSegment:self.moneySegment color:[UIColor colorWithRed:0 green:.5 blue:0 alpha:1]];

	
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
	NSArray *titles = [NSArray arrayWithObjects:@"Profits by Year", @"Profits by Month", @"Profits by Day", @"Profits by Time of Day", @"Hourly Breakdown", nil];
	NSArray *titlesHourly = [NSArray arrayWithObjects:@"Hourly Profits by Year", @"Hourly Profits by Month", @"Hourly Profits by Day", @"Hourly Profits by Time of Day", @"Hourly Breakdown", nil];
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
				cell.backgroundView = chart7ImageView;
			else 
				cell.backgroundView = chart8ImageView; 
		} 
		if(indexPath.section==1) {
			if(moneySegment.selectedSegmentIndex==0)
				cell.backgroundView = chart1ImageView;
			else 
				cell.backgroundView = chart2ImageView; 
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
				NSArray *components = [item componentsSeparatedByString:@"|"];
				[titles addObject:[components objectAtIndex:0]];
				int profits = [[components objectAtIndex:1] intValue];
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
				int profits = [[components objectAtIndex:1] intValue];
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
				int profits = [[components objectAtIndex:1] intValue];
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
				int profits = [[components objectAtIndex:1] intValue];
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
				int profits = [[components objectAtIndex:1] intValue];
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
				int profits = [[components objectAtIndex:1] intValue];
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
				int profits = [[components objectAtIndex:1] intValue];
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
				int profits = [[components objectAtIndex:1] intValue];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(lockScreen)
        return;
    
	self.showBreakdownFlg = !showBreakdownFlg;
	[mainTableView reloadData];
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
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
