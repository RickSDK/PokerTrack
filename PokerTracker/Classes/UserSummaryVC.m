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
@synthesize managedObjectContext, mainTableView, values, addFriendButton, popupBoxNumber, user;
@synthesize nameLabel, locationLabel, dateLabel, viewgameButton, friendName, friend_id, removeFriendButton;
@synthesize activityIndicator, imageViewBG, activityLabel, topSegment, selectedSegment, latestMonth, playerImageView;
@synthesize versionLabel, moneySymbolLabel, cityString, nameString, loadedFlg;
@synthesize adView, selfFlg, netUserObj;

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    self.adView.alpha=0;
    NSLog(@"failed");
}

- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    self.adView.alpha=1;
    NSLog(@"yes!");
}

- (IBAction) segmentChanged: (id) sender
{
    if(topSegment.selectedSegmentIndex==2 && addFriendButton.enabled==YES) {
        topSegment.selectedSegmentIndex=0;
        [ProjectFunctions showAlertPopup:@"Notice" message:@"Year statistics only available to friends"];
    }
    [self calculateTableValues];
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
	detailViewController.friendName = self.friendName;
	detailViewController.user_id = friend_id;
	detailViewController.managedObjectContext=self.managedObjectContext;
	detailViewController.selfFlg=self.selfFlg;
	detailViewController.netUserObj=self.netUserObj;
	[self.navigationController pushViewController:detailViewController animated:YES];
}

