    //
//  ProjectFunctions.m
//  PokerTracker
//
//  Created by Rick Medved on 10/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ProjectFunctions.h"
#import "CoreDataLib.h"
#import "NSDate+ATTDate.h"
#import "NSString+ATTString.h"
#import "QuadFieldTableViewCell.h"
#import "QuadWithImageTableViewCell.h"
#import "WebServicesFunctions.h"
#import "NSArray+ATTArray.h"
#import "NSString+ATTString.h"
#import "NSData+ATTData.h"
#import "GameCell.h"
#import "ChipStackObj.h"


// attrib03 <--- tournament num players
// attrib04 <--- tournament place finished
// FRIEND attrib_07 <--- player pics
// FRIEND attrib_08 <--- game in progress
// FRIEND attrib_09 <--- time in progress
// FRIEND attrib_10 <--- attribs in progress

@implementation ProjectFunctions

+(int)getProductionMode
{
	return kPRODMode;
}

+(NSString *)getProjectVersion
{
	return @"Version 1.0";
}

+(NSString *)getProjectDisplayVersion
{
	NSDictionary *infoDictionary = [[NSBundle mainBundle]infoDictionary];
	
	NSString *version = infoDictionary[@"CFBundleShortVersionString"];
//	NSString *build = infoDictionary[(NSString*)kCFBundleVersionKey];
	
	UIDevice *device = [UIDevice currentDevice];
//    NSString *systemName = [device systemName];
//    NSString *systemVersion = [device systemVersion];
    NSString *model = [device model];
    
//    NSString *softwareVersion = (__bridge NSString *)CFBundleGetValueForInfoDictionaryKey(CFBundleGetMainBundle(), kCFBundleVersionKey); // added RM
	
    NSString *lite = ([self isLiteVersion])?@"L":@"";
    
    return [NSString stringWithFormat:@"Version %@%@ (%@)", version, lite, model];
}

+(BOOL)isLiteVersion
{
	if([ProjectFunctions getUserDefaultValue:@"proVersion101"].length>0)
		return NO;

    return YES;
}

+(NSString *)getAppID
{
	if([ProjectFunctions isLiteVersion])
		return @"488925221";
	else
		return @"475160109";
}

+(void)writeAppReview
{
	NSString *appId = [ProjectFunctions getAppID];
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://itunes.apple.com/us/app/apple-store/id%@?mt=8", appId]]];
}

+(BOOL)useThreads
{
    NSString *flag = [ProjectFunctions getUserDefaultValue:@"bgThreads"];
    if([flag length]==0)
        return YES;
    else
        return NO;
}


+(NSArray *)getFieldListForVersion:(NSString *)version type:(NSString *)type
{
	if([type isEqualToString:@"FRIEND"]) {
		if([version isEqualToString:@"Version 1.0"]) {
			return [NSArray arrayWithObjects:@"mostRecentDate", 
					@"gamesThisYear", @"gamesLastYear", @"gamesThisMonth", @"gamesLast10", 
					@"streakThisYear", @"streakLastYear", @"streakThisMonth", @"streakLast10", 
					@"gameCountThisYear", @"gameCountLastYear", @"gameCountThisMonth", @"gameCountLast10", 
					@"profitThisYear", @"profitLastYear", @"profitThisMonth", @"profitLast10", 
					@"hoursThisYear", @"hoursLastYear", @"hoursThisMonth", 
					@"hourlyThisYear", @"hourlyThisMonth", @"hourlyLast10",
					@"attrib_01", @"attrib_02", @"attrib_03", @"attrib_04", @"attrib_05", @"attrib_06", 
					@"attrib_07", @"attrib_08", @"attrib_09", @"attrib_10", @"attrib_11", @"attrib_12", 
				nil];
		}
	}
	return nil;
}



+(NSArray *)sortArray:(NSMutableArray *)list
{
	[list sortUsingSelector:@selector(compare:)];
	return list;
}

+(NSArray *)sortArrayDescending:(NSArray *)list
{
	return [list sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:nil ascending:NO]]];
}

+(NSString *)getWinLossStreakString:(int)streak
{
	if(streak==0)
		return @"-";
	return (streak>0)?[NSString stringWithFormat:@"Win %d", streak]:[NSString stringWithFormat:@"Lose %d", (streak*-1)];
}

+ (NSString *)escapeQuotes:(NSString *)string 
{
	return [string stringByReplacingOccurrencesOfString:@"'" withString:@"\\'"];
}

+(NSDate *)getFirstDayOfMonth:(NSDate *)thisDay
{
	NSString *currentMonth = [thisDay convertDateToStringWithFormat:@"MM"];
	NSString *currentYear = [thisDay convertDateToStringWithFormat:@"yyyy"];
	NSString *Day1 = [NSString stringWithFormat:@"%@/01/%@", currentMonth, currentYear];
	
	return [Day1 convertStringToDateWithFormat:@"MM/dd/yyyy"];
}

+(void)displayTimeFrameLabel:(UILabel *)label mOC:(NSManagedObjectContext *)mOC buttonNum:(int)buttonNum timeFrame:(NSString *)timeFrame {
	
	if([timeFrame isEqualToString:@"LifeTime"] || [timeFrame intValue]>0) {
		label.text=timeFrame;
		return;
	}
	
	NSDate *startTime = [NSDate date];
	NSDate *endTime = [NSDate date];
	
	if([timeFrame isEqualToString:@"*Custom*"]) {
		NSPredicate *pred = [NSPredicate predicateWithFormat:@"type = %@ AND searchNum = %d", @"Timeframe", buttonNum];
		NSArray *items = [CoreDataLib selectRowsFromEntity:@"SEARCH" predicate:pred sortColumn:nil mOC:mOC ascendingFlg:YES];
		if([items count]>0) {
			NSManagedObject *mo = [items objectAtIndex:0];
			startTime = [mo valueForKey:@"startTime"];
			endTime = [mo valueForKey:@"endTime"];
		}
	}
	
	
	if([timeFrame isEqualToString:@"Last 7 Days"])
		startTime = [[NSDate date] dateByAddingTimeInterval:-1*60*60*24*7];
	
	if([timeFrame isEqualToString:@"Last 30 Days"])
		startTime = [[NSDate date] dateByAddingTimeInterval:-1*60*60*24*30];
	
	if([timeFrame isEqualToString:@"Last 90 Days"])
		startTime = [[NSDate date] dateByAddingTimeInterval:-1*60*60*24*90];
	
	if([timeFrame isEqualToString:@"This Month"])
		startTime = [ProjectFunctions getFirstDayOfMonth:[NSDate date]];
	
	if([timeFrame isEqualToString:@"Last Month"]) {
		NSDate *day1 = [ProjectFunctions getFirstDayOfMonth:[NSDate date]];
		NSDate *lastMonth = [day1 dateByAddingTimeInterval:-1*60*60*24];
		startTime = [ProjectFunctions getFirstDayOfMonth:lastMonth];
		endTime = day1;
	}
	
	label.text = [NSString stringWithFormat:@"%@ to %@", [startTime convertDateToStringWithFormat:nil], [endTime convertDateToStringWithFormat:nil]];
	
}

+(NSPredicate *)getPredicateForFilter:(NSArray *)formDataArray mOC:(NSManagedObjectContext *)mOC buttonNum:(int)buttonNum
{
	int row_id = 0;
	NSPredicate *pred = [NSPredicate predicateWithFormat:@"button = %d", buttonNum];
	NSArray *items = [CoreDataLib selectRowsFromEntity:@"FILTER" predicate:pred sortColumn:nil mOC:mOC ascendingFlg:YES];
	if(items.count>0) {
		NSManagedObject *mo = [items objectAtIndex:0];
		row_id = [[mo valueForKey:@"row_id"] intValue];
	}
	NSLog(@"getPredicateForFilter buttonNum: %d, row_id: %d", buttonNum, row_id);
	
	NSString *predicateString = [ProjectFunctions getPredicateString:formDataArray mOC:mOC buttonNum:buttonNum];
	NSString *timeFrame = [formDataArray stringAtIndex:0];
	
	if([timeFrame isEqualToString:@"LifeTime"] || [timeFrame intValue]>0)
		return [NSPredicate predicateWithFormat:predicateString];
	
	NSDate *startTime = [NSDate date];
	NSDate *endTime = [NSDate date];
	
	NSLog(@"+++filter timeFrame: %@ (%d)", timeFrame, buttonNum);
	if([timeFrame isEqualToString:@"*Custom*"]) {
		NSPredicate *pred = [NSPredicate predicateWithFormat:@"type = %@ AND searchNum = %d", @"Timeframe", row_id];
		NSArray *items = [CoreDataLib selectRowsFromEntity:@"SEARCH" predicate:pred sortColumn:nil mOC:mOC ascendingFlg:YES];
		NSLog(@"+++count (%d)", (int)items.count);
		if([items count]>0) {
			NSManagedObject *mo = [items objectAtIndex:0];
			startTime = [mo valueForKey:@"startTime"];
			endTime = [mo valueForKey:@"endTime"];
		}
	}
	
	
	if([[formDataArray stringAtIndex:0] isEqualToString:@"Last 7 Days"])
		startTime = [[NSDate date] dateByAddingTimeInterval:-1*60*60*24*7];
	
	if([[formDataArray stringAtIndex:0] isEqualToString:@"Last 30 Days"])
		startTime = [[NSDate date] dateByAddingTimeInterval:-1*60*60*24*30];
	
	if([[formDataArray stringAtIndex:0] isEqualToString:@"Last 90 Days"])
		startTime = [[NSDate date] dateByAddingTimeInterval:-1*60*60*24*90];
	
	if([[formDataArray stringAtIndex:0] isEqualToString:@"This Month"])
		startTime = [ProjectFunctions getFirstDayOfMonth:[NSDate date]];

	if([[formDataArray stringAtIndex:0] isEqualToString:@"Last Month"]) {
		NSDate *day1 = [ProjectFunctions getFirstDayOfMonth:[NSDate date]];
		NSDate *lastMonth = [day1 dateByAddingTimeInterval:-1*60*60*24];
		startTime = [ProjectFunctions getFirstDayOfMonth:lastMonth];
		endTime = day1;
	}
	
	NSString *formatString = @"startTime >= %@ AND startTime < %@";
	return [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"%@ AND %@", predicateString, formatString], startTime, endTime];
}

+(NSString *)getYearString:(int)year
{
	if(year>0)
		return [NSString stringWithFormat:@"%d", year];
	else 
		return @"LifeTime";
}

+(NSString *)getBasicPredicateString:(int)year type:(NSString *)Type
{
	NSMutableString *predicateString = [NSMutableString stringWithCapacity:500];
	[predicateString appendString:@"user_id = '0'"];
	
	if(year>0)
		[predicateString appendFormat:@" AND year = '%@'", [NSString stringWithFormat:@"%d", year]];
    
    NSString *bankroll = [ProjectFunctions getUserDefaultValue:@"bankrollDefault"];
    NSString *limitBankRollGames = [ProjectFunctions getUserDefaultValue:@"limitBankRollGames"];
    if([@"YES" isEqualToString:limitBankRollGames])
        [predicateString appendFormat:@" AND bankroll = '%@'", bankroll];
	
	if([Type isEqualToString:@"Cash"] || [Type isEqualToString:@"Tournament"])
		[predicateString appendFormat:@" AND Type = '%@'", [ProjectFunctions formatForDataBase:Type]];
	
	return predicateString;
}

+(NSString *)predicateExt:(NSString *)value allValue:(NSString *)allValue field:(NSString *)field typeValue:(NSString *)typeValue mOC:(NSManagedObjectContext *)mOC buttonNum:(int)buttonNum
{
	NSString *result = @"";
	if(![value isEqualToString:allValue] && ![value isEqualToString:@"*Custom*"])
		result = [NSString stringWithFormat:@" AND %@ = '%@'", field, [ProjectFunctions formatForDataBase:value]];
	
	if([value isEqualToString:@"*Custom*"])
		result = [CoreDataLib getFieldValueForEntity:mOC entityName:@"SEARCH" field:@"searchStr" predString:[NSString stringWithFormat:@"type = '%@' AND searchNum = %d", typeValue, buttonNum] indexPathRow:0];
	
	return result;
}

+(NSString *)getPredicateString:(NSArray *)formDataArray mOC:(NSManagedObjectContext *)mOC buttonNum:(int)buttonNum
{
	NSMutableString *predicateString = [NSMutableString stringWithCapacity:500];
	int year = [[formDataArray stringAtIndex:0] intValue];
	NSString *pred = [ProjectFunctions getBasicPredicateString:year type:[formDataArray stringAtIndex:1]];
	[predicateString appendString:pred];
	
	if([formDataArray count]==2)
		return predicateString;

	[predicateString appendString:[ProjectFunctions predicateExt:[formDataArray stringAtIndex:2] allValue:@"All Games" field:@"gametype" typeValue:@"Game" mOC:mOC buttonNum:buttonNum]];
	[predicateString appendString:[ProjectFunctions predicateExt:[formDataArray stringAtIndex:3] allValue:@"All Limits" field:@"limit" typeValue:@"Limit" mOC:mOC buttonNum:buttonNum]];
	[predicateString appendString:[ProjectFunctions predicateExt:[formDataArray stringAtIndex:4] allValue:@"All Stakes" field:@"stakes" typeValue:@"Stakes" mOC:mOC buttonNum:buttonNum]];
	[predicateString appendString:[ProjectFunctions predicateExt:[formDataArray stringAtIndex:5] allValue:@"All Locations" field:@"location" typeValue:@"Location" mOC:mOC buttonNum:buttonNum]];
	[predicateString appendString:[ProjectFunctions predicateExt:[formDataArray stringAtIndex:6] allValue:@"All Bankrolls" field:@"bankroll" typeValue:@"Bankroll" mOC:mOC buttonNum:buttonNum]];
	if([formDataArray count]>7)
		[predicateString appendString:[ProjectFunctions predicateExt:[formDataArray stringAtIndex:7] allValue:@"All Types" field:@"tournamentType" typeValue:@"Tournament Type" mOC:mOC buttonNum:buttonNum]];
	
	
	if(kLOG)
		NSLog(@"[%@]", predicateString);
	
	return predicateString;
}

