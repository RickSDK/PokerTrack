//
//  FriendsVC.m
//  PokerTracker
//
//  Created by Rick Medved on 10/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FriendsVC.h"
#import "CoreDataLib.h"
#import "QuadFieldTableViewCell.h"
#import "HexWithImageCell.h"
#import "ProjectFunctions.h"
#import "LoginVC.h"
#import "FriendLocatorVC.h"
#import "NSDate+ATTDate.h"
#import "WebServicesFunctions.h"
#import "FriendDetailVC.h"
#import "MessageBox.h"
#import "UIColor+ATTColor.h"
#import "NSArray+ATTArray.h"
#import "FriendSampleVC.h"
#import "FriendInProgressVC.h"
#import "NSString+ATTString.h"
#import "UniverseTrackerVC.h"


@implementation FriendsVC
@synthesize managedObjectContext;
@synthesize refreshButton, autoSyncSwitch, refreshDateLabel, mboxButton;
@synthesize friendsList, mainTableView, mailCount, sampleButton;
@synthesize activityIndicator, textViewBG, activityLabel, activityPopup;
@synthesize timeSegment, categorySegment, updFlg, hasMailFlg;

-(void)mainMenuButtonClicked:(id)sender {
	[self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	[self setUpData];
}

- (IBAction) timeSegmentChanged: (id) sender 
{
	[self setUpData];
}

- (IBAction) categorySegmentChanged: (id) sender 
{
	[self setUpData];
}

- (IBAction) samplePressed: (id) sender
{
	FriendSampleVC *detailViewController = [[FriendSampleVC alloc] initWithNibName:@"FriendSampleVC" bundle:nil];
//	detailViewController.managedObjectContext = managedObjectContext;
	[self.navigationController pushViewController:detailViewController animated:YES];
}

- (IBAction)mailButtonClicked:(id)sender {
	if(updFlg)
		return;
	MessageBox *detailViewController = [[MessageBox alloc] initWithNibName:@"MessageBox" bundle:nil];
	detailViewController.managedObjectContext = managedObjectContext;
	[self.navigationController pushViewController:detailViewController animated:YES];
}

- (IBAction) universeButtonPressed: (id) sender
{
	if([ProjectFunctions getUserDefaultValue:@"userName"]) {
		UniverseTrackerVC *detailViewController = [[UniverseTrackerVC alloc] initWithNibName:@"UniverseTrackerVC" bundle:nil];
		detailViewController.managedObjectContext = managedObjectContext;
		[self.navigationController pushViewController:detailViewController animated:YES];
	} else {
		[ProjectFunctions showAlertPopup:@"Notice" message:@"You need to be signed in to use Universe Tracking. Once logged in you get to compare your results to others using this app!"];
	}
}

-(void)loginButtonClicked:(id)sender {
	if(updFlg)
		return;
	if([ProjectFunctions getUserDefaultValue:@"userName"]) {
		[ProjectFunctions setUserDefaultValue:nil forKey:@"emailAddress"];
		[ProjectFunctions setUserDefaultValue:nil forKey:@"userName"];
	}
	LoginVC *detailViewController = [[LoginVC alloc] initWithNibName:@"LoginVC" bundle:nil];
	detailViewController.managedObjectContext = managedObjectContext;
	[self.navigationController pushViewController:detailViewController animated:YES];
}

-(void)createPressed:(id)sender {
	if(updFlg)
		return;
	if([[ProjectFunctions getUserDefaultValue:@"lastSyncedDate"] isEqualToString:@"01/01/1990 12:00:00 AM"]) {
		[ProjectFunctions showAlertPopup:@"Sync Your Data" message:@"Press the 'Refresh' button to sync your data before adding a new friend."];
	} else {
		FriendLocatorVC *detailViewController = [[FriendLocatorVC alloc] initWithNibName:@"FriendLocatorVC" bundle:nil];
		detailViewController.managedObjectContext = managedObjectContext;
		[self.navigationController pushViewController:detailViewController animated:YES];
	}
}


- (IBAction) switchPressed: (id) sender 
{
	if(updFlg)
		return;
	if(autoSyncSwitch.on) {
		[ProjectFunctions setUserDefaultValue:@"on" forKey:@"autoSyncValue"];
		refreshButton.enabled=NO;
		[ProjectFunctions showAlertPopup:@"AutoSync On" message:@"Your games will automatically be synced every time you save a new game."];
	} else {
		refreshButton.enabled=YES;
		[ProjectFunctions setUserDefaultValue:@"off" forKey:@"autoSyncValue"];
		[ProjectFunctions showAlertPopup:@"AutoSync Off" message:@"Your games will only be synced when you press the 'Refresh' button on this screen."];
	}

}

-(NSString *)friendHardReset
{
	NSArray *nameList = [NSArray arrayWithObjects:@"Username", @"Password", nil];
	
	NSArray *valueList = [NSArray arrayWithObjects:[ProjectFunctions getUserDefaultValue:@"userName"], [ProjectFunctions getUserDefaultValue:@"password"], nil];
	NSString *webAddr = @"http://www.appdigity.com/poker/pokerFriendReset.php";
	return [WebServicesFunctions getResponseFromServerUsingPost:webAddr fieldList:nameList valueList:valueList];
}

-(void)backgroundProcess
{
	@autoreleasepool {

		if([friendsList count]==0 || autoSyncSwitch.on == NO) {
			NSString *response = [self friendHardReset];
			if([response isEqualToString:@"ok"])
				[ProjectFunctions syncDataWithServer:managedObjectContext delegate:self refreshDateLabel:refreshDateLabel];
		} else {
			NSArray *nameList = [NSArray arrayWithObjects:@"Username", @"Password", @"LastUpd", nil];
			NSDate *lastUpd = [[ProjectFunctions getUserDefaultValue:@"lastSyncedDate"] convertStringToDateWithFormat:nil];
			NSString *lastUpdDate = [lastUpd convertDateToStringWithFormat:@"MM/dd/yyyy HH:mm:ss"];
			
			NSArray *valueList = [NSArray arrayWithObjects:[ProjectFunctions getUserDefaultValue:@"userName"], [ProjectFunctions getUserDefaultValue:@"password"], lastUpdDate, nil];
			NSString *webAddr = @"http://www.appdigity.com/poker/pokerRefresh.php";
			NSString *responseStr = [WebServicesFunctions getResponseFromServerUsingPost:webAddr fieldList:nameList valueList:valueList];
  //      NSLog(@"%@", responseStr);
			if([responseStr length]>3) {
				[ProjectFunctions updateFriendRecords:managedObjectContext responseStr:responseStr delegate:self refreshDateLabel:refreshDateLabel];
			}
		}
		
		textViewBG.alpha=0;
		activityLabel.alpha=0;
		activityPopup.alpha=0;
		autoSyncSwitch.enabled=YES;
		mboxButton.enabled=hasMailFlg;
		self.updFlg=NO;
		[activityIndicator stopAnimating];

		[self setUpData];
	}
}

-(void)startBackgroundProcess
{
	if([friendsList count]==0 && [[ProjectFunctions getUserDefaultValue:@"lastSyncedDate"] length]==0)
		[ProjectFunctions setUserDefaultValue:@"01/01/1990 12:00:00 AM" forKey:@"lastSyncedDate"];
	
	[activityIndicator startAnimating];
	textViewBG.alpha=1;
	activityLabel.alpha=1;
	activityPopup.alpha=1;
	refreshButton.enabled=NO;
	autoSyncSwitch.enabled=NO;
	mboxButton.enabled=NO;
	self.updFlg=YES;
	
	[self performSelectorInBackground:@selector(backgroundProcess) withObject:nil];
}


- (IBAction) refreshPressed: (id) sender 
{
	[self startBackgroundProcess];
}

-(NSArray *)getFriends
{
	NSString *sortColumn = @"profitLast10";
	if(timeSegment.selectedSegmentIndex==0) {
		if(categorySegment.selectedSegmentIndex==1)
			sortColumn = @"hourlyLast10";
		if(categorySegment.selectedSegmentIndex==2)
			sortColumn = @"gamesLast10";
	} else if(timeSegment.selectedSegmentIndex==1) {
		if(categorySegment.selectedSegmentIndex==0)
			sortColumn = @"profitThisMonth";
		if(categorySegment.selectedSegmentIndex==1)
			sortColumn = @"hourlyThisMonth";
		if(categorySegment.selectedSegmentIndex==2)
			sortColumn = @"gamesThisMonth";
	} else {
		if(categorySegment.selectedSegmentIndex==0)
			sortColumn = @"profitThisYear";
		if(categorySegment.selectedSegmentIndex==1)
			sortColumn = @"hourlyThisYear";
		if(categorySegment.selectedSegmentIndex==2)
			sortColumn = @"gamesThisYear";
	}
	NSArray *items = [CoreDataLib selectRowsFromEntity:@"FRIEND" predicate:nil sortColumn:sortColumn mOC:managedObjectContext ascendingFlg:NO];
	return items;
}

-(void)setUpData
{
	[friendsList removeAllObjects];
	NSArray *items = [self getFriends];

	for(NSManagedObject *mo in items) {
		NSString *line = [NSString stringWithFormat:@"%@|%d|%@|%@|%d|%d|%d|%d|%d|%d|%d|%d|%d|%@|%@|%@|%d|%d|%d|%@", 
						  [mo valueForKey:@"name"],
						  [[mo valueForKey:@"user_id"] intValue],
						  [mo valueForKey:@"status"],
						  [[mo valueForKey:@"lastGameDate"] convertDateToStringWithFormat:@"short"],
						  [[mo valueForKey:@"profitLast10"] intValue],
						  [[mo valueForKey:@"profitThisMonth"] intValue],
						  [[mo valueForKey:@"profitThisYear"] intValue],
						  [[mo valueForKey:@"streakLast10"] intValue],
						  [[mo valueForKey:@"streakThisMonth"] intValue]
						  ,[[mo valueForKey:@"streakThisYear"] intValue]
						  ,[[mo valueForKey:@"hourlyLast10"] intValue]
						  ,[[mo valueForKey:@"hourlyThisMonth"] intValue]
						  ,[[mo valueForKey:@"hourlyThisYear"] intValue]
						  ,[mo valueForKey:@"gamesLast10"] 
						  ,[mo valueForKey:@"gamesThisMonth"] 
						  ,[mo valueForKey:@"gamesThisYear"]
						  ,[[mo valueForKey:@"attrib_01"] intValue]
						  ,[[mo valueForKey:@"attrib_02"] intValue]
						  ,[[mo valueForKey:@"attrib_03"] intValue]
						  ,[mo valueForKey:@"attrib_08"]
						  ];
		[friendsList addObject:line];
 //       NSLog(@"line: %@", line);
	}

	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"status = %@", nil];
	NSArray *mailItems = [CoreDataLib selectRowsFromEntity:@"MESSAGE" predicate:predicate sortColumn:nil mOC:managedObjectContext ascendingFlg:YES];
	int mailNum=(int)[mailItems count];
	self.hasMailFlg=NO;
	if(mailNum>0) {
		[mboxButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		[mboxButton setBackgroundImage:[UIImage imageNamed:@"blueButton.png"] forState:UIControlStateNormal];
		mboxButton.enabled=YES;
		self.hasMailFlg=YES;
	}
	mailCount.text=[NSString stringWithFormat:@"%d", mailNum];
	
	if([friendsList count]==0) {
		sampleButton.hidden=NO;
		mainTableView.backgroundColor = [UIColor colorWithRed:.9 green:.9 blue:.9 alpha:1];
	} else {
		mainTableView.backgroundColor = [UIColor clearColor];
		sampleButton.hidden=YES;
	}
	
	[mainTableView reloadData];

}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {

	[self setTitle:@"Friend Tracker"];
    [super viewDidLoad];

	textViewBG.alpha=0;
	activityLabel.alpha=0;
	activityPopup.alpha=0;

	friendsList = [[NSMutableArray alloc] init];

	if([[ProjectFunctions getUserDefaultValue:@"autoSyncValue"] isEqualToString:@"off"])
		autoSyncSwitch.on = NO;
	refreshDateLabel.text = [ProjectFunctions getUserDefaultValue:@"lastSyncedDate"];
	
	[refreshButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	[refreshButton setBackgroundImage:[UIImage imageNamed:@"yellowButton.png"] forState:UIControlStateNormal];

	[self setUpData];

	if([[ProjectFunctions getUserDefaultValue:@"userName"] length]>0) {
		UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(createPressed:)];
		self.navigationItem.rightBarButtonItem = addButton;
		refreshButton.enabled=YES;
		autoSyncSwitch.enabled=YES;
		mboxButton.enabled=YES;
		if(autoSyncSwitch.on == YES)
			[self startBackgroundProcess];
	} else {
		refreshButton.enabled=NO;
		autoSyncSwitch.enabled=NO;
		mboxButton.enabled=NO;
		[ProjectFunctions showAlertPopup:@"Notice" message:@"You must create a username before using this feature. Click the 'Login' button at the top of this screen to get started."];
		UIBarButtonItem *moreButton = [[UIBarButtonItem alloc] initWithTitle:@"Login" style:UIBarButtonItemStylePlain target:self action:@selector(loginButtonClicked:)];
		self.navigationItem.rightBarButtonItem = moreButton;
	}


	


}




- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if([friendsList count]==0)
		return @"Amazing Feature: Friend tracker allows you to view the last 10 games of everyone on your buddy list. It also ranks each player based on winnings and hourly rate.\n\nIt's a fun way to keep in contact with your poker friends.";
	else 
		return nil;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [friendsList count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 55;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return CGFLOAT_MIN;
}

-(int)getValueBasedOnSegment:(int)segment value1:(int)value1 value2:(int)value2 value3:(int)value3
{
	if(segment==0)
		return value1;
	else if(segment==1)
		return value2;
	else 
		return value3;
}

-(NSString *)getStringBasedOnSegment:(int)segment value1:(NSString *)value1 value2:(NSString *)value2 value3:(NSString *)value3
{
	if(segment==0)
		return value1;
	else if(segment==1)
		return value2;
	else 
		return value3;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *cellIdentifier = [NSString stringWithFormat:@"cellIdentifierSection%dRow%d", (int)indexPath.section, (int)indexPath.row];
    
    HexWithImageCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[HexWithImageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
	
	NSString *line = [friendsList objectAtIndex:indexPath.row];
	NSArray *components = [line componentsSeparatedByString:@"|"];
	
	NSString *name = [components stringAtIndex:0];
	int user_id = [[components stringAtIndex:1] intValue];
	if([name isEqualToString:@"lre"] && user_id==79)
		name = @"Lee";

	// Name-------
	cell.a1.text = [NSString stringWithFormat:@"#%d - %@", (int)indexPath.row+1, name];
	
	// Status/Date-------
	NSString *status = [components stringAtIndex:2];
	if([status isEqualToString:@"Request Pending"] || [status isEqualToString:@"Requested"])
		cell.b1.text = status;
	else
		cell.b1.text = [NSString stringWithFormat:@"Lst: %@", [components stringAtIndex:3]];
	cell.b1Color = [UIColor orangeColor];

	// Profit--------
	int profit = [[components stringAtIndex:4] intValue];
	if(timeSegment.selectedSegmentIndex==1)
		profit = [[components stringAtIndex:5] intValue];
	if(timeSegment.selectedSegmentIndex==2)
		profit = [[components stringAtIndex:6] intValue];
	
	cell.a2.text = [NSString stringWithFormat:@"%@", [ProjectFunctions convertIntToMoneyString:profit]];
	if(profit>=0)
		cell.a2Color = [UIColor colorWithRed:0 green:.5 blue:0 alpha:1];
	else 
		cell.a2Color = [UIColor redColor];


	//Streak
	int streak = [self getValueBasedOnSegment:(int)timeSegment.selectedSegmentIndex value1:[[components stringAtIndex:7] intValue] value2:[[components stringAtIndex:8] intValue] value3:[[components stringAtIndex:9] intValue]];
	cell.c2.text = [NSString stringWithFormat:@"stk: %@", [ProjectFunctions getWinLossStreakString:streak]];
	cell.c1Color = [UIColor blackColor];

	
	// Hourly
	int hourly = [[components stringAtIndex:10] intValue];
	if(timeSegment.selectedSegmentIndex==1)
		hourly = [[components stringAtIndex:11] intValue];
	if(timeSegment.selectedSegmentIndex==2)
		hourly = [[components stringAtIndex:12] intValue];
	
	cell.b2.text = [NSString stringWithFormat:@"%@%d/hr", [ProjectFunctions getMoneySymbol], hourly];
	if(hourly>=0)
		cell.b2Color = [UIColor colorWithRed:0 green:.5 blue:0 alpha:1];
	else 
		cell.b2Color = [UIColor redColor];
	
	cell.c1.text = [self getStringBasedOnSegment:(int)timeSegment.selectedSegmentIndex value1:[components stringAtIndex:13] value2:[components stringAtIndex:14] value3:[components stringAtIndex:15]];
	cell.c2Color = [UIColor blackColor];

	
	if(user_id>0) {
		cell.a1Color = [UIColor blackColor];
		cell.backgroundColor = [UIColor whiteColor];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		cell.selectionStyle = UITableViewCellSelectionStyleBlue;
	} else {
		cell.a1Color = [UIColor ATTBlue];
		cell.backgroundColor = [UIColor colorWithRed:1 green:1 blue:.9 alpha:1];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}

	if([status isEqualToString:@"Request Pending"] || [status isEqualToString:@"Requested"])
		cell.backgroundColor = [UIColor colorWithRed:.8 green:1 blue:.8 alpha:1];

	
	int moneyRisked = [[components stringAtIndex:16] intValue];
	if(timeSegment.selectedSegmentIndex==1)
		moneyRisked = [[components stringAtIndex:17] intValue];
	if(timeSegment.selectedSegmentIndex==1)
		moneyRisked = [[components stringAtIndex:18] intValue];

	cell.leftImageView.image = [ProjectFunctions getPlayerTypeImage:moneyRisked winnings:profit];
	
	if([[components stringAtIndex:19] isEqualToString:@"Y"]) {
		cell.backgroundColor = [UIColor yellowColor];
		cell.b1.text = @"Now Playing!";
		cell.b1Color = [UIColor redColor];
	}
	
    return cell;
}



#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if(![ProjectFunctions getUserDefaultValue:@"userName"])
		return;
	
	if(updFlg)
		return;
	
	NSManagedObject *mo = nil;
	NSArray *items = [self getFriends];
	if([items count]>indexPath.row)
		mo = [items objectAtIndex:indexPath.row];
	
	if([[mo valueForKey:@"attrib_08"] isEqualToString:@"Y"]) {
		FriendInProgressVC *detailViewController = [[FriendInProgressVC alloc] initWithNibName:@"FriendInProgressVC" bundle:nil];
		detailViewController.mo = mo;
		detailViewController.managedObjectContext = managedObjectContext;
		[self.navigationController pushViewController:detailViewController animated:YES];
		return;
	}

	if([[mo valueForKey:@"user_id"] intValue] >=0) {
		FriendDetailVC *detailViewController = [[FriendDetailVC alloc] initWithNibName:@"FriendDetailVC" bundle:nil];
		detailViewController.mo = mo;
		detailViewController.managedObjectContext = managedObjectContext;
		[self.navigationController pushViewController:detailViewController animated:YES];
	}
}




@end
