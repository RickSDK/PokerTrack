//
//  StatsPage.m
//  PokerTracker
//
//  Created by Rick Medved on 10/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "StatsPage.h"
#import "MultiLineDetailCellWordWrap.h"
#import "CoreDataLib.h"
#import "QuadFieldTableViewCell.h"
#import "SelectionCell.h"
#import "GameDetailsVC.h"
#import "ListPicker.h"
#import "NSDate+ATTDate.h"
#import "UIColor+ATTColor.h"
#import "NSString+ATTString.h"
#import "ProjectFunctions.h"
#import "MainMenuVC.h"
#import "ActionCell.h"
#import "TextEditCell.h"
#import "FilterNameEnterVC.h"
#import "ReportsVC.h"
#import "GameInProgressVC.h"
#import "MonthlyChartsVC.h"
#import "FiltersVC.h"
#import "StatsFunctions.h"
#import "GoalsVC.h"
#import "FilterListVC.h"
#import "AnalysisVC.h"
#import "NSArray+ATTArray.h"
#import "BankrollsVC.h"
#import "PokerTrackerAppDelegate.h"
#import "Last10NewVC.h"
#import "Top5VC.h"

#define kLeftLabelRation	0.4
#define kfilterButton	7
#define kfiltername		8
#define kSaveFilter		8


@implementation StatsPage
@synthesize managedObjectContext, gameType, statsArray, labelValues, rotateLock, filterObj;
@synthesize formDataArray, selectedFieldIndex, mainTableView, hideMainMenuButton, gameSegment, customSegment;
@synthesize dateSessionButton, displayBySession, activityBGView, activityIndicator, chartImageView;
@synthesize displayYear, yearLabel, leftYear, rightYear, viewLocked, profitArray, largeGraph;
@synthesize reportsButton, chartsButton, goalsButton, analysisButton, analysisToolbar, yearToolbar, multiDimenArray, bankRollSegment;
@synthesize bankrollButton, viewUnLoaded, top5Toolbar, last10Button, top5Button;




- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	self.chartImageView2.hidden=(fromInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || fromInterfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

- (void)viewDidLoad {
	
	[self.mainTableView setBackgroundView:nil];
	self.chartImageView2.hidden=YES;
	
	[[[[UIApplication sharedApplication] delegate] window] addSubview:self.chartImageView2];

	
	labelValues = [[NSMutableArray alloc] initWithArray:[NSArray arrayWithObjects:@"Timeframe", @"Game Type", NSLocalizedString(@"Game", nil), NSLocalizedString(@"Limit", nil), @"Stakes", NSLocalizedString(@"Location", nil), @"Bankroll", @"Tournament Type", nil]];
	statsArray = [[NSMutableArray alloc] initWithArray:[NSArray arrayWithObjects:@"winnings", @"risked", @"gameCount", @"streak", @"longestWinStreak", @"longestLoseStreak", @"hours", @"hourlyRate", @"ROI", nil]];
	formDataArray = [[NSMutableArray alloc] initWithArray:[NSArray arrayWithObjects:NSLocalizedString(@"LifeTime", nil), @"All GameTypes", @"All Games", @"All Limits", @"All Stakes", @"All Locations", @"All Bankrolls", @"All Types", nil]];
	profitArray = [[NSMutableArray alloc] init];
	chartImageView = [[UIImageView alloc] init];
	
	multiDimenArray = [[NSMutableArray alloc] init];
	
	
	selectedFieldIndex=0;
	activityBGView.alpha=0;
	
	displayBySession=NO;
	
	self.gameType = @"All";
	largeGraph.alpha=0;
	
	
	UIImageView *bar = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"greenGradWide.png"]];
	[analysisToolbar insertSubview:bar atIndex:0];
	[yearToolbar insertSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"greenGradWide.png"]] atIndex:0];
	[yearToolbar setTintColor:[UIColor colorWithRed:0 green:.5 blue:0 alpha:1]];
	
	
	[self setTitle:NSLocalizedString(@"Stats", nil)];
	[super viewDidLoad];
	
	self.navigationItem.rightBarButtonItem = [ProjectFunctions UIBarButtonItemWithIcon:[NSString fontAwesomeIconStringForEnum:FAFilter] target:self action:@selector(filtersButtonClicked:)];
	
	[ProjectFunctions resetTheYearSegmentBar:mainTableView displayYear:displayYear MoC:managedObjectContext leftButton:leftYear rightButton:rightYear displayYearLabel:yearLabel];
	
	[formDataArray replaceObjectAtIndex:0 withObject:[ProjectFunctions labelForYearValue:displayYear]];
	
	gameSegment.selectedSegmentIndex = [ProjectFunctions selectedSegmentForGameType:self.gameType];
	
