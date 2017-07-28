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
#import "GameStatObj.h"
#import "FilterObj.h"
#import "PieChartVC.h"

#define kLeftLabelRation	0.5
#define kfilterButton	7
#define kfiltername		8
#define kSaveFilter		8


@implementation StatsPage
@synthesize managedObjectContext, gameType, statsArray, labelValues, rotateLock, filterObj;
@synthesize formDataArray, selectedFieldIndex, mainTableView, hideMainMenuButton, gameSegment, customSegment;
@synthesize dateSessionButton, displayBySession, activityBGView, activityIndicator, chartImageView;
@synthesize viewLocked, profitArray, largeGraph;
@synthesize reportsButton, chartsButton, goalsButton, analysisButton, analysisToolbar, multiDimenArray, bankRollSegment;
@synthesize bankrollButton, viewUnLoaded, top5Toolbar;



/*
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	self.chartImageView2.hidden=(fromInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || fromInterfaceOrientation == UIInterfaceOrientationLandscapeRight);
}
*/
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
	profitArray = [[NSMutableArray alloc] init];
	chartImageView = [[UIImageView alloc] init];
	
	multiDimenArray = [[NSMutableArray alloc] init];
	selectedFieldIndex=0;
	displayBySession=NO;
	self.gameType = NSLocalizedString(@"All", nil);
	largeGraph.alpha=0;
	
	UIImageView *bar = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"greenGradWide.png"]];
	[analysisToolbar insertSubview:bar atIndex:0];
	
	self.navigationItem.rightBarButtonItem = [ProjectFunctions UIBarButtonItemWithIcon:[NSString fontAwesomeIconStringForEnum:FAFilter] target:self action:@selector(filtersButtonClicked:)];

	[formDataArray replaceObjectAtIndex:0 withObject:[ProjectFunctions labelForYearValue:self.yearChangeView.statYear]];
	
	gameSegment.selectedSegmentIndex = [ProjectFunctions selectedSegmentForGameType:self.gameType];
	
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
	[self arrayInit];
	[self computeStats];
	
}

-(void)arrayInit {
	self.titles1 = [[NSMutableArray alloc] init];
	self.values1 = [[NSMutableArray alloc] init];
	self.colors1 = [[NSMutableArray alloc] init];

	self.titles2 = [[NSMutableArray alloc] init];
	self.values2 = [[NSMutableArray alloc] init];
	self.colors2 = [[NSMutableArray alloc] init];

	self.titles3 = [[NSMutableArray alloc] init];
	self.values3 = [[NSMutableArray alloc] init];
	self.colors3 = [[NSMutableArray alloc] init];

	self.titles4 = [[NSMutableArray alloc] init];
	self.values4 = [[NSMutableArray alloc] init];
	self.colors4 = [[NSMutableArray alloc] init];
}

-(void)backButtonClicked {
	[self.navigationController popViewControllerAnimated:YES];
}


-(void)setupButtons {
	[ProjectFunctions makeFAButton:self.chartsButton type:16 size:18];
	[ProjectFunctions makeFAButton:self.reportsButton type:26 size:18];
	[ProjectFunctions makeFAButton:self.goalsButton type:15 size:18];
	[ProjectFunctions makeFAButton:self.analysisButton type:35 size:18];
	
	self.chartsLabel.text = NSLocalizedString(@"Bar Charts", nil);
	self.reportsLabel.text = NSLocalizedString(@"Reports", nil);
	self.goalsLabel.text = NSLocalizedString(@"Goals", nil);
	self.analysisLabel.text = NSLocalizedString(@"Pie Charts", nil);
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [ProjectFunctions setBankSegment:self.bankRollSegment];
	[self.customSegment turnIntoFilterSegment:self.managedObjectContext];
//	[self checkCustomSegment];
//    [self computeStats];
    
}

- (IBAction) analysisPressed: (id) sender
{
	if(rotateLock)
		return;
	PieChartVC *detailViewController = [[PieChartVC alloc] initWithNibName:@"PieChartVC" bundle:nil];
	detailViewController.managedObjectContext = managedObjectContext;
	[self.navigationController pushViewController:detailViewController animated:YES];
}

