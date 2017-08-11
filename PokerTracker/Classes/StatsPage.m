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
#import "ProjectFunctions.h"
#import "ReportsVC.h"
#import "MonthlyChartsVC.h"
#import "FiltersVC.h"
#import "StatsFunctions.h"
#import "GoalsVC.h"
#import "AnalysisVC.h"
#import "BankrollsVC.h"
#import "PokerTrackerAppDelegate.h"
#import "GameStatObj.h"
#import "FilterObj.h"
#import "PieChartVC.h"

@implementation StatsPage
@synthesize managedObjectContext, gameType, statsArray, labelValues, rotateLock, filterObj;
@synthesize formDataArray, selectedFieldIndex, mainTableView, hideMainMenuButton, gameSegment, customSegment;
@synthesize dateSessionButton, displayBySession, activityBGView, activityIndicator, chartImageView;
@synthesize viewLocked, profitArray, largeGraph;
@synthesize reportsButton, chartsButton, goalsButton, analysisButton, analysisToolbar, multiDimenArray, bankRollSegment;
@synthesize bankrollButton, viewUnLoaded, top5Toolbar;

- (void)viewDidLoad {
	[super viewDidLoad];
	[self setTitle:NSLocalizedString(@"Stats", nil)];
	[self changeNavToIncludeType:11];
	
	[self.mainTableView setBackgroundView:nil];
	self.chartImageView2.hidden=YES;
	
	[[[[UIApplication sharedApplication] delegate] window] addSubview:self.chartImageView2];

	formDataArray = [[NSMutableArray alloc] initWithArray:[NSArray arrayWithObjects:
														   NSLocalizedString(@"LifeTime", nil),
														   NSLocalizedString(@"All", nil), //@"All GameTypes",
														   NSLocalizedString(@"All", nil), // games
														   NSLocalizedString(@"All", nil), //@"All Limits",
														   NSLocalizedString(@"All", nil), //@"All Stakes",
														   NSLocalizedString(@"All", nil), //@"All Locations",
														   NSLocalizedString(@"All", nil), //@"All Bankrolls",
														   NSLocalizedString(@"All", nil), //@"All Types",
														   nil]];
	
	self.gameStatsSection = [MultiCellObj initWithTitle:NSLocalizedString(@"Game Stats", nil) altTitle:@"alt" labelPercent:.5];
	self.quarterStatsSection = [MultiCellObj initWithTitle:[NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Quarter", nil), NSLocalizedString(@"Stats", nil)] altTitle:@"alt" labelPercent:.5];
	self.gamesWonSection = [MultiCellObj initWithTitle:NSLocalizedString(@"Games Won", nil) altTitle:@"alt" labelPercent:.5];
	self.gamesLostSection = [MultiCellObj initWithTitle:NSLocalizedString(@"Games Lost", nil) altTitle:@"alt" labelPercent:.5];
	
	self.multiDimenArray = [[NSMutableArray alloc] init];
	[self.multiDimenArray addObject:self.gameStatsSection];
	[self.multiDimenArray addObject:self.quarterStatsSection];
	[self.multiDimenArray addObject:self.gamesWonSection];
	[self.multiDimenArray addObject:self.gamesLostSection];

	profitArray = [[NSMutableArray alloc] init];
	chartImageView = [[UIImageView alloc] init];
	
	selectedFieldIndex=0;
	displayBySession=NO;
	self.gameType = NSLocalizedString(@"All", nil);
	largeGraph.alpha=0;
	
	UIImageView *bar = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"greenGradWide.png"]];
	[analysisToolbar insertSubview:bar atIndex:0];
	
	self.navigationItem.rightBarButtonItem = [ProjectFunctions UIBarButtonItemWithIcon:[NSString fontAwesomeIconStringForEnum:FAFilter] target:self action:@selector(filtersButtonClicked:)];

	[formDataArray replaceObjectAtIndex:0 withObject:[ProjectFunctions labelForYearValue:self.yearChangeView.statYear]];
	
	[gameSegment turnIntoGameSegment];
	bankrollButton.alpha=1;
	bankRollSegment.alpha=1;
	int numBanks = [[ProjectFunctions getUserDefaultValue:@"numBanks"] intValue];
	if(numBanks==0) {
		bankrollButton.alpha=0;
		bankRollSegment.alpha=0;
	}
	
	[self.gameSegment turnIntoGameSegment];
	
	[self setupButtons];
	[self computeStats];
}

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	[ProjectFunctions setBankSegment:self.bankRollSegment];
	[self.customSegment turnIntoFilterSegment:self.managedObjectContext];
}

