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
@synthesize topSegment, activityBGView, activityIndicator;
@synthesize displayYear, yearLabel, leftYear, rightYear, gameSegment, gameType, viewLocked, refreshButton, yearToolbar;
@synthesize multiDimentionalValues0, multiDimentionalValues1, multiDimentionalValues2, viewUnLoaded;
@synthesize bankRollSegment, bankrollButton;


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	sectionTitles = [[NSMutableArray alloc] init];
	multiDimentionalValues = [[NSMutableArray alloc] init];
	multiDimentionalValues0 = [[NSMutableArray alloc] init];
	multiDimentionalValues1 = [[NSMutableArray alloc] init];
	multiDimentionalValues2 = [[NSMutableArray alloc] init];
	self.viewLocked=NO;
	
	[self.mainTableView setBackgroundView:nil];
	
	self.gameType = @"All";
	
	[super viewDidLoad];
	[self setTitle:@"Reports"];
	
	yearLabel.text = [NSString stringWithFormat:@"%d", displayYear];
	
	self.navigationItem.rightBarButtonItem = [ProjectFunctions navigationButtonWithTitle:@"Main Menu" selector:@selector(mainMenuButtonClicked:) target:self];
	
	
	activityBGView.alpha=0;
	[yearToolbar insertSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"greenGradWide.png"]] atIndex:0];
	[yearToolbar setTintColor:[UIColor colorWithRed:0 green:.5 blue:0 alpha:1]];
	[gameSegment setTintColor:[UIColor colorWithRed:0 green:.5 blue:0 alpha:1]];
	
	
	[ProjectFunctions resetTheYearSegmentBar:mainTableView displayYear:displayYear MoC:self.managedObjectContext leftButton:leftYear rightButton:rightYear displayYearLabel:yearLabel];
	
	[gameSegment setWidth:60 forSegmentAtIndex:0];
	gameSegment.selectedSegmentIndex = [ProjectFunctions selectedSegmentForGameType:self.gameType];
	
	int numBanks = [[ProjectFunctions getUserDefaultValue:@"numBanks"] intValue];
	
	self.bankrollButton.alpha=1;
	self.bankRollSegment.alpha=1;
	
	if(numBanks==0) {
		self.bankrollButton.alpha=0;
		self.bankRollSegment.alpha=0;
	}
	
	refreshButton.enabled=NO;
	
	[ProjectFunctions makeSegment:self.gameSegment color:[UIColor colorWithRed:0 green:.5 blue:0 alpha:1]];
	[ProjectFunctions makeSegment:self.topSegment color:[UIColor colorWithRed:0 green:.5 blue:0 alpha:1]];
	
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if([self respondsToSelector:@selector(edgesForExtendedLayout)])
        [self setEdgesForExtendedLayout:UIRectEdgeBottom];

    [ProjectFunctions setBankSegment:self.bankRollSegment];
    [self computeStats];
}



