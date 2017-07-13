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

@implementation GameObj



+(GameObj *)gameObjFromDBObj:(NSManagedObject *)mo {
	GameObj *gameObj = [GameObj new];
	gameObj.cashGameFlg = [@"Cash" isEqualToString:[mo valueForKey:@"Type"]];
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

	//	gameObj.name = [mo valueForKey:@"name"];
	//	gameObj.hours = [mo valueForKey:@"hours"];
	//	gameObj.minutes = [[mo valueForKey:@"minutes"] intValue];
	//	gameObj.profit = [[mo valueForKey:@"winnings"] doubleValue];

	// calculated values--------------------
	gameObj.isTourney = [@"Tournament" isEqualToString:gameObj.type];
	gameObj.hudStatsFlg = (gameObj.hudHeroStr.length>10 || gameObj.hudVillianStr.length>10);
	NSString *middleValue = ([@"Cash" isEqualToString:gameObj.type])?gameObj.stakes:gameObj.tournamentType;
	gameObj.name = [NSString stringWithFormat:@"%@ %@ %@", gameObj.gametype, middleValue, gameObj.limit];
	gameObj.risked = gameObj.buyInAmount + gameObj.reBuyAmount;
	if (gameObj.reBuyAmount > 0 && gameObj.numRebuys < 1)
		gameObj.numRebuys = 1;
	
	gameObj.takeHome = gameObj.cashoutAmount - gameObj.risked;
	gameObj.profit = gameObj.cashoutAmount + gameObj.foodDrink - gameObj.risked;
	gameObj.grossIncome = gameObj.cashoutAmount + gameObj.tokes + gameObj.foodDrink - gameObj.risked;
	gameObj.ppr = [ProjectFunctions calculatePprAmountRisked:gameObj.risked netIncome:gameObj.profit];
	
	NSDate *endTime = gameObj.endTime;
	if([gameObj.status isEqualToString:@"In Progress"])
		endTime = [NSDate date];
	gameObj.minutes = [ProjectFunctions getMinutesPlayedUsingStartTime:gameObj.startTime andEndTime:endTime andBreakMin:gameObj.breakMinutes];

	gameObj.hourlyStr = @"-";
	if(gameObj.minutes > 0)
		gameObj.hourlyStr = [NSString stringWithFormat:@"%@/hr", [ProjectFunctions convertNumberToMoneyString:gameObj.profit*60/gameObj.minutes]];
	
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
	gameObj.tournamentFinishStr = [NSString stringWithFormat:@"%d", gameObj.tournamentFinish];
	
	
	return gameObj;
}

+(GameObj *)populateGameFromString:(NSString *)line {
	GameObj *gameObj = [[GameObj alloc] init];
	NSArray *components = [line componentsSeparatedByString:@"|"];
	if(components.count>6) {
		gameObj.cashGameFlg = [@"Cash" isEqualToString:[components objectAtIndex:6]];
		gameObj.type = [components objectAtIndex:6];
		gameObj.name = [NSString stringWithFormat:@"%@ %@ %@", [components objectAtIndex:8], [components objectAtIndex:9], [components objectAtIndex:10]];
		gameObj.startTime = [[components objectAtIndex:0] convertStringToDateFinalSolution];
		gameObj.endTime = [[components objectAtIndex:12] convertStringToDateFinalSolution];
		gameObj.minutes = [gameObj.endTime timeIntervalSinceDate:gameObj.startTime]/60;
		gameObj.hours = [NSString stringWithFormat:@"%.1f", (float)gameObj.minutes/60];
		gameObj.location = [components objectAtIndex:4];
		gameObj.status = @"unknown";
		
		gameObj.buyInAmount = [[components objectAtIndex:1] intValue];
		gameObj.reBuyAmount = [[components objectAtIndex:2] intValue];
		int cashout = [[components objectAtIndex:3] intValue];
		gameObj.profit = cashout-gameObj.buyInAmount-gameObj.reBuyAmount;
		gameObj.ppr = [ProjectFunctions calculatePprAmountRisked:gameObj.buyInAmount+gameObj.reBuyAmount netIncome:gameObj.profit];
//		NSLog(@"+++%@", line);
//		NSLog(@"%@ %d %d %@ [%@] [%@]", gameObj.name, gameObj.profit, gameObj.minutes, gameObj.hours, [components objectAtIndex:0], [components objectAtIndex:12]);
	}
	return gameObj;
}





@end
