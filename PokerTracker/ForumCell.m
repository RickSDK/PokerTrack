//
//  ForumCell.m
//  PokerTracker
//
//  Created by Rick Medved on 6/7/13.
//
//

#import "ForumCell.h"

@implementation ForumCell
@synthesize titleLabel, bodyLabel, userLabel, repliesLabel, dateLabel, mainImg, repliesNumber;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];;
        self.titleLabel.textAlignment = NSTextAlignmentLeft;
        self.titleLabel.textColor = [UIColor blackColor];
        self.titleLabel.font = [UIFont boldSystemFontOfSize:16];
        self.titleLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.titleLabel];

        self.repliesLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 40, 20)];
        self.repliesLabel.textAlignment = NSTextAlignmentCenter;
        self.repliesLabel.textColor = [UIColor blueColor];
        self.repliesLabel.font = [UIFont systemFontOfSize:10];
        self.repliesLabel.text = @"replies";
        self.repliesLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.repliesLabel];

        self.repliesNumber = [[UILabel alloc] initWithFrame:CGRectMake(10, 17, 40, 20)];
        self.repliesNumber.textAlignment = NSTextAlignmentCenter;
        self.repliesNumber.textColor = [UIColor blueColor];
        self.repliesNumber.font = [UIFont boldSystemFontOfSize:22];
        self.repliesNumber.text = @"2";
        self.repliesNumber.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.repliesNumber];

        self.userLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 20, 50, 20)];
        self.userLabel.textAlignment = NSTextAlignmentLeft;
        self.userLabel.textColor = [UIColor purpleColor];
        self.userLabel.font = [UIFont systemFontOfSize:12];
        self.userLabel.text = @"user";
        self.userLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.userLabel];
        
        self.dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(110, 20, 50, 20)];
        self.dateLabel.textAlignment = NSTextAlignmentLeft;
        self.dateLabel.textColor = [UIColor whiteColor];
        self.dateLabel.font = [UIFont systemFontOfSize:12];
        self.dateLabel.text = @"date";
        self.dateLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.dateLabel];
        
        self.bodyLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.bodyLabel.textAlignment = NSTextAlignmentLeft;
        self.bodyLabel.textColor = [UIColor yellowColor];
        self.bodyLabel.font = [UIFont systemFontOfSize:12];
        self.bodyLabel.text = @"body";
        self.bodyLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.bodyLabel];
        
		mainImg = [[UIImageView alloc] initWithFrame:CGRectZero];
		mainImg.image = nil;
		mainImg.frame = CGRectMake(0, 0, 35, 44);
		[self.contentView addSubview:mainImg];

    }
    return self;
}

- (void)layoutSubviews {
	
	[super layoutSubviews];
    
	[ForumCell layoutSubviews:self.titleLabel bodyLabel:self.bodyLabel inBound:self.frame];
    
    
}

+ (void) layoutSubviews:(UILabel *)titleLabel
              bodyLabel:(UILabel *)bodyLabel
				inBound:(CGRect) cellRect
{
    
    float width=cellRect.size.width;
    int margin=width/10;
    
    titleLabel.frame = CGRectMake(60.0, 0, width-95, 26);
    bodyLabel.frame = CGRectMake(160, 20, width-195-margin, 18);

}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
