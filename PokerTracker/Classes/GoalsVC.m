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
@synthesize displayYear, yearLabel, leftYear, rightYear, chart1ImageView, chart2ImageView;
@synthesize monthlyProfits, hourlyProfits, bankrollButton, bankRollSegment;
@synthesize activityBGView, activityIndicator, yearToolbar, coreDataLocked;

-(void)mainMenuButtonClicked:(id)sender {
	[self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
}

- (IBAction) bankrollSegmentChanged: (id) sender
{
    [ProjectFunctions bankSegmentChangedTo:self.bankRollSegment.selectedSegmentIndex];
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


-(void)doTheHardWork
{
	@autoreleasepool {
   
        NSManagedObjectContext *contextLocal = [[NSManagedObjectContext alloc] init];
        [contextLocal setUndoManager:nil];
        
        PokerTrackerAppDelegate *appDelegate = (PokerTrackerAppDelegate *)[[UIApplication sharedApplication] delegate];
        [contextLocal setPersistentStoreCoordinator:appDelegate.persistentStoreCoordinator];
        
	[self.monthlyProfits removeAllObjects];
	[hourlyProfits removeAllObjects];
 	NSString *basicPred = [ProjectFunctions getBasicPredicateString:displayYear type:@"All"];
	NSArray *months = [NSArray arrayWithObjects:@"January", @"February", @"March", @"April", @"May", @"June", @"July", @"August", @"September", @"October", @"November", @"December", nil];
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
		[self.monthlyProfits addObject:[NSString stringWithFormat:@"%d|%d", winnings, gameCount]];
		[self.hourlyProfits addObject:[NSString stringWithFormat:@"%d|%d", hourlyRate, gameCount]];
	}
	int profitGoal = [[ProjectFunctions getUserDefaultValue:@"profitGoal"] intValue];
	int hourlyGoal = [[ProjectFunctions getUserDefaultValue:@"hourlyGoal"] intValue];
	[profitButton setTitle:[NSString stringWithFormat:@"%@", [ProjectFunctions convertIntToMoneyString:profitGoal]] forState:UIControlStateNormal];
	[hourlyButton setTitle:[NSString stringWithFormat:@"%@/hr", [ProjectFunctions convertIntToMoneyString:hourlyGoal]] forState:UIControlStateNormal];

 	self.chart1ImageView.image = [ProjectFunctions graphGoalsChart:contextLocal yearStr:yearLabel.text chartNum:1 goalFlg:YES];
	self.chart2ImageView.image = [ProjectFunctions graphGoalsChart:contextLocal yearStr:yearLabel.text chartNum:2 goalFlg:YES];
	
	activityBGView.alpha=0;
	[activityIndicator stopAnimating];
        self.bankRollSegment.enabled=YES;
        self.bankrollButton.enabled=YES;

	[ProjectFunctions resetTheYearSegmentBar:mainTableView displayYear:displayYear MoC:contextLocal leftButton:leftYear rightButton:rightYear displayYearLabel:yearLabel];
 	[mainTableView reloadData];
 	}
}	

- (void)executeThreadedJob:(SEL)aSelector
{
	[activityIndicator startAnimating];
	activityBGView.alpha=1;
    self.bankRollSegment.enabled=NO;
    self.bankrollButton.enabled=NO;
    self.leftYear.enabled=NO;
    self.rightYear.enabled=NO;
	[self performSelectorInBackground:aSelector withObject:nil];
}

- (void)computeStats
{
	[self executeThreadedJob:@selector(doTheHardWork)];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if([self respondsToSelector:@selector(edgesForExtendedLayout)])
        [self setEdgesForExtendedLayout:UIRectEdgeBottom];

    [ProjectFunctions setBankSegment:self.bankRollSegment];
    [self computeStats];
}



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	[self setTitle:@"Goals"];
    
    yearLabel.text = [NSString stringWithFormat:@"%d", displayYear];

    [mainTableView setBackgroundView:nil];

	self.monthlyProfits = [[NSMutableArray alloc] init];
	self.hourlyProfits = [[NSMutableArray alloc] init];
	chart1ImageView = [[UIImageView alloc] init];
	chart2ImageView = [[UIImageView alloc] init];
	self.selectedObjectForEdit=0;
	
//	[ProjectFunctions addColorToButton:self.leftYear color:[UIColor colorWithRed:1 green:.8 blue:0 alpha:1]];
//	[ProjectFunctions addColorToButton:self.rightYear color:[UIColor colorWithRed:1 green:.8 blue:0 alpha:1]];

	[yearToolbar insertSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"greenGradWide.png"]] atIndex:0];
	[yearToolbar setTintColor:[UIColor colorWithRed:0 green:.5 blue:0 alpha:1]];

	self.navigationItem.rightBarButtonItem = [ProjectFunctions navigationButtonWithTitle:@"Main Menu" selector:@selector(mainMenuButtonClicked:) target:self];
	
	
	self.displayYear = [[[NSDate date] convertDateToStringWithFormat:@"yyyy"] intValue];
	[ProjectFunctions resetTheYearSegmentBar:mainTableView displayYear:displayYear MoC:managedObjectContext leftButton:leftYear rightButton:rightYear displayYearLabel:yearLabel];

    int numBanks = [[ProjectFunctions getUserDefaultValue:@"numBanks"] intValue];
    
    self.bankrollButton.alpha=1;
    self.bankRollSegment.alpha=1;
    
    if(numBanks==0) {
        self.bankrollButton.alpha=0;
        self.bankRollSegment.alpha=0;
    }

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
	NSArray *titles = [NSArray arrayWithObjects:@"Monthly Net Profits", @"Monthly Breakdown", @"Hourly Profits", @"Hourly Breakdown", nil];
	return [ProjectFunctions getViewForHeaderWithText:[titles stringAtIndex:section]];
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return 22;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if(section==0)
		return @"Monthly Net Profits";
	if(section==2)
		return @"Hourly Profits";
	return nil;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *CellIdentifier = [NSString stringWithFormat:@"cellIdentifierSection%dRow%d", indexPath.section, indexPath.row];
	
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
		NSArray *months = [NSArray arrayWithObjects:@"January", @"February", @"March", @"April", @"May", @"June", @"July", @"August", @"September", @"October", @"November", @"December", @"Total", nil];
		int NumberOfRows=[months count];
		MultiLineDetailCellWordWrap *cell = (MultiLineDetailCellWordWrap *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[MultiLineDetailCellWordWrap alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier withRows:NumberOfRows labelProportion:0.35];
		}
		cell.mainTitle = @"Net Profits by Month";
	
		NSMutableArray *values = [[NSMutableArray alloc] init];
		NSMutableArray *colors = [[NSMutableArray alloc] init];
		int totalSuccess=0;
		int goalAmount = [[ProjectFunctions getUserDefaultValue:@"profitGoal"] intValue];
		NSArray *temp = [[NSArray alloc] initWithArray:self.monthlyProfits];
		
		for(NSString *item in temp) {
			NSArray *components = [item componentsSeparatedByString:@"|"];
			int profits = [[components objectAtIndex:0] intValue];
			int games = [[components objectAtIndex:1] intValue];
			NSString *gameTxt = (games==1)?@"Game":@"Games";
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
		NSArray *months = [NSArray arrayWithObjects:@"January", @"February", @"March", @"April", @"May", @"June", @"July", @"August", @"September", @"October", @"November", @"December", @"Total", nil];
		int NumberOfRows=[months count];
		MultiLineDetailCellWordWrap *cell = (MultiLineDetailCellWordWrap *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[MultiLineDetailCellWordWrap alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier withRows:NumberOfRows labelProportion:0.4];
		}
		cell.mainTitle = @"Hourly Rate by Month";
		NSMutableArray *values = [[NSMutableArray alloc] init];
		NSMutableArray *colors = [[NSMutableArray alloc] init];
		int totalSuccess=0;
		int goalAmount = [[ProjectFunctions getUserDefaultValue:@"hourlyGoal"] intValue];
		for(NSString *item in self.hourlyProfits) {
			NSArray *components = [item componentsSeparatedByString:@"|"];
			int profits = [[components objectAtIndex:0] intValue];
			int games = [[components objectAtIndex:1] intValue];
			NSString *gameTxt = (games==1)?@"Game":@"Games";
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
