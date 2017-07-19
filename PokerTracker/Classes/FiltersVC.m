//
//  FiltersVC.m
//  PokerTracker
//
//  Created by Rick Medved on 11/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FiltersVC.h"
#import "MultiLineDetailCellWordWrap.h"
#import "CoreDataLib.h"
#import "QuadFieldTableViewCell.h"
#import "SelectionCell.h"
#import "GameDetailsVC.h"
#import "ListPicker.h"
#import "NSDate+ATTDate.h"
#import "UIColor+ATTColor.h"
#import "ProjectFunctions.h"
#import "MainMenuVC.h"
#import "ActionCell.h"
#import "TextEditCell.h"
#import "FilterNameEnterVC.h"
#import "GameInProgressVC.h"
#import "FilterListVC.h"
#import "NSArray+ATTArray.h"

#define kLeftLabelRation	0.5
#define kfilterButton	7
#define kfiltername		8
#define kSaveFilter		8

@implementation FiltersVC

@synthesize managedObjectContext, gameType, statsArray, labelValues, currentFilterLabel, timeFramLabel, messageLabel;
@synthesize formDataArray, selectedFieldIndex, mainTableView, gameSegment, customSegment;
@synthesize displayBySession, activityBGView, activityIndicator, chartImageView, gamesList, displayLabelValues;
@synthesize displayYear, yearLabel, leftYear, rightYear, viewLocked, yearToolbar, buttonNum, filterObj;


-(void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	if([self respondsToSelector:@selector(edgesForExtendedLayout)])
		[self setEdgesForExtendedLayout:UIRectEdgeBottom];
	
	[self checkCustomSegment];

	if(gameSegment.selectedSegmentIndex==0)
		[self computeStats];
}

