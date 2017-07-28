//
//  AnalysisVC.m
//  PokerTracker
//
//  Created by Rick Medved on 2/7/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "AnalysisVC.h"
#import "ProjectFunctions.h"
#import "CoreDataLib.h"
#import "NSArray+ATTArray.h"
#import "AnalysisLib.h"
#import "AnalysisDetailsVC.h"
#import "Top5VC.h"
#import "Last10NewVC.h"
#import "PokerTrackerAppDelegate.h"
#import "NSDate+ATTDate.h"
#import "BankrollsVC.h"
#import "MultiLineDetailCellWordWrap.h"


@implementation AnalysisVC
@synthesize managedObjectContext, gameSegment, activityIndicator, last10Flg;
@synthesize yearToolbar;
@synthesize top5Button;
@synthesize playerBasicsArray, playerStatsArray, colorArray1, colorArray2, gRisked, gIncome, mainTableView;
@synthesize playerTypeLabel, bankRollSegment, bankrollButton, analysisText;



- (void)viewDidLoad {
	[super viewDidLoad];
	[self setTitle:NSLocalizedString(@"Analysis", nil)];
	[self changeNavToIncludeType:3];
	
	[self.mainTableView setBackgroundView:nil];
	
	
	self.playerBasicsArray = [[NSMutableArray alloc] initWithCapacity:10];
	self.playerStatsArray = [[NSMutableArray alloc] initWithCapacity:10];
	self.colorArray1 = [[NSMutableArray alloc] initWithCapacity:10];
	self.colorArray2 = [[NSMutableArray alloc] initWithCapacity:10];
	
	self.yearChangeView.yearLabel.text = NSLocalizedString(@"Last10", nil);
	self.last10Flg=YES;

	self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:
											   [ProjectFunctions UIBarButtonItemWithIcon:[NSString fontAwesomeIconStringForEnum:FAListOl] target:self action:@selector(top5ButtonClicked:)],
											   [ProjectFunctions UIBarButtonItemWithIcon:[NSString fontAwesomeIconStringForEnum:FABullseye] target:self action:@selector(last10Pressed)],
											   nil];

	self.navigationItem.rightBarButtonItem = [ProjectFunctions UIBarButtonItemWithIcon:[NSString fontAwesomeIconStringForEnum:FAListOl] target:self action:@selector(top5ButtonClicked:)];
	
	
	[yearToolbar insertSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"greenGradWide.png"]] atIndex:0];
	[yearToolbar setTintColor:[UIColor colorWithRed:0 green:.5 blue:0 alpha:1]];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"year = %d", [[[NSDate date] convertDateToStringWithFormat:@"yyyy"] intValue]];
	
	NSString *stats2 = [CoreDataLib getGameStat:self.managedObjectContext dataField:@"stats2" predicate:predicate];
	NSArray *stats = [stats2 componentsSeparatedByString:@"|"];
	if([stats count]>4) {
		NSLog(@"stats2: +++%@", stats2);
		[ProjectFunctions setUserDefaultValue:[stats stringAtIndex:4] forKey:@"longestWinStreak"];
		[ProjectFunctions setUserDefaultValue:[stats stringAtIndex:5] forKey:@"longestLoseStreak"];
	}
	
	int numBanks = [[ProjectFunctions getUserDefaultValue:@"numBanks"] intValue];
	
	
	if(numBanks==0) {
		self.bankrollButton.alpha=0;
		self.bankRollSegment.alpha=0;
	} else {
		self.bankrollButton.alpha=1;
		self.bankRollSegment.alpha=1;
	}
	self.multiCellObj = [MultiCellObj initWithTitle:@"Stats" altTitle:@"Last 10" labelPercent:.4];
}

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	if([self respondsToSelector:@selector(edgesForExtendedLayout)])
		[self setEdgesForExtendedLayout:UIRectEdgeBottom];
	
	[ProjectFunctions setBankSegment:self.bankRollSegment];
	[self computeStats];
}

