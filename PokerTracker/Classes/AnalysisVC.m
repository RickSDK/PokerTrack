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
@synthesize managedObjectContext, yearLabel, leftYear, rightYear, gameSegment, gameType, displayYear, activityIndicator, last10Flg;
@synthesize yearToolbar;
@synthesize last10Button, top5Button;
@synthesize playerBasicsArray, playerStatsArray, colorArray1, colorArray2, gRisked, gIncome, mainTableView;
@synthesize playerTypeLabel, bankRollSegment, bankrollButton, analysisText;



-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if([self respondsToSelector:@selector(edgesForExtendedLayout)])
        [self setEdgesForExtendedLayout:UIRectEdgeBottom];

    [ProjectFunctions setBankSegment:self.bankRollSegment];
    [self computeStats];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	[self setTitle:NSLocalizedString(@"Analysis", nil)];
	
	[self.mainTableView setBackgroundView:nil];
	
	
	self.playerBasicsArray = [[NSMutableArray alloc] initWithCapacity:10];
	self.playerStatsArray = [[NSMutableArray alloc] initWithCapacity:10];
	self.colorArray1 = [[NSMutableArray alloc] initWithCapacity:10];
	self.colorArray2 = [[NSMutableArray alloc] initWithCapacity:10];
	
	[ProjectFunctions addColorToButton:self.last10Button color:[UIColor colorWithRed:1 green:.8 blue:0 alpha:1]];
	
	yearLabel.text = [NSString stringWithFormat:@"%d", displayYear];
	if(last10Flg) {
		yearLabel.text = NSLocalizedString(@"Last10", nil);
		last10Button.enabled=NO;
		last10Button.hidden=YES;
	}
	
	self.gameType = @"All";
	
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
	
	[ProjectFunctions resetTheYearSegmentBar:nil displayYear:self.displayYear MoC:self.managedObjectContext leftButton:leftYear rightButton:rightYear displayYearLabel:yearLabel];
	
	[ProjectFunctions makeGameSegment:self.gameSegment color:[UIColor colorWithRed:0 green:.5 blue:0 alpha:1]];
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


