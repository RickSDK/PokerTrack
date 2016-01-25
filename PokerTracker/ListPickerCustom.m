//
//  ListPickerCustom.m
//  PokerTracker
//
//  Created by Rick Medved on 11/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ListPickerCustom.h"
#import "CoreDataLib.h"
#import "ProjectFunctions.h"


@implementation ListPickerCustom
@synthesize managedObjectContext, checkList;
@synthesize itemList, entityname, callBackViewController;

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self.itemList count];
}

- (IBAction)cancel:(id)sender {
	[self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)save:(id)sender {
	NSString *field = [self.entityname lowercaseString];
	if([field isEqualToString:@"game"])
		field = @"gametype";
	if([field isEqualToString:@"tournament type"])
		field = @"tournamentType";
	
	NSMutableArray *valueArray = [[NSMutableArray alloc] init];
	int i=0;
	for(NSString *check in self.checkList) {
		if([check isEqualToString:@"Y"])
			[valueArray addObject:[ProjectFunctions formatForDataBase:[self.itemList objectAtIndex:i]]];
		i++;
	}
	
	NSString *finalStr = [valueArray componentsJoinedByString:[NSString stringWithFormat:@"' OR %@ = '", field]];
	NSString *predStr = [NSString stringWithFormat:@" AND (%@ = '%@')", field, finalStr];
	NSString *checkmarkList = [self.checkList componentsJoinedByString:@"|"];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"type = %@ AND searchNum = 0", self.entityname];
	[CoreDataLib insertOrUpdateManagedObjectForEntity:@"SEARCH" valueList:[NSArray arrayWithObjects:self.entityname, predStr, @"", @"", checkmarkList, @"0", nil] mOC:managedObjectContext predicate:predicate];
	
	[ProjectFunctions setUserDefaultValue:@"*Custom*" forKey:@"returnValue"];
	[(ProjectFunctions *)callBackViewController setReturningValue:nil];
	[self.navigationController popViewControllerAnimated:YES];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *cellIdentifier = [NSString stringWithFormat:@"cellIdentifierSection%dRow%d", (int)indexPath.section, (int)indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
	cell.textLabel.text = [NSString stringWithFormat:@"%@", [self.itemList objectAtIndex:indexPath.row]];
	if([[self.checkList objectAtIndex:indexPath.row] isEqualToString:@"Y"]) {
		cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkmark.png"]];
	} else { 
		cell.accessoryView = nil;
	}
	cell.backgroundColor = [UIColor whiteColor];
	
	return cell;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.itemList = [[NSMutableArray alloc] initWithArray:[CoreDataLib getFieldList:self.entityname mOC:self.managedObjectContext addAllTypesFlg:NO]];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"type = %@ AND searchNum = 0", self.entityname];
	NSString *checkVals = [CoreDataLib getFieldValueForEntityWithPredicate:managedObjectContext entityName:@"SEARCH" field:@"checkmarkList" predicate:predicate indexPathRow:0];
	if([checkVals length]>0)
		self.checkList = [[NSMutableArray alloc] initWithArray:[checkVals componentsSeparatedByString:@"|"]];
	else {
		self.checkList = [[NSMutableArray alloc] init];
		for(int i=0; i<self.itemList.count; i++)
			[self.checkList addObject:@"N"];
	}
	
	[self setTitle:@"Custom Search"];
	
	UIBarButtonItem *modalButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancel:)];
	self.navigationItem.leftBarButtonItem = modalButton;
	
	UIBarButtonItem *selectButton = [[UIBarButtonItem alloc] initWithTitle:@"Select" style:UIBarButtonItemStyleBordered target:self action:@selector(save:)];
	self.navigationItem.rightBarButtonItem = selectButton;
	
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if([[self.checkList objectAtIndex:indexPath.row] isEqualToString:@"Y"])
		[self.checkList replaceObjectAtIndex:indexPath.row withObject:@"N"];
	else
		[self.checkList replaceObjectAtIndex:indexPath.row withObject:@"Y"];

	[tableView reloadData];
}






@end
