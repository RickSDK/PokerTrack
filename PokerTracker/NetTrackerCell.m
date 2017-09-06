//
//  NetTrackerCell.m
//  PokerTracker
//
//  Created by Rick Medved on 8/20/17.
//
//

#import "NetTrackerCell.h"
#import "ProjectFunctions.h"

#define col1	50
#define col2	200

#define row1	7
#define row2	24
#define row3	40

#define width1	175


@implementation NetTrackerCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	if (self) {
		self.leftView = [[UIView alloc] initWithFrame:CGRectMake(1, 1, 40, 58)];
		self.leftView.backgroundColor = [UIColor yellowColor];
		self.leftView.layer.cornerRadius = 7;
		self.leftView.layer.masksToBounds = YES;				// clips background images to rounded corners
		self.leftView.layer.borderColor = [ProjectFunctions segmentThemeColor].CGColor;
		self.leftView.layer.borderWidth = 1.;
		self.leftView.backgroundColor = [ProjectFunctions primaryButtonColor];
		[self.contentView addSubview:self.leftView];
		
		self.playerTypeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 12, 30, 34)];
		self.playerTypeImageView.image = [UIImage imageNamed:@"playerType1.png"];
		[self.leftView addSubview:self.playerTypeImageView];
		
		self.roiLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 40, 12)];
		self.roiLabel.font = [UIFont boldSystemFontOfSize:9];
		self.roiLabel.adjustsFontSizeToFitWidth = YES;
		self.roiLabel.minimumScaleFactor = .7;
		self.roiLabel.text = NSLocalizedString(@"ROI", nil);
		self.roiLabel.textAlignment = NSTextAlignmentCenter;
		self.roiLabel.textColor = [UIColor whiteColor];
		self.roiLabel.backgroundColor = [ProjectFunctions segmentThemeColor];
		[self.leftView addSubview:self.roiLabel];

		self.pprLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 46, 40, 12)];
		self.pprLabel.font = [UIFont boldSystemFontOfSize:9];
		self.pprLabel.adjustsFontSizeToFitWidth = YES;
		self.pprLabel.minimumScaleFactor = .7;
		self.pprLabel.text = NSLocalizedString(@"100", nil);
		self.pprLabel.textAlignment = NSTextAlignmentCenter;
		self.pprLabel.textColor = [UIColor whiteColor];
		self.pprLabel.backgroundColor = [ProjectFunctions segmentThemeColor];
		[self.leftView addSubview:self.pprLabel];
		
		//----------------col1--------------

		self.flagImageView = [[UIImageView alloc] initWithFrame:CGRectMake(col1, 3, 30, 17)];
		self.flagImageView.image = [UIImage imageNamed:@"World.jpg"];
		[self.contentView addSubview:self.flagImageView];

		self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(col1+35, row1, width1-30, 16)];
		self.nameLabel.font = [UIFont boldSystemFontOfSize:14];
		self.nameLabel.text = @"Name";
		self.nameLabel.textAlignment = NSTextAlignmentLeft;
		self.nameLabel.textColor = [UIColor blackColor];
		self.nameLabel.backgroundColor = [UIColor clearColor];
		[self.contentView addSubview:self.nameLabel];
		
		self.locationLabel = [[UILabel alloc] initWithFrame:CGRectMake(col1, row2, width1, 16)];
		self.locationLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:12];
		self.locationLabel.text = @"locationLabel";
		self.locationLabel.textAlignment = NSTextAlignmentLeft;
		self.locationLabel.textColor = [ProjectFunctions segmentThemeColor];
		self.locationLabel.backgroundColor = [UIColor clearColor];
		[self.contentView addSubview:self.locationLabel];
		
		self.gamesLabel = [[UILabel alloc] initWithFrame:CGRectMake(col1, row3, width1, 16)];
		self.gamesLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:12];
		self.gamesLabel.text = @"gamesLabel";
		self.gamesLabel.textAlignment = NSTextAlignmentLeft;
		self.gamesLabel.textColor = [UIColor grayColor];
		self.gamesLabel.backgroundColor = [UIColor clearColor];
		[self.contentView addSubview:self.gamesLabel];
		
		//----------------col2--------------
		self.profitLabel = [[UILabel alloc] initWithFrame:CGRectMake(col2, row1, 80, 16)];
		self.profitLabel.font = [UIFont boldSystemFontOfSize:14];
		self.profitLabel.text = @"profitLabel";
		self.profitLabel.textAlignment = NSTextAlignmentRight;
		self.profitLabel.textColor = [ProjectFunctions themeBGColor];
		self.profitLabel.backgroundColor = [UIColor clearColor];
		[self.contentView addSubview:self.profitLabel];
		
		self.hourlyLabel = [[UILabel alloc] initWithFrame:CGRectMake(col2, row2, 80, 16)];
		self.hourlyLabel.font = [UIFont systemFontOfSize:12];
		self.hourlyLabel.text = @"hourlyLabel";
		self.hourlyLabel.textAlignment = NSTextAlignmentRight;
		self.hourlyLabel.textColor = [ProjectFunctions themeBGColor];
		self.hourlyLabel.backgroundColor = [UIColor clearColor];
		[self.contentView addSubview:self.hourlyLabel];
		
		self.streakLabel = [[UILabel alloc] initWithFrame:CGRectMake(col2, row3, 80, 16)];
		self.streakLabel.font = [UIFont systemFontOfSize:10];
		self.streakLabel.text = @"streakLabel";
		self.streakLabel.textAlignment = NSTextAlignmentRight;
		self.streakLabel.textColor = [UIColor blackColor];
		self.streakLabel.backgroundColor = [UIColor clearColor];
		[self.contentView addSubview:self.streakLabel];
		
		
	}
	return self;
}