//	[ProjectFunctions setFontColorForSegment:gameSegment values:nil];
	
	bankrollButton.alpha=1;
	bankRollSegment.alpha=1;
	int numBanks = [[ProjectFunctions getUserDefaultValue:@"numBanks"] intValue];
	if(numBanks==0) {
		bankrollButton.alpha=0;
		bankRollSegment.alpha=0;
	}
	
	[ProjectFunctions makeGameSegment:self.gameSegment color:[UIColor colorWithRed:0 green:.5 blue:0 alpha:1]];
	[ProjectFunctions makeSegment:self.customSegment color:[UIColor colorWithRed:0 green:.5 blue:0 alpha:1]];
	
	[self setupButtons];
	
}

-(void)setupButtons {
//	self.top5Button.titleLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:18.f];
//	[self.top5Button setTitle:[NSString stringWithFormat:@"%@ Top 5", [NSString fontAwesomeIconStringForEnum:FATrophy]] forState:UIControlStateNormal];
	
//	self.last10Button.titleLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:18.f];
//	[self.last10Button setTitle:[NSString stringWithFormat:@"%@ Last 10", [NSString fontAwesomeIconStringForEnum:FAListOl]] forState:UIControlStateNormal];
	
//	self.chartsButton.titleLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:16.f];
//	[self.chartsButton setTitle:[NSString stringWithFormat:@"%@ %@", [NSString fontAwesomeIconStringForEnum:FABarChartO], NSLocalizedString(@"Charts", nil)] forState:UIControlStateNormal];
	
//	self.reportsButton.titleLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:16.f];
//	[self.reportsButton setTitle:[NSString stringWithFormat:@"%@ %@", [NSString fontAwesomeIconStringForEnum:FAList], NSLocalizedString(@"Reports", nil)] forState:UIControlStateNormal];
	
//	self.goalsButton.titleLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:16.f];
//	[self.goalsButton setTitle:[NSString stringWithFormat:@"%@ %@", [NSString fontAwesomeIconStringForEnum:FAStar], NSLocalizedString(@"Goals", nil)] forState:UIControlStateNormal];

	self.last10Button.titleLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:18.f];
	[self.last10Button setTitle:[NSString stringWithFormat:@"%@ 10", [NSString fontAwesomeIconStringForEnum:FAListOl]] forState:UIControlStateNormal];
	
	self.top5Button.titleLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:18.f];
	[self.top5Button setTitle:[NSString stringWithFormat:@"%@ %@", [NSString fontAwesomeIconStringForEnum:FAThumbsUp], [NSString fontAwesomeIconStringForEnum:FAThumbsDown]] forState:UIControlStateNormal];
	
	self.chartsButton.titleLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:18.f];
	[self.chartsButton setTitle:[NSString fontAwesomeIconStringForEnum:FABarChartO] forState:UIControlStateNormal];
	
	self.reportsButton.titleLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:18.f];
	[self.reportsButton setTitle:[NSString fontAwesomeIconStringForEnum:FAList] forState:UIControlStateNormal];
	
	self.goalsButton.titleLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:18.f];
	[self.goalsButton setTitle:[NSString fontAwesomeIconStringForEnum:FAStar] forState:UIControlStateNormal];

}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if([self respondsToSelector:@selector(edgesForExtendedLayout)])
        [self setEdgesForExtendedLayout:UIRectEdgeBottom];

    [ProjectFunctions setBankSegment:self.bankRollSegment];
    [self computeStats];
    
	[self checkCustomSegment];
}

