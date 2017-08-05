//
//  GameObj.m
//  PokerTracker
//
//  Created by Rick Medved on 1/22/16.
//
//

#import "GameObj.h"
#import "ProjectFunctions.h"
#import "NSString+ATTString.h"
#import "NSDate+ATTDate.h"
#import "PlayerObj.h"

@implementation GameObj



+(GameObj *)gameObjFromDBObj:(NSManagedObject *)mo {
	GameObj *gameObj = [GameObj new];
	gameObj.tournamentGameFlg = [@"Tournament" isEqualToString:[mo valueForKey:@"Type"]];
	gameObj.type = [mo valueForKey:@"Type"];
	gameObj.startTime = [mo valueForKey:@"startTime"];
	gameObj.endTime = [mo valueForKey:@"endTime"];
	gameObj.location = [mo valueForKey:@"location"];
	gameObj.bankroll = [mo valueForKey:@"bankroll"];
	gameObj.status = [mo valueForKey:@"status"];
	gameObj.notes = [mo valueForKey:@"notes"];
	gameObj.limit = [mo valueForKey:@"limit"];
	gameObj.stakes = [mo valueForKey:@"stakes"];
	gameObj.gametype = [mo valueForKey:@"gametype"];
	gameObj.tournamentType = [mo valueForKey:@"tournamentType"];
	gameObj.hudHeroStr = [mo valueForKey:@"attrib01"];
	gameObj.hudVillianStr = [mo valueForKey:@"attrib02"];
	
	gameObj.buyInAmount = [[mo valueForKey:@"buyInAmount"] doubleValue];
	gameObj.reBuyAmount = [[mo valueForKey:@"rebuyAmount"] doubleValue];
	gameObj.cashoutAmount = [[mo valueForKey:@"cashoutAmount"] doubleValue];
	gameObj.foodDrink = [[mo valueForKey:@"foodDrinks"] intValue];
	gameObj.tokes = [[mo valueForKey:@"tokes"] intValue];
	gameObj.breakMinutes = [[mo valueForKey:@"breakMinutes"] intValue];
	
	gameObj.tournamentSpots = [[mo valueForKey:@"tournamentSpots"] intValue];
	gameObj.tournamentSpotsPaid = [[mo valueForKey:@"tournamentSpotsPaid"] intValue];
	gameObj.tournamentFinish = [[mo valueForKey:@"tournamentFinish"] intValue];

	
	gameObj.weekday = [mo valueForKey:@"weekday"];
	gameObj.daytime = [mo valueForKey:@"daytime"];
	gameObj.numRebuys = [[mo valueForKey:@"numRebuys"] intValue];

	gameObj.startingChips = [[mo valueForKey:@"attrib05"] intValue];
	gameObj.currentChips = [[mo valueForKey:@"hudHeroLine"] intValue];
	gameObj.rebuyChips = [[mo valueForKey:@"hudVillianLine"] intValue];

	

	//	gameObj.name = [mo valueForKey:@"name"];
	//	gameObj.hours = [mo valueForKey:@"hours"];
	//	gameObj.minutes = [[mo valueForKey:@"minutes"] intValue];

	// calculated values--------------------
	gameObj.isTourney = [@"Tournament" isEqualToString:gameObj.type];
	gameObj.hudStatsFlg = (gameObj.hudHeroStr.length>10 || gameObj.hudVillianStr.length>10);
	gameObj.hudSkillLevel = @"-";
	gameObj.hudVpip = @"-";
	gameObj.hudPlayerType = @"-";
	if(gameObj.hudHeroStr.length>10) {
		NSArray *components = [gameObj.hudHeroStr componentsSeparatedByString:@":"];
		if(components.count>6) {
			PlayerObj *hudPlayerObj = [[PlayerObj alloc] init];
			hudPlayerObj.foldCount = [[components objectAtIndex:0] intValue];
			hudPlayerObj.checkCount = [[components objectAtIndex:1] intValue];
			hudPlayerObj.callCount = [[components objectAtIndex:2] intValue];
			hudPlayerObj.raiseCount = [[components objectAtIndex:3] intValue];
			hudPlayerObj.picId = [[components objectAtIndex:4] intValue];
			int vpip = [PlayerObj vpipForPlayer:hudPlayerObj];
			int pfr = [PlayerObj pfrForPlayer:hudPlayerObj];
			NSString *af = [PlayerObj afForPlayer:hudPlayerObj];
			gameObj.hudVpip	= [NSString stringWithFormat:@"%d / %d (%@)", vpip, pfr, af];
			gameObj.hudSkillLevel = [self playerSkillLevelForType:hudPlayerObj.picId];
			int looseNum = [[components objectAtIndex:5] intValue];
			int agressiveNum = [[components objectAtIndex:6] intValue];
			gameObj.hudPlayerType = [ProjectFunctions playerTypeFromLlooseNum:looseNum agressiveNum:agressiveNum];
			gameObj.hudPlayerTypeLong = [ProjectFunctions playerTypeLongFromLooseNum:looseNum agressiveNum:agressiveNum];
		}
		if (gameObj.hudHeroStr.length>10 && gameObj.hudVillianStr.length>10 && [@"0:0:0:0" isEqualToString:[gameObj.hudHeroStr substringToIndex:7]] && [@"0:0:0:0" isEqualToString:[gameObj.hudVillianStr substringToIndex:7]])
			gameObj.hudStatsFlg=NO;
	}
	if(gameObj.hudVillianStr.length>10) {
		NSArray *components = [gameObj.hudVillianStr componentsSeparatedByString:@":"];
		if(components.count>8) {
			int looseNum = [[components objectAtIndex:5] intValue];
			int agressiveNum = [[components objectAtIndex:6] intValue];
			gameObj.hudVillianName = [components objectAtIndex:8];
			gameObj.hudVillianTypeLong = [ProjectFunctions playerTypeLongFromLooseNum:looseNum agressiveNum:agressiveNum];
		}
	}
	NSString *middleValue = ([@"Cash" isEqualToString:gameObj.type])?gameObj.stakes:gameObj.tournamentType;
	gameObj.name = [NSString stringWithFormat:@"%@ %@ %@", gameObj.gametype, middleValue, gameObj.limit];
	gameObj.risked = gameObj.buyInAmount + gameObj.reBuyAmount;
	if (gameObj.reBuyAmount > 0 && gameObj.numRebuys < 1)
		gameObj.numRebuys = 1;
	
	gameObj.takeHome = gameObj.cashoutAmount - gameObj.risked;
	gameObj.profit = gameObj.cashoutAmount + gameObj.foodDrink - gameObj.risked;
	double winnings = [[mo valueForKey:@"winnings"] doubleValue];
	gameObj.grossIncome = gameObj.cashoutAmount + gameObj.tokes + gameObj.foodDrink - gameObj.risked;
	gameObj.ppr = [ProjectFunctions calculatePprAmountRisked:gameObj.risked netIncome:gameObj.profit];
	
	NSDate *endTime = gameObj.endTime;
	if([gameObj.status isEqualToString:@"In Progress"]) {
		endTime = [NSDate date];
		gameObj.playFlag = YES;
	} else if(winnings != gameObj.profit) {
		NSLog(@"+++++++++++++++++++++++++");
		NSLog(@"Whoa!!!!! winnings: %f %f", winnings, gameObj.profit);
		NSLog(@"+++++++++++++++++++++++++");
		[ProjectFunctions setUserDefaultValue:@"" forKey:@"scrub2017"];
	}

	gameObj.minutes = [ProjectFunctions getMinutesPlayedUsingStartTime:gameObj.startTime andEndTime:endTime andBreakMin:gameObj.breakMinutes];

	
//	gameObj.hourlyStr = [ProjectFunctions hourlyStringFromProfit:gameObj.profit hours:gameObj.minutes/60];
	gameObj.hours = [NSString stringWithFormat:@"%.1f", (float)gameObj.minutes/60];
	gameObj.startTimeStr = [ProjectFunctions displayLocalFormatDate:gameObj.startTime showDay:YES showTime:YES];
	gameObj.startTimeAltStr = [gameObj.startTime convertDateToStringWithFormat:@"EEEE hh:mm a"];
	gameObj.startTimePTP = [gameObj.startTime convertDateToStringWithFormat:nil];
	gameObj.endTimePTP = [gameObj.endTime convertDateToStringWithFormat:nil];
	gameObj.weekdayAltStr = [NSString stringWithFormat:@"%@ %@", gameObj.weekday, gameObj.daytime];
	gameObj.endTimeStr = [ProjectFunctions displayLocalFormatDate:gameObj.endTime showDay:YES showTime:YES];
	gameObj.profitStr = [ProjectFunctions convertNumberToMoneyString:gameObj.profit];
	gameObj.profitLongStr = [NSString stringWithFormat:@"%@ (%@)", gameObj.profitStr, gameObj.hourlyStr];
	gameObj.buyInAmountStr = [ProjectFunctions convertNumberToMoneyString:gameObj.buyInAmount];
	gameObj.cashoutAmountStr = [ProjectFunctions convertNumberToMoneyString:gameObj.cashoutAmount];
	gameObj.riskedStr = [ProjectFunctions convertNumberToMoneyString:gameObj.risked];
	gameObj.grossIncomeStr = [ProjectFunctions convertNumberToMoneyString:gameObj.grossIncome];
	gameObj.takeHomeStr = [ProjectFunctions convertNumberToMoneyString:gameObj.takeHome];
	gameObj.foodDrinkStr = [ProjectFunctions convertNumberToMoneyString:gameObj.foodDrink];
	gameObj.tokesStr = [ProjectFunctions convertNumberToMoneyString:gameObj.tokes];
	gameObj.reBuyAmountStr = [ProjectFunctions convertNumberToMoneyString:gameObj.reBuyAmount];
	gameObj.roiStr = [NSString stringWithFormat:@"%d%%", gameObj.ppr];
	gameObj.numRebuysStr = [NSString stringWithFormat:@"%d", gameObj.numRebuys];
	gameObj.breakMinutesStr = [NSString stringWithFormat:@"%d", gameObj.breakMinutes];
	gameObj.tournamentSpotsStr = [NSString stringWithFormat:@"%d", gameObj.tournamentSpots];
	gameObj.tournamentSpotsPaidStr = [NSString stringWithFormat:@"%d", gameObj.tournamentSpotsPaid];
	gameObj.tournamentFinishStr = [self placeStrFromPlace:gameObj.tournamentFinish];
	gameObj = [self updateMoreFieldsForObj:gameObj];
	
	return gameObj;
}

