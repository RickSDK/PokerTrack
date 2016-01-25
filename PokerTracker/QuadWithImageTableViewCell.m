//
//  QuadWithImageTableViewCell.m
//  PokerTracker
//
//  Created by Rick Medved on 1/17/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "QuadWithImageTableViewCell.h"

#define kTopSplit		0.6
#define kBottomSplit	0.5

static NSInteger FONT_SIZE			= 12;

@interface QuadWithImageTableViewCell (Private)
// Internal methods.
+ (void) layoutSubviews:(UILabel *) aa bb: (UILabel *) bb
					 cc: (UILabel *) cc dd: (UILabel *) dd
				inBound:(CGRect) cellRect 
			   topSplit:(CGFloat)topSplit 
			bottomSplit:(CGFloat)bottomSplit;

+ (void) customizeLabel:(UILabel *) aa bb: (UILabel *) bb
					 cc: (UILabel *) cc dd: (UILabel *) dd;
@end

@implementation QuadWithImageTableViewCell
@synthesize aa, bb, dd, cc, aaColor, bbColor, ccColor, ddColor, leftImage;


+ (CGFloat)cellHeight {
	return 44;
}

//index 0 = aa field name,	2 = cc, 
//		1 = bb,				3 = dd. 
//if field is not used, set to @""
+ (UIView *)headerView:(NSArray *)fieldNameArray 
			boundWidth:(int)width 
			  topSplit:(CGFloat)top 
		   bottomSplit:(CGFloat)bot 
	   backgroundColor:(UIColor *)bgColor {
	UIView *infoView = nil; 
	
	if ([fieldNameArray count] == 4)
	{
		CGRect rect = CGRectMake(0,0, width, [QuadWithImageTableViewCell cellHeight]);
		infoView = [[UIView alloc] initWithFrame:rect];
		if (bgColor) {
			infoView.backgroundColor = bgColor;
		}
		
		UILabel *faa = [[UILabel alloc] initWithFrame:CGRectZero];
		UILabel *fcc = [[UILabel alloc] initWithFrame:CGRectZero];
		faa.text = [fieldNameArray objectAtIndex:0];
		fcc.text = [fieldNameArray objectAtIndex:2];
        [infoView addSubview:faa];
        [infoView addSubview:fcc];
		
		UILabel *fbb = [[UILabel alloc] initWithFrame:CGRectZero];
		UILabel *fdd = [[UILabel alloc] initWithFrame:CGRectZero];
		fbb.text = [fieldNameArray objectAtIndex:1];
		fdd.text = [fieldNameArray objectAtIndex:3];
		[infoView addSubview:fbb];
		[infoView addSubview:fdd];
		
		if (bgColor && bgColor == [UIColor whiteColor]) {
			// setup fields so use can see them normal header has a dark background.
			[QuadWithImageTableViewCell customizeLabel:faa bb:fbb cc:fcc dd:fdd];
		} else {
			// Header customized sets the textcolor to be white to show better with a dark background.
			[QuadWithImageTableViewCell headerCustomizeLabel:faa bb:fbb cc:fcc dd:fdd];
		}
		
		[QuadWithImageTableViewCell layoutSubviews:faa bb:fbb cc:fcc dd:fdd 
									   inBound:rect 
									  topSplit:top 
								   bottomSplit:bot];
		
	}
	//else return nil
	return infoView;
	
}

+ (UIView *)headerView:(NSArray *)fieldNameArray 
			boundWidth:(int)width 
			  topSplit:(CGFloat)top 
		   bottomSplit:(CGFloat)bot {
	
	return [QuadWithImageTableViewCell headerView:fieldNameArray boundWidth:width topSplit:top bottomSplit:bot backgroundColor:nil];
}


- (id)initWithStyle:(UITableViewCellStyle)style 
	reuseIdentifier:(NSString *)reuseIdentifier
		   topSplit:(CGFloat)top 
		bottomSplit:(CGFloat)bot {
	return [self initWithStyle:style 
			   reuseIdentifier:reuseIdentifier
					  topSplit:top 
				   bottomSplit:bot
					accessType:UITableViewCellAccessoryNone];
}

- (id)initWithStyle:(UITableViewCellStyle)style 
	reuseIdentifier:(NSString *)reuseIdentifier
		   topSplit:(CGFloat)top 
		bottomSplit:(CGFloat)bot 
		 accessType:(UITableViewCellAccessoryType) at
{
	if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
		topSplit = top;
		bottomSplit = bot;
		self.accessoryType = at;
		
		// Initialization code
        aa = [[UILabel alloc] initWithFrame:CGRectZero];
        cc = [[UILabel alloc] initWithFrame:CGRectZero];
		
		bb = [[UILabel alloc] initWithFrame:CGRectZero];
		dd = [[UILabel alloc] initWithFrame:CGRectZero];
        
//        leftImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Icon.png"]];
  //      leftImage.center = CGPointMake(0, 0);
        leftImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 35, 44)];
        leftImage.image = [UIImage imageNamed:@"Icon.png"];
		
		[QuadWithImageTableViewCell customizeLabel:aa bb:bb cc:cc dd:dd]; 
		self.ccColor = cc.textColor;
		
		self.aaColor = aa.textColor;
		self.bbColor = bb.textColor;
		self.ddColor = dd.textColor;
        // Add the labels to the content view of the cell.
        
        // Important: although UITableViewCell inherits from UIView, you should add subviews to its content view
        // rather than directly to the cell so that they will be positioned appropriately as the cell transitions 
        // into and out of editing mode.
        
        [self.contentView addSubview:aa];
        [self.contentView addSubview:cc];
		[self.contentView addSubview:bb];
		[self.contentView addSubview:dd];
		[self.contentView addSubview:leftImage];
	}
	return self;
}


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	return [self initWithStyle:style reuseIdentifier:reuseIdentifier
					  topSplit:kTopSplit bottomSplit:kBottomSplit];
}

