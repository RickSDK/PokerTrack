//
//  NetUserObj.m
//  PokerTracker
//
//  Created by Rick Medved on 3/23/16.
//
//

#import "NetUserObj.h"
#import "ProjectFunctions.h"

@implementation NetUserObj

+(NetUserObj *)userObjFromString:(NSString *)line type:(int)type {
	NetUserObj *netUserObj = [NetUserObj new];
	NSArray *elements = [line componentsSeparatedByString:@"<xx>"];
	if(elements.count>4) {
		netUserObj.basicsStr = [elements objectAtIndex:0];
		netUserObj.last10Str = [elements objectAtIndex:1];
		netUserObj.yearStats = [elements objectAtIndex:2];
		netUserObj.monthStats = [elements objectAtIndex:3];
		netUserObj.lastGameStr = [elements objectAtIndex:4];
		if(elements.count>7) {
			netUserObj.last90Days = [elements objectAtIndex:5];
			netUserObj.thisMonthGames = [elements objectAtIndex:6];
			netUserObj.last10Games = [elements objectAtIndex:7];
		}
		
		//-----------basicsElements----------------
		NSArray *basicsElements = [netUserObj.basicsStr componentsSeparatedByString:@"|"];
		if(basicsElements.count>10) {
			netUserObj.name = [basicsElements objectAtIndex:0];
			netUserObj.userId = [[basicsElements objectAtIndex:1] intValue];
			netUserObj.email = [basicsElements objectAtIndex:2];
			netUserObj.city = [basicsElements objectAtIndex:3];
			netUserObj.state = [basicsElements objectAtIndex:4];
			netUserObj.country = [basicsElements objectAtIndex:5];
			netUserObj.viewingUserId = [[basicsElements objectAtIndex:6] intValue];
			netUserObj.friendStatus = [basicsElements objectAtIndex:7];
			netUserObj.nowPlayingFlg = [[basicsElements objectAtIndex:8] isEqualToString:@"Y"];
			netUserObj.moneySymbol = [basicsElements objectAtIndex:9];
			netUserObj.version = [basicsElements objectAtIndex:10];
		} else
			NSLog(@"Not enough!! userObjFromString %d", (int)basicsElements.count);
		
		if(basicsElements.count>11)
			netUserObj.iconGroupNumber = [[basicsElements objectAtIndex:11] intValue];

		if(netUserObj.city.length==0)
			netUserObj.location = @"Parts unknown";
		else {
			if([netUserObj.country isEqualToString:@"USA"])
				netUserObj.location = [NSString stringWithFormat:@"%@, %@", netUserObj.city, netUserObj.state];
			else
				netUserObj.location = [NSString stringWithFormat:@"%@, (%@)", netUserObj.city, netUserObj.country];
		}

		//-----------monthStats----------------
		
		[self populateGameStats:netUserObj line:netUserObj.monthStats type:type];

		//-----------lastGameStr----------------
		if(netUserObj.lastGameStr.length>20)
			netUserObj.lastGame = [GameObj populateGameFromNetUserString:netUserObj.lastGameStr];
		
		//----last10Str---------
		netUserObj.statsTitles = [NSArray arrayWithObjects:
						   NSLocalizedString(@"Games", nil),
						   NSLocalizedString(@"Streak", nil),
						   NSLocalizedString(@"Risked", nil),
						   NSLocalizedString(@"Profit", nil),
						   @"ROI",
						   NSLocalizedString(@"Hours", nil),
						   NSLocalizedString(@"Hourly", nil),
						   NSLocalizedString(@"Last Played", nil),
						   NSLocalizedString(@"Last Location", nil),
						   nil];
		NSString *lastStart = netUserObj.lastGame.startTimeStr;
		if(netUserObj.nowPlayingFlg)
			lastStart = @"Now Playing!";
		
		netUserObj.last10StatsValues = [self statFieldsFromLine:netUserObj.last10Str lastStart:lastStart lastLocation:netUserObj.lastGame.location];
		netUserObj.last10StatsColors = [self statColorsFOrArray:netUserObj.last10StatsValues];
		netUserObj.yearStatsValues = [self statFieldsFromLine:netUserObj.yearStats lastStart:lastStart lastLocation:netUserObj.lastGame.location];
		netUserObj.yearStatsColors = [self statColorsFOrArray:netUserObj.yearStatsValues];
		netUserObj.monthStatsValues = [self statFieldsFromLine:netUserObj.monthStats lastStart:lastStart lastLocation:netUserObj.lastGame.location];
		netUserObj.monthStatsColors = [self statColorsFOrArray:netUserObj.monthStatsValues];
		
	}
	netUserObj.flagImage = [UIImage imageNamed:@"World.jpg"];
	netUserObj.hasFlag = YES;
	if(netUserObj.country.length>0) {
		NSString *fileName = [NSString stringWithFormat:@"%@.png", netUserObj.country];
		fileName = [fileName stringByReplacingOccurrencesOfString:@" " withString:@"_"];
		netUserObj.flagImage = [UIImage imageNamed:fileName];
		if (netUserObj.flagImage) {
			netUserObj.hasFlag = YES;
		} else {
			netUserObj.flagImage = [UIImage imageNamed:@"World2.jpg"];
		}
	}
	return netUserObj;
}

