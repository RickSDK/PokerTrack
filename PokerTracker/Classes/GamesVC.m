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
#import "NewGameBuyin.h"
#import "GameInProgressVC.h"
#import "ActionCell.h"
#import "StatsPage.h"
#import "NSArray+ATTArray.h"
#import "GameGraphVC.h"
#import "BankrollsVC.h"
#import "PokerTrackerAppDelegate.h"
#import "GameCell.h"



#define kLeftLabelRation	0.4


@implementation GamesVC
@synthesize managedObjectContext;
@synthesize showMainMenuButton, moneyLabel, gamesLabel, activityIndicator, bankrollButton;
@synthesize displayYear, yearLabel, leftYear, rightYear, mainTableView, gamesList, gameTypeSegment, yearToolbar, bankRollSegment;


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
    //return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(BOOL)shouldAutorotate
{
    return YES;
}

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
	
	self.gamesList = [[NSMutableArray alloc] init];
	[self.mainTableView setBackgroundView:nil];
	[self setTitle:@"Games"];
	
	int minYear = [[ProjectFunctions getUserDefaultValue:@"minYear"] intValue];
	NSArray *allGames = [CoreDataLib selectRowsFromEntity:@"GAME" predicate:nil sortColumn:@"startTime" mOC:self.managedObjectContext ascendingFlg:YES];
	
	if([allGames count]>0) {
		NSManagedObject *firstGame = [allGames objectAtIndex:0];
		NSDate *startTime = [firstGame valueForKey:@"startTime"];
		int year1 = [[startTime convertDateToStringWithFormat:@"yyyy"] intValue];
		if(year1<minYear)
			[ProjectFunctions setUserDefaultValue:[startTime convertDateToStringWithFormat:@"yyyy"] forKey:@"minYear"];
	}
	
	[self.yearToolbar insertSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"greenGradWide.png"]] atIndex:0];
	[self.yearToolbar setTintColor:[UIColor colorWithRed:0 green:.5 blue:0 alpha:1]];
	
	[ProjectFunctions makeSegment:self.gameTypeSegment color:[UIColor colorWithRed:0 green:.5 blue:0 alpha:1]];
	
	[self.gameTypeSegment setWidth:60 forSegmentAtIndex:0];
	NSString *gameType = [ProjectFunctions labelForGameSegment:(int)self.gameTypeSegment.selectedSegmentIndex];
	if([gameType isEqualToString:@"Tournament"])
		self.gameTypeSegment.selectedSegmentIndex=2;
	if([gameType isEqualToString:@"Cash"])
		self.gameTypeSegment.selectedSegmentIndex=1;
	
	self.yearLabel.text = [NSString stringWithFormat:@"%d", self.displayYear];
	
	[ProjectFunctions resetTheYearSegmentBar:self.mainTableView displayYear:self.displayYear MoC:self.managedObjectContext leftButton:leftYear rightButton:rightYear displayYearLabel:self.yearLabel];
	
	
	if(showMainMenuButton) {
		UIBarButtonItem *homeButton = [[UIBarButtonItem alloc] initWithTitle:@"Main Menu" style:UIBarButtonItemStylePlain target:self action:@selector(mainMenuButtonClicked:)];
		self.navigationItem.leftBarButtonItem = homeButton;
	}
	
	UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(createPressed:)];
	self.navigationItem.rightBarButtonItem = addButton;
	
	[ProjectFunctions setFontColorForSegment:self.gameTypeSegment values:nil];
	
	int numBanks = [[ProjectFunctions getUserDefaultValue:@"numBanks"] intValue];
	
	self.bankrollButton.alpha=1;
	self.bankRollSegment.alpha=1;
	
	if(numBanks==0) {
		self.bankrollButton.alpha=0;
		self.bankRollSegment.alpha=0;
	}
	
	
	
}



-(void)yearChanged
{
	[ProjectFunctions resetTheYearSegmentBar:self.mainTableView displayYear:self.displayYear MoC:self.managedObjectContext leftButton:leftYear rightButton:rightYear displayYearLabel:self.yearLabel];
	[self computeStats];
}

- (IBAction) yearGoesUp: (id) sender
{
	self.displayYear = [rightYear.titleLabel.text intValue];
    self.yearLabel.text = [NSString stringWithFormat:@"%d", self.displayYear];
	[self yearChanged];
}
- (IBAction) yearGoesDown: (id) sender
{
	self.displayYear = [leftYear.titleLabel.text intValue];
    self.yearLabel.text = [NSString stringWithFormat:@"%d", self.displayYear];
	[self yearChanged];
}