+(NSString *)convertNumberToMoneyString:(float)money
{
	NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
	[formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
	NSString *moneyStr = [formatter stringFromNumber:[NSNumber numberWithFloat:money]];
	
	NSString *symbol = [ProjectFunctions getMoneySymbol];
	if([symbol length]>0 && ![symbol isEqualToString:@"$"])
		moneyStr = [moneyStr stringByReplacingOccurrencesOfString:@"$" withString:symbol];
	
    if([ProjectFunctions getUserDefaultValue:@"moneySymbol"] && [moneyStr rangeOfString:symbol].location == NSNotFound)
        moneyStr = [NSString stringWithFormat:@"%@%.2f", symbol, money];

	return [moneyStr stringByReplacingOccurrencesOfString:@".00" withString:@""];	
}

+(NSString *)convertIntToMoneyString:(int)money
{
	
	if(money>100000000)
		return [NSString stringWithFormat:@"%@%dM", [ProjectFunctions getMoneySymbol], money/1000000];
	if(money>1000000)
		return [NSString stringWithFormat:@"%@%.1fM", [ProjectFunctions getMoneySymbol], (float)money/1000000];
	if(money>100000)
		return [NSString stringWithFormat:@"%@%dK", [ProjectFunctions getMoneySymbol], money/1000];
	
	return [ProjectFunctions convertNumberToMoneyString:(float)money];
}

+(NSArray *)getArrayForSegment:(int)segment
{
	if(segment==0)
		return [NSArray arrayWithObjects:@"Hold'em", @"Omaha", @"Razz", @"7-Card", @"5-Card", nil];
	if(segment==1)
		return [NSArray arrayWithObjects:@"$1/$2", @"$1/$3", @"$3/$5", @"$3/$6", @"$5/$10", nil];
	if(segment==2)
		return [NSArray arrayWithObjects:@"No-Limit", @"Limit", @"Spread", @"Pot-Limit", nil];
	if(segment==3)
		return [NSArray arrayWithObjects:@"Single Table", @"Multi Table", @"Heads up", @"Rebuy", nil];
	
	return [NSArray arrayWithObjects:@"No-Limit", @"Limit", @"Spread", @"Pot-Limit", nil];
}

+(NSArray *)getColumnListForEntity:(NSString *)entityName type:(NSString *)type
{
	NSArray *list=nil;
	if([entityName isEqualToString:@"BIGHAND"] && [type isEqualToString:@"column"])
		list = [NSArray arrayWithObjects:
				@"winStatus", 
				@"gameDate", 
				@"player1Hand", 
				@"player2Hand",
				@"player3Hand",
				@"player4Hand",
				@"player5Hand",
				@"player6Hand",
				@"flop",
				@"turn",
				@"river",
				@"potsize",
				@"numPlayers",
				@"name",
				@"preflopAction",
				@"attrib02",
				@"turnAction",
				@"riverAction",
				@"details",
				nil];
	
	if([entityName isEqualToString:@"BIGHAND"] && [type isEqualToString:@"type"])
		list = [NSArray arrayWithObjects:
				@"text", 
				@"shortDate", 
				@"text", //1
				@"text", 
				@"text", 
				@"text", 
				@"text", 
				@"text", //6
				@"text", 
				@"text", 
				@"text", 
				@"int", 
				@"int", 
				@"text", 
				@"text", 
				@"text", 
				@"text", 
				@"text", 
				@"text", 
				nil];
	
	if([entityName isEqualToString:@"GAME"] && [type isEqualToString:@"column"])
		list = [NSArray arrayWithObjects:
				@"startTime", 
				@"endTime", 
				@"hours", 
				@"buyInAmount",
				@"rebuyAmount",
				@"foodDrinks",
				@"cashoutAmount",
				@"winnings",
				@"name",
				@"gametype",
				@"stakes",
				@"limit",
				@"location",
				@"bankroll",
				@"numRebuys",
				@"notes",
				@"breakMinutes",
				@"tokes",
				@"minutes",
				@"year",
				@"Type",
				@"status",
				@"tournamentType",
				@"user_id",
				@"weekday",
				@"month",
				@"daytime",
				@"attrib01",
				@"attrib02",
				@"tournamentSpots",
				@"tournamentFinish",
				@"game_id",
				nil];
	
	if([entityName isEqualToString:@"GAME"] && [type isEqualToString:@"type"])
		list = [NSArray arrayWithObjects:
				@"date", 
				@"date", 
				@"text", 
				@"float", 
				@"float", 
				@"int", 
				@"float", 
				@"float", 
				@"text",	// name
				@"text", 
				@"text", 
				@"text", 
				@"text", 
				@"text", 
				@"int", 
				@"text",	// Notes
				@"int", 
				@"int", 
				@"int", 
				@"text", // year
				@"text", 
				@"text", 
				@"text", 
				@"int", 
				@"text", 
				@"text", 
				@"text", 
				@"text",
				@"text",
				@"int",
				@"int",
				@"int",
				nil];

	if([entityName isEqualToString:@"FILTER"] && [type isEqualToString:@"column"])
		list = [NSArray arrayWithObjects:
				@"timeframe", 
				@"Type", 
				@"game", 
				@"limit", 
				@"stakes", 
				@"location", 
				@"bankroll", 
				@"tournamentType",
				@"button", 
				@"name", 
				nil];
	
	if([entityName isEqualToString:@"FILTER"] && [type isEqualToString:@"type"])
		list = [NSArray arrayWithObjects:
				@"text", 
				@"text", 
				@"text", 
				@"text",
				@"text",
				@"text",
				@"text",
				@"text",
				@"int",
				@"text",
				nil];

	if([entityName isEqualToString:@"FRIEND"] && [type isEqualToString:@"column"])
		list = [NSArray arrayWithObjects:
				@"lastGameDate", 
				@"created", 
				@"name",
				@"status",
				@"email",
				@"bankRoll", 
				@"user_id",
				@"gamesThisYear",
				@"gamesLastYear",
				@"gamesThisMonth",
				@"gamesLast10",
				@"streakThisYear",
				@"streakLastYear",
				@"streakThisMonth",
				@"streakLast10",
				@"gameCountThisYear",
				@"gameCountLastYear",
				@"gameCountThisMonth",
				@"gameCountLast10",
				@"profitThisYear",
				@"profitLastYear",
				@"profitThisMonth",
				@"profitLast10",
				@"hoursThisYear",
				@"hoursLastYear",
				@"hoursThisMonth",
				@"hourlyThisYear",
				@"hourlyThisMonth",
				@"hourlyLast10",
				@"attrib_01",
				@"attrib_02",
				@"attrib_03",
				@"attrib_04",
				@"attrib_05",
				@"attrib_06",
				@"attrib_07",
				@"attrib_08",
				@"attrib_09",
				@"attrib_10",
				@"attrib_11",
				@"attrib_12",
				nil];
	
	if([entityName isEqualToString:@"FRIEND"] && [type isEqualToString:@"type"])
		list = [NSArray arrayWithObjects:
				@"date",
				@"date", 
				@"text", 
				@"text",
				@"text",
				@"text",
				@"int",
				@"text",
				@"text",
				@"text",
				@"text",
				@"int",
				@"int",
				@"int",
				@"int",
				@"int",
				@"int",
				@"int",
				@"int",
				@"int",
				@"int",
				@"int",
				@"int",
				@"int",
				@"int",
				@"int",
				@"int",
				@"int",
				@"int",
				@"int",
				@"int",
				@"int",
				@"int",
				@"int",
				@"int",
				@"text",
				@"text",
				@"text",
				@"text",
				@"text",
				@"text",
				nil];
	
	if([entityName isEqualToString:@"SEARCH"] && [type isEqualToString:@"column"])
		list = [NSArray arrayWithObjects:
				@"type", 
				@"searchStr", 
				@"startTime", 
				@"endTime",
				@"checkmarkList",
				@"searchNum",
				nil];
	
	if([entityName isEqualToString:@"SEARCH"] && [type isEqualToString:@"type"])
		list = [NSArray arrayWithObjects:
				@"text", 
				@"text", 
				@"date", 
				@"date",
				@"text", 
				@"int", 
				nil];
	
	if([entityName isEqualToString:@"MESSAGE"] && [type isEqualToString:@"column"])
		list = [NSArray arrayWithObjects:
				@"friend_id", 
				@"created", 
				@"body", 
				nil];
	
	if([entityName isEqualToString:@"MESSAGE"] && [type isEqualToString:@"type"])
		list = [NSArray arrayWithObjects:
				@"int", 
				@"date", 
				@"text", 
				nil];
	
	if([entityName isEqualToString:@"EXTRA"] && [type isEqualToString:@"column"])
		list = [NSArray arrayWithObjects:
				@"type", 
				@"name", 
				@"attrib_01", 
				@"attrib_02", 
				@"attrib_03", 
				@"attrib_04", 
				@"status",
				@"user_id",
				@"player_id",
				@"looseNum",
				@"agressiveNum",
				nil];
	
	if([entityName isEqualToString:@"EXTRA"] && [type isEqualToString:@"type"])
		list = [NSArray arrayWithObjects:
				@"text", 
				@"text", 
				@"int", 
				@"int", 
				@"text", 
				@"text", 
				@"text",
				@"int",
				@"int",
				@"int",
				@"int",
				nil];
	
	if([entityName isEqualToString:@"CHIPSTACK"] && [type isEqualToString:@"column"])
		list = [NSArray arrayWithObjects:
				@"amount", 
				@"timeStamp", 
				nil];
	
	if([entityName isEqualToString:@"CHIPSTACK"] && [type isEqualToString:@"type"])
		list = [NSArray arrayWithObjects:
				@"int", 
				@"date", 
				nil];
	
	if([entityName isEqualToString:@"PLAYER"] && [type isEqualToString:@"column"])
		list = [NSArray arrayWithObjects:
				@"playerNum",
				@"chips",
				@"preflopBet",
				@"preflopOdds",
				@"flopBet", 
				@"flopOdds",
				@"turnBet",
				@"turnOdds",
				@"riverBet",
				@"result",
				@"bighand",
				nil];
	
	if([entityName isEqualToString:@"PLAYER"] && [type isEqualToString:@"type"])
		list = [NSArray arrayWithObjects:
				@"int", 
				@"int", 
				@"int", 
				@"text", 
				@"int", 
				@"text", 
				@"int", 
				@"text", 
				@"int", 
				@"text", 
				@"key", 
				nil];
	
	if([entityName isEqualToString:@"GAMEPLAYER"] && [type isEqualToString:@"column"])
		list = [NSArray arrayWithObjects:
				@"game_id",
				@"player_id",
				@"winFlag",
				@"wonMoneyFlg",
				nil];
	
	if([entityName isEqualToString:@"GAMEPLAYER"] && [type isEqualToString:@"type"])
		list = [NSArray arrayWithObjects:
				@"int", 
				@"int", 
				@"text", 
				@"text", 
				nil];
	
	if([entityName isEqualToString:@"EXTRA2"] && [type isEqualToString:@"column"])
		list = [NSArray arrayWithObjects:
				@"type",
				@"name",
				@"attrib_01",
				@"created",
				nil];
	
	if([entityName isEqualToString:@"EXTRA2"] && [type isEqualToString:@"type"])
		list = [NSArray arrayWithObjects:
				@"text",
				@"text",
				@"int",
				@"date",
				nil];
	
	if([entityName isEqualToString:@"BANKROLL"] && [type isEqualToString:@"column"])
		list = [NSArray arrayWithObjects:
				@"name",
				nil];
	
	if([entityName isEqualToString:@"BANKROLL"] && [type isEqualToString:@"type"])
		list = [NSArray arrayWithObjects:
				@"text",
				nil];
	
	
	
	return list;
}

+(BOOL)updateGameInDatabase:(NSManagedObjectContext *)mOC mo:(NSManagedObject *)mo valueList:(NSArray *)valueList2
{
	NSArray *keyList = [ProjectFunctions getColumnListForEntity:@"GAME" type:@"column"];
	NSArray *typeList = [ProjectFunctions getColumnListForEntity:@"GAME" type:@"type"];
	
	NSMutableArray *valueList = [NSMutableArray arrayWithArray:valueList2];

	int user_id = [[valueList stringAtIndex:23] intValue];

	[ProjectFunctions updateNewvalueIfNeeded:[valueList stringAtIndex:9] type:@"Game" mOC:mOC];
	NSString *gameType = [valueList stringAtIndex:kType];
	NSString *notes = [valueList stringAtIndex:15];
	if([notes length]>1) {
		NSString *newNotes = [notes stringByReplacingOccurrencesOfString:@"[nl]" withString:@"\n"];
		if(![notes isEqualToString:newNotes])
			[valueList replaceObjectAtIndex:15 withObject:newNotes];
	}
	
	if([gameType isEqualToString:@"Cash"]) {
		if(user_id==0) {
			[ProjectFunctions updateNewvalueIfNeeded:[valueList stringAtIndex:kBlinds] type:@"Stakes" mOC:mOC];
			[ProjectFunctions setUserDefaultValue:[NSString stringWithFormat:@"%d", [[valueList stringAtIndex:kbuyIn] intValue]] forKey:@"buyinDefault"];
		}
		
	} else {
		if(user_id==0) {
			[ProjectFunctions updateNewvalueIfNeeded:[valueList stringAtIndex:kBlinds] type:@"Tournament" mOC:mOC];
			[ProjectFunctions setUserDefaultValue:[NSString stringWithFormat:@"%d", [[valueList stringAtIndex:kbuyIn] intValue]] forKey:@"tournbuyinDefault"];
		}
		NSMutableArray *temp = [[NSMutableArray alloc] initWithArray:valueList];
		[temp addObject:@""];
		[temp addObject:@""];
		[temp addObject:[valueList stringAtIndex:kFood]];
		[temp addObject:[valueList stringAtIndex:kdealertokes]];
		[temp replaceObjectAtIndex:kFood withObject:@"0"];
		[temp replaceObjectAtIndex:kdealertokes withObject:@"0"];
		valueList = temp;
	}
		
	if(user_id==0) {
		[ProjectFunctions updateNewvalueIfNeeded:[valueList stringAtIndex:kLimit] type:@"Limit" mOC:mOC];
		[ProjectFunctions updateNewvalueIfNeeded:[valueList stringAtIndex:kLocation] type:@"Location" mOC:mOC];
		[ProjectFunctions updateNewvalueIfNeeded:[valueList stringAtIndex:kBankroll] type:@"Bankroll" mOC:mOC];
		[ProjectFunctions updateNewvalueIfNeeded:[valueList stringAtIndex:kYear] type:@"Year" mOC:mOC];
		[ProjectFunctions updateNewvalueIfNeeded:[valueList stringAtIndex:kType] type:@"Type" mOC:mOC];

	
		[ProjectFunctions setUserDefaultValue:[valueList stringAtIndex:kType] forKey:@"gameTypeDefault"];
		[ProjectFunctions setUserDefaultValue:[valueList stringAtIndex:kGameMode] forKey:@"gameDefault"];
		[ProjectFunctions setUserDefaultValue:[valueList stringAtIndex:kGame] forKey:@"gameNameDefault"];
		if([gameType isEqualToString:@"Cash"])
			[ProjectFunctions setUserDefaultValue:[valueList stringAtIndex:kBlinds] forKey:@"blindDefault"];
		[ProjectFunctions setUserDefaultValue:[valueList stringAtIndex:kLimit] forKey:@"limitDefault"];
		[ProjectFunctions setUserDefaultValue:[valueList stringAtIndex:kLocation] forKey:@"locationDefault"];
		[ProjectFunctions setUserDefaultValue:[valueList stringAtIndex:kBankroll] forKey:@"bankrollDefault"];
		[ProjectFunctions setUserDefaultValue:[valueList stringAtIndex:kTourneyType] forKey:@"tourneyTypeDefault"];
	}
	if(kLOG)
		NSLog(@"-------------------------------------------");
	
	BOOL success = [CoreDataLib updateManagedObject:mo keyList:keyList valueList:valueList typeList:typeList mOC:mOC];
	NSLog(@"weekday: %@", [mo valueForKey:@"weekday"]);
	NSLog(@"hours: %@", [mo valueForKey:@"hours"]);
	NSDate *startTime = [mo valueForKey:@"startTime"];
	NSDate *endTime = [mo valueForKey:@"endTime"];
	
	NSString *weekday = [startTime convertDateToStringWithFormat:@"EEEE"];
	NSString *month = [startTime convertDateToStringWithFormat:@"MMMM"];
	NSString *year = [startTime convertDateToStringWithFormat:@"yyyy"];
	NSString *daytime = [ProjectFunctions getDayTimeFromDate:startTime];
	int seconds = [endTime timeIntervalSinceDate:startTime];
	[mo setValue:weekday forKey:@"weekday"];
	[mo setValue:month forKey:@"month"];
	[mo setValue:year forKey:@"year"];
	[mo setValue:daytime forKey:@"daytime"];
	[mo setValue:[NSString stringWithFormat:@"%.1f", (float)seconds/3600] forKey:@"hours"];
	[mo setValue:[NSNumber numberWithInt:seconds/60] forKey:@"minutes"];
	[mOC save:nil];
	NSLog(@"weekday: %@", [mo valueForKey:@"weekday"]);
	NSLog(@"hours: %@", [mo valueForKey:@"hours"]);

	return success;
}

+(BOOL)updateEntityInDatabase:(NSManagedObjectContext *)mOC mo:(NSManagedObject *)mo valueList:(NSArray *)valueList entityName:(NSString *)entityName
{
	NSArray *keyList = [ProjectFunctions getColumnListForEntity:entityName type:@"column"];
	NSArray *typeList = [ProjectFunctions getColumnListForEntity:entityName type:@"type"];
	NSLog(@"+++updating %@", entityName);
    
	return [CoreDataLib updateManagedObject:mo keyList:keyList valueList:valueList typeList:typeList mOC:mOC];
}

+(void)setUserDefaultValue:(NSString *)value forKey:(NSString *)key
{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults setObject:value forKey:key];
}

+(NSString *)getUserDefaultValue:(NSString *)key
{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	NSString *result = [userDefaults stringForKey:key];
	
	if([key isEqualToString:@"gameTypeDefault"] && [result length]==0) {
		result = @"Cash";
	}
	if([key isEqualToString:@"buyinDefault"] && [result length]==0) {
		result = @"100";
	}
	if([key isEqualToString:@"tournbuyinDefault"] && [result length]==0) {
		result = @"30";
	}
	if([key isEqualToString:@"gameDefault"] && [result length]==0) {
		result = @"Hold'em $1/$3 No-Limit";
	}
	if([key isEqualToString:@"gameNameDefault"] && [result length]==0) {
		result = @"Hold'em";
	}
	if([key isEqualToString:@"blindDefault"] && [result length]==0) {
		result = @"$1/$3";
	}
	if([key isEqualToString:@"limitDefault"] && [result length]==0) {
		result = @"No-Limit";
	}
	if([key isEqualToString:@"locationDefault"] && [result length]==0) {
		result = @"Casino";
	}
	if([key isEqualToString:@"bankrollDefault"] && [result length]==0) {
		result = @"Default";
	}

	if([key isEqualToString:@"profitGoal"] && [result length]==0) {
		result = @"1000";
	}
	if([key isEqualToString:@"hourlyGoal"] && [result length]==0) {
		result = @"20";
	}

	if([key isEqualToString:@"tourneyTypeDefault"] && [result length]<2) {
		result = @"Single Table";
	}
	if([key isEqualToString:@"lastSyncedDate"] && [result length]<2) {
		result = @"01/01/1990 12:00:00 AM";
	}
	
	return result;
}

+(UIImage *)plotStatsChart:(NSManagedObjectContext *)mOC predicate:(NSPredicate *)predicate displayBySession:(BOOL)displayBySession
{
	int totalWidth=640;
	int totalHeight=300;
	int leftEdgeOfChart=50;
	int bottomEdgeOfChart=totalHeight-25;
	float chartWidth = totalWidth-leftEdgeOfChart-6; // account for border of image
	
	// get games from the database based on the filter
	NSArray *games = [CoreDataLib selectRowsFromEntity:@"GAME" predicate:predicate sortColumn:@"startTime" mOC:mOC ascendingFlg:YES];
	int numGames=(int)games.count;
	
	NSDate *firstDate = (numGames>0)?[[games objectAtIndex:0] valueForKey:@"startTime"]:[NSDate date];
	NSDate *lastDate = (numGames>0)?[[games objectAtIndex:numGames-1] valueForKey:@"startTime"]:[NSDate date];
	
	//--------- Initialyze spacing/min/max values
	double min=0;
	double max=0;
	double totalMoney=0;
	for (NSManagedObject *mo in games) {
		totalMoney += [[mo valueForKey:@"winnings"] doubleValue];
		if(totalMoney<min)
			min = totalMoney;
		if(totalMoney>max)
			max = totalMoney;
	}
	max*=1.04;
	double totalMoneyRange = max-min;
	int totalSecondsRange = [lastDate timeIntervalSinceDate:firstDate];

	float yMultiplier = 1;
	float xMultiplier = 1;
	if(totalMoneyRange>0)
		yMultiplier = (float)bottomEdgeOfChart/totalMoneyRange;
	if(totalSecondsRange>0)
		xMultiplier = (float)chartWidth/totalSecondsRange;
	
	float sessionSpacer = 100;
	if(numGames>0)
		sessionSpacer = (float)chartWidth/(numGames);

	NSLog(@"min: %f, max: %f ", min, max);
	
	//------- init UIImage
	UIImage *dynamicChartImage = [[UIImage alloc] init];

	CGContextRef c = [self contextRefForGraphofWidth:totalWidth totalHeight:totalHeight];
	int zeroLoc = [self drawZeroLineForContext:c min:min max:max bottomEdgeOfChart:bottomEdgeOfChart leftEdgeOfChart:leftEdgeOfChart totalWidth:totalWidth];

	// draw bottom labels ---------------------
	CGContextSetRGBFillColor(c, 0.0, 0.0, 0.4, 1); // text
	int percentOver=0;
	for(int i=0; i<=4; i++) {
		int timeSecs = totalSecondsRange*i/4;
		int XCord = leftEdgeOfChart+(totalWidth-leftEdgeOfChart)*i/4;
		NSDate *labelDate = [firstDate dateByAddingTimeInterval:timeSecs];
		[self drawLine:c startX:XCord+20 startY:bottomEdgeOfChart-5 endX:XCord+20 endY:bottomEdgeOfChart+5];
		NSString *label = nil;
		if(totalSecondsRange>60*60*24*365*4)
			label = [labelDate convertDateToStringWithFormat:@"yyyy"];
		else if(totalSecondsRange>60*60*24*31*12)
			label = [labelDate convertDateToStringWithFormat:@"MMM yy"];
		else if(totalSecondsRange>60*60*24*120)
			label = [labelDate convertDateToStringWithFormat:@"MMM"];
		else
			label = [labelDate convertDateToStringWithFormat:@"MMM dd"];

		int labelSpacer=-20;
		if(displayBySession) {
			int sessionNum=(int)games.count*percentOver/100;
			if(sessionNum==0 && games.count>10)
				sessionNum=1;
			label = [NSString stringWithFormat:@"%d", sessionNum];
			labelSpacer = -2;
		}
		
		if(i==4) // last label pushed over a bit
			labelSpacer -= 20;

		BOOL showLabel = NO;
		if(numGames==1 && i==0)
			showLabel = YES;
		if(numGames==2 && (i==0 || i==4))
			showLabel = YES;
		if(numGames==3 && (i==0 || i==2 || i==4))
			showLabel = YES;
		if(numGames==4 && (i==0 || i==1 || i==3 || i==4))
			showLabel = YES;
		if(numGames>4)
			showLabel = YES;
		
		if(numGames==4 && i==1)
			labelSpacer+=20;
		if(numGames==4 && i==3)
			labelSpacer-=25;
		
		if(showLabel)
			[label drawAtPoint:CGPointMake(XCord+labelSpacer, bottomEdgeOfChart) withFont:[UIFont fontWithName:@"Helvetica" size:18]];
		
		percentOver+=25;
	}
	
	// Draw horizontal and vertical baselines
	CGContextSetRGBStrokeColor(c, 0, 0, 0, 1); // black
	[self drawLine:c startX:leftEdgeOfChart startY:bottomEdgeOfChart endX:totalWidth endY:bottomEdgeOfChart];
	[self drawLine:c startX:leftEdgeOfChart startY:0 endX:leftEdgeOfChart endY:bottomEdgeOfChart];
	

	// Graph the Chart---------------------
	UIBezierPath *aPath = [UIBezierPath bezierPath];
	[aPath moveToPoint:CGPointMake(leftEdgeOfChart, bottomEdgeOfChart)];
	if(games.count>0)
		[aPath addLineToPoint:CGPointMake(leftEdgeOfChart, max*yMultiplier)];

	int plotY = [self drawTheGraphWithContext:c games:games firstDate:firstDate aPath:aPath leftEdgeOfChart:leftEdgeOfChart bottomEdgeOfChart:bottomEdgeOfChart max:max min:min xMultiplier:xMultiplier yMultiplier:yMultiplier sessionSpacer:sessionSpacer displayBySession:displayBySession];

	[aPath addLineToPoint:CGPointMake(totalWidth, plotY)];
	[aPath addLineToPoint:CGPointMake(totalWidth, bottomEdgeOfChart)];
	[aPath addLineToPoint:CGPointMake(leftEdgeOfChart, bottomEdgeOfChart)];
	[aPath closePath];

	[self addGradientToPath:aPath context:c color1:[UIColor whiteColor] color2:(UIColor *)[UIColor greenColor] lineWidth:(int)0 imgWidth:totalWidth imgHeight:totalHeight];

	[self drawLeftLabelsAndLinesForContext:c totalMoneyRange:totalMoneyRange min:min leftEdgeOfChart:leftEdgeOfChart totalHeight:totalHeight totalWidth:totalWidth];

	// Graph the Chart Again---------------------
	[self drawTheGraphWithContext:c games:games firstDate:firstDate aPath:nil leftEdgeOfChart:leftEdgeOfChart bottomEdgeOfChart:bottomEdgeOfChart max:max min:min xMultiplier:xMultiplier yMultiplier:yMultiplier sessionSpacer:sessionSpacer displayBySession:displayBySession];


	//----- draw zero line---------------
	CGContextSetRGBStrokeColor(c, 0.6, 0.2, 0.2, 1); // red
	CGContextSetLineWidth(c, 2);
	
	float percentUp = 0;
	if(totalMoneyRange>0)
		percentUp = (float)(0 - min) / totalMoneyRange;

	zeroLoc = bottomEdgeOfChart - ((float)bottomEdgeOfChart*percentUp);
	if(zeroLoc <= bottomEdgeOfChart && zeroLoc >= 0)
		[self drawLine:c startX:leftEdgeOfChart startY:zeroLoc endX:totalWidth endY:zeroLoc];

	
	//----------Draw display type
	CGContextSetLineWidth(c, 1);
	CGContextSetRGBFillColor(c, 0, 0, 0, 1); // 
	CGContextFillRect(c, CGRectMake(leftEdgeOfChart, 0, leftEdgeOfChart+140, 25));
	CGContextSetRGBFillColor(c, 1, 1, 1, 1); 
	if(displayBySession)
		[@"Display by Session" drawAtPoint:CGPointMake(leftEdgeOfChart+10, 1) withFont:[UIFont boldSystemFontOfSize:20]];
	else
		[@"  Display by Date" drawAtPoint:CGPointMake(leftEdgeOfChart+10, 1) withFont:[UIFont boldSystemFontOfSize:20]];


	
	//---finish up----------
	UIGraphicsPopContext();
	dynamicChartImage = UIGraphicsGetImageFromCurrentImageContext();
	
	UIGraphicsEndImageContext();
	
	return dynamicChartImage;
	
}


