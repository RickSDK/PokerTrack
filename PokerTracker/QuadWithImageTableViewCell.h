//
//  QuadWithImageTableViewCell.h
//  PokerTracker
//
//  Created by Rick Medved on 1/17/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PlayerTrackerObj.h"


@interface QuadWithImageTableViewCell : UITableViewCell {
	
@protected
	// placement in the cell
	//		aa		cc
	//		bb		dd
    UILabel *aa;
    UILabel *bb;
	UILabel *cc;
    UILabel *dd;
    UIImageView *leftImage;
	UIColor *aaColor;
	UIColor *bbColor;
	UIColor *ccColor;
	UIColor *ddColor;
	float topSplit;			// divider fraction for top line. 0.5 is middle
	float bottomSplit;		// divider fraction for bottom line
}

@property (readonly, strong) UILabel *aa;
@property (readonly, strong) UILabel *bb;
@property (readonly, strong) UILabel *cc;
@property (readonly, strong) UILabel *dd;
@property (readonly, strong) UIImageView *leftImage;
@property (strong) UIColor *aaColor;
@property (strong) UIColor *bbColor;
@property (strong) UIColor *ccColor;
@property (strong) UIColor *ddColor;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
		   topSplit:(CGFloat)top bottomSplit:(CGFloat)bot;

- (id)initWithStyle:(UITableViewCellStyle) style 
	reuseIdentifier:(NSString *) reuseIdentifier
		   topSplit:(CGFloat) top 
		bottomSplit:(CGFloat) bot 
		 accessType:(UITableViewCellAccessoryType) at;

+ (UIView *)headerView:(NSArray *)fieldNameArray 
			boundWidth:(int)width 
			  topSplit:(CGFloat)top 
		   bottomSplit:(CGFloat)bot 
	   backgroundColor:(UIColor *)bgColor;

+ (UIView *)headerView:(NSArray *)fieldNameArray 
			boundWidth:(int)width 
			  topSplit:(CGFloat)top 
		   bottomSplit:(CGFloat)bot;

+ (CGFloat)cellHeight; 

+ (void) customizeLabel:(UILabel *) aa bb: (UILabel *) bb
					 cc:(UILabel *) cc dd: (UILabel *) dd;
+ (void) headerCustomizeLabel:(UILabel *) aa  bb: (UILabel *) bb
						   cc: (UILabel *) cc dd: (UILabel *) dd;

+(QuadWithImageTableViewCell *)cellForPlayer:(PlayerTrackerObj *)obj cell:(QuadWithImageTableViewCell *)cell;

- (void)becomeAHeaderCellWithBackGroundColor:(UIColor *)hColor
								andTextColor:(UIColor *)tColor;

@end