- (IBAction) reportsPressed: (id) sender
{
	if(rotateLock)
		return;
	ReportsVC *detailViewController = [[ReportsVC alloc] initWithNibName:@"ReportsVC" bundle:nil];
	detailViewController.managedObjectContext = managedObjectContext;
	detailViewController.gameType = self.gameType;
	[self.navigationController pushViewController:detailViewController animated:YES];
}
- (IBAction) chartsPressed: (id) sender
{
	if(rotateLock)
		return;
	MonthlyChartsVC *detailViewController = [[MonthlyChartsVC alloc] initWithNibName:@"MonthlyChartsVC" bundle:nil];
	detailViewController.managedObjectContext = managedObjectContext;
	[self.navigationController pushViewController:detailViewController animated:YES];
}
- (IBAction) goalsPressed: (id) sender
{
	if(rotateLock)
		return;
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
	if(self.gameSegment.selectedSegmentIndex==0) {
		[self setTitle:NSLocalizedString(@"Stats", nil)];
	}
	if(self.gameSegment.selectedSegmentIndex==1) {
		[self setTitle:NSLocalizedString(@"Cash Games", nil)];
	}
	if(self.gameSegment.selectedSegmentIndex==2) {
		[self setTitle:NSLocalizedString(@"Tournaments", nil)];
	}
	self.gameType = [ProjectFunctions labelForGameSegment:(int)gameSegment.selectedSegmentIndex];
	[formDataArray replaceObjectAtIndex:1 withObject:self.gameType];
	[ProjectFunctions changeColorForGameBar:self.gameSegment];
	[self computeStats];
}



- (IBAction) customSegmentPressed: (id) sender {
	if(rotateLock)
		return;
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
			[formDataArray replaceObjectAtIndex:0 withObject:[self scrubFilterValue:[mo valueForKey:@"timeframe"]]];
			[formDataArray replaceObjectAtIndex:1 withObject:[self scrubFilterValue:[mo valueForKey:@"Type"]]];
			[formDataArray replaceObjectAtIndex:2 withObject:[self scrubFilterValue:[mo valueForKey:@"game"]]];
			[formDataArray replaceObjectAtIndex:3 withObject:[self scrubFilterValue:[mo valueForKey:@"limit"]]];
			[formDataArray replaceObjectAtIndex:4 withObject:[self scrubFilterValue:[mo valueForKey:@"stakes"]]];
			[formDataArray replaceObjectAtIndex:5 withObject:[self scrubFilterValue:[mo valueForKey:@"location"]]];
			[formDataArray replaceObjectAtIndex:6 withObject:[self scrubFilterValue:[mo valueForKey:@"bankroll"]]];
			[formDataArray replaceObjectAtIndex:7 withObject:[self scrubFilterValue:[mo valueForKey:@"tournamentType"]]];
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
		NSString *currentYearStr = [[NSDate date] convertDateToStringWithFormat:@"yyyy"];
		[formDataArray replaceObjectAtIndex:0 withObject:currentYearStr];
		self.yearChangeView.statYear=[currentYearStr intValue];
		self.yearChangeView.yearLabel.text =currentYearStr;
	}
	[self computeStats];
}

-(NSString *)scrubFilterValue:(NSString *)value {
	if(value.length>3 && [@"All" isEqualToString:[value substringToIndex:3]])
		return NSLocalizedString(@"All", nil);
	
	return value;
}

- (void)viewWillTransitionToSize:(CGSize)size
	   withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
	[super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
	if(size.width>size.height) {
		self.chartImageView2.frame = CGRectMake(0, 0, size.width, size.height+64);
		self.rotateLock=YES;
		self.chartImageView2.hidden=NO;
	} else {
		self.chartImageView2.hidden=YES;
		self.rotateLock=NO;
	}
}
/*
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
		toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)
	{
		self.chartImageView2.frame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height);
		self.rotateLock=YES;
	}
	else
	{
		largeGraph.alpha=0;
		self.rotateLock=NO;
	}
}
*/
-(void)addArrayToList:(NSPredicate *)predicate moc:(NSManagedObjectContext *)moc
{
	int limit=0;
    NSString *stats1 = [CoreDataLib getGameStatWithLimit:moc dataField:@"stats1" predicate:predicate limit:limit];
    if([stats1 length]>0)
        [multiDimenArray addObject:[stats1 componentsSeparatedByString:@"|"]];
}

-(void)calculateStats {
	self.customSegment.selectedSegmentIndex=0;
	[formDataArray replaceObjectAtIndex:0 withObject:[ProjectFunctions labelForYearValue:self.yearChangeView.statYear]];
	[self computeStats];
}

