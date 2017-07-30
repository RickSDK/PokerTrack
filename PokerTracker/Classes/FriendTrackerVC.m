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
#import "NetUserObj.h"

@interface FriendTrackerVC ()

@end

@implementation FriendTrackerVC
@synthesize managedObjectContext;
@synthesize chartImageView;
@synthesize datelabel, mainTableView, topSegment, friendButton, friendModeOn;
@synthesize sortSegment, processYear, processMonth, timeFrameSegment;
@synthesize chartLast10ImageView, chartThisMonthImageView, playerDict, showRefreshFlg;

- (void)viewDidLoad {
	[super viewDidLoad];
	[self setTitle:@"Friends"];
	[self changeNavToIncludeType:4];

	timeFrameSegment.selectedSegmentIndex=1;

	self.playerDict = [[NSMutableDictionary alloc] init];
	
	
	chartLast10ImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"chart.png"]];
	chartThisMonthImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"chart.png"]];
	chartImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"chart.png"]];
	
	chartLast10ImageView.alpha=1;
	chartThisMonthImageView.alpha=1;
	chartImageView.alpha=1;
	
	self.processMonth = [[[NSDate date] convertDateToStringWithFormat:@"MM"] intValue];
	self.processYear = [[[NSDate date] convertDateToStringWithFormat:@"yyyy"] intValue];
	self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:
												   [ProjectFunctions UIBarButtonItemWithIcon:[NSString fontAwesomeIconStringForEnum:FAPlus] target:self action:@selector(createPressed)],
												   [ProjectFunctions UIBarButtonItemWithIcon:[NSString fontAwesomeIconStringForEnum:FAInfoCircle] target:self action:@selector(popupButtonClicked)],
												   nil];
		
		self.popupView.titleLabel.text = self.title;
		self.popupView.textView.text = @"Add friends here and you can compare stats! You can also be notified when your friend is starting a new game and even view their chip stack in real time!";
		self.popupView.textView.hidden=NO;
	
	self.addFriendView.hidden=YES;

	[self startBackgroundProcess];
}

- (IBAction) xButtonPressed: (id) sender {
	self.addFriendView.hidden=YES;
}

