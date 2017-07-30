//
//  GameStatObj.m
//  PokerTracker
//
//  Created by Rick Medved on 7/19/17.
//
//

#import "GameStatObj.h"
#import "ProjectFunctions.h"
#import "PlayerObj.h"

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
	NSString *largestWinGame = @"-";
	NSString *smallestWinGame = @"-";
	NSString *largestLossGame = @"-";
	NSString *smallestLossGame = @"-";
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
	
	NSString *winStreakDay=@"-";
	NSString *loseStreakDay=@"-";
	double profitHigh=0;
	NSString *profitHighDay=@"";
	double profitLow=0;
	NSString *profitLowDay=@"";
	obj.foodDrinks = 0;
	obj.cashoutAmount = 0;
	obj.tokes = 0;
	int streakReverse=0;
	PlayerObj *hudPlayerObj = [[PlayerObj alloc] init];
	BOOL streakAlive=YES;
	for(NSManagedObject *game in games) {
		double profit = [[game valueForKey:@"winnings"] doubleValue];
		double buyInAmount = [[game valueForKey:@"buyInAmount"] doubleValue];
		double rebuyAmount = [[game valueForKey:@"rebuyAmount"] doubleValue];
		double risked = buyInAmount+rebuyAmount;
		hours += [[game valueForKey:@"hours"] floatValue];
		int minutes = [[game valueForKey:@"minutes"] intValue];
		obj.foodDrinks += [[game valueForKey:@"foodDrinks"] intValue];
		obj.cashoutAmount += [[game valueForKey:@"cashoutAmount"] intValue];
		obj.tokes += [[game valueForKey:@"tokes"] intValue];
		NSString *weekday = [game valueForKey:@"weekday"];
		NSString *daytime = [game valueForKey:@"daytime"];
		NSString *hudString = [game valueForKey:@"attrib01"];
		NSString *displayDay = [ProjectFunctions displayLocalFormatDate:[game valueForKey:@"startTime"] showDay:YES showTime:NO];
		
		double weekdayAmount = [[weekDayDict valueForKey:weekday] doubleValue];
		weekdayAmount+=profit;
		[weekDayDict setObject:[NSNumber numberWithDouble:weekdayAmount] forKey:weekday];
		double daytimeAmount = [[weekDayDict valueForKey:daytime] doubleValue];
		daytimeAmount+=profit;
		[dayTimesDict setObject:[NSNumber numberWithDouble:daytimeAmount] forKey:daytime];

		if(hudString && hudString.length>0) {
			NSArray *components = [hudString componentsSeparatedByString:@":"];
			if(components.count>6) {
				obj.hudGames++;
				hudPlayerObj.foldCount += [[components objectAtIndex:0] intValue];
				hudPlayerObj.checkCount += [[components objectAtIndex:1] intValue];
				hudPlayerObj.callCount += [[components objectAtIndex:2] intValue];
				hudPlayerObj.raiseCount += [[components objectAtIndex:3] intValue];
				hudPlayerObj.picId += [[components objectAtIndex:4] intValue];
				hudPlayerObj.looseNum += [[components objectAtIndex:5] intValue];
				hudPlayerObj.agressiveNum += [[components objectAtIndex:6] intValue];
			}
		}
		obj.games++;
		obj.profit += profit;
		totalRebuyAmount += rebuyAmount;
		obj.risked += risked;
		totalMinutes += minutes;
		if(profit>=0) {
			obj.wins++;
			totalGamesWon++;
			if(streakAlive) {
				if(streakReverse>=0)
					streakReverse++;
				else
					streakAlive=NO;
			}
			totalGamesWonBuyin += buyInAmount + rebuyAmount;
			totalGamesWonProfit+=profit;
			totalGamesWonRisked += risked;
			totalGamesWonRebuys += rebuyAmount;
			streak = (streak>=0)?streak+1:1;
			if (profit>0 && profit<totalGamesWonMinProfit) {
				totalGamesWonMinProfit = profit;
				smallestWinGame = displayDay;
			}
			if (profit>totalGamesWonMaxProfit) {
				totalGamesWonMaxProfit = profit;
				largestWinGame = displayDay;
			}
		} else {
			obj.losses++;
			if(streakAlive) {
				if(streakReverse<=0)
					streakReverse--;
				else
					streakAlive=NO;
			}
			totalGamesLost++;
			totalGamesLostProfit+=profit;
			totalGamesLostBuyin += buyInAmount + rebuyAmount;
			totalGamesLostRisked += risked;
			totalGamesLostRebuys += rebuyAmount;
			streak = (streak>=0)?-1:streak-1;
			if (profit<totalGamesLostMinProfit) {
				totalGamesLostMinProfit = profit;
				largestLossGame = displayDay;
			}
			if (profit>totalGamesLostMaxProfit) {
				totalGamesLostMaxProfit = profit;
				smallestLossGame = displayDay;
			}
		}
		if(streak>winStreak) {
			winStreak=streak;
			winStreakDay = displayDay;
		}
		if(streak<loseStreak) {
			loseStreak=streak;
			loseStreakDay = displayDay;
		}
		if(obj.profit > profitHigh) {
			profitHigh=obj.profit;
			profitHighDay = [NSString stringWithFormat:@"(%@)", displayDay];
		}
		if(obj.profit < profitLow) {
			profitLow=obj.profit;
			profitLowDay = [NSString stringWithFormat:@"(%@)", displayDay];
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
	obj.hudGamesStr=@"-";
	if(obj.hudGames>0) {
		obj.hudPlayerType = [ProjectFunctions playerTypeFromLlooseNum:hudPlayerObj.looseNum/obj.hudGames agressiveNum:hudPlayerObj.agressiveNum/obj.hudGames];
		int vpip = [PlayerObj vpipForPlayer:hudPlayerObj];
		int pfr = [PlayerObj pfrForPlayer:hudPlayerObj];
		NSString *af = [PlayerObj afForPlayer:hudPlayerObj];
		obj.hudVpvp_Pfr = [NSString stringWithFormat:@"%d / %d (%@)", vpip, pfr, af];
		NSArray *types = [NSArray arrayWithObjects:@"Donkey", @"Fish", @"Rounder", @"Grinder", @"Shark", @"Pro", nil];
		int playType = hudPlayerObj.picId/obj.hudGames;
		NSString *hudSkillLevel = @"Grinder";
		if(playType<types.count)
			hudSkillLevel = [types objectAtIndex:playType];
		obj.hudSkillLevel = hudSkillLevel;
		obj.hudGamesStr = [NSString stringWithFormat:@"%d (%d hands)", obj.hudGames, hudPlayerObj.foldCount+hudPlayerObj.checkCount+hudPlayerObj.callCount+hudPlayerObj.raiseCount];
	}

	obj.quarter1Profit = quarter1Profit;
	obj.quarter2Profit = quarter2Profit;
	obj.quarter3Profit = quarter3Profit;
	obj.quarter4Profit = quarter4Profit;
	if(streak>=0) {
		obj.streak = [NSString stringWithFormat:@"Win %d", streak];
	} else
		obj.streak = [NSString stringWithFormat:@"Lose %d", streak*-1];
	if(streakReverse>=0) {
		obj.streakReverse = [NSString stringWithFormat:@"Win %d", streakReverse];
	} else
		obj.streakReverse = [NSString stringWithFormat:@"Lose %d", streakReverse*-1];
	
	obj.winStreak = @"-";
	if(winStreak>0)
		obj.winStreak = [NSString stringWithFormat:@"Win %d (%@)", winStreak, winStreakDay];
	obj.loseStreak = @"-";
	if(loseStreak<0)
		obj.loseStreak = [NSString stringWithFormat:@"Lose %d (%@)", loseStreak*-1, loseStreakDay];
	
	int percent=0;
	if(obj.games>0)
		percent=obj.wins*100/obj.games;
	obj.name = [NSString stringWithFormat:@"%@: %d (%dW, %dL) %d%%", NSLocalizedString(@"Games", nil), obj.games, obj.wins, obj.losses, percent];
	obj.shortName = [NSString stringWithFormat:@"%d (%dW, %dL) %d%%", obj.games, obj.wins, obj.losses, percent];
	hours = (float)totalMinutes/60;
	obj.hours = [NSString stringWithFormat:@"%.1f", hours];
	obj.hourly = @"-";
	if(hours>0)
		obj.hourly = [NSString stringWithFormat:@"%@/hr", [ProjectFunctions convertNumberToMoneyString:obj.profit/hours]];
	obj.roi = @"-";
	if(obj.risked>0) {
		double roiAmount = obj.profit*100/obj.risked;
		obj.roi = [NSString stringWithFormat:@"%d%%", (int)round(roiAmount)];
	}
	obj.grossIncome = obj.profit+obj.foodDrinks+obj.tokes;
	obj.takehomeAmount = obj.profit+obj.foodDrinks;
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
	if(totalGamesWonMinProfit==99999)
		totalGamesWonMinProfit=0;
	obj.gamesWonMinProfit = [NSString stringWithFormat:@"%@ (%@)", [ProjectFunctions convertNumberToMoneyString:totalGamesWonMinProfit], smallestWinGame];
	obj.gamesWonMaxProfit = [NSString stringWithFormat:@"%@ (%@)", [ProjectFunctions convertNumberToMoneyString:totalGamesWonMaxProfit], largestWinGame];
	
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
	if(totalGamesLostMaxProfit==-99999)
		totalGamesLostMaxProfit=0;
	obj.gamesLostMaxProfit = [NSString stringWithFormat:@"%@ (%@)", [ProjectFunctions convertNumberToMoneyString:totalGamesLostMaxProfit], smallestLossGame];
	obj.gamesLostMinProfit = [NSString stringWithFormat:@"%@ (%@)", [ProjectFunctions convertNumberToMoneyString:totalGamesLostMinProfit], largestLossGame];
	
	NSArray *sortedWeekdayArray = [self sortedArrayFromDict:weekDayDict];
	NSArray *sortedDaytimeArray = [self sortedArrayFromDict:dayTimesDict];
	obj.bestWeekday = @"-";
	obj.bestDaytime = @"-";
	obj.worstWeekday = @"-";
	obj.worstDaytime = @"-";
	if(sortedWeekdayArray.count>0 && obj.games>0) {
		NSString *best = [sortedWeekdayArray objectAtIndex:sortedWeekdayArray.count-1];
		NSString *worst = [sortedWeekdayArray objectAtIndex:0];
		NSArray *bestComps = [best componentsSeparatedByString:@"|"];
		NSArray *worstComps = [worst componentsSeparatedByString:@"|"];
		if (bestComps.count>1) {
			obj.bestDayAmount = [[bestComps objectAtIndex:0] floatValue]-100000;
			obj.worstDayAmount = [[worstComps objectAtIndex:0] floatValue]-100000;
			if(obj.wins>0)
				obj.bestWeekday = [NSString stringWithFormat:@"%@s (%@ total)", [bestComps objectAtIndex:1], [self moneyForString:[bestComps objectAtIndex:0]]];
			if(obj.losses>0)
				obj.worstWeekday = [NSString stringWithFormat:@"%@s (%@ total)", [worstComps objectAtIndex:1], [self moneyForString:[worstComps objectAtIndex:0]]];
		}
	}
	if(sortedDaytimeArray.count>0) {
		NSString *best = [sortedDaytimeArray objectAtIndex:sortedDaytimeArray.count-1];
		NSString *worst = [sortedDaytimeArray objectAtIndex:0];
		NSArray *bestComps = [best componentsSeparatedByString:@"|"];
		NSArray *worstComps = [worst componentsSeparatedByString:@"|"];
		if (bestComps.count>1 && worstComps.count>1) {
			obj.bestTimeAmount = [[bestComps objectAtIndex:0] floatValue]-100000;
			obj.worstTimeAmount = [[worstComps objectAtIndex:0] floatValue]-100000;
			if(obj.wins>0)
				obj.bestDaytime = [NSString stringWithFormat:@"%@s (%@ total)", [bestComps objectAtIndex:1], [self moneyForString:[bestComps objectAtIndex:0]]];
			if(obj.losses>0)
				obj.worstDaytime = [NSString stringWithFormat:@"%@s (%@ total)", [worstComps objectAtIndex:1], [self moneyForString:[worstComps objectAtIndex:0]]];
		}
	}
	
	return obj;
}

+(NSString *)moneyForString:(NSString *)str {
	double amount = [str doubleValue]-100000;
	return [ProjectFunctions convertNumberToMoneyString:amount];
}

+(NSArray *)sortedArrayFromDict:(NSMutableDictionary *)dict {
	NSMutableArray *weekDayTotals = [[NSMutableArray alloc] init];
	NSArray *keys = [dict allKeys];
	for(NSString *key in keys) {
		double amount = [[dict valueForKey:key] doubleValue];
		amount += 100000;
		[weekDayTotals addObject:[NSString stringWithFormat:@"%09d|%@", (int)amount, key]];
	}
	return [ProjectFunctions sortArray:weekDayTotals];
}




@end