+(NSString *)placeStrFromPlace:(int)place {
	if(place==0)
		return @"?";
	NSString *suffix;
	int ones = place % 10;
	int tens = (place/10) % 10;
	
	if (tens ==1) {
		suffix = @"th";
	} else if (ones == 1) {
		suffix = @"st";
	} else if (ones == 2) {
		suffix = @"nd";
	} else if (ones == 3) {
		suffix = @"rd";
	} else {
		suffix = @"th";
	}
	
	return [NSString stringWithFormat:@"%d%@", place, suffix];
}

+(NSString *)playerSkillLevelForType:(int)type {
	NSArray *types = [NSArray arrayWithObjects:@"Donkey", @"Fish", @"Rounder", @"Grinder", @"Shark", @"Pro", nil];
	if(type<types.count)
		return [types objectAtIndex:type];
	return @"?";
}

+(GameObj *)updateMoreFieldsForObj:(GameObj *)gameObj {
	gameObj.endTimeStr = [ProjectFunctions displayLocalFormatDate:gameObj.endTime showDay:YES showTime:YES];
	if(gameObj.playFlag) {
		gameObj.endTimeStr = @"In Progress...";
		int gameMinutes = [[NSDate date] timeIntervalSinceDate:gameObj.startTime]/60;
		if(gameMinutes>gameObj.minutes)
			gameObj.minutes = gameMinutes;
	}
	gameObj.tournamentGameFlg = [@"Tournament" isEqualToString:gameObj.type];
	gameObj.risked = gameObj.buyInAmount+gameObj.reBuyAmount;
	gameObj.takeHome = gameObj.cashoutAmount - gameObj.risked;
	gameObj.profit = gameObj.cashoutAmount + gameObj.foodDrink - gameObj.risked;
	gameObj.grossIncome = gameObj.cashoutAmount + gameObj.tokes + gameObj.foodDrink - gameObj.risked;
	gameObj.ppr = [ProjectFunctions calculatePprAmountRisked:gameObj.risked netIncome:gameObj.profit];
	gameObj.hourlyStr = [ProjectFunctions hourlyStringFromProfit:gameObj.profit hours:(float)gameObj.minutes/60];
	gameObj.hours = [NSString stringWithFormat:@"%.1f", (float)gameObj.minutes/60];
	gameObj.startTimeStr = [ProjectFunctions displayLocalFormatDate:gameObj.startTime showDay:YES showTime:YES];
	if(!gameObj.lastUpd)
		gameObj.lastUpd = gameObj.endTime;
	gameObj.lastUpdStr = [ProjectFunctions displayLocalFormatDate:gameObj.lastUpd showDay:YES showTime:YES];
	gameObj.startTimeAltStr = [gameObj.startTime convertDateToStringWithFormat:@"EEEE hh:mm a"];
	gameObj.startTimePTP = [gameObj.startTime convertDateToStringWithFormat:nil];
	gameObj.endTimePTP = [gameObj.endTime convertDateToStringWithFormat:nil];
	gameObj.weekdayAltStr = [NSString stringWithFormat:@"%@ %@", gameObj.weekday, gameObj.daytime];
	gameObj.profitStr = [ProjectFunctions convertNumberToMoneyString:gameObj.profit];
	gameObj.profitLongStr = [NSString stringWithFormat:@"%@ (%@)", gameObj.profitStr, gameObj.hourlyStr];
	gameObj.buyInAmountStr = [ProjectFunctions convertNumberToMoneyString:gameObj.buyInAmount];
	gameObj.cashoutAmountStr = [ProjectFunctions convertNumberToMoneyString:gameObj.cashoutAmount];
	gameObj.riskedStr = [ProjectFunctions convertNumberToMoneyString:gameObj.risked];
	gameObj.grossIncomeStr = [ProjectFunctions convertNumberToMoneyString:gameObj.grossIncome];
	gameObj.takeHomeStr = [ProjectFunctions convertNumberToMoneyString:gameObj.takeHome];
	gameObj.foodDrinkStr = [ProjectFunctions convertNumberToMoneyString:gameObj.foodDrink];
	gameObj.tokesStr = [ProjectFunctions convertNumberToMoneyString:gameObj.tokes];
	gameObj.reBuyAmountStr = [ProjectFunctions convertNumberToMoneyString:gameObj.reBuyAmount];
	gameObj.roiStr = [NSString stringWithFormat:@"%d%%", gameObj.ppr];
	gameObj.pprStr = [ProjectFunctions pprStringFromProfit:gameObj.profit risked:gameObj.risked];
	gameObj.numRebuysStr = [NSString stringWithFormat:@"%d", gameObj.numRebuys];
	gameObj.breakMinutesStr = [NSString stringWithFormat:@"%d", gameObj.breakMinutes];
	gameObj.tournamentSpotsStr = (gameObj.tournamentSpots==0)?@"?":[NSString stringWithFormat:@"%d", gameObj.tournamentSpots];
	gameObj.tournamentSpotsPaidStr = (gameObj.tournamentSpotsPaid==0)?@"?":[NSString stringWithFormat:@"%d", gameObj.tournamentSpotsPaid];
	gameObj.tournamentFinishStr = [self placeStrFromPlace:gameObj.tournamentFinish];
	return gameObj;
}

