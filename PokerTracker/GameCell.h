//
//  GameCell.h
//  PokerTracker
//
//  Created by Rick Medved on 7/24/15.
//
//

#import <UIKit/UIKit.h>
#import "GameObj.h"

@interface GameCell : UITableViewCell

@property (nonatomic, retain) UIImageView *profitImageView;
@property (nonatomic, retain) UIView *bgView;
@property (nonatomic, retain) UILabel *faLabel;
@property (nonatomic, retain) UILabel *nameLabel;
@property (nonatomic, retain) UILabel *dateLabel;
@property (nonatomic, retain) UILabel *hoursLabel;
@property (nonatomic, retain) UILabel *locationLabel;
@property (nonatomic, retain) UILabel *profitLabel;
@property (nonatomic, retain) UILabel *roiLabel;
@property (nonatomic, retain) UILabel *pprLabel;
@property (nonatomic, retain) UILabel *hudTypeLabel;

+ (void) layoutSubviews:(CGRect)cellRect
			  nameLabel:(UILabel *)nameLabel
			  dateLabel:(UILabel *)dateLabel
		  locationLabel:(UILabel *)locationLabel
			 hoursLabel:(UILabel *)hoursLabel
			profitLabel:(UILabel *)profitLabel;

+(void)populateCell:(GameCell *)cell obj:(NSManagedObject *)mo evenFlg:(BOOL)evenFlg;
+(void)populateGameCell:(GameCell *)cell gameObj:(GameObj *)gameObj evenFlg:(BOOL)evenFlg;
+(UIColor *)colorForType:(int)type;

@end
