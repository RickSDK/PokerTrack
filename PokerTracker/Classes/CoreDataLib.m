    //
//  CoreDataLib.m
//  PokerTracker
//
//  Created by Rick Medved on 10/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CoreDataLib.h"
#import "NSString+ATTString.h"
#import "NSDate+ATTDate.h"
#import "ProjectFunctions.h"
#import "PokerTrackerAppDelegate.h"

#define kLOG2 0

@implementation CoreDataLib

+(UIColor *)getFieldColor:(int)value
{
	if(value>0)
		return [UIColor colorWithRed:0 green:.5 blue:0 alpha:1];
	if(value<0)
		return [UIColor redColor];
	return [UIColor blackColor];
}


+(NSArray *)selectRowsFromTable:(NSString *)entityName mOC:(NSManagedObjectContext *)mOC
{
	NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:mOC];
	[fetch setEntity:entity];

	NSError *error;
	NSArray *items = [mOC executeFetchRequest:fetch error:&error];
	
	return items;
}


+(NSArray *)selectRowsFromEntity:(NSString *)entityName predicate:(NSPredicate *)predicate sortColumn:(NSString *)sortColumn mOC:(NSManagedObjectContext *)mOC ascendingFlg:(BOOL)ascendingFlg
{

     if(mOC==nil)
        return nil;
    
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:entityName inManagedObjectContext:mOC];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];

    if(predicate != nil)
		[request setPredicate:predicate];
    
 	if([sortColumn length]>0) {
		NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortColumn ascending:ascendingFlg];
		[request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
	}

    NSError *error=nil;
	NSArray *items = [mOC executeFetchRequest:request error:&error];
    return items;

}

+(NSArray *)selectRowsFromEntityWithLimit:(NSString *)entityName predicate:(NSPredicate *)predicate sortColumn:(NSString *)sortColumn mOC:(NSManagedObjectContext *)mOC ascendingFlg:(BOOL)ascendingFlg limit:(int)limit
{
	NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:mOC];
	[fetch setEntity:entity];
	if(limit>0)
		[fetch setFetchLimit:limit];
	
	if(predicate != nil)
		[fetch setPredicate:predicate];
	
	
	if(sortColumn != nil) {
		NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortColumn ascending:ascendingFlg];
		NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
		[fetch setSortDescriptors:sortDescriptors];
	}
	
	NSError *error;
	NSArray *items = [mOC executeFetchRequest:fetch error:&error];
	
	
	return items;
}


+(void)dumpContentsOfTable:(NSString *)entityName mOC:(NSManagedObjectContext *)mOC key:(NSString *)key
{
	NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:mOC];
	[fetch setEntity:entity];
	
	NSError *error;
	NSArray *items = [mOC executeFetchRequest:fetch error:&error];
	
	for (NSManagedObject *mo in items) {
			NSString *name = [mo valueForKey:key];
			NSLog(@"%@: %@", key, name);
	}
}

+(NSString *)getFieldValueForEntity:(NSManagedObjectContext *)mOC entityName:(NSString *)entityName field:(NSString *)field predString:(NSString *)predString indexPathRow:(int)indexPathRow
{
	NSPredicate *predicate = [NSPredicate predicateWithFormat:predString];
	NSArray *items = [CoreDataLib selectRowsFromEntity:entityName predicate:predicate sortColumn:@"startTime" mOC:mOC ascendingFlg:YES];
	if([items count]>indexPathRow) {
		NSManagedObject *mo = [items objectAtIndex:indexPathRow];
		return [mo valueForKey:field];
	}
	return @"";
}

+(NSString *)getFieldValueForEntityWithPredicate:(NSManagedObjectContext *)mOC entityName:(NSString *)entityName field:(NSString *)field predicate:(NSPredicate *)predicate indexPathRow:(int)indexPathRow
{
	NSArray *items = [CoreDataLib selectRowsFromEntity:entityName predicate:predicate sortColumn:nil mOC:mOC ascendingFlg:YES];
	if([items count]>indexPathRow) {
		NSManagedObject *mo = [items objectAtIndex:indexPathRow];
		return [mo valueForKey:field];
	}
	return @"";
}

+(int)updateStreak:(int)streak winAmount:(int)winAmount
{
	if(winAmount>=0) {
		if(streak>0)
			streak++;
		else
			streak=1;
		
	} else {
		if(streak>0)
			streak=-1;
		else
			streak--;
	}
	return streak;
}