- (void)viewDidLoad {
	
	displayLabelValues = [[NSMutableArray alloc] initWithArray:[NSArray arrayWithObjects:
																@"Timeframe",
																@"Game Type",
																NSLocalizedString(@"Game", nil),
																NSLocalizedString(@"limit", nil),
																NSLocalizedString(@"stakes", nil),
																NSLocalizedString(@"location", nil),
																NSLocalizedString(@"bankroll", nil),
																@"Tournament Type",
																nil]];
	labelValues = [[NSMutableArray alloc] initWithArray:[NSArray arrayWithObjects:
														 @"Timeframe",
														 @"Game Type",
														 @"Game",
														 @"Limit",
														 @"Stakes",
														 @"Location",
														 @"Bankroll",
														 @"Tournament Type",
														 nil]];
	statsArray = [[NSMutableArray alloc] initWithArray:[NSArray arrayWithObjects:
														@"winnings",
														@"gameCount",
														@"streak",
														@"longestWinStreak",
														@"longestLoseStreak",
														@"hours",
														@"hourlyRate",
														nil]];
	formDataArray = [[NSMutableArray alloc] initWithArray:[NSArray arrayWithObjects:
														   NSLocalizedString(@"LifeTime", nil),
														   NSLocalizedString(@"All", nil), //@"All GameTypes",
														   NSLocalizedString(@"All", nil),
														   NSLocalizedString(@"All", nil), //@"All Limits",
														   NSLocalizedString(@"All", nil), //@"All Stakes",
														   NSLocalizedString(@"All", nil), //@"All Locations",
														   NSLocalizedString(@"All", nil), //@"All Bankrolls",
														   NSLocalizedString(@"All", nil), //@"All Types",
														   nil]];
	gamesList = [[NSMutableArray alloc] init];
	
	self.chartImageView = [[UIImageView alloc] init];
	self.messageLabel.text = NSLocalizedString(@"FilterMessage", nil);
	
	self.selectedFieldIndex=0;
	self.displayBySession=NO;
	self.viewLocked=NO;
	
	[self.mainTableView setBackgroundView:nil];
	
	if([gameType isEqualToString:@""])
		self.gameType = [ProjectFunctions getUserDefaultValue:@"gameTypeDefault"];
	
	[yearToolbar insertSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"greenGradWide.png"]] atIndex:0];
	[yearToolbar setTintColor:[UIColor colorWithRed:0 green:.5 blue:0 alpha:1]];
	[gameSegment setTintColor:[UIColor colorWithRed:0 green:.5 blue:0 alpha:1]];
	
	
	[self setTitle:NSLocalizedString(@"Filters", nil)];
	[super viewDidLoad];
	
	if(displayYear==0)
		displayYear = [[[NSDate date] convertDateToStringWithFormat:@"yyyy"] intValue];
	
	yearLabel.text = [NSString stringWithFormat:@"%d", displayYear];
	
	self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:
											   [ProjectFunctions UIBarButtonItemWithIcon:[NSString fontAwesomeIconStringForEnum:FASearch] target:self action:@selector(mainMenuButtonClicked:)],
											   [ProjectFunctions UIBarButtonItemWithIcon:[NSString fontAwesomeIconStringForEnum:FAInfoCircle] target:self action:@selector(popupButtonClicked)],
											   nil];
	
	self.popupView.titleLabel.text = self.title;
	self.popupView.textView.text = NSLocalizedString(@"FilterMessage", nil);
	self.popupView.textView.hidden=NO;

	
	self.chartImageView.alpha=0;
	
	[ProjectFunctions resetTheYearSegmentBar:mainTableView displayYear:displayYear MoC:self.managedObjectContext leftButton:leftYear rightButton:rightYear displayYearLabel:yearLabel];
	
	[formDataArray replaceObjectAtIndex:0 withObject:[ProjectFunctions labelForYearValue:displayYear]];
	
	gameSegment.selectedSegmentIndex = [ProjectFunctions selectedSegmentForGameType:gameType];
	
	[gameSegment setWidth:60 forSegmentAtIndex:0];
	self.currentFilterLabel.text = @"None";
	
	[ProjectFunctions makeSegment:self.gameSegment color:[UIColor colorWithRed:.0 green:.5 blue:0 alpha:1]];
	[ProjectFunctions makeSegment:self.customSegment color:[UIColor colorWithRed:0 green:.5 blue:0 alpha:1]];
	
	NSArray *items = [CoreDataLib selectRowsFromTable:@"SEARCH" mOC:self.managedObjectContext];
	for(NSManagedObject *mo in items) {
		NSLog(@"+++SEARCH Record: %@", [mo valueForKey:@"type"]);
		NSLog(@"checkmarkList: %@", [mo valueForKey:@"checkmarkList"]);
		NSLog(@"searchStr: %@", [mo valueForKey:@"searchStr"]);
		NSLog(@"%@", [mo valueForKey:@"startTime"]);
		NSLog(@"%@", [mo valueForKey:@"endTime"]);
		NSLog(@"searchNum: %d", [[mo valueForKey:@"searchNum"] intValue]);
	}
	
}

-(void)chooseFilterObj:(NSManagedObject *)mo {
	self.filterObj=mo;
	self.currentFilterLabel.text = [mo valueForKey:@"name"];
	self.buttonNum=[[mo valueForKey:@"button"] intValue];
	yearLabel.text=[mo valueForKey:@"name"];
	[formDataArray replaceObjectAtIndex:0 withObject:[mo valueForKey:@"timeframe"]];
	[formDataArray replaceObjectAtIndex:1 withObject:[mo valueForKey:@"Type"]];
	[formDataArray replaceObjectAtIndex:2 withObject:[mo valueForKey:@"game"]];
	[formDataArray replaceObjectAtIndex:3 withObject:[mo valueForKey:@"limit"]];
	[formDataArray replaceObjectAtIndex:4 withObject:[mo valueForKey:@"stakes"]];
	[formDataArray replaceObjectAtIndex:5 withObject:[mo valueForKey:@"location"]];
	[formDataArray replaceObjectAtIndex:6 withObject:[mo valueForKey:@"bankroll"]];
	[formDataArray replaceObjectAtIndex:7 withObject:[mo valueForKey:@"tournamentType"]];
	[self computeStats];
}