+ (void) customizeLabel:(UILabel *) aa bb: (UILabel *) bb
					 cc: (UILabel *) cc dd: (UILabel *) dd {
	
	// Initialize the labels, their fonts, colors, alignment, and background color.
	aa.font = [UIFont boldSystemFontOfSize:(FONT_SIZE)];
	aa.backgroundColor = [UIColor clearColor];
	
	cc.font = [UIFont systemFontOfSize:FONT_SIZE];
	cc.textColor = [UIColor darkGrayColor];	// default color
	cc.textAlignment = NSTextAlignmentRight;
	cc.backgroundColor = [UIColor clearColor];
	
	bb.font = [UIFont systemFontOfSize:FONT_SIZE];
	bb.textColor = [UIColor darkGrayColor];		// default gray color
	bb.backgroundColor = [UIColor clearColor];
	
	dd.font = [UIFont boldSystemFontOfSize:FONT_SIZE+2];
	dd.textColor = [UIColor grayColor];		// default gray color
	dd.textAlignment = NSTextAlignmentRight;
	dd.backgroundColor = [UIColor clearColor];
    dd.shadowColor = [UIColor whiteColor];
    dd.shadowOffset = CGSizeMake(1, 1);
}

+ (void) headerCustomizeLabel:(UILabel *) aa bb: (UILabel *) bb
						   cc:(UILabel *) cc dd: (UILabel *) dd {
	
	// Initialize the labels, their fonts, colors, alignment, and background color.
	aa.font = [UIFont boldSystemFontOfSize:(FONT_SIZE + 2)];
	aa.textColor = [UIColor whiteColor];
	aa.backgroundColor = [UIColor clearColor];
	
	bb.font = [UIFont systemFontOfSize:FONT_SIZE];
	bb.textColor = [UIColor whiteColor];		
	bb.backgroundColor = [UIColor clearColor];
	
	cc.font = [UIFont systemFontOfSize:FONT_SIZE];
	cc.textColor = [UIColor whiteColor];	
	cc.textAlignment = NSTextAlignmentRight;
	cc.backgroundColor = [UIColor clearColor];
	
	dd.font = [UIFont systemFontOfSize:FONT_SIZE];
	dd.textColor = [UIColor whiteColor];		
	dd.textAlignment = NSTextAlignmentRight;
	dd.backgroundColor = [UIColor clearColor];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	
	[super setSelected:selected animated:animated];
	
	// Configure the view for the selected state
	if (selected && self.selectionStyle != UITableViewCellSelectionStyleNone) {
        aa.textColor = [UIColor whiteColor];
        cc.textColor = [UIColor whiteColor];
		
		bb.textColor = [UIColor whiteColor];
		dd.textColor = [UIColor whiteColor];
    } else {
        aa.textColor = [UIColor blackColor];
        cc.textColor = ccColor;
		
		aa.textColor = aaColor;
		bb.textColor = bbColor;
		dd.textColor = ddColor;
    }
}




- (void)layoutSubviews {
	
    [super layoutSubviews];
	
	[QuadWithImageTableViewCell layoutSubviews:aa bb:bb cc:cc dd: dd 
								   inBound:self.contentView.bounds 
								  topSplit:topSplit 
							   bottomSplit:bottomSplit];
	
}


+ (void) layoutSubviews:(UILabel *) aa bb: (UILabel *) bb
					 cc: (UILabel *) cc dd: (UILabel *) dd
				inBound:(CGRect)cellRect 
			   topSplit:(CGFloat)topSplit 
			bottomSplit:(CGFloat)bottomSplit {
	
	// Start with a rect that is inset from the content view by 10 pixels on all sides.
    CGRect baseRect = CGRectInset(cellRect, 10, 10);
	baseRect.size.height = 20;
	int leftSection = trunc((baseRect.size.width-40) * topSplit);
    CGRect rect = baseRect;
	rect.origin.x += 40;
	rect.origin.y -= 5;
	rect.size.width = leftSection;
	aa.frame = rect;
	rect.origin.x += leftSection-40;
	rect.size.width = baseRect.size.width - leftSection;
	cc.frame = rect;
	
	// bottom two segments are seperated by 10 pixs because font is the same
	leftSection = trunc(baseRect.size.width * bottomSplit) + 5;
	rect = baseRect;
	rect.origin.x += 40;
	rect.origin.y += 10;		// seperation between top and bottom line
	rect.size.width = leftSection - 5;
	bb.frame = rect;
	rect.origin.x += leftSection-40;
	rect.size.width = baseRect.size.width - leftSection;
	dd.frame = rect;
	
}

- (void)becomeAHeaderCellWithBackGroundColor:(UIColor *)hColor 
								andTextColor:(UIColor *)tColor {
	self.backgroundColor = hColor;
	aa.textColor = tColor;
	bb.textColor = tColor;
	cc.textColor = tColor;
	dd.textColor = tColor;
	
}

@end
