//
//  HudStatObj.m
//  PokerTracker
//
//  Created by Rick Medved on 7/10/17.
//
//

#import "HudStatObj.h"

@implementation HudStatObj

+(HudStatObj *)createObjWithPercentLabel1:(UILabel *)percentLabel1
							percentLabel2:(UILabel *)percentLabel2
							  countLabel1:(UILabel *)countLabel1
							  countLabel2:(UILabel *)countLabel2
							  bGImageView:(UIImageView *)bGImageView
					 playerType1ImageView:(UIImageView *)playerType1ImageView
					 playerType2ImageView:(UIImageView *)playerType2ImageView
								 barView1:(UIView *)barView1
								 barView2:(UIView *)barView2 {
	HudStatObj *obj = [[HudStatObj alloc] init];
	obj.percentLabel1 = percentLabel1;
	obj.percentLabel2 = percentLabel2;
	obj.countLabel1 = countLabel1;
	obj.countLabel2 = countLabel2;
	obj.bGImageView = bGImageView;
	obj.playerType1ImageView = playerType1ImageView;
	obj.playerType2ImageView = playerType2ImageView;
	obj.barView1 = barView1;
	obj.barView2 = barView2;

	return obj;
}

@end
