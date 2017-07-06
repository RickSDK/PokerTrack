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

@interface Last10NewVC ()

@end

@implementation Last10NewVC
@synthesize managedObjectContext, mainTableView, bestGames, worstGames;

-(void)top5ButtonClicked:(id)sender {
    Top5VC *detailViewController = [[Top5VC alloc] initWithNibName:@"Top5VC" bundle:nil];
    detailViewController.managedObjectContext = managedObjectContext;
    [self.navigationController pushViewController:detailViewController animated:YES];
}

-(void)mainMenuButtonClicked:(id)sender {
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
	[self setTitle:NSLocalizedString(@"Last10", nil)];
	bestGames = [[NSMutableArray alloc] init];
	worstGames = [[NSMutableArray alloc] init];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"user_id = 0"];
    [self.mainTableView setBackgroundView:nil];
	
	[bestGames addObjectsFromArray:[CoreDataLib selectRowsFromEntityWithLimit:@"GAME" predicate:predicate sortColumn:@"startTime" mOC:managedObjectContext ascendingFlg:NO limit:10]];
    
	self.navigationItem.rightBarButtonItem = [ProjectFunctions navigationButtonWithTitle:NSLocalizedString(@"Main Menu", nil) selector:@selector(mainMenuButtonClicked:) target:self];

	
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}




- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	
	return 44;
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

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}



@end
