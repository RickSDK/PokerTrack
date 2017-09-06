//
//  UniverseTrackerVC.m
//  PokerTracker
//
//  Created by Rick Medved on 6/5/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "UniverseTrackerVC.h"
#import "NSDate+ATTDate.h"
#import "ProjectFunctions.h"
#import "WebServicesFunctions.h"
#import "NSString+ATTString.h"
//#import "HexWithImageCell.h"
#import "ProfileVC.h"
#import "UserSummaryVC.h"
#import "CoreDataLib.h"
#import "FriendsVC.h"
#import "LoginVC.h"
#import "FriendTrackerVC.h"
#import "NetTrackerCell.h"

#define kBatchLimit	20


@implementation UniverseTrackerVC
@synthesize skip, keepGoing;
@synthesize datelabel, profileButton, friendModeOn;
@synthesize sortSegment, processYear, processMonth;


- (void)viewDidLoad {
	[super viewDidLoad];
	[self setTitle:@"Net Tracker"];
	[self changeNavToIncludeType:13];
	
	if([[ProjectFunctions getUserDefaultValue:@"userName"] length]>0 && [[ProjectFunctions getUserDefaultValue:@"userCity"] length]==0)
		[ProjectFunctions showAlertPopupWithDelegate:@"Notice" message:@"Please update your profile to include your City and State" delegate:self];
	
	self.processMonth = [[[NSDate date] convertDateToStringWithFormat:@"MM"] intValue];
	self.processYear = [[[NSDate date] convertDateToStringWithFormat:@"yyyy"] intValue];
	self.datelabel.text = [[NSDate date] convertDateToStringWithFormat:@"MMMM yyyy"];
	
	
	if([[ProjectFunctions getUserDefaultValue:@"userName"] length]==0) {
		[ProjectFunctions showAlertPopup:@"Notice" message:@"Please login to use the Net Tracker System. Use the login button at the top."];
		self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Login" style:UIBarButtonItemStylePlain target:self action:@selector(loginButtonClicked:)];
	} else {
		self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:
												   [ProjectFunctions UIBarButtonItemWithIcon:[NSString fontAwesomeIconStringForEnum:FAUsers] target:self action:@selector(friendButtonClicked:)],
												   [ProjectFunctions UIBarButtonItemWithIcon:[NSString fontAwesomeIconStringForEnum:FAInfoCircle] target:self action:@selector(popupButtonClicked)],
												   nil];
		self.popupView.titleLabel.text = self.title;
		self.popupView.textView.text = @"Net Tracker is a leader board of all players using PTP. A very limited amount of data is included on these screens so as to protect player privacy. Email addresses are never shared or displayed on any screen.\n\nYou can also opt out of Net Tracker on your profile.";
		self.popupView.textView.hidden=NO;
	}

	if([[ProjectFunctions getUserDefaultValue:@"userName"] length]>0 && [[ProjectFunctions getUserDefaultValue:@"Universe"] length]==0) {
		[ProjectFunctions setUserDefaultValue:@"Y" forKey:@"Universe"];
		[ProjectFunctions uploadUniverseStats:self.managedObjectContext];
	}

	NSString *killNetTracker = [ProjectFunctions getUserDefaultValue:@"killNetTracker"];
	self.netSwitch.on = killNetTracker.length==0;
	self.mainTableView.hidden=!self.netSwitch.on;
	
	if(self.netSwitch.on)
		[self loadDataFromScratch];
}

-(void)loadDataFromScratch {
	[self.mainArray removeAllObjects];
	self.latestVersionCount=0;
	self.themeCount=0;
	self.iconCount=0;
	self.skip=0;
	self.keepGoing=YES;
	[self startBackgroundProcess];
}

-(void)startBackgroundProcess
{
	[self.webServiceView startWithTitle:@"Loading..."];
	[self performSelectorInBackground:@selector(backgroundProcess) withObject:nil];
}

