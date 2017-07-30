//
//  GamesVC.m
//  PokerTracker
//
//  Created by Rick Medved on 10/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GamesVC.h"
#import "MultiLineDetailCellWordWrap.h"
#import "GameDetailsVC.h"
#import "CoreDataLib.h"
#import "QuadFieldTableViewCell.h"
#import "NSDate+ATTDate.h"
#import "NSString+ATTString.h"
#import "ProjectFunctions.h"
#import "GameInProgressVC.h"
#import "ActionCell.h"
#import "StatsPage.h"
#import "NSArray+ATTArray.h"
#import "GameGraphVC.h"
#import "BankrollsVC.h"
#import "PokerTrackerAppDelegate.h"
#import "GameCell.h"
#import "GameObj.h"
#import "UpgradeVC.h"
#import "StartNewGameVC.h"
#import "AnalysisDetailsVC.h"
#import "Last10NewVC.h"
#import "Top5VC.h"



#define kLeftLabelRation	0.4


@implementation GamesVC
@synthesize managedObjectContext;
@synthesize bankrollButton;
@synthesize mainTableView, gamesList, bankRollSegment;


-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	[ProjectFunctions setBankSegment:self.bankRollSegment];
	
	[self computeStats];
}


- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.gamesList = [[NSMutableArray alloc] init];
	[self.mainTableView setBackgroundView:nil];
	[self setTitle:NSLocalizedString(@"Games", nil)];
	[self changeNavToIncludeType:34];
	
	[ProjectFunctions makeFAButton:self.last10Button type:18 size:18 text:NSLocalizedString(@"Last10", nil)];
	[ProjectFunctions makeFAButton:self.top5Button type:19 size:18 text:NSLocalizedString(@"Top5", nil)];
	
	self.navigationItem.rightBarButtonItem = [ProjectFunctions UIBarButtonItemWithIcon:[NSString fontAwesomeIconStringForEnum:FAPlus] target:self action:@selector(createPressed:)];
	
	int numBanks = [[ProjectFunctions getUserDefaultValue:@"numBanks"] intValue];
	
	self.bankrollButton.alpha=1;
	self.bankRollSegment.alpha=1;
	
	if(numBanks==0) {
		self.bankrollButton.alpha=0;
		self.bankRollSegment.alpha=0;
	}

	[self.gameSummaryView addTarget:@selector(gotoAnalysis) target:self];

	if([ProjectFunctions getUserDefaultValue:@"scrub2017"].length==0)
		[self scrubAllGames];
	
	
}

- (IBAction) top5Pressed: (id) sender {
	[self performSelector:@selector(gotoTop5) withObject:nil afterDelay:.1];
}
-(void)gotoTop5 {
	Top5VC *detailViewController = [[Top5VC alloc] initWithNibName:@"Top5VC" bundle:nil];
	detailViewController.managedObjectContext = managedObjectContext;
	[self.navigationController pushViewController:detailViewController animated:YES];
}
- (IBAction) last10Pressed: (id) sender {
	[self performSelector:@selector(gotoLast10) withObject:nil afterDelay:.1];
}
-(void)gotoLast10 {
	Last10NewVC *detailViewController = [[Last10NewVC alloc] initWithNibName:@"Last10NewVC" bundle:nil];
	detailViewController.managedObjectContext = managedObjectContext;
	[self.navigationController pushViewController:detailViewController animated:YES];
}

-(void)scrubAllGames {
	[ProjectFunctions setUserDefaultValue:@"Y" forKey:@"scrub2017"];
	[self.webServiceView startWithTitle:@"Scrubbing data"];
	[self performSelectorInBackground:@selector(scrubDataBG) withObject:nil];
}

-(void)scrubDataBG
{
	@autoreleasepool {
		NSManagedObjectContext *contextLocal = [[NSManagedObjectContext alloc] init];
		[contextLocal setUndoManager:nil];
		
		PokerTrackerAppDelegate *appDelegate = (PokerTrackerAppDelegate *)[[UIApplication sharedApplication] delegate];
		[contextLocal setPersistentStoreCoordinator:appDelegate.persistentStoreCoordinator];

		NSArray *games = [CoreDataLib selectRowsFromTable:@"GAME" mOC:self.managedObjectContext];
		for(NSManagedObject *mo in games) {
			[ProjectFunctions scrubDataForObj:mo context:self.managedObjectContext];
		}

		[self.webServiceView stop];
	}
}

-(IBAction) segmentChanged:(id)sender
{
	[ProjectFunctions changeColorForGameBar:self.ptpGameSegment];
	[self updateTitleForBar:self.ptpGameSegment title:@"Games" type:34];
	[self computeStats];
}

- (IBAction) createPressed: (id) sender
{
	if([ProjectFunctions isOkToProceed:self.managedObjectContext delegate:self]) {
		StartNewGameVC *detailViewController = [[StartNewGameVC alloc] initWithNibName:@"StartNewGameVC" bundle:nil];
		detailViewController.managedObjectContext = self.managedObjectContext;
		[self.navigationController pushViewController:detailViewController animated:YES];
	}
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if(alertView.tag==104 && buttonIndex != alertView.cancelButtonIndex) {
		UpgradeVC *detailViewController = [[UpgradeVC alloc] initWithNibName:@"UpgradeVC" bundle:nil];
		detailViewController.managedObjectContext = managedObjectContext;
		[self.navigationController pushViewController:detailViewController animated:YES];
	}
}

