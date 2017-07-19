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
#import "HexWithImageCell.h"
#import "NSArray+ATTArray.h"
#import "ProfileVC.h"
#import "UserSummaryVC.h"
#import "CoreDataLib.h"
#import "FriendsVC.h"
#import "LoginVC.h"
#import "UIColor+ATTColor.h"
#import "FriendTrackerVC.h"

#define kBatchLimit	20


@implementation UniverseTrackerVC
@synthesize managedObjectContext, skip, keepGoing;
@synthesize activityIndicator, activityLabel, activityPopup, netUserList;
@synthesize datelabel, userList, mainTableView, topSegment, profileButton, friendList, friendButton, friendModeOn;
@synthesize profitList, moneyList, gamesList, sortSegment, prevButton, nextButton, processYear, processMonth, timeFrameSegment;
@synthesize last10MoneyAllList, last10ProfitAllList, last10GamesAllList, monthMoneyAllList, monthProfitAllList, monthGamesAllList;
@synthesize yearMoneyFriendsList, yearProfitFriendsList, yearGamesFriendsList;


- (void)viewDidLoad {
	[super viewDidLoad];
	[self setTitle:@"Net Tracker"];
	
	self.netUserList = [[NSMutableArray alloc] init];
	[self.netUserList removeAllObjects];

	
	timeFrameSegment.selectedSegmentIndex=1;
	[timeFrameSegment changeSegment];
	[self.mainTableView setBackgroundView:nil];
	
	NSArray *items = [CoreDataLib selectRowsFromEntity:@"FRIEND" predicate:nil sortColumn:nil mOC:managedObjectContext ascendingFlg:NO];
	NSMutableArray *friends = [[NSMutableArray alloc] init];
	for(NSManagedObject *mo in items) {
		int uid = [[mo valueForKey:@"user_id"] intValue];
		[friends addObject:[NSString stringWithFormat:@"[%d]", uid]];
	}
	
	self.friendList = [friends componentsJoinedByString:@"|"];
	
	if([[ProjectFunctions getUserDefaultValue:@"userName"] length]>0 && [[ProjectFunctions getUserDefaultValue:@"userCity"] length]==0)
		[ProjectFunctions showAlertPopupWithDelegate:@"Notice" message:@"Please update your profile to include your City and State" delegate:self];
	
	self.processMonth = [[[NSDate date] convertDateToStringWithFormat:@"MM"] intValue];
	self.processYear = [[[NSDate date] convertDateToStringWithFormat:@"yyyy"] intValue];
	
	userList = [[NSMutableArray alloc] init];
	profitList = [[NSMutableArray alloc] init];
	moneyList = [[NSMutableArray alloc] init];
	gamesList = [[NSMutableArray alloc] init];
	
	last10MoneyAllList = [[NSMutableArray alloc] init];
	last10ProfitAllList = [[NSMutableArray alloc] init];
	last10GamesAllList = [[NSMutableArray alloc] init];
	monthMoneyAllList = [[NSMutableArray alloc] init];
	monthProfitAllList = [[NSMutableArray alloc] init];
	monthGamesAllList = [[NSMutableArray alloc] init];
	
	yearMoneyFriendsList = [[NSMutableArray alloc] init];
	yearProfitFriendsList = [[NSMutableArray alloc] init];
	yearGamesFriendsList = [[NSMutableArray alloc] init];
	
	
	if([[ProjectFunctions getUserDefaultValue:@"userName"] length]==0) {
		[ProjectFunctions showAlertPopup:@"Notice" message:@"Please login to use the Net Tracker System. Use the login button at the top."];
		UIBarButtonItem *moreButton = [[UIBarButtonItem alloc] initWithTitle:@"Login" style:UIBarButtonItemStylePlain target:self action:@selector(loginButtonClicked:)];
		self.navigationItem.rightBarButtonItem = moreButton;
	} else {
		self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:
												   [ProjectFunctions UIBarButtonItemWithIcon:[NSString fontAwesomeIconStringForEnum:FAUsers] target:self action:@selector(friendButtonClicked:)],
												   [ProjectFunctions UIBarButtonItemWithIcon:[NSString fontAwesomeIconStringForEnum:FAInfoCircle] target:self action:@selector(popupButtonClicked)],
												   nil];
		
		self.popupView.titleLabel.text = self.title;
		self.popupView.textView.text = @"Net Tracker is a leader board of all players using PTP. A very limited amount of data is included on these screens so as to protect player privacy. Email addresses are never shared or displayed on any screen.\n\nYou can also opt out of Net Tracker on your profile.";
		self.popupView.textView.hidden=NO;
	}
	
	[ProjectFunctions makeSegment:self.topSegment color:[UIColor colorWithRed:0 green:.5 blue:0 alpha:1]];
	[ProjectFunctions makeSegment:self.sortSegment color:[UIColor colorWithRed:0 green:.5 blue:0 alpha:1]];
	[ProjectFunctions makeSegment:self.timeFrameSegment color:[UIColor colorWithRed:0 green:.5 blue:0 alpha:1]];

	[self loadData];

	
}

