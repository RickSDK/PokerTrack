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
	[self changeNavToIncludeType:34];
	
	[self addHomeButton];
	if(!self.gameObj)
		self.gameObj=self.netUserObj.lastGame;
	
	self.userLabel.text = self.netUserObj.name;
	if(self.gameObj.playFlag)
		self.nowPlayingLabel.text = @"Now PLaying!";
	else
		self.nowPlayingLabel.text = (self.gameObj.profit>=0)?@"Win":@"Loss";
	self.gameTypeLabel.text = self.gameObj.gametype;
	self.lastUpdLabel.text = [NSString stringWithFormat:@"Last Upd: %@", self.gameObj.lastUpdStr];
	
	[self setupData];
}

-(void)setupData {
	self.multiCellObj = [MultiCellObj initWithTitle:self.gameObj.type altTitle:self.gameObj.gametype labelPercent:.4];
	[self.multiCellObj addBlackLineWithTitle:@"location" value:self.gameObj.location];
	[self.multiCellObj addBlackLineWithTitle:@"Game" value:self.gameObj.gametype];
	[self.multiCellObj addBlackLineWithTitle:@"limit" value:self.gameObj.limit];
	if(self.gameObj.stakes && !self.gameObj.tournamentGameFlg)
		[self.multiCellObj addBlackLineWithTitle:@"stakes" value:self.gameObj.stakes];
	[self.multiCellObj addBlackLineWithTitle:@"startTime" value:self.gameObj.startTimeStr];
	[self.multiCellObj addBlackLineWithTitle:@"Buyin" value:self.gameObj.buyInAmountStr];
	[self.multiCellObj addBlackLineWithTitle:@"rebuyAmount" value:self.gameObj.reBuyAmountStr];
	[self.multiCellObj addBlackLineWithTitle:self.gameObj.playFlag?@"Current Chips":@"cashoutAmount" value:self.gameObj.cashoutAmountStr];
	[self.multiCellObj addMoneyLineWithTitle:@"Profit" amount:self.gameObj.profit];
	[self.multiCellObj addBlackLineWithTitle:@"endTime" value:self.gameObj.endTimeStr];
	[self.multiCellObj addBlackLineWithTitle:@"Hours" value:self.gameObj.hours];
	[self.multiCellObj addColoredLineWithTitle:@"Hourly" value:self.gameObj.hourlyStr amount:self.gameObj.profit];
	[self.multiCellObj addColoredLineWithTitle:@"ROI" value:self.gameObj.pprStr amount:self.gameObj.profit];
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