-(void)backButtonClicked {
	[self.navigationController popViewControllerAnimated:YES];
}

-(void)setupButtons {
	[ProjectFunctions makeFAButton2:self.chartsButton type:16 size:18];
	[ProjectFunctions makeFAButton2:self.reportsButton type:26 size:18];
	[ProjectFunctions makeFAButton2:self.goalsButton type:15 size:18];
	[ProjectFunctions makeFAButton2:self.analysisButton type:35 size:18];
	
	self.chartsLabel.text = [ProjectFunctions localizedTitle:@"Bar Charts"];
	self.reportsLabel.text = NSLocalizedString(@"Reports", nil);
	self.goalsLabel.text = NSLocalizedString(@"Goals", nil);
	self.analysisLabel.text = [ProjectFunctions localizedTitle:@"Pie Charts"];
}

- (IBAction) analysisPressed: (id) sender
{
	if(rotateLock)
		return;
	[self performSelector:@selector(gotoPieCharts) withObject:nil afterDelay:.1];
}
-(void)gotoPieCharts {
	PieChartVC *detailViewController = [[PieChartVC alloc] initWithNibName:@"PieChartVC" bundle:nil];
	detailViewController.managedObjectContext = managedObjectContext;
	[self.navigationController pushViewController:detailViewController animated:YES];
}

- (IBAction) reportsPressed: (id) sender
{
	if(rotateLock)
		return;
	[self performSelector:@selector(gotoReports) withObject:nil afterDelay:.1];
}
-(void)gotoReports {
	ReportsVC *detailViewController = [[ReportsVC alloc] initWithNibName:@"ReportsVC" bundle:nil];
	detailViewController.managedObjectContext = managedObjectContext;
	[self.navigationController pushViewController:detailViewController animated:YES];
}
- (IBAction) chartsPressed: (id) sender
{
	if(rotateLock)
		return;
	[self performSelector:@selector(gotoCharts) withObject:nil afterDelay:.1];
}
-(void)gotoCharts {
	MonthlyChartsVC *detailViewController = [[MonthlyChartsVC alloc] initWithNibName:@"MonthlyChartsVC" bundle:nil];
	detailViewController.managedObjectContext = managedObjectContext;
	[self.navigationController pushViewController:detailViewController animated:YES];
}
- (IBAction) goalsPressed: (id) sender
{
	if(rotateLock)
		return;
	[self performSelector:@selector(gotoGoals) withObject:nil afterDelay:.1];
}
-(void)gotoGoals {
	GoalsVC *detailViewController = [[GoalsVC alloc] initWithNibName:@"GoalsVC" bundle:nil];
	detailViewController.managedObjectContext = managedObjectContext;
	[self.navigationController pushViewController:detailViewController animated:YES];
}

-(void)checkCustomSegment
{
	for(int i=1; i<=3; i++) {
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"button = %d", i];
		NSArray *filters = [CoreDataLib selectRowsFromEntity:@"FILTER" predicate:predicate sortColumn:@"button" mOC:self.managedObjectContext ascendingFlg:YES];
		if([filters count]>0) {
			NSManagedObject *mo = [filters objectAtIndex:0];
			FilterObj *obj = [FilterObj objectFromMO:mo];
			[customSegment setTitle:obj.shortName forSegmentAtIndex:i];
		} else
			[customSegment setTitle:@"Extra" forSegmentAtIndex:i];
	}
}

- (IBAction) yearSegmentPressed: (id) sender {
	if(rotateLock)
		return;

	[self computeStats];
}