+(int)drawTheGraphWithContext:(CGContextRef)c
						 games:(NSArray *)games
					 firstDate:(NSDate *)firstDate
						aPath:(UIBezierPath *)aPath
			   leftEdgeOfChart:(int)leftEdgeOfChart
			 bottomEdgeOfChart:(int)bottomEdgeOfChart
						   max:(double)max
						   min:(double)min
				   xMultiplier:(float)xMultiplier
				   yMultiplier:(float)yMultiplier
				 sessionSpacer:(float)sessionSpacer
			  displayBySession:(BOOL)displayBySession
{
	if(games.count>20)
		CGContextSetLineWidth(c, 1);
	else
		CGContextSetLineWidth(c, 2);
	int oldX=leftEdgeOfChart;
	int oldY=(max*yMultiplier);
	int plotY=0;
	int currentMoney = 0;
	int circleSize=30-(int)games.count;
	int i=1;
	BOOL prevWinFlg=YES;
	for (NSManagedObject *mo in games) {
		NSDate *startTime = [mo valueForKey:@"startTime"];
		int money = [[mo valueForKey:@"winnings"] intValue];
		BOOL winFlg = (money>=0);
		int seconds = [startTime timeIntervalSinceDate:firstDate];
		currentMoney += money;
		int plotX = seconds*xMultiplier+leftEdgeOfChart;
		
		if(displayBySession || games.count==1)
			plotX = sessionSpacer*i+leftEdgeOfChart;
		
		if(games.count==1)
			plotX-=10; // just to show it better
		
		plotY = bottomEdgeOfChart-(currentMoney-min)*yMultiplier;
		
		CGContextSetRGBFillColor(c, 0, 0, 0, 1);
		CGContextSetRGBStrokeColor(c, 0, 0, 0, 1); // black
		[self drawLine:c startX:oldX-1 startY:oldY+1 endX:plotX-1 endY:plotY+1];
		
		if(winFlg)
			CGContextSetRGBStrokeColor(c, 0, .5, 0, 1); // green
		else
			CGContextSetRGBStrokeColor(c, 1, 0, 0, 1); // red
		
		[self drawLine:c startX:oldX startY:oldY endX:plotX endY:plotY];
		
		[self drawGraphCircleForContext:c x:plotX y:plotY winFlg:winFlg circleSize:circleSize];
		if(i>1)
			[self drawGraphCircleForContext:c x:oldX y:oldY winFlg:prevWinFlg circleSize:circleSize];

		
		if(aPath) {
			[aPath addLineToPoint:CGPointMake(plotX, plotY)];
		}

		prevWinFlg=winFlg;
		oldX = plotX;
		oldY = plotY;
		i++;
	}
	return plotY;
}

+(void)addGradientToPath:(UIBezierPath *)aPath
				 context:(CGContextRef)context
				  color1:(UIColor *)color1
				  color2:(UIColor *)color2
			   lineWidth:(int)lineWidth
				imgWidth:(int)width
			   imgHeight:(int)height
{
	CGFloat red1 = 0.0, green1 = 0.0, blue1 = 0.0, alpha1 =0.0;
	[color1 getRed:&red1 green:&green1 blue:&blue1 alpha:&alpha1];
	
	CGFloat red2 = 0.0, green2 = 0.0, blue2 = 0.0, alpha2 =0.0;
	[color2 getRed:&red2 green:&green2 blue:&blue2 alpha:&alpha2];
	
	CGColorSpaceRef myColorspace=CGColorSpaceCreateDeviceRGB();
	size_t num_locations = 2;
	CGFloat locations[2] = { 1.0, 0.0 };
	CGFloat components[8] =	{ red2, green2, blue2, alpha2,    red1, green1, blue1, alpha1};
	
	CGGradientRef myGradient = CGGradientCreateWithColorComponents(myColorspace, components, locations, num_locations);
	
	CGContextSaveGState(context);
	[aPath addClip];
	CGContextDrawLinearGradient(context, myGradient, CGPointMake(0, 0), CGPointMake(width, height), 0);
	CGContextRestoreGState(context);
	
	[[UIColor blackColor] setStroke];
	aPath.lineWidth = lineWidth;
	[aPath stroke];
	
	CGGradientRelease(myGradient);
}

+(void)drawGraphCircleForContext:(CGContextRef)c x:(int)x y:(int)y winFlg:(BOOL)winFlg circleSize:(int)circleSize {
	if(circleSize>22)
		circleSize=22;
	if(circleSize<6)
		circleSize=6;
	
	CGContextSetRGBFillColor(c, .5, .5, .5, 1);
	for(int i=1; i<=2; i++)
		CGContextFillEllipseInRect(c, CGRectMake(x-circleSize/2+i,y-circleSize/2+i,circleSize,circleSize));
	
	CGContextSetRGBFillColor(c, 0, 0, 0, 1);
	CGContextFillEllipseInRect(c, CGRectMake(x-circleSize/2,y-circleSize/2,circleSize,circleSize));
	
	circleSize-=2;
	CGContextSetRGBFillColor(c, 1, 1, 1, 1);
	CGContextFillEllipseInRect(c, CGRectMake(x-circleSize/2,y-circleSize/2,circleSize,circleSize));
	
	if(circleSize>8)
		circleSize-=8;
	if(winFlg)
		CGContextSetRGBFillColor(c, 0, .5, 0, 1);
	else
		CGContextSetRGBFillColor(c, 1, 0, 0, 1);
	
	CGContextFillEllipseInRect(c, CGRectMake(x-circleSize/2,y-circleSize/2,circleSize,circleSize));
	
	CGContextDrawPath(c, kCGPathFillStroke);
}



+(NSString *)smallLabelForMoney:(float)money totalMoneyRange:(float)totalMoneyRange {
	int moneyRoundingFactor = 1;
	if(totalMoneyRange>500)
		moneyRoundingFactor=10;
	if(totalMoneyRange>5000)
		moneyRoundingFactor=100;
	if(totalMoneyRange>50000)
		moneyRoundingFactor=1000;
	if(totalMoneyRange>500000)
		moneyRoundingFactor=10000;
	if(totalMoneyRange>5000000)
		moneyRoundingFactor=100000;
	
	money /=moneyRoundingFactor;
	money *=moneyRoundingFactor;
	
	BOOL negValue = (money<0)?YES:NO;
	if(negValue)
		money*=-1;
	
	NSString *label = [NSString stringWithFormat:@"%@%d", [ProjectFunctions getMoneySymbol], (int)money];
	if(money>1000)
		label = [NSString stringWithFormat:@"%@%.1fk", [ProjectFunctions getMoneySymbol], (float)money/1000];
	if(money>10000)
		label = [NSString stringWithFormat:@"%@%dk", [ProjectFunctions getMoneySymbol], (int)money/1000];
	if(money>100000)
		label = [NSString stringWithFormat:@"%dk", (int)money/1000];
	if(money>1000000)
		label = [NSString stringWithFormat:@"%@%.1fM", [ProjectFunctions getMoneySymbol], (float)money/1000000];
	if(money>10000000)
		label = [NSString stringWithFormat:@"%@%dM", [ProjectFunctions getMoneySymbol], (int)money/1000000];
	
	if (negValue)
		return [NSString stringWithFormat:@"-%@", label];
	else
		return label;
}

+(void)drawLeftLabelsAndLinesForContext:(CGContextRef)c totalMoneyRange:(float)totalMoneyRange min:(double)min leftEdgeOfChart:(int)leftEdgeOfChart totalHeight:(int)totalHeight totalWidth:(int)totalWidth
{
	//------ draw left hand labels and grid---------------------
	int YCord=-8;
	for(int i=11; i>=0; i--) {
		float multiplyer = (float)totalMoneyRange/11;
		float money = (multiplyer*i+min);
		
		NSString *label = [ProjectFunctions smallLabelForMoney:money totalMoneyRange:totalMoneyRange];
		
		if(money>=0)
			CGContextSetRGBFillColor(c, 0.0, 0.3, 0.0, 1); // text green
		else
			CGContextSetRGBFillColor(c, .8, 0, 0, 1); // text red
		
		if(i<11) {
			[label drawAtPoint:CGPointMake(6, YCord) withFont:[UIFont fontWithName:@"Helvetica" size:15]];
			CGContextSetRGBStrokeColor(c, 0.7, 0.7, 0.7, 1); // line color - lightGray
			[self drawLine:c startX:leftEdgeOfChart+1 startY:YCord+7 endX:totalWidth endY:YCord+7];
		}
		YCord += totalHeight/12;
	}

}

+(void)drawBottomLabelsForContext:(CGContextRef)c totalSecondsRange:(int)totalSecondsRange leftEdgeOfChart:(int)leftEdgeOfChart totalHeight:(int)totalHeight totalWidth:(int)totalWidth bottomEdgeOfChart:(int)bottomEdgeOfChart firstDate:(NSDate *)firstDate sessionSpacer:(int)sessionSpacer displayBySession:(BOOL)displayBySession numGames:(int)numGames {
	CGContextSetRGBFillColor(c, 0.4, 0.4, 0.4, 1); // black
	for(int i=0; i<=4; i++) {
		int timeSecs = totalSecondsRange*i/4;
		int XCord = leftEdgeOfChart+(totalWidth-leftEdgeOfChart)*i/4;
		NSDate *labelDate = [firstDate dateByAddingTimeInterval:timeSecs];
		[self drawLine:c startX:XCord+20 startY:bottomEdgeOfChart-5 endX:XCord+20 endY:bottomEdgeOfChart+5];
		NSString *label = nil;
		if(totalSecondsRange>60*60*24*365*4)
			label = [labelDate convertDateToStringWithFormat:@"yyyy"];
		else if(totalSecondsRange>60*60*24*31*12)
			label = [labelDate convertDateToStringWithFormat:@"MMM yy"];
		else if(totalSecondsRange>60*60*24*120)
			label = [labelDate convertDateToStringWithFormat:@"MMM"];
		else if(totalSecondsRange>60*60*24*2)
			label = [labelDate convertDateToStringWithFormat:@"MMM dd"];
		else
			label = [labelDate convertDateToStringWithFormat:@"h:mm a"];
		
		int sessionNum = 1;
		if(sessionSpacer>0)
			sessionNum = ceil(XCord/sessionSpacer);
		
		int labelSpacer=-20;
		if(displayBySession) {
			label = [NSString stringWithFormat:@"%d", sessionNum];
			labelSpacer = -2;
		}
		
		if(i==4) // last label pushed over a bit
			labelSpacer -= 20;
		
		BOOL showLabel = NO;
		if(numGames==1 && i==0)
			showLabel = YES;
		if(numGames==2 && (i==0 || i==4))
			showLabel = YES;
		if(numGames==3 && (i==0 || i==2 || i==4))
			showLabel = YES;
		if(numGames==4 && (i==0 || i==1 || i==3 || i==4))
			showLabel = YES;
		if(numGames>4)
			showLabel = YES;
		
		if(numGames==4 && i==1)
			labelSpacer+=20;
		if(numGames==4 && i==3)
			labelSpacer-=25;
		
		if(showLabel)
			[label drawAtPoint:CGPointMake(XCord+labelSpacer, bottomEdgeOfChart+2) withFont:[UIFont fontWithName:@"Helvetica" size:16]];
		
	} // <-- for
}

+(ChipStackObj *)plotGameChipsChart:(NSManagedObjectContext *)mOC mo:(NSManagedObject *)mo predicate:(NSPredicate *)predicate2 displayBySession:(BOOL)displayBySession
{
	int totalWidth=640;
	int totalHeight=300;
	int leftEdgeOfChart=50;
	int bottomEdgeOfChart=totalHeight-25;
	
	NSMutableArray *pointsArray = [[NSMutableArray alloc] init];

	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"game = %@", mo];
	
	NSArray *items = [CoreDataLib selectRowsFromEntity:@"CHIPSTACK" predicate:predicate sortColumn:@"timeStamp" mOC:mOC ascendingFlg:YES];

	int circleSize=30-(int)items.count;

	NSDate *firstDate = (items.count>0)?[[items objectAtIndex:0] valueForKey:@"timeStamp"]:[NSDate date];
	NSDate *lastDate = (items.count>0)?[[items objectAtIndex:items.count-1] valueForKey:@"timeStamp"]:[NSDate date];
	int min=0;
	int max=0;
	int numGames=0;
	for (NSManagedObject *mo in items) {
		int money = [[mo valueForKey:@"amount"] intValue];
		if(money<min)
			min = money;
		if(money>max)
			max = money;
	}
	max+=20;
	int totalMoneyRange = max-min;
	int totalSecondsRange = [lastDate timeIntervalSinceDate:firstDate];
	
	float yMultiplier = 1;
	float xMultiplier = 1;
	if(totalMoneyRange>0)
		yMultiplier = (float)bottomEdgeOfChart/totalMoneyRange;
	if(totalSecondsRange>0)
		xMultiplier = (float)(totalWidth-leftEdgeOfChart-10)/totalSecondsRange;
	
	float sessionSpacer = 100;
	if(numGames>0)
		sessionSpacer = (float)(totalWidth-leftEdgeOfChart)/(numGames);
	
	UIImage *dynamicChartImage = [[UIImage alloc] init];
	
	UIGraphicsBeginImageContext(CGSizeMake(totalWidth,totalHeight));
	CGContextRef c = UIGraphicsGetCurrentContext();
	UIGraphicsPushContext(c); // <--
	CGContextSetLineCap(c, kCGLineCapRound);
	
	// draw Box---------------------
	CGContextSetLineWidth(c, 1);
	CGContextSetRGBStrokeColor(c, 0, 0, 0, 1); // blank
	CGContextSetRGBFillColor(c, 1, 1, 1, 1); // white
	CGContextFillRect(c, CGRectMake(0, 0, totalWidth, totalHeight));
	CGContextStrokeRect(c, CGRectMake(0, 0, totalWidth, totalHeight));
	
	
	// draw left hand labels and grid---------------------
	[self drawLeftLabelsAndLinesForContext:c totalMoneyRange:totalMoneyRange min:min leftEdgeOfChart:leftEdgeOfChart totalHeight:totalHeight totalWidth:totalWidth];

	// draw bottom labels ---------------------
	[self drawBottomLabelsForContext:c totalSecondsRange:totalSecondsRange leftEdgeOfChart:leftEdgeOfChart totalHeight:totalHeight totalWidth:totalWidth bottomEdgeOfChart:bottomEdgeOfChart firstDate:firstDate sessionSpacer:sessionSpacer displayBySession:displayBySession numGames:5];
	
	// Draw horizontal and vertical baselines
	CGContextSetRGBStrokeColor(c, 0, 0, 0, 1); // black
	[self drawLine:c startX:leftEdgeOfChart startY:bottomEdgeOfChart endX:totalWidth endY:bottomEdgeOfChart];
	[self drawLine:c startX:leftEdgeOfChart startY:0 endX:leftEdgeOfChart endY:bottomEdgeOfChart];
	
	// Graph the Chart---------------------
	CGContextSetLineWidth(c, 2);
	int oldX=leftEdgeOfChart;
	int oldY=(max*yMultiplier);
	int currentMoney = 0;
	//	NSLog(@"start [%d, %d]", oldX, oldY);
	int i=0;
	BOOL prevWinFlg=NO;
	for (NSManagedObject *mo in items) {
		NSDate *startTime = [mo valueForKey:@"timeStamp"];
		int money = [[mo valueForKey:@"amount"] intValue];
		BOOL rebuyFlg = [[mo valueForKey:@"rebuyFlg"] intValue];
		int seconds = [startTime timeIntervalSinceDate:firstDate];
		currentMoney = money;
		int plotX = seconds*xMultiplier+leftEdgeOfChart;
		if(displayBySession)
			plotX = sessionSpacer*i+leftEdgeOfChart;
		
		int plotY = bottomEdgeOfChart-(currentMoney-min)*yMultiplier;
		
		BOOL winFlg=(money>=0)?YES:NO;
			
		//		NSLog(@"$%d [%d, %d]", money, plotX, plotY);
		if(money>=0)
			CGContextSetRGBStrokeColor(c, 0, .5, 0, 1); // green
		else
			CGContextSetRGBStrokeColor(c, 1, 0, 0, 1); // red
		
		if(rebuyFlg)
			CGContextSetRGBStrokeColor(c, 0, 0, 1, 1); // blue
		
		[self drawLine:c startX:oldX startY:oldY endX:plotX endY:plotY];
		[self drawGraphCircleForContext:c x:plotX y:plotY winFlg:winFlg circleSize:circleSize];
		[self drawGraphCircleForContext:c x:oldX y:oldY winFlg:prevWinFlg circleSize:circleSize];
		[pointsArray addObject:[NSString stringWithFormat:@"%d|%d|%d|%@", plotX, plotY, money, [startTime convertDateToStringWithFormat:@"h:mm a"]]];
		
		prevWinFlg=winFlg;
		oldX = plotX;
		oldY = plotY;
		i++;
	}

	// draw zero line---------------
	CGContextSetRGBStrokeColor(c, 0.6, 0.2, 0.2, 1); // lightGray
	CGContextSetLineWidth(c, 2);
	float percentOfScreen = 0;
	if(max-min>0)
		percentOfScreen = (float)max/(max-min);
	
	int zeroLoc=bottomEdgeOfChart*percentOfScreen;
	if(zeroLoc<bottomEdgeOfChart)
		[self drawLine:c startX:leftEdgeOfChart startY:zeroLoc endX:totalWidth endY:zeroLoc];
	

	//Draw display type
	CGContextSetLineWidth(c, 1);
	CGContextSetRGBFillColor(c, 0, 0, 0, 1); // 
	CGContextFillRect(c, CGRectMake(leftEdgeOfChart, 0, leftEdgeOfChart+100, 26));
	CGContextSetRGBFillColor(c, 1, 1, 1, 1); 
	[@"    Profit" drawAtPoint:CGPointMake(leftEdgeOfChart+10, 1) withFont:[UIFont fontWithName:@"Helvetica" size:24]];
	
	
	// Draw box outline again
	CGContextSetRGBStrokeColor(c, 0, 0, 0, 1); // black
	CGContextStrokeRect(c, CGRectMake(0, 0, totalWidth, totalHeight));
	
	UIGraphicsPopContext();
	dynamicChartImage = UIGraphicsGetImageFromCurrentImageContext();
	
	UIGraphicsEndImageContext();
	ChipStackObj *chipStackObj = [[ChipStackObj alloc] init];
	chipStackObj.image = dynamicChartImage;
	chipStackObj.pointArray = pointsArray;
	return chipStackObj;
	
}


