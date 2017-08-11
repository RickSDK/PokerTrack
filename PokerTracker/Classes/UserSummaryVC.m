//
//  UserSummaryVC.m
//  PokerTracker
//
//  Created by Rick Medved on 6/6/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "UserSummaryVC.h"
#import "NSArray+ATTArray.h"
#import "NSDate+ATTDate.h"
#import "ProjectFunctions.h"
#import "CoreDataLib.h"
#import "WebServicesFunctions.h"
#import "FriendInProgressVC.h"
#import "FriendLast10GamesVC.h"
#import "NSString+ATTString.h"
#import "MultiLineDetailCellWordWrap.h"
#import "ImageCell.h"


@implementation UserSummaryVC
@synthesize managedObjectContext, mainTableView, addFriendButton, popupBoxNumber, user;
@synthesize viewgameButton, friendName, removeFriendButton;
@synthesize topSegment, selectedSegment, latestMonth;
@synthesize versionLabel, moneySymbolLabel, cityString, nameString, loadedFlg;
@synthesize selfFlg, netUserObj;

- (void)viewDidLoad {
	[super viewDidLoad];
	[self setTitle:@"PTP User"];
	[self changeNavToIncludeType:3];
	
	if(self.netUserObj.nowPlayingFlg)
		[self.viewgameButton setTitle:@"Now Playing!" forState:UIControlStateNormal];
	
	topSegment.selectedSegmentIndex = selectedSegment;
	[topSegment changeSegment];
	[self setupScreen];
	[self populateData];
	
	self.viewgameButton.enabled = self.netUserObj.lastGame.location != nil;
}

-(void)setupScreen {

	self.nameLabel.text = self.netUserObj.name;
	self.cityLabel.text = self.netUserObj.location;
	self.flagImageView.image = self.netUserObj.flagImage;
	NSString *friendStatus = self.netUserObj.friendStatus;
	
	removeFriendButton.hidden=YES;
	addFriendButton.hidden=NO;

	if([friendStatus length]==0)
		addFriendButton.enabled=YES;
	
	self.versionLabel.text = self.netUserObj.version;
	self.moneySymbolLabel.text = self.netUserObj.moneySymbol;
	
	self.selfFlg=NO;
	if([friendStatus isEqualToString:@"self"] || [friendStatus isEqualToString:@"Blocked"]) {
		addFriendButton.hidden=YES;
		self.selfFlg=YES;
	}
	
	if([friendStatus isEqualToString:@"Requested"] || [friendStatus isEqualToString:@"Request Pending"])
		addFriendButton.enabled=NO;
	
	if([friendStatus isEqualToString:@"Active"]) {
		addFriendButton.hidden=YES;
		removeFriendButton.hidden=NO;
	}
	
	if([friendStatus isEqualToString:@"Active"] || self.netUserObj.userId==self.netUserObj.viewingUserId) {
		UIBarButtonItem *moreButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Last10", nil) style:UIBarButtonItemStylePlain target:self action:@selector(last10ButtonClicked:)];
		self.navigationItem.rightBarButtonItem = moreButton;
	}
	NSLog(@"+++self.friend_id %d", self.netUserObj.userId);
	if([friendStatus isEqualToString:@"Request Pending"])
		[ProjectFunctions showAcceptDeclinePopup:@"New Friend Request!" message:[NSString stringWithFormat:@"%@ has requested to share each other's recent games. Would you like to accept?", self.netUserObj.name] delegate:self];
}

-(void)populateData {
	NSArray *titles = [NSArray arrayWithObjects:@"Last 10 Stats", @"Month Stats", @"Year Stats", nil];
	NSString *mainTitle = [titles objectAtIndex:topSegment.selectedSegmentIndex];
	NSString *alternateTitle = (topSegment.selectedSegmentIndex>=1)?[[NSDate date] convertDateToStringWithFormat:@"MMMM yyyy"]:NSLocalizedString(@"Last10", nil);
	NSArray *values = (topSegment.selectedSegmentIndex>=1)?self.netUserObj.monthStatsValues:self.netUserObj.last10StatsValues;
	
	self.multiCellObj = [MultiCellObj multiCellObjWithTitle:mainTitle altTitle:alternateTitle titles:self.netUserObj.statsTitles values:values colors:(self.topSegment.selectedSegmentIndex==0)?self.netUserObj.last10StatsColors:self.netUserObj.monthStatsColors labelPercent:.4];
}