+(int)updateWinLoss:(int)gameCount winAmount:(int)winAmount winFlag:(BOOL)winFlag
{
	if(winFlag) {
		if(winAmount>=0)
			gameCount++;
	} else {
		if(winAmount<0)
			gameCount++;
	}
	return gameCount;
}

+(NSString *)getGameString:(int)wins losses:(int)losses
{
	NSString *percent = @"-";
	int games=wins+losses;
	if(games>0)
		percent = [NSString stringWithFormat:@"%d%%", wins*100/games];
	return [NSString stringWithFormat:@"%d (%dW, %dL) %@", games, wins, losses, percent];
}

+(NSString *)getThisGameStat:(NSManagedObjectContext *)mOC dataField:(NSString *)dataField items:(NSArray *)items
{
	int winnings=0;
	int games=0;
	int streak=0;
	int longestWin=0;
	int longestLose=0;
	int hours=0;
    float hoursFloat;
	int minutes=0;
	int hourlyRate=0;
	int totalWins=0;
	int totalLosses=0;
	
	int currentYear = [[[NSDate date] convertDateToStringWithFormat:@"yyyy"] intValue];
	int lastYear = currentYear-1;
	
	int profitThisYear=0;
	int profitThisMonth=0;
	int profitLastYear=0;
	int profitLast10=0;
	
	int streakThisYear=0;
	int streakThisMonth=0;
	int streakLastYear=0;
	int streakLast10=0;
	
	int gameCountThisYear=0;
	int gameCountLastYear=0;
	int gameCountThisMonth=0;
	int gameCountLast10=0;
	
	int minutesThisYear=0;
	int minutesLastYear=0;
	int minutesThisMonth=0;
	int minutesLast10=0;
	
	int totalWinsLast10=0;
	int totalLossesLast10=0;
	int totalWinsThisYear=0;
	int totalLossesThisYear=0;
	int totalWinsLastYear=0;
	int totalLossesLastYear=0;
	int totalWinsThisMonth=0;
	int totalLossesThisMonth=0;
	
	int tokes=0;
	int foodDrinks=0;
	int amountRisked=0;
	int amountRiskedThisYear=0;
	int amountRiskedThisMonth=0;
	
	NSDate *mostRecentGame = nil;
	NSString *thisMonth = [[NSDate date] convertDateToStringWithFormat:@"yyyyMM"];
	
	int totalGames = (int)[items count];
	int minRisked=999;
	int maxRisked=0;
	int aveRisked=0;

	int minWon=999;
	int maxWon=-999;
	int aveWon=0;
    int reverseStreak=0;
    BOOL streakAlive=YES;

	for (NSManagedObject *mo in items) {
		int winAmount = [[mo valueForKey:@"winnings"] intValue];
        if(streakAlive) {
            if(winAmount>=0) {
                if(reverseStreak>=0)
                    reverseStreak++;
                else
                    streakAlive=NO;
            } else {
                if(reverseStreak<=0)
                    reverseStreak--;
                else
                    streakAlive=NO;
            }
        }
		int gameYear = [[mo valueForKey:@"year"] intValue];
		int minutesThisGame = [[mo valueForKey:@"minutes"] intValue];
		int buyInAmount = [[mo valueForKey:@"buyInAmount"] intValue];
		int rebuyAmount = [[mo valueForKey:@"rebuyAmount"] intValue];
		tokes += [[mo valueForKey:@"tokes"] intValue];
		foodDrinks += [[mo valueForKey:@"foodDrinks"] intValue];
		NSDate *gameDate = [mo valueForKey:@"startTime"];
		mostRecentGame = gameDate;
		NSString *gameMonth = [gameDate convertDateToStringWithFormat:@"yyyyMM"];
		if(minutesThisGame>0)
			minutes += minutesThisGame;
		winnings += winAmount;
		int riskAmount = (buyInAmount+rebuyAmount);
		amountRisked += riskAmount;
		games++;
		if(winAmount<minWon)
			minWon=winAmount;
		if(winAmount>maxWon)
			maxWon=winAmount;
		
		if(riskAmount<minRisked)
			minRisked=riskAmount;
		if(riskAmount>maxRisked)
			maxRisked=riskAmount;
		
		if(games>totalGames-10) {
			profitLast10+=winAmount;
			gameCountLast10++;
			minutesLast10+=minutesThisGame;
			streakLast10 = [CoreDataLib updateStreak:streakLast10 winAmount:winAmount];
			totalWinsLast10 = [CoreDataLib updateWinLoss:totalWinsLast10 winAmount:winAmount winFlag:YES];
			totalLossesLast10 = [CoreDataLib updateWinLoss:totalLossesLast10 winAmount:winAmount winFlag:NO];
		}
		if(gameYear==currentYear) {
			profitThisYear+=winAmount;
			gameCountThisYear++;
			minutesThisYear+=minutesThisGame;
			amountRiskedThisYear+=(buyInAmount+rebuyAmount);
			streakThisYear = [CoreDataLib updateStreak:streakThisYear winAmount:winAmount];
			totalWinsThisYear = [CoreDataLib updateWinLoss:totalWinsThisYear winAmount:winAmount winFlag:YES];
			totalLossesThisYear = [CoreDataLib updateWinLoss:totalLossesThisYear winAmount:winAmount winFlag:NO];
		}
		if(gameYear==lastYear) {
			profitLastYear+=winAmount;
			gameCountLastYear++;
			minutesLastYear+=minutesThisGame;
			streakLastYear = [CoreDataLib updateStreak:streakLastYear winAmount:winAmount];
			totalWinsLastYear = [CoreDataLib updateWinLoss:totalWinsLastYear winAmount:winAmount winFlag:YES];
			totalLossesLastYear = [CoreDataLib updateWinLoss:totalLossesLastYear winAmount:winAmount winFlag:NO];
		}
		if([gameMonth isEqualToString:thisMonth]) {
			profitThisMonth+=winAmount;
			gameCountThisMonth++;
			minutesThisMonth+=minutesThisGame;
			amountRiskedThisMonth+=(buyInAmount+rebuyAmount);
			streakThisMonth = [CoreDataLib updateStreak:streakThisMonth winAmount:winAmount];
			totalWinsThisMonth = [CoreDataLib updateWinLoss:totalWinsThisMonth winAmount:winAmount winFlag:YES];
			totalLossesThisMonth = [CoreDataLib updateWinLoss:totalLossesThisMonth winAmount:winAmount winFlag:NO];
		}
		
		streak = [CoreDataLib updateStreak:streak winAmount:winAmount];
		
		totalWins = [CoreDataLib updateWinLoss:totalWins winAmount:winAmount winFlag:YES];
		totalLosses = [CoreDataLib updateWinLoss:totalLosses winAmount:winAmount winFlag:NO];
		
		if(streak>longestWin)
			longestWin=streak;
		if(streak<longestLose)
			longestLose=streak;
	}
	
	if(games==0) {
		minRisked=0;
		minWon=0;
		maxWon=0;
	}
	
	hours = minutes/60;
    hoursFloat = (float)minutes/60;
	if(hoursFloat>0)
		hourlyRate = (float)winnings/hoursFloat;


	NSString *winpercent = @"";
	if(games>0)
		winpercent = [NSString stringWithFormat:@"%d%%", totalWins*100/games];
	if([dataField isEqualToString:@"money"])
		return [ProjectFunctions convertIntToMoneyString:winnings];
	
	if([dataField isEqualToString:@"winnings"])
		return [NSString stringWithFormat:@"%d", winnings];
	
	if([dataField isEqualToString:@"tokes"])
		return [NSString stringWithFormat:@"%d", tokes];
	
	if([dataField isEqualToString:@"foodDrinks"])
		return [NSString stringWithFormat:@"%d", foodDrinks];
	
	if([dataField isEqualToString:@"amountRisked"])
		return [NSString stringWithFormat:@"%d", amountRisked];

	
	if([dataField isEqualToString:@"grosssIncome"])
		return [NSString stringWithFormat:@"%d", (winnings+tokes)];
	
	if([dataField isEqualToString:@"takehomeIncome"])
		return [NSString stringWithFormat:@"%d", (winnings-foodDrinks)];
	
	if([dataField isEqualToString:@"gameCount"])
		return [NSString stringWithFormat:@"%d", games];
	
	if([dataField isEqualToString:@"totalWins"])
		return [NSString stringWithFormat:@"%d", totalWins];
	
	if([dataField isEqualToString:@"totalLosses"])
		return [NSString stringWithFormat:@"%d", totalLosses];
	
	if([dataField isEqualToString:@"games"])
		return [NSString stringWithFormat:@"%d (%dW, %dL) %@", games, totalWins, totalLosses, winpercent];
	
	if([dataField isEqualToString:@"streak"])
		return [NSString stringWithFormat:@"%d", streak];
	
	if([dataField isEqualToString:@"longestWinStreak"])
		return [NSString stringWithFormat:@"%d", longestWin];
	
	if([dataField isEqualToString:@"longestLoseStreak"])
		return [NSString stringWithFormat:@"%d", longestLose];
	
	if([dataField isEqualToString:@"hours"])
		return [NSString stringWithFormat:@"%d", hours];
	
	if([dataField isEqualToString:@"hourlyRate"])
		return [NSString stringWithFormat:@"%d", hourlyRate];
	
	if([dataField isEqualToString:@"minutes"])
		return [NSString stringWithFormat:@"%d", minutes];
	
	
	if([dataField isEqualToString:@"amountRiskedThisYear"])
		return [NSString stringWithFormat:@"%d", amountRiskedThisYear];
	if([dataField isEqualToString:@"amountRiskedThisMonth"])
		return [NSString stringWithFormat:@"%d", amountRiskedThisMonth];

	
	if([dataField isEqualToString:@"gamesThisYear"])
		return [CoreDataLib getGameString:totalWinsThisYear losses:totalLossesThisYear];
	if([dataField isEqualToString:@"gamesLastYear"])
		return [CoreDataLib getGameString:totalWinsLastYear losses:totalLossesLastYear];
	if([dataField isEqualToString:@"gamesThisMonth"])
		return [CoreDataLib getGameString:totalWinsThisMonth losses:totalLossesThisMonth];
	if([dataField isEqualToString:@"gamesLast10"])
		return [CoreDataLib getGameString:totalWinsLast10 losses:totalLossesLast10];
	
	
	
	int hoursThisYear = minutesThisYear/60;
	if([dataField isEqualToString:@"profitThisYear"])
		return [NSString stringWithFormat:@"%d", profitThisYear];
	if([dataField isEqualToString:@"profitLastYear"])
		return [NSString stringWithFormat:@"%d", profitLastYear];
	int hoursThisMonth = minutesThisMonth/60;
	if([dataField isEqualToString:@"profitThisMonth"])
		return [NSString stringWithFormat:@"%d", profitThisMonth];
	if([dataField isEqualToString:@"profitLast10"])
		return [NSString stringWithFormat:@"%d", profitLast10];
	
	if([dataField isEqualToString:@"streakThisYear"])
		return [NSString stringWithFormat:@"%d", streakThisYear];
	if([dataField isEqualToString:@"streakLastYear"])
		return [NSString stringWithFormat:@"%d", streakLastYear];
	if([dataField isEqualToString:@"streakThisMonth"])
		return [NSString stringWithFormat:@"%d", streakThisMonth];
	if([dataField isEqualToString:@"streakLast10"])
		return [NSString stringWithFormat:@"%d", streakLast10];
	
	
	if([dataField isEqualToString:@"gameCountThisYear"])
		return [NSString stringWithFormat:@"%d", gameCountThisYear];
	if([dataField isEqualToString:@"gameCountLastYear"])
		return [NSString stringWithFormat:@"%d", gameCountLastYear];
	if([dataField isEqualToString:@"gameCountThisMonth"])
		return [NSString stringWithFormat:@"%d", gameCountThisMonth];
	if([dataField isEqualToString:@"gameCountLast10"])
		return [NSString stringWithFormat:@"%d", gameCountLast10];
	
	if([dataField isEqualToString:@"hoursThisYear"])
		return [NSString stringWithFormat:@"%d", hoursThisYear];
	if([dataField isEqualToString:@"hoursLastYear"])
		return [NSString stringWithFormat:@"%d", minutesLastYear/60];
	if([dataField isEqualToString:@"hoursThisMonth"])
		return [NSString stringWithFormat:@"%d", minutesThisMonth/60];
	
	if(mostRecentGame==nil)
		mostRecentGame = [NSDate date];
	if([dataField isEqualToString:@"mostRecentDate"])
		return [NSString stringWithFormat:@"%@", [mostRecentGame convertDateToStringWithFormat:nil]];
	
	int hourlyThisMonth=0;
	if(hoursThisMonth>0)
		hourlyThisMonth = profitThisMonth/hoursThisMonth;
	if([dataField isEqualToString:@"hourlyThisMonth"])
		return [NSString stringWithFormat:@"%d", hourlyThisMonth];
	int hourlyThisYear=0;
	if(hoursThisYear>0)
		hourlyThisYear = profitThisYear/hoursThisYear;
	if([dataField isEqualToString:@"hourlyThisYear"])
		return [NSString stringWithFormat:@"%d", hourlyThisYear];
	
	int hourlyLast10=0;
	if(minutesLast10>0)
		hourlyLast10 = profitLast10*60/minutesLast10;
	if([dataField isEqualToString:@"hourlyLast10"])
		return [NSString stringWithFormat:@"%d", hourlyLast10];
	
	if([dataField isEqualToString:@"minRisked"])
		return [NSString stringWithFormat:@"%@", [ProjectFunctions convertIntToMoneyString:minRisked]];
	if([dataField isEqualToString:@"maxRisked"])
		return [NSString stringWithFormat:@"%@", [ProjectFunctions convertIntToMoneyString:maxRisked]];
	
	if(games>0)
		aveRisked = amountRisked/games;
	if([dataField isEqualToString:@"aveRisked"])
		return [NSString stringWithFormat:@"%@", [ProjectFunctions convertIntToMoneyString:aveRisked]];

	if(games>0)
		aveWon = winnings/games;
	if([dataField isEqualToString:@"aveWon"])
		return [NSString stringWithFormat:@"%@", [ProjectFunctions convertIntToMoneyString:aveWon]];
	
	int targetDev = aveRisked/2+25;
	if(games==0)
		targetDev=0;
	if([dataField isEqualToString:@"targetDev"])
		return [NSString stringWithFormat:@"%@", [ProjectFunctions convertIntToMoneyString:targetDev]];
	if([dataField isEqualToString:@"stanDev"])
		return [CoreDataLib getStandardDeviation:mOC items:items amount:aveWon targetDev:targetDev type:0];
	if([dataField isEqualToString:@"trend"])
		return [CoreDataLib getStandardDeviation:mOC items:items amount:aveWon targetDev:targetDev type:1];

	if([dataField isEqualToString:@"minWon"])
		return [NSString stringWithFormat:@"%@", [ProjectFunctions convertIntToMoneyString:minWon]];
	if([dataField isEqualToString:@"maxWon"])
		return [NSString stringWithFormat:@"%@", [ProjectFunctions convertIntToMoneyString:maxWon]];

    if([dataField isEqualToString:@"stats1"])
        return [NSString stringWithFormat:@"%d|%@|%@|%@|%@|%@|%@|%@", games,
                [ProjectFunctions convertIntToMoneyString:aveRisked], 
                [ProjectFunctions convertIntToMoneyString:minWon], 
                [ProjectFunctions convertIntToMoneyString:maxWon], 
                [ProjectFunctions convertIntToMoneyString:aveWon], 
                [CoreDataLib getStandardDeviation:mOC items:items amount:aveWon targetDev:targetDev type:0],
                [ProjectFunctions convertIntToMoneyString:targetDev], 
                [CoreDataLib getStandardDeviation:mOC items:items amount:aveWon targetDev:targetDev type:1]];
    
    if([dataField isEqualToString:@"stats2"]) {
		int percent = 0;
		if(amountRisked>0)
			percent = winnings*100/amountRisked;
		NSLog(@"+++hoursFloat%f", hoursFloat);
        return [NSString stringWithFormat:@"%d|%d|%@|%d|%d|%d|%@|%d|%d", winnings, amountRisked, [NSString stringWithFormat:@"%d (%dW, %dL) %@", games, totalWins, totalLosses, winpercent], streak, longestWin, longestLose, [NSString stringWithFormat:@"%.1f", hoursFloat], hourlyRate, percent];
    }
    
    if([dataField isEqualToString:@"chart1"])
        return [NSString stringWithFormat:@"%d|%d|%d", winnings, games, minutes]; 
    
    if([dataField isEqualToString:@"analysis1"])
        return [NSString stringWithFormat:@"%d|%d|%d|%d|%d|%d|%d|%@|%@|%@|%@", amountRisked, foodDrinks, tokes, (winnings+tokes), 
                (winnings-foodDrinks), winnings, hourlyRate, 
                [NSString stringWithFormat:@"%d (%dW, %dL) %@", games, totalWins, totalLosses, winpercent],
                [ProjectFunctions convertIntToMoneyString:aveRisked],
                [ProjectFunctions convertIntToMoneyString:aveWon], 
                [CoreDataLib getStandardDeviation:mOC items:items amount:aveWon targetDev:targetDev type:0]
                ]; 
   
	int percent = 0;
	if(winnings>0)
		percent = tokes*100/winnings;
    
    if([dataField isEqualToString:@"tokeString"])
        return [NSString stringWithFormat:@"%d|Dealer Tips|%d", tokes, percent];

    int rating=100;
    if(amountRisked>0)
        rating = (winnings+amountRisked)*100/amountRisked;
    
    if([dataField isEqualToString:@"totalStats"])
        return [NSString stringWithFormat:@"%@|%d|%d|%d|%d|%d|%d", 
                [NSString stringWithFormat:@"%d (%dW, %dL) %@", games, totalWins, totalLosses, winpercent], 
                games, amountRisked, winnings, streak, rating, minutes];

    if([dataField isEqualToString:@"totalStatsL10"])
        return [NSString stringWithFormat:@"%@|%d|%d|%d|%d|%d|%d", 
                [NSString stringWithFormat:@"%d (%dW, %dL) %@", games, totalWins, totalLosses, winpercent], 
                games, amountRisked, winnings, reverseStreak, rating, minutes];

    
	return @"none-found";
}