- (void)layoutSubviews {
	
	[super layoutSubviews];
	
	float width = self.contentView.frame.size.width;
	self.profitLabel.frame = CGRectMake(width-90, row1, 80, 16);
	self.hourlyLabel.frame = CGRectMake(width-90, row2, 80, 16);
	self.streakLabel.frame = CGRectMake(width-90, row3, 80, 16);
}

+(NetTrackerCell *)cellForCell:(NetTrackerCell *)cell netUserObj:(NetUserObj *)netUserObj {
	//---- ROI info-----
	int value = [ProjectFunctions getNewPlayerType:netUserObj.risked winnings:netUserObj.profit];
	cell.pprLabel.backgroundColor = [ProjectFunctions colorForPlayerType:value];
	cell.pprLabel.text = netUserObj.ppr;
	cell.pprLabel.textColor = (value==4)?[UIColor whiteColor]:[UIColor blackColor];
	cell.playerTypeImageView.image = netUserObj.leftImage;
	cell.roiLabel.backgroundColor = netUserObj.themeColorObj.navBarColor;
	cell.roiLabel.textColor = netUserObj.themeColorObj.primaryColor;
	cell.leftView.backgroundColor = netUserObj.themeColorObj.themeBGColor;
	if(netUserObj.themeFlg) {
		switch (netUserObj.themeGroupNumber) {
			case 0:
				cell.roiLabel.text = [NSString stringWithFormat:@"🏈%@", NSLocalizedString(@"ROI", nil)];
				break;
			case 1:
				cell.roiLabel.text = [NSString stringWithFormat:@"⚾️%@", NSLocalizedString(@"ROI", nil)];
				break;
			case 2:
				cell.roiLabel.text = [NSString stringWithFormat:@"🏀%@", NSLocalizedString(@"ROI", nil)];
				break;
			case 3:
				cell.roiLabel.text = [NSString stringWithFormat:@"🎓%@", NSLocalizedString(@"ROI", nil)];
				break;
			case 4:
				cell.roiLabel.text = [NSString stringWithFormat:@"❄️%@", NSLocalizedString(@"ROI", nil)];
				break;
			case 5:
				cell.roiLabel.text = [NSString stringWithFormat:@"⚽️%@", NSLocalizedString(@"ROI", nil)];
				break;
			case 6:
				cell.roiLabel.text = [NSString stringWithFormat:@"🏰%@", NSLocalizedString(@"ROI", nil)];
				break;
			case 7:
				cell.roiLabel.text = [NSString stringWithFormat:@"🈴%@", NSLocalizedString(@"ROI", nil)];
				break;
				
			default:
				cell.roiLabel.text = [NSString stringWithFormat:@"🌅%@", NSLocalizedString(@"ROI", nil)];
				break;
		}
	}
	if(netUserObj.customFlg)
		cell.roiLabel.text = [NSString stringWithFormat:@"🎨%@", NSLocalizedString(@"ROI", nil)];
	
	//---- Name--------
	if(netUserObj.hasFlag)
		cell.flagImageView.image=netUserObj.flagImage;
	cell.flagImageView.hidden=!netUserObj.hasFlag;
	cell.nameLabel.text = [NSString stringWithFormat:@"#%d - %@", netUserObj.rowId, netUserObj.name];
	cell.nameLabel.textColor = [UIColor blackColor];

	//---- Location-----
	if([@"Parts unknown" isEqualToString:netUserObj.location]) {
		cell.locationLabel.text = @"Parts unknown";
		cell.locationLabel.textColor = [ProjectFunctions primaryButtonColor];
	} else {
		cell.locationLabel.text = [NSString stringWithFormat:@"%@ %@", [NSString fontAwesomeIconStringForEnum:FAGlobe], netUserObj.location];
		cell.locationLabel.textColor = [ProjectFunctions segmentThemeColor];
	}

	//---- Games-----
	NSString *checkMark = @"";
	NSString *nowPlaying = @"";
	NSString *chipstack = @"";
	if([self isCurrentVersion:netUserObj.version])
		checkMark = [NSString fontAwesomeIconStringForEnum:FACheck];
	
	if(netUserObj.nowPlayingFlg) {
		nowPlaying = @"⛳️";
		cell.gamesLabel.textColor = [UIColor purpleColor];
		if(netUserObj.lastGame.profit>0)
			chipstack = [NSString fontAwesomeIconStringForEnum:FAArrowUp];
		if(netUserObj.lastGame.profit<0)
			chipstack = [NSString fontAwesomeIconStringForEnum:FAArrowDown];
	}
	cell.gamesLabel.text = [NSString stringWithFormat:@"%@%@%@%@", checkMark, nowPlaying, chipstack, netUserObj.games];

	//---- Profit/Hourly-----
	cell.profitLabel.text = netUserObj.profitStr;
	cell.hourlyLabel.text = netUserObj.hourly;
	if(netUserObj.profit>=0) {
		cell.profitLabel.textColor = [UIColor colorWithRed:0 green:.5 blue:0 alpha:1];
		cell.hourlyLabel.textColor = [UIColor colorWithRed:0 green:.5 blue:0 alpha:1];
	} else {
		cell.profitLabel.textColor = [UIColor redColor];
		cell.hourlyLabel.textColor = [UIColor redColor];
	}

	//---- Streak-----
	cell.streakLabel.text = netUserObj.streak;
	cell.streakLabel.textColor = (netUserObj.streakCount>=0)?[UIColor colorWithRed:0 green:.1 blue:0 alpha:1]:[UIColor colorWithRed:.75 green:0 blue:0 alpha:1];

	//---------------------
	cell.backgroundColor = [UIColor whiteColor];

	if(netUserObj.userId==netUserObj.viewingUserId) {
		cell.nameLabel.textColor = [UIColor redColor];
		cell.backgroundColor = [UIColor colorWithRed:1 green:1 blue:.5 alpha:1];
	} else if([netUserObj.friendStatus isEqualToString:@"Active"]) {
		cell.nameLabel.textColor = [UIColor redColor];
		cell.backgroundColor = [UIColor colorWithRed:.8 green:.8 blue:1 alpha:1];
	} else if([netUserObj.friendStatus isEqualToString:@"Pending"] || [netUserObj.friendStatus isEqualToString:@"Request Pending"] || [netUserObj.friendStatus isEqualToString:@"Requested"]) {
		cell.nameLabel.textColor = [UIColor redColor];
		cell.backgroundColor = [UIColor colorWithRed:.8 green:1 blue:.8 alpha:1];
	}
	
	cell.selectionStyle = UITableViewCellSelectionStyleBlue;
	if([netUserObj.friendStatus isEqualToString:@"Requested"])
		cell.gamesLabel.text = @"Friend Request Pending";
	
	if([netUserObj.friendStatus isEqualToString:@"Request Pending"]) {
		cell.backgroundColor = [UIColor colorWithRed:.8 green:1 blue:.8 alpha:1];
		cell.gamesLabel.text = @"Friend Request!";
	}
	
	cell.accessoryType = UITableViewCellAccessoryNone;
	return cell;
}

+(BOOL)isCurrentVersion:(NSString *)version {
	NSString *userVersion = version;
	NSString *projectVersion = [ProjectFunctions getProjectDisplayVersion];
	if(userVersion.length>12)
		userVersion = [userVersion substringToIndex:12];
	if(projectVersion.length>12)
		projectVersion = [projectVersion substringToIndex:12];
	return [userVersion isEqualToString:projectVersion];
}


@end
