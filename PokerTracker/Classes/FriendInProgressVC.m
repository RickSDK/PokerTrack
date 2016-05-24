//
//  FriendInProgressVC.m
//  PokerTracker
//
//  Created by Rick Medved on 3/23/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "FriendInProgressVC.h"
#import "FriendDetailVC.h"
#import "NSArray+ATTArray.h"
#import "ProjectFunctions.h"
#import "NSDate+ATTDate.h"
#import "NSString+ATTString.h"
#import "MapKitTut.h"
#import "MultiLineDetailCellWordWrap.h"
#import "ImageCell.h"


@implementation FriendInProgressVC
@synthesize managedObjectContext, mo, mapButton, profitStr, netUserObj;
@synthesize locationLabel, timeLabel, buyinLabel, rebuyLabel, chipsLabel, currentChipsLabel;
@synthesize timeRunningLabel, profitLabel, hourlyLabel, lastUpdLabel, playerTypeImg, nowPlayingLabel;
@synthesize gameTypeLabel, gameSpecslabel, playingFlg, chipAmountLabelString, mainTableView, chipAmountString, profitFlg;
@synthesize gameTypeStr, gpsValues, basicsArray, casinoName, userLabel, gameObj;


-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if([self respondsToSelector:@selector(edgesForExtendedLayout)])
        [self setEdgesForExtendedLayout:UIRectEdgeBottom];
}

