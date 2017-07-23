//
//  ImageCell.m
//  PokerTracker
//
//  Created by Rick Medved on 7/8/13.
//
//

#import "ImageCell.h"

@implementation ImageCell
@synthesize nameLabel, cityLabel, leftImage;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.nameLabel.textAlignment = NSTextAlignmentCenter;
        self.nameLabel.textColor = [UIColor blackColor];
        self.nameLabel.font = [UIFont boldSystemFontOfSize:36];
        [self.nameLabel sizeToFit];
        self.nameLabel.minimumScaleFactor = .7;
        self.nameLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.nameLabel];

        self.cityLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.cityLabel.textAlignment = NSTextAlignmentCenter;
        [self.cityLabel sizeToFit];
        self.cityLabel.minimumScaleFactor = .7;
        self.cityLabel.numberOfLines=1;
        self.cityLabel.textColor = [UIColor colorWithRed:0 green:.5 blue:0 alpha:1];
        self.cityLabel.font = [UIFont boldSystemFontOfSize:20];
        self.cityLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.cityLabel];
		
		self.leftImage = [[UIImageView alloc] initWithFrame:CGRectZero];
		[self.contentView addSubview:self.leftImage];
}
    return self;
}

- (void)layoutSubviews {
	
	[super layoutSubviews];
	
	
	[ImageCell layoutSubviews:self.nameLabel cityLabel:self.cityLabel inBound:self.frame];
	self.leftImage.frame = CGRectMake(0, 0, self.frame.size.height*.75, self.frame.size.height);
    
    
}

+ (void) layoutSubviews:(UILabel *)nameLabel
              cityLabel:(UILabel *)cityLabel
				inBound:(CGRect) cellRect
{
    
    float width=cellRect.size.width;
//    int margin=width/10;
    
    nameLabel.frame = CGRectMake(80.0, 10, width-100, 40);
    cityLabel.frame = CGRectMake(80, 50, width-100, 40);
    
    if([cityLabel.text length]>20)
        cityLabel.font = [UIFont boldSystemFontOfSize:16];
    
    if([nameLabel.text length]>10)
        nameLabel.font = [UIFont boldSystemFontOfSize:26];
    
    if([nameLabel.text length]>14)
        nameLabel.font = [UIFont boldSystemFontOfSize:20];
    
    if([nameLabel.text length]>20)
        nameLabel.font = [UIFont boldSystemFontOfSize:16];
    
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
