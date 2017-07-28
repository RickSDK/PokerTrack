//
//  FilterListVC.m
//  PokerTracker
//
//  Created by Rick Medved on 11/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FilterListVC.h"
#import "CoreDataLib.h"
#import "FiltersVC.h"
#import "FilterNameEnterVC.h"
#import "ProjectFunctions.h"
#import "SelectionCell.h"
#import "FilterObj.h"

@implementation FilterListVC
@synthesize managedObjectContext, filterList, callBackViewController, mainTableView, editMode, filterObj;
@synthesize editButton, filterSegment, selectedRowId, detailsButton, selectedButton, maxFilterId;


- (void)viewDidLoad {
	[super viewDidLoad];
	[self setTitle:NSLocalizedString(@"Filter List", nil)];
	[self changeNavToIncludeType:39];
	
	NSArray *filters = [CoreDataLib selectRowsFromEntity:@"FILTER" predicate:nil sortColumn:@"button" mOC:managedObjectContext ascendingFlg:YES];
	self.filterList = [[NSMutableArray alloc] initWithArray:filters];
	
	[ProjectFunctions makeFAButton:detailsButton type:33 size:24];
	[ProjectFunctions makeFAButton:editButton type:2 size:24];
	
	[ProjectFunctions makeSegment:self.filterSegment color:[UIColor colorWithRed:0 green:.5 blue:0 alpha:1]];

	self.navigationItem.rightBarButtonItem = [ProjectFunctions UIBarButtonItemWithIcon:[NSString fontAwesomeIconStringForEnum:FAInfoCircle] target:self action:@selector(popupButtonClicked)];
	
	self.popupView.titleLabel.text = self.title;
	self.popupView.textView.text = @"This is no limit to the number of filters you can have, but only 3 can appear on your custom filter bar. Be sure to keep the names short.\n\nThe ones that appear on the Filter Bar will be listed below as 'Tab 1', 'Tab 2' & 'Tab 3'.\n\nYou can edit the names on here, or return to the previous page to create a new filter.";
	self.popupView.textView.hidden=NO;

}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if([self respondsToSelector:@selector(edgesForExtendedLayout)])
        [self setEdgesForExtendedLayout:UIRectEdgeBottom];

	self.editButton.enabled=NO;
	self.detailsButton.enabled=NO;
	
	[self checkCustomSegment];
	
	[self reloadView];

}

-(void)checkCustomSegment
{
	for(int i=1; i<=3; i++) {
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"button = %d", i];
		NSArray *filters = [CoreDataLib selectRowsFromEntity:@"FILTER" predicate:predicate sortColumn:@"button" mOC:self.managedObjectContext ascendingFlg:YES];
		if([filters count]>0) {
			NSManagedObject *mo = [filters objectAtIndex:0];
			[self.filterSegment setTitle:[mo valueForKey:@"name"] forSegmentAtIndex:i];
		}
	}
	
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return CGFLOAT_MIN;
}

-(void)editMenuButtonClicked:(id)sender {
    self.editMode=!self.editMode;
    [self.mainTableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self.filterList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *CellIdentifier = [NSString stringWithFormat:@"cellIdentifierSection%dRow%d", (int)indexPath.section, (int)indexPath.row];
	SelectionCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[SelectionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
	}
	
	cell.backgroundColor = [UIColor whiteColor];
	cell.selectionStyle = UITableViewCellSelectionStyleBlue;
	NSManagedObject *mo = [self.filterList objectAtIndex:indexPath.row];
	FilterObj *obj = [FilterObj objectFromMO:mo];

	if(obj.button<=3 && obj.button>0)
		cell.selection.text = [NSString stringWithFormat:@"(Tab %d)", obj.button];

	cell.textLabel.text = obj.name;
	
	
    if(self.editMode) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
	
	return cell;
}

- (void)reloadView {
    [self.filterList removeAllObjects];
    [self.filterList addObjectsFromArray:[CoreDataLib selectRowsFromEntity:@"FILTER" predicate:nil sortColumn:@"button" mOC:managedObjectContext ascendingFlg:YES]];
    
    [self.mainTableView reloadData];
}

-(void) setReturningValue:(NSObject *) value2 {
    NSLog(@"+++%@", value2);
}

	
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	self.filterSegment.selectedSegmentIndex=0;
	self.filterObj = [self.filterList objectAtIndex:indexPath.row];
	self.selectedRowId = (int)indexPath.row;
	self.editButton.enabled=YES;
	self.detailsButton.enabled=YES;
	[(FiltersVC *)callBackViewController chooseFilterObj:self.filterObj];
	[self.navigationController popViewControllerAnimated:YES];
}

- (IBAction) detailsButtonPressed: (id) sender {
	[(FiltersVC *)callBackViewController chooseFilterObj:self.filterObj];
	[self.navigationController popViewControllerAnimated:YES];
}
- (IBAction) editButtonPressed: (id) sender {
	FilterNameEnterVC *detailViewController = [[FilterNameEnterVC alloc] initWithNibName:@"FilterNameEnterVC" bundle:nil];
	detailViewController.callBackViewController = self;
	detailViewController.managedObjectContext = managedObjectContext;
	detailViewController.filerObj=[self.filterList objectAtIndex:self.selectedRowId];
	[self.navigationController pushViewController:detailViewController animated:YES];
}




@end
