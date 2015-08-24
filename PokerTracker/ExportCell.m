//
//  ExportCell.m
//  PokerTracker
//
//  Created by Rick Medved on 10/8/14.
//
//

#import "ExportCell.h"

@implementation ExportCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];;
        self.titleLabel.textAlignment = NSTextAlignmentLeft;
        self.titleLabel.textColor = [UIColor colorWithWhite:.5 alpha:1];
        self.titleLabel.font = [UIFont systemFontOfSize:18];
        self.titleLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.titleLabel];

		self.gamesStoredLabel = [[UILabel alloc] initWithFrame:CGRectZero];;
        self.gamesStoredLabel.textAlignment = NSTextAlignmentRight;
        self.gamesStoredLabel.textColor = [UIColor blueColor];
        self.gamesStoredLabel.font = [UIFont boldSystemFontOfSize:12];
        self.gamesStoredLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.gamesStoredLabel];

	}
    return self;
}

- (void)layoutSubviews {
	
	[super layoutSubviews];
    
	[ExportCell layoutSubviews:self.titleLabel gamesStoredLabel:self.gamesStoredLabel inBound:self.frame];
    
    
}

+ (void) layoutSubviews:(UILabel *)titleLabel
	   gamesStoredLabel:(UILabel *)gamesStoredLabel
				inBound:(CGRect) cellRect
{
    
    float width=cellRect.size.width;
    
    titleLabel.frame = CGRectMake(15, 5, 200, 35);
    gamesStoredLabel.frame = CGRectMake(width-210, 5, 150, 35);
	
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
