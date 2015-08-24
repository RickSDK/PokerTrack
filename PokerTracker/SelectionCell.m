//
//  SelectionCell.m
//  BASE
//
//

#import "SelectionCell.h"
#import "UIColor+ATTColor.h"

#define kCellLeftOffset			8.0
#define kTextWidth				140.0


@implementation SelectionCell

@synthesize selection;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        // Initialization code
		self.textLabel.font = [UIFont boldSystemFontOfSize:[UIFont labelFontSize]];	// label is 17, system is 14
		self.textLabel.textAlignment = UITextAlignmentLeft;

		self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		
        selection = [[UILabel alloc] initWithFrame:CGRectZero];
        selection.font = [UIFont systemFontOfSize:[UIFont labelFontSize]];
		selection.adjustsFontSizeToFitWidth = YES;
		selection.minimumFontSize = [UIFont labelFontSize] - 2;
		selection.textAlignment = UITextAlignmentRight;
		selection.textColor = [UIColor ATTBlue];
        selection.backgroundColor = [UIColor clearColor];
		
		[self.contentView addSubview:selection];
// calling this in 3.0 causes selection highlighting to have square corners even though table style is Grouped
//		[self layoutSubviews];
    }
    return self;
}


- (void)layoutSubviews
{	
	[super layoutSubviews];
    CGRect contentRect = [self.contentView bounds];
	
	CGRect uiFrame = CGRectMake(contentRect.size.width - kTextWidth - kCellLeftOffset, 0,
								kTextWidth, contentRect.size.height);
	selection.frame = uiFrame;
	[self.contentView bringSubviewToFront:selection];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}




@end
