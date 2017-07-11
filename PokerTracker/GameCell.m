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
		
		self.faLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 34, 29)];
		self.faLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:24];
		self.faLabel.adjustsFontSizeToFitWidth = YES;
		self.faLabel.minimumScaleFactor = .8;
		self.faLabel.textAlignment = NSTextAlignmentCenter;
		self.faLabel.textColor = [UIColor blackColor];
		self.faLabel.backgroundColor = [UIColor clearColor];
		[self.contentView addSubview:self.faLabel];
		
		self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 0, 170, 22)];
		self.nameLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:14];
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
		
		self.hoursLabel = [[UILabel alloc] initWithFrame:CGRectMake(170, 22, 50, 22)];
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
		self.locationLabel.textColor = [UIColor colorWithRed:0 green:0 blue:.5 alpha:1];
		self.locationLabel.backgroundColor = [UIColor clearColor];
		[self.contentView addSubview:self.locationLabel];
		
		self.profitLabel = [[UILabel alloc] initWithFrame:CGRectMake(210, 22, 100, 22)];
		self.profitLabel.font = [UIFont boldSystemFontOfSize:17];
		self.profitLabel.adjustsFontSizeToFitWidth = YES;
		self.profitLabel.minimumScaleFactor = .5;
		self.profitLabel.text = @"profitLabel";
		self.profitLabel.textAlignment = NSTextAlignmentRight;
		self.profitLabel.textColor = [UIColor greenColor];
		self.profitLabel.backgroundColor = [UIColor clearColor];
		[self.contentView addSubview:self.profitLabel];
		
		self.pprLabel = [[UILabel alloc] initWithFrame:CGRectMake(2, 2, 32, 40)];
		self.pprLabel.font = [UIFont boldSystemFontOfSize:14];
		self.pprLabel.adjustsFontSizeToFitWidth = YES;
		self.pprLabel.minimumScaleFactor = .8;
		self.pprLabel.text = @"PPR";
		self.pprLabel.textAlignment = NSTextAlignmentCenter;
		self.pprLabel.textColor = [UIColor blackColor];
		self.pprLabel.backgroundColor = [UIColor clearColor];
		[self.contentView addSubview:self.pprLabel];
		
		
	}
	return self;
}

- (void)layoutSubviews {
	
	[super layoutSubviews];
	
	[GameCell layoutSubviews:self.frame nameLabel:self.nameLabel dateLabel:self.dateLabel locationLabel:self.locationLabel hoursLabel:self.hoursLabel profitLabel:self.profitLabel];
	
}

+ (void) layoutSubviews:(CGRect)cellRect
			  nameLabel:(UILabel *)nameLabel
			  dateLabel:(UILabel *)dateLabel
		  locationLabel:(UILabel *)locationLabel
			 hoursLabel:(UILabel *)hoursLabel
			profitLabel:(UILabel *)profitLabel
{
	
	float width=cellRect.size.width;
	
	nameLabel.frame = CGRectMake(40, 0, width-150, 22);
	locationLabel.frame = CGRectMake(width-110, 0, 100, 22);
	dateLabel.frame = CGRectMake(40, 22, width*0.4, 22);
	hoursLabel.frame = CGRectMake(10+width/2, 22, 50, 22);
	profitLabel.frame = CGRectMake(width-95, 20, 85, 22);
}

+(void)populateGameCell:(GameCell *)cell gameObj:(GameObj *)gameObj evenFlg:(BOOL)evenFlg {
	NSString *faSymbol = ([@"Cash" isEqualToString:gameObj.type])?[NSString fontAwesomeIconStringForEnum:FAMoney]:[NSString fontAwesomeIconStringForEnum:FATrophy];
	if(gameObj.hudStatsFlg)
		faSymbol = [NSString stringWithFormat:@"%@ %@", faSymbol, [NSString fontAwesomeIconStringForEnum:FAuserSecret]];
	cell.nameLabel.text = [NSString stringWithFormat:@"%@ %@", faSymbol, gameObj.name];
	cell.dateLabel.text = [ProjectFunctions displayLocalFormatDate:gameObj.startTime showDay:YES showTime:YES];
	cell.hoursLabel.text = [NSString stringWithFormat:@"(%@ hrs)", gameObj.hours];
	cell.locationLabel.text = gameObj.location;
	cell.profitLabel.text = [NSString stringWithFormat:@"%@", [ProjectFunctions convertIntToMoneyString:gameObj.profit]];
	
	if(gameObj.profit>=0) {
		cell.profitLabel.textColor = [UIColor colorWithRed:0 green:.5 blue:0 alpha:1]; //<-- green
	} else {
		cell.profitLabel.textColor = [UIColor colorWithRed:.7 green:0 blue:0 alpha:1]; //<-- red
	}
	
	cell.nameLabel.textColor = [UIColor blackColor];
	if(gameObj.cashGameFlg) {
		cell.backgroundColor=(evenFlg)?[UIColor colorWithWhite:.9 alpha:1]:[UIColor whiteColor];
	} else {
		cell.backgroundColor=(evenFlg)?[UIColor colorWithRed:217/255.0 green:223/255.0 blue:1 alpha:1.0]:[UIColor colorWithRed:237/255.0 green:243/255.0 blue:1 alpha:1.0];
	}
	
	cell.profitImageView.image = [ProjectFunctions getPlayerTypeImage:gameObj.buyInAmount+gameObj.reBuyAmount winnings:gameObj.profit];
	cell.pprLabel.text = [NSString stringWithFormat:@"%d", gameObj.ppr];
	cell.profitImageView.hidden=YES;
	int value = [ProjectFunctions getNewPlayerType:gameObj.risked winnings:gameObj.profit];
	cell.pprLabel.backgroundColor = [self colorForType:value];
	
	if([gameObj.status isEqualToString:@"In Progress"]) {
		cell.backgroundColor = [UIColor yellowColor];
		cell.profitLabel.text = @"Playing";
		cell.profitLabel.textColor = [UIColor redColor];
	}
}

+(UIColor *)colorForType:(int)type {
	NSArray *colors = [NSArray arrayWithObjects:
					   [UIColor redColor], // fish
					   [UIColor colorWithRed:1 green:.7 blue:0 alpha:1], //
					   [UIColor yellowColor], //
					   [UIColor colorWithRed:.75 green:1 blue:0 alpha:1], // rounder (orange)
					   [UIColor colorWithRed:0 green:.7 blue:0 alpha:1], // rounder (orange)
					   [UIColor greenColor], //
					   [UIColor colorWithRed:.7 green:.7 blue:.7 alpha:1],
					   nil];
	return [colors objectAtIndex:type];
}

+(void)populateCell:(GameCell *)cell obj:(NSManagedObject *)mo evenFlg:(BOOL)evenFlg {
	GameObj *gameObj = [GameObj gameObjFromDBObj:mo];
	[self populateGameCell:cell gameObj:gameObj evenFlg:evenFlg];
	
}


@end
