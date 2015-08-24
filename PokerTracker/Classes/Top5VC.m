//
//  Top5VC.m
//  PokerTracker
//
//  Created by Rick Medved on 3/9/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "Top5VC.h"
#import "ProjectFunctions.h"
#import "CoreDataLib.h"
#import "GameInProgressVC.h"
#import "GameGraphVC.h"
#import "MainMenuVC.h"
#import "NSArray+ATTArray.h"


@implementation Top5VC
@synthesize managedObjectContext, mainTableView, bestGames, worstGames;

-(void)mainMenuButtonClicked:(id)sender {
//	MainMenuVC *detailViewController = [[MainMenuVC alloc] initWithNibName:@"MainMenuVC" bundle:nil];
//	detailViewController.managedObjectContext=managedObjectContext;
//	[self.navigationController pushViewController:detailViewController animated:YES];
//	[detailViewController release];
	[self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if([self respondsToSelector:@selector(edgesForExtendedLayout)])
        [self setEdgesForExtendedLayout:UIRectEdgeBottom];
}
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	[self setTitle:@"Top 5 Lists"];
	bestGames = [[NSMutableArray alloc] init];
	worstGames = [[NSMutableArray alloc] init];
	
    [mainTableView setBackgroundView:nil];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"winnings > 0 AND user_id = 0"];
	
	[bestGames addObjectsFromArray:[CoreDataLib selectRowsFromEntityWithLimit:@"GAME" predicate:predicate sortColumn:@"winnings" mOC:managedObjectContext ascendingFlg:NO limit:5]];
	NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"winnings < 0 AND user_id = 0"];
	[worstGames addObjectsFromArray:[CoreDataLib selectRowsFromEntityWithLimit:@"GAME" predicate:predicate2 sortColumn:@"winnings" mOC:managedObjectContext ascendingFlg:YES limit:5]];

	self.navigationItem.rightBarButtonItem = [ProjectFunctions navigationButtonWithTitle:@"Main Menu" selector:@selector(mainMenuButtonClicked:) target:self];

	
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	
	return 44;
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if(section==0)
		return [bestGames count];
	else 
		return [worstGames count];
}



- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	NSArray *titles = [NSArray arrayWithObjects:@"Top 5 Best Games", @"Top 5 Worst Games", @"x", nil];
	return [ProjectFunctions getViewForHeaderWithText:[titles stringAtIndex:(int)section]];
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return 44.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *cellIdentifier = [NSString stringWithFormat:@"cellIdentifierSection%dRow%d", indexPath.section, indexPath.row];
	
	if(indexPath.section==0)
		return [ProjectFunctions getGameCell:[bestGames objectAtIndex:indexPath.row] CellIdentifier:cellIdentifier tableView:tableView evenFlg:indexPath.row%2==0];
	else
		return [ProjectFunctions getGameCell:[worstGames objectAtIndex:indexPath.row] CellIdentifier:cellIdentifier tableView:tableView evenFlg:indexPath.row%2==0];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSManagedObject *mo = nil;
	if(indexPath.section==0)
		mo = [bestGames objectAtIndex:indexPath.row];
	else 
		mo = [worstGames objectAtIndex:indexPath.row];
	
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