+(NSString *)getStandardDeviation:(NSManagedObjectContext *)mOC items:(NSArray *)items amount:(int)amount targetDev:(int)targetDev type:(int)type
{
	int games=0;
	int SDRisked=0;
	int standardDeviation=0;
	NSString *trend=@"Need more data";
	int count=(int)[items count];
	int earlyTrend=0;
	int lateTrend=0;
	
	for (NSManagedObject *mo in items) {
		int winAmount = [[mo valueForKey:@"winnings"] intValue];
		games++;
		int riskDeviation = winAmount-amount;
		if(riskDeviation<0)
			riskDeviation*=-1;
		SDRisked += riskDeviation;
		
		if(count>5) {
			if(games==count-3 || games==count-4 || games==count-5)
				earlyTrend += riskDeviation;
			if(games==count || games==count-1 || games==count-2)
				lateTrend += riskDeviation;
		}
	}
	if(games>0)
		standardDeviation=SDRisked/games;

	if(type==0) {
		NSString *devAmount = [ProjectFunctions convertIntToMoneyString:standardDeviation];
		NSString *tag = @"Good";
		int percent=0;
		if(targetDev>0)
			percent = standardDeviation*100/targetDev;
		if(percent < 75)
			tag = @"Passive";
		if(percent > 150)
			tag = @"Aggressive";
		return [NSString stringWithFormat:@"%@ (%@)", devAmount, tag];
	}
	
	if(count>5) {
		int percent=0;
		int trendDeviation = earlyTrend-lateTrend;
		if(trendDeviation<0)
			trendDeviation*=-1;
		if(earlyTrend+lateTrend>0)
			percent = trendDeviation*100/earlyTrend+lateTrend;
		trend = @"even";
		if(earlyTrend<lateTrend && percent>5)
			trend = @"slightly widening";
		if(earlyTrend>lateTrend && percent>5)
			trend = @"slightly narrowing";
		if(earlyTrend<lateTrend && percent>50)
			trend = @"widening";
		if(earlyTrend>lateTrend && percent>50)
			trend = @"narrowing";
	}
	if(type==1)
		return trend;
	
	return @"";
}

