//
//  BigHandCell.h
//  PokerTracker
//
//  Created by Rick Medved on 8/5/17.
//
//

#import <UIKit/UIKit.h>
#import "BigHandObj.h"

@interface BigHandCell : UITableViewCell

@property (nonatomic, strong) UIImageView *card1BG;
@property (nonatomic, strong) UIImageView *card2BG;
@property (nonatomic, strong) UIImageView *suit1Image;
@property (nonatomic, strong) UIImageView *suit2Image;
@property (nonatomic, strong) UILabel *card1Label;
@property (nonatomic, strong) UILabel *card2Label;
@property (nonatomic, strong) UILabel *card1SuitLabel;
@property (nonatomic, strong) UILabel *card2SuitLabel;

@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) UILabel *potSizeLabel;

+(UITableViewCell *)cellForBigHand:(BigHandObj *)obj cellIdentifier:(NSString *)cellIdentifier tableView:(UITableView *)tableView;

@end
