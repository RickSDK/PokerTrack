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


@implementation UniverseTrackerVC
@synthesize managedObjectContext;
@synthesize activityIndicator, activityLabel, activityPopup;
@synthesize datelabel, userList, mainTableView, topSegment, profileButton, friendList, friendButton, friendModeOn;
@synthesize profitList, moneyList, gamesList, sortSegment, prevButton, nextButton, processYear, processMonth, timeFrameSegment;
@synthesize last10MoneyAllList, last10ProfitAllList, last10GamesAllList, monthMoneyAllList, monthProfitAllList, monthGamesAllList;
@synthesize yearMoneyFriendsList, yearProfitFriendsList, yearGamesFriendsList;


-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if([self respondsToSelector:@selector(edgesForExtendedLayout)])
        [self setEdgesForExtendedLayout:UIRectEdgeBottom];
}


-(void)populateArray
{
	[userList removeAllObjects];
    switch (timeFrameSegment.selectedSegmentIndex) {
        case 0: //Last10
            if(sortSegment.selectedSegmentIndex==0)
                self.userList = [NSMutableArray arrayWithArray:[ProjectFunctions sortArrayDescending:last10MoneyAllList]];
            if(sortSegment.selectedSegmentIndex==1)
                self.userList = [NSMutableArray arrayWithArray:[ProjectFunctions sortArrayDescending:last10ProfitAllList]];
            if(sortSegment.selectedSegmentIndex==2)
                self.userList = [NSMutableArray arrayWithArray:[ProjectFunctions sortArrayDescending:last10GamesAllList]];
            break;
        case 1: // Month
            if(sortSegment.selectedSegmentIndex==0)
                self.userList = [NSMutableArray arrayWithArray:[ProjectFunctions sortArrayDescending:monthMoneyAllList]];
            if(sortSegment.selectedSegmentIndex==1)
                self.userList = [NSMutableArray arrayWithArray:[ProjectFunctions sortArrayDescending:monthProfitAllList]];
            if(sortSegment.selectedSegmentIndex==2)
                self.userList = [NSMutableArray arrayWithArray:[ProjectFunctions sortArrayDescending:monthGamesAllList]];
            break;
        case 2: // Year
            if(sortSegment.selectedSegmentIndex==0)
                self.userList = [NSMutableArray arrayWithArray:[ProjectFunctions sortArrayDescending:yearMoneyFriendsList]];
            if(sortSegment.selectedSegmentIndex==1)
                self.userList = [NSMutableArray arrayWithArray:[ProjectFunctions sortArrayDescending:yearProfitFriendsList]];
            if(sortSegment.selectedSegmentIndex==2)
                self.userList = [NSMutableArray arrayWithArray:[ProjectFunctions sortArrayDescending:yearGamesFriendsList]];
            break;
            
        default:
            break;
    }
	[mainTableView reloadData];
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
        NSString *currentMonth = [[NSDate date] convertDateToStringWithFormat:@"MMM yyyy"];
        
        datelabel.text = [thisdate convertDateToStringWithFormat:@"MMMM yyyy"];

	NSArray *nameList = [NSArray arrayWithObjects:@"Username", @"Password", @"localFlg", @"dateText", @"friendFlg", nil];
	NSString *localFlg=@"N";
	if(topSegment.selectedSegmentIndex==1)
		localFlg=@"Y";
        
        NSString *dateText = [NSString stringWithFormat:@"%d%02d", processYear, processMonth];
	
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
	NSArray *valueList = [NSArray arrayWithObjects:username, password, localFlg, dateText, friendFlg, nil];
	NSString *webAddr = @"http://www.appdigity.com/poker/pokerUniverse2.php";
	NSString *responseStr = [WebServicesFunctions getResponseFromServerUsingPost:webAddr fieldList:nameList valueList:valueList];
        if([WebServicesFunctions validateStandardResponse:responseStr delegate:nil]) {
	
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
            for(NSString *line in users)
                if([line length]>20) {
                    NSArray *elements = [line componentsSeparatedByString:@"<xx>"];
                    NSString *basics = [elements stringAtIndex:0];
                    NSString *last10 = [elements stringAtIndex:1];
                    NSString *monthStats = [elements stringAtIndex:3];
                    NSString *yearStats = [elements stringAtIndex:2];
                    NSString *lastGame = [elements stringAtIndex:4];
                  
                    NSArray *last10Elements = [last10 componentsSeparatedByString:@"|"];
                    NSArray *yearElements = [yearStats componentsSeparatedByString:@"|"];
                    NSArray *monthElements = [monthStats componentsSeparatedByString:@"|"];
                    NSArray *basicsElements = [basics componentsSeparatedByString:@"|"];
                    
                    int gamesThisMonth = [[monthElements stringAtIndex:2] intValue];
                    
                    NSString *status = [basicsElements stringAtIndex:7];
                    if([status isEqualToString:@"Request Pending"])
                        [ProjectFunctions showAlertPopup:@"New Friend Request!" message:[NSString stringWithFormat:@"%@ has requested to be your friend. Find that person below and click on the link.", [basicsElements stringAtIndex:0]]];
                    
                    NSString *lastMonthUpd = [monthElements stringAtIndex:0];
                    
                    //Money
                    [last10MoneyAllList addObject:[NSString stringWithFormat:@"%08d<xx>%@<xx>%@<xx>%@<aa>%@", ([[last10Elements stringAtIndex:4] intValue]+1000000), last10, basics, lastGame, line]];
                    
                    if([lastMonthUpd isEqualToString:currentMonth] && gamesThisMonth>0)
                        [monthMoneyAllList addObject:[NSString stringWithFormat:@"%08d<xx>%@<xx>%@<xx>%@<aa>%@", ([[monthElements stringAtIndex:4] intValue]+1000000), monthStats, basics, lastGame, line]];
                    [yearMoneyFriendsList addObject:[NSString stringWithFormat:@"%08d<xx>%@<xx>%@<xx>%@<aa>%@", ([[yearElements stringAtIndex:4] intValue]+1000000), yearStats, basics, lastGame, line]];
                    
                    //Skill
                    [last10ProfitAllList addObject:[NSString stringWithFormat:@"%08d<xx>%@<xx>%@<xx>%@<aa>%@", [[last10Elements stringAtIndex:6] intValue], last10, basics, lastGame, line]];
                    if([lastMonthUpd isEqualToString:currentMonth] && gamesThisMonth>0)
                        [monthProfitAllList addObject:[NSString stringWithFormat:@"%08d<xx>%@<xx>%@<xx>%@<aa>%@", [[monthElements stringAtIndex:6] intValue], monthStats, basics, lastGame, line]];
                    [yearProfitFriendsList addObject:[NSString stringWithFormat:@"%08d<xx>%@<xx>%@<xx>%@<aa>%@", [[yearElements stringAtIndex:6] intValue], yearStats, basics, lastGame, line]];
                    
                    //Games
                    [last10GamesAllList addObject:[NSString stringWithFormat:@"%08d<xx>%@<xx>%@<xx>%@<aa>%@", [[last10Elements stringAtIndex:2] intValue], last10, basics, lastGame, line]];
                    if([lastMonthUpd isEqualToString:currentMonth] && gamesThisMonth>0)
                        [monthGamesAllList addObject:[NSString stringWithFormat:@"%08d<xx>%@<xx>%@<xx>%@<aa>%@", [[monthElements stringAtIndex:2] intValue], monthStats, basics, lastGame, line]];
                    [yearGamesFriendsList addObject:[NSString stringWithFormat:@"%08d<xx>%@<xx>%@<xx>%@<aa>%@", [[yearElements stringAtIndex:2] intValue], yearStats, basics, lastGame, line]];

                }
	}

	[self populateArray];
	
	activityLabel.alpha=0;
	activityPopup.alpha=0;
	profileButton.enabled=YES;
	[activityIndicator stopAnimating];
	
	
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
//    self.friendModeOn = !friendModeOn;
  //  [self startBackgroundProcess];

	FriendTrackerVC *detailViewController = [[FriendTrackerVC alloc] initWithNibName:@"FriendTrackerVC" bundle:nil];
	detailViewController.managedObjectContext = managedObjectContext;
	[self.navigationController pushViewController:detailViewController animated:YES];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (IBAction) sortSegmentChanged: (id) sender
{
	if([[ProjectFunctions getUserDefaultValue:@"userName"] length]==0) {
		[ProjectFunctions showAlertPopup:@"Notice" message:@"Please log in to view these features"];
		return;
	}
	[self populateArray];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [userList count];
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
	
	NSString *user = [userList objectAtIndex:indexPath.row];
 //   NSLog(@"%@", user);
	
	NSArray *elements = [user componentsSeparatedByString:@"<xx>"];
    NSString *indexStr = [elements stringAtIndex:0];
    NSString *statsStr = [elements stringAtIndex:1];
    NSString *basics = [elements stringAtIndex:2];
    NSString *lastGame = [elements stringAtIndex:3];
//    NSLog(@"++lastGame: %@", lastGame);
    
    NSArray *statFields = [statsStr componentsSeparatedByString:@"|"];
    NSArray *basicsFields = [basics componentsSeparatedByString:@"|"];
    NSArray *lastGameFields = [lastGame componentsSeparatedByString:@"|"];
	
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
	
//    int hours = [[statFields stringAtIndex:7] intValue]/60;
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
        cell.b2.text = [NSString stringWithFormat:@"PPR: %d", [indexStr intValue]-100];
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


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	[self setTitle:@"Net Tracker"];
    
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
        int friendCount = [[ProjectFunctions getUserDefaultValue:@"FriendsCount"] intValue];
        if(friendCount>1) {
            self.syncButton = [[UIBarButtonItem alloc] initWithTitle:@"Re-Sync" style:UIBarButtonItemStylePlain target:self action:@selector(mainMenuButtonClicked:)];
            self.navigationItem.rightBarButtonItem = self.syncButton;
            
        } else {
            self.navigationItem.rightBarButtonItem = [ProjectFunctions navigationButtonWithTitle:@"Friends" selector:@selector(friendButtonClicked:) target:self];

        }
	}
	
    
	[self startBackgroundProcess];
	
	[ProjectFunctions makeSegment:self.topSegment color:[UIColor colorWithRed:0 green:.5 blue:0 alpha:1]];
	[ProjectFunctions makeSegment:self.sortSegment color:[UIColor colorWithRed:0 green:.5 blue:0 alpha:1]];
	[ProjectFunctions makeSegment:self.timeFrameSegment color:[UIColor colorWithRed:0 green:.5 blue:0 alpha:1]];

	
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if([[ProjectFunctions getUserDefaultValue:@"userName"] length]==0) {
		[ProjectFunctions showAlertPopup:@"Notice" message:@"Please log in to view these features"];
	} else {
		UserSummaryVC *detailViewController = [[UserSummaryVC alloc] initWithNibName:@"UserSummaryVC" bundle:nil];
		detailViewController.managedObjectContext=managedObjectContext;
		detailViewController.user=[userList objectAtIndex:indexPath.row];
        detailViewController.selectedSegment=(int)timeFrameSegment.selectedSegmentIndex;
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
	[self populateArray];

}






@end
