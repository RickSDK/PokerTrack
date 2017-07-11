//
//  HudButtonObj.m
//  PokerTracker
//
//  Created by Rick Medved on 7/10/17.
//
//

#import "HudActionObj.h"

@implementation HudActionObj

+(HudActionObj *)createObjWithFoldLabel:(UILabel *)foldLabel
							  callLabel:(UILabel *)callLabel
							 raiseLabel:(UILabel *)raiseLabel
							 styleLabel:(UILabel *)styleLabel
						 skillImageView:(UIImageView *)skillImageView {
	
	HudActionObj *obj = [[HudActionObj alloc] init];
	obj.foldLabel = foldLabel;
	obj.callLabel = callLabel;
	obj.raiseLabel = raiseLabel;
	obj.skillImageView = skillImageView;
	obj.styleLabel = styleLabel;
	
	return obj;
}

@end