-(void)calculateStats
{
	@autoreleasepool {
		self.fetchIsReady=NO;
		
		NSString *gameType = [ProjectFunctions labelForGameSegment:(int)self.ptpGameSegment.selectedSegmentIndex];
		[self updateTitleForBar:self.ptpGameSegment title:@"Games" type:34];
		NSPredicate *predicate = [ProjectFunctions getPredicateForFilter:[NSArray arrayWithObjects:[ProjectFunctions getYearString:self.yearChangeView.statYear], gameType, nil] mOC:self.managedObjectContext buttonNum:0];
		NSArray *games = [CoreDataLib selectRowsFromEntity:@"GAME" predicate:predicate sortColumn:@"startTime" mOC:self.managedObjectContext ascendingFlg:YES];
		[self.gameSummaryView populateViewWithObj:[GameStatObj gameStatObjForGames:games]];
		[self.mainTableView reloadData];
	}
}

-(void)gotoAnalysis {
	AnalysisDetailsVC *detailViewController = [[AnalysisDetailsVC alloc] initWithNibName:@"AnalysisDetailsVC" bundle:nil];
	detailViewController.managedObjectContext = managedObjectContext;
	[self.navigationController pushViewController:detailViewController animated:YES];
}

- (IBAction) playerTypeButtonPressed: (id) sender {
	AnalysisDetailsVC *detailViewController = [[AnalysisDetailsVC alloc] initWithNibName:@"AnalysisDetailsVC" bundle:nil];
	detailViewController.managedObjectContext = managedObjectContext;
	[self.navigationController pushViewController:detailViewController animated:YES];
}

- (void) computeStats
{
	[self calculateStats];
}

- (IBAction) bankrollSegmentChanged: (id) sender
{
    [ProjectFunctions bankSegmentChangedTo:(int)self.bankRollSegment.selectedSegmentIndex];
    [self computeStats];
}

- (IBAction) bankrollPressed: (id) sender
{
	BankrollsVC *detailViewController = [[BankrollsVC alloc] initWithNibName:@"BankrollsVC" bundle:nil];
	detailViewController.managedObjectContext = self.managedObjectContext;
	detailViewController.callBackViewController = self;
	[self.navigationController pushViewController:detailViewController animated:YES];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 44;
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

	
	NSString *cellIdentifier = [NSString stringWithFormat:@"cellIdentifierSection%ldRow%ld", (long)indexPath.section, (long)indexPath.row];
	GameCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (cell == nil) {
		cell = [[GameCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
	}

	NSManagedObject *mo = [self.fetchedResultsController objectAtIndexPath:indexPath];
	[GameCell populateCell:cell obj:mo evenFlg:indexPath.row%2==0];
	[self checkToScrubDataForObj:mo context:self.managedObjectContext];
	
	return cell;

}

-(void)checkToScrubDataForObj:(NSManagedObject *)mo context:(NSManagedObjectContext *)context {
	NSString *daytime = [mo valueForKey:@"daytime"];
	NSString *daytime2 = [ProjectFunctions getDayTimeFromDate:[mo valueForKey:@"startTime"]];
	
	if (![daytime isEqualToString:daytime2])
		[ProjectFunctions setUserDefaultValue:@"" forKey:@"scrub2017"];
}
		 
- (NSFetchedResultsController *)fetchedResultsController
{
	if (_fetchedResultsController != nil && self.fetchIsReady) {
		return _fetchedResultsController;
	}
	self.fetchIsReady=YES;
	
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	// Edit the entity name as appropriate.
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"GAME" inManagedObjectContext:self.managedObjectContext];
	[fetchRequest setEntity:entity];
	


	// Set the batch size to a suitable number.
	[fetchRequest setFetchBatchSize:20];
	
	// Edit the sort key as appropriate.
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"startTime" ascending:NO];
	NSArray *sortDescriptors = @[sortDescriptor];
	[fetchRequest setSortDescriptors:sortDescriptors];
	
	NSString *gameType = [ProjectFunctions labelForGameSegment:(int)self.ptpGameSegment.selectedSegmentIndex];
	NSPredicate *predicate = [ProjectFunctions getPredicateForFilter:[NSArray arrayWithObjects:[ProjectFunctions getYearString:self.yearChangeView.statYear], gameType, nil] mOC:self.managedObjectContext buttonNum:0];

	[fetchRequest setPredicate:predicate];
	
	// Edit the section name key path and cache name if appropriate.
	// nil for section name key path means "no sections".
	NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Master"];
	aFetchedResultsController.delegate = self;
	
	[NSFetchedResultsController deleteCacheWithName:@"Master"];
	
	self.fetchedResultsController = aFetchedResultsController;
	
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
		// Replace this implementation with code to handle the error appropriately.
		// abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
//		abort();
	}
	
	return _fetchedResultsController;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
	return [sectionInfo numberOfObjects];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSManagedObject *mo = [self.fetchedResultsController objectAtIndexPath:indexPath];
    if([[mo valueForKey:@"status"] isEqualToString:@"In Progress"]) {
        GameInProgressVC *detailViewController = [[GameInProgressVC alloc] initWithNibName:@"GameInProgressVC" bundle:nil];
        detailViewController.managedObjectContext = self.managedObjectContext;
        detailViewController.mo = mo;
        detailViewController.newGameStated=NO;
        [self.navigationController pushViewController:detailViewController animated:YES];
    } else {
        GameGraphVC *detailViewController = [[GameGraphVC alloc] initWithNibName:@"GameGraphVC" bundle:nil];
        detailViewController.managedObjectContext = self.managedObjectContext;
        detailViewController.viewEditable = NO;
        detailViewController.mo = mo;
        [self.navigationController pushViewController:detailViewController animated:YES];
    }
}

@end