+(NSString *)getGameStat:(NSManagedObjectContext *)mOC dataField:(NSString *)dataField predicate:(NSPredicate *)predicate
{
	if(predicate==nil)
		predicate = [NSPredicate predicateWithFormat:@"user_id = %d", 0];
	
	NSArray *items = [CoreDataLib selectRowsFromEntity:@"GAME" predicate:predicate sortColumn:@"startTime" mOC:mOC ascendingFlg:YES];
	
	return [CoreDataLib getThisGameStat:mOC dataField:dataField items:items];
}


+(NSString *)getGameStatWithLimit:(NSManagedObjectContext *)mOC dataField:(NSString *)dataField predicate:(NSPredicate *)predicate limit:(int)limit
{
	if(predicate==nil)
		predicate = [NSPredicate predicateWithFormat:@"user_id = %d", 0];
	
	NSArray *items = [CoreDataLib selectRowsFromEntityWithLimit:@"GAME" predicate:predicate sortColumn:@"startTime" mOC:mOC ascendingFlg:NO limit:limit];
	
	return [CoreDataLib getThisGameStat:mOC dataField:dataField items:items];
}



+(BOOL) insertAttributeManagedObject:(NSString *)entityName valueList:(NSArray *)valueList mOC:(NSManagedObjectContext *)mOC
{
	NSManagedObject *mo = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:mOC];
	NSMutableArray *keyList = [[NSMutableArray alloc] init];
	NSMutableArray *typeList = [[NSMutableArray alloc] init];
	
	for(int i=0; i<valueList.count; i++) {
		[keyList addObject:@"name"];
		[typeList addObject:@"text"];
	}
	return [CoreDataLib updateManagedObject:mo keyList:keyList valueList:valueList typeList:typeList mOC:mOC];
}