- (void)computeStats
{
    
    self.mainTableView.alpha=.5;
	[activityIndicator startAnimating];
    gameSegment.enabled=NO;

    self.bankrollButton.enabled=NO;
    self.bankRollSegment.enabled=NO;
    self.leftYear.enabled=NO;
    self.rightYear.enabled=NO;
    
    [ProjectFunctions setFontColorForSegment:gameSegment values:nil];
    
    
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
        
        NSString *basicPred = [ProjectFunctions getBasicPredicateString:displayYear type:self.gameType];
        basicPred = [NSString stringWithFormat:@"%@ AND status = 'Completed'", basicPred];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:basicPred];
        int limit=0;
        if([yearLabel.text isEqualToString:NSLocalizedString(@"Last10", nil)])
            limit=10;
        
            
        NSString *analysis1 = [CoreDataLib getGameStatWithLimit:contextLocal dataField:@"analysis1" predicate:predicate limit:limit];
        NSArray *values = [analysis1 componentsSeparatedByString:@"|"];
        if([values count]<11) {
            [ProjectFunctions showAlertPopup:@"Error" message:@"Error with Stats"];
            return;
        }
        amountRisked = [[values stringAtIndex:0] doubleValue];
        foodDrinks = [[values stringAtIndex:1] intValue];
        tokes = [[values stringAtIndex:2] intValue];
        grosssIncome = [[values stringAtIndex:3] doubleValue];
        takehomeIncome = [[values stringAtIndex:4] doubleValue];
        netIncome = [[values stringAtIndex:5] doubleValue];
        hourlyRate = [[values stringAtIndex:6] intValue];
        gamesStr = [values stringAtIndex:7];
        riskedLabelStr = [values stringAtIndex:8];
        profitLabelStr = [values stringAtIndex:9];
        deviationLabelStr = [values stringAtIndex:10];
        
  
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
        [self.playerBasicsArray addObject:[NSString stringWithFormat:@"%@", [ProjectFunctions convertIntToMoneyString:netIncome]]];
        
        [self.colorArray1 addObject:[UIColor blackColor]];
        [self.colorArray1 addObject:[self addColorBasedOnValue:netIncome]];
        [self.colorArray1 addObject:[UIColor blackColor]];
        [self.colorArray1 addObject:[self addColorBasedOnValue:netIncome]];

   
        [self.playerStatsArray addObject:[NSString stringWithFormat:@"%@", gamesStr]];
        [self.playerStatsArray addObject:[NSString stringWithFormat:@"%@", [ProjectFunctions convertIntToMoneyString:amountRisked]]];
        [self.playerStatsArray addObject:[NSString stringWithFormat:@"%@", [ProjectFunctions convertIntToMoneyString:foodDrinks]]];
        [self.playerStatsArray addObject:[NSString stringWithFormat:@"%@", [ProjectFunctions convertIntToMoneyString:tokes]]];
        [self.playerStatsArray addObject:[NSString stringWithFormat:@"%@", [ProjectFunctions convertIntToMoneyString:grosssIncome]]];
        [self.playerStatsArray addObject:[NSString stringWithFormat:@"%@", [ProjectFunctions convertIntToMoneyString:netIncome]]];
        [self.playerStatsArray addObject:[NSString stringWithFormat:@"%@/hr", [ProjectFunctions convertIntToMoneyString:hourlyRate]]];
        [self.playerStatsArray addObject:riskedLabelStr];
        [self.playerStatsArray addObject:profitLabelStr];
        [self.playerStatsArray addObject:deviationLabelStr];
 
        [self.colorArray2 addObject:[UIColor blackColor]];
        [self.colorArray2 addObject:[UIColor blackColor]];
        [self.colorArray2 addObject:[UIColor blackColor]];
        [self.colorArray2 addObject:[UIColor blackColor]];
        [self.colorArray2 addObject:[self addColorBasedOnValue:grosssIncome]];
        [self.colorArray2 addObject:[self addColorBasedOnValue:netIncome]];
        [self.colorArray2 addObject:[self addColorBasedOnValue:netIncome]];
        [self.colorArray2 addObject:[UIColor blackColor]];
        [self.colorArray2 addObject:[self addColorBasedOnValue:netIncome]];
        [self.colorArray2 addObject:[UIColor blackColor]];


		self.analysisText = [AnalysisLib getAnalysisForPlayer:contextLocal predicate:predicate displayYear:displayYear gameType:self.gameType last10Flg:last10Flg amountRisked:amountRisked foodDrinks:foodDrinks tokes:tokes grosssIncome:grosssIncome takehomeIncome:takehomeIncome netIncome:netIncome limit:limit];
							 
        self.gRisked=amountRisked;
        self.gIncome=netIncome;
        
        [activityIndicator stopAnimating];
        self.mainTableView.alpha=1;
        [mainTableView reloadData];

        gameSegment.enabled=YES;
        self.bankrollButton.enabled=YES;
        self.bankRollSegment.enabled=YES;

        [self performSelectorOnMainThread:@selector(updateDisplay) withObject:nil waitUntilDone:NO];

	}
}

-(UIColor *)addColorBasedOnValue:(int)value {
    if(value>=0)
        return [UIColor colorWithRed:0 green:.5 blue:0 alpha:1];
    else
        return [UIColor redColor];
}

-(void)updateDisplay
{
	[ProjectFunctions resetTheYearSegmentBar:nil displayYear:displayYear MoC:managedObjectContext leftButton:leftYear rightButton:rightYear displayYearLabel:yearLabel];
}