- (IBAction) analysisPressed: (id) sender
{
	if(rotateLock)
		return;
	AnalysisVC *detailViewController = [[AnalysisVC alloc] initWithNibName:@"AnalysisVC" bundle:nil];
	detailViewController.managedObjectContext = managedObjectContext;
	detailViewController.gameType = self.gameType;
	detailViewController.displayYear = displayYear;
	[self.navigationController pushViewController:detailViewController animated:YES];
}

- (IBAction) reportsPressed: (id) sender
{
	if(rotateLock)
		return;
	ReportsVC *detailViewController = [[ReportsVC alloc] initWithNibName:@"ReportsVC" bundle:nil];
	detailViewController.managedObjectContext = managedObjectContext;
	detailViewController.gameType = self.gameType;
	detailViewController.displayYear = displayYear;
	[self.navigationController pushViewController:detailViewController animated:YES];
}
- (IBAction) chartsPressed: (id) sender
{
	if(rotateLock)
		return;
	MonthlyChartsVC *detailViewController = [[MonthlyChartsVC alloc] initWithNibName:@"MonthlyChartsVC" bundle:nil];
	detailViewController.managedObjectContext = managedObjectContext;
	detailViewController.displayYear = displayYear;
	[self.navigationController pushViewController:detailViewController animated:YES];
}
- (IBAction) goalsPressed: (id) sender
{
	if(rotateLock)
		return;
	GoalsVC *detailViewController = [[GoalsVC alloc] initWithNibName:@"GoalsVC" bundle:nil];
	detailViewController.managedObjectContext = managedObjectContext;
	detailViewController.displayYear = displayYear;
	[self.navigationController pushViewController:detailViewController animated:YES];
}

-(void)checkCustomSegment
{
	for(int i=1; i<=3; i++) {
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"button = %d", i];
		NSArray *filters = [CoreDataLib selectRowsFromEntity:@"FILTER" predicate:predicate sortColumn:@"button" mOC:self.managedObjectContext ascendingFlg:YES];
		if([filters count]>0) {
			NSManagedObject *mo = [filters objectAtIndex:0];
			[customSegment setTitle:[mo valueForKey:@"name"] forSegmentAtIndex:i];
		}
	}
		
}

- (IBAction) top5Pressed: (id) sender {
    Top5VC *detailViewController = [[Top5VC alloc] initWithNibName:@"Top5VC" bundle:nil];
    detailViewController.managedObjectContext = managedObjectContext;
    [self.navigationController pushViewController:detailViewController animated:YES];
}
- (IBAction) last10Pressed: (id) sender {
    Last10NewVC *detailViewController = [[Last10NewVC alloc] initWithNibName:@"Last10NewVC" bundle:nil];
    detailViewController.managedObjectContext = managedObjectContext;
    [self.navigationController pushViewController:detailViewController animated:YES];
}

- (IBAction) yearSegmentPressed: (id) sender {
	if(rotateLock)
		return;

	[self computeStats];
}


-(void)yearChanged:(UIButton *)barButton
{
	if(rotateLock)
		return;
	
    yearLabel.text = barButton.titleLabel.text;
	self.displayYear = [barButton.titleLabel.text intValue];
	[ProjectFunctions resetTheYearSegmentBar:mainTableView displayYear:displayYear MoC:self.managedObjectContext leftButton:leftYear rightButton:rightYear displayYearLabel:yearLabel];

	[formDataArray replaceObjectAtIndex:0 withObject:[ProjectFunctions labelForYearValue:displayYear]];
	if(customSegment.selectedSegmentIndex>0)
		customSegment.selectedSegmentIndex = 0;
	[self computeStats];
}

- (IBAction) yearGoesUp: (id) sender 
{
	if(rotateLock)
		return;
	[self yearChanged:rightYear];
}
- (IBAction) yearGoesDown: (id) sender
{
	if(rotateLock)
		return;
	[self yearChanged:leftYear];
}


