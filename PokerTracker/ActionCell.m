//
//  ActionCell.m
//  BASE
//
//

#import "ActionCell.h"

#define kCellLeftOffset			8.0


@implementation ActionCell

@synthesize activityIndicator;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        // Initialization code
		self.textLabel.font = [UIFont boldSystemFontOfSize:[UIFont labelFontSize]];	// label is 17, system is 14
		self.textLabel.textAlignment = UITextAlignmentCenter;
		self.textLabel.highlightedTextColor = [UIColor whiteColor];

		// Create and configure activity indicator
 //   	self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
//		self.activityIndicator.hidesWhenStopped = YES;
		// in case the parent view draws with a custom color or gradient, use a transparent color
//		self.activityIndicator.backgroundColor = [UIColor clearColor];
		
		[self.contentView addSubview:self.activityIndicator];
// calling this in 3.0 causes selection highlighting to have square corners even though table style is Grouped
//		[self layoutSubviews];
	}
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)layoutSubviews
{	
	[super layoutSubviews];
    CGRect contentRect = [self.contentView bounds];
	
	CGRect uiFrame = CGRectMake(contentRect.size.width - self.activityIndicator.bounds.size.width - kCellLeftOffset,
								round((contentRect.size.height - self.activityIndicator.bounds.size.height) / 2.0),
								self.activityIndicator.bounds.size.width,
								self.activityIndicator.bounds.size.height);
	self.activityIndicator.frame = uiFrame;
}




@end
