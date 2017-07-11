//
//  HudStatObj.h
//  PokerTracker
//
//  Created by Rick Medved on 7/10/17.
//
//

#import <Foundation/Foundation.h>

@interface HudStatObj : NSObject

@property (nonatomic, strong) UILabel *percentLabel1;
@property (nonatomic, strong) UILabel *percentLabel2;
@property (nonatomic, strong) UILabel *countLabel1;
@property (nonatomic, strong) UILabel *countLabel2;
@property (nonatomic, strong) UIImageView *bGImageView;
@property (nonatomic, strong) UIImageView *playerType1ImageView;
@property (nonatomic, strong) UIImageView *playerType2ImageView;
@property (nonatomic, strong) UIView *barView1;
@property (nonatomic, strong)  UIView *barView2;

+(HudStatObj *)createObjWithPercentLabel1:(UILabel *)percentLabel1
							percentLabel2:(UILabel *)percentLabel2
							  countLabel1:(UILabel *)countLabel1
							  countLabel2:(UILabel *)countLabel2
							  bGImageView:(UIImageView *)bGImageView
					 playerType1ImageView:(UIImageView *)playerType1ImageView
					 playerType2ImageView:(UIImageView *)playerType2ImageView
								 barView1:(UIView *)barView1
								 barView2:(UIView *)barView2;
@end
