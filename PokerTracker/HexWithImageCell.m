//
//  HexWithImageCell.m
//  Inventory
//
//
// ************
//
// In using this Cell you will need to compute how hieght you cell will come out to be. Then use 
// Interface builder to set the height of the Cell to you needed height. 
// 
// ************


#import "HexWithImageCell.h"


static NSInteger FONT_SIZE = 12;
static NSInteger ROW_SEP = 2;


#define kTopSplit		0.6
#define kMiddleSplit	0.6
#define kBottomSplit	0.6

@interface HexWithImageCell (Private)
// Internal methods.
+ (void) layoutSubviews:(UILabel *)a1 a2:(UILabel *)a2 
					 b1:(UILabel *)b1 b2:(UILabel *)b2
					 c1:(UILabel *)c1 c2:(UILabel *)c2 
				inBound:(CGRect) cellRect 
			   topSplit:(CGFloat)topSplit 
			middleSplit:(CGFloat)middleSplit 
			bottomSplit:(CGFloat)bottomSplit;

+ (void) customizeLabel:(UILabel *)a1 a2:(UILabel *)a2 
					 b1:(UILabel *)b1 b2:(UILabel *)b2 
					 c1:(UILabel *)c1 c2:(UILabel *)c2;
@end

@implementation HexWithImageCell


@synthesize a1, a2, b1, b2, c1, c2;
@synthesize a1Color, a2Color, b1Color, b2Color, c1Color, c2Color, leftImageView;

+ (CGFloat)cellHeight {  //return cellHeight which is constant
	return 3*(FONT_SIZE + ROW_SEP) + 12;
}

//index 0 = a1 field name, 1 = a2 field name, 2 = b1 field name, etc... if field is not used, set to @""
+ (UIView *)headerView:(NSArray *)fieldNameArray 
			boundWidth:(int)width  
			  topSplit:(CGFloat)top 
		   middleSplit:(CGFloat)mid 
		   bottomSplit:(CGFloat)bot {
	UIView *infoView = nil; 
	if ([fieldNameArray count] == 6)
	{
		CGRect rect = CGRectMake(0,0, width, [HexWithImageCell cellHeight]);
		infoView = [[UIView alloc] initWithFrame:rect];
		
		UILabel *fa1 = [[UILabel alloc] initWithFrame:CGRectZero];
		UILabel *fa2 = [[UILabel alloc] initWithFrame:CGRectZero];
		UILabel *fb1 = [[UILabel alloc] initWithFrame:CGRectZero];
		UILabel *fb2 = [[UILabel alloc] initWithFrame:CGRectZero];
		UILabel *fc1 = [[UILabel alloc] initWithFrame:CGRectZero];
		UILabel *fc2 = [[UILabel alloc] initWithFrame:CGRectZero];
		fa1.text = [fieldNameArray objectAtIndex:0];
		fa2.text = [fieldNameArray objectAtIndex:1];
		fb1.text = [fieldNameArray objectAtIndex:2];
		fb2.text = [fieldNameArray objectAtIndex:3];
		fc1.text = [fieldNameArray objectAtIndex:4];
		fc2.text = [fieldNameArray objectAtIndex:5];
		
		[HexWithImageCell customizeLabel:fa1 a2:fa2 b1:fb1 b2:fb2 c1:fc1 c2:fc2];
		[HexWithImageCell layoutSubviews:fa1 a2:fa2 
								   b1:fb1 b2:fb2
								   c1:fc1 c2:fc2 
							  inBound:rect 
							 topSplit:top 
						  middleSplit:mid 
						  bottomSplit:bot];
		
        [infoView addSubview:fa1];
        [infoView addSubview:fa2];
        [infoView addSubview:fb1];
        [infoView addSubview:fb2];
		[infoView addSubview:fc1];
        [infoView addSubview:fc2];
		
		
		
	}
	//else return nil
	return infoView;
}