- (IBAction) segmentChanged: (id) sender
{
    if(topSegment.selectedSegmentIndex==2 && addFriendButton.enabled==YES) {
        topSegment.selectedSegmentIndex=0;
        [ProjectFunctions showAlertPopup:@"Notice" message:@"Year statistics only available to friends"];
    }
	[topSegment changeSegment];
	[self populateData];
    [self.mainTableView reloadData];
}

- (IBAction) viewButtonPressed: (id) sender
{
	FriendInProgressVC *detailViewController = [[FriendInProgressVC alloc] initWithNibName:@"FriendInProgressVC" bundle:nil];
	detailViewController.managedObjectContext=managedObjectContext;
	detailViewController.netUserObj=self.netUserObj;
	[self.navigationController pushViewController:detailViewController animated:YES];
}

-(void)last10ButtonClicked:(id)sender {
	FriendLast10GamesVC *detailViewController = [[FriendLast10GamesVC alloc] initWithNibName:@"FriendLast10GamesVC" bundle:nil];
	detailViewController.managedObjectContext=self.managedObjectContext;
	detailViewController.selfFlg=self.selfFlg;
	detailViewController.netUserObj=self.netUserObj;
	[self.navigationController pushViewController:detailViewController animated:YES];
}

-(void)acceptNewFriend
{
	@autoreleasepool {
		NSLog(@"Accepting new friend!: %d", self.netUserObj.userId);
		NSArray *nameList = [NSArray arrayWithObjects:@"Username", @"Password", @"friend_id", nil];
        
		NSArray *valueList = [NSArray arrayWithObjects:[ProjectFunctions getUserDefaultValue:@"userName"], [ProjectFunctions getUserDefaultValue:@"password"], [NSString stringWithFormat:@"%d", self.netUserObj.userId], nil];
		NSString *webAddr = @"http://www.appdigity.com/poker/pokerAcceptFriend.php";
		NSString *responseStr = [WebServicesFunctions getResponseFromServerUsingPost:webAddr fieldList:nameList valueList:valueList];
		if([WebServicesFunctions validateStandardResponse:responseStr delegate:nil]) {
			[ProjectFunctions showAlertPopup:@"Success!" message:@"Friend Added."];
		}
    
		[self endThreadedJob];
	}
}

-(void)removeFriend
{
	@autoreleasepool {
		NSLog(@"removing friend!: %d", self.netUserObj.userId);
		NSArray *nameList = [NSArray arrayWithObjects:@"Username", @"Password", @"friend_id", nil];
		NSArray *valueList = [NSArray arrayWithObjects:[ProjectFunctions getUserDefaultValue:@"userName"], [ProjectFunctions getUserDefaultValue:@"password"], [NSString stringWithFormat:@"%d", self.netUserObj.userId], nil];
		NSString *webAddr = @"http://www.appdigity.com/poker/pokerRemoveFriend.php";
		NSString *responseStr = [WebServicesFunctions getResponseFromServerUsingPost:webAddr fieldList:nameList valueList:valueList];
		if([WebServicesFunctions validateStandardResponse:responseStr delegate:nil]) {
			[ProjectFunctions showAlertPopup:@"Friend Removed" message:@"Friend has been removed."];
		}
		[self endThreadedJob];
	}
}

-(void)executeThreadedJob:(SEL)aSelector
{
	[self.webServiceView startWithTitle:@"Working..."];
	[self performSelectorInBackground:aSelector withObject:nil];
}

-(void)endThreadedJob
{
	[self.webServiceView stop];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(popupBoxNumber==99) {
        if(buttonIndex==1)
            [self executeThreadedJob:@selector(removeFriend)];
        
        return;
    }
    if(popupBoxNumber==87) {
        if(buttonIndex==1)
			[self executeThreadedJob:@selector(addFriendWebRequest)];
        
        return;
    }
		if(buttonIndex==0) {
			[self executeThreadedJob:@selector(removeFriend)];
		} else {
			[self executeThreadedJob:@selector(acceptNewFriend)];
		}
}

