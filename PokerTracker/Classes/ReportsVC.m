//
//  ReportsVC.m
//  PokerTracker
//
//  Created by Rick Medved on 10/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ReportsVC.h"
#import "MultiLineDetailCellWordWrap.h"
#import "CoreDataLib.h"
#import "ProjectFunctions.h"
#import "NSDate+ATTDate.h"
#import "NSArray+ATTArray.h"
#import "PokerTrackerAppDelegate.h"
#import "BankrollsVC.h"


@implementation ReportsVC
@synthesize managedObjectContext, mainTableView;
@synthesize sectionTitles, multiDimentionalValues;
@synthesize topSegment, activityIndicator;
@synthesize gameSegment, gameType, refreshButton;
@synthesize multiDimentionalValues0, multiDimentionalValues1, multiDimentionalValues2;
@synthesize bankRollSegment, bankrollButton;


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	sectionTitles = [[NSMutableArray alloc] init];
	multiDimentionalValues = [[NSMutableArray alloc] init];
	multiDimentionalValues0 = [[NSMutableArray alloc] init];
	multiDimentionalValues1 = [[NSMutableArray alloc] init];
	multiDimentionalValues2 = [[NSMutableArray alloc] init];
	
	[self.mainTableView setBackgroundView:nil];
	
	self.gameType = @"All";
	
	[super viewDidLoad];
	[self setTitle:NSLocalizedString(@"Reports", nil)];
	[self changeNavToIncludeType:26];
	
	self.navigationItem.rightBarButtonItem = [ProjectFunctions navigationButtonWithTitle:NSLocalizedString(@"Main Menu", nil) selector:@selector(mainMenuButtonClicked:) target:self];
	
	[gameSegment setTintColor:[UIColor colorWithRed:0 green:.5 blue:0 alpha:1]];
	
	gameSegment.selectedSegmentIndex = [ProjectFunctions selectedSegmentForGameType:self.gameType];
	
	int numBanks = [[ProjectFunctions getUserDefaultValue:@"numBanks"] intValue];
	
	self.bankrollButton.alpha=1;
	self.bankRollSegment.alpha=1;
	
	if(numBanks==0) {
		self.bankrollButton.alpha=0;
		self.bankRollSegment.alpha=0;
	}
	
	refreshButton.enabled=NO;
	
	[ProjectFunctions makeGameSegment:self.gameSegment color:[UIColor colorWithRed:0 green:.5 blue:0 alpha:1]];
	[ProjectFunctions makeSegment:self.topSegment color:[UIColor colorWithRed:0 green:.5 blue:0 alpha:1] size:16];
	[self.topSegment setTitle:[NSString fontAwesomeIconStringForEnum:FAUsd] forSegmentAtIndex:0];
	[self.topSegment setTitle:[NSString fontAwesomeIconStringForEnum:FAClockO] forSegmentAtIndex:1];
	[self.topSegment setTitle:[NSString fontAwesomeIconStringForEnum:FAStar] forSegmentAtIndex:2];
	
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if([self respondsToSelector:@selector(edgesForExtendedLayout)])
        [self setEdgesForExtendedLayout:UIRectEdgeBottom];

    [ProjectFunctions setBankSegment:self.bankRollSegment];
    [self computeStats];
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

- (IBAction) segmentChanged: (id) sender {
	if(self.topSegment.selectedSegmentIndex==0) {
		[self setTitle:NSLocalizedString(@"Profit", nil)];
	}
	if(self.topSegment.selectedSegmentIndex==1) {
		[self setTitle:NSLocalizedString(@"Hourly", nil)];
	}
	if(self.topSegment.selectedSegmentIndex==2) {
		[self setTitle:NSLocalizedString(@"Games", nil)];
	}
	[self changeNavToIncludeType:26];
    [mainTableView reloadData];
}


- (IBAction) gameSegmentChanged: (id) sender {
	[ProjectFunctions changeColorForGameBar:self.gameSegment];
	self.gameType = [ProjectFunctions labelForGameSegment:(int)gameSegment.selectedSegmentIndex];
	[self updateTitleForBar:self.gameSegment title:@"Reports" type:26];
	[self computeStats];
}