-(void)yearChanged:(UIButton *)barButton
{
	self.displayYear = [barButton.titleLabel.text intValue];
    yearLabel.text = barButton.titleLabel.text;
	[ProjectFunctions resetTheYearSegmentBar:mainTableView displayYear:displayYear MoC:managedObjectContext leftButton:leftYear rightButton:rightYear displayYearLabel:yearLabel];
    
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

- (IBAction) yearGoesUp: (id) sender 
{
	[self yearChanged:rightYear];
}
- (IBAction) yearGoesDown: (id) sender
{
	[self yearChanged:leftYear];
}

- (IBAction) segmentChanged: (id) sender {
    [mainTableView reloadData];
}


- (IBAction) gameSegmentChanged: (id) sender {
	self.gameType = [ProjectFunctions labelForGameSegment:(int)gameSegment.selectedSegmentIndex];
	[self computeStats];
}

-(void)mainMenuButtonClicked:(id)sender {
	[self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
}

-(int)getPrimaryNumber:(int)winnings gameCount:(int)gameCount minutes:(int)minutes selectedSegmentIndex:(int)selectedSegmentIndex
{
//    int hours = minutes/60;
    float hoursFloat = (float)minutes/60;
    int hourlyRate = 0;
    if(hoursFloat>0)
        hourlyRate = (float)winnings/hoursFloat;
    int number=0;
    
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

- (void)computeStats
{
	[ProjectFunctions setFontColorForSegment:gameSegment values:nil];
	[activityIndicator startAnimating];
	activityBGView.alpha=1;
    leftYear.enabled=NO;
    rightYear.enabled=NO;
    gameSegment.enabled=NO;
    topSegment.enabled=NO;
    self.bankRollSegment.enabled=NO;
    self.bankrollButton.enabled=NO;
    mainTableView.alpha=0;
    
	
	[self performSelectorInBackground:@selector(doTheHardWork) withObject:nil];
}



-(void)doTheHardWork {
	@autoreleasepool {
		NSLog(@"doTheHardWork");
//    [NSThread sleepForTimeInterval:1];
    
        NSManagedObjectContext *contextLocal = [[NSManagedObjectContext alloc] init];
        [contextLocal setUndoManager:nil];
        
        PokerTrackerAppDelegate *appDelegate = (PokerTrackerAppDelegate *)[[UIApplication sharedApplication] delegate];
        [contextLocal setPersistentStoreCoordinator:appDelegate.persistentStoreCoordinator];

        
	[sectionTitles removeAllObjects];
	[multiDimentionalValues removeAllObjects];
	[multiDimentionalValues0 removeAllObjects];
	[multiDimentionalValues1 removeAllObjects];
	[multiDimentionalValues2 removeAllObjects];

	NSArray *sectionList = [NSArray arrayWithObjects:@"Type", @"gametype", @"location", @"stakes", @"limit", @"year", nil];
	NSString *basicPred = [ProjectFunctions getBasicPredicateString:displayYear type:self.gameType];
	for(NSString *sectionField in sectionList) {
		NSLog(@"sectionField: %@", sectionField);
		NSMutableArray *valueArray = [[NSMutableArray alloc] init];
		NSMutableArray *typeList = [[NSMutableArray alloc] init];
		NSMutableArray *valueArray0 = [[NSMutableArray alloc] init];
		NSMutableArray *valueArray1 = [[NSMutableArray alloc] init];
		NSMutableArray *valueArray2 = [[NSMutableArray alloc] init];
		
		NSArray *items = [CoreDataLib selectRowsFromTable:[sectionField uppercaseString] mOC:contextLocal];
		for(NSManagedObject *mo in items)
			[typeList addObject:[mo valueForKey:@"name"]];
		
		for(NSString *type in typeList) {
			NSString *predString = [NSString stringWithFormat:@"%@ AND %@ = %%@", basicPred, sectionField];
			NSPredicate *predicate = [NSPredicate predicateWithFormat:predString, type];
                NSString *chart1 = [CoreDataLib getGameStat:contextLocal dataField:@"chart1" predicate:predicate];
                NSArray *values = [chart1 componentsSeparatedByString:@"|"];
                int winnings = [[values stringAtIndex:0] intValue];
                int gameCount = [[values stringAtIndex:1] intValue];
                int minutes = [[values stringAtIndex:2] intValue];

			if(gameCount>0) {
				int primaryNumber = [self getPrimaryNumber:winnings gameCount:gameCount minutes:minutes selectedSegmentIndex:(int)topSegment.selectedSegmentIndex];
				int secondaryNumber = [self getSecondaryNumber:winnings gameCount:gameCount minutes:minutes selectedSegmentIndex:(int)topSegment.selectedSegmentIndex];
                    
				[valueArray addObject:[NSString stringWithFormat:@"%d|%@|%d", primaryNumber, type, secondaryNumber]];
				[valueArray0 addObject:[NSString stringWithFormat:@"%d|%@|%d", 
                                            [self getPrimaryNumber:winnings gameCount:gameCount minutes:minutes selectedSegmentIndex:0],
                                            type, 
                                            [self getSecondaryNumber:winnings gameCount:gameCount minutes:minutes selectedSegmentIndex:0]]];
				[valueArray1 addObject:[NSString stringWithFormat:@"%d|%@|%d", 
                                            [self getPrimaryNumber:winnings gameCount:gameCount minutes:minutes selectedSegmentIndex:1],
                                            type, 
                                            [self getSecondaryNumber:winnings gameCount:gameCount minutes:minutes selectedSegmentIndex:1]]];
				[valueArray2 addObject:[NSString stringWithFormat:@"%d|%@|%d", 
                                            [self getPrimaryNumber:winnings gameCount:gameCount minutes:minutes selectedSegmentIndex:2],
                                            type, 
                                            [self getSecondaryNumber:winnings gameCount:gameCount minutes:minutes selectedSegmentIndex:2]]];
			}
		}
		if([valueArray count]>0) {
			[sectionTitles addObject:sectionField];
			[multiDimentionalValues addObject:valueArray];
                [multiDimentionalValues0 addObject:valueArray0];
                [multiDimentionalValues1 addObject:valueArray1];
                [multiDimentionalValues2 addObject:valueArray2];
		}
	} // <-- for


        if([sectionTitles count]==0)
		[ProjectFunctions showAlertPopup:@"No Records" message:@"No results for that search"];

	activityBGView.alpha=0;


        mainTableView.alpha=1;
	[mainTableView reloadData];
	[self performSelectorInBackground:@selector(calcMoreStats) withObject:nil];
	 
	}
}

- (void)calcMoreStats
{
	@autoreleasepool {
		NSLog(@"calcMoreStats");
		[NSThread sleepForTimeInterval:1];
		NSManagedObjectContext *contextLocal = [[NSManagedObjectContext alloc] init];
        [contextLocal setUndoManager:nil];
        
        PokerTrackerAppDelegate *appDelegate = (PokerTrackerAppDelegate *)[[UIApplication sharedApplication] delegate];
        [contextLocal setPersistentStoreCoordinator:appDelegate.persistentStoreCoordinator];

 	NSString *basicPred = [ProjectFunctions getBasicPredicateString:displayYear type:self.gameType];
 
        NSPredicate *predicate = [NSPredicate predicateWithFormat:basicPred];
        
        [sectionTitles addObject:@"Dealer Tokes"];
        NSString *tokeString = [CoreDataLib getGameStat:contextLocal dataField:@"tokeString" predicate:predicate];
	[multiDimentionalValues addObject:[NSArray arrayWithObjects:tokeString, nil]];
	[multiDimentionalValues0 addObject:[NSArray arrayWithObjects:tokeString, nil]];
	[multiDimentionalValues1 addObject:[NSArray arrayWithObjects:tokeString, nil]];
	[multiDimentionalValues2 addObject:[NSArray arrayWithObjects:tokeString, nil]];
	
	if(1) {
		// weekdays
		NSMutableArray *valueArray = [[NSMutableArray alloc] init];
		NSMutableArray *valueArray0 = [[NSMutableArray alloc] init];
		NSMutableArray *valueArray1 = [[NSMutableArray alloc] init];
		NSMutableArray *valueArray2 = [[NSMutableArray alloc] init];
		NSArray *days = [NSArray arrayWithObjects:@"Monday", @"Tuesday", @"Wednesday", @"Thursday", @"Friday", @"Saturday", @"Sunday", nil];
		for(NSString *day in days) {
			NSString *predString = [NSString stringWithFormat:@"%@ AND weekday = '%@'", basicPred, day];
			NSPredicate *predicate = [NSPredicate predicateWithFormat:predString];
                NSString *chart1 = [CoreDataLib getGameStat:contextLocal dataField:@"chart1" predicate:predicate];
                NSArray *values = [chart1 componentsSeparatedByString:@"|"];
                int winnings = [[values stringAtIndex:0] intValue];
                int gameCount = [[values stringAtIndex:1] intValue];
                int minutes = [[values stringAtIndex:2] intValue];
                
			if(gameCount>0) {
				int primaryNumber = [self getPrimaryNumber:winnings gameCount:gameCount minutes:minutes selectedSegmentIndex:(int)topSegment.selectedSegmentIndex];
				int secondaryNumber = [self getSecondaryNumber:winnings gameCount:gameCount minutes:minutes selectedSegmentIndex:(int)topSegment.selectedSegmentIndex];
                    
				[valueArray addObject:[NSString stringWithFormat:@"%d|%@|%d", primaryNumber, day, secondaryNumber]];
				[valueArray0 addObject:[NSString stringWithFormat:@"%d|%@|%d", 
                                            [self getPrimaryNumber:winnings gameCount:gameCount minutes:minutes selectedSegmentIndex:0],
                                            day, 
                                            [self getSecondaryNumber:winnings gameCount:gameCount minutes:minutes selectedSegmentIndex:0]]];
				[valueArray1 addObject:[NSString stringWithFormat:@"%d|%@|%d", 
                                            [self getPrimaryNumber:winnings gameCount:gameCount minutes:minutes selectedSegmentIndex:1],
                                            day, 
                                            [self getSecondaryNumber:winnings gameCount:gameCount minutes:minutes selectedSegmentIndex:1]]];
				[valueArray2 addObject:[NSString stringWithFormat:@"%d|%@|%d", 
                                            [self getPrimaryNumber:winnings gameCount:gameCount minutes:minutes selectedSegmentIndex:2],
                                            day, 
                                            [self getSecondaryNumber:winnings gameCount:gameCount minutes:minutes selectedSegmentIndex:2]]];
			}
 		}
		[sectionTitles addObject:@"Weekdays"];
		[multiDimentionalValues addObject:valueArray];
		[multiDimentionalValues0 addObject:valueArray0];
		[multiDimentionalValues1 addObject:valueArray1];
		[multiDimentionalValues2 addObject:valueArray2];
	}
	
	if(1) {
		// months
		NSMutableArray *valueArray = [[NSMutableArray alloc] init];
		NSMutableArray *valueArray0 = [[NSMutableArray alloc] init];
		NSMutableArray *valueArray1 = [[NSMutableArray alloc] init];
		NSMutableArray *valueArray2 = [[NSMutableArray alloc] init];
		NSArray *days = [NSArray arrayWithObjects:@"January", @"February", @"March", @"April", @"May", @"June", @"July", @"August", @"September", @"October", @"November", @"December", nil];
		for(NSString *day in days) {
			NSString *predString = [NSString stringWithFormat:@"%@ AND month = '%@'", basicPred, day];
			NSPredicate *predicate = [NSPredicate predicateWithFormat:predString];
                NSString *chart1 = [CoreDataLib getGameStat:contextLocal dataField:@"chart1" predicate:predicate];
                NSArray *values = [chart1 componentsSeparatedByString:@"|"];
                int winnings = [[values stringAtIndex:0] intValue];
                int gameCount = [[values stringAtIndex:1] intValue];
                int minutes = [[values stringAtIndex:2] intValue];
                
			if(gameCount>0) {
				int primaryNumber = [self getPrimaryNumber:winnings gameCount:gameCount minutes:minutes selectedSegmentIndex:(int)topSegment.selectedSegmentIndex];
				int secondaryNumber = [self getSecondaryNumber:winnings gameCount:gameCount minutes:minutes selectedSegmentIndex:(int)topSegment.selectedSegmentIndex];
                    
				[valueArray addObject:[NSString stringWithFormat:@"%d|%@|%d", primaryNumber, day, secondaryNumber]];
				[valueArray0 addObject:[NSString stringWithFormat:@"%d|%@|%d", 
                                            [self getPrimaryNumber:winnings gameCount:gameCount minutes:minutes selectedSegmentIndex:0],
                                            day, 
                                            [self getSecondaryNumber:winnings gameCount:gameCount minutes:minutes selectedSegmentIndex:0]]];
				[valueArray1 addObject:[NSString stringWithFormat:@"%d|%@|%d", 
                                            [self getPrimaryNumber:winnings gameCount:gameCount minutes:minutes selectedSegmentIndex:1],
                                            day, 
                                            [self getSecondaryNumber:winnings gameCount:gameCount minutes:minutes selectedSegmentIndex:1]]];
				[valueArray2 addObject:[NSString stringWithFormat:@"%d|%@|%d", 
                                            [self getPrimaryNumber:winnings gameCount:gameCount minutes:minutes selectedSegmentIndex:2],
                                            day, 
                                            [self getSecondaryNumber:winnings gameCount:gameCount minutes:minutes selectedSegmentIndex:2]]];
			}
		}
		[sectionTitles addObject:@"Months"];
		[multiDimentionalValues addObject:valueArray];
		[multiDimentionalValues0 addObject:valueArray0];
		[multiDimentionalValues1 addObject:valueArray1];
		[multiDimentionalValues2 addObject:valueArray2];
	}
	

        if(1) {
		// daytime
		NSMutableArray *valueArray = [[NSMutableArray alloc] init];
		NSMutableArray *valueArray0 = [[NSMutableArray alloc] init];
		NSMutableArray *valueArray1 = [[NSMutableArray alloc] init];
		NSMutableArray *valueArray2 = [[NSMutableArray alloc] init];
		NSArray *days = [NSArray arrayWithObjects:@"Morning", @"Afternoon", @"Evening", @"Night", nil];
		for(NSString *day in days) {
			NSString *predString = [NSString stringWithFormat:@"%@ AND daytime = '%@'", basicPred, day];
			NSPredicate *predicate = [NSPredicate predicateWithFormat:predString];
                
                NSString *chart1 = [CoreDataLib getGameStat:contextLocal dataField:@"chart1" predicate:predicate];
                NSArray *values = [chart1 componentsSeparatedByString:@"|"];
                int winnings = [[values stringAtIndex:0] intValue];
                int gameCount = [[values stringAtIndex:1] intValue];
                int minutes = [[values stringAtIndex:2] intValue];
                
			if(gameCount>0) {
				int primaryNumber = [self getPrimaryNumber:winnings gameCount:gameCount minutes:minutes selectedSegmentIndex:(int)topSegment.selectedSegmentIndex];
				int secondaryNumber = [self getSecondaryNumber:winnings gameCount:gameCount minutes:minutes selectedSegmentIndex:(int)topSegment.selectedSegmentIndex];
                    
				[valueArray addObject:[NSString stringWithFormat:@"%d|%@|%d", primaryNumber, day, secondaryNumber]];
				[valueArray0 addObject:[NSString stringWithFormat:@"%d|%@|%d", 
                                            [self getPrimaryNumber:winnings gameCount:gameCount minutes:minutes selectedSegmentIndex:0],
                                            day, 
                                            [self getSecondaryNumber:winnings gameCount:gameCount minutes:minutes selectedSegmentIndex:0]]];
				[valueArray1 addObject:[NSString stringWithFormat:@"%d|%@|%d", 
                                            [self getPrimaryNumber:winnings gameCount:gameCount minutes:minutes selectedSegmentIndex:1],
                                            day, 
                                            [self getSecondaryNumber:winnings gameCount:gameCount minutes:minutes selectedSegmentIndex:1]]];
				[valueArray2 addObject:[NSString stringWithFormat:@"%d|%@|%d", 
                                            [self getPrimaryNumber:winnings gameCount:gameCount minutes:minutes selectedSegmentIndex:2],
                                            day, 
                                            [self getSecondaryNumber:winnings gameCount:gameCount minutes:minutes selectedSegmentIndex:2]]];
			}
		}
		[sectionTitles addObject:@"DayTime"];
		[multiDimentionalValues addObject:valueArray];
		[multiDimentionalValues0 addObject:valueArray0];
		[multiDimentionalValues1 addObject:valueArray1];
		[multiDimentionalValues2 addObject:valueArray2];
	}
        
		[activityIndicator stopAnimating];
		
		self.viewLocked=NO;
		refreshButton.enabled=YES;
		gameSegment.enabled=YES;
		topSegment.enabled=YES;
		
		[ProjectFunctions resetTheYearSegmentBar:mainTableView displayYear:displayYear MoC:contextLocal leftButton:leftYear rightButton:rightYear displayYearLabel:yearLabel];
		
		self.bankRollSegment.enabled=YES;
		self.bankrollButton.enabled=YES;
		NSLog(@"done");
		[mainTableView reloadData];
	}
}

- (IBAction) refreshPressed: (id) sender
{
	[self computeStats];
}

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
	NSArray *filterOptions = [NSArray arrayWithObjects:@"Total Money", @"Hourly", @"# Games", nil];
	cell.alternateTitle = [filterOptions stringAtIndex:(int)topSegment.selectedSegmentIndex];
	
	NSMutableArray *titles = [[NSMutableArray alloc] init];
	NSMutableArray *values = [[NSMutableArray alloc] init];
	NSMutableArray *colors = [[NSMutableArray alloc] init];

	for(NSString *line in sortedArray) {
		NSArray *components = [line componentsSeparatedByString:@"|"];
		NSString *title = [components stringAtIndex:1];
		NSString *primaryTxt=@"";
		NSString *secondaryTxt=@"";
		int primaryValue = [[components stringAtIndex:0] intValue]-50000000;
		int secondaryValue = [[components stringAtIndex:2] intValue];
		int colorVal = primaryValue;
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
			primaryTxt = [NSString stringWithFormat:@"%d %@", primaryValue, gameTxt];
			secondaryTxt = [NSString stringWithFormat:@"%@", [ProjectFunctions convertIntToMoneyString:secondaryValue]];
			colorVal = secondaryValue;
		}
		[titles addObject:title];
		if([[sectionTitles stringAtIndex:(int)indexPath.section] isEqualToString:@"Dealer Tokes"]) {
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
