//
//  BigHandCell.m
//  PokerTracker
//
//  Created by Rick Medved on 8/5/17.
//
//

#import "BigHandCell.h"
#import "ProjectFunctions.h"

@implementation BigHandCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	if (self) {
		self.card1BG = [[UIImageView alloc] initWithFrame:CGRectMake(2, 3, 20, 30)];
		self.card1BG.image = [UIImage imageNamed:@"blankCard.png"];
		[self.contentView addSubview:self.card1BG];
		
		self.suit1Image = [[UIImageView alloc] initWithFrame:CGRectMake(5, 17, 14, 14)];
		self.suit1Image.image = [UIImage imageNamed:@"cards.png"];
		[self.contentView addSubview:self.suit1Image];
		
		self.card1Label = [[UILabel alloc] initWithFrame:CGRectZero];
		self.card1Label.text = @"A";
		self.card1Label.frame = CGRectMake(4, 4, 15, 15);
		self.card1Label.textAlignment = NSTextAlignmentCenter;
		self.card1Label.font = [UIFont boldSystemFontOfSize:14];
		self.card1Label.backgroundColor = [UIColor clearColor];
		[self.contentView addSubview:self.card1Label];
		
		self.card2BG = [[UIImageView alloc] initWithFrame:CGRectMake(10, 13, 20, 30)];
		self.card2BG.image = [UIImage imageNamed:@"blankCard.png"];
		[self.contentView addSubview:self.card2BG];
		
		self.suit2Image = [[UIImageView alloc] initWithFrame:CGRectMake(14, 27, 14, 14)];
		self.suit2Image.image = [UIImage imageNamed:@"cards.png"];
		[self.contentView addSubview:self.suit2Image];

		self.card2Label = [[UILabel alloc] initWithFrame:CGRectZero];
		self.card2Label.text = @"A";
		self.card2Label.frame = CGRectMake(13, 14, 15, 15);
		self.card2Label.textAlignment = NSTextAlignmentCenter;
		self.card2Label.font = [UIFont boldSystemFontOfSize:14];
		self.card2Label.backgroundColor = [UIColor clearColor];
		[self.contentView addSubview:self.card2Label];
		
		self.nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];;
		self.nameLabel.textAlignment = NSTextAlignmentLeft;
		self.nameLabel.textColor = [UIColor blackColor];
		self.nameLabel.font = [UIFont boldSystemFontOfSize:16];
		self.nameLabel.backgroundColor = [UIColor clearColor];
		[self.contentView addSubview:self.nameLabel];
		
		self.dateLabel = [[UILabel alloc] initWithFrame:CGRectZero];;
		self.dateLabel.textAlignment = NSTextAlignmentLeft;
		self.dateLabel.textColor = [UIColor grayColor];
		self.dateLabel.font = [UIFont systemFontOfSize:14];
		self.dateLabel.backgroundColor = [UIColor clearColor];
		[self.contentView addSubview:self.dateLabel];
		
		self.statusLabel = [[UILabel alloc] initWithFrame:CGRectZero];;
		self.statusLabel.textAlignment = NSTextAlignmentRight;
		self.statusLabel.textColor = [UIColor redColor];
		self.statusLabel.font = [UIFont systemFontOfSize:14];
		self.statusLabel.backgroundColor = [UIColor clearColor];
		[self.contentView addSubview:self.statusLabel];
		
		self.potSizeLabel = [[UILabel alloc] initWithFrame:CGRectZero];;
		self.potSizeLabel.textAlignment = NSTextAlignmentRight;
		self.potSizeLabel.textColor = [UIColor greenColor];
		self.potSizeLabel.font = [UIFont systemFontOfSize:14];
		self.potSizeLabel.backgroundColor = [UIColor clearColor];
		[self.contentView addSubview:self.potSizeLabel];
		
		
	}
	return self;
}

- (void)layoutSubviews {
	[super layoutSubviews];
	
	float width = self.frame.size.width;
	
	self.nameLabel.frame = CGRectMake(35, 0, 200, 24);
	self.dateLabel.frame = CGRectMake(35, 22, 200, 20);
	self.statusLabel.frame = CGRectMake(width-140, -1, 110, 20);
	self.potSizeLabel.frame = CGRectMake(width-140, 23, 110, 20);
	
}

+(UITableViewCell *)cellForBigHand:(BigHandObj *)obj cellIdentifier:(NSString *)cellIdentifier tableView:(UITableView *)tableView {
	BigHandCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (cell == nil) {
		cell = [[BigHandCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
	}
	cell.nameLabel.text = obj.name;
	cell.dateLabel.text = [ProjectFunctions displayLocalFormatDate:obj.gameDate showDay:YES showTime:NO];
	cell.statusLabel.text = obj.winStatus;
	cell.potSizeLabel.text = [ProjectFunctions convertNumberToMoneyString:obj.potsize];
	if([obj.winStatus isEqualToString:@"Win"])
		cell.statusLabel.textColor = [UIColor colorWithRed:0 green:.5 blue:0 alpha:1];
	if([obj.winStatus isEqualToString:@"Loss"])
		cell.statusLabel.textColor = [UIColor redColor];
	if([obj.winStatus isEqualToString:@"Chop"])
		cell.statusLabel.textColor = [UIColor orangeColor];
	[BigHandObj createHand:obj.player1Hand suit1:cell.suit1Image label1:cell.card1Label suit2:cell.suit2Image label2:cell.card2Label];
	
	cell.potSizeLabel.textColor = [UIColor colorWithRed:0 green:.5 blue:0 alpha:1];
	cell.backgroundColor = [UIColor whiteColor];
	cell.accessoryType= UITableViewCellAccessoryDisclosureIndicator;
	return cell;
}




@end
