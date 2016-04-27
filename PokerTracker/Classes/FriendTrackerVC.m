//
//  FriendTrackerVC.m
//  PokerTracker
//
//  Created by Rick Medved on 4/29/13.
//
//

#import "FriendTrackerVC.h"
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
#import "GrabphLib.h"
#import "UniverseTrackerVC.h"

@interface FriendTrackerVC ()

@end

@implementation FriendTrackerVC
@synthesize managedObjectContext;
@synthesize activityIndicator, activityLabel, activityPopup, chartImageView;
@synthesize datelabel, userList, mainTableView, topSegment, profileButton, friendList, friendButton, friendModeOn;
@synthesize profitList, moneyList, gamesList, sortSegment, prevButton, nextButton, processYear, processMonth, timeFrameSegment;
@synthesize last10MoneyAllList, last10ProfitAllList, last10GamesAllList, monthMoneyAllList, monthProfitAllList, monthGamesAllList;
@synthesize yearMoneyFriendsList, yearProfitFriendsList, yearGamesFriendsList;
@synthesize chartLast10ImageView, chartThisMonthImageView, refreshButton, playerDict, blackBG, showRefreshFlg;



-(void)populateArray
{
    
    if(timeFrameSegment.selectedSegmentIndex==0) {
        datelabel.text = @"Last 10";
    }
    if(timeFrameSegment.selectedSegmentIndex==1) {
        datelabel.text = @"This Month";
    }
    if(timeFrameSegment.selectedSegmentIndex==2) {
        datelabel.text = @"Last 90 Days";
    }
    
	[self.userList removeAllObjects];
    
    
    switch (timeFrameSegment.selectedSegmentIndex) {
        case 0: //Last10
            if(sortSegment.selectedSegmentIndex==0)
                [self.userList addObjectsFromArray:[NSMutableArray arrayWithArray:[ProjectFunctions sortArrayDescending:last10MoneyAllList]]];
            if(sortSegment.selectedSegmentIndex==1)
                [self.userList addObjectsFromArray:[NSMutableArray arrayWithArray:[ProjectFunctions sortArrayDescending:last10ProfitAllList]]];
            if(sortSegment.selectedSegmentIndex==2)
                [self.userList addObjectsFromArray:[NSMutableArray arrayWithArray:[ProjectFunctions sortArrayDescending:last10GamesAllList]]];
            break;
        case 1: // Month
            if(sortSegment.selectedSegmentIndex==0)
                [self.userList addObjectsFromArray:[NSMutableArray arrayWithArray:[ProjectFunctions sortArrayDescending:monthMoneyAllList]]];
            if(sortSegment.selectedSegmentIndex==1)
                [self.userList addObjectsFromArray:[NSMutableArray arrayWithArray:[ProjectFunctions sortArrayDescending:monthProfitAllList]]];
            if(sortSegment.selectedSegmentIndex==2)
                [self.userList addObjectsFromArray:[NSMutableArray arrayWithArray:[ProjectFunctions sortArrayDescending:monthGamesAllList]]];
            break;
        case 2: // Year
            if(sortSegment.selectedSegmentIndex==0)
                [self.userList addObjectsFromArray:[NSMutableArray arrayWithArray:[ProjectFunctions sortArrayDescending:yearMoneyFriendsList]]];
            if(sortSegment.selectedSegmentIndex==1)
                [self.userList addObjectsFromArray:[NSMutableArray arrayWithArray:[ProjectFunctions sortArrayDescending:yearProfitFriendsList]]];
            if(sortSegment.selectedSegmentIndex==2)
                [self.userList addObjectsFromArray:[NSMutableArray arrayWithArray:[ProjectFunctions sortArrayDescending:yearGamesFriendsList]]];
            break;
            
        default:
            break;
    }
    

    [ProjectFunctions setUserDefaultValue:[NSString stringWithFormat:@"%d", (int)[self.userList count]] forKey:@"FriendsCount"];
    
    
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

-(void)uploadStatsFunction
{
	@autoreleasepool {
        BOOL success = [ProjectFunctions uploadUniverseStats:managedObjectContext];
		if(success)
			[ProjectFunctions showAlertPopup:@"Success" message:@""];
		[self performSelectorInBackground:@selector(backgroundProcess) withObject:nil];
	}
}

- (IBAction) refreshButtonPressed: (id) sender
{
	[activityIndicator startAnimating];
	activityLabel.alpha=1;
	activityPopup.alpha=1;
    self.refreshButton.alpha=0;
	
	[self performSelectorInBackground:@selector(uploadStatsFunction) withObject:nil];
 }

-(void)backgroundProcess
{
	@autoreleasepool {

 //   [ProjectFunctions uploadUniverseStats:managedObjectContext];

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
        
//    NSString *thisDateString = [NSString stringWithFormat:@"%02d/1/%d", processMonth, processYear];
//    NSDate *thisdate = [thisDateString convertStringToDateWithFormat:@"MM/dd/yyyy"];
        NSString *currentMonth = [[NSDate date] convertDateToStringWithFormat:@"MMM yyyy"];
        
	NSArray *nameList = [NSArray arrayWithObjects:@"Username", @"Password", @"localFlg", @"dateText", @"friendFlg", nil];
	NSString *localFlg=@"N";
	if(topSegment.selectedSegmentIndex==1)
		localFlg=@"Y";
        
        NSString *dateText = [NSString stringWithFormat:@"%d%02d", processYear, processMonth];
	
	NSString *username = [ProjectFunctions getUserDefaultValue:@"userName"];
	NSString *password = [ProjectFunctions getUserDefaultValue:@"password"];
	if([username length]==0) {
		username = @"test@aol.com";
		password = @"test123";
	}
        NSMutableString *data = [[NSMutableString alloc] initWithCapacity:5000];
        NSMutableString *dataLast10 = [[NSMutableString alloc] initWithCapacity:5000];
        NSMutableString *dataThisMonth = [[NSMutableString alloc] initWithCapacity:5000];
	NSString *friendFlg = @"Y";
	NSArray *valueList = [NSArray arrayWithObjects:username, password, localFlg, dateText, friendFlg, nil];
	NSString *webAddr = @"http://www.appdigity.com/poker/pokerFriendTracker.php";
	NSString *responseStr = [WebServicesFunctions getResponseFromServerUsingPost:webAddr fieldList:nameList valueList:valueList];
        NSLog(@"Size of response: %d", (int)[responseStr length]);
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
                    //               NSLog(@"%@", line);
                    NSArray *elements = [line componentsSeparatedByString:@"<xx>"];
                    NSString *basics = [elements stringAtIndex:0];
                    NSString *last10 = [elements stringAtIndex:1];
                    NSString *monthStats = [elements stringAtIndex:3];
                    NSString *yearStats = [elements stringAtIndex:2];
                    NSString *lastGame = [elements stringAtIndex:4];
                    NSString *last90Days = [elements stringAtIndex:5];
                    NSString *thisMonthGames = [elements stringAtIndex:6];
                    NSString *last10Games = [elements stringAtIndex:7];
                    //                NSLog(@"%@", lastGame);
                    
                    //              NSLog(@"monthStats %@", monthStats);
                    NSArray *last10Elements = [last10 componentsSeparatedByString:@"|"];
                    NSArray *yearElements = [yearStats componentsSeparatedByString:@"|"];
                    NSArray *monthElements = [monthStats componentsSeparatedByString:@"|"];
                    NSArray *basicsElements = [basics componentsSeparatedByString:@"|"];

                    [data appendFormat:@"%@<1>%@+", [basicsElements stringAtIndex:0], last90Days];
                    [dataLast10 appendFormat:@"%@<1>%@+", [basicsElements stringAtIndex:0], last10Games];
                    [dataThisMonth appendFormat:@"%@<1>%@+", [basicsElements stringAtIndex:0], thisMonthGames];

                    int gamesThisMonth = [[monthElements stringAtIndex:2] intValue];
                    
                    NSString *status = [basicsElements stringAtIndex:7];
                    if([status isEqualToString:@"Request Pending"])
                        [ProjectFunctions showAlertPopup:@"New Friend Request!" message:[NSString stringWithFormat:@"%@ has requested to be your friend. Find that person below and click on the link.", [basicsElements stringAtIndex:0]]];
                    
                    NSString *lastMonthUpd = [monthElements stringAtIndex:0];
                    //              NSLog(@"%@ %@", currentMonth, lastMonthUpd);
                    
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
        
        UIImageView *img = [GrabphLib graphStatsChart:self.managedObjectContext data:data type:0];
        UIImageView *imgLast10 = [GrabphLib graphStatsChart:self.managedObjectContext data:dataLast10 type:1];
        UIImageView *imgThisMonth = [GrabphLib graphStatsChart:self.managedObjectContext data:dataThisMonth type:2];
	
        chartImageView.image = img.image;
        chartLast10ImageView.image = imgLast10.image;
        chartThisMonthImageView.image = imgThisMonth.image;
        




        NSArray *players = [data componentsSeparatedByString:@"+"];
        int i=0;
        for(NSString *player in players) {
            NSArray *components = [player componentsSeparatedByString:@"<1>"];
            if([components count]>1) {
                [self.playerDict setValue:[NSString stringWithFormat:@"%d", i] forKey:[components objectAtIndex:0]];
                i++;
            }
        }
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

-(void)mainMenuButtonClicked:(id)sender {
	[self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
}

-(void)netTrackerButtonClicked:(id)sender {
    UniverseTrackerVC *detailViewController = [[UniverseTrackerVC alloc] initWithNibName:@"UniverseTrackerVC" bundle:nil];
    detailViewController.managedObjectContext = managedObjectContext;
    [self.navigationController pushViewController:detailViewController animated:YES];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
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
    if(section==0)
        return 1;
    else
        return [self.userList count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section==0)
        return 200;
    else
        return 55;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *cellIdentifier = [NSString stringWithFormat:@"cellIdentifierSection%dRow%d", (int)indexPath.section, (int)indexPath.row];
    
    if(indexPath.section==0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if(cell==nil)
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];

        switch (timeFrameSegment.selectedSegmentIndex) {
            case 0:
                cell.backgroundView = chartLast10ImageView;
                break;
            case 1:
                cell.backgroundView = chartThisMonthImageView;
                break;
            case 2:
                cell.backgroundView = chartImageView;
                break;
                
            default:
                break;
        }
        
        
        cell.backgroundColor = [UIColor whiteColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }

    HexWithImageCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[HexWithImageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    
    NSString *user = [self.userList objectAtIndex:indexPath.row];
    //   NSLog(@"%@", user);
	
	NSArray *elements = [user componentsSeparatedByString:@"<xx>"];
    NSString *indexStr = [elements stringAtIndex:0];
    NSString *statsStr = [elements stringAtIndex:1];
    NSString *basics = [elements stringAtIndex:2];
    NSString *lastGame = [elements stringAtIndex:3];
    //    NSLog(@"%@ [%@]", basics, @"");
    
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
        cell.b2.text = [NSString stringWithFormat:@"ROI: %d%%", [indexStr intValue]-100];
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

    NSString *name = [basicsFields stringAtIndex:0];
    
    cell.backgroundColor = [self colorForCellOnNumber:[[self.playerDict valueForKey:name] intValue]];

	return cell;
}

-(UIColor *)colorForCellOnNumber:(int)number { 
    switch (number) {
        case 0:
            return [UIColor colorWithRed:1 green:.8 blue:.8 alpha:1];
            break;
        case 1:
            return [UIColor colorWithRed:.8 green:1 blue:.8 alpha:1];
            break;
        case 2:
            return [UIColor colorWithRed:.8 green:.8 blue:1 alpha:1];
            break;
        case 3:
            return [UIColor colorWithRed:1 green:1 blue:.8 alpha:1];
            break;
        case 4:
            return [UIColor colorWithRed:.8 green:1 blue:1 alpha:1];
            break;
        case 5:
            return [UIColor colorWithRed:1 green:.8 blue:1 alpha:1];
            break;
        case 6:
            return [UIColor colorWithRed:.8 green:1 blue:.9 alpha:1];
            break;
        case 7:
            return [UIColor colorWithRed:1 green:.8 blue:.7 alpha:1];
            break;
            
        default:
            break;
    }
    return [UIColor colorWithRed:1 green:.9 blue:1 alpha:1];
}

- (IBAction) segmentChanged: (id) sender
{
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



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	[self setTitle:@"Friends"];
 
    self.userList = [[NSMutableArray alloc] init];

    self.playerDict = [[NSMutableDictionary alloc] init];
    self.datelabel.text = @"This Month";
    
    
    timeFrameSegment.selectedSegmentIndex=1;
    
    chartLast10ImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"chart.png"]];
    chartThisMonthImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"chart.png"]];
    chartImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"chart.png"]];

    chartLast10ImageView.alpha=1;
    chartThisMonthImageView.alpha=1;
    chartImageView.alpha=1;
    self.blackBG.alpha=0;
    self.refreshButton.alpha=0;

	
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
	
	self.profitList = [[NSMutableArray alloc] init];
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
            self.navigationItem.rightBarButtonItem = [ProjectFunctions navigationButtonWithTitle:@"Net Tracker" selector:@selector(netTrackerButtonClicked:) target:self];
            
        } else {
            self.navigationItem.rightBarButtonItem = [ProjectFunctions navigationButtonWithTitle:@"Main Menu" selector:@selector(mainMenuButtonClicked:) target:self];

        }
	}
	
    
	[self startBackgroundProcess];
	
	[ProjectFunctions makeSegment:self.timeFrameSegment color:[UIColor colorWithRed:.8 green:.7 blue:0 alpha:1]];
	[ProjectFunctions makeSegment:self.sortSegment color:[UIColor colorWithRed:0 green:.5 blue:0 alpha:1]];

	
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.showRefreshFlg=!self.showRefreshFlg;
    if(self.showRefreshFlg)
        self.refreshButton.alpha=1;
    else
        self.refreshButton.alpha=0;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section==0) {
        self.showRefreshFlg=!self.showRefreshFlg;
        if(self.showRefreshFlg)
            self.refreshButton.alpha=1;
        else
            self.refreshButton.alpha=0;
        return;
    }
    
	if([[ProjectFunctions getUserDefaultValue:@"userName"] length]==0) {
		[ProjectFunctions showAlertPopup:@"Notice" message:@"Please log in to view these features"];
	} else {
		UserSummaryVC *detailViewController = [[UserSummaryVC alloc] initWithNibName:@"UserSummaryVC" bundle:nil];
		detailViewController.managedObjectContext=managedObjectContext;
		detailViewController.user=[self.userList objectAtIndex:indexPath.row];
        detailViewController.selectedSegment=(int)timeFrameSegment.selectedSegmentIndex;
		[self.navigationController pushViewController:detailViewController animated:YES];
	}
}

- (IBAction) timeSegmentChanged: (id) sender
{
    
	[self populateArray];
    
}




-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if([self respondsToSelector:@selector(edgesForExtendedLayout)])
        [self setEdgesForExtendedLayout:UIRectEdgeBottom];
}



- (void)dealloc {
    playerDict=nil;
    
    
    
}

@end