+(void)drawLine:(CGContextRef)c startX:(int)startX startY:(int)startY endX:(int)endX endY:(int)endY
{
	CGContextMoveToPoint(c, startX, startY);
	CGContextAddLineToPoint(c, endX, endY);
	CGContextStrokePath(c);
}

+(void)showAlertPopup:(NSString *)title message:(NSString *)message
{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
													message:message
												   delegate:nil
										  cancelButtonTitle:@"OK"
										  otherButtonTitles: nil];
    [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
//	[alert show];
}	

+(void)showAlertPopupWithDelegate:(NSString *)title message:(NSString *)message delegate:(id)delegate
{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
													message:message
												   delegate:delegate
										  cancelButtonTitle:@"OK"
										  otherButtonTitles: nil];
    [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
//	[alert show];
	//-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
}

+(void)showAlertPopupWithDelegateBG:(NSString *)title message:(NSString *)message delegate:(id)delegate
{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
													message:message
												   delegate:delegate
										  cancelButtonTitle:@"OK"
										  otherButtonTitles: nil];
    [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
	//-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
}

+(void)showConfirmationPopup:(NSString *)title message:(NSString *)message delegate:(id)delegate tag:(int)tag
{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
													message:message
												   delegate:delegate
										  cancelButtonTitle:@"Cancel"
										  otherButtonTitles: @"OK", nil];
	alert.tag = tag;
    [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
//	[alert show];
	//-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
}	

+(void)showAcceptDeclinePopup:(NSString *)title message:(NSString *)message delegate:(id)delegate
{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
													message:message
												   delegate:delegate
										  cancelButtonTitle:@"Decline"
										  otherButtonTitles: @"Accept", nil];
	
    [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
    //	[alert show];
	//-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
}	

+(void)showTwoButtonPopupWithTitle:(NSString *)title message:(NSString *)message button1:(NSString *)button1 button2:(NSString *)button2 delegate:(id)delegate
{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
													message:message
												   delegate:delegate
										  cancelButtonTitle:button1
										  otherButtonTitles: button2, nil];
	
    [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
    //	[alert show];
	//-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
}	

+(NSArray *)getContentsOfFlatFile:(NSString *)filename
{
	NSString *defaultPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:filename];
	NSFileHandle *fh = [NSFileHandle fileHandleForReadingAtPath:defaultPath];
	if(!fh)
		[ProjectFunctions showAlertPopup:@"File not Found!" message:[NSString stringWithFormat:@"File: %@ not found.", filename]];
	[fh closeFile];
	
	NSString *contents = [NSString stringWithContentsOfFile:defaultPath encoding:NSUTF8StringEncoding error:nil];
	NSArray *lines = [contents componentsSeparatedByString:@"\n"];
	return lines;
}
/*
+(void)executeThreadedJob:(NSString *)class:(SEL)aSelector:(UIActivityIndicatorView *)activityIndicator
{
	[activityIndicator startAnimating];
	[NSClassFromString(class) performSelectorInBackground:aSelector withObject:nil];
//	[NSClassFromString(class) performSelector:aSelector];
}
*/

+(void)updateNewvalueIfNeeded:(NSString *)value type:(NSString *)type mOC:(NSManagedObjectContext *)mOC
{
	if([value length]==0)
		return;
	
	NSString *entityname = nil;
	if([type isEqualToString:@"Game"])
		entityname = @"GAMETYPE";
	if([type isEqualToString:@"Limit"])
		entityname = @"LIMIT";
	if([type isEqualToString:@"Stakes"])
		entityname = @"STAKES";
	if([type isEqualToString:@"Location"])
		entityname = @"LOCATION";
	if([type isEqualToString:@"Bankroll"])
		entityname = @"BANKROLL";
	if([type isEqualToString:@"Type"])
		entityname = @"TYPE";
	if([type isEqualToString:@"Year"])
		entityname = @"YEAR";
	
	if(entityname==nil)
		return;
	
	NSArray *items = [CoreDataLib selectRowsFromTable:entityname mOC:mOC];
	BOOL newEntryFlg=YES;
	for (NSManagedObject *mo in items) {
		NSString *name = [mo valueForKey:@"name"];
		if([name isEqualToString:value])
			newEntryFlg=NO;
	}
	if(newEntryFlg)
		[CoreDataLib insertAttributeManagedObject:entityname valueList:[NSArray arrayWithObjects:value, nil] mOC:mOC];
}

+(BOOL)limitTextViewLength:(UITextView *)textViewLocal currentText:(NSString *)currentText string:(NSString *)string limit:(int)limit saveButton:(UIBarButtonItem *)saveButton resignOnReturn:(BOOL)resignOnReturn
{
	if([string isEqualToString:@"|"])
		return NO;
	if([string isEqualToString:@"`"])
		return NO;
	
	if(saveButton != nil) {
		if([string length]==0 && [currentText length]==1)
			saveButton.enabled = NO;
		else 
			saveButton.enabled = YES;
	}
	
	if(resignOnReturn && [string isEqualToString:@"\n"]) {
		[textViewLocal resignFirstResponder];
		return NO;
	}
	
	if( [string length]==0)
		return YES;
	
	if([textViewLocal.text length]>=limit)
		return NO;  //prevents change
	else {
		return YES;
	}
}

+(BOOL)limitTextFieldLength:(UITextField *)textViewLocal currentText:(NSString *)currentText string:(NSString *)string limit:(int)limit saveButton:(UIBarButtonItem *)saveButton resignOnReturn:(BOOL)resignOnReturn
{
//-(BOOL)textField:(UITextField *)textFieldlocal shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
	if([string isEqualToString:@"|"])
		return NO;
	if([string isEqualToString:@"`"])
		return NO;
	
	if(saveButton != nil) {
		if([string length]==0 && [currentText length]==1)
			saveButton.enabled = NO;
		else 
			saveButton.enabled = YES;
	}
	
	if(resignOnReturn && [string isEqualToString:@"\n"]) {
		[textViewLocal resignFirstResponder];
		return NO;
	}
	
	if( [string length]==0)
		return YES;
	
	if([textViewLocal.text length]>=limit)
		return NO;  //prevents change
	else {
		return YES;
	}
}

+(void)SetButtonAttributes:(UIButton *)button yearStr:(NSString *)yearStr enabled:(BOOL)enabled
{
	[button setTitle:yearStr forState:UIControlStateNormal];
	
	button.enabled=enabled;
	if([yearStr isEqualToString:@"0"]) {
		[button setTitle:@"-" forState:UIControlStateNormal];
		button.enabled=NO;
	}
}

+(void)resetTheYearSegmentBar:(UITableView *)tableView displayYear:(int)displayYear MoC:(NSManagedObjectContext *)MoC leftButton:(UIButton *)leftButton rightButton:(UIButton *)rightButton displayYearLabel:(UILabel *)displayYearLabel
{
    
    int prevYear = displayYear-1;
	int nextYear = displayYear+1;

    int minYear = [[ProjectFunctions getUserDefaultValue:@"minYear2"] intValue];
    NSString *maxYearStr = [ProjectFunctions getUserDefaultValue:@"maxYear"];

    int maxYear = [maxYearStr intValue];
    

    if(displayYear>0)
        [displayYearLabel performSelectorOnMainThread:@selector(setText: ) withObject:[NSString stringWithFormat:@"%d", displayYear] waitUntilDone:NO];
    
    if(displayYear==0) {
        if([displayYearLabel.text length]<=1)
            [displayYearLabel performSelectorOnMainThread:@selector(setText: ) withObject:@"LifeTime" waitUntilDone:NO];

		if(maxYear>0)
			[ProjectFunctions SetButtonAttributes:leftButton yearStr:maxYearStr enabled:YES];
		if(prevYear>0)
			[ProjectFunctions SetButtonAttributes:rightButton yearStr:@"0" enabled:YES];
		return;
	}
	
	
    if(prevYear>=minYear)
        [ProjectFunctions SetButtonAttributes:leftButton yearStr:[NSString stringWithFormat:@"%d", prevYear] enabled:YES];
    else
        [ProjectFunctions SetButtonAttributes:leftButton yearStr:@"-" enabled:NO];
 

	if(nextYear>maxYear)
		[ProjectFunctions SetButtonAttributes:rightButton yearStr:@"LifeTime" enabled:YES];
	else
		[ProjectFunctions SetButtonAttributes:rightButton yearStr:[NSString stringWithFormat:@"%d", nextYear] enabled:YES];
	
}

+(NSString *)labelForYearValue:(int)yearValue
{
	NSString *yearString = @"";
	if(yearValue==0)
		yearString = @"LifeTime";
	else
		yearString = [NSString stringWithFormat:@"%d", yearValue];
	return yearString;
}

+(NSString *)labelForGameSegment:(int)segmentIndex
{
	NSString *name=@"";
	if(segmentIndex==0) {
		name = @"All Game Types";
	}
	if(segmentIndex==1) {
		name = @"Cash";
	}
	if(segmentIndex==2) {
		name = @"Tournament";
	}
	return name;
}

+(int)selectedSegmentForGameType:(NSString *)gameType
{
	if([gameType isEqualToString:@"Cash"])
		return 1;
	else if([gameType isEqualToString:@"Tournament"])
		return 2;
	else
		return 0;
}

+(NSManagedObject *)insertRecordIntoEntity:(NSManagedObjectContext *)mOC EntityName:(NSString *)EntityName valueList:(NSArray *)valueList
{
	NSArray *keyList = [ProjectFunctions getColumnListForEntity:EntityName type:@"column"];
	NSArray *typeList = [ProjectFunctions getColumnListForEntity:EntityName type:@"type"];

	NSManagedObject *mo = [NSEntityDescription insertNewObjectForEntityForName:EntityName inManagedObjectContext:mOC];
	
	[CoreDataLib updateManagedObject:mo keyList:keyList valueList:valueList typeList:typeList mOC:mOC];
	return mo;
}

+(void)updateYourOwnFriendRecord:(NSManagedObjectContext *)MoC list:(NSMutableArray *)list
{
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"user_id = %d", 0];
	NSManagedObject *mo = nil;
	NSArray *items = [CoreDataLib selectRowsFromEntity:@"FRIEND" predicate:predicate sortColumn:nil mOC:MoC ascendingFlg:YES];
	
	NSMutableArray *selfList = [[NSMutableArray alloc] initWithArray:list];
	[selfList insertObject:[[NSDate date] convertDateToStringWithFormat:nil] atIndex:1];
	[selfList insertObject:[ProjectFunctions getUserDefaultValue:@"firstName"] atIndex:2];
	[selfList insertObject:@"Active" atIndex:3];
	[selfList insertObject:[ProjectFunctions getUserDefaultValue:@"userName"] atIndex:4];
	[selfList insertObject:@"" atIndex:5];
	[selfList insertObject:@"0" atIndex:6]; // user_id
	
	if([items count]==0) {
		[ProjectFunctions insertRecordIntoEntity:MoC EntityName:@"FRIEND" valueList:selfList];
	} else {
		mo = [items objectAtIndex:0];
		[CoreDataLib updateManagedObjectForEntity:mo entityName:@"FRIEND" valueList:selfList mOC:MoC];
	}
}

+(void)checkForFriendRecords:(NSManagedObjectContext *)MoC
{
	NSArray *nameList = [NSArray arrayWithObjects:@"Username", @"Password", nil];
	
	NSArray *valueList = [NSArray arrayWithObjects:[ProjectFunctions getUserDefaultValue:@"userName"], [ProjectFunctions getUserDefaultValue:@"password"], nil];
	NSString *webAddr = @"http://www.appdigity.com/poker/pokerCheckFriends.php";
	NSString *responseStr = [WebServicesFunctions getResponseFromServerUsingPost:webAddr fieldList:nameList valueList:valueList];
	NSArray *friends = [responseStr componentsSeparatedByString:@"\n"];
	for(NSString *friend in friends) {
		NSArray *fields = [friend componentsSeparatedByString:@"|"];
		int user_id = [[fields stringAtIndex:0] intValue];
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"user_id = %d", user_id];
		NSArray *items = [CoreDataLib selectRowsFromEntity:@"FRIEND" predicate:predicate sortColumn:nil mOC:MoC ascendingFlg:YES];
		if([items count]==0) {
			NSMutableArray *selfList = [[NSMutableArray alloc] init];
			[selfList addObject:[[NSDate date] convertDateToStringWithFormat:nil]];
			[selfList addObject:[[NSDate date] convertDateToStringWithFormat:nil]];
			[selfList addObject:[fields stringAtIndex:2]];
			[selfList addObject:@"Active"];
			[selfList addObject:[fields stringAtIndex:1]];
			[selfList addObject:@"Default"];
			[selfList addObject:[fields stringAtIndex:0]];
			[ProjectFunctions insertRecordIntoEntity:MoC EntityName:@"FRIEND" valueList:selfList];
		}
	}
}

+(NSString *)getLastestStatsForFriend:(NSManagedObjectContext *)MoC
{
	NSMutableArray *list = [[NSMutableArray alloc] init];
	NSString *version = [ProjectFunctions getProjectVersion];
	NSArray *fields = [ProjectFunctions getFieldListForVersion:version type:@"FRIEND"];
	for(NSString *field in fields)
		[list addObject:[CoreDataLib getGameStat:MoC dataField:field predicate:nil]];

	[list replaceObjectAtIndex:23 withObject:[CoreDataLib getGameStatWithLimit:MoC dataField:@"amountRisked" predicate:nil limit:10]];
	[list replaceObjectAtIndex:24 withObject:[CoreDataLib getGameStat:MoC dataField:@"amountRiskedThisYear" predicate:nil]];
	[list replaceObjectAtIndex:25 withObject:[CoreDataLib getGameStat:MoC dataField:@"amountRiskedThisMonth" predicate:nil]];
	[ProjectFunctions updateYourOwnFriendRecord:MoC list:list];
	[ProjectFunctions checkForFriendRecords:MoC];
	
	return [NSString stringWithFormat:@"%@\n%@\n%@", version, [list componentsJoinedByString:@"|"], [ProjectFunctions getLast5GamesForFriend:MoC]];
}


+(NSString *)getLast5GamesForFriend:(NSManagedObjectContext *)MoC
{
	NSArray *keyList = [ProjectFunctions getColumnListForEntity:@"GAME" type:@"column"];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"user_id = %d", 0];
	NSArray *items = [CoreDataLib selectRowsFromEntity:@"GAME" predicate:predicate sortColumn:@"startTime" mOC:MoC ascendingFlg:NO];
	NSMutableString *line = [NSMutableString stringWithCapacity:50000];
	
	int count = (int)[items count];
	if(count>10)
		count=10;
	
	for(int i=0; i<count; i++) {
		NSManagedObject *mo = [items objectAtIndex:i];
		for(NSString *key in keyList) {
			NSString *value = [mo valueForKey:key];
			if([key isEqualToString:@"startTime"] || [key isEqualToString:@"endTime"] || [key isEqualToString:@"gameDate"] || [key isEqualToString:@"created"]) {
				value = [[mo valueForKey:key] convertDateToStringWithFormat:nil];
			}
			[line appendFormat:@"%@%@", value, @"|"];
		}
		[line appendString:@"\n"];
	}
	return line;
}

+(UITableViewCell *)getGameCell:(NSManagedObject *)mo CellIdentifier:(NSString *)CellIdentifier tableView:(UITableView *)tableView evenFlg:(BOOL)evenFlg
{
	GameCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[GameCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
	}
	
	[GameCell populateCell:cell obj:mo evenFlg:evenFlg];

	
	


	return cell;
}

+(int)getSegmentValueForSegment:(int)segment currentValue:(NSString *)currentValue startGameScreen:(BOOL)startGameScreen
{
	NSArray *dtValues = [ProjectFunctions getArrayForSegment:segment];
	int i=0;
	int result=0;
	for(NSString *value in dtValues) {
		if([value isEqualToString:currentValue])
			result = i;
		i++;
	}
	
	if(startGameScreen && result==4)
		return 0; // make sure it doesn't auto skip to next screen
	if(startGameScreen && result==3 && (segment==0 || segment==2))
		return 0;
	
	return result;
}

+(void)initializeSegmentBar:(UISegmentedControl *)segmentBar defaultValue:(NSString *)defaultValue
{
	BOOL needsIt = YES;
	int numSegs = (int)[segmentBar numberOfSegments];
	for(int i=0; i<numSegs; i++) {
		if([defaultValue isEqualToString:[segmentBar titleForSegmentAtIndex:i]])
			needsIt = NO;
	}
	
	if(needsIt)
		[segmentBar setTitle:defaultValue forSegmentAtIndex:0];
}



+(void)insertFriendGames:(NSMutableArray *)components friend_id:(int)friend_id mOC:(NSManagedObjectContext *)mOC
{
	if([components count]<24 || friend_id==0)
		return;
	NSManagedObject *mo = [NSEntityDescription insertNewObjectForEntityForName:@"GAME" inManagedObjectContext:mOC];
	[components replaceObjectAtIndex:23 withObject:[NSString stringWithFormat:@"%d", friend_id]];
	[components removeLastObject];
	[ProjectFunctions updateGameInDatabase:mOC mo:mo valueList:components];
}