-(void)setFilterIndex:(int)row_id
{
	NSArray *filterList = [CoreDataLib selectRowsFromEntity:@"FILTER" predicate:nil sortColumn:@"button" mOC:managedObjectContext ascendingFlg:YES];
	if([filterList count]>row_id) {
		NSManagedObject *mo = [filterList objectAtIndex:row_id];
		self.currentFilterLabel.text = [mo valueForKey:@"name"];
		self.buttonNum=[[mo valueForKey:@"button"] intValue];
		NSLog(@"+++self.buttonNum: %d", self.buttonNum);
		yearLabel.text=[mo valueForKey:@"name"];
		[formDataArray replaceObjectAtIndex:0 withObject:[mo valueForKey:@"timeframe"]];
		[formDataArray replaceObjectAtIndex:1 withObject:[mo valueForKey:@"Type"]];
		[formDataArray replaceObjectAtIndex:2 withObject:[mo valueForKey:@"game"]];
		[formDataArray replaceObjectAtIndex:3 withObject:[mo valueForKey:@"limit"]];
		[formDataArray replaceObjectAtIndex:4 withObject:[mo valueForKey:@"stakes"]];
		[formDataArray replaceObjectAtIndex:5 withObject:[mo valueForKey:@"location"]];
		[formDataArray replaceObjectAtIndex:6 withObject:[mo valueForKey:@"bankroll"]];
		[formDataArray replaceObjectAtIndex:7 withObject:[mo valueForKey:@"tournamentType"]];
		[self computeStats];
	}

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

-(void)mainMenuButtonClicked:(id)sender {
    FilterListVC *detailViewController = [[FilterListVC alloc] initWithNibName:@"FilterListVC" bundle:nil];
    detailViewController.managedObjectContext = managedObjectContext;
    detailViewController.callBackViewController=self;
    [self.navigationController pushViewController:detailViewController animated:YES];
}

-(void)doTheHardWord {
	@autoreleasepool {
		[ProjectFunctions displayTimeFrameLabel:self.timeFramLabel mOC:self.managedObjectContext buttonNum:self.buttonNum timeFrame:[formDataArray objectAtIndex:0]];
		NSPredicate *predicate = [ProjectFunctions getPredicateForFilter:formDataArray mOC:managedObjectContext buttonNum:(int)self.buttonNum];
		NSArray *games = [CoreDataLib selectRowsFromEntity:@"GAME" predicate:predicate sortColumn:@"startTime" mOC:self.managedObjectContext ascendingFlg:NO];
		[gamesList removeAllObjects];
		[gamesList addObjectsFromArray:games];
		self.chartImageView.image = [ProjectFunctions plotStatsChart:managedObjectContext predicate:predicate displayBySession:displayBySession];
		self.chartImageView.alpha=1;

		NSString *stats2 = [CoreDataLib getGameStat:managedObjectContext dataField:@"stats2" predicate:predicate];
		[statsArray removeAllObjects];
		[statsArray addObjectsFromArray:[stats2 componentsSeparatedByString:@"|"]];
		
		activityBGView.alpha=0;
		[activityIndicator stopAnimating];
		viewLocked=NO;
		[mainTableView reloadData];
	}
}

-(void)executeThreadedJob:(SEL)aSelector
{
	[activityIndicator startAnimating];
	activityBGView.alpha=1;
	[self performSelectorInBackground:aSelector withObject:nil];
}

-(void) computeStats
{
	[ProjectFunctions setFontColorForSegment:gameSegment values:nil];

    [self doTheHardWord];
	
//	[self executeThreadedJob:@selector(doTheHardWord)];
}

-(void)initializeFormData
{
	[formDataArray replaceObjectAtIndex:0 withObject:[ProjectFunctions labelForYearValue:displayYear]];
	[formDataArray replaceObjectAtIndex:1 withObject:[ProjectFunctions labelForGameSegment:(int)gameSegment.selectedSegmentIndex]];
	[formDataArray replaceObjectAtIndex:2 withObject:NSLocalizedString(@"All", nil)]; //games
	[formDataArray replaceObjectAtIndex:3 withObject:NSLocalizedString(@"All", nil)]; //@"All Limits"
	[formDataArray replaceObjectAtIndex:4 withObject:NSLocalizedString(@"All", nil)]; //@"All Stakes"
	[formDataArray replaceObjectAtIndex:5 withObject:NSLocalizedString(@"All", nil)]; //@"All Locations"
	[formDataArray replaceObjectAtIndex:6 withObject:NSLocalizedString(@"All", nil)]; //@"All Bankrolls"
	[formDataArray replaceObjectAtIndex:7 withObject:NSLocalizedString(@"All", nil)]; //@"All Types"
}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}


- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return CGFLOAT_MIN;
}


-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	return CGFLOAT_MIN;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if(indexPath.section==0) {
		int height = [MultiLineDetailCellWordWrap cellHeightWithNoMainTitleForData:statsArray
																		 tableView:tableView
															  labelWidthProportion:kLeftLabelRation]+20;
		return height;
	} 
	if(indexPath.section==1)
		return [ProjectFunctions chartHeightForSize:170];
	
	return 44;
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if(section==3) {
		return [gamesList count];
	}
	if(section==2)
		return [formDataArray count]+1;
	else
		return 1;	
}

-(UIColor *)getFieldColor:(int)value
{
	if(value>0)
		return [UIColor colorWithRed:0 green:.5 blue:0 alpha:1];
	if(value<0)
		return [UIColor redColor];
	return [UIColor blackColor];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *CellIdentifier = [NSString stringWithFormat:@"cellIdentifierSection%dRow%d", (int)indexPath.section, (int)indexPath.row];
    
	if(indexPath.section==0) {
		int NumberOfRows=(int)[statsArray count];
		MultiLineDetailCellWordWrap *cell = (MultiLineDetailCellWordWrap *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[MultiLineDetailCellWordWrap alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier withRows:NumberOfRows labelProportion:kLeftLabelRation];
		}
		
		cell.mainTitle = NSLocalizedString(@"Game Stats", nil);
		cell.alternateTitle = [formDataArray objectAtIndex:0];
		
		NSArray *titles = [NSArray arrayWithObjects:NSLocalizedString(@"Profit", nil), NSLocalizedString(@"Risked", nil), NSLocalizedString(@"Games", nil), NSLocalizedString(@"Streak", nil), NSLocalizedString(@"WinStreak", nil), NSLocalizedString(@"LoseStreak", nil), NSLocalizedString(@"Hours", nil), NSLocalizedString(@"Hourly", nil), @"ROI", nil];
		NSMutableArray *colorArray = [[NSMutableArray alloc] init];
		
		[colorArray addObject:[self getFieldColor:[[statsArray objectAtIndex:0] intValue]]];
		[colorArray addObject:[UIColor blackColor]];
		[colorArray addObject:[UIColor blackColor]];
		[colorArray addObject:[self getFieldColor:[[statsArray objectAtIndex:3] intValue]]];
		[colorArray addObject:[self getFieldColor:[[statsArray objectAtIndex:4] intValue]]];
		[colorArray addObject:[self getFieldColor:[[statsArray objectAtIndex:5] intValue]]];
		[colorArray addObject:[UIColor blackColor]];
		[colorArray addObject:[self getFieldColor:[[statsArray objectAtIndex:7] intValue]]];
		[colorArray addObject:[self getFieldColor:[[statsArray objectAtIndex:8] intValue]]];
		
		NSMutableArray *valueArray = [[NSMutableArray alloc] initWithArray:statsArray];
		int money = [[statsArray objectAtIndex:0] intValue];
		int risked = [[statsArray objectAtIndex:1] intValue];
		[valueArray replaceObjectAtIndex:0 withObject:[ProjectFunctions convertIntToMoneyString:money]];
		[valueArray replaceObjectAtIndex:1 withObject:[ProjectFunctions convertIntToMoneyString:risked]];
		int streak = [[statsArray objectAtIndex:3] intValue];
		[valueArray replaceObjectAtIndex:3 withObject:[ProjectFunctions getWinLossStreakString:streak]];
		streak = [[statsArray objectAtIndex:4] intValue];
		[valueArray replaceObjectAtIndex:4 withObject:[ProjectFunctions getWinLossStreakString:streak]];
		streak = [[statsArray objectAtIndex:5] intValue];
		[valueArray replaceObjectAtIndex:5 withObject:[ProjectFunctions getWinLossStreakString:streak]];
		
		[valueArray replaceObjectAtIndex:7 withObject:[NSString stringWithFormat:@"%@%@/hr", [ProjectFunctions getMoneySymbol], [statsArray objectAtIndex:7]]];
		[valueArray replaceObjectAtIndex:8 withObject:[NSString stringWithFormat:@"%@%%", [statsArray objectAtIndex:8]]];
		
		cell.titleTextArray = titles;
		cell.fieldTextArray = valueArray;
		cell.fieldColorArray = colorArray;
		
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		
		return cell;
	}
	if(indexPath.section==1) {
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
		}
		
		cell.backgroundView = self.chartImageView;
		cell.backgroundColor = [UIColor whiteColor];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		
		return cell;
	}
	if(indexPath.section==2) {
		NSString *cellIdentifier = [NSString stringWithFormat:@"cellIdentifierSection%dRow%d", (int)indexPath.section, (int)indexPath.row];
		if(indexPath.row==kSaveFilter) {
			ActionCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
			if (cell == nil) {
				cell = [[ActionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
			}
			cell.backgroundColor = [UIColor colorWithRed:1 green:.8 blue:0 alpha:1];
			cell.textLabel.text = NSLocalizedString(@"saveFilter", nil);
			return cell;
		}
		
		SelectionCell *cell = (SelectionCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
		if (cell == nil) {
			cell = [[SelectionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
		}
		
//		cell.textLabel.text = [labelValues objectAtIndex:indexPath.row];
		cell.textLabel.text = [displayLabelValues objectAtIndex:indexPath.row];
		cell.selection.text = [formDataArray objectAtIndex:indexPath.row];
		NSString *value = [formDataArray objectAtIndex:indexPath.row];
		if([value length]>2) {
			if(indexPath.row<kSaveFilter && ![value isEqualToString:NSLocalizedString(@"LifeTime", nil)] && ![[value substringToIndex:3] isEqualToString:@"All"])
				cell.selection.textColor = [UIColor redColor];
			else
				cell.selection.textColor = [UIColor ATTBlue];
		}
		
		cell.backgroundColor = [UIColor ATTFaintBlue];
		cell.selectionStyle = UITableViewCellSelectionStyleGray;
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		return cell;
	}
	
	return [ProjectFunctions getGameCell:[gamesList objectAtIndex:indexPath.row] CellIdentifier:CellIdentifier tableView:tableView evenFlg:indexPath.row%2==0];
	
}

-(void) setReturningValue:(NSObject *) value2 {
	NSString *value = [ProjectFunctions getUserDefaultValue:@"returnValue"];
	if(selectedFieldIndex==kSaveFilter) {
		[self saveNewFilter:(NSString *)value];
		[self computeStats];
		return;
	}
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

-(void)saveCustomSearch:(NSString *)type searchNum:(NSString *)searchNum row_id:(int)row_id
{
	searchNum = [NSString stringWithFormat:@"%d", row_id];
	NSLog(@"saveCustomSearch : %@ %@ %d", type, searchNum, row_id);
	if([type isEqualToString:@"Timeframe"]) {
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"type = %@ AND searchNum = 0", type];
		NSArray *items = [CoreDataLib selectRowsFromEntity:@"SEARCH" predicate:predicate sortColumn:nil mOC:managedObjectContext ascendingFlg:YES];
		if([items count]>0) {
			NSManagedObject *mo = [items objectAtIndex:0];
			NSDate *startTime = [mo valueForKey:@"startTime"];
			NSDate *endTime = [mo valueForKey:@"endTime"];
			
			NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"type = %@ AND searchNum = %d", type, row_id];
			[CoreDataLib insertOrUpdateManagedObjectForEntity:@"SEARCH" valueList:[NSArray arrayWithObjects:@"Timeframe", @"", [startTime convertDateToStringWithFormat:nil], [endTime convertDateToStringWithFormat:nil], @"", searchNum, nil] mOC:managedObjectContext predicate:predicate2];
			NSLog(@"Creating new Timeframe record for searchNum: %@", searchNum);
		}
	} else {
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"type = %@ AND searchNum = %d", type, row_id];
		NSString *checkmarkList = [CoreDataLib getFieldValueForEntityWithPredicate:managedObjectContext entityName:@"SEARCH" field:@"checkmarkList" predicate:predicate indexPathRow:0];
		NSString *searchStr = [CoreDataLib getFieldValueForEntityWithPredicate:managedObjectContext entityName:@"SEARCH" field:@"searchStr" predicate:predicate indexPathRow:0];
		
		NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"type = %@ AND searchNum = %d", type, row_id];
		[CoreDataLib insertOrUpdateManagedObjectForEntity:@"SEARCH" valueList:[NSArray arrayWithObjects:type, searchStr, @"", @"", checkmarkList, searchNum, nil] mOC:managedObjectContext predicate:predicate2];
		
		NSLog(@"Creating new search record for searchNum: %@", searchNum);
	}
}

-(int)getMaxFilterPlusOne
{
	int button=1;
	NSArray *filters = [CoreDataLib selectRowsFromEntity:@"FILTER" predicate:nil sortColumn:@"button" mOC:self.managedObjectContext ascendingFlg:NO];
	if([filters count]>0) {
		NSManagedObject *mo = [filters objectAtIndex:0];
		button = [[mo valueForKey:@"button"] intValue];
		button++;
	}
	NSLog(@"button: %d", button);
	return button;
}

-(BOOL)saveNewFilter:(NSString *)valueCombo
{
	NSLog(@"+++saving! %@", valueCombo);
	NSArray *items = [valueCombo componentsSeparatedByString:@"|"];
	NSString *buttonName = [items objectAtIndex:0];
	int buttonNumber = [[items objectAtIndex:1] intValue]+1;
	if(buttonNumber==4)
		buttonNumber = [self getMaxFilterPlusOne];

	
	NSArray *oldFilters = [CoreDataLib selectRowsFromEntity:@"FILTER" predicate:nil sortColumn:@"button" mOC:managedObjectContext ascendingFlg:YES];
	int newRowId=1;
	NSLog(@"saving filter");
	for(NSManagedObject *mo in oldFilters) {
		int row_id = [[mo valueForKey:@"row_id"] intValue];
		NSLog(@"+++row_id: %d", row_id);
		if(row_id>=newRowId)
			newRowId=row_id+1;
	}

	
	NSArray *keyList = [ProjectFunctions getColumnListForEntity:@"FILTER" type:@"column"];
	NSArray *typeList = [ProjectFunctions getColumnListForEntity:@"FILTER" type:@"type"];
	NSMutableArray *valueList = [[NSMutableArray alloc] initWithArray:formDataArray];
	
	[valueList addObject:[NSString stringWithFormat:@"%d", buttonNumber]];
	[valueList addObject:buttonName];

	NSManagedObject *mo;
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name = %@", buttonName];
	NSArray *filters = [CoreDataLib selectRowsFromEntity:@"FILTER" predicate:predicate sortColumn:@"button" mOC:self.managedObjectContext ascendingFlg:YES];
	if([filters count]>0) {
		NSLog(@"---updating");
		mo = [filters objectAtIndex:0];
		newRowId = [[mo valueForKey:@"row_id"] intValue];
	} else {
		NSLog(@"---inserting");
		mo = [NSEntityDescription insertNewObjectForEntityForName:@"FILTER" inManagedObjectContext:self.managedObjectContext];
		[mo setValue:[NSNumber numberWithInt:newRowId] forKey:@"row_id"];
	}
	BOOL success = [CoreDataLib updateManagedObject:mo keyList:keyList valueList:valueList typeList:typeList mOC:self.managedObjectContext];
	if(success) {
		gameSegment.selectedSegmentIndex = 0;
	}
	if(buttonNumber<3) {
		[customSegment setTitle:buttonName forSegmentAtIndex:buttonNumber];
		customSegment.selectedSegmentIndex = buttonNumber;
	}
	
	// save custom filters
	int i=0;
	for(NSString *value in formDataArray) {
		NSString *type = [labelValues objectAtIndex:i++];
		if([value isEqualToString:@"*Custom*"])
			[self saveCustomSearch:type searchNum:[NSString stringWithFormat:@"%d", buttonNumber] row_id:newRowId];
	}
	NSLog(@"+++newRowId: %d", newRowId);
	[managedObjectContext save:nil];
	NSLog(@"Done!");
	return success;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	self.selectedFieldIndex = (int)indexPath.row;
	if(indexPath.section==1) {
		self.displayBySession = !displayBySession;
		[self computeStats];
	}
	if(indexPath.section==2) {	
		if(indexPath.row<kSaveFilter) {
			ListPicker *detailViewController = [[ListPicker alloc] initWithNibName:@"ListPicker" bundle:nil];
			detailViewController.initialDateValue = [formDataArray objectAtIndex:indexPath.row];
			detailViewController.titleLabel = [NSString stringWithFormat:@"%@", [labelValues objectAtIndex:indexPath.row]];
			detailViewController.selectedList = (int)indexPath.row;
			detailViewController.managedObjectContext = managedObjectContext;
			detailViewController.showNumRecords=YES;
			detailViewController.allowEditing=NO;
			if(indexPath.row==0)
				detailViewController.selectionList = [self getListOfYears];
			else
				detailViewController.selectionList = [CoreDataLib getFieldList:[labelValues objectAtIndex:indexPath.row] mOC:self.managedObjectContext addAllTypesFlg:YES];
			detailViewController.callBackViewController = self;
			[self.navigationController pushViewController:detailViewController animated:YES];
		}
		if(indexPath.row==kSaveFilter) {
			FilterNameEnterVC *detailViewController = [[FilterNameEnterVC alloc] initWithNibName:@"FilterNameEnterVC" bundle:nil];
			detailViewController.callBackViewController = self;
			detailViewController.managedObjectContext = managedObjectContext;
			detailViewController.filerObj=self.filterObj;
			[self.navigationController pushViewController:detailViewController animated:YES];
		}
	}
	if(indexPath.section==3) {
		NSManagedObject *mo = [gamesList objectAtIndex:indexPath.row];
		
		if([[mo valueForKey:@"status"] isEqualToString:@"In Progress"]) {
			GameInProgressVC *detailViewController = [[GameInProgressVC alloc] initWithNibName:@"GameInProgressVC" bundle:nil];
			detailViewController.managedObjectContext = managedObjectContext;
			detailViewController.mo = mo;
			detailViewController.newGameStated=NO;
			[self.navigationController pushViewController:detailViewController animated:YES];
		} else {
			GameDetailsVC *detailViewController = [[GameDetailsVC alloc] initWithNibName:@"GameDetailsVC" bundle:nil];
			detailViewController.managedObjectContext = managedObjectContext;
			detailViewController.viewEditable = NO;
			detailViewController.mo = mo;
			[self.navigationController pushViewController:detailViewController animated:YES];
		}
	} 
}






@end
