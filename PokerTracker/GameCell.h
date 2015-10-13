//
//  GameCell.h
//  PokerTracker
//
//  Created by Rick Medved on 7/24/15.
//
//

#import <UIKit/UIKit.h>

@interface GameCell : UITableViewCell

@property (nonatomic, retain) UIImageView *profitImageView;
@property (nonatomic, retain) UILabel *nameLabel;
@property (nonatomic, retain) UILabel *dateLabel;
@property (nonatomic, retain) UILabel *hoursLabel;
@property (nonatomic, retain) UILabel *locationLabel;
@property (nonatomic, retain) UILabel *profitLabel;

+ (void) layoutSubviews:(CGRect)cellRect
			  nameLabel:(UILabel *)nameLabel
			  dateLabel:(UILabel *)dateLabel
		  locationLabel:(UILabel *)locationLabel
			profitLabel:(UILabel *)profitLabel;
@end