+(void)updateOrInsertThisFriend:(NSManagedObjectContext *)mOC line:(NSString *)line
{
	NSArray *components = [line componentsSeparatedByString:@"<li>"];
	if([components count]>3) {
		NSString *friend_id = [components stringAtIndex:0];
		NSString *email = [components stringAtIndex:1];
		NSString *name = [components stringAtIndex:2];
		NSString *status = [components stringAtIndex:3];
		NSString *data = [components stringAtIndex:4];
		
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"email = %@", email];
		NSManagedObject *mo = nil;
		NSArray *items = [CoreDataLib selectRowsFromEntity:@"FRIEND" predicate:predicate sortColumn:nil mOC:mOC ascendingFlg:YES];
		if([items count]==0) {
			NSArray *valueList = [NSArray arrayWithObjects: 
								  [[NSDate date] convertDateToStringWithFormat:nil], 
								  [[NSDate date] convertDateToStringWithFormat:nil], 
								  name, 
								  status, 
								  email, 
								  @"", 
								  friend_id, 
								  @"", 
								  @"", 
								  @"", 
								  @"", 
								  @"", 
								  @"", 
								  @"", 
								  @"", 
								  @"", 
								  @"", 
								  @"", 
								  @"", 
								  @"", 
								  @"", 
								  @"", 
								  nil];
			mo = [ProjectFunctions insertRecordIntoEntity:mOC EntityName:@"FRIEND" valueList:valueList];
		} else {
			mo = [items objectAtIndex:0];
		}
		
		if(mo != nil && [friend_id intValue]>0) {
			// delete old games
			NSPredicate *predicate = [NSPredicate predicateWithFormat:@"user_id = %@", friend_id];
			NSArray *friendGames = [CoreDataLib selectRowsFromEntity:@"GAME" predicate:predicate sortColumn:nil mOC:mOC ascendingFlg:YES];
			for(NSManagedObject *gameObject in friendGames)
				[mOC deleteObject:gameObject];
			
			NSArray *lines = [data componentsSeparatedByString:@"<br>"];
			int i=0;
			NSString *version = @"";
			for(NSString *line in lines) {
				if(i==0)
					version=line;
				NSMutableArray *valuesAmount = [NSMutableArray arrayWithArray:[line componentsSeparatedByString:@"|"]];
				if(i==1 && [valuesAmount count]>34) {
					// insert basic values
					if([version isEqualToString:@"Version 1.0"]) {
						NSLog(@"friend: [%@]", friend_id);
						NSArray *valueList = [NSArray arrayWithObjects:
											  [valuesAmount stringAtIndex:0], // last date
											  [[NSDate date] convertDateToStringWithFormat:nil], 
											  name, 
											  status, 
											  email, 
											  @"", 
											  friend_id, 
											  [valuesAmount stringAtIndex:1], 
											  [valuesAmount stringAtIndex:2], 
											  [valuesAmount stringAtIndex:3], 
											  [valuesAmount stringAtIndex:4], 
											  [valuesAmount stringAtIndex:5], 
											  [valuesAmount stringAtIndex:6], 
											  [valuesAmount stringAtIndex:7], 
											  [valuesAmount stringAtIndex:8], 
											  [valuesAmount stringAtIndex:9], 
											  [valuesAmount stringAtIndex:10], 
											  [valuesAmount stringAtIndex:11], 
											  [valuesAmount stringAtIndex:12], 
											  [valuesAmount stringAtIndex:13], 
											  [valuesAmount stringAtIndex:14], 
											  [valuesAmount stringAtIndex:15], 
											  [valuesAmount stringAtIndex:16], 
											  [valuesAmount stringAtIndex:17], 
											  [valuesAmount stringAtIndex:18], 
											  [valuesAmount stringAtIndex:19], 
											  [valuesAmount stringAtIndex:20], 
											  [valuesAmount stringAtIndex:21], 
											  [valuesAmount stringAtIndex:22], 
											  [valuesAmount stringAtIndex:23], 
											  [valuesAmount stringAtIndex:24], 
											  [valuesAmount stringAtIndex:25], 
											  [valuesAmount stringAtIndex:26], 
											  [valuesAmount stringAtIndex:27], 
											  [valuesAmount stringAtIndex:28], 
											  [valuesAmount stringAtIndex:29], 
											  [valuesAmount stringAtIndex:30], 
											  [valuesAmount stringAtIndex:31], 
											  [valuesAmount stringAtIndex:32], 
											  [valuesAmount stringAtIndex:33], 
											  [valuesAmount stringAtIndex:34], 
											  nil];
						[CoreDataLib updateManagedObjectForEntity:mo entityName:@"FRIEND" valueList:valueList mOC:mOC];
					}
				} else {
					// insert games
					[ProjectFunctions insertFriendGames:valuesAmount friend_id:[friend_id intValue] mOC:mOC];
				}
				
				i++;
			}
		}
		
		[mOC save:nil];
	
	}
}

+(void)updateOrInsertThisMessage:(NSManagedObjectContext *)mOC line:(NSString *)line
{
	NSArray *components = [line componentsSeparatedByString:@"|"];
	NSManagedObject *mo = [NSEntityDescription insertNewObjectForEntityForName:@"MESSAGE" inManagedObjectContext:mOC];
	[CoreDataLib updateManagedObjectForEntity:mo entityName:@"MESSAGE" valueList:components mOC:mOC];
}

+(int)updateFriendRecords:(NSManagedObjectContext *)mOC responseStr:(NSString *)responseStr delegate:(id)delegate refreshDateLabel:(UILabel *)refreshDateLabel
{
	NSString *syncDate = [[NSDate date] convertDateToStringWithFormat:nil];
	NSArray *lines = [responseStr componentsSeparatedByString:@"<hr>"];
	int i=0;
	NSString *type = @"None";
	int friendRecords=0;
	int messages=0;
	for(NSString *line in lines) {
		
		if([type isEqualToString:@"-----FRIEND"] && [line length]>15) {
			[ProjectFunctions updateOrInsertThisFriend:mOC line:line];
			friendRecords++;
		}
		
		if([type isEqualToString:@"-----MESSAGE"] && [line length]>15) {
			[ProjectFunctions updateOrInsertThisMessage:mOC line:line];
			messages++;
		}
		
		if([line isEqualToString:@"-----FRIEND"] || [line isEqualToString:@"-----MESSAGE"])
			type = line;
		i++;
	}
	[ProjectFunctions setUserDefaultValue:[ProjectFunctions getUserDefaultValue:@"lastSyncedDate"] forKey:@"prevSyncedDate"];
	[ProjectFunctions setUserDefaultValue:syncDate forKey:@"lastSyncedDate"];
	if(refreshDateLabel != nil)
		refreshDateLabel.text = syncDate;
	if(0 && (id)delegate != nil) {
		if(friendRecords==0 && messages==0)
			[ProjectFunctions showAlertPopupWithDelegate:@"Success" message:@"Server data synced" delegate:(id)delegate];
		else if(friendRecords>0)
			[ProjectFunctions showAlertPopupWithDelegate:@"Success" message:@"Server data synced. You have an update to your firend's games" delegate:(id)delegate];
		else 
			[ProjectFunctions showAlertPopupWithDelegate:@"Success" message:@"Server data synced. You have a new mail message" delegate:(id)delegate];
	}
	return friendRecords;
}

+(NSString *)pullGameString:(NSManagedObjectContext *)mOC mo:(NSManagedObject *)mo {
    return [NSString stringWithFormat:@"%@|%@|%@|%@|%@|%@|%@|%@|%@|%@|%@|%@|%@|%@|%d|%d",
                [[mo valueForKey:@"startTime"] convertDateToStringWithFormat:nil],
                [mo valueForKey:@"buyInAmount"],
                [mo valueForKey:@"rebuyAmount"],
                [mo valueForKey:@"cashoutAmount"],
            [mo valueForKey:@"location"],
            [mo valueForKey:@"minutes"],
            [mo valueForKey:@"Type"],
                ([[mo valueForKey:@"status"] isEqualToString:@"In Progress"])?@"Y":@"N",
            [mo valueForKey:@"gametype"],
            [mo valueForKey:@"stakes"],
            [mo valueForKey:@"limit"],
            [[NSDate date] convertDateToStringWithFormat:nil],
            [[mo valueForKey:@"endTime"] convertDateToStringWithFormat:nil],
            [ProjectFunctions getMoneySymbol],
            [[ProjectFunctions getUserDefaultValue:@"latestPos"] intValue],
            [[mo valueForKey:@"foodDrinks"] intValue]
            ];
  
}

+(NSString *)getLast90Days:(NSManagedObjectContext *)mOC
{
    NSMutableString *last90Str = [[NSMutableString alloc] initWithCapacity:1000];
    NSDate *startDate = [[NSDate date] dateByAddingTimeInterval:-1*60*60*24*90];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"startTime >= %@", startDate];
    NSArray *games = [CoreDataLib selectRowsFromEntity:@"GAME" predicate:predicate sortColumn:@"startTime" mOC:mOC ascendingFlg:YES];
    for(NSManagedObject *game in games)
        [last90Str appendString:[NSString stringWithFormat:@"%@|%d:", [[game valueForKey:@"startTime"] convertDateToStringWithFormat:@"MM/dd/yyyy"], [[game valueForKey:@"winnings"] intValue]]];
    return last90Str;
}

+(BOOL)uploadUniverseStats:(NSManagedObjectContext *)mOC
{
	// Step 1: Upload your stats to the server
	if([[ProjectFunctions getUserDefaultValue:@"userName"] length]==0)
		return NO;
	if([[ProjectFunctions getUserDefaultValue:@"password"] length]==0)
		return NO;

    
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"user_id = %d ", 0];
    NSArray *games = [CoreDataLib selectRowsFromEntity:@"GAME" predicate:predicate sortColumn:@"startTime" mOC:mOC ascendingFlg:NO];
    NSString *dateText = @"";
    NSString *yearText = @"";
    NSString *lastGame = nil;
    NSString *playFlg = nil;
    
    if([games count]>0) {
        NSManagedObject *mo = [games objectAtIndex:0];
        lastGame = [ProjectFunctions pullGameString:mOC mo:mo];
        NSString *status = [mo valueForKey:@"status"];
        playFlg = ([status isEqualToString:@"In Progress"])?@"Y":@"N";
    }
    dateText = [[NSDate date] convertDateToStringWithFormat:@"MMM yyyy"];
    yearText = [[NSDate date] convertDateToStringWithFormat:@"yyyy"];
    
    //----------last10Stats--------
	NSPredicate *predicateLast10 = [NSPredicate predicateWithFormat:@"user_id = %d AND status = 'Completed'", 0];
    NSString *last10Stats = [CoreDataLib getGameStatWithLimit:mOC dataField:@"totalStatsL10" predicate:predicateLast10 limit:10];

    
    //----------yearStats--------
    NSPredicate *predicateYear = [NSPredicate predicateWithFormat:@"user_id = %d AND year = %@ AND status = 'Completed'", 0, [[NSDate date] convertDateToStringWithFormat:@"yyyy"]];
    NSString *yearStats = [CoreDataLib getGameStat:mOC dataField:@"totalStats" predicate:predicateYear];

    //----------monthStats--------
    NSMutableString *thisMonthStr = [[NSMutableString alloc] initWithCapacity:1000];
    NSPredicate *predicateMonth = [NSPredicate predicateWithFormat:@"user_id = %d AND year = %@ AND month = %@ AND status = 'Completed'", 0, [[NSDate date] convertDateToStringWithFormat:@"yyyy"], [[NSDate date] convertDateToStringWithFormat:@"MMMM"]];
    NSString *monthStats = [CoreDataLib getGameStat:mOC dataField:@"totalStats" predicate:predicateMonth];
    NSArray *monthGames = [CoreDataLib selectRowsFromEntity:@"GAME" predicate:predicateMonth sortColumn:@"startTime" mOC:mOC ascendingFlg:YES];
    for(NSManagedObject *mo in monthGames)
        [thisMonthStr appendString:[NSString stringWithFormat:@"%@|%d:", [[mo valueForKey:@"startTime"] convertDateToStringWithFormat:@"MM/dd/yyyy"], [[mo valueForKey:@"winnings"] intValue]]];
    
    //----------last10 Games--------
    NSArray *last10 = [CoreDataLib selectRowsFromEntityWithLimit:@"GAME" predicate:predicateLast10 sortColumn:@"startTime" mOC:mOC ascendingFlg:NO limit:10];
    NSMutableArray *last10Reverse = [[NSMutableArray alloc] initWithCapacity:10];
    NSString *last10String = @"";
    for(NSManagedObject *mo in last10) {
        last10String = [NSString stringWithFormat:@"%@[li]%@", last10String, [ProjectFunctions pullGameString:mOC mo:mo]];
        [last10Reverse addObject:[NSString stringWithFormat:@"%@|%d", [[mo valueForKey:@"startTime"] convertDateToStringWithFormat:@"MM/dd/yyyy"], [[mo valueForKey:@"winnings"] intValue]]];
    }


    NSString *last90Days = [ProjectFunctions getLast90Days:mOC];
    last10Reverse = [NSMutableArray arrayWithArray:[self reverseArray:last10Reverse]];

    NSString *dataUpload = [NSString stringWithFormat:@"Last10|%@[xx]%@|%@[xx]%@|%@[xx]%@[xx]%@[xx]%@|%@|%@[xx]%@[xx]%@[xx]%@",
                            last10Stats, 
                            dateText, monthStats, 
                            yearText, yearStats, 
                            lastGame, 
                            last10String, playFlg,
                            [ProjectFunctions getProjectDisplayVersion], [ProjectFunctions getMoneySymbol],
                            last90Days, thisMonthStr, [last10Reverse componentsJoinedByString:@":"]];

    NSLog(@"Sending Universe tracker Stats...");

	NSArray *nameList = [NSArray arrayWithObjects:@"Username", @"Password", @"LastUpd", @"Data", @"dateText", nil];
	NSDate *lastUpd = [[ProjectFunctions getUserDefaultValue:@"lastSyncedDate"] convertStringToDateFinalSolution];
	NSString *lastUpdDate = [lastUpd convertDateToStringWithFormat:@"MM/dd/yyyy HH:mm:ss"];


    NSArray *valueList = [NSArray arrayWithObjects:[ProjectFunctions getUserDefaultValue:@"userName"], [ProjectFunctions getUserDefaultValue:@"password"], lastUpdDate, dataUpload, dateText, nil];
	NSString *webAddr = @"http://www.appdigity.com/poker/pokerUploadUniverseStats.php";
	NSString *responseStr = [WebServicesFunctions getResponseFromServerUsingPost:webAddr fieldList:nameList valueList:valueList];
	NSLog(@"+++responseStr: %@", responseStr);
    if([responseStr isEqualToString:@"Success"])
        return YES;
    else
        return NO;
}

+(NSArray *)reverseArray:(NSArray *)array
{
    NSMutableArray *reverseArray = [[NSMutableArray alloc] initWithCapacity:[array count]];
    for(int i=(int)[array count]-1; i>=0; i--)
        [reverseArray addObject:[array objectAtIndex:i]];
    return reverseArray;
}

+(int)countFriendsPlaying {
 	NSArray *nameList = [NSArray arrayWithObjects:@"Username", @"Password", nil];
	NSString *userName = @"x";
	NSString *password = @"x";
	if([ProjectFunctions getUserDefaultValue:@"userName"])
		userName = [ProjectFunctions getUserDefaultValue:@"userName"];
	if([ProjectFunctions getUserDefaultValue:@"password"])
		password = [ProjectFunctions getUserDefaultValue:@"password"];
    NSArray *valueList = [NSArray arrayWithObjects:userName, password, nil];
	NSString *webAddr = @"http://www.appdigity.com/poker/pokerCheckFriendsPlaying.php";
	NSString *responseStr = [WebServicesFunctions getResponseFromServerUsingPost:webAddr fieldList:nameList valueList:valueList];
    //    NSLog(@"responseStr: %@", responseStr);
    return [responseStr intValue];
}

+(NSString *)getFriendsPlayingData {
    NSLog(@"Getting friend data...");
 	NSArray *nameList = [NSArray arrayWithObjects:@"Username", @"Password", nil];
	NSString *userName = @"x";
	NSString *password = @"x";
	if([ProjectFunctions getUserDefaultValue:@"userName"])
		userName = [ProjectFunctions getUserDefaultValue:@"userName"];
	if([ProjectFunctions getUserDefaultValue:@"password"])
		password = [ProjectFunctions getUserDefaultValue:@"password"];
    NSArray *valueList = [NSArray arrayWithObjects:userName, password, nil];
	NSString *webAddr = @"http://www.appdigity.com/poker/pokergetFriendsPlayingData.php";
	NSString *responseStr = [WebServicesFunctions getResponseFromServerUsingPost:webAddr fieldList:nameList valueList:valueList];
    return responseStr;
}


+(BOOL)syncDataWithServer:(NSManagedObjectContext *)mOC delegate:(id)delegate refreshDateLabel:(UILabel *)refreshDateLabel
{
	// Step 1: Upload your stats to the server
	if([[ProjectFunctions getUserDefaultValue:@"userName"] length]==0)
		return NO;
	if([[ProjectFunctions getUserDefaultValue:@"password"] length]==0)
		return NO;
	
	NSString *dataUpload = [ProjectFunctions getLastestStatsForFriend:mOC];
	NSArray *nameList = [NSArray arrayWithObjects:@"Username", @"Password", @"LastUpd", @"Data", @"dateText", nil];
	NSDate *lastUpd = [[ProjectFunctions getUserDefaultValue:@"lastSyncedDate"] convertStringToDateWithFormat:nil];
	NSString *lastUpdDate = [lastUpd convertDateToStringWithFormat:@"MM/dd/yyyy HH:mm:ss"];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"user_id = %d", 0];
	NSArray *items = [CoreDataLib selectRowsFromEntity:@"GAME" predicate:predicate sortColumn:@"startTime" mOC:mOC ascendingFlg:NO];
    NSString *dateText = @"";
    if([items count]>0) {
        NSManagedObject *lastGame = [items objectAtIndex:0];
        NSDate *startDate = [lastGame valueForKey:@"startTime"];
        dateText = [startDate convertDateToStringWithFormat:@"yyyyMM"];
        NSLog(@"dateText: %@", dateText);
    }

	
	NSArray *valueList = [NSArray arrayWithObjects:[ProjectFunctions getUserDefaultValue:@"userName"], [ProjectFunctions getUserDefaultValue:@"password"], lastUpdDate, dataUpload, dateText, nil];
	NSString *webAddr = @"http://www.appdigity.com/poker/pokerSyncData.php";
	NSString *responseStr = [WebServicesFunctions getResponseFromServerUsingPost:webAddr fieldList:nameList valueList:valueList];
	
	if([WebServicesFunctions validateStandardResponse:responseStr delegate:(id)delegate]) {
		// Step 2: Based on the response, update the data on the phone to match the server.
		[ProjectFunctions updateFriendRecords:mOC responseStr:responseStr delegate:delegate refreshDateLabel:refreshDateLabel];
		return YES;
		
	} // Success
	return NO;
}

+(NSString *)formatForDataBase:(NSString *)str
{
	str = [str stringByReplacingOccurrencesOfString:@"'" withString:@"\\'"];
	str = [str stringByReplacingOccurrencesOfString:@"`" withString:@"\\'"];
	return [str stringByReplacingOccurrencesOfString:@"\"" withString:@"\\'"];
}

+(NSString *)getDayTimeFromDate:(NSDate *)localDate
{
	int hour = [[localDate convertDateToStringWithFormat:@"H"] intValue];
	if(hour>=0 && hour < 12)
		return @"Morning";
	else if(hour>=12 && hour < 16)
		return @"Afternoon";
	else if(hour>=16 && hour < 20)
		return @"Evening";
	else 
		return @"Night";
	
}

+(float)getMoneyValueFromText:(NSString *)money 
{
	money = [money stringByReplacingOccurrencesOfString:[ProjectFunctions getMoneySymbol] withString:@""];
	money = [money stringByReplacingOccurrencesOfString:@"," withString:@""];
	return [money floatValue];
}

+(CGContextRef)contextRefForGraphofWidth:(int)totalWidth totalHeight:(int)totalHeight {
	UIGraphicsBeginImageContext(CGSizeMake(totalWidth,totalHeight));
	CGContextRef c = UIGraphicsGetCurrentContext();
	UIGraphicsPushContext(c); // <--
	CGContextSetLineCap(c, kCGLineCapRound);
	
	// draw Box---------------------
	CGContextSetLineWidth(c, 1);
	CGContextSetRGBStrokeColor(c, 0, 0, 0, 1); // blank
	CGContextSetRGBFillColor(c, 1, 1, 1, 1); // white
	CGContextFillRect(c, CGRectMake(0, 0, totalWidth, totalHeight));
	CGContextStrokeRect(c, CGRectMake(0, 0, totalWidth, totalHeight));
	
	return c;
}