+ (void) customizeLabel:(UILabel *)a1 a2:(UILabel *)a2 
					 b1:(UILabel *)b1 b2:(UILabel *)b2 
					 c1:(UILabel *)c1 c2:(UILabel *)c2
{
	// Initialization code
	// Initialize the labels, their fonts, colors, alignment, and background color.
	
	a1.font = [UIFont boldSystemFontOfSize:16];
	a1.backgroundColor = [UIColor clearColor];
	
	a2.font = [UIFont boldSystemFontOfSize:FONT_SIZE+1];
	a2.textColor = [UIColor grayColor];		// default gray color
	a2.backgroundColor = [UIColor clearColor];
	a2.textAlignment = UITextAlignmentRight;
	
	b1.font = [UIFont systemFontOfSize:FONT_SIZE];
	b1.textColor = [UIColor darkGrayColor];	// default color
	b1.textAlignment = UITextAlignmentLeft;
	b1.backgroundColor = [UIColor clearColor];
	
	
	b2.font = [UIFont systemFontOfSize:FONT_SIZE];
	b2.textColor = [UIColor grayColor];		// default gray color
	b2.textAlignment = UITextAlignmentRight;
	b2.backgroundColor = [UIColor clearColor];
	
	
	c1.font = [UIFont systemFontOfSize:FONT_SIZE];
	c1.textColor = [UIColor darkGrayColor];	// default color
	c1.textAlignment = UITextAlignmentLeft;
	c1.backgroundColor = [UIColor clearColor];
	
	
	c2.font = [UIFont systemFontOfSize:FONT_SIZE];
	c2.textColor = [UIColor grayColor];		// default gray color
	c2.textAlignment = UITextAlignmentRight;
	c2.backgroundColor = [UIColor clearColor];
	
	
}

- (id)initWithStyle:(UITableViewCellStyle)style 
	reuseIdentifier:(NSString *)reuseIdentifier
		   topSplit:(CGFloat)top 
		middleSplit:(CGFloat)mid 
		bottomSplit:(CGFloat)bot {
	if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
		topSplit = top;
		middleSplit = mid;
		bottomSplit = bot;
		
		a1 = [[UILabel alloc] initWithFrame:CGRectZero];
		a2 = [[UILabel alloc] initWithFrame:CGRectZero];
		b1 = [[UILabel alloc] initWithFrame:CGRectZero];
		b2 = [[UILabel alloc] initWithFrame:CGRectZero];
		c1 = [[UILabel alloc] initWithFrame:CGRectZero];
		c2 = [[UILabel alloc] initWithFrame:CGRectZero];
		
		[HexWithImageCell customizeLabel:a1 a2:a2 b1:b1 b2:b2 c1:c1 c2:c2];
		//initialize color
		self.a1Color = a1.textColor; 
		self.a2Color = a2.textColor; 
		self.b1Color = b1.textColor;
		self.b2Color = b2.textColor;
		self.c1Color = c1.textColor;
		self.c2Color = c2.textColor;
		
		// Add the labels to the content view of the cell.
		
		// Important: although UITableViewCell inherits from UIView, you should add subviews to its content view
		// rather than directly to the cell so that they will be positioned appropriately as the cell transitions 
		// into and out of editing mode.
        [self.contentView addSubview:a1];
        [self.contentView addSubview:a2];
        [self.contentView addSubview:b1];
        [self.contentView addSubview:b2];
		[self.contentView addSubview:c1];
        [self.contentView addSubview:c2];

		leftImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 55)];
		[self.contentView addSubview:leftImageView];

	}
	return self;
}


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	return [self initWithStyle:style reuseIdentifier:reuseIdentifier
					  topSplit:kTopSplit middleSplit:kMiddleSplit bottomSplit:kBottomSplit];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	
	[super setSelected:selected animated:animated];
	
	// Configure the view for the selected state
	a1.textColor = a1Color;
	a2.textColor = a2Color;
	b1.textColor = b1Color;
	b2.textColor = b2Color;
	c1.textColor = c1Color;
	c2.textColor = c2Color;
}




