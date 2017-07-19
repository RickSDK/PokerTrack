//
//  GameSummaryView.h
//  PokerTracker
//
//  Created by Rick Medved on 7/19/17.
//
//

#import <UIKit/UIKit.h>
#import "GameStatObj.h"

@interface GameSummaryView : UIView

@property (nonatomic, strong) UIButton *skillButton;
@property (nonatomic, strong) UILabel *gameSummaryLabel;
@property (nonatomic, strong) UILabel *profitLabel;
@property (nonatomic, strong) UILabel *roiLabel;

-(void)addTarget:(SEL)selector target:(id)target;

-(void)populateViewWithObj:(GameStatObj *)obj;

@end
