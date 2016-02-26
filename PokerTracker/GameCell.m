//
//  GameCell.m
//  PokerTracker
//
//  Created by Rick Medved on 7/24/15.
//
//

#import "GameCell.h"
#import "GameObj.h"
#import "ProjectFunctions.h"
#import "NSDate+ATTDate.h"

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
		
		self.hoursLabel = [[UILabel alloc] initWithFrame:CGRectMake(170, 22, 170, 22)];
		self.hoursLabel.font = [UIFont systemFontOfSize:14];
		self.hoursLabel.adjustsFontSizeToFitWidth = YES;
		self.hoursLabel.minimumScaleFactor = .8;
		self.hoursLabel.text = @"hours";
		self.hoursLabel.textAlignment = NSTextAlignmentLeft;
		self.hoursLabel.textColor = [UIColor colorWithRed:0 green:0 blue:.5 alpha:1];
		self.hoursLabel.backgroundColor = [UIColor clearColor];
		[self.contentView addSubview:self.hoursLabel];
		
		
		
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
		self.profitLabel.font = [UIFont boldSystemFontOfSize:18];
		self.profitLabel.adjustsFontSizeToFitWidth = YES;
		self.profitLabel.minimumScaleFactor = .8;
		self.profitLabel.text = @"profitLabel";
		self.profitLabel.textAlignment = NSTextAlignmentRight;
		self.profitLabel.textColor = [UIColor greenColor];
		self.profitLabel.backgroundColor = [UIColor clearColor];
		[self.contentView addSubview:self.profitLabel];
		
		self.pprLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 29, 34, 15)];
		self.pprLabel.font = [UIFont boldSystemFontOfSize:14];
		self.pprLabel.adjustsFontSizeToFitWidth = YES;
		self.pprLabel.minimumScaleFactor = .8;
		self.pprLabel.shadowColor = [UIColor blackColor];
		self.pprLabel.shadowOffset = CGSizeMake(1.0, 1.0);
		self.pprLabel.text = @"PPR";
		self.pprLabel.textAlignment = NSTextAlignmentCenter;
		self.pprLabel.textColor = [UIColor whiteColor];
		self.pprLabel.backgroundColor = [UIColor clearColor];
		[self.contentView addSubview:self.pprLabel];
		
		
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


+(void)populateCell:(GameCell *)cell obj:(NSManagedObject *)mo evenFlg:(BOOL)evenFlg {
	GameObj *gameObj = [GameObj gameObjFromDBObj:mo];
	
	cell.nameLabel.text = [NSString stringWithFormat:@"%@ (%@)", gameObj.name, [gameObj.type substringToIndex:1]];
	cell.dateLabel.text = [NSString stringWithFormat:@"%@", [gameObj.startTime convertDateToStringWithFormat:@"MM/dd/yyyy ha"]];
	cell.hoursLabel.text = [NSString stringWithFormat:@"(%@ hrs)", gameObj.hours];
	cell.locationLabel.text = gameObj.location;
	cell.locationLabel.textColor = [UIColor purpleColor];
	cell.profitLabel.text = [NSString stringWithFormat:@"%@", [ProjectFunctions convertIntToMoneyString:gameObj.profit]];
	
	if(gameObj.profit>=0) {
		cell.pprLabel.backgroundColor=[UIColor colorWithRed:0 green:.5 blue:0 alpha:1];
		cell.profitLabel.textColor = [UIColor colorWithRed:0 green:.5 blue:0 alpha:1]; //<-- green
	} else {
		cell.pprLabel.backgroundColor=[UIColor redColor];
		cell.profitLabel.textColor = [UIColor colorWithRed:.7 green:0 blue:0 alpha:1]; //<-- red
	}
	
	if(gameObj.cashGameFlg) {
		cell.nameLabel.textColor = [UIColor blackColor];
		cell.backgroundColor=(evenFlg)?[UIColor colorWithWhite:.9 alpha:1]:[UIColor whiteColor];
	} else {
		cell.nameLabel.textColor = [UIColor colorWithRed:0 green:0 blue:.6 alpha:1];
		cell.backgroundColor=(evenFlg)?[UIColor colorWithRed:217/255.0 green:223/255.0 blue:1 alpha:1.0]:[UIColor colorWithRed:237/255.0 green:243/255.0 blue:1 alpha:1.0];
	}
	
	cell.profitImageView.image = [ProjectFunctions getPlayerTypeImage:gameObj.buyInAmount+gameObj.reBuyAmount winnings:gameObj.profit];
	cell.pprLabel.text = [NSString stringWithFormat:@"%d", gameObj.ppr];
	
	if([gameObj.status isEqualToString:@"In Progress"]) {
		cell.backgroundColor = [UIColor yellowColor];
		cell.profitLabel.text = @"In Progress";
		cell.profitLabel.textColor = [UIColor redColor];
	}
}


@end