-(void)mainMenuButtonClicked:(id)sender {
	[self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
}

-(double)getPrimaryNumber:(double)winnings gameCount:(int)gameCount minutes:(int)minutes selectedSegmentIndex:(int)selectedSegmentIndex
{
//    int hours = minutes/60;
    float hoursFloat = (float)minutes/60;
    int hourlyRate = 0;
    if(hoursFloat>0)
        hourlyRate = (float)winnings/hoursFloat;
    double number=0;
    
    if(selectedSegmentIndex==0) 
        number = winnings + 50000000;
    
    if(selectedSegmentIndex==1) 
        number = hourlyRate + 50000000;
    
    if(selectedSegmentIndex==2) 
        number = gameCount + 50000000;

    
    return number;
}

-(int)getSecondaryNumber:(int)winnings gameCount:(int)gameCount minutes:(int)minutes selectedSegmentIndex:(int)selectedSegmentIndex
{
    int number=0;
    
    if(selectedSegmentIndex==0) 
        number = gameCount;
    
    if(selectedSegmentIndex==1) 
        number = minutes/60;
    
    if(selectedSegmentIndex==2) 
        number = winnings;
    
    
    return number;
}

-(void)yearChanged {
	[self computeStats];
}

- (void)computeStats
{
	[ProjectFunctions setFontColorForSegment:gameSegment values:nil];
	[activityIndicator startAnimating];
	self.mainTableView.alpha=.5;
	[self performSelectorInBackground:@selector(doTheHardWork) withObject:nil];
}

-(void)doTheHardWork {
	@autoreleasepool {
        NSManagedObjectContext *contextLocal = [[NSManagedObjectContext alloc] init];
        [contextLocal setUndoManager:nil];
        
        PokerTrackerAppDelegate *appDelegate = (PokerTrackerAppDelegate *)[[UIApplication sharedApplication] delegate];
        [contextLocal setPersistentStoreCoordinator:appDelegate.persistentStoreCoordinator];
		
		[sectionTitles removeAllObjects];
		[multiDimentionalValues removeAllObjects];
		[multiDimentionalValues0 removeAllObjects];
		[multiDimentionalValues1 removeAllObjects];
		[multiDimentionalValues2 removeAllObjects];
		
		NSArray *sectionList = [NSArray arrayWithObjects:@"Type", @"gametype", @"location", @"stakes", @"limit", @"year", @"weekday", @"month", @"daytime", nil];
		for(NSString *sectionField in sectionList) {
			[self populateArrayForField:sectionField context:contextLocal];
		} // <-- for
		
		NSString *basicPred = [ProjectFunctions getBasicPredicateString:self.yearChangeView.statYear type:self.gameType];
		NSPredicate *predicate = [NSPredicate predicateWithFormat:basicPred];
		[sectionTitles addObject:NSLocalizedString(@"Tips", nil)];
		NSString *tokeString = [CoreDataLib getGameStat:contextLocal dataField:@"tokeString" predicate:predicate];
		[multiDimentionalValues addObject:[NSArray arrayWithObjects:tokeString, nil]];
		[multiDimentionalValues0 addObject:[NSArray arrayWithObjects:tokeString, nil]];
		[multiDimentionalValues1 addObject:[NSArray arrayWithObjects:tokeString, nil]];
		[multiDimentionalValues2 addObject:[NSArray arrayWithObjects:tokeString, nil]];
		
		[activityIndicator stopAnimating];
		self.mainTableView.alpha=1;
		[mainTableView reloadData];
	}
}

-(NSArray *)getValuesForField:(NSString *)field context:(NSManagedObjectContext *)context {
	NSMutableDictionary *daysOfWeekDict = [[NSMutableDictionary alloc] init];
	NSString *basicPred = [ProjectFunctions getBasicPredicateString:self.yearChangeView.statYear type:self.gameType];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:basicPred];
	NSArray *allGames = [CoreDataLib selectRowsFromEntity:@"GAME" predicate:predicate sortColumn:nil mOC:context ascendingFlg:NO];
	for (NSManagedObject *mo in allGames) {
		[daysOfWeekDict setObject:@"1" forKey:[mo valueForKey:field]];
	}
	return [daysOfWeekDict allKeys];
}

