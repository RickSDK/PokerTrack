//
//  HexagonFieldCell.h
//  Inventory
//
//

#import <UIKit/UIKit.h>


@interface HexaFieldCell : UITableViewCell {

@protected
	// placement in the cell
	//		a1		b1
	//		a2		b2
	//		a3		b3
    UILabel *a1;
    UILabel *a2;
	UILabel *b1;
    UILabel *b2;
	UILabel *c1;
	UILabel *c2;
	UIColor *a1Color;
	UIColor *a2Color;
	UIColor *b1Color;
	UIColor *b2Color;
	UIColor *c1Color;
	UIColor *c2Color;
	float topSplit;			// divider fraction for top line. 0.5 is middle
	float middleSplit;
	float bottomSplit;		// divider fraction for bottom line
}

@property (readonly, strong) UILabel *a1;
@property (readonly, strong) UILabel *a2;
@property (readonly, strong) UILabel *b1;
@property (readonly, strong) UILabel *b2;
@property (readonly, strong) UILabel *c1;
@property (readonly, strong) UILabel *c2;

@property (strong) UIColor *a1Color;
@property (strong) UIColor *a2Color;
@property (strong) UIColor *b1Color;
@property (strong) UIColor *b2Color;
@property (strong) UIColor *c1Color;
@property (strong) UIColor *c2Color;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
		   topSplit:(CGFloat)top middleSplit:(CGFloat)mid bottomSplit:(CGFloat)bot;

+ (UIView *)headerView:(NSArray *)fieldNameArray 
			boundWidth:(int)width 
			  topSplit:(CGFloat)top 
		   middleSplit:(CGFloat)mid 
		   bottomSplit:(CGFloat)bot;

+ (CGFloat)cellHeight; 

- (void)becomeAHeaderCellWithBackGroundColor:(UIColor *)hColor 
								andTextColor:(UIColor *)tColor;
@end