+(int)drawZeroLineForContext:(CGContextRef)c min:(float)min max:(float)max bottomEdgeOfChart:(int)bottomEdgeOfChart leftEdgeOfChart:(int)leftEdgeOfChart totalWidth:(int)totalWidth
{
	UIBezierPath *aPath3 = [UIBezierPath bezierPath];
	[aPath3 moveToPoint:CGPointMake(leftEdgeOfChart, 0)];
	[aPath3 addLineToPoint:CGPointMake(totalWidth, 0)];
	[aPath3 addLineToPoint:CGPointMake(totalWidth, bottomEdgeOfChart)];
	[aPath3 addLineToPoint:CGPointMake(leftEdgeOfChart, bottomEdgeOfChart)];
	[aPath3 addLineToPoint:CGPointMake(leftEdgeOfChart, 0)];
	[aPath3 closePath];
	[self addGradientToPath:aPath3 context:c color1:[UIColor whiteColor] color2:(UIColor *)[UIColor yellowColor] lineWidth:(int)1 imgWidth:totalWidth imgHeight:bottomEdgeOfChart];

	// draw zero line---------------
	CGContextSetRGBStrokeColor(c, 0.6, 0.2, 0.2, 1); // lightGray
	CGContextSetLineWidth(c, 2);
	//	int zeroLoc = max*yMultiplier-10;
	//	float percentOfScreen = max/(max-min);
	int zeroLoc = 0;
	if((max-min)>0)
		zeroLoc = bottomEdgeOfChart*max/(max-min);
	if(zeroLoc<bottomEdgeOfChart)
		[self drawLine:c startX:leftEdgeOfChart startY:zeroLoc endX:totalWidth endY:zeroLoc];

	// Draw horizontal and vertical baselines
	CGContextSetRGBStrokeColor(c, 0, 0, 0, 1); // black
	[self drawLine:c startX:leftEdgeOfChart startY:bottomEdgeOfChart endX:totalWidth endY:bottomEdgeOfChart];
	[self drawLine:c startX:leftEdgeOfChart startY:0 endX:leftEdgeOfChart endY:bottomEdgeOfChart];

	return zeroLoc;
}

+(void)drawBottomLabelsForArray:(NSArray *)labels c:(CGContextRef)c bottomEdgeOfChart:(int)bottomEdgeOfChart leftEdgeOfChart:(int)leftEdgeOfChart totalWidth:(int)totalWidth
{
	int spacing = totalWidth/(labels.count+1);
	int XCord = leftEdgeOfChart+spacing/2-10;
	CGContextSetRGBFillColor(c, 0, 0, 0, 1); // black
	for(NSString *label in labels) {
		NSString *labelStr = label;
		if(labels.count>4 && label.length>4) {
			if(labels.count<10)
				labelStr = [NSString stringWithFormat:@"  %@", [label substringToIndex:3]];
			else
				labelStr = [label substringToIndex:3];
		}
		
		[labelStr drawAtPoint:CGPointMake(XCord+spacing/10, bottomEdgeOfChart+2) withFont:[UIFont fontWithName:@"Helvetica" size:18]];
		XCord+=spacing;
	}
}

+(void)drawBarChartForContext:(CGContextRef)c itemArray:(NSArray *)itemArray leftEdgeOfChart:(int)leftEdgeOfChart mainGoal:(int)mainGoal zeroLoc:(int)zeroLoc yMultiplier:(float)yMultiplier totalWidth:(int)totalWidth
{
	int spacing = totalWidth/(itemArray.count+1);
	int XCord = leftEdgeOfChart+spacing/2-10;
	for(NSString *item in itemArray) {
		float value = [item floatValue];
		
		UIColor *mainColor = [UIColor colorWithRed:1 green:0 blue:0 alpha:1];
		UIColor *topColor = [UIColor colorWithRed:.5 green:0 blue:0 alpha:1];
		UIColor *sideColor = [UIColor colorWithRed:1 green:.8 blue:.8 alpha:1];
		
		if(value>=0) {
			if(value>=mainGoal) { // green
				mainColor = [UIColor colorWithRed:0 green:.8 blue:0 alpha:1];
				topColor = [UIColor colorWithRed:0 green:.5 blue:0 alpha:1];
				sideColor = [UIColor colorWithRed:.7 green:1 blue:.7 alpha:1];
			} else { // blue
				mainColor = [UIColor colorWithRed:0 green:.5 blue:1 alpha:1];
				topColor = [UIColor colorWithRed:0 green:0 blue:.5 alpha:1];
				sideColor = [UIColor colorWithRed:.5 green:.8 blue:1 alpha:1];
			}
		}
		
		
		int top = zeroLoc-value*yMultiplier;
		int bot = zeroLoc;
		if(value<0) {
			bot = top;
			top = zeroLoc;
		}
		
		if(value != 0) {
			int width=(totalWidth/(itemArray.count+2))-10;
			UIBezierPath *aPath = [UIBezierPath bezierPath];
			[aPath moveToPoint:CGPointMake(XCord, bot)];
			[aPath addLineToPoint:CGPointMake(XCord, top)];
			[aPath addLineToPoint:CGPointMake(XCord+width, top)];
			[aPath addLineToPoint:CGPointMake(XCord+width, bot)];
			[aPath addLineToPoint:CGPointMake(XCord, bot)];
			[aPath closePath];
			[self addGradientToPath:aPath context:c color1:[UIColor whiteColor] color2:(UIColor *)mainColor lineWidth:(int)1 imgWidth:XCord+width imgHeight:300];
			
			UIBezierPath *aPath2 = [UIBezierPath bezierPath];
			[aPath2 moveToPoint:CGPointMake(XCord, top)];
			[aPath2 addLineToPoint:CGPointMake(XCord+10, top-10)];
			[aPath2 addLineToPoint:CGPointMake(XCord+10+width, top-10)];
			[aPath2 addLineToPoint:CGPointMake(XCord+width, top)];
			[aPath2 addLineToPoint:CGPointMake(XCord, top)];
			[aPath2 closePath];
			[self addGradientToPath:aPath2 context:c color1:[UIColor whiteColor] color2:(UIColor *)topColor lineWidth:(int)1 imgWidth:XCord+width imgHeight:300];

			UIBezierPath *aPath3 = [UIBezierPath bezierPath];
			[aPath3 moveToPoint:CGPointMake(XCord+width, top)];
			[aPath3 addLineToPoint:CGPointMake(XCord+width+10, top-10)];
			[aPath3 addLineToPoint:CGPointMake(XCord+10+width, bot-10)];
			[aPath3 addLineToPoint:CGPointMake(XCord+width, bot)];
			[aPath3 addLineToPoint:CGPointMake(XCord+width, bot)];
			[aPath3 closePath];
			[self addGradientToPath:aPath3 context:c color1:[UIColor whiteColor] color2:(UIColor *)sideColor lineWidth:(int)1 imgWidth:XCord+width imgHeight:300];

		}
		XCord+=spacing;
	}
}

+(UIImage *)graphGoalsChart:(NSManagedObjectContext *)mOC yearStr:(NSString *)yearStr chartNum:(int)chartNum goalFlg:(BOOL)goalFlg
{
	int totalWidth=640;
	int totalHeight=300;
	int leftEdgeOfChart=50;
	int bottomEdgeOfChart=totalHeight-25;
	
	int mainGoal=0;
	if(goalFlg)
		mainGoal = (chartNum==1)?[[ProjectFunctions getUserDefaultValue:@"profitGoal"] intValue]:[[ProjectFunctions getUserDefaultValue:@"hourlyGoal"] intValue];
	
	
	int displayYear = [yearStr intValue];
	NSMutableArray *itemList = [[NSMutableArray alloc] init];
	NSString *basicPred = [ProjectFunctions getBasicPredicateString:displayYear type:@"All"];
	NSArray *months = [NSArray arrayWithObjects:@"January", @"February", @"March", @"April", @"May", @"June", @"July", @"August", @"September", @"October", @"November", @"December", nil];
	int min=0;
	int max=0;
	for(NSString *month in months) {
		NSString *predString = [NSString stringWithFormat:@"%@ AND month = '%@'", basicPred, month];
		NSPredicate *predicate = [NSPredicate predicateWithFormat:predString];
		
		
		NSString *chart1 = [CoreDataLib getGameStat:mOC dataField:@"chart1" predicate:predicate];
		NSArray *values = [chart1 componentsSeparatedByString:@"|"];
		int winnings = [[values stringAtIndex:0] intValue];
		int minutes = [[values stringAtIndex:2] intValue];
		
		int hours = minutes/60;
		int hourlyRate = 0;
		if(hours>0)
			hourlyRate = winnings/hours;
		float amount = (chartNum==1)?winnings:hourlyRate;
		
		if(amount>max)
			max=amount;
		if(amount<min)
			min=amount;
		[itemList addObject:[NSString stringWithFormat:@"%f", amount]];
	}
	max*=1.1;
	int totalMoneyRange = max-min;
	
	float yMultiplier = 1;
	if(totalMoneyRange>0)
		yMultiplier = (float)bottomEdgeOfChart/totalMoneyRange;
	
	
	UIImage *dynamicChartImage = [[UIImage alloc] init];
	
	CGContextRef c = [self contextRefForGraphofWidth:totalWidth totalHeight:totalHeight];
	
	int zeroLoc = [self drawZeroLineForContext:c min:min max:max bottomEdgeOfChart:bottomEdgeOfChart leftEdgeOfChart:leftEdgeOfChart totalWidth:totalWidth];
	
	[self drawLeftLabelsAndLinesForContext:c totalMoneyRange:totalMoneyRange min:min leftEdgeOfChart:leftEdgeOfChart totalHeight:totalHeight totalWidth:totalWidth];
	
	[self drawBottomLabelsForArray:months c:c bottomEdgeOfChart:bottomEdgeOfChart leftEdgeOfChart:leftEdgeOfChart totalWidth:totalWidth];
	
	
	[self drawBarChartForContext:c itemArray:itemList leftEdgeOfChart:leftEdgeOfChart mainGoal:mainGoal zeroLoc:zeroLoc yMultiplier:yMultiplier totalWidth:totalWidth];
	
	//Draw goal line
	int goalHeight = zeroLoc-mainGoal*yMultiplier;
	CGContextSetLineWidth(c, 4);
	CGContextSetRGBStrokeColor(c, 0, .8, 1, 1); // black
	if(goalFlg)
		[self drawLine:c startX:leftEdgeOfChart startY:goalHeight endX:totalWidth endY:goalHeight];
	
	UIGraphicsPopContext();
	dynamicChartImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return dynamicChartImage;
	
}

+(UIImage *)graphDaysChart:(NSManagedObjectContext *)mOC yearStr:(NSString *)yearStr chartNum:(int)chartNum goalFlg:(BOOL)goalFlg
{
	int totalWidth=640;
	int totalHeight=300;
	int leftEdgeOfChart=50;
	int bottomEdgeOfChart=totalHeight-25;
	
	int displayYear = [yearStr intValue];
	NSMutableArray *profitList = [[NSMutableArray alloc] init];
	NSString *basicPred = [ProjectFunctions getBasicPredicateString:displayYear type:@"All"];
	NSArray *months = [NSArray arrayWithObjects:@"Monday", @"Tuesday", @"Wednesday", @"Thursday", @"Friday", @"Saturday", @"Sunday", nil];
	int min=0;
	int max=0;
	for(NSString *month in months) {
		NSString *predString = [NSString stringWithFormat:@"%@ AND weekday = '%@'", basicPred, month];
		NSPredicate *predicate = [NSPredicate predicateWithFormat:predString];
		int winnings = [[CoreDataLib getGameStat:mOC dataField:@"winnings" predicate:predicate] intValue];
		int minutes = [[CoreDataLib getGameStat:mOC dataField:@"minutes" predicate:predicate] intValue];
		int hours = minutes/60;
		int hourlyRate = 0;
		if(hours>0)
			hourlyRate = winnings/hours;
		float amount = (chartNum==1)?winnings:hourlyRate;
		
		if(amount>max)
			max=amount;
		if(amount<min)
			min=amount;
		[profitList addObject:[NSString stringWithFormat:@"%f", amount]];
	}
	max*=1.1;
	int totalMoneyRange = max-min;
	
	float yMultiplier = 1;
	if(totalMoneyRange>0)
		yMultiplier = (float)bottomEdgeOfChart/totalMoneyRange;
	
	
	UIImage *dynamicChartImage = [[UIImage alloc] init];

	CGContextRef c = [self contextRefForGraphofWidth:totalWidth totalHeight:totalHeight];
	
	int zeroLoc = [self drawZeroLineForContext:c min:min max:max bottomEdgeOfChart:bottomEdgeOfChart leftEdgeOfChart:leftEdgeOfChart totalWidth:totalWidth];
	
	[self drawLeftLabelsAndLinesForContext:c totalMoneyRange:totalMoneyRange min:min leftEdgeOfChart:leftEdgeOfChart totalHeight:totalHeight totalWidth:totalWidth];
	
	[self drawBottomLabelsForArray:months c:c bottomEdgeOfChart:bottomEdgeOfChart leftEdgeOfChart:leftEdgeOfChart totalWidth:totalWidth];

	[self drawBarChartForContext:c itemArray:profitList leftEdgeOfChart:leftEdgeOfChart mainGoal:0 zeroLoc:zeroLoc yMultiplier:yMultiplier totalWidth:totalWidth];

	
	UIGraphicsPopContext();
	dynamicChartImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return dynamicChartImage;
	
}

+(UIImage *)graphDaytimeChart:(NSManagedObjectContext *)mOC yearStr:(NSString *)yearStr chartNum:(int)chartNum goalFlg:(BOOL)goalFlg
{
	int totalWidth=640;
	int totalHeight=300;
	int leftEdgeOfChart=50;
	int bottomEdgeOfChart=totalHeight-25;
	
	int displayYear = [yearStr intValue];
	NSMutableArray *profitList = [[NSMutableArray alloc] init];
	NSString *basicPred = [ProjectFunctions getBasicPredicateString:displayYear type:@"All"];
	NSArray *months = [NSArray arrayWithObjects:@"Morning", @"Afternoon", @"Evening", @"Night", nil];
	int min=0;
	int max=0;
	for(NSString *month in months) {
		NSString *predString = [NSString stringWithFormat:@"%@ AND daytime = '%@'", basicPred, month];
		NSPredicate *predicate = [NSPredicate predicateWithFormat:predString];
		int winnings = [[CoreDataLib getGameStat:mOC dataField:@"winnings" predicate:predicate] intValue];
		int minutes = [[CoreDataLib getGameStat:mOC dataField:@"minutes" predicate:predicate] intValue];
		int hours = minutes/60;
		int hourlyRate = 0;
		if(hours>0)
			hourlyRate = winnings/hours;

		float amount = (chartNum==1)?winnings:hourlyRate;

		if(amount>max)
			max=amount;
		if(amount<min)
			min=amount;
		
		[profitList addObject:[NSString stringWithFormat:@"%f", amount]];
	}
	max*=1.1;
	int totalMoneyRange = max-min;
	
	float yMultiplier = 1;
	if(totalMoneyRange>0)
		yMultiplier = (float)bottomEdgeOfChart/totalMoneyRange;
	
	UIImage *dynamicChartImage = [[UIImage alloc] init];
	
	CGContextRef c = [self contextRefForGraphofWidth:totalWidth totalHeight:totalHeight];
	
	int zeroLoc = [self drawZeroLineForContext:c min:min max:max bottomEdgeOfChart:bottomEdgeOfChart leftEdgeOfChart:leftEdgeOfChart totalWidth:totalWidth];
	
	[self drawLeftLabelsAndLinesForContext:c totalMoneyRange:totalMoneyRange min:min leftEdgeOfChart:leftEdgeOfChart totalHeight:totalHeight totalWidth:totalWidth];
	
	[self drawBottomLabelsForArray:months c:c bottomEdgeOfChart:bottomEdgeOfChart leftEdgeOfChart:leftEdgeOfChart totalWidth:totalWidth];
	
	[self drawBarChartForContext:c itemArray:profitList leftEdgeOfChart:leftEdgeOfChart mainGoal:0 zeroLoc:zeroLoc yMultiplier:yMultiplier totalWidth:totalWidth];

	
	UIGraphicsPopContext();
	dynamicChartImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return dynamicChartImage;
	
}

+(UIImage *)graphYearlyChart:(NSManagedObjectContext *)mOC yearStr:(NSString *)yearStr chartNum:(int)chartNum goalFlg:(BOOL)goalFlg
{
	
	int totalWidth=640;
	int totalHeight=300;
	int leftEdgeOfChart=50;
	int bottomEdgeOfChart=totalHeight-25;
	
//	int displayYear = [yearStr intValue];
	NSMutableArray *profitList = [[NSMutableArray alloc] init];
	NSString *basicPred = [ProjectFunctions getBasicPredicateString:0 type:@"All"];
	NSMutableArray *months = [[NSMutableArray alloc] init];
	
	NSArray *items = [CoreDataLib selectRowsFromEntity:@"GAME" predicate:nil sortColumn:@"startTime" mOC:mOC ascendingFlg:YES];
	int endYear = [[[NSDate date] convertDateToStringWithFormat:@"yyyy"] intValue];
	int startYear = endYear;
	if([items count]>1) {
		NSManagedObject *mo1 = [items objectAtIndex:0];
		startYear = [[mo1 valueForKey:@"year"] intValue];
	}
    
    if(startYear < endYear-10)
        startYear=endYear-10;

	for(int i=startYear; i<=endYear; i++)
		[months addObject:[NSString stringWithFormat:@"%d", i]];
	
	int min=0;
	int max=0;
	for(NSString *month in months) {
		NSString *predString = [NSString stringWithFormat:@"%@ AND year = '%d'", basicPred, [month intValue]];
		NSPredicate *predicate = [NSPredicate predicateWithFormat:predString];
		int winnings = [[CoreDataLib getGameStat:mOC dataField:@"winnings" predicate:predicate] intValue];
		int minutes = [[CoreDataLib getGameStat:mOC dataField:@"minutes" predicate:predicate] intValue];
		int hours = minutes/60;
		int hourlyRate = 0;
		if(hours>0)
			hourlyRate = winnings/hours;
		if(chartNum==1) {
			if(winnings>max)
				max=winnings;
			if(winnings<min)
				min=winnings;
		}
		if(chartNum==2) {
			if(hourlyRate>max)
				max=hourlyRate;
			if(hourlyRate<min)
				min=hourlyRate;
		}
		float amount = (chartNum==1)?winnings:hourlyRate;
		[profitList addObject:[NSString stringWithFormat:@"%f", amount]];
	}
	max*=1.1;
	int totalMoneyRange = max-min;
	
	float yMultiplier = 1;
	if(totalMoneyRange>0)
		yMultiplier = (float)bottomEdgeOfChart/totalMoneyRange;
	
	
	UIImage *dynamicChartImage = [[UIImage alloc] init];

	CGContextRef c = [self contextRefForGraphofWidth:totalWidth totalHeight:totalHeight];
	
	int zeroLoc = [self drawZeroLineForContext:c min:min max:max bottomEdgeOfChart:bottomEdgeOfChart leftEdgeOfChart:leftEdgeOfChart totalWidth:totalWidth];
	
	[self drawLeftLabelsAndLinesForContext:c totalMoneyRange:totalMoneyRange min:min leftEdgeOfChart:leftEdgeOfChart totalHeight:totalHeight totalWidth:totalWidth];
	
	[self drawBottomLabelsForArray:months c:c bottomEdgeOfChart:bottomEdgeOfChart leftEdgeOfChart:leftEdgeOfChart totalWidth:totalWidth];
	
	[self drawBarChartForContext:c itemArray:profitList leftEdgeOfChart:leftEdgeOfChart mainGoal:0 zeroLoc:zeroLoc yMultiplier:yMultiplier totalWidth:totalWidth];
	UIGraphicsPopContext();
	dynamicChartImage = UIGraphicsGetImageFromCurrentImageContext();
	
	UIGraphicsEndImageContext();
	
	return dynamicChartImage;
	
}


+(NSString *)getGamesTextFromInt:(int)numGames
{
	NSString *gameTxt = (numGames==1)?@"Game":@"Games";
	return [NSString stringWithFormat:@"%d %@", numGames, gameTxt];
}

+(CLLocation *)getCurrentLocation
{
	CLLocation *currentLocation = nil;
//	if ([LocationGetter sharedInstance].currentLocation == nil)
//		return nil;

	[[[LocationGetter sharedInstance] locationManager] startUpdatingLocation];
	
	currentLocation = [LocationGetter sharedInstance].currentLocation;

//	currentLocation = [[[CLLocation alloc] initWithLatitude:47.7590380 longitude:-122.2021071] autorelease];

	return currentLocation;
}