-(void)populateArrayForField:(NSString *)field context:(NSManagedObjectContext *)contextLocal {
	NSMutableArray *valueArray = [[NSMutableArray alloc] init];
	NSMutableArray *valueArray0 = [[NSMutableArray alloc] init];
	NSMutableArray *valueArray1 = [[NSMutableArray alloc] init];
	NSMutableArray *valueArray2 = [[NSMutableArray alloc] init];
	NSString *basicPred = [ProjectFunctions getBasicPredicateString:self.yearChangeView.statYear type:self.gameType];
	NSArray *days = [self getValuesForField:field context:contextLocal];
	for(NSString *day in days) {
		NSPredicate *predicate = [ProjectFunctions predicateForBasic:basicPred field:field value:day];

		NSArray *games = [CoreDataLib selectRowsFromEntity:@"GAME" predicate:predicate sortColumn:nil mOC:contextLocal ascendingFlg:NO];
		double winnings=0;
		int gameCount=(int)games.count;
		int minutes=0;
		for(NSManagedObject *game in games) {
			winnings += [[game valueForKey:@"winnings"] doubleValue];
			minutes += [[game valueForKey:@"minutes"] intValue];
		}

		if(gameCount>0) {
			double primaryNumber = [self getPrimaryNumber:winnings gameCount:gameCount minutes:minutes selectedSegmentIndex:(int)topSegment.selectedSegmentIndex];
			int secondaryNumber = [self getSecondaryNumber:winnings gameCount:gameCount minutes:minutes selectedSegmentIndex:(int)topSegment.selectedSegmentIndex];
			
			[valueArray addObject:[NSString stringWithFormat:@"%f|%@|%d", primaryNumber, day, secondaryNumber]];
			[valueArray0 addObject:[NSString stringWithFormat:@"%f|%@|%d",
									[self getPrimaryNumber:winnings gameCount:gameCount minutes:minutes selectedSegmentIndex:0],
									day,
									[self getSecondaryNumber:winnings gameCount:gameCount minutes:minutes selectedSegmentIndex:0]]];
			[valueArray1 addObject:[NSString stringWithFormat:@"%f|%@|%d",
									[self getPrimaryNumber:winnings gameCount:gameCount minutes:minutes selectedSegmentIndex:1],
									day,
									[self getSecondaryNumber:winnings gameCount:gameCount minutes:minutes selectedSegmentIndex:1]]];
			[valueArray2 addObject:[NSString stringWithFormat:@"%f|%@|%d",
									[self getPrimaryNumber:winnings gameCount:gameCount minutes:minutes selectedSegmentIndex:2],
									day,
									[self getSecondaryNumber:winnings gameCount:gameCount minutes:minutes selectedSegmentIndex:2]]];
		}
	}
	[sectionTitles addObject:NSLocalizedString(field, nil)];
	[multiDimentionalValues addObject:valueArray];
	[multiDimentionalValues0 addObject:valueArray0];
	[multiDimentionalValues1 addObject:valueArray1];
	[multiDimentionalValues2 addObject:valueArray2];
}

- (void)calcMoreStats
{
	@autoreleasepool {
		NSManagedObjectContext *contextLocal = [[NSManagedObjectContext alloc] init];
		[contextLocal setUndoManager:nil];
		
		PokerTrackerAppDelegate *appDelegate = (PokerTrackerAppDelegate *)[[UIApplication sharedApplication] delegate];
		[contextLocal setPersistentStoreCoordinator:appDelegate.persistentStoreCoordinator];
		
	}
}

//- (IBAction) refreshPressed: (id) sender
//{
//	[self computeStats];
//}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [sectionTitles count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
		return nil;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if(multiDimentionalValues==nil || [multiDimentionalValues count]==0)
		return 0;
    if(indexPath.section>=[multiDimentionalValues count])
        return 0;
    
	int NumberOfRows=(int)[[multiDimentionalValues objectAtIndex:indexPath.section] count];
	return 25+(NumberOfRows*18);
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return CGFLOAT_MIN;
}


