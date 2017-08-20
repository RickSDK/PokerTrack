//
//  ThemeCell.h
//  PokerTracker
//
//  Created by Rick Medved on 8/18/17.
//
//

#import <UIKit/UIKit.h>
#import "ThemeColorObj.h"

@interface ThemeCell : UITableViewCell

@property (nonatomic, strong) UIView *primaryColorView;
@property (nonatomic, strong) UIView *bgColorView;
@property (nonatomic, strong) UIView *navBarColorView;

+(ThemeCell *)cellForRowWithObj:(ThemeColorObj *)obj cell:(ThemeCell *)cell;

@end