- (IBAction) gameSegmentPressed: (id) sender {
	if(rotateLock)
		return;
	self.gameType = [ProjectFunctions labelForGameSegment:(int)gameSegment.selectedSegmentIndex];
	[formDataArray replaceObjectAtIndex:1 withObject:self.gameType];
	[self computeStats];
}



- (IBAction) customSegmentPressed: (id) sender {
	if(rotateLock)
		return;
	if(customSegment.selectedSegmentIndex>0) {
        self.displayYear=0;
		gameSegment.selectedSegmentIndex = 0;
		[formDataArray replaceObjectAtIndex:0 withObject:NSLocalizedString(@"LifeTime", nil)];
		[formDataArray replaceObjectAtIndex:1 withObject:@"All Games Types"];
		NSString *button = [NSString stringWithFormat:@"%d", (int)customSegment.selectedSegmentIndex];
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"button = %@", button];
		NSArray *filters = [CoreDataLib selectRowsFromEntity:@"FILTER" predicate:predicate sortColumn:@"button" mOC:self.managedObjectContext ascendingFlg:YES];
		if([filters count]>0 && [formDataArray count]>7) {
			NSManagedObject *mo = [filters objectAtIndex:0];
			self.filterObj = mo;
			[formDataArray replaceObjectAtIndex:0 withObject:[mo valueForKey:@"timeframe"]];
			[formDataArray replaceObjectAtIndex:1 withObject:[mo valueForKey:@"Type"]];
			[formDataArray replaceObjectAtIndex:2 withObject:[mo valueForKey:@"game"]];
			[formDataArray replaceObjectAtIndex:3 withObject:[mo valueForKey:@"limit"]];
			[formDataArray replaceObjectAtIndex:4 withObject:[mo valueForKey:@"stakes"]];
			[formDataArray replaceObjectAtIndex:5 withObject:[mo valueForKey:@"location"]];
			[formDataArray replaceObjectAtIndex:6 withObject:[mo valueForKey:@"bankroll"]];
			[formDataArray replaceObjectAtIndex:7 withObject:[mo valueForKey:@"tournamentType"]];
			yearLabel.text = [mo valueForKey:@"name"];
 		} else {
			[ProjectFunctions showAlertPopup:@"Notice" message:@"No filter currently saved to that button"];
			customSegment.selectedSegmentIndex=0;
		}
	} else { // no custom button
		[self initializeFormData];
		
		NSString *currentYearStr = [[NSDate date] convertDateToStringWithFormat:@"yyyy"];
		NSLog(@"+++%@", currentYearStr);
		self.displayYear=[currentYearStr intValue];
		[formDataArray replaceObjectAtIndex:0 withObject:currentYearStr];
        if([formDataArray count]>0)
            yearLabel.text = [formDataArray objectAtIndex:0];
	}
	[self computeStats];

}


- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
		toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)
	{
		self.chartImageView2.frame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height);

//		largeGraph.alpha=.5;
//		chartImageView.alpha=.5;
//		self.chartImageView2.alpha=.5;
//		NSLog(@"Here!!");
//		largeGraph.frame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width/2, [[UIScreen mainScreen] bounds].size.height);
		self.rotateLock=YES;
	}
	else
	{
		largeGraph.alpha=0;
		self.rotateLock=NO;
	}
}

-(void)addArrayToList:(NSPredicate *)predicate moc:(NSManagedObjectContext *)moc
{
	int limit=0;
    NSString *stats1 = [CoreDataLib getGameStatWithLimit:moc dataField:@"stats1" predicate:predicate limit:limit];
    if([stats1 length]>0)
        [multiDimenArray addObject:[stats1 componentsSeparatedByString:@"|"]];
}

-(void) computeStats
{
	
    analysisButton.enabled=NO;
    reportsButton.enabled=NO;
    chartsButton.enabled=NO;
    goalsButton.enabled=NO;
    gameSegment.enabled=NO;
    customSegment.enabled=NO;
    
	[activityIndicator startAnimating];
	activityBGView.alpha=1;
    mainTableView.alpha=0;


    if([ProjectFunctions useThreads]) {
        [self performSelectorInBackground:@selector(doTheHardWork) withObject:nil];
    } else {
        // sync implementation
        [self doTheHardWork];
    }

}