-(void)addFriendWebRequest
{
	@autoreleasepool {
		NSArray *nameList = [NSArray arrayWithObjects:@"Username", @"Password", @"friendEmail", nil];

		NSArray *valueList = [NSArray arrayWithObjects:[ProjectFunctions getUserDefaultValue:@"userName"], [ProjectFunctions getUserDefaultValue:@"password"], self.netUserObj.email, nil];
		NSString *webAddr = @"http://www.appdigity.com/poker/pokerAddFriend.php";
		NSString *responseStr = [WebServicesFunctions getResponseFromServerUsingPost:webAddr fieldList:nameList valueList:valueList];
		
		if([[responseStr substringToIndex:7] isEqualToString:@"Success"]) {
        
			NSArray *components = [responseStr componentsSeparatedByString:@"|"];
			NSString *firstName = @"Error";
			if([components count]>2) {
				firstName = [components objectAtIndex:1];
			}

			[ProjectFunctions showAlertPopup:@"Success" message:[NSString stringWithFormat:@"Friend %@ added. Awaiting acceptance.", firstName]];
		}
		else {
			if(responseStr==nil || [responseStr isEqualToString:@""])
				responseStr = @"No network Connection.";
			
			if([responseStr length]>100)
				responseStr = @"Possible server issues. Please try again later.";

			[ProjectFunctions showAlertPopup:@"ERROR" message:responseStr];
		}
		[self endThreadedJob];
		
	}
}

- (IBAction) addButtonPressed: (id) sender
{
    self.popupBoxNumber=87;
	addFriendButton.enabled=NO;
    [ProjectFunctions showConfirmationPopup:@"Add Friend?" message:@"Add this player to your friend list?" delegate:self tag:87];
}

- (IBAction) removeButtonPressed: (id) sender {
    self.popupBoxNumber=99;
	removeFriendButton.enabled=NO;
    [ProjectFunctions showConfirmationPopup:@"Remove Friend?" message:@"Remove this player from your friend list?" delegate:self tag:99];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row==0)
        return 100;
    else
		return [MultiLineDetailCellWordWrap heightForMultiCellObj:self.multiCellObj tableView:tableView];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *cellIdentifier = [NSString stringWithFormat:@"cellIdentifierSection%dRow%d", (int)indexPath.section, (int)indexPath.row];
  
    if(indexPath.row==0) {
        ImageCell *cell = (ImageCell *) [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[ImageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
		double risked=0;
		double profit=0;
		if(topSegment.selectedSegmentIndex==0) {
			cell.leftImage.image = [self imageFromArray:self.netUserObj.last10StatsValues iconGroupNumber:self.netUserObj.iconGroupNumber];
			if(self.netUserObj.last10StatsValues.count>3) {
				cell.nameLabel.text = [self.netUserObj.last10StatsValues objectAtIndex:3];
				risked = [ProjectFunctions convertMoneyStringToDouble:[self.netUserObj.last10StatsValues objectAtIndex:2]];
				profit = [ProjectFunctions convertMoneyStringToDouble:[self.netUserObj.last10StatsValues objectAtIndex:3]];
			}
		} else {
			cell.leftImage.image = [self imageFromArray:self.netUserObj.monthStatsValues iconGroupNumber:self.netUserObj.iconGroupNumber];
			if(self.netUserObj.monthStatsValues.count>3) {
				cell.nameLabel.text = [self.netUserObj.monthStatsValues objectAtIndex:3];
				risked = [ProjectFunctions convertMoneyStringToDouble:[self.netUserObj.monthStatsValues objectAtIndex:2]];
				profit = [ProjectFunctions convertMoneyStringToDouble:[self.netUserObj.monthStatsValues objectAtIndex:3]];
			}
		}
		cell.cityLabel.text = [ProjectFunctions getPlayerTypelabel:risked winnings:profit];
		if(profit>=0) {
			cell.nameLabel.textColor=[UIColor colorWithRed:0 green:.5 blue:0 alpha:1];
			cell.cityLabel.textColor=[UIColor colorWithRed:0 green:.5 blue:0 alpha:1];
		} else {
			cell.nameLabel.textColor=[UIColor colorWithRed:.5 green:0 blue:0 alpha:1];
			cell.cityLabel.textColor=[UIColor colorWithRed:.5 green:0 blue:0 alpha:1];
		}
		
		
        cell.backgroundColor = [UIColor colorWithRed:.7 green:.9 blue:.7 alpha:1];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
        return cell;
    }
	return [MultiLineDetailCellWordWrap multiCellForID:cellIdentifier obj:self.multiCellObj tableView:tableView];
}

-(UIImage *)imageFromArray:(NSArray *)valuesList iconGroupNumber:(int)iconGroupNumber {
	if(valuesList.count>2) {
		double risked = [ProjectFunctions convertMoneyStringToDouble:[valuesList objectAtIndex:2]];
		double profit = [ProjectFunctions convertMoneyStringToDouble:[valuesList objectAtIndex:3]];
		return [ProjectFunctions getPtpPlayerTypeImage:risked winnings:profit iconGroupNumber:iconGroupNumber];
	} else
		return nil;
}

@end
