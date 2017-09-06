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
		
//		self.bgView = [[UIView alloc] initWithFrame:CGRectZero];
//		[ProjectFunctions addGradientToView:self.bgView];
//		[self.contentView addSubview:self.bgView];
//		self.backgroundColor = [ProjectFunctions primaryButtonColor];
		
		self.profitImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 34, 44)];
		self.profitImageView.image = [UIImage imageNamed:@"playerType1.png"];
		[self.contentView addSubview:self.profitImageView];
		
		self.faLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 2, 34, 22)];
		self.faLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:13];
		self.faLabel.textAlignment = NSTextAlignmentLeft;
		self.faLabel.textColor = [UIColor blackColor];
		self.faLabel.text = [NSString fontAwesomeIconStringForEnum:FATrophy];
		self.faLabel.backgroundColor = [UIColor clearColor];
		[self.contentView addSubview:self.faLabel];
		
		self.nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		self.nameLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:13];
		self.nameLabel.text = @"nameLabel";
		self.nameLabel.textAlignment = NSTextAlignmentLeft;
		self.nameLabel.textColor = [UIColor blackColor];
		self.nameLabel.backgroundColor = [UIColor clearColor];
		[self.contentView addSubview:self.nameLabel];
		
		self.dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 22, 170, 22)];
		self.dateLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:10];
		self.dateLabel.adjustsFontSizeToFitWidth = YES;
		self.dateLabel.minimumScaleFactor = .8;
		self.dateLabel.text = @"";
		self.dateLabel.textAlignment = NSTextAlignmentLeft;
		self.dateLabel.textColor = [ProjectFunctions themeBGColor];
		self.dateLabel.backgroundColor = [UIColor clearColor];
		[self.contentView addSubview:self.dateLabel];
		
		self.hoursLabel = [[UILabel alloc] initWithFrame:CGRectMake(170, 22, 50, 22)];
		self.hoursLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:10];
		self.hoursLabel.adjustsFontSizeToFitWidth = YES;
		self.hoursLabel.minimumScaleFactor = .7;
		self.hoursLabel.text = @"hours";
		self.hoursLabel.textAlignment = NSTextAlignmentCenter;
		self.hoursLabel.textColor = [ProjectFunctions segmentThemeColor];
		self.hoursLabel.backgroundColor = [ProjectFunctions primaryButtonColor];
		self.hoursLabel.layer.cornerRadius = 4;
		self.hoursLabel.layer.masksToBounds = YES;				// clips background images to rounded corners
		[self.contentView addSubview:self.hoursLabel];
		
		
		
		self.locationLabel = [[UILabel alloc] initWithFrame:CGRectMake(210, 0, 100, 22)];
		self.locationLabel.font = [UIFont systemFontOfSize:12];
		self.locationLabel.adjustsFontSizeToFitWidth = YES;
		self.locationLabel.minimumScaleFactor = .8;
		self.locationLabel.text = @"locationLabel";
		self.locationLabel.textAlignment = NSTextAlignmentRight;
		self.locationLabel.textColor = [ProjectFunctions themeBGColor];
		self.locationLabel.backgroundColor = [UIColor clearColor];
		[self.contentView addSubview:self.locationLabel];
		
		self.profitLabel = [[UILabel alloc] initWithFrame:CGRectMake(210, 22, 100, 22)];
		self.profitLabel.font = [UIFont boldSystemFontOfSize:16];
		self.profitLabel.adjustsFontSizeToFitWidth = YES;
		self.profitLabel.minimumScaleFactor = .5;
		self.profitLabel.text = @"profitLabel";
		self.profitLabel.textAlignment = NSTextAlignmentRight;
		self.profitLabel.textColor = [UIColor greenColor];
		self.profitLabel.backgroundColor = [UIColor clearColor];
		[self.contentView addSubview:self.profitLabel];
		
		self.pprLabel = [[UILabel alloc] initWithFrame:CGRectMake(2, 2, 32, 40)];
		self.pprLabel.font = [UIFont boldSystemFontOfSize:12];
		self.pprLabel.adjustsFontSizeToFitWidth = YES;
		self.pprLabel.minimumScaleFactor = .5;
		self.pprLabel.text = @"PPR";
		self.pprLabel.textAlignment = NSTextAlignmentCenter;
		self.pprLabel.textColor = [UIColor blackColor];
		self.pprLabel.backgroundColor = [UIColor clearColor];
		self.pprLabel.layer.cornerRadius = 7;
		self.pprLabel.layer.masksToBounds = YES;				// clips background images to rounded corners
		self.pprLabel.layer.borderColor = [ProjectFunctions segmentThemeColor].CGColor;
		self.pprLabel.layer.borderWidth = 1.;
		[self.contentView addSubview:self.pprLabel];
		
		self.roiLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 32, 12)];
		self.roiLabel.font = [UIFont boldSystemFontOfSize:9];
		self.roiLabel.adjustsFontSizeToFitWidth = YES;
		self.roiLabel.minimumScaleFactor = .7;
		self.roiLabel.text = NSLocalizedString(@"ROI", nil);
		self.roiLabel.textAlignment = NSTextAlignmentCenter;
		self.roiLabel.textColor = [UIColor whiteColor];
		self.roiLabel.backgroundColor = [ProjectFunctions segmentThemeColor];
		[self.pprLabel addSubview:self.roiLabel];
		
		self.hudTypeLabel = [[UILabel alloc] initWithFrame:CGRectMake(3, 24, 30, 20)];
		self.hudTypeLabel.font = [UIFont systemFontOfSize:6];
		self.hudTypeLabel.adjustsFontSizeToFitWidth = YES;
		self.hudTypeLabel.minimumScaleFactor = .5;
		self.hudTypeLabel.text = @"Tight-Agressive";
		self.hudTypeLabel.textAlignment = NSTextAlignmentCenter;
		self.hudTypeLabel.textColor = [UIColor grayColor];
		self.hudTypeLabel.backgroundColor = [UIColor clearColor];
		self.hudTypeLabel.numberOfLines=2;
		[self.contentView addSubview:self.hudTypeLabel];
		
		
		
	}
	return self;
}