- (IBAction) detailsButtonPressed: (id) sender
{
	AnalysisDetailsVC *detailViewController = [[AnalysisDetailsVC alloc] initWithNibName:@"AnalysisDetailsVC" bundle:nil];
	detailViewController.managedObjectContext = managedObjectContext;
	[self.navigationController pushViewController:detailViewController animated:YES];
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

-(void)calculateStats {
	[self computeStats];
}

- (void)computeStats
{
    
    self.mainTableView.alpha=.5;
	[activityIndicator startAnimating];

    self.bankrollButton.enabled=NO;
    self.bankRollSegment.enabled=NO;
	
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

        double amountRisked = 0;
        int foodDrinks = 0;
        int tokes = 0;
        double grosssIncome = 0;
        double takehomeIncome = 0;
        double netIncome = 0;
        int hourlyRate = 0;
        NSString *gamesStr = @"";
        NSString *riskedLabelStr = @"";
        NSString *profitLabelStr = @"";
        NSString *deviationLabelStr = @"";
		
		int limit=0;
		int year = self.yearChangeView.statYear;
		if([self.yearChangeView.yearLabel.text isEqualToString:NSLocalizedString(@"Last10", nil)]) {
			limit=10;
			year=0;
		}
		
		NSString *gameType = [ProjectFunctions labelForGameSegment:(int)gameSegment.selectedSegmentIndex];
        NSString *basicPred = [ProjectFunctions getBasicPredicateString:year type:gameType];
        basicPred = [NSString stringWithFormat:@"%@ AND status = 'Completed'", basicPred];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:basicPred];

		NSArray *games = nil;
		if(limit>0)
			games = [CoreDataLib selectRowsFromEntityWithLimit:@"GAME" predicate:predicate sortColumn:@"startTime" mOC:contextLocal ascendingFlg:NO limit:limit];
		else
			games = [CoreDataLib selectRowsFromEntity:@"GAME" predicate:predicate sortColumn:@"startTime" mOC:contextLocal ascendingFlg:NO];
		
		GameStatObj *gameStatObj = [GameStatObj gameStatObjDetailedForGames:games];
		amountRisked = gameStatObj.risked;
		foodDrinks = gameStatObj.foodDrinks;
		tokes = gameStatObj.tokes;
		grosssIncome = gameStatObj.grossIncome;
		takehomeIncome = gameStatObj.takehomeAmount;
		netIncome = gameStatObj.profit;
		hourlyRate = 0;
		gamesStr = gameStatObj.name;
		riskedLabelStr = @"-";
		profitLabelStr = @"-";
		if (gameStatObj.games>0) {
			riskedLabelStr = [ProjectFunctions convertNumberToMoneyString:gameStatObj.risked/gameStatObj.games];
			profitLabelStr = [ProjectFunctions convertNumberToMoneyString:gameStatObj.profit/gameStatObj.games];
		}
		deviationLabelStr = @"-";

        [self.playerBasicsArray removeAllObjects];
        [self.colorArray1 removeAllObjects];
        [self.colorArray2 removeAllObjects];
        [self.playerStatsArray removeAllObjects];
        
        int ppr = [ProjectFunctions calculatePprAmountRisked:amountRisked netIncome:netIncome];
        
        NSString *name = [ProjectFunctions getUserDefaultValue:@"firstName"];
        if([name length]==0)
            name = @"-";
        
        [self.playerBasicsArray addObject:[NSString stringWithFormat:@"%@", name]];
        [self.playerBasicsArray addObject:[NSString stringWithFormat:@"%d%%", ppr]];
        [self.playerBasicsArray addObject:[ProjectFunctions getPlayerTypelabel:amountRisked winnings:netIncome]];
        [self.playerBasicsArray addObject:gameStatObj.profitString];
        
        [self.colorArray1 addObject:[UIColor blackColor]];
        [self.colorArray1 addObject:[self addColorBasedOnValue:netIncome]];
        [self.colorArray1 addObject:[UIColor blackColor]];
        [self.colorArray1 addObject:[self addColorBasedOnValue:netIncome]];

		[self.multiCellObj removeAllObjects];
		[self.multiCellObj addBlackLineWithTitle:@"Games" value:gamesStr];
		[self.multiCellObj addBlackLineWithTitle:@"Risked" value:gameStatObj.riskedString];
		[self.multiCellObj addBlackLineWithTitle:@"foodDrink" value:[ProjectFunctions convertIntToMoneyString:foodDrinks]];
		[self.multiCellObj addBlackLineWithTitle:@"Tips" value:[ProjectFunctions convertIntToMoneyString:tokes]];
		[self.multiCellObj addMoneyLineWithTitle:@"IncomeTotal" amount:grosssIncome];
		[self.multiCellObj addMoneyLineWithTitle:@"Profit" amount:gameStatObj.profit];
		[self.multiCellObj addColoredLineWithTitle:@"Hourly" value:gameStatObj.hourly amount:gameStatObj.profit];
		[self.multiCellObj addBlackLineWithTitle:[NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Average", nil), NSLocalizedString(@"Buyin", nil)] value:riskedLabelStr];
		[self.multiCellObj addBlackLineWithTitle:[NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Average", nil), NSLocalizedString(@"Profit", nil)] value:profitLabelStr];
		[self.multiCellObj addBlackLineWithTitle:@"Streak" value:gameStatObj.streakReverse];
		
		self.analysisText = [AnalysisLib getAnalysisForPlayer:contextLocal predicate:predicate displayYear:self.yearChangeView.statYear gameType:gameType last10Flg:last10Flg amountRisked:gameStatObj.risked foodDrinks:foodDrinks tokes:tokes grosssIncome:grosssIncome takehomeIncome:takehomeIncome netIncome:gameStatObj.profit limit:limit];
							 
        self.gRisked=amountRisked;
        self.gIncome=netIncome;
        
        [activityIndicator stopAnimating];
        self.mainTableView.alpha=1;
        [mainTableView reloadData];

        self.bankrollButton.enabled=YES;
        self.bankRollSegment.enabled=YES;


	}
}

-(UIColor *)addColorBasedOnValue:(int)value {
    if(value>=0)
        return [UIColor colorWithRed:0 green:.5 blue:0 alpha:1];
    else
        return [UIColor redColor];
}

- (IBAction) segmentChanged: (id) sender {
	[self computeStats];
}

- (IBAction) gameSegmentChanged: (id) sender {
	[self.ptpGameSegment gameSegmentChanged];
	[self computeStats];
}

-(void)top5ButtonClicked:(id)sender {
        Last10NewVC *detailViewController = [[Last10NewVC alloc] initWithNibName:@"Last10NewVC" bundle:nil];
        detailViewController.managedObjectContext = managedObjectContext;
        [self.navigationController pushViewController:detailViewController animated:YES];
}

- (void)last10Pressed
{
	self.yearChangeView.yearLabel.text = NSLocalizedString(@"Last10", nil);
	last10Flg=YES;
	
	[self computeStats];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section==0) {
        return 20*4+20;
    }

    if(indexPath.section==1) {
		return [MultiLineDetailCellWordWrap heightForMultiCellObj:self.multiCellObj tableView:tableView];
//        return 20*10+10;
    }

    NSArray *data = [NSArray arrayWithObject:@"dummy"];
    if([self.analysisText length]>10)
        data = [NSArray arrayWithObject:self.analysisText];
    return [MultiLineDetailCellWordWrap cellHeightWithNoMainTitleForData:data
                                                               tableView:tableView
                                                    labelWidthProportion:0]+20;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

-(BOOL)shouldAutorotate
{
    return YES;
}


- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return CGFLOAT_MIN;
}


-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	return CGFLOAT_MIN;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *cellIdentifier = [NSString stringWithFormat:@"cellIdentifierSection%dRow%d", (int)indexPath.section, (int)indexPath.row];

    
    if(indexPath.section==0) {
        MultiLineDetailCellWordWrap *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if(cell==nil)
            cell = [[MultiLineDetailCellWordWrap alloc] initWithStyle:UITableViewCellStyleDefault
                                                       reuseIdentifier:cellIdentifier
                                                              withRows:4
                                                       labelProportion:.55];
        
        cell.alternateTitle = self.yearChangeView.yearLabel.text;
        cell.titleTextArray = [NSArray arrayWithObjects:NSLocalizedString(@"Name", nil), @"ROI", @"Type", NSLocalizedString(@"Profit", nil), nil];
        if([self.playerBasicsArray count]==4) {
            cell.fieldTextArray = self.playerBasicsArray;
            cell.fieldColorArray = self.colorArray1;
        } else
            cell.fieldTextArray = [NSArray arrayWithObjects:NSLocalizedString(@"Name", nil), @"25", @"Grinder", @"$125", nil];
        cell.mainTitle = @"";
        cell.leftImage.image = [ProjectFunctions getPlayerTypeImage:self.gRisked winnings:self.gIncome];
        
        cell.accessoryType= UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        return cell;
    } else if(indexPath.section==1) {
		self.multiCellObj.altTitle = self.yearChangeView.yearLabel.text;
		return [MultiLineDetailCellWordWrap multiCellForID:cellIdentifier obj:self.multiCellObj tableView:tableView];
   } else { // section==2
        MultiLineDetailCellWordWrap *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if(cell==nil)
            cell = [[MultiLineDetailCellWordWrap alloc] initWithStyle:UITableViewCellStyleDefault
                                                       reuseIdentifier:cellIdentifier
                                                              withRows:1
                                                       labelProportion:0];
        
        cell.alternateTitle = self.yearChangeView.yearLabel.text;
        cell.titleTextArray = [NSArray arrayWithObject:@""];
        cell.fieldTextArray = [NSArray arrayWithObject:@"Loading..."];
        cell.mainTitle = @"Analysis";
        
        if([self.analysisText length]>0)
            cell.fieldTextArray = [NSArray arrayWithObject:[NSString stringWithFormat:@"%@", self.analysisText]];
        cell.accessoryType= UITableViewCellAccessoryNone;
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        return cell;
    }
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section==0) {
        AnalysisDetailsVC *detailViewController = [[AnalysisDetailsVC alloc] initWithNibName:@"AnalysisDetailsVC" bundle:nil];
        detailViewController.managedObjectContext = managedObjectContext;
        [self.navigationController pushViewController:detailViewController animated:YES];
    }
}

@end