+(NSString *)getLatitudeFromLocation:(CLLocation *)currentLocation decimalPlaces:(int)decimalPlaces
{
	if(currentLocation==nil)
		return @"-";
	NSString *floatStr = [NSString stringWithFormat:@"%%.%df", decimalPlaces];
	return [NSString stringWithFormat:floatStr, currentLocation.coordinate.latitude];
}

+(NSString *)getLongitudeFromLocation:(CLLocation *)currentLocation decimalPlaces:(int)decimalPlaces
{
	if(currentLocation==nil)
		return @"-";
	NSString *floatStr = [NSString stringWithFormat:@"%%.%df", decimalPlaces];
	return [NSString stringWithFormat:floatStr, currentLocation.coordinate.longitude];
}

+(float)getDistanceFromTarget:(float)fromLatitude fromLong:(float)fromLongitude toLat:(float)toLatitude toLong:(float)toLongitude
{
	CLLocation *currentLocation = [[CLLocation alloc] initWithLatitude:fromLatitude longitude:fromLongitude];
	CLLocation *targetLocation = [[CLLocation alloc] initWithLatitude:toLatitude longitude:toLongitude];
	CLLocationDistance distance =[currentLocation distanceFromLocation:targetLocation] * 0.000621371192237334;
    
//    NSLog(@"+++ %.1f %.1f %.1f %.1f %.1f", fromLatitude, fromLongitude, toLatitude, toLongitude, distance);
	return (float)distance; 
}

+(NSString *)getCurrentLocationFromCoreData:(float)fromLatitude long:(float)fromLongitude moc:(NSManagedObjectContext *)managedObjectContext
{
	
	if(fromLatitude==0)	
		return nil;

	NSArray *items = [CoreDataLib selectRowsFromTable:@"LOCATION" mOC:managedObjectContext];
	NSString *thisLoc = nil;
	float distance = 99;
	float minDist = 99;
	for(NSManagedObject *mo in items) {
		NSString *lat = [mo valueForKey:@"latitude"];
		NSString *longitude = [mo valueForKey:@"longitude"];
		if([lat length]>1) {
			distance = [ProjectFunctions getDistanceFromTarget:fromLatitude fromLong:fromLongitude toLat:[lat floatValue] toLong:[longitude floatValue]];

            if(distance<1.8) {
                if(distance<minDist) {
                    minDist=distance;
                    thisLoc = [mo valueForKey:@"name"];
                }
            }

		}
	} // <-- for
	NSLog(@"+++looking for casino on device: %@", thisLoc);
	return thisLoc;
}


+(NSString *)getDefaultLocation:(float)fromLatitude long:(float)fromLongitude moc:(NSManagedObjectContext *)managedObjectContext
{
	if(fromLatitude==0)
		return [ProjectFunctions getUserDefaultValue:@"locationDefault"];
	
	NSString *thisLoc = [ProjectFunctions getCurrentLocationFromCoreData:fromLatitude long:fromLongitude moc:managedObjectContext];

	if(thisLoc==nil)	
		return [ProjectFunctions getUserDefaultValue:@"locationDefault"];
	else
		return thisLoc;
}

+(NSString *)checkLocation1:(CLLocation *)currentLocation moc:(NSManagedObjectContext *)managedObjectContext
{
    NSString *locationName = nil;
	float lat=currentLocation.coordinate.latitude;
	float lng=currentLocation.coordinate.longitude;
	
	BOOL coordsFound = (currentLocation != nil);
	
	if(0) {		//testing
		lat=36.11;
		lng=-115.171;
		coordsFound=YES;
	}
	
	if(coordsFound)
		locationName = [ProjectFunctions getCurrentLocationFromCoreData:lat long:lng moc:managedObjectContext];
    
	if([locationName length]==0 && coordsFound)
		locationName = [ProjectFunctions getDefaultDBLocation:lat lng:lng];
    
    return locationName;
}

+(NSString *)checkLocation2:(CLLocation *)currentLocation moc:(NSManagedObjectContext *)managedObjectContext
{
 	float lat=currentLocation.coordinate.latitude;
	float lng=currentLocation.coordinate.longitude;
   
    NSString *locationName = [WebServicesFunctions getAddressFromGPSLat:lat lng:lng type:1];

	if([locationName length]==0)
		locationName = [ProjectFunctions getUserDefaultValue:@"locationDefault"];
    
    return locationName;
}

+(NSString *)getBestLocation:(CLLocation *)currentLocation MoC:(NSManagedObjectContext *)managedObjectContext
{
    NSString *locationName = [ProjectFunctions checkLocation1:currentLocation moc:managedObjectContext];
    
	if([locationName length]==0)
        locationName = [ProjectFunctions checkLocation2:currentLocation moc:managedObjectContext];
    
	return locationName;
}



+(NSString *)getDefaultDBLocation:(float)currLat lng:(float)currLng
{
	
	NSString *latitude = [NSString stringWithFormat:@"%.6f", currLat];
	NSString *longitutde = [NSString stringWithFormat:@"%.6f", currLng];
	NSArray *nameList = [NSArray arrayWithObjects:@"Username", @"Password", @"lat", @"lng", @"distance", nil];
	
	NSString *userName = @"test@test.com";
	NSString *password = @"test";
	if([[ProjectFunctions getUserDefaultValue:@"userName"] length]>0)
		userName = [ProjectFunctions getUserDefaultValue:@"userName"];
	if([ProjectFunctions getUserDefaultValue:@"password"])
		password = [ProjectFunctions getUserDefaultValue:@"password"];

	NSLog(@"+++Checking Casinos at loc: (%f, %f)", currLat, currLng);

	NSArray *valueList = [NSArray arrayWithObjects:userName, password, latitude, longitutde, @"2", nil];
	NSString *webAddr = @"http://www.appdigity.com/poker/pokerCasinoLookup.php";
	NSString *responseStr = [WebServicesFunctions getResponseFromServerUsingPost:webAddr fieldList:nameList valueList:valueList];
	NSString *thisLoc = nil;
	if([WebServicesFunctions validateStandardResponse:responseStr delegate:nil]) {
		NSArray *casinos = [responseStr componentsSeparatedByString:@"<li>"];
		
		float distance = 3;
		float minDist = .3;
		for(NSString *casino in casinos) {
			NSArray *items = [casino componentsSeparatedByString:@"|"];
			if(items.count>7) {
				NSString *name = [items stringAtIndex:1];
				NSString *lat = [items stringAtIndex:6];
				NSString *lng = [items stringAtIndex:7];
				if([lat length]>1) {
					distance = [ProjectFunctions getDistanceFromTarget:currLat fromLong:currLng toLat:[lat floatValue] toLong:[lng floatValue]];
					NSLog(@"+++%f: %@", distance, name);
					if(distance <= minDist) {
						minDist = distance;
						thisLoc = name;
					}
				}
			}
		} // <-- for
	}
		
	return thisLoc;
	
	
}




+(NSDate *)getDateInCorrectFormat:(NSString *)istartTime {
	NSDate *ist = [istartTime convertStringToDateWithFormat:@"pokerJounral"];
    
	if(ist==nil)
		ist = [istartTime convertStringToDateWithFormat:@"pokerJounral2"];
	if(ist==nil)
		ist = [istartTime convertStringToDateWithFormat:nil];
	if(ist==nil)
		ist = [istartTime convertStringToDateWithFormat:@"MM/dd/yy hh:mm a"];
	if(ist==nil)
		ist = [istartTime convertStringToDateWithFormat:@"MM/dd/yyyy hh:mm:ss a"];
	if(ist==nil)
		ist = [istartTime convertStringToDateWithFormat:@"MM/dd/yy HH:mm"];
	if(ist==nil)
		ist = [istartTime convertStringToDateWithFormat:@"MM/dd/yy hh:mm:ss a"];
	if(ist==nil)
		ist = [istartTime convertStringToDateWithFormat:@"MM/dd/yy hh:mm a"];

    if(ist==nil)
        ist=[istartTime convertStringToDateFinalSolution];
    
	
	return ist;
}

+ (UIImage *)imageWithImage:(UIImage *)image newSize:(CGSize)newSize {
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();    
    UIGraphicsEndImageContext();
    return newImage;
}

+(NSString *)getPicPath:(int)user_id
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *docDir = [paths stringAtIndex:0];
	return [docDir stringByAppendingPathComponent:[NSString stringWithFormat:@"player%d.jpg", user_id]];
}

+(NSArray *)getStateArray
{
	return [NSArray arrayWithObjects:@"AK", @"AL", @"AR", @"AZ", @"CA", @"CO", @"CT", @"DE", @"FL", @"GA",
			@"HI", @"IA", @"ID", @"IL", @"IN", @"KS", @"KY", @"LA", @"MA", @"MD", @"ME",
			@"MI", @"MN", @"MO", @"MS", @"MT", @"NC", @"ND", @"NE", @"NH", @"NJ", @"NM",
			@"NV", @"NY", @"OH", @"OK", @"OR", @"PA", @"RI", @"SC", @"SD", @"TN", @"TX",
			@"UT", @"VA", @"VT", @"WA", @"WI", @"WV", @"WY",
			nil];
}

+(NSArray *)getCountryArray
{
	return [NSArray arrayWithObjects:@"Afghanistan",
							 @"Albania",
							 @"Algeria",
							 @"Andorra",
							 @"Angola",
							 @"Antigua and Barbuda",
							 @"Argentina",
							 @"Armenia",
							 @"Australia",
							 @"Austria",
							 @"Azerbaijan",
							 @"Bahamas, The",
							 @"Bahrain",
							 @"Bangladesh",
							 @"Barbados",
							 @"Belarus",
							 @"Belgium",
							 @"Belize",
							 @"Benin",
							 @"Bhutan",
							 @"Bolivia",
							 @"Bosnia and Herzegovina",
							 @"Botswana",
							 @"Brazil",
							 @"Brunei",
							 @"Bulgaria",
							 @"Burkina Faso",
							 @"Burma",
							 @"Burundi",
							 @"Cambodia",
							 @"Cameroon",
							 @"Canada",
							 @"Cape Verde",
							 @"Central African Republic",
							 @"Chad",
							 @"Chile",
							 @"China",
							 @"Colombia",
							 @"Comoros",
							 @"Congo, Democratic Republic of the",
							 @"Congo, Republic of the",
							 @"Costa Rica",
							 @"Cote d'Ivoire",
							 @"Croatia",
							 @"Cuba",
							 @"Cyprus",
							 @"Czech Republic",
							 @"Denmark",
							 @"Djibouti",
							 @"Dominica",
							 @"Dominican Republic",
							 @"East Timor",
							 @"Ecuador",
							 @"Egypt",
							 @"El Salvador",
							 @"Equatorial Guinea",
							 @"Eritrea",
							 @"Estonia",
							 @"Ethiopia",
							 @"Fiji",
							 @"Finland",
							 @"France",
							 @"Gabon",
							 @"Gambia, The",
							 @"Georgia",
							 @"Germany",
							 @"Ghana",
							 @"Greece",
							 @"Grenada",
							 @"Guatemala",
							 @"Guinea",
							 @"Guinea-Bissau",
							 @"Guyana",
							 @"Haiti",
							 @"Holy See",
							 @"Honduras",
							 @"Hong Kong",
							 @"Hungary",
							 @"Iceland",
							 @"India",
							 @"Indonesia",
							 @"Iran",
							 @"Iraq",
							 @"Ireland",
							 @"Israel",
							 @"Italy",
							 @"Jamaica",
							 @"Japan",
							 @"Jordan",
							 @"Kazakhstan",
							 @"Kenya",
							 @"Kiribati",
							 @"Kosovo",
							 @"Kuwait",
							 @"Kyrgyzstan",
							 @"Laos",
							 @"Latvia",
							 @"Lebanon",
							 @"Lesotho",
							 @"Liberia",
							 @"Libya",
							 @"Liechtenstein",
							 @"Lithuania",
							 @"Luxembourg",
							 @"Macau",
							 @"Macedonia",
							 @"Madagascar",
							 @"Malawi",
							 @"Malaysia",
							 @"Maldives",
							 @"Mali",
							 @"Malta",
							 @"Marshall Islands",
							 @"Mauritania",
							 @"Mauritius",
							 @"Mexico",
							 @"Micronesia",
							 @"Moldova",
							 @"Monaco",
							 @"Mongolia",
							 @"Montenegro",
							 @"Morocco",
							 @"Namibia",
							 @"Nauru",
							 @"Nepal",
							 @"Netherlands",
							 @"Netherlands Antilles",
							 @"New Zealand",
							 @"Nicaragua",
							 @"Niger",
							 @"Nigeria",
							 @"North Korea",
							 @"Norway",
							 @"Oman",
							 @"Pakistan",
							 @"Palau",
							 @"Palestinian Territories",
							 @"Panama",
							 @"Papua New Guinea",
							 @"Paraguay",
							 @"Peru",
							 @"Philippines",
							 @"Poland",
							 @"Portugal",
							 @"Qatar",
							 @"Romania",
							 @"Russia",
							 @"Rwanda",
							 @"Saint Kitts and Nevis",
							 @"Saint Lucia",
							 @"Saint Vincent and the Grenadines",
							 @"Samoa",
							 @"San Marino",
							 @"Sao Tome and Principe",
							 @"Saudi Arabia",
							 @"Senegal",
							 @"Serbia",
							 @"Seychelles",
							 @"Sierra Leone",
							 @"Singapore",
							 @"Slovakia",
							 @"Slovenia",
							 @"Solomon Islands",
							 @"Somalia",
							 @"South Africa",
							 @"South Korea",
							 @"South Sudan",
							 @"Spain",
							 @"Sri Lanka",
							 @"Sudan",
							 @"Suriname",
							 @"Swaziland",
							 @"Sweden",
							 @"Switzerland",
							 @"Syria",
							 @"Taiwan",
							 @"Tajikistan",
							 @"Tanzania",
							 @"Thailand",
							 @"Timor-Leste",
							 @"Togo",
							 @"Tonga",
							 @"Trinidad and Tobago",
							 @"Tunisia",
							 @"Turkey",
							 @"Turkmenistan",
							 @"Tuvalu",
							 @"Uganda",
							 @"Ukraine",
							 @"United Arab Emirates",
							 @"United Kingdom",
							 @"Uruguay",
							 @"USA",
							 @"Uzbekistan",
							 @"Vanuatu",
							 @"Venezuela",
							 @"Vietnam",
							 @"Yemen",
							 @"Zambia",
							 @"Zimbabwe",
							 nil];
}	

+ (NSString *)formatTelNumberForCalling:(NSString *)phoneNumber
{
	phoneNumber = [NSString removeTelephoneFormatting:phoneNumber];
	int len = (int)[phoneNumber length];
	
	if (len>=11 && [[phoneNumber substringWithRange:NSMakeRange(0, 1)] isEqualToString:@"1"]) {
		phoneNumber = [phoneNumber substringWithRange:NSMakeRange(1, len-1)];
		len--;
	}
	
	if(len<=10)
		return phoneNumber;
	
	return [NSString stringWithFormat:@"%@p%@",
			[phoneNumber substringWithRange:NSMakeRange(0, 10)],
			[phoneNumber substringWithRange:NSMakeRange(10, len-10)]];	
}	

+(NSString *)formatFieldForWebService:(NSString *)field
{
	field = [field stringByReplacingOccurrencesOfString:@"|" withString:@""];
	field = [field stringByReplacingOccurrencesOfString:@"&" withString:@"[amp]"];
	field = [field stringByReplacingOccurrencesOfString:@"<li>" withString:@""];
	field = [field stringByReplacingOccurrencesOfString:@"<hr>" withString:@""];
	field = [field stringByReplacingOccurrencesOfString:@"\n" withString:@"[nl]"];
	return field;
}

+(void)updateMoneyFloatLabel:(UILabel *)localLabel money:(float)money
{
	localLabel.text = [ProjectFunctions convertNumberToMoneyString:money];
	if(money<0)
		localLabel.textColor = [UIColor orangeColor];
	else 
		localLabel.textColor = [UIColor greenColor];
}

+(void)updateMoneyLabel:(UILabel *)localLabel money:(int)money
{
    [localLabel performSelectorOnMainThread:@selector(setText: ) withObject:[ProjectFunctions convertIntToMoneyString:money] waitUntilDone:NO];
    
	if(money<0)
        [localLabel performSelectorOnMainThread:@selector(setTextColor: ) withObject:[UIColor orangeColor] waitUntilDone:NO];
	else
        [localLabel performSelectorOnMainThread:@selector(setTextColor: ) withObject:[UIColor greenColor] waitUntilDone:NO];
    
}

+(int)getPlayerType:(int)amountRisked winnings:(int)winnings
{
	int amountReturned = amountRisked+winnings;
	int percent=100;
	if(amountRisked>0)
		percent = amountReturned*100/amountRisked;
	
	if(percent<50)
		return 0;
	if(percent>=50 && percent<100)
		return 1;
	if(percent>=100 && percent<125)
		return 2;
	if(percent>=125 && percent<150)
		return 3;
	
	return 4;
}

+(NSString *)getPlayerTypelabel:(int)amountRisked winnings:(int)winnings
{
	int value = [ProjectFunctions getNewPlayerType:amountRisked winnings:winnings];
	NSArray *types = [NSArray arrayWithObjects:@"Donkey", @"Fish", @"Rounder", @"Grinder", @"Shark", @"Pro", nil];
	return [types stringAtIndex:value];
}


+(int)getNewPlayerType:(int)amountRisked winnings:(int)winnings
{
	int amountReturned = amountRisked+winnings;
	int percent=100;
	if(amountRisked>0)
		percent = amountReturned*100/amountRisked;
	
	if(percent<35)
		return 0;
	if(percent>=35 && percent<75)
		return 1;
	if(percent>=75 && percent<=100)
		return 2;
	if(percent>=100 && percent<125)
		return 3;
	if(percent>=125 && percent<150)
		return 4;
	
	return 5;
}

+(UIImage *)getPlayerTypeImage:(int)amountRisked winnings:(int)winnings
{
    if(winnings==0)
        return [UIImage imageNamed:@"playerType99.png"];
	int value = [ProjectFunctions getNewPlayerType:amountRisked winnings:winnings];
	return [UIImage imageNamed:[NSString stringWithFormat:@"playerType%d.png", value]];
}

+(void)setFontColorForSegment:(UISegmentedControl *)segment values:(NSArray *)values
{
	return;
	if(values==nil)
		values = [NSArray arrayWithObjects:@"All", @"Cash Games", @"Tournaments", nil];
	for (id seg in [segment subviews]) {
		for (id label in [seg subviews])
			if([label isKindOfClass:[UILabel class]]) {
				UILabel *temp = label;
				if(![temp.text isEqualToString:[values stringAtIndex:segment.selectedSegmentIndex]]) {
					[label setTextColor:[UIColor colorWithRed:.9 green:.9 blue:.9 alpha:1]];
					[label setShadowColor:[UIColor blackColor]];
					[label setShadowOffset:CGSizeMake(1.0, 1.0)];
				} else {
					[label setTextColor:[UIColor whiteColor]];
					[label setShadowColor:[UIColor blackColor]];
					[label setShadowOffset:CGSizeMake(2.0, 2.0)];
				}
			}
		
	}
}

+ (UIView *)getViewForHeaderWithText:(NSString *)headerText
{
	UIView* customView = [[UIView alloc] initWithFrame:CGRectMake(0, 0.0, 320.0, 22.0)];
	UILabel * headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	headerLabel.backgroundColor = [UIColor clearColor];
	headerLabel.opaque = NO;
	headerLabel.textColor = [UIColor whiteColor];
	headerLabel.highlightedTextColor = [UIColor whiteColor];
	headerLabel.font = [UIFont boldSystemFontOfSize:14];
	headerLabel.numberOfLines = 0;
	headerLabel.frame = CGRectMake(10.0, 0.0, 300.0, 22.0);
	headerLabel.text = headerText;
	customView.backgroundColor	= [UIColor colorWithRed:0 green:.4 blue:0 alpha:1];
	[customView addSubview:headerLabel];
	return customView;
}

