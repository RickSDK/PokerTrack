//
//  HudButtonObj.h
//  PokerTracker
//
//  Created by Rick Medved on 7/10/17.
//
//

#import <Foundation/Foundation.h>

@interface HudActionObj : NSObject

@property (nonatomic, strong) UIImageView *skillImageView;

@property (nonatomic, strong) UILabel *foldLabel;
@property (nonatomic, strong) UILabel *checkLabel;
@property (nonatomic, strong) UILabel *callLabel;
@property (nonatomic, strong) UILabel *raiseLabel;
@property (nonatomic, strong) UILabel *styleLabel;


+(HudActionObj *)createObjWithFoldLabel:(UILabel *)foldLabel
							 checkLabel:(UILabel *)checkLabel
							  callLabel:(UILabel *)callLabel
							 raiseLabel:(UILabel *)raiseLabel
							 styleLabel:(UILabel *)styleLabel
						 skillImageView:(UIImageView *)skillImageView;

@end
