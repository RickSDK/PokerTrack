    //
//  PokerOddsFunctions.m
//  PokerTracker
//
//  Created by Rick Medved on 10/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PokerOddsFunctions.h"


@implementation PokerOddsFunctions

+(NSString *)getRandomCard:(NSString *)burnedCards {
	NSArray *card = [NSArray arrayWithObjects:@"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"T", @"J", @"Q", @"K", @"A", nil];
	NSArray *suit = [NSArray arrayWithObjects:@"c", @"d", @"h", @"s", nil];
	if(burnedCards==nil)
		burnedCards=@"";
	BOOL keepGoing=YES;
	NSString *randomCard=nil;
	while(keepGoing) {
		int rc = arc4random()%13;
		int rs = arc4random()%4;
		randomCard = [NSString stringWithFormat:@"%@%@", [card objectAtIndex:rc], [suit objectAtIndex:rs]];
		if([burnedCards rangeOfString:randomCard].location == NSNotFound)
			keepGoing=NO;
	}
	return randomCard;
	
}

+(NSString *)getRandomHand:(NSString *)burnedCards {
	if(burnedCards==nil)
		burnedCards=@"";
	NSString *card1 = [PokerOddsFunctions getRandomCard:burnedCards];
	burnedCards = [NSString stringWithFormat:@"%@-%@", burnedCards, card1];
	NSString *card2 = [PokerOddsFunctions getRandomCard:burnedCards];
	
	return [NSString stringWithFormat:@"%@-%@", card1, card2];;
}

+(NSString *)getBurnedCards:(NSArray *)playerHands flop:(NSString *)flop turn:(NSString *)turn river:(NSString *)river
{
	NSString *pHands = @"";
	if(playerHands != nil)
		pHands = [playerHands componentsJoinedByString:@"-"];
	return [NSString stringWithFormat:@"%@-%@-%@-%@", pHands , flop, turn, river];
}

+(NSString *)getBurnedCardsMinusThese:(NSArray *)playerHands flop:(NSString *)flop turn:(NSString *)turn river:(NSString *)river removeIndex:(int)removeIndex
{
	NSMutableArray *burnedCards = [[NSMutableArray alloc] initWithArray:playerHands];
	[burnedCards addObject:flop];
	[burnedCards addObject:turn];
	[burnedCards addObject:river];
	
	[burnedCards removeObjectAtIndex:removeIndex];
	NSString *burnedStr = [burnedCards componentsJoinedByString:@"-"];
	return burnedStr;
}


+(NSString *)getRandomFlop:(NSString *)burnedCards
{
	NSString *card1 = [PokerOddsFunctions getRandomCard:burnedCards];
	burnedCards = [NSString stringWithFormat:@"%@-%@", burnedCards, card1];
	NSString *card2 = [PokerOddsFunctions getRandomCard:burnedCards];
	burnedCards = [NSString stringWithFormat:@"%@-%@", burnedCards, card2];
	NSString *card3 = [PokerOddsFunctions getRandomCard:burnedCards];
	return [NSString stringWithFormat:@"%@-%@-%@", card1, card2, card3];
}

+(int)getFlushHandValue:(NSArray *)handValues
{
	int handStrength = 6000000;
	NSMutableDictionary *valueDict = [[NSMutableDictionary alloc] init];
	for(NSString *value in handValues)
		[valueDict setObject:@"1" forKey:[NSString stringWithFormat:@"%02d", [value intValue]]];
	
	// check for straight flushes
    int max=0;
	for(int i=1; i<=10; i++) {
		NSString *value1 = [NSString stringWithFormat:@"%02d", i];
		if(i==1)
			value1 = @"14"; // ace
		NSString *value2 = [NSString stringWithFormat:@"%02d", i+1];
		NSString *value3 = [NSString stringWithFormat:@"%02d", i+2];
		NSString *value4 = [NSString stringWithFormat:@"%02d", i+3];
		NSString *value5 = [NSString stringWithFormat:@"%02d", i+4];
		if([[valueDict objectForKey:value1] isEqualToString:@"1"] &&
		   [[valueDict objectForKey:value2] isEqualToString:@"1"] &&
		   [[valueDict objectForKey:value3] isEqualToString:@"1"] &&
		   [[valueDict objectForKey:value4] isEqualToString:@"1"] &&
		   [[valueDict objectForKey:value5] isEqualToString:@"1"])
			max=i;
	}

	if(max>0)
        return 9000000+max*1000;

	NSMutableArray *sortedList = [NSMutableArray arrayWithCapacity:0];
	for (NSString *key in valueDict) {
		[sortedList addObject:key];
	}
	[sortedList sortUsingSelector:@selector(compare:)];	//sort the key
    
    int sortedCount = [sortedList count];
    

    if(sortedCount>=6)
		[sortedList removeObjectAtIndex:0];
	if(sortedCount>=7)
		[sortedList removeObjectAtIndex:0];

    int multiplyer = 1;
    
	for(NSString *value in sortedList) {
		handStrength += multiplyer*[value intValue];
		multiplyer*=15;
	}

	if(handStrength>=7000000)
		handStrength=6999999;
    
	
	return handStrength;
}

+(int)determinHandStrength:(NSString *)startingHand flop:(NSString *)flop turn:(NSString *)turn river:(NSString *)river
{
	//	NSLog(@"%@ %@ %@ %@", startingHand, flop, turn, river);
//    NSLog(@"+++%@", startingHand);
    if([startingHand isEqualToString:@"?x-?x"])
        return 0;
    
	int handStrength = 1000000;
	NSArray *startingHands = [startingHand componentsSeparatedByString:@"-"];
	NSArray *flopHands = [flop componentsSeparatedByString:@"-"];
	NSMutableArray *cardValues = [[NSMutableArray alloc] init];
	[cardValues addObject:[[startingHands objectAtIndex:0] substringToIndex:1]];
	[cardValues addObject:[[startingHands objectAtIndex:1] substringToIndex:1]];
	[cardValues addObject:[[flopHands objectAtIndex:0] substringToIndex:1]];
	[cardValues addObject:[[flopHands objectAtIndex:1] substringToIndex:1]];
	[cardValues addObject:[[flopHands objectAtIndex:2] substringToIndex:1]];
	[cardValues addObject:[turn substringToIndex:1]];
	[cardValues addObject:[river substringToIndex:1]];
	
	NSMutableArray *suits = [[NSMutableArray alloc] init];
	[suits addObject:[[startingHands objectAtIndex:0] substringFromIndex:1]];
	[suits addObject:[[startingHands objectAtIndex:1] substringFromIndex:1]];
	[suits addObject:[[flopHands objectAtIndex:0] substringFromIndex:1]];
	[suits addObject:[[flopHands objectAtIndex:1] substringFromIndex:1]];
	[suits addObject:[[flopHands objectAtIndex:2] substringFromIndex:1]];
	[suits addObject:[turn substringFromIndex:1]];
	[suits addObject:[river substringFromIndex:1]];
	
	for(int i=0; i<7; i++) {
		NSString *value = [cardValues objectAtIndex:i];
		if([value isEqualToString:@"T"])
			[cardValues replaceObjectAtIndex:i withObject:@"10"];
		if([value isEqualToString:@"J"])
			[cardValues replaceObjectAtIndex:i withObject:@"11"];
		if([value isEqualToString:@"Q"])
			[cardValues replaceObjectAtIndex:i withObject:@"12"];
		if([value isEqualToString:@"K"])
			[cardValues replaceObjectAtIndex:i withObject:@"13"];
		if([value isEqualToString:@"A"])
			[cardValues replaceObjectAtIndex:i withObject:@"14"];
	}
	
	//count suits
	NSMutableDictionary *suitDict = [[NSMutableDictionary alloc] init];
	for(NSString *suit in suits) {
		int number = [[suitDict objectForKey:suit] intValue];
		number++;
		[suitDict setObject:[NSString stringWithFormat:@"%d", number] forKey:suit];
	}
	
	// check for straight-flushes----------------
	int maxSuits = 2;
	NSString *flushSuit = @"";
	for(NSString *key in suitDict) {
		int numberSuits = [[suitDict objectForKey:key] intValue];
		if(numberSuits>2) {
			maxSuits = numberSuits;
			flushSuit = key;
		}
	}
	if(maxSuits>4) {
		NSMutableArray *flushHand = [[NSMutableArray alloc] init];
		int i=0;
		for(NSString *suit in suits) {
			if([suit isEqualToString:flushSuit])
				[flushHand addObject:[cardValues objectAtIndex:i]];
			i++;
		}
		handStrength=[PokerOddsFunctions getFlushHandValue:flushHand];
		if (handStrength>9000000)
			return handStrength;
	}
	
	// group into combos----------------
	int maxDupes=1;
	NSString *maxCard=nil;
	int secondDupes=1;
	NSString *secondCard=nil;
	int thridDupes=1;
	NSString *thirdCard=nil;
	NSMutableDictionary *cardDict = [[NSMutableDictionary alloc] init];
	for(NSString *cardValue in cardValues) {
		int number = [[cardDict objectForKey:cardValue] intValue];
		number++;
		if(number>maxDupes) {
			maxDupes=number;
			maxCard = cardValue;
		}
		else if(number>secondDupes) {
			secondDupes=number;
			secondCard = cardValue;
		}
		else if(number>thridDupes) {
			thridDupes=number;
			thirdCard = cardValue;
		}
		[cardDict setObject:[NSString stringWithFormat:@"%02d", number] forKey:cardValue];
	}
	if(secondDupes==2 && thridDupes==2 && [thirdCard intValue] > [secondCard intValue]) {
		NSString *temp = thirdCard;
		thirdCard = secondCard;
		secondCard = temp;
	}
	if(maxDupes==3 && secondDupes==3 && [secondCard intValue] > [maxCard intValue]) {
		NSString *temp = secondCard;
		secondCard = maxCard;
		maxCard = temp;
	}
	if(maxDupes==3 && secondDupes==3)
		secondDupes=2; // full house
		
	if(maxDupes==2 && secondDupes==2 && thridDupes==2) {
		if([thirdCard intValue] > [maxCard intValue])
			maxCard = thirdCard;
		else if([thirdCard intValue] > [secondCard intValue])
			secondCard = thirdCard;
	}
	if(maxDupes==2 && secondDupes==2 && thridDupes==1) {
		if([secondCard intValue] > [maxCard intValue]) {
			NSString *temp = secondCard;
			secondCard = maxCard;
			maxCard = temp;
		}
	}
	if(maxDupes==4)
		secondCard = @"";
	
	NSMutableArray *remainingCards = [[NSMutableArray alloc] init];
	for(NSString *cardValue in cardValues) {
		if(![cardValue isEqualToString:maxCard] && ![cardValue isEqualToString:secondCard])
			[remainingCards addObject:[NSString stringWithFormat:@"%02d", [cardValue intValue]]];
	}
	[remainingCards sortUsingSelector:@selector(compare:)];	//sort the key
	NSString *highCard = @"1";
	if([remainingCards count]>0)
	   highCard = [remainingCards objectAtIndex:[remainingCards count]-1];
	
	//check 4 of a kind
	if(maxDupes==4)
		return 8000000+[maxCard intValue]*15+[highCard intValue];
	
	// full house
	if(maxDupes==3 && secondDupes==2)
		return 7000000 + ([maxCard intValue]*15) + [secondCard intValue];
	
	//Flush
	if(maxSuits>4)
		return handStrength;
	
	//Straights
	NSMutableDictionary *valueDict = [[NSMutableDictionary alloc] init];
	for(NSString *value in cardValues)
		[valueDict setObject:@"1" forKey:[NSString stringWithFormat:@"%02d", [value intValue]]];
	
    int max=0;
	for(int i=1; i<=10; i++) {
		NSString *value1 = [NSString stringWithFormat:@"%02d", i];
		if(i==1)
			value1 = @"14"; // ace
		NSString *value2 = [NSString stringWithFormat:@"%02d", i+1];
		NSString *value3 = [NSString stringWithFormat:@"%02d", i+2];
		NSString *value4 = [NSString stringWithFormat:@"%02d", i+3];
		NSString *value5 = [NSString stringWithFormat:@"%02d", i+4];
		if([[valueDict objectForKey:value1] isEqualToString:@"1"] &&
		   [[valueDict objectForKey:value2] isEqualToString:@"1"] &&
		   [[valueDict objectForKey:value3] isEqualToString:@"1"] &&
		   [[valueDict objectForKey:value4] isEqualToString:@"1"] &&
		   [[valueDict objectForKey:value5] isEqualToString:@"1"])
			max=i;
	}
    if(max>0)
        return 5000000+(max*1000);
	
	// trips
	if(maxDupes==3 && [remainingCards count]>1)
		return 4000000 + ([maxCard intValue]*225) + 15*[[remainingCards objectAtIndex:[remainingCards count]-1] intValue] + [[remainingCards objectAtIndex:[remainingCards count]-2] intValue];
	
	// 2 pair
	if(maxDupes==2 && secondDupes==2 && [remainingCards count]>0)
		return 3000000 + ([maxCard intValue]*225) + ([secondCard intValue]*15) + [[remainingCards objectAtIndex:[remainingCards count]-1] intValue];
	
	// pair
	if(maxDupes==2 && [remainingCards count]>2)
		return 2000000 + ([maxCard intValue]*3375) + 225*[[remainingCards objectAtIndex:[remainingCards count]-1] intValue] + 15*[[remainingCards objectAtIndex:[remainingCards count]-2] intValue] + [[remainingCards objectAtIndex:[remainingCards count]-3] intValue];
	
	// junk
	if([remainingCards count]>4)
		return 1000000 + 50625*[[remainingCards objectAtIndex:[remainingCards count]-1] intValue] + 3375*[[remainingCards objectAtIndex:[remainingCards count]-2] intValue] + 225*[[remainingCards objectAtIndex:[remainingCards count]-3] intValue] + 15*[[remainingCards objectAtIndex:[remainingCards count]-4] intValue] + 1*[[remainingCards objectAtIndex:[remainingCards count]-5] intValue];
	
	return handStrength;
}

+(NSString *)getNameOfhandFromValue:(int)handValue
{
	NSArray *names = [NSArray arrayWithObjects:@"-", @"Junk", @"Pair", @"2 Pair", @"Trips", @"Straight", @"Flush", @"Full House", @"Quads", @"Straight-Flush", @"NO", nil];
	int index = [[[NSString stringWithFormat:@"%d", handValue] substringToIndex:1] intValue];
	return [names objectAtIndex:index];
}

+(NSArray *)getPlayerResultsForHand:(NSArray *)playerHands flop:(NSString *)flop turn:(NSString *)turn river:(NSString *)river includeHandString:(BOOL)includeHandString
{
	int hiHand=0;
	int numberWinning=0;
	NSMutableArray *playerhandStrength = [[NSMutableArray alloc] init];
	for(NSString *hand in playerHands) { // first determine if we have a single winner or chopped pot
		int handStrength = [PokerOddsFunctions determinHandStrength:hand flop:flop turn:turn river:river];
		[playerhandStrength addObject:[NSString stringWithFormat:@"%d", handStrength]];
		if(handStrength==hiHand)
			numberWinning++;
		if(handStrength>hiHand) {
			hiHand = handStrength;
			numberWinning=1;
		}
	}
	NSMutableArray *playerhandResults = [[NSMutableArray alloc] init];
	for(int i=0; i<playerHands.count; i++) {
		int handStrength = [[playerhandStrength objectAtIndex:i] intValue];
		NSString *handname = [PokerOddsFunctions getNameOfhandFromValue:handStrength];
		NSString *result=@"Loss";
		NSString *win = @"Win";
		if(numberWinning>1)
			win = @"Chop";
		if(handStrength>=hiHand)
			result=win;
		
		if(includeHandString)
			result = [NSString stringWithFormat:@"%@ (%@)", result, handname];
		[playerhandResults addObject:result];
	}
	return playerhandResults;
}

+(NSString *)getSeededHand:(NSString *)burnedCards seed:(int)seed {
	NSArray *card = [NSArray arrayWithObjects:@"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"T", @"J", @"Q", @"K", @"A", nil];
	NSArray *suit = [NSArray arrayWithObjects:@"c", @"d", @"h", @"s", nil];
//	int rc = arc4random()%13;
//	int rs = arc4random()%4;
	int rc=seed%13;
	int rs=seed%4;
	NSString *randomCard = [NSString stringWithFormat:@"%@%@", [card objectAtIndex:rc], [suit objectAtIndex:rs]];
	if([burnedCards rangeOfString:randomCard].location != NSNotFound)
		return @"NO";
	
	return randomCard;
	
}

+(NSArray *)calculateTotalsandReturnTheStrings:(NSString *)newTotals numPlayers:(int)numPlayers
{
	NSArray *parts = [newTotals componentsSeparatedByString:@"|"];
	int numberHands = [[parts objectAtIndex:0] intValue];
	NSArray *wins = [[parts objectAtIndex:1] componentsSeparatedByString:@","];
	NSArray *chops = [[parts objectAtIndex:2] componentsSeparatedByString:@","];
	int winninghands[10] = {[[wins objectAtIndex:0] intValue],
		[[wins objectAtIndex:1] intValue],
		[[wins objectAtIndex:2] intValue],
		[[wins objectAtIndex:3] intValue],
		[[wins objectAtIndex:4] intValue],
		[[wins objectAtIndex:5] intValue],
		[[wins objectAtIndex:6] intValue],
		[[wins objectAtIndex:7] intValue],
		[[wins objectAtIndex:8] intValue],
		[[wins objectAtIndex:9] intValue]};
	int choppinghands[10] = {[[chops objectAtIndex:0] intValue],
		[[chops objectAtIndex:1] intValue],
		[[chops objectAtIndex:2] intValue],
		[[chops objectAtIndex:3] intValue],
		[[chops objectAtIndex:4] intValue],
		[[chops objectAtIndex:5] intValue],
		[[chops objectAtIndex:6] intValue],
		[[chops objectAtIndex:7] intValue],
		[[chops objectAtIndex:8] intValue],
		[[chops objectAtIndex:9] intValue]};
	
	NSMutableArray *playerHandPercents = [[NSMutableArray alloc] init];
	for(int i=0; i<numPlayers; i++) {
		int winPercent = 0;
		int chopPercent = 0;
		if(numberHands>0) {
			winPercent = 100*winninghands[i]/numberHands;
			chopPercent = 100*choppinghands[i]/numberHands;
		}
		if(chopPercent>0)
			[playerHandPercents addObject:[NSString stringWithFormat:@"Win %d%% (Chop %d%%)", winPercent, chopPercent]];
		else
			[playerHandPercents addObject:[NSString stringWithFormat:@"Win %d%%", winPercent]];
	}
	return playerHandPercents;
}

+(NSString *)getPlayerResultsTotals:(NSString *)totals playerHands:(NSArray *)playerHands flop:(NSString *)flop turn:(NSString *)turn
{
	if([turn isEqualToString:@"NO"])
		return totals;
	
	NSArray *parts = [totals componentsSeparatedByString:@"|"];
	int numberHands = [[parts objectAtIndex:0] intValue];
	NSArray *wins = [[parts objectAtIndex:1] componentsSeparatedByString:@","];
	NSArray *chops = [[parts objectAtIndex:2] componentsSeparatedByString:@","];
	int winninghands[10] = {[[wins objectAtIndex:0] intValue],
		[[wins objectAtIndex:1] intValue],
		[[wins objectAtIndex:2] intValue],
		[[wins objectAtIndex:3] intValue],
		[[wins objectAtIndex:4] intValue],
		[[wins objectAtIndex:5] intValue],
		[[wins objectAtIndex:6] intValue],
		[[wins objectAtIndex:7] intValue],
		[[wins objectAtIndex:8] intValue],
		[[wins objectAtIndex:9] intValue]};
	int choppinghands[10] = {[[chops objectAtIndex:0] intValue],
		[[chops objectAtIndex:1] intValue],
		[[chops objectAtIndex:2] intValue],
		[[chops objectAtIndex:3] intValue],
		[[chops objectAtIndex:4] intValue],
		[[chops objectAtIndex:5] intValue],
		[[chops objectAtIndex:6] intValue],
		[[chops objectAtIndex:7] intValue],
		[[chops objectAtIndex:8] intValue],
		[[chops objectAtIndex:9] intValue]};
	
	
	NSString *burnedCards = [NSString stringWithFormat:@"%@|%@|%@", [playerHands componentsJoinedByString:@"|"], flop, turn];
	for(int i=0; i<52; i++) {
		NSString *randomHand = [PokerOddsFunctions getSeededHand:burnedCards seed:i];
		if(![randomHand isEqualToString:@"NO"]) {
			numberHands++;
			NSArray *playerResults = [PokerOddsFunctions getPlayerResultsForHand:playerHands flop:flop turn:turn river:randomHand includeHandString:NO];
			int x=0;
			for(NSString *resultText in playerResults) {
				if([resultText isEqualToString:@"Win"])
					winninghands[x]++;
				if([resultText isEqualToString:@"Chop"])
					choppinghands[x]++;
				x++;
			}
		}
	}
	return [NSString stringWithFormat:@"%d|%d,%d,%d,%d,%d,%d,%d,%d,%d,%d|%d,%d,%d,%d,%d,%d,%d,%d,%d,%d", numberHands,
			winninghands[0],
			winninghands[1],
			winninghands[2],
			winninghands[3],
			winninghands[4],
			winninghands[5],
			winninghands[6],
			winninghands[7],
			winninghands[8],
			winninghands[9],
			choppinghands[0],
			choppinghands[1],
			choppinghands[2],
			choppinghands[3],
			choppinghands[4],
			choppinghands[5],
			choppinghands[6],
			choppinghands[7],
			choppinghands[8],
			choppinghands[9]
			];
}

+(NSArray *)getPlayerResultsForPreFlop:(NSArray *)playerHands
{
	NSString *burnedCards = [PokerOddsFunctions getBurnedCards:playerHands flop:@"" turn:@"" river:@""];
	NSString *totals = @"0|0,0,0,0,0,0,0,0,0,0|0,0,0,0,0,0,0,0,0,0";
	for(int x=1;x<=150;x++) {
		NSString *flop = [PokerOddsFunctions getRandomFlop:burnedCards];
		NSString *turn = [PokerOddsFunctions getRandomCard:burnedCards];
		totals = [PokerOddsFunctions getPlayerResultsTotals:totals playerHands:playerHands flop:flop turn:turn];
	}
	return [PokerOddsFunctions calculateTotalsandReturnTheStrings:totals numPlayers:[playerHands count]];
}

+(NSArray *)getPlayerResultsForFlop:(NSArray *)playerHands flop:(NSString *)flop
{
	NSString *burnedCards = [NSString stringWithFormat:@"%@|%@", [playerHands componentsJoinedByString:@"|"], flop];
	
	NSString *totals = @"0|0,0,0,0,0,0,0,0,0,0|0,0,0,0,0,0,0,0,0,0";
	//	NSLog(@"--------Start");
	for(int i=0; i<52; i++) {
		totals = [PokerOddsFunctions getPlayerResultsTotals:totals playerHands:playerHands flop:flop turn:[PokerOddsFunctions getSeededHand:burnedCards seed:i]];
	}
	//	NSLog(@"--------Stop");
	return [PokerOddsFunctions calculateTotalsandReturnTheStrings:totals numPlayers:[playerHands count]];
	
}


+(NSArray *)getPlayerResultsForTurn:(NSArray *)playerHands flop:(NSString *)flop turn:(NSString *)turn
{
	NSString *totals = @"0|0,0,0,0,0,0,0,0,0,0|0,0,0,0,0,0,0,0,0,0";
	NSString *newTotals = [PokerOddsFunctions getPlayerResultsTotals:totals playerHands:playerHands flop:flop turn:turn];
//	NSLog(newTotals);
	return [PokerOddsFunctions calculateTotalsandReturnTheStrings:newTotals numPlayers:[playerHands count]];
	
}










@end