-(IBAction) segmentChanged:(id)sender
{
	[ProjectFunctions setFontColorForSegment:self.gameTypeSegment values:nil];
	[self computeStats];
}

- (IBAction) createPressed: (id) sender
{
	if([ProjectFunctions isLiteVersion]) {
		NSArray *games = [CoreDataLib selectRowsFromTable:@"GAME" mOC:self.managedObjectContext];
        if([games count]>20) {
            [ProjectFunctions showAlertPopup:@"Lite Version Expired" message:@"Sorry, the lite version is only for trial purposes and has expired. Please purchase the full version at this time. You can export/import all your games by clicking 'More' from the main menu."];
            return;
        }
	}
	
	NewGameBuyin *detailViewController = [[NewGameBuyin alloc] initWithNibName:@"NewGameBuyin" bundle:nil];
	detailViewController.managedObjectContext = self.managedObjectContext;
	[self.navigationController pushViewController:detailViewController animated:YES];
}



-(void)calculateStats
{
	@autoreleasepool {
		self.fetchIsReady=NO;
		
		NSString *gameType = [ProjectFunctions labelForGameSegment:(int)self.gameTypeSegment.selectedSegmentIndex];
		NSPredicate *predicate = [ProjectFunctions getPredicateForFilter:[NSArray arrayWithObjects:[ProjectFunctions getYearString:self.displayYear], gameType, nil] mOC:self.managedObjectContext buttonNum:0];
		
		NSString *gameString = [CoreDataLib getGameStat:self.managedObjectContext dataField:@"games" predicate:predicate];
		NSString *labelStr = [NSString stringWithFormat:@"Games: %@", gameString];
		int winnings = [[CoreDataLib getGameStat:self.managedObjectContext dataField:@"winnings" predicate:predicate] intValue];
		[ProjectFunctions updateMoneyLabel:self.moneyLabel money:winnings];
		[self.gamesLabel performSelectorOnMainThread:@selector(setText: ) withObject:labelStr waitUntilDone:NO];

		/*
		
		
		
		NSArray *games = [CoreDataLib selectRowsFromEntity:@"GAME" predicate:predicate sortColumn:@"startTime" mOC:self.managedObjectContext ascendingFlg:NO];
		for(NSManagedObject *game in games) {
			NSDate *startTime = [game valueForKey:@"startTime"];
			float winnings = [[game valueForKey:@"winnings"] floatValue];
			[self.gamesList addObject:[NSString stringWithFormat:@"%@|%f", [startTime convertDateToStringWithFormat:nil], winnings]];
		}
		
		
		[self.activityIndicator stopAnimating];
		self.mainTableView.alpha=1;
		 */
		[self.mainTableView reloadData];
	}
}

-(NSManagedObject *)gameFromString:(NSString *)gameString localContext:(NSManagedObjectContext *)localContext {
	NSArray *components = [gameString componentsSeparatedByString:@"|"];
	NSDate *startTime = [[components objectAtIndex:0] convertStringToDateWithFormat:nil];
	float winnings = [[components objectAtIndex:1] floatValue];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"startTime >= %@ AND winnings = %f", startTime, winnings];
	NSArray *games = [CoreDataLib selectRowsFromEntity:@"GAME" predicate:predicate sortColumn:@"startTime" mOC:localContext ascendingFlg:NO];
	
	if(games.count>0)
		return [games objectAtIndex:0];
	else
		return nil;
}