- (void)layoutSubviews {
	
	[super layoutSubviews];
	
	self.bgView.frame = CGRectMake(0, 0, self.contentView.frame.size.width, 44);
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
	
	nameLabel.frame = CGRectMake(56, 2, width-160, 22);
	locationLabel.frame = CGRectMake(width-110, 0, 100, 22);
	dateLabel.frame = CGRectMake(40, 20, width*0.4, 22);
	hoursLabel.frame = CGRectMake(10+width/2, 25, 60, 12);
	profitLabel.frame = CGRectMake(width-95, 20, 85, 22);
}

+(UIColor *)faColorForType:(NSString *)type {
	return ([@"Cash" isEqualToString:type])?[UIColor colorWithRed:0 green:.8 blue:0 alpha:1]:[UIColor colorWithRed:0 green:.3 blue:1 alpha:1];
}

+(void)populateGameCell:(GameCell *)cell gameObj:(GameObj *)gameObj evenFlg:(BOOL)evenFlg {
	//name---------
	cell.faLabel.text = ([@"Cash" isEqualToString:gameObj.type])?[NSString fontAwesomeIconStringForEnum:FAMoney]:[NSString fontAwesomeIconStringForEnum:FATrophy];
	cell.faLabel.textColor = [self faColorForType:gameObj.type];
	
	NSString *faSymbol = @"";
	if(gameObj.hudStatsFlg)
		faSymbol = [NSString fontAwesomeIconStringForEnum:FAuserSecret];
	if([@"Calendar" isEqualToString:gameObj.type])
		faSymbol = [NSString fontAwesomeIconStringForEnum:FACalendar];
	if([@"Calendar-o" isEqualToString:gameObj.type])
		faSymbol = [NSString fontAwesomeIconStringForEnum:FAcalendarCheckO];
	cell.nameLabel.text = [NSString stringWithFormat:@"%@ %@", faSymbol, gameObj.name];
	
	//date---------
	if(gameObj.startTime)
		cell.dateLabel.text = [NSString stringWithFormat:@"%@ %@", [NSString fontAwesomeIconStringForEnum:FACalendar], [ProjectFunctions displayLocalFormatDate:gameObj.startTime showDay:YES showTime:YES]];
	
	//hours---------
	NSString *hoursLabel = NSLocalizedString(@"Hours", nil);
	if([hoursLabel isEqualToString:@"Hours"])
		hoursLabel = @"Hrs";
	if(gameObj.profitStr.length>8 && hoursLabel.length>3)
		hoursLabel = [hoursLabel substringToIndex:1];
	cell.hoursLabel.text = [NSString stringWithFormat:@"%@ %.1f %@", [NSString fontAwesomeIconStringForEnum:FAClockO], [gameObj.hours floatValue], hoursLabel];

	//profit---------
	cell.profitLabel.text = gameObj.profitStr;
	if(gameObj.profit>=0) {
		cell.profitLabel.textColor = [UIColor colorWithRed:0 green:.5 blue:0 alpha:1]; //<-- green
	} else {
		cell.profitLabel.textColor = [UIColor colorWithRed:.7 green:0 blue:0 alpha:1]; //<-- red
	}

	//location---------
	NSString *location = gameObj.location;
	if(location.length>12) {
		NSArray *components = [location componentsSeparatedByString:@" "];
		if(components.count>0)
			location = [components objectAtIndex:0];
		if([@"the" isEqualToString:[location lowercaseString]] && components.count>1)
			location = [components objectAtIndex:1];
	}
	if(![@"Default" isEqualToString:gameObj.bankroll] && gameObj.bankroll.length>0)
		location = gameObj.bankroll;
	cell.locationLabel.text = location;

	//hud & ppr text---------
	cell.profitImageView.hidden=YES;
	[ProjectFunctions makeFALabel:cell.hudTypeLabel type:0 size:9];
	cell.hudTypeLabel.text = [NSString stringWithFormat:@"%@ %@", [NSString fontAwesomeIconStringForEnum:FAuserSecret], gameObj.hudPlayerType];
	cell.hudTypeLabel.hidden=!gameObj.hudStatsFlg;
	int value = [ProjectFunctions getNewPlayerType:gameObj.risked winnings:gameObj.profit];
	cell.pprLabel.backgroundColor = [ProjectFunctions colorForPlayerType:value];
	NSString *pprString = [NSString stringWithFormat:@"%d%%", [ProjectFunctions calculatePprAmountRisked:gameObj.risked netIncome:gameObj.profit]];
	cell.pprLabel.text = (pprString.length<4)?pprString:[NSString stringWithFormat:@"%d", [ProjectFunctions calculatePprAmountRisked:gameObj.risked netIncome:gameObj.profit]];
	
	cell.faLabel.hidden=NO;
	cell.backgroundColor=(evenFlg)?[UIColor colorWithWhite:.9 alpha:1]:[UIColor whiteColor];
	
	if([gameObj.status isEqualToString:@"In Progress"]) {
		cell.backgroundColor = [UIColor colorWithRed:1 green:1 blue:.8 alpha:1];
		cell.dateLabel.text = @"Now Playing!";
		cell.dateLabel.textColor = [UIColor purpleColor];
	}
}

+(void)populateCell:(GameCell *)cell obj:(NSManagedObject *)mo evenFlg:(BOOL)evenFlg {
	GameObj *gameObj = [GameObj gameObjFromDBObj:mo];
	[self populateGameCell:cell gameObj:gameObj evenFlg:evenFlg];
	
}


@end
