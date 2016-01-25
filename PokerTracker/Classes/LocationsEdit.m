//
//  LocationsEdit.m
//  PokerTracker
//
//  Created by Rick Medved on 1/17/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "LocationsEdit.h"
#import "CoreDataLib.h"
#import "ProjectFunctions.h"


@implementation LocationsEdit
@synthesize managedObjectContext, mainTableView;
@synthesize locations, checkBoxes, deleteButton;

-(void)mainMenuButtonClicked:(id)sender {
	[self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
}


-(void) loadData {
	[locations removeAllObjects];
	[checkBoxes removeAllObjects];
	
	[locations addObjectsFromArray:[CoreDataLib selectRowsFromTable:@"LOCATION" mOC:managedObjectContext]];
	for(int x=1; x<= [locations count]; x++)
		[checkBoxes addObject:@"U"];
	
	[mainTableView reloadData];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if(buttonIndex==1) {
		int x=0;
		for(NSManagedObject *mo in locations) {
			if([[checkBoxes objectAtIndex:x++] isEqualToString:@"C"]) {
				[managedObjectContext deleteObject:mo];
				[managedObjectContext save:nil];
			}
		}
		deleteButton.enabled=NO;

		UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] initWithTitle:@"Main Menu" style:UIBarButtonItemStylePlain target:self action:@selector(mainMenuButtonClicked:)];
		self.navigationItem.leftBarButtonItem = menuButton;

		[self loadData];
	}
}
- (IBAction) deletePressed: (id) sender
{
	[ProjectFunctions showConfirmationPopup:@"Confirmation" message:@"Are you sure you want to delete these locations?" delegate:self tag:1];
}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
    return [locations count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	NSString *cellIdentifier = [NSString stringWithFormat:@"cellIdentifierSection%dRow%d", (int)indexPath.section, (int)indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    // Configure the cell...
	NSManagedObject *mo = [locations objectAtIndex:indexPath.row];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"location = %@ and user_id = 0", [mo valueForKey:@"name"]];
	NSArray *items = [CoreDataLib selectRowsFromEntity:@"GAME" predicate:predicate sortColumn:nil mOC:managedObjectContext ascendingFlg:YES];
	cell.textLabel.text = [NSString stringWithFormat:@"%@ (%d records)", [mo valueForKey:@"name"], (int)[items count]];;
	if([[checkBoxes objectAtIndex:indexPath.row] isEqualToString:@"U"])
		cell.imageView.image = [UIImage imageNamed:@"UnSelectedCheckBox.png"];
	else 
		cell.imageView.image = [UIImage imageNamed:@"SelectedCheckBox.png"];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	deleteButton.enabled=YES;
	if([[checkBoxes objectAtIndex:indexPath.row] isEqualToString:@"U"])
		[checkBoxes replaceObjectAtIndex:indexPath.row withObject:@"C"];
	else
		[checkBoxes replaceObjectAtIndex:indexPath.row withObject:@"U"];
	
	[mainTableView reloadData];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if([self respondsToSelector:@selector(edgesForExtendedLayout)])
        [self setEdgesForExtendedLayout:UIRectEdgeBottom];
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	[self setTitle:@"Edit Locations"];
	
	locations = [[NSMutableArray alloc] init];
	checkBoxes = [[NSMutableArray alloc] init];
	
	deleteButton.enabled=NO;
	
	[self loadData];
}







@end
