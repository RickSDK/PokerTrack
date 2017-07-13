//
//  EditSegmentVC.m
//  PokerTracker
//
//  Created by Rick Medved on 7/6/17.
//
//

#import "EditSegmentVC.h"
#import "CoreDataLib.h"
#import "TextLineEnterVC.h"
#import "SelectionCell.h"

@interface EditSegmentVC ()

@end

@implementation EditSegmentVC

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.entity = [[NSString alloc] init];
	self.listDict = [[NSMutableDictionary alloc] init];
	self.list = [[NSMutableArray alloc] init];
	
	self.navigationItem.leftBarButtonItem = [ProjectFunctions UIBarButtonItemWithIcon:[NSString fontAwesomeIconStringForEnum:FATimes] target:self action:@selector(cancel:)];
	
	self.selectButton = [ProjectFunctions UIBarButtonItemWithIcon:[NSString fontAwesomeIconStringForEnum:FACheck] target:self action:@selector(save:)];
	self.navigationItem.rightBarButtonItem = self.selectButton;

	[self setTitle:NSLocalizedString(self.databaseField, nil)];
	self.entity = [self.databaseField uppercaseString];
	if ([@"tournamentType" isEqualToString:self.databaseField])
		self.entity = @"TOURNAMENT";

	[ProjectFunctions makeFAButton:self.deleteButton type:0 size:24];
	[ProjectFunctions makeFAButton:self.addButton type:1 size:24];
	[ProjectFunctions makeFAButton:self.editButton type:2 size:24];

	[self refreshFromDatabase];

}

-(void)refreshFromDatabase {
	[self.list removeAllObjects];
	[self.list addObjectsFromArray:[CoreDataLib getEntityNameList:self.entity mOC:self.managedObjectContext]];
	NSArray *games = [CoreDataLib selectRowsFromTable:@"GAME" mOC:self.managedObjectContext];
	NSString *field = [self.entity lowercaseString];
	if([@"tournament" isEqualToString:field])
		field = @"tournamentType";
	for (NSString *key in self.list) {
		[self.listDict setValue:@"0" forKey:key];
	}
	for (NSManagedObject *mo in games) {
		NSString *type = [mo valueForKey:field];
		int count = [[self.listDict valueForKey:type] intValue];
		count++;
		[self.listDict setValue:[NSString stringWithFormat:@"%d", count] forKey:type];
	}
	[self sortDict:self.listDict field:field];
	[self setupData];
}

-(void)sortDict:(NSMutableDictionary *)dict field:(NSString *)field {
	NSMutableArray *array = [[NSMutableArray alloc] init];
	NSArray *keys = [dict allKeys];
	for (NSString *key in keys) {
		int count = [[dict valueForKey:key] intValue];
		[array addObject:[NSString stringWithFormat:@"%d:%@", count+100, key]];
	}
	NSArray *sortedArray = [ProjectFunctions sortArrayDescending:array];
	NSString *finalList = [sortedArray componentsJoinedByString:@"|"];
	[ProjectFunctions setUserDefaultValue:finalList forKey:[NSString stringWithFormat:@"%@Segments", field]];
}

-(void)setupData {
	self.editButton.enabled=self.optionSelectedFlg;
	self.deleteButton.enabled=self.optionSelectedFlg;
	self.selectButton.enabled=self.optionSelectedFlg;
	[self.mainTableView reloadData];
}


- (IBAction)deleteButtonPressed:(id)sender {
	int numGames = [[self.listDict valueForKey:[self.list objectAtIndex:self.rowNum]] intValue];
	if (numGames>0) {
		[ProjectFunctions showAlertPopup:NSLocalizedString(@"notice", nil) message:@"There already exists games with this entry. You cannot edit or delete it."];
		return;
	}
	[ProjectFunctions showConfirmationPopup:@"Delete this entry?" message:@"" delegate:self tag:1];
	
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if(buttonIndex != alertView.cancelButtonIndex) {
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name = %@", [self.list objectAtIndex:self.rowNum]];
		NSArray *records = [CoreDataLib selectRowsFromEntity:self.entity predicate:predicate sortColumn:nil mOC:self.managedObjectContext ascendingFlg:NO];
		if(records.count>0) {
			NSManagedObject *mo = [records objectAtIndex:0];
			[self.managedObjectContext deleteObject:mo];
			[self.managedObjectContext save:nil];
			[ProjectFunctions showAlertPopup:@"Success!" message:@""];
			self.optionSelectedFlg=NO;
			[self refreshFromDatabase];
		}
	}
}