+(BOOL) insertManagedObject:(NSString *)entityName keyList:(NSArray *)keyList valueList:(NSArray *)valueList typeList:(NSArray *)typeList mOC:(NSManagedObjectContext *)mOC
{
	NSManagedObject *mo = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:mOC];
	return [CoreDataLib updateManagedObject:mo keyList:keyList valueList:valueList typeList:typeList mOC:mOC];
}

+(BOOL)insertOrUpdateManagedObjectForEntity:(NSString *)entityName valueList:(NSArray *)valueList mOC:(NSManagedObjectContext *)mOC predicate:(NSPredicate *)predicate
{
	NSArray *items = [CoreDataLib selectRowsFromEntity:entityName predicate:predicate sortColumn:nil mOC:mOC ascendingFlg:YES];
	NSManagedObject *mo=nil;
	if([items count]>0)
		mo = [items objectAtIndex:0];
	else
		mo = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:mOC];
	NSLog(@"updating... %d", (int)[items count]);
	return [CoreDataLib updateManagedObjectForEntity:mo entityName:entityName valueList:valueList mOC:mOC];
}

+(NSManagedObject *)insertManagedObjectForEntity:(NSString *)entityName valueList:(NSArray *)valueList mOC:(NSManagedObjectContext *)mOC
{
	NSManagedObject *mo = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:mOC];
	[CoreDataLib updateManagedObjectForEntity:mo entityName:entityName valueList:valueList mOC:mOC];
	return mo;
}

