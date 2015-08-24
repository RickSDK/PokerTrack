//
//  ForumCell.h
//  PokerTracker
//
//  Created by Rick Medved on 6/7/13.
//
//

#import <UIKit/UIKit.h>

@interface ForumCell : UITableViewCell {
    UILabel *titleLabel;
    UILabel *bodyLabel;
    UILabel *userLabel;
    UILabel *repliesLabel;
    UILabel *repliesNumber;
    UILabel *dateLabel;
    UIImageView *mainImg;
}

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *bodyLabel;
@property (nonatomic, strong) UILabel *userLabel;
@property (nonatomic, strong) UILabel *repliesLabel;
@property (nonatomic, strong) UILabel *repliesNumber;
@property (nonatomic, strong) UILabel *dateLabel;

@property (nonatomic, strong) UIImageView *mainImg;


@end
