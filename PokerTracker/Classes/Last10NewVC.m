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
#import "AnalysisDetailsVC.h"
#import "GameStatObj.h"

@interface Last10NewVC ()

@end

@implementation Last10NewVC
@synthesize managedObjectContext, mainTableView;

- (void)viewDidLoad {
    [super viewDidLoad];
	[self setTitle:NSLocalizedString(@"Last10", nil)];
	[self changeNavToIncludeType:18];
	
	[self addHomeButton];

	[self.mainSegment turnIntoGameSegment];
	
	[self calculateStats];
}

-(void)calculateStats {
	[self.mainArray removeAllObjects];
	NSPredicate *predicate = [ProjectFunctions predicateForGameSegment:self.mainSegment];
	[self.mainArray addObjectsFromArray:[CoreDataLib selectRowsFromEntityWithLimit:@"GAME" predicate:predicate sortColumn:@"startTime" mOC:managedObjectContext ascendingFlg:NO limit:10]];
	[self.gameSummaryView populateViewWithObj:[GameStatObj gameStatObjForGames:self.mainArray]];
	[self.mainTableView reloadData];
}

-(IBAction)segmentChanged:(id)sender {
	[self.mainSegment gameSegmentChanged];
	[self calculateStats];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	return [ProjectFunctions getGameCell:[self.mainArray objectAtIndex:indexPath.row] CellIdentifier:[self cellId:indexPath] tableView:tableView evenFlg:indexPath.row%2==0];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[self gotoGame:[self.mainArray objectAtIndex:indexPath.row]];
}

@end