-(void)doTheHardWork {
	@autoreleasepool {
	
        NSManagedObjectContext *contextLocal = [[NSManagedObjectContext alloc] init];
        [contextLocal setUndoManager:nil];
        
        PokerTrackerAppDelegate *appDelegate = (PokerTrackerAppDelegate *)[[UIApplication sharedApplication] delegate];
        [contextLocal setPersistentStoreCoordinator:appDelegate.persistentStoreCoordinator];

        
	NSPredicate *predicate = [ProjectFunctions getPredicateForFilter:formDataArray mOC:contextLocal buttonNum:(int)customSegment.selectedSegmentIndex];
	
	[multiDimenArray removeAllObjects];
	[multiDimenArray addObject:[NSArray arrayWithObject:@"1"]];
	[multiDimenArray addObject:[NSArray arrayWithObject:@"2"]];
	[multiDimenArray addObject:[NSArray arrayWithObject:@"3"]];

	NSString *basicPred = [ProjectFunctions getBasicPredicateString:displayYear type:self.gameType];
	NSString *predString = [NSString stringWithFormat:@"%@ AND winnings > 0", basicPred];
	[self addArrayToList:[NSPredicate predicateWithFormat:predString] moc:contextLocal];
	
	NSString *predString2 = [NSString stringWithFormat:@"%@ AND winnings < 0", basicPred];
	[self addArrayToList:[NSPredicate predicateWithFormat:predString2] moc:contextLocal];
	
	[self addArrayToList:predicate moc:contextLocal];

	
    chartImageView.image = [ProjectFunctions plotStatsChart:contextLocal predicate:predicate displayBySession:displayBySession];
		self.chartImageView2.image = chartImageView.image;

        NSString *stats2 = [CoreDataLib getGameStat:contextLocal dataField:@"stats2" predicate:predicate];
        [statsArray removeAllObjects];
        if([stats2 length]>0)
            [statsArray addObjectsFromArray:[stats2 componentsSeparatedByString:@"|"]];
	
	
	[profitArray removeAllObjects];
	NSArray *titleArray = [NSArray arrayWithObjects:@"Quarter 1", @"Quarter 2", @"Quarter 3", @"Quarter 4", @"Totals",nil]; 
	int totalMoney=0;
		int totalGames=0;
		int totalRisked=0;
	NSString *predStr = [ProjectFunctions getBasicPredicateString:displayYear type:self.gameType];
	if(displayYear>1980) {
		NSDate *startDate = [[NSString stringWithFormat:@"01/01/%d", displayYear] convertStringToDateWithFormat:@"MM/dd/yyyy"];
            NSArray *endDates = [NSArray arrayWithObjects:
                                 [[NSString stringWithFormat:@"04/01/%d", displayYear] convertStringToDateWithFormat:@"MM/dd/yyyy"],
                                 [[NSString stringWithFormat:@"07/01/%d", displayYear] convertStringToDateWithFormat:@"MM/dd/yyyy"],
                                 [[NSString stringWithFormat:@"10/01/%d", displayYear] convertStringToDateWithFormat:@"MM/dd/yyyy"],
                                 [[NSString stringWithFormat:@"01/01/%d", displayYear+1] convertStringToDateWithFormat:@"MM/dd/yyyy"],
                                 nil];
		for(int i=0; i<4; i++) {
                NSDate *endDate = [endDates objectAtIndex:i];
			NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"%@ AND startTime >= %%@ AND startTime < %%@", predStr], startDate, endDate];
			int money = [[CoreDataLib getGameStat:contextLocal dataField:@"winnings" predicate:predicate] intValue];
			int games = [[CoreDataLib getGameStat:contextLocal dataField:@"gameCount" predicate:predicate] intValue];
			totalRisked += [[CoreDataLib getGameStat:contextLocal dataField:@"amountRisked" predicate:predicate] intValue];
			
			startDate = endDate;
			totalMoney += money;
			totalGames += games;
			[profitArray addObject:[NSString stringWithFormat:@"%@|%d|%d", [titleArray objectAtIndex:i], money, games]];
		}
	} else {
		NSArray *items = [CoreDataLib selectRowsFromEntity:@"YEAR" predicate:nil sortColumn:@"name" mOC:contextLocal ascendingFlg:YES];
		for(NSManagedObject *mo in items) {
			NSString *year = [mo valueForKey:@"name"];
			NSString *predString = [NSString stringWithFormat:@"%@ AND year = '%@'", predStr, year];
			NSPredicate *predicate = [NSPredicate predicateWithFormat :predString];
			
			int money = [[CoreDataLib getGameStat:contextLocal dataField:@"winnings" predicate:predicate] intValue];
			int games = [[CoreDataLib getGameStat:contextLocal dataField:@"gameCount" predicate:predicate] intValue];
			totalRisked += [[CoreDataLib getGameStat:contextLocal dataField:@"amountRisked" predicate:predicate] intValue];
			totalMoney += money;
			totalGames += games;
			[profitArray addObject:[NSString stringWithFormat:@"%@|%d|%d", year, money, games]];
		}
		
	}
		
		self.playerTypeImageView.image = [ProjectFunctions getPlayerTypeImage:totalRisked winnings:totalMoney];

	[profitArray addObject:[NSString stringWithFormat:@"%@|%d|%d", @"Totals", totalMoney, totalGames]]; // totals

	
		[ProjectFunctions resetTheYearSegmentBar:mainTableView displayYear:displayYear MoC:contextLocal leftButton:leftYear rightButton:rightYear displayYearLabel:yearLabel];
		
		
		[activityIndicator stopAnimating];
		mainTableView.alpha=1;
		activityBGView.alpha=0;
		analysisButton.enabled=YES;
		reportsButton.enabled=YES;
		chartsButton.enabled=YES;
		goalsButton.enabled=YES;
		gameSegment.enabled=YES;
		customSegment.enabled=YES;
		
		[mainTableView reloadData];

	}
}