+(void)populateGameStats:(NetUserObj *)netUserObj line:(NSString *)line type:(int)type {
//	NSLog(@"+++%@ %@", netUserObj.name, line);
	NSArray *statFields = [line componentsSeparatedByString:@"|"];
	
	if(statFields.count>7) {
		netUserObj.games = [NSString stringWithFormat:@"Games: %@", [statFields objectAtIndex:1]];
		netUserObj.minutes = [[statFields objectAtIndex:7] intValue];
		netUserObj.risked = [[statFields objectAtIndex:3] doubleValue];
		netUserObj.profit = [[statFields objectAtIndex:4] doubleValue];
		int streak = [[statFields objectAtIndex:5] intValue];
		netUserObj.pprCount = [[statFields objectAtIndex:6] intValue];
		netUserObj.ppr	= [NSString stringWithFormat:@"%d", netUserObj.pprCount-100];
		netUserObj.gameCount = [[statFields objectAtIndex:1] intValue];
		
		NSString *timeFrame = [statFields objectAtIndex:0];
		NSString *displayType = timeFrame;
		if(type==0)
			displayType = @"Last10";
		if(type==1)
			displayType = [ProjectFunctions getNetTrackerMonth];
		if(type==2)
			displayType = [NSString stringWithFormat:@"%d", [ProjectFunctions getNowYear]];
		if(type==99)
			displayType=timeFrame; // always show stats for net tracker
		
		if(![displayType isEqualToString:timeFrame]) {
			netUserObj.games = @"Games: 0";
			netUserObj.gameCount = 0;
			netUserObj.pprCount = 100;
			netUserObj.minutes = 0;
			netUserObj.risked = 0;
			netUserObj.profit = 0;
			streak = 0;
			netUserObj.ppr	= @"ROI: -";;
		}
		
		netUserObj.hours = (float)netUserObj.minutes/60;
		netUserObj.profitStr = [ProjectFunctions convertNumberToMoneyString:netUserObj.profit];
		netUserObj.hourly = @"-";
		if(netUserObj.hours>0)
			netUserObj.hourly = [NSString stringWithFormat:@"%@/hr", [ProjectFunctions smallLabelForMoney:netUserObj.profit/netUserObj.hours totalMoneyRange:netUserObj.profit/netUserObj.hours]];
		netUserObj.streak= @"stk: -";
		if(streak>0)
			netUserObj.streak = [NSString stringWithFormat:@"stk: W%d", streak];
		if(streak<0)
			netUserObj.streak = [NSString stringWithFormat:@"stk: L%d", streak*-1];
	}
	netUserObj.leftImage = [ProjectFunctions getPtpPlayerTypeImage:netUserObj.risked winnings:netUserObj.profit iconGroupNumber:netUserObj.iconGroupNumber];
}

+(NSArray *)statColorsFOrArray:(NSArray *)values {
	double profit=0;
	if(values.count>3)
		profit = [ProjectFunctions convertMoneyStringToDouble:[values objectAtIndex:3]];
	NSMutableArray *colors = [[NSMutableArray alloc] init];
	for(int i=1; i<values.count; i++) {
		if(i==4 || i==7)
			[colors addObject:[ProjectFunctions colorForProfit:profit]];
		else
			[colors addObject:[UIColor blackColor]];
	}
	return colors;
}

+(NSArray *)statFieldsFromLine:(NSString *)line lastStart:(NSString *)lastStart lastLocation:(NSString *)lastLocation {
	NSArray *statFields = [line componentsSeparatedByString:@"|"];
	double risked=0;
	double profit=0;
	float hours=0;
	int streak=0;
	if(!lastStart) {
		lastStart = @"?";
		lastLocation = @"?";
	}
	if(statFields.count>7) {
		risked = [[statFields objectAtIndex:3] doubleValue];
		profit = [[statFields objectAtIndex:4] doubleValue];
		hours = [[statFields objectAtIndex:7] floatValue]/60;
		streak = [[statFields objectAtIndex:5] intValue];
	}
	return [NSArray arrayWithObjects:
			[statFields objectAtIndex:1],
			[ProjectFunctions getWinLossStreakString:streak],
			[ProjectFunctions convertNumberToMoneyString:risked],
			[ProjectFunctions convertNumberToMoneyString:profit],
			[ProjectFunctions pprStringFromProfit:profit risked:risked],
			[NSString stringWithFormat:@"%.1f", hours],
			[ProjectFunctions hourlyStringFromProfit:profit hours:hours],
			lastStart,
			lastLocation,
			nil];
}

+(NetUserObj *)friendObjFromLine:(NSString *)line {
	return [self userObjFromString:line type:1];
}

- (NSComparisonResult)compare:(NetUserObj *)otherObject {
	//	NSString *amount = [NSString stringWithFormat:@"%f", self.amount];
	//	NSString *othertAmount = [NSString stringWithFormat:@"%f", otherObject.amount];
	//	return [amount compare:othertAmount];
	//	return [[NSNumber numberWithDouble:self.amount] compare:[NSNumber numberWithDouble:otherObject.amount]];
	return [[NSNumber numberWithDouble:otherObject.profit] compare:[NSNumber numberWithDouble:self.profit]];
}
- (NSComparisonResult)compareGames:(NetUserObj *)otherObject {
	return [[NSNumber numberWithInt:otherObject.gameCount] compare:[NSNumber numberWithInt:self.gameCount]];
}

- (NSComparisonResult)comparePpr:(NetUserObj *)otherObject {
	return [[NSNumber numberWithInt:otherObject.pprCount] compare:[NSNumber numberWithInt:self.pprCount]];
}


@end