-(void)acceptNewFriend
{
	@autoreleasepool {
		NSArray *nameList = [NSArray arrayWithObjects:@"Username", @"Password", @"friend_id", nil];
        
		NSArray *valueList = [NSArray arrayWithObjects:[ProjectFunctions getUserDefaultValue:@"userName"], [ProjectFunctions getUserDefaultValue:@"password"], [NSString stringWithFormat:@"%d", friend_id], nil];
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
		NSArray *nameList = [NSArray arrayWithObjects:@"Username", @"Password", @"friend_id", nil];
		NSArray *valueList = [NSArray arrayWithObjects:[ProjectFunctions getUserDefaultValue:@"userName"], [ProjectFunctions getUserDefaultValue:@"password"], [NSString stringWithFormat:@"%d", friend_id], nil];
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
	[activityIndicator startAnimating];
	self.imageViewBG.alpha=1;
	self.activityLabel.alpha=1;
	[self performSelectorInBackground:aSelector withObject:nil];
}

-(void)endThreadedJob
{
	[activityIndicator stopAnimating];
	self.imageViewBG.alpha=0;
	self.activityLabel.alpha=0;
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
/*
-(void)loadUserInfo
{
	@autoreleasepool {
		NSArray *nameList = [NSArray arrayWithObjects:@"Username", @"Password", @"friend_id", nil];
    
		NSArray *valueList = [NSArray arrayWithObjects:[ProjectFunctions getUserDefaultValue:@"userName"], [ProjectFunctions getUserDefaultValue:@"password"], [NSString stringWithFormat:@"%d", friend_id], nil];
		NSString *webAddr = @"http://www.appdigity.com/poker/pokerLoadUser.php";
		NSString *responseStr = [WebServicesFunctions getResponseFromServerUsingPost:webAddr fieldList:nameList valueList:valueList];
		if([WebServicesFunctions validateStandardResponse:responseStr delegate:nil]) {
        NSArray *parts = [responseStr componentsSeparatedByString:@"<br>"];
        if([parts count]>1) {
            NSString *mainStr = [parts objectAtIndex:1];
            NSArray *elements = [mainStr componentsSeparatedByString:@"<xx>"];
            NSString *basics = [elements stringAtIndex:0];
            NSString *last10 = [elements stringAtIndex:1];
            NSString *lastGame = [elements stringAtIndex:4];
 //           self.user = [NSString stringWithFormat:@"12345<xx>%@<xx>%@<xx>%@<aa>%@", last10, basics, lastGame, mainStr];
            topSegment.selectedSegmentIndex = 0;
            self.loadedFlg=YES;
            [self calculateTableValues];
        }
		}
    self.mainTableView.alpha=1;
		[self endThreadedJob];
	}
}


-(void)loadData {
    [self executeThreadedJob:@selector(loadUserInfo)];
}
*/
-(void)calculateTableValues
{
    [values removeAllObjects];
    
//    NSLog(@"user: %@", user);
    

    
	
//	NSString *basics = self.netUserObj.basicsStr;
//	NSString *monthStats = self.netUserObj.monthStats;
//	NSString *lastGame = self.netUserObj.lastGameStr;
//	NSString *last10Stats = self.netUserObj.last10Str;
	
	if(user.length>0) {
		self.netUserObj = [[NetUserObj alloc] init];
		NSArray *segments = [user componentsSeparatedByString:@"<aa>"];
		NSString *mainSegment = [segments stringAtIndex:1];
		
		NSArray *elements = [mainSegment componentsSeparatedByString:@"<xx>"];
		self.netUserObj.basicsStr = [elements stringAtIndex:0];
		self.netUserObj.last10Str = [elements stringAtIndex:1];
//		yearStats = [elements stringAtIndex:2];
		self.netUserObj.monthStats = [elements stringAtIndex:3];
		self.netUserObj.lastGameStr = [elements stringAtIndex:4];
	}

    
 //   NSLog(@"lastGame: %@", lastGame);
    
    NSArray *statFields = nil;
    if(topSegment.selectedSegmentIndex==0)
        statFields = [self.netUserObj.last10Str componentsSeparatedByString:@"|"];
    if(topSegment.selectedSegmentIndex==1)
        statFields = [self.netUserObj.monthStats componentsSeparatedByString:@"|"];
//    if(topSegment.selectedSegmentIndex==2)
  //      statFields = [yearStats componentsSeparatedByString:@"|"];
    NSArray *basicsFields = [self.netUserObj.basicsStr componentsSeparatedByString:@"|"];
    NSArray *lastGameFields = [self.netUserObj.lastGameStr componentsSeparatedByString:@"|"];
    
                                 
    self.latestMonth = [statFields stringAtIndex:0];
    
    versionLabel.text = [basicsFields stringAtIndex:10];
    moneySymbolLabel.text = @"";
    NSString *moneySymbol = [basicsFields stringAtIndex:9];
    if([moneySymbol length]>0 && ![moneySymbol isEqualToString:@"$"])
        moneySymbolLabel.text = [NSString stringWithFormat:@"Money Symbol: %@", moneySymbol];
    
	viewgameButton.enabled=YES;
	if([[lastGameFields stringAtIndex:0] length]==0)
		viewgameButton.enabled=NO;
	
    if(statFields)
        [values addObject:[statFields stringAtIndex:1]]; // games
    
	int streak= [[statFields stringAtIndex:5] intValue];
	NSString *str = [NSString stringWithFormat:@"Win %d", streak];
	if(streak<0)
		str = [NSString stringWithFormat:@"Lose %d", streak*-1];
	[values addObject:str];
    int risked = [[statFields stringAtIndex:3] intValue];
    int profit = [[statFields stringAtIndex:4] intValue];
    
    playerImageView.image = [ProjectFunctions getPlayerTypeImage:risked winnings:profit];
	[values addObject:[ProjectFunctions convertIntToMoneyString:risked]];
	[values addObject:[ProjectFunctions convertIntToMoneyString:profit]];
    NSString *ppr = @"-";
    if(risked>0)
        ppr = [NSString stringWithFormat:@"%d (%@)", 100*(profit+risked)/risked-100, [ProjectFunctions getPlayerTypelabel:risked winnings:profit]];
	[values addObject:ppr];
    int hours = [[statFields stringAtIndex:7] intValue]/60;
	[values addObject:[NSString stringWithFormat:@"%d", hours]];
    NSString *hourly=@"";
    if(hours>0)
        hourly = [NSString stringWithFormat:@"%@", [ProjectFunctions convertIntToMoneyString:profit/hours]];
	[values addObject:[NSString stringWithFormat:@"%@/hr", hourly]];

    NSString *nowPlaying = [basicsFields stringAtIndex:8];
    if([nowPlaying length]==0)
        nowPlaying = [lastGameFields stringAtIndex:13];
    
    if([nowPlaying isEqualToString:@"Y"]) {
		[values addObject:@"Now!"];
		viewgameButton.alpha=1;
        [viewgameButton setTitle:@"Now Playing!" forState:UIControlStateNormal];
	} else {
        NSString *lastPlayedStr = [lastGameFields stringAtIndex:0];
        if([lastPlayedStr length]==22) {
            NSDate *lastPlayedDate = [lastPlayedStr convertStringToDateFinalSolution];
            lastPlayedStr = [NSString stringWithFormat:@"%@", [lastPlayedDate convertDateToStringWithFormat:@"MM/dd/yyyy (h a)"]];
        }
		[values addObject:lastPlayedStr];
	}
    [values addObject:[lastGameFields stringAtIndex:4]]; // last game location

   
    self.friendName = [basicsFields stringAtIndex:0];
	nameLabel.text = self.friendName;
    self.nameString = self.friendName;
    self.cityString = @"(No city)";
    if([[basicsFields stringAtIndex:3] length]>2)
        self.cityString = [NSString stringWithFormat:@"%@, %@ (%@)", [basicsFields stringAtIndex:3], [basicsFields stringAtIndex:4], [basicsFields stringAtIndex:5]];
	locationLabel.text = self.cityString;
	if([[basicsFields stringAtIndex:3] length]==0)
		locationLabel.text = @"Location Unknown";
	dateLabel.text = [NSString stringWithFormat:@"%@ stats", [statFields stringAtIndex:0]];
	
	int user_id = [[basicsFields stringAtIndex:1] intValue];
 	int uid = [[basicsFields stringAtIndex:6] intValue];

    if(self.friend_id>0 && !self.loadedFlg) {
        nameLabel.text = @"Loading";
        locationLabel.text = @"";
//        self.mainTableView.alpha=0;
//        [self loadData];
    }

    self.friend_id=user_id;
    NSString *friendStatus = [basicsFields stringAtIndex:7];
    if([friendStatus length]==0)
		addFriendButton.enabled=YES;
    
	self.selfFlg=NO;
	if([friendStatus isEqualToString:@"self"] || [friendStatus isEqualToString:@"Blocked"]) {
		addFriendButton.enabled=NO;
		self.selfFlg=YES;
	}
	
    if([friendStatus isEqualToString:@"Requested"] || [friendStatus isEqualToString:@"Request Pending"]) 
 		addFriendButton.enabled=NO;
    
    if([friendStatus isEqualToString:@"Active"]) {
        addFriendButton.alpha=0;
 		addFriendButton.enabled=NO;
        removeFriendButton.alpha=1;
    }

    if([friendStatus isEqualToString:@"Active"] || user_id==uid) {
        UIBarButtonItem *moreButton = [[UIBarButtonItem alloc] initWithTitle:@"Last 10" style:UIBarButtonItemStylePlain target:self action:@selector(last10ButtonClicked:)];
        self.navigationItem.rightBarButtonItem = moreButton;
    }
    
    if([friendStatus isEqualToString:@"Request Pending"])
		[ProjectFunctions showAcceptDeclinePopup:@"New Friend Request!" message:[NSString stringWithFormat:@"%@ has requested to share each other's recent games. Would you like to accept?", [basicsFields stringAtIndex:0]] delegate:self];
 

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
	[self setTitle:@"PTP User"]; 
    
	[self.mainTableView setBackgroundView:nil];
	
    addFriendButton.alpha=1;
    removeFriendButton.alpha=0;
	
	values= [[NSMutableArray alloc] init];
    playerImageView = [[UIImageView alloc] init];

    topSegment.selectedSegmentIndex = selectedSegment;
    [self calculateTableValues];

    self.imageViewBG.alpha=0;
	self.activityLabel.alpha=0;

	[ProjectFunctions makeSegment:self.topSegment color:[UIColor colorWithRed:0 green:.5 blue:0 alpha:1]];

}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return CGFLOAT_MIN;
}


-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

-(void)addFriendWebRequest
{
	@autoreleasepool {
		NSArray *nameList = [NSArray arrayWithObjects:@"Username", @"Password", @"friendEmail", nil];

		
//    NSArray *elements = [user componentsSeparatedByString:@"<xx>"];
//    NSString *basics = [elements stringAtIndex:2];
    
//    NSArray *basicsFields = [basics componentsSeparatedByString:@"|"];
		
//		NSString *email = [basicsFields stringAtIndex:2];
    

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
			[ProjectFunctions showAlertPopup:@"ERROR" message:[NSString stringWithFormat:@"%@", responseStr]];
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
        return 9*18+30;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *cellIdentifier = [NSString stringWithFormat:@"cellIdentifierSection%dRow%d", (int)indexPath.section, (int)indexPath.row];
  
    if(indexPath.row==0) {
        ImageCell *cell = (ImageCell *) [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[ImageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        
        cell.imageView.image = playerImageView.image;
        cell.nameLabel.text = self.nameString;
        cell.cityLabel.text = self.cityString;
        cell.backgroundColor = [UIColor colorWithRed:.7 green:.9 blue:.7 alpha:1];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
        return cell;

    }
    int NumberOfRows=(int)[values count];
    
    MultiLineDetailCellWordWrap *cell = (MultiLineDetailCellWordWrap *) [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (cell == nil) {
		cell = [[MultiLineDetailCellWordWrap alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier withRows:NumberOfRows labelProportion:0.4];
	}

	
	// Configure the cell...
	NSArray *labels = [NSArray arrayWithObjects:@"Games", @"Streak", @"Risked", @"Profit", @"ROI", @"Hours", @"Hourly", @"Last Played", @"Last Game", nil];
	NSArray *titles = [NSArray arrayWithObjects:@"Last 10 Stats", @"Month Stats", @"Year Stats", nil];
	
    cell.mainTitle = [titles objectAtIndex:topSegment.selectedSegmentIndex];
    if(topSegment.selectedSegmentIndex>=1)
        cell.alternateTitle = self.latestMonth;
    else
        cell.alternateTitle = @"Last 10";
        
    if([labels count] == [values count])
        cell.titleTextArray = labels;
    else
        cell.titleTextArray = values;
	cell.fieldTextArray = values;

	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	cell.accessoryType = UITableViewCellAccessoryNone;

	return cell;
	
		
}





@end