-(void)initializeFormData
{
	[formDataArray replaceObjectAtIndex:0 withObject:[ProjectFunctions labelForYearValue:displayYear]];
	[formDataArray replaceObjectAtIndex:1 withObject:[ProjectFunctions labelForGameSegment:(int)gameSegment.selectedSegmentIndex]];
	[formDataArray replaceObjectAtIndex:2 withObject:@"All Games"];
	[formDataArray replaceObjectAtIndex:3 withObject:@"All Limits"];
	[formDataArray replaceObjectAtIndex:4 withObject:@"All Stakes"];
	[formDataArray replaceObjectAtIndex:5 withObject:@"All Locations"];
	[formDataArray replaceObjectAtIndex:6 withObject:@"All Bankrolls"];
	[formDataArray replaceObjectAtIndex:7 withObject:@"All Types"];
}

-(void)filtersButtonClicked:(id)sender {
	if(rotateLock)
		return;
	FiltersVC *detailViewController = [[FiltersVC alloc] initWithNibName:@"FiltersVC" bundle:nil];
	detailViewController.managedObjectContext = managedObjectContext;
	detailViewController.gameType = self.gameType;
	detailViewController.displayYear = displayYear;
	[self.navigationController pushViewController:detailViewController animated:YES];
}


- (IBAction) bankrollPressed: (id) sender
{
	BankrollsVC *detailViewController = [[BankrollsVC alloc] initWithNibName:@"BankrollsVC" bundle:nil];
	detailViewController.managedObjectContext = managedObjectContext;
	detailViewController.callBackViewController = self;
	[self.navigationController pushViewController:detailViewController animated:YES];
    
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 6;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return nil;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if(indexPath.section==1) {
		int height = [MultiLineDetailCellWordWrap cellHeightWithNoMainTitleForData:statsArray
																		 tableView:tableView
															  labelWidthProportion:kLeftLabelRation]+20;
		return height;
	} 
	if(indexPath.section==0)
		return [ProjectFunctions chartHeightForSize:170];
	
	if(indexPath.section==2)
		return [MultiLineDetailCellWordWrap cellHeightWithNoMainTitleForData:profitArray
																   tableView:tableView
														labelWidthProportion:kLeftLabelRation]+20;
	
	return 8*18+25;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 1;	
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return CGFLOAT_MIN;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	return CGFLOAT_MIN;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *CellIdentifier = [NSString stringWithFormat:@"cellIdentifierSection%dRow%d", (int)indexPath.section, (int)indexPath.row];
    
	if(indexPath.section==0) {
		return [StatsFunctions mainChartCell:tableView CellIdentifier:CellIdentifier chartImageView:chartImageView];
	}
	if(indexPath.section==1) {
		return [StatsFunctions statsBreakdown:tableView CellIdentifier:CellIdentifier title:[formDataArray objectAtIndex:0] stats:statsArray];
	}
	if(indexPath.section==2) {
		return [StatsFunctions quarterlyStats:tableView CellIdentifier:CellIdentifier title:[ProjectFunctions labelForYearValue:displayYear] statsArray:profitArray];
	}

	int NumberOfRows=8;
	NSString *cellIdentifier = [NSString stringWithFormat:@"cellIdentifierSection%dRow%drows%d", (int)indexPath.section, (int)indexPath.row, NumberOfRows];
	MultiLineDetailCellWordWrap *cell = (MultiLineDetailCellWordWrap *) [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (cell == nil) {
		cell = [[MultiLineDetailCellWordWrap alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier withRows:NumberOfRows labelProportion:0.5];
	}
	NSArray *titles = [NSArray arrayWithObjects:@"1", @"2", @"3", @"Games Won", @"Games Lost", @"All Games", nil];
	NSArray *labels = [NSArray arrayWithObjects:NSLocalizedString(@"Games", nil),
					   [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Average", nil), NSLocalizedString(@"Buyin", nil)],
					   [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Min", nil), NSLocalizedString(@"Profit", nil)],
					   [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Max", nil), NSLocalizedString(@"Profit", nil)],
					   [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Average", nil), NSLocalizedString(@"Profit", nil)],
					   @"Standard Deviation", @"Target Deviation", @"Trend", nil];
	cell.mainTitle = [titles stringAtIndex:(int)indexPath.section];
	
	if([multiDimenArray count]<=indexPath.section)
		return cell;
	
	cell.titleTextArray = labels;
	cell.fieldTextArray = [multiDimenArray objectAtIndex:indexPath.section];
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	
	return cell;

}

-(void) setReturningValue:(NSObject *) value2 {
	NSString *value = [ProjectFunctions getUserDefaultValue:@"returnValue"];
//	if(selectedFieldIndex==kSaveFilter) {
//		[self saveNewFilter:(NSString *)value];
//		return;
//	}
	customSegment.selectedSegmentIndex=0;
	[formDataArray replaceObjectAtIndex:selectedFieldIndex withObject:value];
	if(selectedFieldIndex==0)
		yearLabel.text = (NSString *)value;

	[self computeStats];
}

-(NSArray *)getListOfYears
{
	NSMutableArray *list = [[NSMutableArray alloc] init];
	[list addObject:NSLocalizedString(@"LifeTime", nil)];
	[list addObject:@"*Custom*"];
	[list addObject:@"This Month"];
	[list addObject:@"Last Month"];
	[list addObject:@"Last 7 Days"];
	[list addObject:@"Last 30 Days"];
	[list addObject:@"Last 90 Days"];

	int numYears = [CoreDataLib calculateActiveYearsPlaying:self.managedObjectContext];
	int thisYear = [[[NSDate date] convertDateToStringWithFormat:@"yyyy"] intValue];
	
	for(int i=thisYear-numYears+1; i<=thisYear; i++)
		[list addObject:[NSString stringWithFormat:@"%d", i]];
	
	return list;
}
/*
-(void)saveCustomSearch:(NSString *)type searchNum:(NSString *)searchNum
{
	NSLog(@"saving: %@ %@", type, searchNum);
	if([type isEqualToString:@"Timeframe"]) {
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"type = %@ AND searchNum = 0", type];
		NSArray *items = [CoreDataLib selectRowsFromEntity:@"SEARCH" predicate:predicate sortColumn:nil mOC:managedObjectContext ascendingFlg:YES];
		if([items count]>0) {
			NSManagedObject *mo = [items objectAtIndex:0];
			NSDate *startTime = [mo valueForKey:@"startTime"];
			NSDate *endTime = [mo valueForKey:@"endTime"];
			
			NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"type = %@ AND searchNum = 0", type];
			[CoreDataLib insertOrUpdateManagedObjectForEntity:@"SEARCH" valueList:[NSArray arrayWithObjects:@"Timeframe", @"", [startTime convertDateToStringWithFormat:nil], [endTime convertDateToStringWithFormat:nil], @"", searchNum, nil] mOC:managedObjectContext predicate:predicate2];
		}
	} else {
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"type = %@ AND searchNum = 0", type];
		NSString *checkmarkList = [CoreDataLib getFieldValueForEntityWithPredicate:managedObjectContext entityName:@"SEARCH" field:@"checkmarkList" predicate:predicate indexPathRow:0];
		NSString *searchStr = [CoreDataLib getFieldValueForEntityWithPredicate:managedObjectContext entityName:@"SEARCH" field:@"searchStr" predicate:predicate indexPathRow:0];
		
		NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"type = %@ AND searchNum = 0", type];
		[CoreDataLib insertOrUpdateManagedObjectForEntity:@"SEARCH" valueList:[NSArray arrayWithObjects:type, searchStr, @"", @"", checkmarkList, searchNum, nil] mOC:managedObjectContext predicate:predicate2];
	}
}
 */
/*
-(BOOL)saveNewFilter:(NSString *)valueCombo
{
	NSLog(@"saving! %@", valueCombo);
	NSArray *items = [valueCombo componentsSeparatedByString:@"|"];
	NSString *buttonName = [items objectAtIndex:0];
	int buttonNumber = [[items objectAtIndex:1] intValue]+1;
	
	NSArray *keyList = [ProjectFunctions getColumnListForEntity:@"FILTER" type:@"column"];
	NSArray *typeList = [ProjectFunctions getColumnListForEntity:@"FILTER" type:@"type"];
	NSMutableArray *valueList = [[NSMutableArray alloc] initWithArray:formDataArray];
	
	[valueList addObject:[NSString stringWithFormat:@"%d", buttonNumber]];
	[valueList addObject:buttonName];
	
	NSManagedObject *mo;
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"button = %d", buttonNumber];
	NSArray *filters = [CoreDataLib selectRowsFromEntity:@"FILTER" predicate:predicate sortColumn:@"button" mOC:self.managedObjectContext ascendingFlg:YES];
	if([filters count]>0) {
		NSLog(@"---updating");
		mo = [filters objectAtIndex:0];
	} else {
		NSLog(@"---inserting");
		mo = [NSEntityDescription insertNewObjectForEntityForName:@"FILTER" inManagedObjectContext:self.managedObjectContext];
	}
	[customSegment setTitle:buttonName forSegmentAtIndex:buttonNumber];
	BOOL success = [CoreDataLib updateManagedObject:mo keyList:keyList valueList:valueList typeList:typeList mOC:self.managedObjectContext];
	if(success) {
		customSegment.selectedSegmentIndex = buttonNumber;
		gameSegment.selectedSegmentIndex = 0;
	}
	
	// save custom filters
	int i=0;
	for(NSString *value in formDataArray) {
		NSString *type = [labelValues objectAtIndex:i++];
		if([value isEqualToString:@"*Custom*"])
			[self saveCustomSearch:type searchNum:[NSString stringWithFormat:@"%d", buttonNumber]];
	}
	return success;
}

*/
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	selectedFieldIndex = (int)indexPath.row;
	if(indexPath.section==0) {
		displayBySession = !displayBySession;
		[self computeStats];
	}
}






- (IBAction) bankrollSegmentChanged: (id) sender
{
    [ProjectFunctions bankSegmentChangedTo:(int)self.bankRollSegment.selectedSegmentIndex];
    
    [self computeStats];
}








@end
