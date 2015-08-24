//
//  GameCell.m
//  PokerTracker
//
//  Created by Rick Medved on 7/24/15.
//
//

#import "GameCell.h"

@implementation GameCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	if (self) {
		
		self.profitImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 34, 44)];
		self.profitImageView.image = [UIImage imageNamed:@"playerType1.png"];
		[self.contentView addSubview:self.profitImageView];
		
		self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 0, 170, 22)];
		self.nameLabel.font = [UIFont boldSystemFontOfSize:14];
		self.nameLabel.adjustsFontSizeToFitWidth = YES;
		self.nameLabel.minimumScaleFactor = .8;
		self.nameLabel.text = @"nameLabel";
		self.nameLabel.textAlignment = NSTextAlignmentLeft;
		self.nameLabel.textColor = [UIColor blackColor];
		self.nameLabel.backgroundColor = [UIColor clearColor];
		[self.contentView addSubview:self.nameLabel];
		
		self.dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 22, 170, 22)];
		self.dateLabel.font = [UIFont systemFontOfSize:14];
		self.dateLabel.adjustsFontSizeToFitWidth = YES;
		self.dateLabel.minimumScaleFactor = .8;
		self.dateLabel.text = @"dateLabel";
		self.dateLabel.textAlignment = NSTextAlignmentLeft;
		self.dateLabel.textColor = [UIColor grayColor];
		self.dateLabel.backgroundColor = [UIColor clearColor];
		[self.contentView addSubview:self.dateLabel];
		
		self.locationLabel = [[UILabel alloc] initWithFrame:CGRectMake(210, 0, 100, 22)];
		self.locationLabel.font = [UIFont systemFontOfSize:14];
		self.locationLabel.adjustsFontSizeToFitWidth = YES;
		self.locationLabel.minimumScaleFactor = .8;
		self.locationLabel.text = @"locationLabel";
		self.locationLabel.textAlignment = NSTextAlignmentRight;
		self.locationLabel.textColor = [UIColor purpleColor];
		self.locationLabel.backgroundColor = [UIColor clearColor];
		[self.contentView addSubview:self.locationLabel];
		
		self.profitLabel = [[UILabel alloc] initWithFrame:CGRectMake(210, 22, 100, 22)];
		self.profitLabel.font = [UIFont boldSystemFontOfSize:20];
		self.profitLabel.adjustsFontSizeToFitWidth = YES;
		self.profitLabel.minimumScaleFactor = .8;
		self.profitLabel.text = @"profitLabel";
		self.profitLabel.textAlignment = NSTextAlignmentRight;
		self.profitLabel.textColor = [UIColor greenColor];
		self.profitLabel.backgroundColor = [UIColor clearColor];
		[self.contentView addSubview:self.profitLabel];
		
		
	}
	return self;
}

- (void)layoutSubviews {
	
	[super layoutSubviews];
	
	[GameCell layoutSubviews:self.frame nameLabel:self.nameLabel dateLabel:self.dateLabel locationLabel:self.locationLabel profitLabel:self.profitLabel];
	
}

+ (void) layoutSubviews:(CGRect)cellRect
			  nameLabel:(UILabel *)nameLabel
			  dateLabel:(UILabel *)dateLabel
		  locationLabel:(UILabel *)locationLabel
			profitLabel:(UILabel *)profitLabel
{
	
	float width=cellRect.size.width;
	
	nameLabel.frame = CGRectMake(40, 0, width-150, 22);
	dateLabel.frame = CGRectMake(40, 22, width-150, 22);
	locationLabel.frame = CGRectMake(width-110, 0, 100, 22);
	profitLabel.frame = CGRectMake(width-110, 20, 100, 22);
}


- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
