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

-(void)menuButtonClicked:(id)sender {
	[self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	[self setTitle:@"Game Summary"];
	
	[self addHomeButton];
	if(!self.gameObj)
		self.gameObj=self.netUserObj.lastGame;
	
	self.userLabel.text = self.netUserObj.name;
	if(self.netUserObj.nowPlayingFlg)
		self.nowPlayingLabel.text = @"Now PLaying!";
	else
		self.nowPlayingLabel.text = (self.gameObj.profit>=0)?@"Win":@"Loss";
	self.gameTypeLabel.text = self.gameObj.gametype;
	self.lastUpdLabel.text = [NSString stringWithFormat:@"Last Upd: %@", self.gameObj.lastUpdStr];
	
	[self setupData];
}

-(void)setupData {
	NSString *stakes = @"-";
	if(self.gameObj.stakes && !self.gameObj.tournamentGameFlg)
		stakes = self.gameObj.stakes;
	NSArray *values = [NSArray arrayWithObjects:
					   self.gameObj.location,
					   self.gameObj.gametype,
					   self.gameObj.limit,
					   stakes,
					   self.gameObj.startTimeStr,
					   self.gameObj.buyInAmountStr,
					   self.gameObj.reBuyAmountStr,
					   self.gameObj.cashoutAmountStr,
					   self.gameObj.profitStr,
					   self.gameObj.endTimeStr,
					   self.gameObj.hours,
					   self.gameObj.hourlyStr,
					   self.gameObj.pprStr,
					   nil];
	NSArray *titles = [NSArray arrayWithObjects:
					   NSLocalizedString(@"location", nil),
					   NSLocalizedString(@"game", nil),
					   NSLocalizedString(@"limit", nil),
					   NSLocalizedString(@"stakes", nil),
					   NSLocalizedString(@"startTime", nil),
					   NSLocalizedString(@"Buyin", nil),
					   NSLocalizedString(@"rebuyAmount", nil),
					   NSLocalizedString(@"chips", nil),
					   NSLocalizedString(@"profit", nil),
					   NSLocalizedString(@"endTime", nil),
					   NSLocalizedString(@"Hours", nil),
					   NSLocalizedString(@"Hourly", nil),
					   NSLocalizedString(@"ROI", nil),
					   nil];
	NSArray *colors =  [NSArray arrayWithObjects:
						[UIColor blackColor],
						[UIColor blackColor],
						[UIColor blackColor],
						[UIColor blackColor],
						[UIColor blackColor],
						[UIColor blackColor],
						[UIColor blackColor],
						[UIColor blackColor],
						[ProjectFunctions colorForProfit:self.gameObj.profit],
						[UIColor blackColor],
						[UIColor blackColor],
						[ProjectFunctions colorForProfit:self.gameObj.profit],
						[ProjectFunctions colorForProfit:self.gameObj.profit],
						nil];
	
	self.multiCellObj = [MultiCellObj multiCellObjWithTitle:self.gameObj.type altTitle:self.gameObj.gametype titles:titles values:values colors:colors labelPercent:.4];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *cellIdentifier = [NSString stringWithFormat:@"cellIdentifierSection%dRow%d", (int)indexPath.section, (int)indexPath.row];
    
    if(indexPath.row==0) {
		return [MultiLineDetailCellWordWrap multiCellForID:cellIdentifier obj:self.multiCellObj tableView:tableView];
	}
    if(indexPath.row==1) {
        ImageCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if(cell==nil)
            cell = [[ImageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        
        cell.leftImage.image = [ProjectFunctions getPtpPlayerTypeImage:self.gameObj.risked winnings:self.gameObj.profit iconGroupNumber:self.netUserObj.iconGroupNumber];
        cell.nameLabel.text = self.gameObj.profitStr;
        cell.cityLabel.text = [NSString stringWithFormat:@"Chips: %@", self.gameObj.cashoutAmountStr];
        
        [cell.nameLabel setShadowColor:[UIColor whiteColor]];

        if(self.gameObj.profit>=0) {
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
		return [MultiLineDetailCellWordWrap heightForMultiCellObj:self.multiCellObj tableView:tableView];

	return 90;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row>0)
        return;
}

@end