-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	return CGFLOAT_MIN;
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 1;
	
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if(multiDimentionalValues==nil || [multiDimentionalValues count]==0) {
        MultiLineDetailCellWordWrap *cell = (MultiLineDetailCellWordWrap *) [tableView dequeueReusableCellWithIdentifier:@"x"];
        if (cell == nil) {
            cell = [[MultiLineDetailCellWordWrap alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"x" withRows:0 labelProportion:0.4];
        }
        return cell;
    }
    NSArray *listOfObjects = nil;
    if(topSegment.selectedSegmentIndex==0)
        listOfObjects = [multiDimentionalValues0 objectAtIndex:indexPath.section];
    if(topSegment.selectedSegmentIndex==1)
        listOfObjects = [multiDimentionalValues1 objectAtIndex:indexPath.section];
    if(topSegment.selectedSegmentIndex==2)
        listOfObjects = [multiDimentionalValues2 objectAtIndex:indexPath.section];
    
//	NSArray *listOfObjects = [multiDimentionalValues objectAtIndex:indexPath.section];
	NSArray *sortedArray = [ProjectFunctions sortArrayDescending:listOfObjects];
																	
	int NumberOfRows=(int)[listOfObjects count];
	NSString *cellIdentifier = [NSString stringWithFormat:@"cellIdentifierSection%dRow%drows%d", (int)indexPath.section, (int)indexPath.row, NumberOfRows];
	MultiLineDetailCellWordWrap *cell = (MultiLineDetailCellWordWrap *) [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (cell == nil) {
		cell = [[MultiLineDetailCellWordWrap alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier withRows:NumberOfRows labelProportion:0.4];
	}
	cell.mainTitle = [[sectionTitles stringAtIndex:(int)indexPath.section] capitalizedString];
	NSArray *filterOptions = [NSArray arrayWithObjects:NSLocalizedString(@"Profit", nil), NSLocalizedString(@"Hourly", nil), NSLocalizedString(@"Games", nil), nil];
	cell.alternateTitle = [filterOptions stringAtIndex:(int)topSegment.selectedSegmentIndex];
	
	NSMutableArray *titles = [[NSMutableArray alloc] init];
	NSMutableArray *values = [[NSMutableArray alloc] init];
	NSMutableArray *colors = [[NSMutableArray alloc] init];

	for(NSString *line in sortedArray) {
		NSArray *components = [line componentsSeparatedByString:@"|"];
		NSString *title = [components stringAtIndex:1];
		NSString *primaryTxt=@"";
		NSString *secondaryTxt=@"";
		double primaryValue = [[components stringAtIndex:0] doubleValue]-50000000;
		int secondaryValue = [[components stringAtIndex:2] intValue];
		double colorVal = primaryValue;
		NSString *gameTxt = (secondaryValue==1)?@"Game":@"Games";
		NSString *hourTxt = (secondaryValue==1)?@"Hour":@"Hours";
		if(topSegment.selectedSegmentIndex==0) {
			primaryTxt = [NSString stringWithFormat:@"%@", [ProjectFunctions convertIntToMoneyString:primaryValue]];
			secondaryTxt = [NSString stringWithFormat:@"(%d %@)", secondaryValue, gameTxt];
		}
		if(topSegment.selectedSegmentIndex==1) {
			primaryTxt = [NSString stringWithFormat:@"%@/hr", [ProjectFunctions convertIntToMoneyString:primaryValue]];
			secondaryTxt = [NSString stringWithFormat:@"(%d %@)", secondaryValue, hourTxt];
		}
		if(topSegment.selectedSegmentIndex==2) {
			NSString *gameTxt = (primaryValue==1)?@"Game":@"Games";
			primaryTxt = [NSString stringWithFormat:@"%d %@", (int)primaryValue, gameTxt];
			secondaryTxt = [NSString stringWithFormat:@"%@", [ProjectFunctions convertIntToMoneyString:secondaryValue]];
			colorVal = secondaryValue;
		}
		[titles addObject:title];
		if([[sectionTitles stringAtIndex:(int)indexPath.section] isEqualToString:NSLocalizedString(@"Tips", nil)]) {
			primaryTxt = [NSString stringWithFormat:@"%@", [ProjectFunctions convertIntToMoneyString:primaryValue+50000000]];
			secondaryTxt = [NSString stringWithFormat:@" (%d%% of profit)", secondaryValue];
		}
		
		[values addObject:[NSString stringWithFormat:@"%@ %@", primaryTxt, secondaryTxt]];
		[colors addObject:[CoreDataLib getFieldColor:colorVal]];
	}

	cell.titleTextArray = titles;
	cell.fieldTextArray = values;
	cell.fieldColorArray = colors;
	cell.selectionStyle = UITableViewCellSelectionStyleNone;

	return cell;
}		








@end
