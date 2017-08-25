//
//  NetTrackerCell.h
//  PokerTracker
//
//  Created by Rick Medved on 8/20/17.
//
//

#import <UIKit/UIKit.h>
#import "NetUserObj.h"

@interface NetTrackerCell : UITableViewCell

@property (nonatomic, retain) UIView *leftView;
@property (nonatomic, retain) UIImageView *flagImageView;
@property (nonatomic, retain) UIImageView *playerTypeImageView;
@property (nonatomic, retain) UILabel *roiLabel;
@property (nonatomic, retain) UILabel *pprLabel;

@property (nonatomic, retain) UILabel *nameLabel;
@property (nonatomic, retain) UILabel *locationLabel;
@property (nonatomic, retain) UILabel *gamesLabel;

@property (nonatomic, retain) UILabel *profitLabel;
@property (nonatomic, retain) UILabel *hourlyLabel;
@property (nonatomic, retain) UILabel *streakLabel;

+(NetTrackerCell *)cellForCell:(NetTrackerCell *)cell netUserObj:(NetUserObj *)netUserObj;

@end