-(void) computeStats
{
	analysisButton.enabled=NO;
    reportsButton.enabled=NO;
    chartsButton.enabled=NO;
    goalsButton.enabled=NO;
    gameSegment.enabled=NO;
    customSegment.enabled=NO;
	self.mainTableView.alpha=0;
    
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
		[self.titles1 removeAllObjects];
		[self.values1 removeAllObjects];
		[self.colors1 removeAllObjects];

		[self addDataToArray:self.titles1 values:self.values1 colors:self.colors1 title:NSLocalizedString(@"Profit", nil) value:gameStatObj.profitString color:[self colorForValue:gameStatObj.profit]];
		[self addDataToArray:self.titles1 values:self.values1 colors:self.colors1 title:NSLocalizedString(@"Risked", nil) value:gameStatObj.riskedString color:[UIColor blackColor]];
		[self addDataToArray:self.titles1 values:self.values1 colors:self.colors1 title:NSLocalizedString(@"Games", nil) value:gameStatObj.shortName color:[UIColor blackColor]];
		[self addDataToArray:self.titles1 values:self.values1 colors:self.colors1 title:NSLocalizedString(@"Streak", nil) value:gameStatObj.streak color:[UIColor blackColor]];
		[self addDataToArray:self.titles1 values:self.values1 colors:self.colors1 title:NSLocalizedString(@"WinStreak", nil) value:gameStatObj.winStreak color:[UIColor blackColor]];
		[self addDataToArray:self.titles1 values:self.values1 colors:self.colors1 title:NSLocalizedString(@"LoseStreak", nil) value:gameStatObj.loseStreak color:[UIColor blackColor]];
		[self addDataToArray:self.titles1 values:self.values1 colors:self.colors1 title:NSLocalizedString(@"Hours", nil) value:gameStatObj.hours color:[UIColor blackColor]];
		[self addDataToArray:self.titles1 values:self.values1 colors:self.colors1 title:NSLocalizedString(@"Hourly", nil) value:gameStatObj.hourly color:[self colorForValue:gameStatObj.profit]];
		[self addDataToArray:self.titles1 values:self.values1 colors:self.colors1 title:@"ROI" value:gameStatObj.roi color:[self colorForValue:gameStatObj.profit]];
		[self addDataToArray:self.titles1 values:self.values1 colors:self.colors1 title:[NSString stringWithFormat:@"%@ %@ Point", NSLocalizedString(@"Highest", nil), NSLocalizedString(@"Profit", nil)] value:gameStatObj.profitHigh color:[UIColor colorWithRed:0 green:.5 blue:0 alpha:1]];
		[self addDataToArray:self.titles1 values:self.values1 colors:self.colors1 title:[NSString stringWithFormat:@"%@ %@ Point", NSLocalizedString(@"Lowest", nil), NSLocalizedString(@"Profit", nil)] value:gameStatObj.profitLow color:[UIColor redColor]];
		[self addDataToArray:self.titles1 values:self.values1 colors:self.colors1 title:[NSString stringWithFormat:@"%@ %@ of Week", NSLocalizedString(@"Best", nil), NSLocalizedString(@"day", nil)] value:gameStatObj.bestWeekday color:[ProjectFunctions colorForProfit:gameStatObj.bestDayAmount]];
		[self addDataToArray:self.titles1 values:self.values1 colors:self.colors1 title:[NSString stringWithFormat:@"%@ %@ of Week", NSLocalizedString(@"Worst", nil), NSLocalizedString(@"day", nil)] value:gameStatObj.worstWeekday color:[ProjectFunctions colorForProfit:gameStatObj.worstDayAmount]];
		[self addDataToArray:self.titles1 values:self.values1 colors:self.colors1 title:[NSString stringWithFormat:@"%@ Time of %@", NSLocalizedString(@"Best", nil), NSLocalizedString(@"day", nil)] value:gameStatObj.bestDaytime color:[ProjectFunctions colorForProfit:gameStatObj.bestTimeAmount]];
		[self addDataToArray:self.titles1 values:self.values1 colors:self.colors1 title:[NSString stringWithFormat:@"%@ Time of %@", NSLocalizedString(@"Worst", nil), NSLocalizedString(@"day", nil)] value:gameStatObj.worstDaytime color:[ProjectFunctions colorForProfit:gameStatObj.worstTimeAmount]];
		
		if(gameStatObj.hudGames>0) {
			[self addDataToArray:self.titles1 values:self.values1 colors:self.colors1 title:@"Hud Games" value:[NSString stringWithFormat:@"%d", gameStatObj.hudGames] color:[UIColor purpleColor]];
			[self addDataToArray:self.titles1 values:self.values1 colors:self.colors1 title:@"VPIP / PFR" value:gameStatObj.hudVpvp_Pfr color:[UIColor purpleColor]];
			[self addDataToArray:self.titles1 values:self.values1 colors:self.colors1 title:@"Hud Play Style" value:gameStatObj.hudPlayerType color:[UIColor purpleColor]];
			[self addDataToArray:self.titles1 values:self.values1 colors:self.colors1 title:@"Hud Skill Level" value:gameStatObj.hudSkillLevel color:[UIColor purpleColor]];
		}

		[self.titles2 removeAllObjects];
		[self.values2 removeAllObjects];
		[self.colors2 removeAllObjects];
		
		[self addDataToArray:self.titles2 values:self.values2 colors:self.colors2 title:[NSString stringWithFormat:@"%@ 1", NSLocalizedString(@"Quarter", nil)] value:gameStatObj.quarter1 color:[self colorForValue:gameStatObj.quarter1Profit]];
		[self addDataToArray:self.titles2 values:self.values2 colors:self.colors2 title:[NSString stringWithFormat:@"%@ 2", NSLocalizedString(@"Quarter", nil)] value:gameStatObj.quarter2 color:[self colorForValue:gameStatObj.quarter2Profit]];
		[self addDataToArray:self.titles2 values:self.values2 colors:self.colors2 title:[NSString stringWithFormat:@"%@ 3", NSLocalizedString(@"Quarter", nil)] value:gameStatObj.quarter3 color:[self colorForValue:gameStatObj.quarter3Profit]];
		[self addDataToArray:self.titles2 values:self.values2 colors:self.colors2 title:[NSString stringWithFormat:@"%@ 4", NSLocalizedString(@"Quarter", nil)] value:gameStatObj.quarter4 color:[self colorForValue:gameStatObj.quarter4Profit]];
		[self addDataToArray:self.titles2 values:self.values2 colors:self.colors2 title:NSLocalizedString(@"Total", nil) value:gameStatObj.totals color:[self colorForValue:gameStatObj.quarter1Profit+gameStatObj.quarter2Profit+gameStatObj.quarter3Profit+gameStatObj.quarter4Profit]];

		[self.titles3 removeAllObjects];
		[self.values3 removeAllObjects];
		[self.colors3 removeAllObjects];
		[self addDataToArray:self.titles3 values:self.values3 colors:self.colors3 title:NSLocalizedString(@"Games Won", nil) value:gameStatObj.gamesWon color:[UIColor blackColor]];
		[self addDataToArray:self.titles3 values:self.values3 colors:self.colors3 title:[NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Average", nil), NSLocalizedString(@"Risked", nil)] value:gameStatObj.gamesWonAverageRisked color:[UIColor blackColor]];
		[self addDataToArray:self.titles3 values:self.values3 colors:self.colors3 title:[NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Average", nil), NSLocalizedString(@"rebuy", nil)] value:gameStatObj.gamesWonAverageRebuy color:[UIColor blackColor]];
		[self addDataToArray:self.titles3 values:self.values3 colors:self.colors3 title:[NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Average", nil), NSLocalizedString(@"Profit", nil)] value:gameStatObj.gamesWonAverageProfit color:[UIColor colorWithRed:0 green:.5 blue:0 alpha:1]];
		[self addDataToArray:self.titles3 values:self.values3 colors:self.colors3 title:[NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Max", nil), NSLocalizedString(@"Profit", nil)] value:gameStatObj.gamesWonMaxProfit color:[UIColor colorWithRed:0 green:.5 blue:0 alpha:1]];
		[self addDataToArray:self.titles3 values:self.values3 colors:self.colors3 title:[NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Min", nil), NSLocalizedString(@"Profit", nil)] value:gameStatObj.gamesWonMinProfit color:[UIColor colorWithRed:0 green:.5 blue:0 alpha:1]];

		[self.titles4 removeAllObjects];
		[self.values4 removeAllObjects];
		[self.colors4 removeAllObjects];
		[self addDataToArray:self.titles4 values:self.values4 colors:self.colors4 title:NSLocalizedString(@"Games Lost", nil) value:gameStatObj.gamesLost color:[UIColor blackColor]];
		[self addDataToArray:self.titles4 values:self.values4 colors:self.colors4 title:[NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Average", nil), NSLocalizedString(@"Risked", nil)] value:gameStatObj.gamesLostAverageRisked color:[UIColor blackColor]];
		[self addDataToArray:self.titles4 values:self.values4 colors:self.colors4 title:[NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Average", nil), NSLocalizedString(@"rebuy", nil)] value:gameStatObj.gamesLostAverageRebuy color:[UIColor blackColor]];
		[self addDataToArray:self.titles4 values:self.values4 colors:self.colors4 title:[NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Average", nil), NSLocalizedString(@"Profit", nil)] value:gameStatObj.gamesLostAverageProfit color:[UIColor redColor]];
		[self addDataToArray:self.titles4 values:self.values4 colors:self.colors4 title:[NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Max", nil), NSLocalizedString(@"Profit", nil)] value:gameStatObj.gamesLostMaxProfit color:[UIColor redColor]];
		[self addDataToArray:self.titles4 values:self.values4 colors:self.colors4 title:[NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Min", nil), NSLocalizedString(@"Profit", nil)] value:gameStatObj.gamesLostMinProfit color:[UIColor redColor]];

		chartImageView.image = [ProjectFunctions plotStatsChart:contextLocal predicate:predicate displayBySession:displayBySession];
		self.chartImageView2.image = chartImageView.image;

		[activityIndicator stopAnimating];
		analysisButton.enabled=YES;
		reportsButton.enabled=YES;
		chartsButton.enabled=YES;
		goalsButton.enabled=YES;
		gameSegment.enabled=YES;
		customSegment.enabled=YES;
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
	if(indexPath.section==1)
		return [MultiLineDetailCellWordWrap cellHeightWithNoMainTitleForData:self.values1
																		 tableView:tableView
														labelWidthProportion:0.5]+20;
	if(indexPath.section==2)
		return [MultiLineDetailCellWordWrap cellHeightWithNoMainTitleForData:self.values2
																   tableView:tableView
														labelWidthProportion:0.5]+20;
	if(indexPath.section==3)
		return [MultiLineDetailCellWordWrap cellHeightWithNoMainTitleForData:self.values3
																   tableView:tableView
														labelWidthProportion:0.5]+20;
	if(indexPath.section==4)
		return [MultiLineDetailCellWordWrap cellHeightWithNoMainTitleForData:self.values4
																   tableView:tableView
														labelWidthProportion:0.5]+20;
	return 44;
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
	if(indexPath.section==1) {
		MultiLineDetailCellWordWrap *cell = [[MultiLineDetailCellWordWrap alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier withRows:self.titles1.count labelProportion:0.5];
		cell.mainTitle = NSLocalizedString(@"Game Stats", nil);
		cell.alternateTitle=self.yearChangeView.yearLabel.text;
		
		cell.titleTextArray = self.titles1;
		cell.fieldTextArray = self.values1;
		cell.fieldColorArray = self.colors1;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		
		return cell;
	}
	if(indexPath.section==2) {
		MultiLineDetailCellWordWrap *cell = [[MultiLineDetailCellWordWrap alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier withRows:self.titles2.count labelProportion:0.5];
		cell.mainTitle = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Quarter", nil), NSLocalizedString(@"Stats", nil)];
		cell.alternateTitle=self.yearChangeView.yearLabel.text;
		
		cell.titleTextArray = self.titles2;
		cell.fieldTextArray = self.values2;
		cell.fieldColorArray = self.colors2;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		
		return cell;
	}
	if(indexPath.section==3) {
		MultiLineDetailCellWordWrap *cell = [[MultiLineDetailCellWordWrap alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier withRows:self.titles3.count labelProportion:0.5];
		cell.mainTitle = NSLocalizedString(@"Games Won", nil);
		cell.alternateTitle=self.yearChangeView.yearLabel.text;
		
		cell.titleTextArray = self.titles3;
		cell.fieldTextArray = self.values3;
		cell.fieldColorArray = self.colors3;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		
		return cell;
	}
	
		MultiLineDetailCellWordWrap *cell = [[MultiLineDetailCellWordWrap alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier withRows:self.titles4.count labelProportion:0.5];
		cell.mainTitle = NSLocalizedString(@"Games Lost", nil);
		cell.alternateTitle=self.yearChangeView.yearLabel.text;
		
		cell.titleTextArray = self.titles4;
		cell.fieldTextArray = self.values4;
		cell.fieldColorArray = self.colors4;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		
		return cell;
}

-(NSArray *)colorsForData:(NSArray *)data {
	NSMutableArray *colors = [[NSMutableArray alloc] init];
	int i=0;
	for (NSString *item in data) {
		if(i>1 && i<=4)
			[colors addObject:[self colorForAmount:item]];
		else
			[colors addObject:[UIColor blackColor]];
		i++;
	}
	return colors;
}

-(UIColor *)colorForAmount:(NSString *)money {
	double amount = [ProjectFunctions convertMoneyStringToDouble:money];
	if(amount==0)
		return [UIColor grayColor];
	return (amount>=0)?[UIColor colorWithRed:0 green:.5 blue:0 alpha:1]:[UIColor redColor];
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
	int thisYear = [[[NSDate date] convertDateToStringWithFormat:@"yyyy"] intValue];
	
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

@end