- (void)layoutSubviews {
	
	[super layoutSubviews];
	
	[HexWithImageCell layoutSubviews:a1 a2:a2 b1:b1 b2:b2 c1:c1 c2:c2 
						  inBound:self.contentView.bounds 
						 topSplit:topSplit 
					  middleSplit:middleSplit 
					  bottomSplit:bottomSplit];
	
	
}

+ (void) layoutSubviews:(UILabel *)a1 a2:(UILabel *)a2 
					 b1:(UILabel *)b1 b2:(UILabel *)b2
					 c1:(UILabel *)c1 c2:(UILabel *)c2 
				inBound:(CGRect) cellRect
			   topSplit:(CGFloat)topSplit 
			middleSplit:(CGFloat)middleSplit 
			bottomSplit:(CGFloat)bottomSplit {
	
	CGRect baseRect = CGRectInset(cellRect, 10, 0);
	
	CGFloat topPadding = ROW_SEP;
	CGFloat padding = ROW_SEP;
	CGFloat currentYOrigin = baseRect.origin.y + topPadding; // start down 5 from top of cell
	
	int leftSection = trunc(baseRect.size.width * topSplit); // compute left section width
	
	CGFloat rowHeight = 0;
	if ((a1.font.ascender + (-1 * a1.font.descender)) >= (a2.font.ascender + (-1 * a2.font.descender))) {
		rowHeight = ceil(a1.font.ascender + (-1 * a1.font.descender));
	} else {
		rowHeight = ceil(a2.font.ascender + (-1 * a2.font.descender));
	}
	
	CGRect rect = baseRect;
	rect.origin.y += currentYOrigin; // Move down 5 from Top of Cell.
	rect.origin.x += 50;
	rect.size.width = leftSection;
	rect.size.height = rowHeight;
	a1.frame = rect;
	
	rect.origin.x += leftSection-40;
	rect.size.width = baseRect.size.width - leftSection;
	a2.frame = rect;
	
	// adjust hieght from row a, and add to height of cell
	currentYOrigin += rowHeight + padding;
	
	// Start Row B
	
	// re-compute Left Section for Row
	leftSection = trunc(baseRect.size.width * middleSplit); 
	
	// re-compute row height for new row.
	if ((b1.font.ascender + (-1 * b1.font.descender)) >= (b2.font.ascender + (-1 * b2.font.descender))) {
		rowHeight = ceil(b1.font.ascender + (-1 * b1.font.descender));
	} else {
		rowHeight = ceil(b2.font.ascender + (-1 * b2.font.descender));
	}
	
	rect = baseRect; 
	rect.origin.y = currentYOrigin;
	rect.origin.x += 50;
	rect.size.width = leftSection;
	rect.size.height = rowHeight;
	b1.frame = rect;
	
	rect.origin.x += leftSection-40;
	rect.size.width = baseRect.size.width - leftSection;
	b2.frame = rect;
	
	// adjust hieght from row b
	currentYOrigin += rowHeight + padding;
	
	// Start Row C
	
	// recompute left Section for Row
	leftSection = trunc(baseRect.size.width * bottomSplit);
	
	// re-compute row height for new row
    if ((c1.font.ascender + (-1 * c1.font.descender)) >= (c2.font.ascender + (-1 * c2.font.descender))) {
		rowHeight = ceil(c1.font.ascender + (-1 * c1.font.descender));
	} else {
		rowHeight = ceil(c2.font.ascender + (-1 * c2.font.descender));
	}
	
	rect = baseRect;
	rect.origin.y = currentYOrigin;
	rect.origin.x += 50;
	rect.size.width = leftSection;
	rect.size.height = rowHeight;
	c1.frame = rect;
	
	rect.origin.x += leftSection-40;
	rect.size.width = baseRect.size.width - leftSection;
	c2.frame = rect;
}

- (void)becomeAHeaderCellWithBackGroundColor:(UIColor *)hColor 
								andTextColor:(UIColor *)tColor {
	self.backgroundColor = hColor;
	a1.textColor = tColor;
	a2.textColor = tColor;
	b1.textColor = tColor;
	b2.textColor = tColor;
	c1.textColor = tColor;
	c2.textColor = tColor;
}


@end
