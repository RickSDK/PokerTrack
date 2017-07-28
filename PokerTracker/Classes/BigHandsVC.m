//
//  BigHandsVC.m
//  PokerTracker
//
//  Created by Rick Medved on 10/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BigHandsVC.h"
#import "OddsCalculatorVC.h"
#import "CoreDataLib.h"
#import "QuadFieldTableViewCell.h"
#import "NSDate+ATTDate.h"
#import "BigHandsFormVC.h"
#import "ProjectFunctions.h"


@implementation BigHandsVC
@synthesize showMainMenuButton, bigHands, mainTableView;
@synthesize managedObjectContext;

#pragma mark -
#pragma mark View lifecycle

- (IBAction) createPressed: (id) sender 
{
	OddsCalculatorVC *detailViewController = [[OddsCalculatorVC alloc] initWithNibName:@"OddsCalculatorVC" bundle:nil];
	detailViewController.managedObjectContext = managedObjectContext;
	detailViewController.bigHandsFlag = YES;
	[self.navigationController pushViewController:detailViewController animated:YES];
}


-(void)mainMenuButtonClicked:(id)sender {
	[self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
}

- (void)viewDidLoad {
	[super viewDidLoad];
    [mainTableView setBackgroundView:nil];
	
	bigHands = [[NSMutableArray alloc] initWithArray:[CoreDataLib selectRowsFromTable:@"BIGHAND" mOC:managedObjectContext]];

	[self setTitle:@"Hand Tracker"];
	[self changeNavToIncludeType:37];
	
	if(showMainMenuButton) {
		self.navigationItem.leftBarButtonItem = [ProjectFunctions UIBarButtonItemWithIcon:[NSString fontAwesomeIconStringForEnum:FAHome] target:self action:@selector(mainMenuButtonClicked:)];
	}
	
	self.navigationItem.rightBarButtonItem = [ProjectFunctions UIBarButtonItemWithIcon:[NSString fontAwesomeIconStringForEnum:FAPlus] target:self action:@selector(createPressed:)];
}

- (IBAction) deleteButtonPressed: (id) sender {
	[ProjectFunctions showConfirmationPopup:@"Delete All Hands on Device?" message:@"You can re-import ones that are saved" delegate:self tag:1];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if(alertView.tag==1 && buttonIndex!=alertView.cancelButtonIndex) {
		NSArray *items = [CoreDataLib selectRowsFromEntity:@"BIGHAND" predicate:nil sortColumn:nil mOC:self.managedObjectContext ascendingFlg:NO];
		for(NSManagedObject *mo in items) {
			[self.managedObjectContext deleteObject:mo];
		}
		[self.managedObjectContext save:nil];
		[bigHands removeAllObjects];
		[self.mainTableView reloadData];
		[ProjectFunctions showAlertPopup:@"Hands Deletes" message:@""];
	}
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [bigHands count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *cellIdentifier = [NSString stringWithFormat:@"cellIdentifierSection%dRow%d", (int)indexPath.section, (int)indexPath.row];
    
    QuadFieldTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[QuadFieldTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
	
	NSManagedObject *mo = [bigHands objectAtIndex:indexPath.row];
	cell.aa.text = [mo valueForKey:@"name"];
	NSDate *gameDate = [mo valueForKey:@"gameDate"];
	cell.bb.text = [ProjectFunctions displayLocalFormatDate:gameDate showDay:YES showTime:NO];
	NSString *status = [mo valueForKey:@"winStatus"];
	cell.cc.text = status;
	cell.dd.text = [NSString stringWithFormat:@"%@%@", [ProjectFunctions getMoneySymbol], [mo valueForKey:@"potsize"]];
	if([status isEqualToString:@"Win"])
		cell.ccColor = [UIColor colorWithRed:0 green:.5 blue:0 alpha:1];
	if([status isEqualToString:@"Loss"])
		cell.ccColor = [UIColor redColor];
	if([status isEqualToString:@"Chop"])
		cell.ccColor = [UIColor orangeColor];

    cell.ddColor = [UIColor colorWithRed:0 green:.5 blue:0 alpha:1];
	cell.backgroundColor = [UIColor whiteColor];
	cell.accessoryType= UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if([self respondsToSelector:@selector(edgesForExtendedLayout)])
        [self setEdgesForExtendedLayout:UIRectEdgeBottom];
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSManagedObject *managedObject = [bigHands objectAtIndex:indexPath.row];
    BigHandsFormVC *detailViewController = [[BigHandsFormVC alloc] initWithNibName:@"BigHandsFormVC" bundle:nil];
	detailViewController.managedObjectContext = managedObjectContext;
	detailViewController.drilldown = YES;
	detailViewController.viewEditable = NO;
	detailViewController.mo = managedObject;
	detailViewController.numPlayers=2;
    [self.navigationController pushViewController:detailViewController animated:YES];
}


#pragma mark -
#pragma mark Memory management






@end

