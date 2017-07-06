//
//  FriendDetailVC.m
//  PokerTracker
//
//  Created by Rick Medved on 10/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FriendDetailVC.h"
#import "QuadFieldTableViewCell.h"
#import "MultiLineDetailCellWordWrap.h"
#import "NSDate+ATTDate.h"
#import "ProjectFunctions.h"
#import "CoreDataLib.h"
#import "GameDetailsVC.h"
#import "WebServicesFunctions.h"
#import "FriendSendMessage.h"
#import "NSArray+ATTArray.h"

//-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex

@implementation FriendDetailVC
@synthesize managedObjectContext, mo, mainTableView;
@synthesize yearSegment, displayYear, processForm, friendGames;
@synthesize activityIndicator, imageViewBG, activityLabel, removeButton, sendMessageButton, userLabel, emailLabel;

-(void)mainMenuButtonClicked:(id)sender {
	[self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
}


-(void)acceptNewFriend
{
	@autoreleasepool {
		NSArray *nameList = [NSArray arrayWithObjects:@"Username", @"Password", @"friend_id", nil];
		NSArray *valueList = [NSArray arrayWithObjects:[ProjectFunctions getUserDefaultValue:@"userName"], [ProjectFunctions getUserDefaultValue:@"password"], [mo valueForKey:@"user_id"], nil];
		NSString *webAddr = @"http://www.appdigity.com/poker/pokerAcceptFriend.php";
		NSString *responseStr = [WebServicesFunctions getResponseFromServerUsingPost:webAddr fieldList:nameList valueList:valueList];
		if([WebServicesFunctions validateStandardResponse:responseStr delegate:nil]) {
			NSString *name = [mo valueForKey:@"name"];
			[mo setValue:@"Active" forKey:@"status"];
			[managedObjectContext save:nil];
			self.processForm=95;
			[ProjectFunctions showAlertPopupWithDelegate:@"Success!" message:[NSString stringWithFormat:@"%@ Added.", name] delegate:self];
		}

		[activityIndicator stopAnimating];
		self.imageViewBG.alpha=0;
		self.activityLabel.alpha=0;
		[mainTableView reloadData];
	}
}

-(void)removeFriend
{
	@autoreleasepool {
		NSArray *nameList = [NSArray arrayWithObjects:@"Username", @"Password", @"friend_id", nil];
		NSArray *valueList = [NSArray arrayWithObjects:[ProjectFunctions getUserDefaultValue:@"userName"], [ProjectFunctions getUserDefaultValue:@"password"], [mo valueForKey:@"user_id"], nil];
		NSString *webAddr = @"http://www.appdigity.com/poker/pokerRemoveFriend.php";
		NSString *responseStr = [WebServicesFunctions getResponseFromServerUsingPost:webAddr fieldList:nameList valueList:valueList];
		if([WebServicesFunctions validateStandardResponse:responseStr delegate:nil]) {
			NSString *name = [mo valueForKey:@"name"];
			self.processForm=96;
			[ProjectFunctions showAlertPopupWithDelegate:@"Friend Removed" message:[NSString stringWithFormat:@"%@ has been removed.", name] delegate:self];
		}
		
		[activityIndicator stopAnimating];
		self.imageViewBG.alpha=0;
		self.activityLabel.alpha=0;
		[mainTableView reloadData];
	}
}

	

-(void)executeThreadedJob:(SEL)aSelector
{
	[activityIndicator startAnimating];
	self.imageViewBG.alpha=1;
	self.activityLabel.alpha=1;
	[self performSelectorInBackground:aSelector withObject:nil];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if(processForm==95)
		[self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
	if(processForm==98)
		mainTableView.alpha=0;
		
		
	if(processForm==96) {
		[managedObjectContext deleteObject:mo];
		[managedObjectContext save:nil];
		[self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
	}
	if(processForm==97 && buttonIndex==1) {
		[self executeThreadedJob:@selector(removeFriend)];
	}
	if(processForm==99) {
		self.processForm=0;
		if(buttonIndex==0) {
			[self executeThreadedJob:@selector(removeFriend)];
		} else {
			[self executeThreadedJob:@selector(acceptNewFriend)];
		}
	}

}
- (IBAction) removeButtonPressed: (id) sender
{
	self.processForm=97;
	[ProjectFunctions showConfirmationPopup:@"Remove this friend?" message:[NSString stringWithFormat:@"Are you sure you want to remove %@ from your account?", [mo valueForKey:@"name"]] delegate:self tag:1];
}

- (IBAction) messageButtonPressed: (id) sender 
{
	FriendSendMessage *detailViewController = [[FriendSendMessage alloc] initWithNibName:@"FriendSendMessage" bundle:nil];
	detailViewController.managedObjectContext = managedObjectContext;
	detailViewController.mo = mo;
	[self.navigationController pushViewController:detailViewController animated:YES];
}

- (IBAction) segmentChanged: (id) sender 
{
	int lastYear = [[[NSDate date] convertDateToStringWithFormat:@"yyyy"] intValue]-1;
	self.displayYear = lastYear + (int)yearSegment.selectedSegmentIndex;
	[mainTableView reloadData];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	
	friendGames = [[NSMutableArray alloc] init];
	self.displayYear = [[[NSDate date] convertDateToStringWithFormat:@"yyyy"] intValue];
	self.processForm=0;
	
	int user_id = [[mo valueForKey:@"user_id"] intValue];
	if(user_id==0)
		removeButton.enabled=NO;

	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"user_id = %d", user_id];
	[friendGames addObjectsFromArray:[CoreDataLib selectRowsFromEntityWithLimit:@"GAME" predicate:predicate sortColumn:@"startTime" mOC:self.managedObjectContext ascendingFlg:NO limit:10]];
	
	int lastyear = displayYear-1;
	
	[yearSegment setTitle:[NSString stringWithFormat:@"%d", lastyear] forSegmentAtIndex:0];
	[yearSegment setTitle:[NSString stringWithFormat:@"%d", displayYear] forSegmentAtIndex:1];
	self.yearSegment.selectedSegmentIndex=1;
	
	NSString *status = [mo valueForKey:@"status"];

	if([status isEqualToString:@"Requested"]) {
		self.processForm=99;
		self.sendMessageButton.enabled=NO;
		[ProjectFunctions showAcceptDeclinePopup:@"New Friend Request!" message:[NSString stringWithFormat:@"%@ has requested to share each other's recent games. Would you like to accept?", [mo valueForKey:@"name"]] delegate:self];
	}
	
	if([status isEqualToString:@"Request Pending"]) {
		self.processForm=98;
		self.sendMessageButton.enabled=NO; 
		emailLabel.alpha=0;
		[ProjectFunctions showAlertPopupWithDelegate:@"Awaiting Friend" message:[NSString stringWithFormat:@"Awaiting %@ to approve your request.", [mo valueForKey:@"name"]] delegate:self];
	}

	[removeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[removeButton setBackgroundImage:[UIImage imageNamed:@"redButton.png"] forState:UIControlStateNormal];
	
	[sendMessageButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	[sendMessageButton setBackgroundImage:[UIImage imageNamed:@"yellowButton.png"] forState:UIControlStateNormal];

	self.imageViewBG.alpha=0;
	self.activityLabel.alpha=0;

	[self setTitle:@"Friend Stats"];
    [super viewDidLoad];

	self.userLabel.text = [mo valueForKey:@"name"];
	self.emailLabel.text = [mo valueForKey:@"email"];

	self.navigationItem.rightBarButtonItem = [ProjectFunctions UIBarButtonItemWithIcon:[NSString fontAwesomeIconStringForEnum:FAHome] target:self action:@selector(mainMenuButtonClicked:)];
//	UIBarButtonItem *homeButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Main Menu", nil) style:UIBarButtonItemStylePlain target:self action:@selector(mainMenuButtonClicked:)];
//	self.navigationItem.rightBarButtonItem = homeButton;
	
	if([[mo valueForKey:@"name"] length]==0) {
		// clean up mess!
		[managedObjectContext deleteObject:mo];
		[managedObjectContext save:nil];
		[self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
	}
 
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	if(section==1)
		return [friendGames count];
    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	NSArray *titles = [NSArray arrayWithObjects:@"Stats", @"Last 10 Games", nil];
	return [ProjectFunctions getViewForHeaderWithText:[titles stringAtIndex:(int)section]];
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return 22;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if(section==1)
		return @"Last 10 Games";
	return nil;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if(indexPath.section==0) {
		return 100;
	}
	
	return 44;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *cellIdentifier = [NSString stringWithFormat:@"cellIdentifierSection%dRow%d", (int)indexPath.section, (int)indexPath.row];


	if(indexPath.section==0) {
		NSArray *titles = [NSArray arrayWithObjects:NSLocalizedString(@"Games", nil), NSLocalizedString(@"Hours", nil), NSLocalizedString(@"Profit", nil), NSLocalizedString(@"Hourly", nil), nil];
		int NumberOfRows=(int)[titles count];

		MultiLineDetailCellWordWrap *cell = (MultiLineDetailCellWordWrap *) [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
		if (cell == nil) {
			cell = [[MultiLineDetailCellWordWrap alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier withRows:NumberOfRows labelProportion:0.5];
		}
		
		
		NSString *games = [mo valueForKey:@"gamesLastYear"];
		int profit = [[mo valueForKey:@"profitLastYear"] intValue];
		int hours = [[mo valueForKey:@"hoursLastYear"] intValue];
		if(yearSegment.selectedSegmentIndex==1) {
			games = [mo valueForKey:@"gamesThisYear"];
			profit = [[mo valueForKey:@"profitThisYear"] intValue];
			hours = [[mo valueForKey:@"hoursThisYear"] intValue];
		}
		int hourly=0;
		if(hours>0)
			hourly = profit/hours;
		NSArray *values = [NSArray arrayWithObjects:
						   [NSString stringWithFormat:@"%@", games], 
						   [NSString stringWithFormat:@"%d", hours], 
						   [NSString stringWithFormat:@"%@", [ProjectFunctions convertIntToMoneyString:profit]], 
						   [NSString stringWithFormat:@"%@%d/hr", [ProjectFunctions getMoneySymbol], hourly], 
						   nil];
		NSMutableArray *colors = [[NSMutableArray alloc] init];
		[colors addObject:[UIColor blackColor]];
		[colors addObject:[UIColor blackColor]];
		if(profit>0) {
			[colors addObject:[UIColor colorWithRed:0 green:.5 blue:0 alpha:1]];
			[colors addObject:[UIColor colorWithRed:0 green:.5 blue:0 alpha:1]];
		} else { 
			[colors addObject:[UIColor redColor]];
			[colors addObject:[UIColor redColor]];
		}

		cell.mainTitle = [NSString stringWithFormat:@"%@'s Stats", [mo valueForKey:@"name"]];
		cell.alternateTitle = [NSString stringWithFormat:@"%d", displayYear];
		cell.titleTextArray = titles;
		cell.fieldTextArray = values;
		cell.fieldColorArray = colors;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		return cell;
	}

	return [ProjectFunctions getGameCell:[friendGames objectAtIndex:indexPath.row] CellIdentifier:cellIdentifier tableView:tableView evenFlg:indexPath.row%2==0];

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if(indexPath.section==1) {
		NSManagedObject *managedObject = [friendGames objectAtIndex:indexPath.row];
		GameDetailsVC *detailViewController = [[GameDetailsVC alloc] initWithNibName:@"GameDetailsVC" bundle:nil];
		detailViewController.managedObjectContext = managedObjectContext;
		detailViewController.viewEditable = NO;
		detailViewController.mo = managedObject;
		[self.navigationController pushViewController:detailViewController animated:YES];
	}
}





@end