-(void)loadData {
	[self.netUserList removeAllObjects];
	self.skip=0;
	self.keepGoing=YES;
	[self startBackgroundProcess];
}

- (IBAction) prevButtonPressed: (id) sender
{
    self.processMonth--;
    if(processMonth<1) {
        self.processMonth=12;
        processYear--;
    }
 	[self startBackgroundProcess];
   
}
- (IBAction) nextButtonPressed: (id) sender
{
    self.processMonth++;
    if(processMonth>12) {
        self.processMonth=1;
        processYear++;
    }
	[self startBackgroundProcess];
    
}

-(void)backgroundProcess
{
	@autoreleasepool {

        if([[ProjectFunctions getUserDefaultValue:@"userName"] length]>0 && [[ProjectFunctions getUserDefaultValue:@"Universe"] length]==0) {
            [ProjectFunctions setUserDefaultValue:@"Y" forKey:@"Universe"];
            [ProjectFunctions uploadUniverseStats:managedObjectContext];
        }
        
		
        prevButton.enabled=YES;
        nextButton.enabled=YES;
        int thisMonth = [[[NSDate date] convertDateToStringWithFormat:@"MM"] intValue];
        int thisYear = [[[NSDate date] convertDateToStringWithFormat:@"yyyy"] intValue];
        if(processMonth==thisMonth && processYear==thisYear)
            nextButton.enabled=NO;
        if(processMonth==6 && processYear==2012)
            prevButton.enabled=NO;

        NSString *thisDateString = [NSString stringWithFormat:@"%02d/1/%d", processMonth, processYear];
        NSDate *thisdate = [thisDateString convertStringToDateWithFormat:@"MM/dd/yyyy"];
		
        datelabel.text = [thisdate convertDateToStringWithFormat:@"MMMM yyyy"];

		NSString *username = [ProjectFunctions getUserDefaultValue:@"userName"];
		NSString *password = [ProjectFunctions getUserDefaultValue:@"password"];
		if([username length]==0) {
			topSegment.enabled=NO;
			sortSegment.enabled=NO;
			timeFrameSegment.enabled=NO;
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
//			NSLog(@"%@", responseStr);
	
            [last10MoneyAllList removeAllObjects];
            [monthMoneyAllList removeAllObjects];
            [yearMoneyFriendsList removeAllObjects];

            [last10ProfitAllList removeAllObjects];
            [monthProfitAllList removeAllObjects];
            [yearProfitFriendsList removeAllObjects];

            [last10GamesAllList removeAllObjects];
            [monthGamesAllList removeAllObjects];
            [yearGamesFriendsList removeAllObjects];

            NSArray *users = [responseStr componentsSeparatedByString:@"<br>"];
			int count=0;
            for(NSString *line in users)
                if([line length]>20) {
					count++;
					self.skip++;
					
					NetUserObj *netUserObj = [NetUserObj userObjFromString:line];
					[self.netUserList addObject:netUserObj];
                  
                    if([netUserObj.friendStatus isEqualToString:@"Request Pending"])
                        [ProjectFunctions showAlertPopup:@"New Friend Request!" message:[NSString stringWithFormat:@"%@ has requested to be your friend. Find that person below and click on the link.", netUserObj.name]];

				}
			self.keepGoing=(count>=kBatchLimit);
		}
		
		activityLabel.alpha=0;
		activityPopup.alpha=0;
		profileButton.enabled=YES;
		[activityIndicator stopAnimating];
		[self.mainTableView reloadData];
	
	
	}
}

-(void)startBackgroundProcess
{
	[activityIndicator startAnimating];
	activityLabel.alpha=1;
	activityPopup.alpha=1;
	profileButton.enabled=NO;
    prevButton.enabled=NO;
    nextButton.enabled=NO;
	
	[self performSelectorInBackground:@selector(backgroundProcess) withObject:nil];
}