- (IBAction) gameSegmentPressed: (id) sender {
	if(rotateLock)
		return;
	self.gameType = [ProjectFunctions labelForGameSegment:(int)gameSegment.selectedSegmentIndex];
	[formDataArray replaceObjectAtIndex:1 withObject:self.gameType];
	[self.gameSegment gameSegmentChanged];
	[self computeStats];
}

- (IBAction) customSegmentPressed: (id) sender {
	if(rotateLock)
		return;
	[self.customSegment changeSegment];
	if(customSegment.selectedSegmentIndex>0) {
		gameSegment.selectedSegmentIndex = 0;
		[formDataArray replaceObjectAtIndex:0 withObject:NSLocalizedString(@"LifeTime", nil)];
		[formDataArray replaceObjectAtIndex:1 withObject:NSLocalizedString(@"All", nil)];
		NSString *button = [NSString stringWithFormat:@"%d", (int)customSegment.selectedSegmentIndex];
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"button = %@", button];
		NSArray *filters = [CoreDataLib selectRowsFromEntity:@"FILTER" predicate:predicate sortColumn:@"button" mOC:self.managedObjectContext ascendingFlg:YES];
		if([filters count]>0 && [formDataArray count]>7) {
			NSManagedObject *mo = [filters objectAtIndex:0];
			self.filterObj = mo;
			[formDataArray replaceObjectAtIndex:0 withObject:[ProjectFunctions scrubFilterValue:[mo valueForKey:@"timeframe"]]];
			[formDataArray replaceObjectAtIndex:1 withObject:[ProjectFunctions scrubFilterValue:[mo valueForKey:@"Type"]]];
			[formDataArray replaceObjectAtIndex:2 withObject:[ProjectFunctions scrubFilterValue:[mo valueForKey:@"game"]]];
			[formDataArray replaceObjectAtIndex:3 withObject:[ProjectFunctions scrubFilterValue:[mo valueForKey:@"limit"]]];
			[formDataArray replaceObjectAtIndex:4 withObject:[ProjectFunctions scrubFilterValue:[mo valueForKey:@"stakes"]]];
			[formDataArray replaceObjectAtIndex:5 withObject:[ProjectFunctions scrubFilterValue:[mo valueForKey:@"location"]]];
			[formDataArray replaceObjectAtIndex:6 withObject:[ProjectFunctions scrubFilterValue:[mo valueForKey:@"bankroll"]]];
			[formDataArray replaceObjectAtIndex:7 withObject:[ProjectFunctions scrubFilterValue:[mo valueForKey:@"tournamentType"]]];
			FilterObj *obj = [FilterObj objectFromMO:mo];
			self.yearChangeView.yearLabel.text = obj.name;
			NSLog(@"+++formDataArray: %@", formDataArray);
 		} else {
			[ProjectFunctions showAlertPopup:@"Notice" message:@"No filter currently saved to that button"];
			self.customSegment.selectedSegmentIndex=0;
			return;
		}
	} else { // no custom button
		[self initializeFormData];
		NSString *currentYearStr = [NSString stringWithFormat:@"%d", [ProjectFunctions getNowYear]];
		[formDataArray replaceObjectAtIndex:0 withObject:currentYearStr];
		self.yearChangeView.statYear=[currentYearStr intValue];
		self.yearChangeView.yearLabel.text =currentYearStr;
	}
	[self computeStats];
}

- (void)viewWillTransitionToSize:(CGSize)size
	   withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
	[super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
	if(size.width>size.height) {
		self.chartImageView2.frame = CGRectMake(0, 0, size.width, size.height+64);
		self.rotateLock=YES;
		self.chartImageView2.image = chartImageView.image;
		self.chartImageView2.hidden=NO;
	} else {
		self.chartImageView2.hidden=YES;
		self.rotateLock=NO;
	}
}

-(void)yearChanged {
	self.customSegment.selectedSegmentIndex=0;
	[formDataArray replaceObjectAtIndex:0 withObject:[ProjectFunctions labelForYearValue:self.yearChangeView.statYear]];
	[self computeStats];
}