- (IBAction)editButtonPressed:(id)sender {
	int numGames = [[self.listDict valueForKey:[self.list objectAtIndex:self.rowNum]] intValue];
	if (numGames>0) {
		[ProjectFunctions showAlertPopup:NSLocalizedString(@"notice", nil) message:@"There already exists games with this entry. You cannot edit or delete it."];
		return;
	}
	self.selectedAction = 1;
	TextLineEnterVC *detailViewController = [[TextLineEnterVC alloc] initWithNibName:@"TextLineEnterVC" bundle:nil];
	detailViewController.titleLabel = self.title;
	detailViewController.initialDateValue = [self.list objectAtIndex:self.rowNum];
	detailViewController.callBackViewController = self;
	[self.navigationController pushViewController:detailViewController animated:YES];
}

- (IBAction)addButtonPressed:(id)sender {
	self.selectedAction = 2;
	TextLineEnterVC *detailViewController = [[TextLineEnterVC alloc] initWithNibName:@"TextLineEnterVC" bundle:nil];
	detailViewController.titleLabel = self.title;
	detailViewController.initialDateValue = @"";
	detailViewController.callBackViewController = self;
	[self.navigationController pushViewController:detailViewController animated:YES];
}

-(void) setReturningValue:(NSString *) value {
	if (value.length==0) {
		[ProjectFunctions showAlertPopup:NSLocalizedString(@"notice", nil) message:@"Invalid entry!"];
		return;
	}
	for (NSString *item in self.list) {
		if ([item isEqualToString:value]) {
			[ProjectFunctions showAlertPopup:NSLocalizedString(@"notice", nil) message:@"That value already exists!"];
			return;
		}
	}
	NSString *scrubbed = [ProjectFunctions scrubRefData:value context:self.managedObjectContext];
	if (![scrubbed isEqualToString:value]) {
		[ProjectFunctions showAlertPopup:NSLocalizedString(@"notice", nil) message:@"That entry already exists!!!"];
		return;
	}
	self.initialDateValue = value;
	if (self.selectedAction==1) { // edit
		[self changeRefDataFrom:[self.list objectAtIndex:self.rowNum] newValue:value];
	}
	if (self.selectedAction==2) { // add
		[self addDataToList:value];
	}
}

-(void)addDataToList:(NSString *)value {
	[self.list addObject:value];
	self.optionSelectedFlg=YES;
	self.rowNum = (int)self.list.count-1;
	[self setupData];
}

-(void)changeRefDataFrom:(NSString *)oldValue newValue:(NSString *)newValue {
	NSArray *records = [CoreDataLib selectRowsFromTable:self.entity mOC:self.managedObjectContext];
	for(NSManagedObject *record in records) {
		if ([oldValue isEqualToString:[record valueForKey:@"name"]]) {
			[record setValue:newValue forKey:@"name"];
			[self.managedObjectContext save:nil];
		}
	}
	[self refreshFromDatabase];
}

- (IBAction)cancel:(id)sender {
	[self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)save:(id)sender {
	[(ProjectFunctions *)self.callBackViewController setReturningValue:[self.list objectAtIndex:self.rowNum]];
	[self.navigationController popViewControllerAnimated:YES];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	NSString *cellIdentifier = [NSString stringWithFormat:@"cellIdentifierSection%dRow%d", (int)indexPath.section, (int)indexPath.row];
	SelectionCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	
	if(cell==nil)
		cell = [[SelectionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
	int numGames = [[self.listDict valueForKey:[self.list objectAtIndex:indexPath.row]] intValue];
	NSString *name = [self.list objectAtIndex:indexPath.row];
	cell.textLabel.text=name;
	cell.selection.text=[NSString stringWithFormat:@"(%d %@)", numGames, NSLocalizedString(@"Games", nil)];
	cell.accessoryType= UITableViewCellAccessoryDisclosureIndicator;
	cell.backgroundColor = [UIColor whiteColor];
	if ([name isEqualToString:self.initialDateValue]) {
		self.optionSelectedFlg=YES;
		self.rowNum = (int)indexPath.row;
	}
	if (self.optionSelectedFlg && self.rowNum == indexPath.row) {
		cell.accessoryType= UITableViewCellAccessoryCheckmark;
		cell.backgroundColor = [UIColor colorWithRed:.9 green:1 blue:.9 alpha:1];
	}
	
	cell.selectionStyle = UITableViewCellSelectionStyleDefault;
	return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.list.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	self.initialDateValue = nil;
	self.optionSelectedFlg = YES;
	self.rowNum = (int)indexPath.row;
	[self setupData];
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return CGFLOAT_MIN;
}


-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 44;
}

@end
