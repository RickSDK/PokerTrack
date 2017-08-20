//
//  ThemeCell.m
//  PokerTracker
//
//  Created by Rick Medved on 8/18/17.
//
//

#import "ThemeCell.h"

@implementation ThemeCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	if (self) {
		self.primaryColorView = [self createView];
		[self.contentView addSubview:self.primaryColorView];

		self.bgColorView = [self createView];
		[self.contentView addSubview:self.bgColorView];

		self.navBarColorView = [self createView];
		[self.contentView addSubview:self.navBarColorView];
	}
	return self;
}

-(UIView *)createView {
	UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
	view.layer.masksToBounds = NO;
	view.layer.shadowOffset = CGSizeMake(2, 2);
	view.layer.shadowColor	= [UIColor blackColor].CGColor;
	view.layer.shadowOpacity = 0.8;
	return view;
}

- (void)layoutSubviews {
	[super layoutSubviews];
	
	float width = self.frame.size.width;
	float leftEdge = width-65;
	float third=44.0/3;
	self.primaryColorView.frame = CGRectMake(leftEdge-third, third, third, third);
	self.bgColorView.frame = CGRectMake(leftEdge, third, third, third);
	self.navBarColorView.frame = CGRectMake(leftEdge+third, third, third, third);
}

+(ThemeCell *)cellForRowWithObj:(ThemeColorObj *)obj cell:(ThemeCell *)cell {
	cell.textLabel.text=obj.longName;
	cell.backgroundColor = obj.themeBGColor;
	cell.textLabel.textColor = obj.primaryColor;
	cell.primaryColorView.backgroundColor=obj.primaryColor;
	cell.bgColorView.backgroundColor=obj.themeBGColor;
	cell.navBarColorView.backgroundColor=obj.navBarColor;
	return cell;
}

@end