-(void)populateArray
{
    if(timeFrameSegment.selectedSegmentIndex==0) {
        datelabel.text = NSLocalizedString(@"Last10", nil);
    }
    if(timeFrameSegment.selectedSegmentIndex==1) {
        datelabel.text = NSLocalizedString(@"month", nil);
    }
    if(timeFrameSegment.selectedSegmentIndex==2) {
        datelabel.text = [NSString stringWithFormat:@"Last 90 %@", NSLocalizedString(@"day", nil)];
    }
	[mainTableView reloadData];
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

-(void)backgroundProcess
{
	@autoreleasepool {

		//   [ProjectFunctions uploadUniverseStats:managedObjectContext];
		
		NSArray *nameList = [NSArray arrayWithObjects:@"Username", @"Password", @"localFlg", @"dateText", @"friendFlg", nil];
		
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
		NSArray *valueList = [NSArray arrayWithObjects:username, password, @"N", dateText, friendFlg, nil];
		NSString *webAddr = @"http://www.appdigity.com/poker/pokerFriendTracker.php";
		NSString *responseStr = [WebServicesFunctions getResponseFromServerUsingPost:webAddr fieldList:nameList valueList:valueList];
		if([WebServicesFunctions validateStandardResponse:responseStr delegate:nil]) {
			[self.mainArray removeAllObjects];
            NSArray *users = [responseStr componentsSeparatedByString:@"<br>"];
			for(NSString *line in users)
				if([line length]>20) {
					NetUserObj *obj = [NetUserObj friendObjFromLine:line];
//					NSLog(@"---line---%@", line);
					NSLog(@"---%@ monthStats---%@", obj.name, obj.monthStats);
					[self.mainArray addObject:obj];
					
					[data appendFormat:@"%@<1>%@+", obj.name, obj.last90Days];
					[dataLast10 appendFormat:@"%@<1>%@+", obj.name, obj.last10Games];
					[dataThisMonth appendFormat:@"%@<1>%@+", obj.name, obj.thisMonthGames];
				}
		}
		
		chartImageView = [GrabphLib graphStatsChart:self.managedObjectContext data:data type:0];
		chartLast10ImageView = [GrabphLib graphStatsChart:self.managedObjectContext data:dataLast10 type:1];
		chartThisMonthImageView = [GrabphLib graphStatsChart:self.managedObjectContext data:dataThisMonth type:2];
		
		NSArray *players = [data componentsSeparatedByString:@"+"];
		int i=0;
		for(NSString *player in players) {
			NSArray *components = [player componentsSeparatedByString:@"<1>"];
			if([components count]>1) {
				[self.playerDict setValue:[NSString stringWithFormat:@"%d", i] forKey:[components objectAtIndex:0]];
				i++;
			}
		}
		[self.webServiceView stop];
		[self checkSortingOrder];
	}
}

-(void)startBackgroundProcess
{
	[self.webServiceView startWithTitle:@"Loading..."];
	[self performSelectorInBackground:@selector(backgroundProcess) withObject:nil];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (IBAction) sortSegmentChanged: (id) sender
{
	[self checkSortingOrder];
}

-(void)checkSortingOrder {
	if(self.sortSegment.selectedSegmentIndex==0)
		self.mainArray = [NSMutableArray arrayWithArray:[self.mainArray sortedArrayUsingSelector:@selector(compare:)]];
	if(self.sortSegment.selectedSegmentIndex==1)
		self.mainArray = [NSMutableArray arrayWithArray:[self.mainArray sortedArrayUsingSelector:@selector(comparePpr:)]];
	if(self.sortSegment.selectedSegmentIndex==2)
		self.mainArray = [NSMutableArray arrayWithArray:[self.mainArray sortedArrayUsingSelector:@selector(compareGames:)]];
	[self populateArray];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section==0)
        return 1;
    else
        return self.mainArray.count;
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
	} else {
		HexWithImageCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
		if (cell == nil) {
			cell = [[HexWithImageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
		}
		
		NetUserObj *netUserObj = [self.mainArray objectAtIndex:indexPath.row];
		netUserObj.rowId = (int)indexPath.row+1;
		netUserObj.sortType = (int)sortSegment.selectedSegmentIndex;
		cell = [HexWithImageCell cellForCell:cell netUserObj:netUserObj];
		cell.backgroundColor = [self colorForCellOnNumber:[[self.playerDict valueForKey:netUserObj.name] intValue]];
		return cell;
	}
}

-(UIColor *)colorForCellOnNumber:(int)number { 
    switch (number%9) {
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
		case 8:
			return [UIColor colorWithRed:1 green:.9 blue:1 alpha:1];
			break;
			
        default:
            break;
    }
    return [UIColor colorWithRed:1 green:.9 blue:1 alpha:1];
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

- (void)createPressed {
	self.addFriendView.hidden=!self.addFriendView.hidden;
	[self.mainTextfield	becomeFirstResponder];
}

- (IBAction) addButtonPressed: (id) sender {
	if(self.mainTextfield.text.length==0) {
		[ProjectFunctions showAlertPopup:@"Invalid Email Address" message:@""];
		return;
	}
	[self.mainTextfield resignFirstResponder];
	self.addFriendView.hidden=YES;
	[self startWebService:@selector(addFriendFunction) message:@"Working..."];
}

-(void)addFriendFunction {
	@autoreleasepool {
		NSArray *nameList = [NSArray arrayWithObjects:@"Username", @"Password", @"friendEmail", nil];
		
		NSArray *valueList = [NSArray arrayWithObjects:[ProjectFunctions getUserDefaultValue:@"userName"], [ProjectFunctions getUserDefaultValue:@"password"], self.mainTextfield.text, nil];
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
			[ProjectFunctions showAlertPopup:@"ERROR" message:responseStr];
		}
		[self stopWebService];
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section==0) {
        return;
    }
	UserSummaryVC *detailViewController = [[UserSummaryVC alloc] initWithNibName:@"UserSummaryVC" bundle:nil];
	detailViewController.managedObjectContext=managedObjectContext;
	detailViewController.netUserObj=[self.mainArray objectAtIndex:indexPath.row];
	[self.navigationController pushViewController:detailViewController animated:YES];
}

- (IBAction) timeSegmentChanged: (id) sender
{
	for(NetUserObj *obj in self.mainArray) {
		switch (self.timeFrameSegment.selectedSegmentIndex) {
			case 0:
    [NetUserObj populateGameStats:obj line:obj.last10Str type:(int)self.timeFrameSegment.selectedSegmentIndex];
    break;
			case 1:
    [NetUserObj populateGameStats:obj line:obj.monthStats type:(int)self.timeFrameSegment.selectedSegmentIndex];
    break;
			case 2:
    [NetUserObj populateGameStats:obj line:obj.yearStats type:(int)self.timeFrameSegment.selectedSegmentIndex];
    break;
				
			default:
    break;
		}
	}
	[self checkSortingOrder];
}

//710 lines
@end