-(void) computeStats
{
	self.mainTableView.alpha=.5;
	[activityIndicator startAnimating];
	[self performSelectorInBackground:@selector(doTheHardWork) withObject:nil];
}

-(void)addDataToArray:(NSMutableArray *)titles values:(NSMutableArray *)values colors:(NSMutableArray *)colors title:(NSString *)title value:(NSString *)value color:(UIColor *)color {
	if(value) {
		[titles addObject:title];
		[values addObject:value];
		[colors addObject:color];
	}
}

-(UIColor *)colorForValue:(double)value {
	if(value==0)
		return [UIColor blackColor];
	return (value>0)?[UIColor colorWithRed:0 green:.5 blue:0 alpha:1]:[UIColor redColor];
}

-(void)doTheHardWork {
	@autoreleasepool {
	
		NSManagedObjectContext *contextLocal = [[NSManagedObjectContext alloc] init];
		[contextLocal setUndoManager:nil];
		
		PokerTrackerAppDelegate *appDelegate = (PokerTrackerAppDelegate *)[[UIApplication sharedApplication] delegate];
		[contextLocal setPersistentStoreCoordinator:appDelegate.persistentStoreCoordinator];
		
		NSPredicate *predicate = [ProjectFunctions getPredicateForFilter:formDataArray mOC:contextLocal buttonNum:(int)customSegment.selectedSegmentIndex];
		
		NSArray *games = [CoreDataLib selectRowsFromEntity:@"GAME" predicate:predicate sortColumn:@"startTime" mOC:contextLocal ascendingFlg:YES];
		GameStatObj *gameStatObj = [GameStatObj gameStatObjDetailedForGames:games];
		
		[self.gameStatsSection removeAllObjects];
		[self.quarterStatsSection removeAllObjects];
		[self.gamesWonSection removeAllObjects];
		[self.gamesLostSection removeAllObjects];
		
		self.gameStatsSection.altTitle = self.yearChangeView.yearLabel.text;
		self.quarterStatsSection.altTitle = self.yearChangeView.yearLabel.text;
		self.gamesWonSection.altTitle = self.yearChangeView.yearLabel.text;
		self.gamesLostSection.altTitle = self.yearChangeView.yearLabel.text;
		
		[self.gameStatsSection addBlackLineWithTitle:@"Games" value:gameStatObj.shortName];
		[self.gameStatsSection addBlackLineWithTitle:@"Risked" value:gameStatObj.riskedString];
		[self.gameStatsSection addMoneyLineWithTitle:@"Profit" amount:gameStatObj.profit];
		[self.gameStatsSection addBlackLineWithTitle:@"Hours" value:gameStatObj.hours];
		[self.gameStatsSection addColoredLineWithTitle:@"Hourly" value:gameStatObj.hourly amount:gameStatObj.profit];
		[self.gameStatsSection addColoredLineWithTitle:@"ROI" value:gameStatObj.roiLong amount:gameStatObj.profit];
		[self.gameStatsSection addBlackLineWithTitle:@"Streak" value:gameStatObj.streak];
		[self.gameStatsSection addBlackLineWithTitle:@"WinStreak" value:gameStatObj.winStreak];
		[self.gameStatsSection addBlackLineWithTitle:@"LoseStreak" value:gameStatObj.loseStreak];
		[self.gameStatsSection addColoredLineWithTitle:@"Highest Profit Point" value:gameStatObj.profitHigh amount:1];
		[self.gameStatsSection addColoredLineWithTitle:@"Lowest Profit Point" value:gameStatObj.profitLow amount:-1];
		
		[self.gameStatsSection addColoredLineWithTitle:@"Best day of Week" value:gameStatObj.bestWeekday amount:gameStatObj.bestDayAmount];
		[self.gameStatsSection addColoredLineWithTitle:@"Worst day of Week" value:gameStatObj.worstWeekday amount:gameStatObj.worstDayAmount];
		[self.gameStatsSection addColoredLineWithTitle:@"Best Time of day" value:gameStatObj.bestDaytime amount:gameStatObj.bestTimeAmount];
		[self.gameStatsSection addColoredLineWithTitle:@"Worst Time of day" value:gameStatObj.worstDaytime amount:gameStatObj.worstTimeAmount];
		
		if(gameStatObj.hudGames>0) {
			[self.gameStatsSection addLineWithTitle:@"Hud Games" value:gameStatObj.hudGamesStr color:[UIColor colorWithRed:0 green:0 blue:.5 alpha:1]];
			[self.gameStatsSection addLineWithTitle:@"VPIP / PFR (AF)" value:gameStatObj.hudVpvp_Pfr color:[UIColor colorWithRed:0 green:0 blue:.5 alpha:1]];
			[self.gameStatsSection addLineWithTitle:@"Hud Play Style" value:gameStatObj.hudPlayerType color:[UIColor colorWithRed:0 green:0 blue:.5 alpha:1]];
			[self.gameStatsSection addLineWithTitle:@"Hud Detailed Style" value:gameStatObj.hudPlayerTypeLong color:[UIColor colorWithRed:0 green:0 blue:.5 alpha:1]];
			[self.gameStatsSection addLineWithTitle:@"Hud Skill Level" value:gameStatObj.hudSkillLevel color:[UIColor colorWithRed:0 green:0 blue:.5 alpha:1]];
		}
		
		if(gameStatObj.quarter1Profit!=0)
			[self.quarterStatsSection addMoneyLineWithTitle:[NSString stringWithFormat:@"%@ 1", NSLocalizedString(@"Quarter", nil)] amount:gameStatObj.quarter1Profit];
		if(gameStatObj.quarter2Profit!=0)
			[self.quarterStatsSection addMoneyLineWithTitle:[NSString stringWithFormat:@"%@ 2", NSLocalizedString(@"Quarter", nil)] amount:gameStatObj.quarter2Profit];
		if(gameStatObj.quarter3Profit!=0)
			[self.quarterStatsSection addMoneyLineWithTitle:[NSString stringWithFormat:@"%@ 3", NSLocalizedString(@"Quarter", nil)] amount:gameStatObj.quarter3Profit];
		if(gameStatObj.quarter4Profit!=0)
			[self.quarterStatsSection addMoneyLineWithTitle:[NSString stringWithFormat:@"%@ 4", NSLocalizedString(@"Quarter", nil)] amount:gameStatObj.quarter4Profit];
		[self.quarterStatsSection addMoneyLineWithTitle:NSLocalizedString(@"Total", nil) amount:gameStatObj.quarter1Profit+gameStatObj.quarter2Profit+gameStatObj.quarter3Profit+gameStatObj.quarter4Profit];

		
		[self.gamesWonSection addBlackLineWithTitle:@"Games Won" value:gameStatObj.gamesWon];
		[self.gamesWonSection addBlackLineWithTitle:[NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Average", nil), NSLocalizedString(@"Risked", nil)] value:gameStatObj.gamesWonAverageRisked];
		[self.gamesWonSection addBlackLineWithTitle:[NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Average", nil), NSLocalizedString(@"rebuy", nil)] value:gameStatObj.gamesWonAverageRebuy];
		[self.gamesWonSection addColoredLineWithTitle:[NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Average", nil), NSLocalizedString(@"Profit", nil)] value:gameStatObj.gamesWonAverageProfit amount:1];
		[self.gamesWonSection addColoredLineWithTitle:[NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Largest", nil), NSLocalizedString(@"Win", nil)] value:gameStatObj.gamesWonMaxProfit amount:1];
		[self.gamesWonSection addColoredLineWithTitle:[NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Smallest", nil), NSLocalizedString(@"Win", nil)] value:gameStatObj.gamesWonMinProfit amount:1];

		[self.gamesLostSection addBlackLineWithTitle:@"Games Lost" value:gameStatObj.gamesLost];
		[self.gamesLostSection addBlackLineWithTitle:[NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Average", nil), NSLocalizedString(@"Risked", nil)] value:gameStatObj.gamesLostAverageRisked];
		[self.gamesLostSection addBlackLineWithTitle:[NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Average", nil), NSLocalizedString(@"rebuy", nil)] value:gameStatObj.gamesLostAverageRebuy];
		[self.gamesLostSection addColoredLineWithTitle:[NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Average", nil), NSLocalizedString(@"Profit", nil)] value:gameStatObj.gamesLostAverageProfit amount:-1];
		[self.gamesLostSection addColoredLineWithTitle:[NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Smallest", nil), NSLocalizedString(@"Loss", nil)] value:gameStatObj.gamesLostMaxProfit amount:-1];
		[self.gamesLostSection addColoredLineWithTitle:[NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Largest", nil), NSLocalizedString(@"Loss", nil)] value:gameStatObj.gamesLostMinProfit amount:-1];

		chartImageView.image = [ProjectFunctions plotStatsChart:contextLocal predicate:predicate displayBySession:displayBySession];

		[activityIndicator stopAnimating];
		self.mainTableView.alpha=1;
		[mainTableView reloadData];
	}
}

-(void)initializeFormData
{
	[formDataArray replaceObjectAtIndex:0 withObject:[ProjectFunctions labelForYearValue:self.yearChangeView.statYear]];
	[formDataArray replaceObjectAtIndex:1 withObject:[ProjectFunctions labelForGameSegment:(int)gameSegment.selectedSegmentIndex]];
	[formDataArray replaceObjectAtIndex:2 withObject:NSLocalizedString(@"All", nil)]; // games
	[formDataArray replaceObjectAtIndex:3 withObject:NSLocalizedString(@"All", nil)]; //,@"All Limits"
	[formDataArray replaceObjectAtIndex:4 withObject:NSLocalizedString(@"All", nil)]; //@"All Stakes"
	[formDataArray replaceObjectAtIndex:5 withObject:NSLocalizedString(@"All", nil)]; //@"All Locations"
	[formDataArray replaceObjectAtIndex:6 withObject:NSLocalizedString(@"All", nil)]; //@"All Bankrolls"
	[formDataArray replaceObjectAtIndex:7 withObject:NSLocalizedString(@"All", nil)]; //@"All Types"
}

-(void)filtersButtonClicked:(id)sender {
	if(rotateLock)
		return;
	FiltersVC *detailViewController = [[FiltersVC alloc] initWithNibName:@"FiltersVC" bundle:nil];
	detailViewController.managedObjectContext = managedObjectContext;
	detailViewController.gameType = self.gameType;
	detailViewController.displayYear = self.yearChangeView.statYear;
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
    return 5;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if(indexPath.section==0)
		return [ProjectFunctions chartHeightForSize:170];
	
	return [MultiLineDetailCellWordWrap heightForMultiCellObj:[self.multiDimenArray objectAtIndex:indexPath.section-1] tableView:tableView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 1;	
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	return CGFLOAT_MIN;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *CellIdentifier = [NSString stringWithFormat:@"cellIdentifierSection%dRow%d", (int)indexPath.section, (int)indexPath.row];
    
	if(indexPath.section==0) {
		return [StatsFunctions mainChartCell:tableView CellIdentifier:CellIdentifier chartImageView:chartImageView];
	}
	return [MultiLineDetailCellWordWrap multiCellForID:CellIdentifier obj:[self.multiDimenArray objectAtIndex:indexPath.section-1] tableView:tableView];
}

-(void) setReturningValue:(NSObject *) value2 {
	NSString *value = [ProjectFunctions getUserDefaultValue:@"returnValue"];
	customSegment.selectedSegmentIndex=0;
	[formDataArray replaceObjectAtIndex:selectedFieldIndex withObject:value];
	if(selectedFieldIndex==0)
		self.yearChangeView.yearLabel.text = (NSString *)value;

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
	int thisYear = [ProjectFunctions getNowYear];
	
	for(int i=thisYear-numYears+1; i<=thisYear; i++)
		[list addObject:[NSString stringWithFormat:@"%d", i]];
	
	return list;
}

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
// 645 lines
@end