+(NSString *)convertImgToBase64String:(UIImage *)img height:(int)height
{
	NSData *data = UIImageJPEGRepresentation(img, 1.0);
	return [ProjectFunctions convertDataToBase64String:data height:height];
}

+(NSString *)convertDataToBase64String:(NSData *)data height:(int)height
{
	UIImage *img = [UIImage imageWithData:data];
	CGSize newSize;
	newSize.height=height;
	newSize.width=height;
	
	UIImage *newImg = [ProjectFunctions imageWithImage:img newSize:newSize];
	NSData *imgData = UIImageJPEGRepresentation(newImg, 1.0);
	return [NSString base64StringFromData:imgData length:(int)[imgData length]];
}

+(NSData *)convertBase64StringToData:(NSString *)imgString
{
	NSData *imgData = [NSData base64DataFromString:imgString];
	return imgData;
}

+(UIImage *)convertBase64StringToImage:(NSString *)imgString
{
	NSData *imgData = [ProjectFunctions convertBase64StringToData:imgString];
	UIImage *img = [UIImage imageWithData:imgData];
	return img;
}

+(NSString *)getMoneySymbol
{
	NSString *moneySymbol = [ProjectFunctions getUserDefaultValue:@"moneySymbol"];
	if([moneySymbol length]==0)
		return @"$";
	else 
		return moneySymbol;
}

+(NSArray *)moneySymbols
{
	return [NSArray arrayWithObjects:
					   @"$", @"£", @"€", @"¥", @"฿", @"Br", 
					   @"₵", @"₡", @"ден", @"₫", @"ƒ", 
					   @"Ft", @"₲", @"Kč", @"₭", @"L", 
					   @"₤", @"₥", @"₦", @"₱", @"P", 
					   @"R", @"RM", @"RSD", @"₨", @"৳", 
					   @"₮", @"₩", @"¥", @"zł", @"₴", 
					   @"Q", @"₪", @"TL", nil];
}

+(void)createChipTimeStamp:(NSManagedObjectContext *)managedObjectContext mo:(NSManagedObject *)mo timeStamp:(NSDate *)timeStamp amount:(int)amount rebuyFlg:(BOOL)rebuyFlg
{
	if(timeStamp==nil)
		timeStamp=[NSDate date];

    if(amount>32000)
        amount=32000; // temp code needed until field size is larger
    
	NSArray *a1 = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%d",amount], [timeStamp convertDateToStringWithFormat:nil], nil];
	
	NSManagedObject *m1 = [CoreDataLib insertManagedObjectForEntity:@"CHIPSTACK" valueList:a1 mOC:managedObjectContext];
	
	[m1 setValue:mo forKey:@"game"];
	
	if(rebuyFlg)
		[m1 setValue:[NSNumber numberWithInt:1] forKey:@"rebuyFlg"];

	[managedObjectContext save:nil];
	
}

+(void)showActionSheet:(id)delegate view:(UIView *)view title:(NSString *)title buttons:(NSArray *)buttons
{
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:title delegate:delegate cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
	for(NSString *buttonName in buttons)
		[actionSheet addButtonWithTitle:buttonName];
	[actionSheet addButtonWithTitle:@"Cancel"];
	[actionSheet showInView:view];
	
	//-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
}

+(NSString *)numberWithSuffix:(int)number
{
	NSString *text = [NSString stringWithFormat:@"%d", number];
	if([text length]>1) {
		int lastDigits = [[text substringWithRange:NSMakeRange([text length]-2, 2)] intValue];
		if(lastDigits==11 || lastDigits==12 || lastDigits==13) 
			return [NSString stringWithFormat:@"%dth", number];
	}
	int lastDigit = [[text substringWithRange:NSMakeRange([text length]-1, 1)] intValue];
	if(lastDigit==1)
		return [NSString stringWithFormat:@"%dst", number];
	if(lastDigit==2)
		return [NSString stringWithFormat:@"%dnd", number];
	if(lastDigit==3)
		return [NSString stringWithFormat:@"%drd", number];
	
	return [NSString stringWithFormat:@"%dth", number];
}

+(int)synvLiveUpdateInfo:(NSManagedObjectContext *)MoC
{
	NSLog(@"Sync Live Update");
	NSString *data = @"N";
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"user_id = 0 AND status = %@", @"In Progress"];
	NSArray *items = [CoreDataLib selectRowsFromEntity:@"GAME" predicate:predicate sortColumn:@"name" mOC:MoC ascendingFlg:YES];
	if([items count]>0) {
		NSManagedObject *mo = [items objectAtIndex:0];
		data = [NSString stringWithFormat:@"Y|%@|%@|%@|%@|%@", 
				[mo valueForKey:@"location"], 
				[mo valueForKey:@"cashoutAmount"], 
				[[mo valueForKey:@"startTime"] convertDateToStringWithFormat:nil],
				[mo valueForKey:@"buyInAmount"],
				[mo valueForKey:@"rebuyAmount"]];
	} else {
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"user_id = %d", 0];
		NSArray *items = [CoreDataLib selectRowsFromEntity:@"GAME" predicate:predicate sortColumn:@"startTime" mOC:MoC ascendingFlg:NO];
		if([items count]>0) {
			NSManagedObject *mo = [items objectAtIndex:0];
			data = [NSString stringWithFormat:@"N|%@|%@|%@|%@|%@", 
					[mo valueForKey:@"location"], 
					[mo valueForKey:@"cashoutAmount"], 
					[[mo valueForKey:@"startTime"] convertDateToStringWithFormat:nil],
					[mo valueForKey:@"buyInAmount"],
					[mo valueForKey:@"rebuyAmount"]];
		}
	}

	NSArray *nameList = [NSArray arrayWithObjects:@"Username", @"Password", @"data", nil];
	NSString *userName = @"x";
	NSString *password = @"x";
	if([ProjectFunctions getUserDefaultValue:@"userName"])
		userName = [ProjectFunctions getUserDefaultValue:@"userName"];
	if([ProjectFunctions getUserDefaultValue:@"password"])
		password = [ProjectFunctions getUserDefaultValue:@"password"];

	NSArray *valueList = [NSArray arrayWithObjects:userName, password, data, nil];
	NSString *webAddr = @"http://www.appdigity.com/poker/pokerLiveUpdate.php";
	NSString *responseStr = [WebServicesFunctions getResponseFromServerUsingPost:webAddr fieldList:nameList valueList:valueList];
	int count = [ProjectFunctions updateFriendData:responseStr MoC:MoC];
	return count;
}

+(int)updateFriendData:(NSString *)responseStr MoC:(NSManagedObjectContext *)MoC
{
	NSArray *friends = [responseStr componentsSeparatedByString:@"<br>"];
	int count=0;
	int chips=0;
	for(NSString *friend in friends) {
		NSArray *components = [friend componentsSeparatedByString:@"|"];
		if([components count]>5) {
			int friendId = [[components stringAtIndex:0] intValue];
			if([[components stringAtIndex:1] isEqualToString:@"Y"])
				count++;
			
			NSPredicate *predicate = [NSPredicate predicateWithFormat:@"user_id = %d", friendId];
			NSArray *friendObj = [CoreDataLib selectRowsFromEntity:@"FRIEND" predicate:predicate sortColumn:nil mOC:MoC ascendingFlg:YES];
			if([friendObj count]>0) {
				chips += [[components stringAtIndex:3] intValue];
				NSString *line = [NSString stringWithFormat:@"%@|%@|%@|%@|%@", [components stringAtIndex:2], [components stringAtIndex:3], [components stringAtIndex:5], [components stringAtIndex:6], [components stringAtIndex:7]];
				[friendObj setValue:[components stringAtIndex:1] forKey:@"attrib_08"];
				[friendObj setValue:[components stringAtIndex:4] forKey:@"attrib_09"];
				if([line length]<50)
					[friendObj setValue:line forKey:@"attrib_10"];
				[MoC save:nil];
			}
		}
	}
	[ProjectFunctions setUserDefaultValue:[NSString stringWithFormat:@"%d", chips] forKey:@"FriendChips"];
	return count;
}

+(void)doLiveUpdate:(NSManagedObjectContext *)MoC
{
	@autoreleasepool {
		NSArray *items = [CoreDataLib selectRowsFromEntity:@"FRIEND" predicate:nil sortColumn:nil mOC:MoC ascendingFlg:YES];
		
		if([items count]>0)
			[ProjectFunctions synvLiveUpdateInfo:MoC];
	
	
	}
}

+(NSString *)displayMoney:(NSManagedObject *)mo column:(NSString *)column
{
	return [ProjectFunctions convertNumberToMoneyString:[[mo valueForKey:column] floatValue]];
}

+(NSString *)convertTextToMoneyString:(NSString *)amount
{
	return [ProjectFunctions convertNumberToMoneyString:[amount floatValue]];
}

+(BOOL)shouldSyncGameResultsWithServer:(NSManagedObjectContext *)moc
{
	if([[ProjectFunctions getUserDefaultValue:@"userName"] length]==0)
		return NO;
	
	if([[ProjectFunctions getUserDefaultValue:@"autoSyncValue"] isEqualToString:@"off"])
		return NO;
	
	return YES;
}

+(int)generateUniqueId
{
	int UniqueId = [[ProjectFunctions getUserDefaultValue:@"UniqueId"] intValue];
	UniqueId++;
	[ProjectFunctions setUserDefaultValue:[NSString stringWithFormat:@"%d", UniqueId] forKey:@"UniqueId"];
	return UniqueId;
}

+(void)updateBankroll:(int)winnings bankrollName:(NSString *)bankrollName MOC:(NSManagedObjectContext *)MOC;
{
 	int bankrollAmount = [[ProjectFunctions getUserDefaultValue:@"defaultBankroll"] intValue];
	bankrollAmount += winnings;
	NSLog(@"bankrollAmount: %d %d [%@]", bankrollAmount, winnings, bankrollName);
	[ProjectFunctions setUserDefaultValue:[NSString stringWithFormat:@"%d", bankrollAmount] forKey:@"defaultBankroll"];
 
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"type = 'bankroll' AND name = %@", bankrollName];
    NSArray *items = [CoreDataLib selectRowsFromEntity:@"EXTRA2" predicate:predicate sortColumn:nil mOC:MOC ascendingFlg:NO];
    if([items count]>0) {
        NSManagedObject *mo = [items objectAtIndex:0];
        [mo setValue:[NSNumber numberWithInt:bankrollAmount] forKey:@"attrib_01"];
    }

}


-(void) setReturningValue:(NSString *)value
{
    // This function needed to avoid warning messages
}

+(int)getMinutesPlayedUsingStartTime:(NSDate *)startTime andEndTime:(NSDate *)endTime andBreakMin:(int)breakMinutes
{
    int minutesPlayed = [endTime timeIntervalSinceDate:startTime]/60;
    return minutesPlayed-breakMinutes;
}

+(NSString *)getHoursPlayedUsingStartTime:(NSDate *)startTime andEndTime:(NSDate *)endTime andBreakMin:(int)breakMinutes
{
    int minutesPlayed = [self getMinutesPlayedUsingStartTime:startTime andEndTime:endTime andBreakMin:breakMinutes];
    return [NSString stringWithFormat:@"%.1f hours", (float)minutesPlayed/60];
}

+(int)calculatePprAmountRisked:(int)amountRisked netIncome:(int)netIncome {
    int ppr=100;
    if(amountRisked>0)
        ppr=100*(netIncome+amountRisked)/amountRisked;
    ppr -=100;
    return ppr;
}

+(void)setBankSegment:(UISegmentedControl *)segment
{
    NSString *bankrollDefault = [ProjectFunctions getUserDefaultValue:@"bankrollDefault"];
    if(![@"ALL" isEqualToString:bankrollDefault])
        [segment setTitle:[NSString stringWithFormat:@"%@", bankrollDefault] forSegmentAtIndex:0];
    
    NSString *limitBankRollGames = [ProjectFunctions getUserDefaultValue:@"limitBankRollGames"];
    if([@"YES" isEqualToString:limitBankRollGames])
        segment.selectedSegmentIndex=0;
    else
        segment.selectedSegmentIndex=1;
    
}

+(void)bankSegmentChangedTo:(int)number
{
    if(number==1)
        [ProjectFunctions setUserDefaultValue:@"" forKey:@"limitBankRollGames"];
    else
        [ProjectFunctions setUserDefaultValue:@"YES" forKey:@"limitBankRollGames"];
}

+(void)checkBankrollsForSegment:(UISegmentedControl *)segment moc:(NSManagedObjectContext *)moc
{
    NSPredicate *predicateBank = [NSPredicate predicateWithFormat:@"bankroll <> %@ ", @"Default"];
    NSArray *gamesBank = [CoreDataLib selectRowsFromEntity:@"GAME" predicate:predicateBank sortColumn:@"" mOC:moc ascendingFlg:YES];
    int numBanks = (int)[gamesBank count];
    int oldNumBanks = [[ProjectFunctions getUserDefaultValue:@"numBanks"] intValue];
    if(numBanks != oldNumBanks)
        [ProjectFunctions setUserDefaultValue:[NSString stringWithFormat:@"%d", numBanks] forKey:@"numBanks"];
    
    if(numBanks==0)
        segment.alpha=0;
}

+(void)addColorToButton:(UIButton *)button color:(UIColor *)color {
	CGFloat red = 0.0, green = 0.0, blue = 0.0, alpha =0.0;
	[color getRed:&red green:&green blue:&blue alpha:&alpha];
	
	float colorAmount = red+green+blue;
	
	[button setBackgroundImage:[ProjectFunctions imageFromColor:color]
					  forState:UIControlStateNormal];
	
	if (colorAmount > 1.5)
		[button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	else
		[button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	
	button.layer.borderColor = [UIColor blackColor].CGColor;
	
	button.layer.masksToBounds = YES;
	button.layer.borderWidth = 1.0f;
    button.layer.cornerRadius = 8.0f;
}

+ (UIImage *) imageFromColor:(UIColor *)color {
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

+(UIBarButtonItem *)navigationButtonWithTitle:(NSString *)title selector:(SEL)selector target:(id)target
{
	
	return [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStylePlain target:target action:selector];

	float fontSize=14;
	int width=40+(int)title.length*7;
	UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
	[button setBackgroundImage:[UIImage imageNamed:@"yellowChromeBut.png"] forState:UIControlStateNormal];
	[button setTitle:title forState:UIControlStateNormal];
	[button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	button.titleLabel.font = [UIFont boldSystemFontOfSize:fontSize];
	//	button.titleLabel.shadowColor = [UIColor colorWithRed:1 green:1 blue:.9 alpha:1];
	//	button.titleLabel.shadowOffset = CGSizeMake(-1.0, -1.0);
	[button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
	button.frame = CGRectMake(0, 0, width, 34);
	UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:button];
	return barButton;
}

+(void)updateGamesOnDevice:(NSManagedObjectContext *)context {
	NSArray *allGames = [CoreDataLib selectRowsFromEntity:@"GAME" predicate:nil sortColumn:nil mOC:context ascendingFlg:YES];
	NSLog(@"+++gamesOnDevice: %d", (int)allGames.count);
	[ProjectFunctions setUserDefaultValue:[NSString stringWithFormat:@"%d", (int)allGames.count] forKey:@"gamesOnDevice"];
}

+(void)updateGamesOnServer:(NSManagedObjectContext *)context {
	NSArray *allGames = [CoreDataLib selectRowsFromEntity:@"GAME" predicate:nil sortColumn:nil mOC:context ascendingFlg:YES];
	NSLog(@"+++gamesOnServer: %d", (int)allGames.count);
	[ProjectFunctions setUserDefaultValue:[NSString stringWithFormat:@"%d", (int)allGames.count] forKey:@"gamesOnServer"];
}

+(void)makeSegment:(UISegmentedControl *)segment color:(UIColor *)color {
	[segment setTintColor:color];
//	[segment setBackgroundColor:[UIColor colorWithRed:.7 green:.7 blue:.7 alpha:1]];
	
	segment.layer.backgroundColor = [UIColor colorWithRed:.7 green:.7 blue:.7 alpha:1].CGColor;
	segment.layer.cornerRadius = 7;
	
	UIFont *font = [UIFont fontWithName:@"Helvetica-Bold" size:12];
	NSMutableDictionary *attribsNormal;
	attribsNormal = [NSMutableDictionary dictionaryWithObjectsAndKeys:font, UITextAttributeFont, [UIColor blackColor], UITextAttributeTextColor, nil];
	
	NSMutableDictionary *attribsSelected;
	attribsSelected = [NSMutableDictionary dictionaryWithObjectsAndKeys:font, UITextAttributeFont, [UIColor whiteColor], UITextAttributeTextColor, nil];
	
	[segment setTitleTextAttributes:attribsNormal forState:UIControlStateNormal];
	[segment setTitleTextAttributes:attribsSelected forState:UIControlStateSelected];
	
}

+(void)populateSegmentBar:(UISegmentedControl *)segmentBar mOC:(NSManagedObjectContext *)mOC
{
	NSArray *games = [CoreDataLib selectRowsFromEntity:@"GAME" predicate:nil sortColumn:@"startTime" mOC:mOC ascendingFlg:NO];
	
	NSString *paddingString = @"%04d";
	NSMutableDictionary *stakesDict = [[NSMutableDictionary alloc] init];
	[stakesDict setValue:[NSString stringWithFormat:paddingString, 1] forKey:@"$1/$2"];
	[stakesDict setValue:[NSString stringWithFormat:paddingString, 1] forKey:@"$1/$3"];
	[stakesDict setValue:[NSString stringWithFormat:paddingString, 1] forKey:@"$3/$5"];
	[stakesDict setValue:[NSString stringWithFormat:paddingString, 1] forKey:@"$3/$6"];
	
	for(NSManagedObject *game in games) {
		NSString *type = [game valueForKey:@"Type"];
		NSString *stakes = [game valueForKey:@"stakes"];
		//		NSString *gametype = [game valueForKey:@"gametype"];
		//		NSString *limit = [game valueForKey:@"limit"];
		//		NSString *tournamentType = [game valueForKey:@"tournamentType"];
		
		int count = [[stakesDict valueForKey:stakes] intValue];
		count++;
		if([@"Cash" isEqualToString:type] && ![@"Single Table" isEqualToString:stakes])
			[stakesDict setValue:[NSString stringWithFormat:paddingString, count] forKey:stakes];
		
	}
	NSArray* sortedValues2 = [ProjectFunctions sortArrayDescending:[stakesDict allValues]];
	NSMutableArray *finalArray = [[NSMutableArray alloc] init];
	for(NSString *stake in sortedValues2) {
		for(NSString *clave in [stakesDict allKeys]){
			if ([stake isEqualToString:[stakesDict valueForKey:clave]]) {
				[finalArray addObject:clave];
			}
		}
	}
	
	int i=0;
	for (NSString *value in finalArray)
		if (i<=3)
			[segmentBar setTitle:value forSegmentAtIndex:i++];
	
}

+(void)ptpLocationAuthorizedCheck:(CLAuthorizationStatus)status {
	if (status == kCLAuthorizationStatusDenied) {
		[ProjectFunctions showAlertPopup:@"Location services not authorized" message:@"PTP needs locations services for some features to work.\n You can enable by exiting PTP and then going to Settings->PokerTrack. Set Location to \"While Using the App.\""];
	}
}

+(float)chartHeightForSize:(float)height {
	float width = [[UIScreen mainScreen] bounds].size.width;
	if(width<320)
		width=320;
	return height*width/320;
}

+(BOOL)isOkToProceed:(NSManagedObjectContext *)context delegate:(id)delegate {
	if([ProjectFunctions isLiteVersion] && [CoreDataLib selectRowsFromTable:@"GAME" mOC:context].count>=5) {
		[ProjectFunctions showConfirmationPopup:@"Upgrade Now?" message:@"Sorry the trial period has ended. You will need to upgrade to use this feature." delegate:delegate tag:104];
		return NO;
	}
	return YES;
}












































@end