-(void)menuButtonClicked:(id)sender {
	[self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	[self setTitle:@"Summary"];
    
    self.basicsArray = [[NSMutableArray alloc] init];
    playerTypeImg = [[UIImageView alloc] init];
	
	NSString *location, *startTime, *playFlg, *gameType, *gameSpecs;
	int buyIn, rebuy, chips;
	int seconds=0;

    gameSpecs = @"";
    location = @"unknown";

    NSDate *lastUpdDate = [NSDate date];
    self.mapButton.alpha=0;
	
	BOOL gameGoing=YES;
    playFlg = @"N";
    self.chipAmountLabelString = @"Profit";
    
	if(mo) {
		NSArray *components = [[mo valueForKey:@"attrib_10"] componentsSeparatedByString:@"|"];
        if([components count]>4) {
            location = [components stringAtIndex:0];
            startTime = [mo valueForKey:@"attrib_09"];
            gameType = [mo valueForKey:@"Type"];
            buyIn = [[components stringAtIndex:2] intValue];
            rebuy = [[components stringAtIndex:3] intValue];
            chips = [[components stringAtIndex:1] intValue];
            seconds = [[components stringAtIndex:4] intValue];
            if([[mo valueForKey:@"status"] isEqualToString:@"In Progress"])
                playFlg = @"Y";
        }
        
	} else {
		NSLog(@"Here: %@", self.netUserObj.lastGameStr);
//        NSArray *segments = [self.userValues componentsSeparatedByString:@"<aa>"];
 //       NSArray *elements = [[segments objectAtIndex:0] componentsSeparatedByString:@"<xx>"];
 //       NSString *basics = [elements stringAtIndex:2];
 //       NSString *lastGame = [elements stringAtIndex:3];
 //       NSArray *basicsFields = [basics componentsSeparatedByString:@"|"];
		
		
        NSArray *lastGameFields = [self.netUserObj.lastGameStr componentsSeparatedByString:@"|"];

//		userName = [basicsFields stringAtIndex:0];
        self.userLabel.text=self.netUserObj.name;
		
		location = [lastGameFields stringAtIndex:4];
		startTime = [lastGameFields stringAtIndex:0];
		playFlg = [lastGameFields stringAtIndex:7];
        lastUpdLabel.text = [NSString stringWithFormat:@"Game Ended: %@", [lastGameFields stringAtIndex:11]];
		buyIn = [[lastGameFields stringAtIndex:1] intValue];
		rebuy = [[lastGameFields stringAtIndex:2] intValue];
		chips = [[lastGameFields stringAtIndex:3] intValue];
		seconds = [[lastGameFields stringAtIndex:8] intValue];
        if(seconds==0)
            seconds = [[lastGameFields stringAtIndex:5] intValue]*60;
		
		if(self.gameObj && self.gameObj.location.length>0) {
			location = self.gameObj.location;
			startTime = [self.gameObj.startTime convertDateToStringWithFormat:nil];
			lastUpdLabel.text = [NSString stringWithFormat:@"Game Ended: %@", [self.gameObj.endTime convertDateToStringWithFormat:nil]];
			buyIn=self.gameObj.buyInAmount;
			rebuy=self.gameObj.reBuyAmount;
			seconds=self.gameObj.minutes*60;
			chips = buyIn+rebuy+self.gameObj.profit;
		}
		
        gameType = [lastGameFields stringAtIndex:6];
        if([lastGameFields count]>10)
            gameSpecs = [NSString stringWithFormat:@"%@ %@ %@", [lastGameFields stringAtIndex:8], [lastGameFields stringAtIndex:9], [lastGameFields stringAtIndex:10]];
        
        if([gameSpecs length]>50)
            gameSpecs=@"";
        
        self.gameTypeStr = gameSpecs;
        
        if([lastGameFields count]>14)
            self.gpsValues = [lastGameFields stringAtIndex:14];
        
        if([self.gpsValues length]>4)
            self.mapButton.alpha=1;

        
        NSString *lastUpdStr = [lastGameFields stringAtIndex:11];
        if([playFlg isEqualToString:@"Y"]) {
            if([lastUpdStr isEqualToString:startTime])
                lastUpdLabel.text = @"Game not updated yet";
            else
                lastUpdLabel.text = @"Game updated 27 min ago";
        }

        
        if([lastUpdStr length]>5)
            lastUpdDate = [lastUpdStr convertStringToDateFinalSolution];
        self.playingFlg=YES;
 		if([[lastGameFields stringAtIndex:7] isEqualToString:@"N"]) {
			if(chips>buyIn+rebuy)
				nowPlayingLabel.text = @"Win";
			if(chips<buyIn+rebuy)
				nowPlayingLabel.text = @"Loss";
			if(chips==buyIn+rebuy)
				nowPlayingLabel.text = @"Broke Even";
			gameGoing=NO;
            self.playingFlg=NO;
		}
	}
	
	locationLabel.text = location;
	
	
	int minutes = seconds / 60;
    NSString *startTimeString = startTime;
	
	if([playFlg isEqualToString:@"Y"] && [startTime length]>5) {
		NSDate *startDate = [startTime convertStringToDateWithFormat:nil];
		timeLabel.text = [startDate convertDateToStringWithFormat:@"hh:mm a"];
		minutes = [[NSDate date] timeIntervalSinceDate:startDate]/60;
        startTimeString = [startDate convertDateToStringWithFormat:@"hh:mm a"];
	}
	
	buyinLabel.text = [ProjectFunctions convertIntToMoneyString:buyIn];
	rebuyLabel.text = [ProjectFunctions convertIntToMoneyString:rebuy];
    self.chipAmountString = [ProjectFunctions convertIntToMoneyString:chips];
	chipsLabel.text = self.chipAmountString;
    gameTypeLabel.text = gameType;
    gameSpecslabel.text = gameSpecs;
	
    self.casinoName = location;

	
    NSString *played = @"Played";
	if(gameGoing) {
        int minutesUpd=[[NSDate date] timeIntervalSinceDate:lastUpdDate]/60;
        if(minutesUpd>0)
            lastUpdLabel.text = [NSString stringWithFormat:@"Last Update: %d %@ ago", minutesUpd, (minutesUpd==1)?@"minute":@"minutes"];
        played = @"Playing";
        if(minutesUpd>minutes)
            minutes=minutesUpd;
    }
    
    NSString *timeRunning = @"";
	if(minutes>0)
		timeRunning= [NSString stringWithFormat:@"(%@ %d minutes)", played, minutes];
	if(minutes>60)
		timeRunning = [NSString stringWithFormat:@"(%@ %.1f hours)", played, (float)minutes/60];
	if(minutes<0)
		timeRunning = @"(Local Time)";

    timeRunningLabel.text = timeRunning;
	[self.basicsArray addObject:[MultiLineDetailCellWordWrap multiObjectWithName:@"Location" value:location color:[UIColor blackColor]]];
	[self.basicsArray addObject:[MultiLineDetailCellWordWrap multiObjectWithName:@"Started" value:startTimeString color:[UIColor blackColor]]];
	[self.basicsArray addObject:[MultiLineDetailCellWordWrap multiObjectWithName:@"Hours Played" value:timeRunning color:[UIColor blackColor]]];
	[self.basicsArray addObject:[MultiLineDetailCellWordWrap multiObjectWithName:@"Buyin Amount" value:[ProjectFunctions convertIntToMoneyString:buyIn] color:[UIColor blackColor]]];
	[self.basicsArray addObject:[MultiLineDetailCellWordWrap multiObjectWithName:@"Rebuy Amount" value:[ProjectFunctions convertIntToMoneyString:rebuy] color:[UIColor blackColor]]];

	

	if(!gameGoing) {
		timeLabel.text = startTime;
    }
	
	int profit = chips-buyIn-rebuy;
    if(profit>=0)
        self.profitFlg=YES;
	
	UIColor *profitColor = (profit>=0)?[UIColor colorWithRed:0 green:.5 blue:0 alpha:1]:[UIColor redColor];
	
	playerTypeImg.image = [ProjectFunctions getPlayerTypeImage:buyIn+rebuy winnings:profit];
	[ProjectFunctions updateMoneyLabel:profitLabel money:profit];

    self.profitStr = [ProjectFunctions convertIntToMoneyString:profit];
    
	NSString *chipsStr = (self.playingFlg)?@"Current Chips":@"Cashed Out";
	[self.basicsArray addObject:[MultiLineDetailCellWordWrap multiObjectWithName:chipsStr value:[ProjectFunctions convertIntToMoneyString:chips] color:profitColor]];
	
   
    NSString *hourly = @"-";
	if(minutes>0)
		hourly = [NSString stringWithFormat:@"$%d/hr", profit*60/minutes];
    
	[self.basicsArray addObject:[MultiLineDetailCellWordWrap multiObjectWithName:@"Hourly" value:hourly color:profitColor]];
	
    hourlyLabel.text = hourly;

	UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] initWithTitle:@"Main Menu" style:UIBarButtonItemStylePlain target:self action:@selector(menuButtonClicked:)];
	self.navigationItem.rightBarButtonItem = menuButton;
    
    [mainTableView reloadData];
	
	 
}
/*
-(NSString *)objectForAdding:(NSString *)obj {
    if(obj)
        return obj;
    else
        return @"Error";
}
*/
- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return CGFLOAT_MIN;
}