+(GameObj *)populateGameFromString:(NSString *)line {
	return [self populateGameFromNetUserString:line];
}

+(GameObj *)populateGameFromNetUserString:(NSString *)line {
	//NSLog(@"*-*: %@", line);
	GameObj *gameObj = [[GameObj alloc] init];
	NSArray *components = [line componentsSeparatedByString:@"|"];
	if(components.count>6) {
		gameObj.startTime = [[components objectAtIndex:0] convertStringToDateFinalSolution];
		gameObj.startTimeStr = [components objectAtIndex:0];
		gameObj.buyInAmount = [[components objectAtIndex:1] doubleValue];
		gameObj.reBuyAmount = [[components objectAtIndex:2] doubleValue];
		gameObj.cashoutAmount = [[components objectAtIndex:3] doubleValue];
		gameObj.location = [components objectAtIndex:4];
		gameObj.minutes = [[components objectAtIndex:5] intValue];
		gameObj.type = [components objectAtIndex:6];
	}
	if(components.count>12) {
		gameObj.playFlag = [@"Y" isEqualToString:[components objectAtIndex:7]];
		gameObj.gametype = [components objectAtIndex:8];
		gameObj.stakes = [components objectAtIndex:9];
		gameObj.limit = [components objectAtIndex:10];
		gameObj.name = [NSString stringWithFormat:@"%@ %@ %@", gameObj.gametype, gameObj.stakes, gameObj.limit];
		
		gameObj.lastUpdStr = [components objectAtIndex:11];
		gameObj.endTimeStr = [components objectAtIndex:12];
		gameObj.lastUpd = [[components objectAtIndex:11] convertStringToDateFinalSolution];
		int gameMinutes = [gameObj.lastUpd timeIntervalSinceDate:gameObj.startTime]/60;
		if(gameMinutes>gameObj.minutes)
			gameObj.minutes = gameMinutes;
//		NSLog(@"+++lastUpd: %d %@", gameMinutes, gameObj.location);
		gameObj.endTime = [[components objectAtIndex:12] convertStringToDateFinalSolution];
		gameObj.status = @"unknown";
	} else
		NSLog(@"Not enough!!!! [%@]", line);
	gameObj = [self updateMoreFieldsForObj:gameObj];
	
	return gameObj;
}





@end