-(void)backgroundProcess
{
	@autoreleasepool {
		NSString *username = [ProjectFunctions getUserDefaultValue:@"userName"];
		NSString *password = [ProjectFunctions getUserDefaultValue:@"password"];
		if([username length]==0) {
			sortSegment.enabled=NO;
			username = @"test@aol.com";
			password = @"test123";
		}
		NSString *friendFlg = (friendModeOn)?@"Y":@"N";
		NSString *sort = [NSString stringWithFormat:@"%d", (int)self.sortSegment.selectedSegmentIndex];
		NSString *skipStr = [NSString stringWithFormat:@"%d", self.skip];
		NSString *batchLimitStr = [NSString stringWithFormat:@"%d", kBatchLimit];
		
		NSArray *nameList = [NSArray arrayWithObjects:@"Username", @"Password", @"sort", @"skip", @"friendFlg", @"batchLimit", nil];
		NSArray *valueList = [NSArray arrayWithObjects:username, password, sort, skipStr, friendFlg, batchLimitStr, nil];
		NSString *webAddr = @"http://www.appdigity.com/poker/pokerNetTracker.php";
		NSString *responseStr = [WebServicesFunctions getResponseFromServerUsingPost:webAddr fieldList:nameList valueList:valueList];
		if([WebServicesFunctions validateStandardResponse:responseStr delegate:nil]) {
            NSArray *users = [responseStr componentsSeparatedByString:@"<br>"];
			int count=0;
            for(NSString *line in users)
                if([line length]>20) {
					count++;
					self.skip++;
					
					NetUserObj *netUserObj = [NetUserObj userObjFromString:line type:99];
					[self.mainArray addObject:netUserObj];
					if(netUserObj.currentVersionFlg)
						self.latestVersionCount++;
					if(netUserObj.themeFlg || netUserObj.customFlg)
						self.themeCount++;
					if(netUserObj.iconGroupNumber>0)
						self.iconCount++;
					if(netUserObj.currentVersionFlg && (netUserObj.themeFlg || netUserObj.customFlg) && netUserObj.iconGroupNumber>0)
						NSLog(@"!!!!!Super User: 👮%@", netUserObj.name);

                    if([netUserObj.friendStatus isEqualToString:@"Request Pending"])
                        [ProjectFunctions showAlertPopup:@"New Friend Request!" message:[NSString stringWithFormat:@"%@ has requested to be your friend. Find that person below and click on the link.", netUserObj.name]];

				}
			self.keepGoing=(count>=kBatchLimit);
		}
		[self logCountOfIcon:@"✅️" count:self.latestVersionCount total:(int)self.mainArray.count];
		[self logCountOfIcon:@"🎨" count:self.themeCount total:(int)self.mainArray.count];
		[self logCountOfIcon:@"🐠" count:self.iconCount total:(int)self.mainArray.count];
		
		[self.webServiceView stop];
		[self.mainTableView reloadData];
	}
}

-(void)logCountOfIcon:(NSString *)icon count:(int)count total:(int)total {
	if(total==0)
		return;
	if([@"🎨" isEqualToString:icon] && self.latestVersionCount>0)
		NSLog(@"%@%d/%d (%d%%) [%d%%]", icon, count, total, count*100/total, count*100/self.latestVersionCount);
	else
		NSLog(@"%@%d/%d (%d%%)", icon, count, total, count*100/total);
}

-(void)friendButtonClicked:(id)sender {
	FriendTrackerVC *detailViewController = [[FriendTrackerVC alloc] initWithNibName:@"FriendTrackerVC" bundle:nil];
	detailViewController.managedObjectContext = self.managedObjectContext;
	[self.navigationController pushViewController:detailViewController animated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (IBAction) sortSegmentChanged: (id) sender
{
	[self.sortSegment changeSegment];
	if([self verifyLogin])
		[self loadDataFromScratch];
}

-(BOOL)verifyLogin {
	if([[ProjectFunctions getUserDefaultValue:@"userName"] length]==0) {
		[ProjectFunctions showAlertPopup:@"Notice" message:@"Please log in to view these features"];
		return NO;
	} else
		return YES;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.mainArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *cellIdentifier = [NSString stringWithFormat:@"cellIdentifierSection%dRow%d", (int)indexPath.section, (int)indexPath.row];
    
	NetUserObj *netUserObj = [self.mainArray objectAtIndex:indexPath.row];
	netUserObj.rowId = (int)indexPath.row+1;
	netUserObj.sortType = (int)sortSegment.selectedSegmentIndex;

	NetTrackerCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[NetTrackerCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
	
	if(indexPath.row==self.mainArray.count-1 && self.keepGoing) {
		if([[ProjectFunctions getUserDefaultValue:@"userName"] length]>0) {
			NSLog(@"Load more...");
			self.keepGoing=NO;
			[self startBackgroundProcess];
		}
	}
	return [NetTrackerCell cellForCell:cell netUserObj:netUserObj];
}	

- (IBAction) profileButtonPressed: (id) sender
{
	if([self verifyLogin])
		[self gotoProfile];
}

-(void)gotoProfile {
	ProfileVC *detailViewController = [[ProfileVC alloc] initWithNibName:@"ProfileVC" bundle:nil];
	detailViewController.managedObjectContext=self.managedObjectContext;
	[self.navigationController pushViewController:detailViewController animated:YES];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	[self gotoProfile];
}

-(void)loginButtonClicked:(id)sender {
	LoginVC *detailViewController = [[LoginVC alloc] initWithNibName:@"LoginVC" bundle:nil];
	detailViewController.managedObjectContext = self.managedObjectContext;
	[self.navigationController pushViewController:detailViewController animated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if([self verifyLogin]) {
		UserSummaryVC *detailViewController = [[UserSummaryVC alloc] initWithNibName:@"UserSummaryVC" bundle:nil];
		detailViewController.managedObjectContext=self.managedObjectContext;
		detailViewController.netUserObj = [self.mainArray objectAtIndex:indexPath.row];
        detailViewController.selectedSegment=1;
		[self.navigationController pushViewController:detailViewController animated:YES];
	}
}

- (IBAction) netSwitchChanged: (id) sender {
	self.mainTableView.hidden=!self.netSwitch.on;
	if(self.netSwitch.on) {
		[self loadDataFromScratch];
		[ProjectFunctions setUserDefaultValue:@"" forKey:@"killNetTracker"];
	} else {
		[ProjectFunctions setUserDefaultValue:@"Y" forKey:@"killNetTracker"];
	}
}

@end