- (void) computeStats
{
	
 //   [self.activityIndicator startAnimating];
 //   self.mainTableView.alpha=0;
 //   self.gamesLabel.text = @"-";
 //   self.moneyLabel.text = @"-";
//	[self.gamesList removeAllObjects];
	
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

-(void)mainMenuButtonClicked:(id)sender {
	[self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
}
-(void)statsButtonClicked:(id)sender {
	StatsPage *detailViewController = [[StatsPage alloc] initWithNibName:@"StatsPage" bundle:nil];
	detailViewController.managedObjectContext = self.managedObjectContext;
	detailViewController.gameType = [ProjectFunctions labelForGameSegment:(int)self.gameTypeSegment.selectedSegmentIndex];
	detailViewController.displayYear=self.displayYear;
	detailViewController.hideMainMenuButton=NO;
	[self.navigationController pushViewController:detailViewController animated:YES];
}




//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//    return 1;
//}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 44;
}



//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//	return [self.gamesList count];
//}


-(UIColor *)getFieldColor:(int)value
{
	if(value>0)
		return [UIColor colorWithRed:0 green:.5 blue:0 alpha:1];
	if(value<0)
		return [UIColor redColor];
	return [UIColor blackColor];
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

	
	NSManagedObject *mo = [self.fetchedResultsController objectAtIndexPath:indexPath];
	BOOL evenFlg=indexPath.row%2==0;
	NSString *cellIdentifier = [NSString stringWithFormat:@"cellIdentifierSection%ldRow%ld", (long)indexPath.section, (long)indexPath.row];
	GameCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (cell == nil) {
		cell = [[GameCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
	}
	
	NSString *type = [mo valueForKey:@"Type"];
	cell.nameLabel.text = [NSString stringWithFormat:@"%@ (%@)", [mo valueForKey:@"name"], [type substringToIndex:1]];
//	cell.dateLabel.text = [NSString stringWithFormat:@"%@", [[mo valueForKey:@"startTime"] convertDateToStringWithFormat:@"MM/dd/yyyy hh:mm a"]];
	cell.dateLabel.text = [NSString stringWithFormat:@"%@", [[mo valueForKey:@"startTime"] convertDateToStringWithFormat:@"MM/dd/yyyy ha"]];
	cell.hoursLabel.text = [NSString stringWithFormat:@"(%@ hrs)", [mo valueForKey:@"hours"]];
	cell.locationLabel.text = [mo valueForKey:@"location"];
	cell.locationLabel.textColor = [UIColor purpleColor];
	cell.profitLabel.text = [NSString stringWithFormat:@"%@", [ProjectFunctions convertIntToMoneyString:[[mo valueForKey:@"winnings"] intValue]]];
	int buyin = [[mo valueForKey:@"buyInAmount"] intValue];

	int rebuy = [[mo valueForKey:@"rebuyAmount"] intValue];
	int winnings = [[mo valueForKey:@"winnings"] intValue];
	if(winnings>=0)
		cell.profitLabel.textColor = [UIColor colorWithRed:0 green:.5 blue:0 alpha:1]; //<-- green
	else
		cell.profitLabel.textColor = [UIColor colorWithRed:.7 green:0 blue:0 alpha:1]; //<-- red
	
	if([[mo valueForKey:@"Type"] isEqualToString:@"Cash"]) {
		cell.nameLabel.textColor = [UIColor blackColor];
		cell.backgroundColor=(evenFlg)?[UIColor colorWithWhite:.9 alpha:1]:[UIColor whiteColor];
	} else {
		cell.nameLabel.textColor = [UIColor colorWithRed:0 green:0 blue:.6 alpha:1];
		cell.backgroundColor=(evenFlg)?[UIColor colorWithRed:217/255.0 green:223/255.0 blue:1 alpha:1.0]:[UIColor colorWithRed:237/255.0 green:243/255.0 blue:1 alpha:1.0];
	}
	
	cell.profitImageView.image = [ProjectFunctions getPlayerTypeImage:buyin+rebuy winnings:winnings];
	
	
	if([[mo valueForKey:@"status"] isEqualToString:@"In Progress"]) {
		cell.backgroundColor = [UIColor yellowColor];
		cell.profitLabel.text = @"In Progress";
		cell.profitLabel.textColor = [UIColor redColor];
	}
	
	
	
	
	return cell;

//	NSString *cellIdentifier = [NSString stringWithFormat:@"cellIdentifierSection%ldRow%ld", (long)indexPath.section, (long)indexPath.row];
	
	
//	return [ProjectFunctions getGameCell:[self gameFromString:[self.gamesList objectAtIndex:indexPath.row] localContext:self.managedObjectContext] CellIdentifier:cellIdentifier tableView:tableView evenFlg:indexPath.row%2==0];
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
	
	NSString *gameType = [ProjectFunctions labelForGameSegment:(int)self.gameTypeSegment.selectedSegmentIndex];
	NSPredicate *predicate = [ProjectFunctions getPredicateForFilter:[NSArray arrayWithObjects:[ProjectFunctions getYearString:self.displayYear], gameType, nil] mOC:self.managedObjectContext buttonNum:0];

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
//    NSManagedObject *mo = [self gameFromString:[self.gamesList objectAtIndex:indexPath.row] localContext:self.managedObjectContext];
	NSManagedObject *mo = [self.fetchedResultsController objectAtIndexPath:indexPath];
	NSLog(@"+++month: %@", [mo valueForKey:@"month"]);
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