-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *cellIdentifier = [NSString stringWithFormat:@"cellIdentifierSection%dRow%d", (int)indexPath.section, (int)indexPath.row];
    
    if(indexPath.row==0) {
         MultiLineDetailCellWordWrap *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if(cell==nil)
            cell = [[MultiLineDetailCellWordWrap alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier withRows:self.basicsArray.count labelProportion:0.35];
        
		cell.mainTitle = self.gameTypeStr;
		cell.alternateTitle = self.gameTypeLabel.text;
		cell.titleTextArray = [MultiLineDetailCellWordWrap arrayOfType:0 objList:self.basicsArray];
		cell.fieldTextArray = [MultiLineDetailCellWordWrap arrayOfType:1 objList:self.basicsArray];
		cell.fieldColorArray = [MultiLineDetailCellWordWrap arrayOfType:2 objList:self.basicsArray];

        
        cell.accessoryType= UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    if(indexPath.row==1) {
        ImageCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if(cell==nil)
            cell = [[ImageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        
        cell.imageView.image = playerTypeImg.image;
        cell.nameLabel.text = self.profitStr;
        cell.cityLabel.text = self.chipAmountLabelString;
        
        [cell.nameLabel setShadowColor:[UIColor whiteColor]];

        if(self.profitFlg) {
            cell.backgroundColor = [UIColor colorWithRed:.7 green:.9 blue:.7 alpha:1];
            cell.nameLabel.textColor = [UIColor colorWithRed:0 green:.5 blue:0 alpha:1];
        } else {
            cell.backgroundColor = [UIColor colorWithRed:.9 green:.7 blue:.7 alpha:1];
            cell.nameLabel.textColor = [UIColor colorWithRed:.5 green:0 blue:0 alpha:1];
        }
        
        cell.accessoryType= UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
	
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	
    if(indexPath.row==0)
		return [MultiLineDetailCellWordWrap cellHeightForMultiCellData:self.basicsArray
															 tableView:tableView
												  labelWidthProportion:0.35];

	return 90;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row>0)
        return;
    
	NSArray *items = [self.gpsValues componentsSeparatedByString:@":"];
    if([items count]>1) {
        MapKitTut *detailViewController = [[MapKitTut alloc] initWithNibName:@"MapKitTut" bundle:nil];
        detailViewController.lat = [[items stringAtIndex:0] floatValue];
        detailViewController.lng = [[items stringAtIndex:1] floatValue];
        [self.navigationController pushViewController:detailViewController animated:YES];
    }
}


- (IBAction) mapPressed: (id) sender
{
    NSLog(@"+++%@", self.gpsValues);
    
	NSArray *items = [self.gpsValues componentsSeparatedByString:@":"];
    if([items count]>1) {
        MapKitTut *detailViewController = [[MapKitTut alloc] initWithNibName:@"MapKitTut" bundle:nil];
        detailViewController.lat = [[items stringAtIndex:0] floatValue];
        detailViewController.lng = [[items stringAtIndex:1] floatValue];
        [self.navigationController pushViewController:detailViewController animated:YES];
    }
    
}




@end
