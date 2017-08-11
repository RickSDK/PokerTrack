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
#import "BigHandObj.h"
#import "BigHandCell.h"


@implementation BigHandsVC

#pragma mark -
#pragma mark View lifecycle

- (IBAction) createPressed: (id) sender 
{
	OddsCalculatorVC *detailViewController = [[OddsCalculatorVC alloc] initWithNibName:@"OddsCalculatorVC" bundle:nil];
	detailViewController.managedObjectContext = self.managedObjectContext;
	detailViewController.bigHandsFlag = YES;
	[self.navigationController pushViewController:detailViewController animated:YES];
}

- (void)viewDidLoad {
	[super viewDidLoad];

	[self setTitle:@"Hand Tracker"];
	[self changeNavToIncludeType:37];

	self.bottomView.hidden=YES;
	[self.mainArray addObjectsFromArray:[CoreDataLib selectRowsFromTable:@"BIGHAND" mOC:self.managedObjectContext]];
	
	self.navigationItem.rightBarButtonItem = [ProjectFunctions UIBarButtonItemWithIcon:[NSString fontAwesomeIconStringForEnum:FAPlus] target:self action:@selector(createPressed:)];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	NSLog(@"Here!!");
	if(self.touchesCount++>=4)
		self.bottomView.hidden=NO;
	
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
		[self.mainArray removeAllObjects];
		[self.mainTableView reloadData];
		[ProjectFunctions showAlertPopup:@"Hands Deletes" message:@""];
	}
}

#pragma mark -
#pragma mark Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.mainArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *cellIdentifier = [NSString stringWithFormat:@"cellIdentifierSection%dRow%d", (int)indexPath.section, (int)indexPath.row];
	
	NSManagedObject *mo = [self.mainArray objectAtIndex:indexPath.row];
	BigHandObj *obj = [BigHandObj objectFromMO:mo];
    return [BigHandCell cellForBigHand:obj cellIdentifier:cellIdentifier tableView:tableView];
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSManagedObject *managedObject = [self.mainArray objectAtIndex:indexPath.row];
    BigHandsFormVC *detailViewController = [[BigHandsFormVC alloc] initWithNibName:@"BigHandsFormVC" bundle:nil];
	detailViewController.managedObjectContext = self.managedObjectContext;
	detailViewController.drilldown = YES;
	detailViewController.viewEditable = NO;
	detailViewController.mo = managedObject;
	detailViewController.hideHomeButton=YES;
    [self.navigationController pushViewController:detailViewController animated:YES];
}
//149 lines

@end

