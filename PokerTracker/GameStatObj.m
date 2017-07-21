//
//  GameStatObj.m
//  PokerTracker
//
//  Created by Rick Medved on 7/19/17.
//
//

#import "GameStatObj.h"
#import "ProjectFunctions.h"

@implementation GameStatObj

+(GameStatObj *)gameStatObjForGames:(NSArray *)games {
	GameStatObj *obj = [[GameStatObj alloc] init];
	for(NSManagedObject *game in games) {
		obj.games++;
		double profit = [[game valueForKey:@"winnings"] doubleValue];
		obj.profit += profit;
		obj.risked += [[game valueForKey:@"buyInAmount"] doubleValue] + [[game valueForKey:@"rebuyAmount"] doubleValue];
		if(profit>=0)
			obj.wins++;
		else
			obj.losses++;
	}
	int percent=0;
	if(obj.games>0)
		percent=obj.wins*100/obj.games;
	obj.name = [NSString stringWithFormat:@"%@: %d (%dW, %dL) %d%%", NSLocalizedString(@"Games", nil), obj.games, obj.wins, obj.losses, percent];
	return obj;
}

+(GameStatObj *)gameStatObjDetailedForGames:(NSArray *)games {
	GameStatObj *obj = [[GameStatObj alloc] init];
	double totalRebuyAmount=0;
	int streak=0;
	int winStreak=0;
	int loseStreak=0;
	int totalMinutes=0;
	float hours=0;
	double quarter1Profit=0;
	int quarter1Games=0;
	double quarter2Profit=0;
	int quarter2Games=0;
	double quarter3Profit=0;
	int quarter3Games=0;
	double quarter4Profit=0;
	int quarter4Games=0;
	int totalGamesWon=0;
	double totalGamesWonBuyin=0;
	double totalGamesWonMinProfit=0;
	if(games.count>0)
		totalGamesWonMinProfit=99999;
	double totalGamesWonMaxProfit=0;
	double totalGamesWonProfit=0;
	double totalGamesWonRisked=0;
	double totalGamesWonRebuys=0;
	
	int totalGamesLost=0;
	double totalGamesLostBuyin=0;
	double totalGamesLostMinProfit=0;
	double totalGamesLostMaxProfit=0;
	if(games.count>0)
		totalGamesLostMaxProfit=-99999;
	double totalGamesLostProfit=0;
	double totalGamesLostRisked=0;
	double totalGamesLostRebuys=0;
	
	NSArray *namesOfMonths = [ProjectFunctions namesOfAllMonths];
	NSArray *namesOfAllDayTimes = [ProjectFunctions namesOfAllDayTimes];
	NSArray *namesOfAllWeekdays = [ProjectFunctions namesOfAllWeekdays];
	NSMutableDictionary *weekDayDict = [[NSMutableDictionary alloc] init];
	NSMutableDictionary *dayTimesDict = [[NSMutableDictionary alloc] init];
	for(NSString *weekday in namesOfAllWeekdays)
		[weekDayDict setObject:@"0" forKey:weekday];
	for(NSString *daytime in namesOfAllDayTimes)
		[dayTimesDict setObject:@"0" forKey:daytime];
	
	NSString *winStreakDay=@"";
	NSString *loseStreakDay=@"";
	double profitHigh=0;
	NSString *profitHighDay=@"";
	double profitLow=0;
	NSString *profitLowDay=@"";
	for(NSManagedObject *game in games) {
		double profit = [[game valueForKey:@"winnings"] doubleValue];
		double buyInAmount = [[game valueForKey:@"buyInAmount"] doubleValue];
		double rebuyAmount = [[game valueForKey:@"rebuyAmount"] doubleValue];
		double risked = buyInAmount+rebuyAmount;
		hours += [[game valueForKey:@"hours"] floatValue];
		int minutes = [[game valueForKey:@"minutes"] intValue];
		NSString *weekday = [game valueForKey:@"weekday"];
		NSString *daytime = [game valueForKey:@"daytime"];
		
		double weekdayAmount = [[weekDayDict valueForKey:weekday] doubleValue];
		weekdayAmount+=profit;
		[weekDayDict setObject:[NSNumber numberWithDouble:weekdayAmount] forKey:weekday];
		double daytimeAmount = [[weekDayDict valueForKey:daytime] doubleValue];
		daytimeAmount+=profit;
		[dayTimesDict setObject:[NSNumber numberWithDouble:daytimeAmount] forKey:daytime];
		
		obj.games++;
		obj.profit += profit;
		totalRebuyAmount += rebuyAmount;
		obj.risked += risked;
		totalMinutes += minutes;
		if(profit>=0) {
			obj.wins++;
			totalGamesWon++;
			totalGamesWonBuyin += buyInAmount + rebuyAmount;
			totalGamesWonProfit+=profit;
			totalGamesWonRisked += risked;
			totalGamesWonRebuys += rebuyAmount;
			streak = (streak>=0)?streak+1:1;
			if (profit>0 && profit<totalGamesWonMinProfit)
				totalGamesWonMinProfit = profit;
			if (profit>totalGamesWonMaxProfit)
				totalGamesWonMaxProfit = profit;
		} else {
			obj.losses++;
			totalGamesLost++;
			totalGamesLostProfit+=profit;
			totalGamesLostBuyin += buyInAmount + rebuyAmount;
			totalGamesLostRisked += risked;
			totalGamesLostRebuys += rebuyAmount;
			streak = (streak>=0)?-1:streak-1;
			if (profit<totalGamesLostMinProfit)
				totalGamesLostMinProfit = profit;
			if (profit>totalGamesLostMaxProfit)
				totalGamesLostMaxProfit = profit;
		}
		if(streak>winStreak) {
			winStreak=streak;
			winStreakDay = [ProjectFunctions displayLocalFormatDate:[game valueForKey:@"startTime"] showDay:YES showTime:NO];
		}
		if(streak<loseStreak) {
			loseStreak=streak;
			loseStreakDay = [ProjectFunctions displayLocalFormatDate:[game valueForKey:@"startTime"] showDay:YES showTime:NO];
		}
		if(obj.profit > profitHigh) {
			profitHigh=obj.profit;
			profitHighDay = [ProjectFunctions displayLocalFormatDate:[game valueForKey:@"startTime"] showDay:YES showTime:NO];
		}
		if(obj.profit < profitLow) {
			profitLow=obj.profit;
			profitLowDay = [ProjectFunctions displayLocalFormatDate:[game valueForKey:@"startTime"] showDay:YES showTime:NO];
		}
		int i=0;
		NSString *gameMonth = [game valueForKey:@"month"];
		for (NSString *month in namesOfMonths) {
			if ([month isEqualToString:gameMonth]) {
				int quarter = i/3+1;
				if(quarter==1) {
					quarter1Profit+=profit;
					quarter1Games++;
				}
				if(quarter==2) {
					quarter2Profit+=profit;
					quarter2Games++;
				}
				if(quarter==3) {
					quarter3Profit+=profit;
					quarter3Games++;
				}
				if(quarter==4) {
					quarter4Profit+=profit;
					quarter4Games++;
				}
			}
			i++;
		}
	}
	obj.quarter1Profit = quarter1Profit;
	obj.quarter2Profit = quarter2Profit;
	obj.quarter3Profit = quarter3Profit;
	obj.quarter4Profit = quarter4Profit;
	if(streak>=0) {
		obj.streak = [NSString stringWithFormat:@"Win %d", streak];
	} else
		obj.streak = [NSString stringWithFormat:@"Lose %d", streak*-1];
	
	obj.winStreak = [NSString stringWithFormat:@"Win %d (%@)", winStreak, winStreakDay];
	obj.loseStreak = [NSString stringWithFormat:@"Lose %d (%@)", loseStreak*-1, loseStreakDay];
	
	int percent=0;
	if(obj.games>0)
		percent=obj.wins*100/obj.games;
	obj.name = [NSString stringWithFormat:@"%@: %d (%dW, %dL) %d%%", NSLocalizedString(@"Games", nil), obj.games, obj.wins, obj.losses, percent];
	hours = (float)totalMinutes/60;
	obj.hours = [NSString stringWithFormat:@"%.1f", hours];
	if(hours>0)
		obj.hourly = [NSString stringWithFormat:@"%@/hr", [ProjectFunctions convertNumberToMoneyString:obj.profit/hours]];
	obj.roi = @"-";
	if(obj.risked>0) {
		double roiAmount = obj.profit*100/obj.risked;
		obj.roi = [NSString stringWithFormat:@"%d%%", (int)round(roiAmount)];
	}
	obj.profitHigh = [NSString stringWithFormat:@"%@ %@", [ProjectFunctions convertNumberToMoneyString:profitHigh], profitHighDay];
	obj.profitLow = [NSString stringWithFormat:@"%@ %@", [ProjectFunctions convertNumberToMoneyString:profitLow], profitLowDay];
	obj.profitString = [ProjectFunctions convertNumberToMoneyString:obj.profit];
	obj.riskedString = [ProjectFunctions convertNumberToMoneyString:obj.risked];
	obj.gameCount = [NSString stringWithFormat:@"%d", obj.games];
	
	//-----------quarterly-----------
	obj.quarter1 = [NSString stringWithFormat:@"%@ (%d Games)", [ProjectFunctions convertNumberToMoneyString:quarter1Profit], quarter1Games];
	obj.quarter2 = [NSString stringWithFormat:@"%@ (%d Games)", [ProjectFunctions convertNumberToMoneyString:quarter2Profit], quarter2Games];
	obj.quarter3 = [NSString stringWithFormat:@"%@ (%d Games)", [ProjectFunctions convertNumberToMoneyString:quarter3Profit], quarter3Games];
	obj.quarter4 = [NSString stringWithFormat:@"%@ (%d Games)", [ProjectFunctions convertNumberToMoneyString:quarter4Profit], quarter4Games];
	obj.totals = [NSString stringWithFormat:@"%@ (%d Games)", [ProjectFunctions convertNumberToMoneyString:obj.profit], obj.games];
	
	//-------Games won-----
	obj.gamesWon = [NSString stringWithFormat:@"%d", totalGamesWon];
	obj.gamesWonAverageBuyin = @"-";
	obj.gamesWonAverageProfit = @"-";
	obj.gamesWonAverageRebuy = @"-";
	obj.gamesWonAverageRisked = @"-";
	if(totalGamesWon>0) {
		obj.gamesWonAverageBuyin = [NSString stringWithFormat:@"%@", [ProjectFunctions convertNumberToMoneyString:totalGamesWonBuyin/totalGamesWon]];
		obj.gamesWonAverageProfit = [NSString stringWithFormat:@"%@", [ProjectFunctions convertNumberToMoneyString:totalGamesWonProfit/totalGamesWon]];
		obj.gamesWonAverageRebuy = [NSString stringWithFormat:@"%@", [ProjectFunctions convertNumberToMoneyString:totalGamesWonRebuys/totalGamesWon]];
		obj.gamesWonAverageRisked = [NSString stringWithFormat:@"%@", [ProjectFunctions convertNumberToMoneyString:totalGamesWonRisked/totalGamesWon]];
	}
	obj.gamesWonMinProfit = [NSString stringWithFormat:@"%@", [ProjectFunctions convertNumberToMoneyString:totalGamesWonMinProfit]];
	obj.gamesWonMaxProfit = [NSString stringWithFormat:@"%@", [ProjectFunctions convertNumberToMoneyString:totalGamesWonMaxProfit]];
	
	//-------Games lost-----
	obj.gamesLost = [NSString stringWithFormat:@"%d", totalGamesLost];
	obj.gamesLostAverageBuyin = @"-";
	obj.gamesLostAverageProfit = @"-";
	obj.gamesLostAverageRebuy = @"-";
	obj.gamesLostAverageRisked = @"-";
	if(totalGamesLost>0) {
		obj.gamesLostAverageBuyin = [NSString stringWithFormat:@"%@", [ProjectFunctions convertNumberToMoneyString:totalGamesLostBuyin/totalGamesLost]];
		obj.gamesLostAverageProfit = [NSString stringWithFormat:@"%@", [ProjectFunctions convertNumberToMoneyString:totalGamesLostProfit/totalGamesLost]];
		obj.gamesLostAverageRebuy = [NSString stringWithFormat:@"%@", [ProjectFunctions convertNumberToMoneyString:totalGamesLostRebuys/totalGamesLost]];
		obj.gamesLostAverageRisked = [NSString stringWithFormat:@"%@", [ProjectFunctions convertNumberToMoneyString:totalGamesLostRisked/totalGamesLost]];
	}
	
	obj.gamesLostMaxProfit = [NSString stringWithFormat:@"%@", [ProjectFunctions convertNumberToMoneyString:totalGamesLostMaxProfit]];
	obj.gamesLostMinProfit = [NSString stringWithFormat:@"%@", [ProjectFunctions convertNumberToMoneyString:totalGamesLostMinProfit]];
	
	NSArray *sortedWeekdayArray = [self sortedArrayFromDict:weekDayDict];
	NSArray *sortedDaytimeArray = [self sortedArrayFromDict:dayTimesDict];
	obj.bestWeekday = @"-";
	obj.bestDaytime = @"-";
	obj.worstWeekday = @"-";
	obj.worstDaytime = @"-";
	if(sortedWeekdayArray.count>0) {
		NSString *best = [sortedWeekdayArray objectAtIndex:sortedWeekdayArray.count-1];
		NSString *worst = [sortedWeekdayArray objectAtIndex:0];
		NSArray *bestComps = [best componentsSeparatedByString:@"|"];
		NSArray *worstComps = [worst componentsSeparatedByString:@"|"];
		if(bestComps.count>1)
			obj.bestWeekday = [NSString stringWithFormat:@"%@ (%@)", [bestComps objectAtIndex:1], [self moneyForString:[bestComps objectAtIndex:0]]];
		if(worstComps.count>1)
			obj.worstWeekday = [NSString stringWithFormat:@"%@ (%@)", [worstComps objectAtIndex:1], [self moneyForString:[worstComps objectAtIndex:0]]];
	}
	if(sortedDaytimeArray.count>0) {
		NSString *best = [sortedDaytimeArray objectAtIndex:sortedDaytimeArray.count-1];
		NSString *worst = [sortedDaytimeArray objectAtIndex:0];
		NSArray *bestComps = [best componentsSeparatedByString:@"|"];
		NSArray *worstComps = [worst componentsSeparatedByString:@"|"];
		if(bestComps.count>1)
			obj.bestDaytime = [NSString stringWithFormat:@"%@ (%@)", [bestComps objectAtIndex:1], [ProjectFunctions convertNumberToMoneyString:[[bestComps objectAtIndex:0] doubleValue]]];
		if(worstComps.count>1)
			obj.worstDaytime = [NSString stringWithFormat:@"%@ (%@)", [worstComps objectAtIndex:1], [self moneyForString:[worstComps objectAtIndex:0]]];
	}
	
	
	return obj;
}

+(NSString *)moneyForString:(NSString *)str {
	return [ProjectFunctions convertNumberToMoneyString:[str doubleValue]];
}

+(NSArray *)sortedArrayFromDict:(NSMutableDictionary *)dict {
	NSMutableArray *weekDayTotals = [[NSMutableArray alloc] init];
	NSArray *keys = [dict allKeys];
	for(NSString *key in keys) {
		double amount = [[dict valueForKey:key] doubleValue];
		[weekDayTotals addObject:[NSString stringWithFormat:@"%09d|%@", (int)amount, key]];
	}
	return [ProjectFunctions sortArray:weekDayTotals];
}




@end