+(BOOL)updateManagedObjectForEntity:(NSManagedObject *)mo entityName:(NSString *)entityName valueList:(NSArray *)valueList mOC:(NSManagedObjectContext *)mOC
{
	NSArray *keyList = [ProjectFunctions getColumnListForEntity:entityName type:@"column"];
	NSArray *typeList = [ProjectFunctions getColumnListForEntity:entityName type:@"type"];
	return [CoreDataLib updateManagedObject:mo keyList:keyList valueList:valueList typeList:typeList mOC:mOC];
}


+(BOOL) updateManagedObject:(NSManagedObject *)newManagedObject keyList:(NSArray *)keyList valueList:(NSArray *)valueList typeList:(NSArray *)typeList mOC:(NSManagedObjectContext *)mOC
{
	if([keyList count] != [valueList count] || [keyList count] != [typeList count]) {
		NSLog(@"WARNING!! Unmatching number of columns in newManagedObject: v=%d k=%d t=%d", (int)[valueList count], (int)[keyList count], (int)[typeList count]);
	}
	int i=0;
	for(NSString *key in keyList) {
//		NSLog(@"+++key: %@", key);
		if(i<[valueList count] && i<[typeList count]) {
			NSString *type = [typeList objectAtIndex:i];
			NSString *value = [valueList objectAtIndex:i];
			
			if(kLOG2)
				NSLog(@"%@ (%@) = '%@'", key, type, value);

			if([@"notes" isEqualToString:key] && value.length>100) {
				value = [NSString stringWithFormat:@"%@...", [value substringToIndex:100]];
			}
			if([type isEqualToString:@"text"])
				[newManagedObject setValue:value forKey:key];
			if([type isEqualToString:@"date"] || [type isEqualToString:@"time"]) {
				NSDate *inputDate = [value convertStringToDateFinalSolution];
                if(inputDate==nil)
                    inputDate = [NSDate date];
                
				[newManagedObject setValue:inputDate forKey:key];
            }
			if([type isEqualToString:@"shortDate"]) {
				NSDate *inputDate = [value convertStringToDateWithFormat:@"yyyy-MM-dd"];
				if(inputDate==nil)
					inputDate = [NSDate date];
				[newManagedObject setValue:inputDate forKey:key];
			}
			if([type isEqualToString:@"int"])
				[newManagedObject setValue:[NSNumber numberWithInt:[value intValue]] forKey:key];
			if([type isEqualToString:@"float"])
				[newManagedObject setValue:[NSNumber numberWithFloat:[value floatValue]] forKey:key];
			if([type isEqualToString:@"key"])
				[newManagedObject setValue:value forKey:key];
			i++;
		} else {
			NSLog(@"key: '%@' not populated", key);
		}

	}
	
    NSError *error = nil;
    if (![mOC save:&error]) {
		NSLog(@"Error: unable to save to coredata! %@", error.localizedDescription);
		NSLog(@"%@", valueList);
		return FALSE;
	}
	return TRUE;
	
}