-(void)yearChanged:(UIButton *)barButton
{
	self.displayYear = [barButton.titleLabel.text intValue];
    yearLabel.text = barButton.titleLabel.text;
    last10Button.enabled = YES;
	last10Button.hidden=NO;
	last10Flg=NO;
	
	[ProjectFunctions resetTheYearSegmentBar:nil displayYear:displayYear MoC:managedObjectContext leftButton:leftYear rightButton:rightYear displayYearLabel:yearLabel];
	
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

- (IBAction) segmentChanged: (id) sender {
	[self computeStats];
}


- (IBAction) gameSegmentChanged: (id) sender {
	[ProjectFunctions changeColorForGameBar:self.gameSegment];
	self.gameType = [ProjectFunctions labelForGameSegment:(int)gameSegment.selectedSegmentIndex];
	if(displayYear>0)
		yearLabel.text = [NSString stringWithFormat:@"%d", displayYear];
	else {
		yearLabel.text = NSLocalizedString(@"LifeTime", nil);
	}

	last10Flg=NO;
	[self computeStats];
}

-(void)top5ButtonClicked:(id)sender {
        Last10NewVC *detailViewController = [[Last10NewVC alloc] initWithNibName:@"Last10NewVC" bundle:nil];
        detailViewController.managedObjectContext = managedObjectContext;
        [self.navigationController pushViewController:detailViewController animated:YES];
}

- (IBAction) last10Pressed: (id) sender
{
 
	if(gameSegment.selectedSegmentIndex>0) {
		gameSegment.selectedSegmentIndex=0;
		[ProjectFunctions changeColorForGameBar:self.gameSegment];
	}
	yearLabel.text = NSLocalizedString(@"Last10", nil);
    [top5Button setTitle:NSLocalizedString(@"Last10", nil)];
    last10Button.enabled = NO;
	last10Button.hidden=YES;
	last10Flg=YES;
	self.displayYear=0;
    
	[ProjectFunctions resetTheYearSegmentBar:nil displayYear:displayYear MoC:self.managedObjectContext leftButton:leftYear rightButton:rightYear displayYearLabel:yearLabel];

	[self computeStats];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section==0) {
        return 20*4+20;
    }

    if(indexPath.section==1) {
        return 20*10+10;
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
        
        cell.alternateTitle = yearLabel.text;
        cell.titleTextArray = [NSArray arrayWithObjects:NSLocalizedString(@"Name", nil), @"ROI", @"Type", NSLocalizedString(@"Profit", nil), nil];
        if([self.playerBasicsArray count]==4) {
            cell.fieldTextArray = self.playerBasicsArray;
            cell.fieldColorArray = self.colorArray1;
        } else
            cell.fieldTextArray = [NSArray arrayWithObjects:NSLocalizedString(@"Name", nil), @"25", @"Grinder", @"$125", nil];
        cell.mainTitle = @"";
        cell.imageView.image = [ProjectFunctions getPlayerTypeImage:self.gRisked winnings:self.gIncome];
        
        cell.accessoryType= UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        return cell;
    } else if(indexPath.section==1) {
        MultiLineDetailCellWordWrap *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if(cell==nil)
            cell = [[MultiLineDetailCellWordWrap alloc] initWithStyle:UITableViewCellStyleDefault
                                                       reuseIdentifier:cellIdentifier
                                                              withRows:10
                                                       labelProportion:.45];
        

        cell.alternateTitle = yearLabel.text;
		
        cell.titleTextArray = [NSArray arrayWithObjects:NSLocalizedString(@"Games", nil), NSLocalizedString(@"Risked", nil), NSLocalizedString(@"foodDrink", nil), NSLocalizedString(@"Tips", nil), NSLocalizedString(@"IncomeTotal", nil), NSLocalizedString(@"Profit", nil), NSLocalizedString(@"Hourly", nil),
							   [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Average", nil), NSLocalizedString(@"Buyin", nil)],
							   [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Average", nil), NSLocalizedString(@"Profit", nil)],
							   @"Standard Deviation", nil];
        if([self.playerStatsArray count]>=10) {
            cell.fieldTextArray = self.playerStatsArray;
            cell.fieldColorArray = self.colorArray2;
        } else
            cell.fieldTextArray = [NSArray arrayWithObjects:NSLocalizedString(@"Name", nil), @"0", @"0", @"0", @"0", @"0", @"0", @"0", @"0", @"0", nil];
        cell.mainTitle = @"Stats";
        cell.accessoryType= UITableViewCellAccessoryNone;
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        return cell;
   } else { // section==2
        MultiLineDetailCellWordWrap *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if(cell==nil)
            cell = [[MultiLineDetailCellWordWrap alloc] initWithStyle:UITableViewCellStyleDefault
                                                       reuseIdentifier:cellIdentifier
                                                              withRows:1
                                                       labelProportion:0];
        
        cell.alternateTitle = yearLabel.text;
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