-(void)friendButtonClicked:(id)sender {
	FriendTrackerVC *detailViewController = [[FriendTrackerVC alloc] initWithNibName:@"FriendTrackerVC" bundle:nil];
	detailViewController.managedObjectContext = managedObjectContext;
	[self.navigationController pushViewController:detailViewController animated:YES];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (IBAction) sortSegmentChanged: (id) sender
{
	if([[ProjectFunctions getUserDefaultValue:@"userName"] length]==0) {
		[ProjectFunctions showAlertPopup:@"Notice" message:@"Please log in to view these features"];
		return;
	}
	[self loadData];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.netUserList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *cellIdentifier = [NSString stringWithFormat:@"cellIdentifierSection%dRow%d", (int)indexPath.section, (int)indexPath.row];
    
    HexWithImageCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[HexWithImageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
	
	NetUserObj *netUserObj = [netUserList objectAtIndex:indexPath.row];
	if(netUserObj.hasFlag)
		cell.flagImageView.image=netUserObj.flagImage;
	cell.flagImageView.hidden=!netUserObj.hasFlag;
	
    NSArray *statFields = [netUserObj.monthStats componentsSeparatedByString:@"|"];
    NSArray *basicsFields = [netUserObj.basicsStr componentsSeparatedByString:@"|"];
    NSArray *lastGameFields = [netUserObj.lastGameStr componentsSeparatedByString:@"|"];
	
	cell.a1.text = [NSString stringWithFormat:@"#%d - %@", (int)indexPath.row+1, [basicsFields stringAtIndex:0]];
	int uid = [[basicsFields stringAtIndex:1] intValue];
	int user_id = [[basicsFields stringAtIndex:6] intValue];
	NSString *friendStatus = [basicsFields stringAtIndex:7];
	
	if([[basicsFields stringAtIndex:3] length]==0)
		cell.b1.text = [lastGameFields stringAtIndex:0];
	else {
		if([[basicsFields stringAtIndex:5] isEqualToString:@"USA"])
			cell.b1.text = [NSString stringWithFormat:@"%@, %@", [basicsFields stringAtIndex:3], [basicsFields stringAtIndex:4]];
		else 
			cell.b1.text = [NSString stringWithFormat:@"%@, %@", [basicsFields stringAtIndex:3], [basicsFields stringAtIndex:5]];
	}
	cell.b1Color = [UIColor orangeColor];
	
    NSString *nowPlayingFlg = [basicsFields stringAtIndex:8];

    if([nowPlayingFlg length]==0)
        nowPlayingFlg = [lastGameFields stringAtIndex:13];
    
	if([nowPlayingFlg isEqualToString:@"Y"]) {
		cell.b1.text = [NSString stringWithFormat:@"Now Playing: %@", [lastGameFields stringAtIndex:4]];
		cell.b1Color = [UIColor purpleColor];
	}
	
    int minutes = [[statFields stringAtIndex:7] intValue];
    float hoursFloat = (float)minutes/60;
	int profit = [[statFields stringAtIndex:4] intValue];
	int moneyRisked = [[statFields stringAtIndex:3] intValue];
	int hourly = 0;
    if(hoursFloat>0)
        hourly = (float)profit/hoursFloat;
    
	cell.b2.text = [NSString stringWithFormat:@"%@%d/hr", [ProjectFunctions getMoneySymbol], hourly];
	if(hourly>=0)
		cell.b2Color = [UIColor colorWithRed:0 green:.5 blue:0 alpha:1];
	else 
		cell.b2Color = [UIColor redColor];
	
	cell.a2.text = [NSString stringWithFormat:@"%@", [ProjectFunctions convertIntToMoneyString:profit]];
	if(profit>=0)
		cell.a2Color = [UIColor colorWithRed:0 green:.5 blue:0 alpha:1];
	else 
		cell.a2Color = [UIColor redColor];

	cell.c1.text = [NSString stringWithFormat:@"games: %@", [statFields stringAtIndex:1]];
    
    int streak = [[statFields stringAtIndex:5] intValue];
    NSString *streakStr = @"-";
    if(streak>0)
        streakStr = [NSString stringWithFormat:@"W%d", streak];
    if(streak<0)
        streakStr = [NSString stringWithFormat:@"L%d", streak*-1];
	cell.c2.text = [NSString stringWithFormat:@"stk: %@", streakStr];
	
	cell.leftImageView.image = [ProjectFunctions getPlayerTypeImage:moneyRisked winnings:profit];
    if(sortSegment.selectedSegmentIndex==1) {
        cell.b2.text = [NSString stringWithFormat:@"ROI: %@%%", netUserObj.ppr];
        cell.b2Color = [UIColor blueColor];
    }
    if(uid==user_id) {
		cell.a1Color = [UIColor ATTBlue];
		cell.backgroundColor = [UIColor colorWithRed:1 green:1 blue:.5 alpha:1];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
    } else if([friendStatus isEqualToString:@"Active"]) {
        cell.a1Color = [UIColor blackColor];
        cell.backgroundColor = [UIColor colorWithRed:.8 green:.8 blue:1 alpha:1];
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    } else if([friendStatus isEqualToString:@"Pending"] || [friendStatus isEqualToString:@"Request Pending"] || [friendStatus isEqualToString:@"Requested"]) {
        cell.a1Color = [UIColor blackColor];
        cell.backgroundColor = [UIColor colorWithRed:.8 green:1 blue:.8 alpha:1];
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    } else {
        cell.a1Color = [UIColor blackColor];
        cell.backgroundColor = [UIColor whiteColor];
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    }
	
    if([friendStatus isEqualToString:@"Requested"]) 
        cell.b1.text = @"Friend Request Pending";
    
    if([friendStatus isEqualToString:@"Request Pending"]) {
        cell.backgroundColor = [UIColor colorWithRed:.8 green:1 blue:.8 alpha:1];
        cell.b1.text = @"Friend Request!";
    }
    
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	if(indexPath.row==self.netUserList.count-1 && self.keepGoing) {
		if([[ProjectFunctions getUserDefaultValue:@"userName"] length]>0) {
			NSLog(@"Load more...");
			self.keepGoing=NO;
			[self startBackgroundProcess];
		}
	}

	return cell;
}	

- (IBAction) segmentChanged: (id) sender
{
	[topSegment changeSegment];
	if([[ProjectFunctions getUserDefaultValue:@"userName"] length]==0) {
		[ProjectFunctions showAlertPopup:@"Notice" message:@"Please log in to view these features"];
		return;
	}
	[self startBackgroundProcess];
}

- (IBAction) profileButtonPressed: (id) sender
{
	if([[ProjectFunctions getUserDefaultValue:@"userName"] length]==0) {
		[ProjectFunctions showAlertPopup:@"Notice" message:@"Please log in to view these features"];
		return;
	}
	ProfileVC *detailViewController = [[ProfileVC alloc] initWithNibName:@"ProfileVC" bundle:nil];
	detailViewController.managedObjectContext=managedObjectContext;
	[self.navigationController pushViewController:detailViewController animated:YES];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	ProfileVC *detailViewController = [[ProfileVC alloc] initWithNibName:@"ProfileVC" bundle:nil];
	detailViewController.managedObjectContext=managedObjectContext;
	[self.navigationController pushViewController:detailViewController animated:YES];
}

-(void)loginButtonClicked:(id)sender {
	LoginVC *detailViewController = [[LoginVC alloc] initWithNibName:@"LoginVC" bundle:nil];
	detailViewController.managedObjectContext = managedObjectContext;
	[self.navigationController pushViewController:detailViewController animated:YES];
}


-(void)uploadStatsFunction
{
	@autoreleasepool {
        [ProjectFunctions uploadUniverseStats:managedObjectContext];
        [self.mainTableView reloadData];
	[activityIndicator stopAnimating];
	activityLabel.alpha=0;
	activityPopup.alpha=0;
        [ProjectFunctions showAlertPopup:@"Stats Synced" message:@"Note this feature is only needed if your own stats are out of sync."];
	}
}


-(void)mainMenuButtonClicked:(id)sender {
	[activityIndicator startAnimating];
	activityLabel.alpha=1;
	activityPopup.alpha=1;
    self.syncButton.enabled=NO;
	
	[self performSelectorInBackground:@selector(uploadStatsFunction) withObject:nil];
//	[self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if([[ProjectFunctions getUserDefaultValue:@"userName"] length]==0) {
		[ProjectFunctions showAlertPopup:@"Notice" message:@"Please log in to view these features"];
	} else {
		UserSummaryVC *detailViewController = [[UserSummaryVC alloc] initWithNibName:@"UserSummaryVC" bundle:nil];
		detailViewController.managedObjectContext=managedObjectContext;
		detailViewController.netUserObj = [self.netUserList objectAtIndex:indexPath.row];
//		detailViewController.user=[userList objectAtIndex:indexPath.row];
        detailViewController.selectedSegment=1;
		[self.navigationController pushViewController:detailViewController animated:YES];
	}
}

- (IBAction) timeSegmentChanged: (id) sender
{
	[timeFrameSegment changeSegment];
    if(timeFrameSegment.selectedSegmentIndex==2 && !friendModeOn) {
        timeFrameSegment.selectedSegmentIndex=0;
        [ProjectFunctions showAlertPopup:@"Notice" message:@"Year stats only available in friends mode"];
        return;
   }
}






@end