+(NSArray *)getEntityNameList:(NSString *)entityName mOC:(NSManagedObjectContext *)mOC
{
	NSMutableArray *finalList = [[NSMutableArray alloc] init];
	NSArray *items = [CoreDataLib selectRowsFromEntity:entityName predicate:nil sortColumn:@"name" mOC:mOC ascendingFlg:YES];
	for (NSManagedObject *mo in items) {
		NSString *name = [mo valueForKey:@"name"];
		[finalList addObject:name];
	}
	return finalList;
}

+(NSArray *)getFieldList:(NSString *)name mOC:(NSManagedObjectContext *)mOC addAllTypesFlg:(BOOL)addAllTypesFlg
{
	NSMutableArray *finalList = [[NSMutableArray alloc] init];
	NSArray *list;
	if([name isEqualToString:@"Game"])
		list = [CoreDataLib getEntityNameList:@"GAMETYPE" mOC:mOC];
	else if([name isEqualToString:@"Game Type"])
		list = [NSArray arrayWithObjects:@"Cash", @"Tournament", nil];
	else if([name isEqualToString:@"Bankroll"])
		list = [CoreDataLib getEntityNameList:@"BANKROLL" mOC:mOC];
	else if([name isEqualToString:@"Location"])
		list = [CoreDataLib getEntityNameList:@"LOCATION" mOC:mOC];
	else if([name isEqualToString:@"Limit"])
		list = [CoreDataLib getEntityNameList:@"LIMIT" mOC:mOC];
	else if([name isEqualToString:@"Stakes"])
		list = [CoreDataLib getEntityNameList:@"STAKES" mOC:mOC];
	else if([name isEqualToString:@"Tournament Type"])
		list = [CoreDataLib getEntityNameList:@"TOURNAMENT" mOC:mOC];
	else
		list = [NSArray arrayWithObjects:name, nil];
	
	NSString *displayName = name;
	if([name isEqualToString:@"Stakes"])
		displayName = @"Stake";
	
	if(addAllTypesFlg) {
		[finalList addObject:[NSString stringWithFormat:@"All %@s", displayName]];
		if(![name isEqualToString:@"Game Type"])
			[finalList addObject:@"*Custom*"];
	}

	for(NSString *value in list)
		[finalList addObject:value];
	
	return finalList;
}

+(int)calculateActiveYearsPlaying:(NSManagedObjectContext *)mOC
{
	int thisYear = [[[NSDate date] convertDateToStringWithFormat:@"yyyy"] intValue];
	int minYear = thisYear;
	NSArray *items = [CoreDataLib selectRowsFromTable:@"GAME" mOC:mOC];
	for (NSManagedObject *mo in items) {
		//		NSDate *startDate = [mo valueForKey:@"startTime"];
		int year = [[mo valueForKey:@"year"] intValue];
		if(year<minYear)
			minYear=year;
	}
	
	return thisYear-minYear+1;
}

+(NSManagedObjectContext *)getLocalContext
{
	NSManagedObjectContext *contextLocal = [[NSManagedObjectContext alloc] init];
	[contextLocal setUndoManager:nil];
	
	PokerTrackerAppDelegate *appDelegate = (PokerTrackerAppDelegate *)[[UIApplication sharedApplication] delegate];
	[contextLocal setPersistentStoreCoordinator:appDelegate.persistentStoreCoordinator];
	return contextLocal;
}






@end
