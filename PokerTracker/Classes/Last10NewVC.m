//
//  Last10NewVC.m
//  PokerTracker
//
//  Created by Rick Medved on 12/11/12.
//
//

#import "Last10NewVC.h"
#import "ProjectFunctions.h"
#import "CoreDataLib.h"
#import "GameInProgressVC.h"
#import "GameGraphVC.h"
#import "MainMenuVC.h"
#import "NSArray+ATTArray.h"
#import "Top5VC.h"
#import "AnalysisDetailsVC.h"
#import "GameStatObj.h"

@interface Last10NewVC ()

@end

@implementation Last10NewVC
@synthesize managedObjectContext, mainTableView, bestGames;

-(void)top5ButtonClicked:(id)sender {
    Top5VC *detailViewController = [[Top5VC alloc] initWithNibName:@"Top5VC" bundle:nil];
    detailViewController.managedObjectContext = managedObjectContext;
    [self.navigationController pushViewController:detailViewController animated:YES];
}

-(void)mainMenuButtonClicked:(id)sender {
	[self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	[self setTitle:NSLocalizedString(@"Last10", nil)];
	bestGames = [[NSMutableArray alloc] init];
	
	self.navigationItem.rightBarButtonItem = [ProjectFunctions navigationButtonWithTitle:NSLocalizedString(@"Main Menu", nil) selector:@selector(mainMenuButtonClicked:) target:self];

	[self.mainSegment turnIntoGameSegment];
	
	[self.gameSummaryView addTarget:@selector(gotoAnalysis) target:self];
	
	[self calculateStats];
	
}

-(void)calculateStats {
	[bestGames removeAllObjects];
	NSPredicate *predicate = nil;
	if(self.mainSegment.selectedSegmentIndex>0) {
		NSString *gameType = [ProjectFunctions labelForGameSegment:(int)self.mainSegment.selectedSegmentIndex];
		predicate=[NSPredicate predicateWithFormat:@"user_id = 0 AND Type = %@", gameType];
	}
	[bestGames addObjectsFromArray:[CoreDataLib selectRowsFromEntityWithLimit:@"GAME" predicate:predicate sortColumn:@"startTime" mOC:managedObjectContext ascendingFlg:NO limit:10]];
	[self.gameSummaryView populateViewWithObj:[GameStatObj gameStatObjForGames:bestGames]];
	[self.mainTableView reloadData];
}

-(IBAction)segmentChanged:(id)sender {
	if(self.mainSegment.selectedSegmentIndex==0) {
		[self setTitle:NSLocalizedString(@"Games", nil)];
	}
	if(self.mainSegment.selectedSegmentIndex==1) {
		[self setTitle:NSLocalizedString(@"Cash Games", nil)];
	}
	if(self.mainSegment.selectedSegmentIndex==2) {
		[self setTitle:NSLocalizedString(@"Tournaments", nil)];
	}
	[self.mainSegment gameSegmentChanged];
	[self calculateStats];
}

-(void)gotoAnalysis {
	AnalysisDetailsVC *detailViewController = [[AnalysisDetailsVC alloc] initWithNibName:@"AnalysisDetailsVC" bundle:nil];
	detailViewController.managedObjectContext = managedObjectContext;
	[self.navigationController pushViewController:detailViewController animated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [bestGames count];
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return CGFLOAT_MIN;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *cellIdentifier = [NSString stringWithFormat:@"cellIdentifierSection%dRow%d", (int)indexPath.section, (int)indexPath.row];
	
	return [ProjectFunctions getGameCell:[bestGames objectAtIndex:indexPath.row] CellIdentifier:cellIdentifier tableView:tableView evenFlg:indexPath.row%2==0];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSManagedObject *mo = [bestGames objectAtIndex:indexPath.row];
	
	if([[mo valueForKey:@"status"] isEqualToString:@"In Progress"]) {
		GameInProgressVC *detailViewController = [[GameInProgressVC alloc] initWithNibName:@"GameInProgressVC" bundle:nil];
		detailViewController.managedObjectContext = managedObjectContext;
		detailViewController.mo = mo;
		detailViewController.newGameStated=NO;
		[self.navigationController pushViewController:detailViewController animated:YES];
	} else {
		GameGraphVC *detailViewController = [[GameGraphVC alloc] initWithNibName:@"GameGraphVC" bundle:nil];
		detailViewController.managedObjectContext = managedObjectContext;
		detailViewController.viewEditable = NO;
		detailViewController.mo = mo;
		[self.navigationController pushViewController:detailViewController animated:YES];
	}
}

@end
