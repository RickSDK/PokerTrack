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
    
    int sortedCount = (int)[sortedList count];
    

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
	// new group into combos
	NSMutableDictionary *cardDictionary = [[NSMutableDictionary alloc] init];
	for(NSString *cardValue in cardValues) {
		int number = [[cardDictionary objectForKey:cardValue] intValue];
		number++;
		[cardDictionary setObject:[NSString stringWithFormat:@"%02d", number] forKey:cardValue];
	}
	int highestQuad = 0;
	int highestTrip = 0;
	int secondTrip = 0;
	int highestPair = 0;
	int secondPair = 0;
	int highestJunk = 0;
	int secondJunk = 0;
	int thirdJunk = 0;
	int fourthJunk = 0;
	int fifthJunk = 0;
	for(NSString *key in cardDictionary.allKeys) {
		int cardNum = key.intValue;
		int number = [[cardDictionary valueForKey:key] intValue];
		if(number==4 && cardNum>highestQuad)
			highestQuad=cardNum;
		if(number==3 && cardNum>secondTrip) {
			if(cardNum>highestTrip) {
				secondTrip=highestTrip;
				highestTrip=cardNum;
			} else
				secondTrip=cardNum;
		}
		if(number==2 && cardNum>secondPair) {
			if(cardNum>highestPair) {
				secondPair=highestPair;
				highestPair=cardNum;
			} else
				secondPair=cardNum;
		}
		if(number==1 && cardNum>fifthJunk) {
			if(cardNum>highestJunk) {
				secondJunk=highestJunk;
				highestJunk=cardNum;
			} else if(cardNum>secondJunk) {
				thirdJunk=secondJunk;
				secondJunk=cardNum;
			} else if(cardNum>thirdJunk) {
				fourthJunk=thirdJunk;
				thirdJunk=cardNum;
			} else if(cardNum>fourthJunk) {
				fifthJunk=fourthJunk;
				fourthJunk=cardNum;
			} else if(cardNum>fifthJunk) {
				fifthJunk=cardNum;
			}
		}
	}
	
	//check 4 of a kind
	if(highestQuad>0) {
		if(highestTrip>highestJunk)
			highestJunk=highestTrip;
		if(highestPair>highestJunk)
			highestJunk=highestPair;
		return 8000000+highestQuad*15+highestJunk;
	}
	
	// full house
	if( (highestTrip>0 && secondTrip>0) || (highestTrip>0 && highestPair>0)) {
		if(secondTrip>highestPair)
			highestPair=secondTrip;
		
		return 7000000 + (highestTrip*15) + highestPair;
	}
	
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
	if(highestTrip>0)
		return 4000000 + highestTrip*225 + highestJunk*15 + secondJunk;
	
	// 2 pair
	if(secondPair>0)
		return 3000000 + (highestPair*225) + (secondPair*15) + highestJunk;
	
	// pair
	if(highestPair>0)
		return 2000000 + highestPair*3375 + highestJunk*225 + secondJunk*15 + thirdJunk;
	
	return 1000000 + highestJunk*50625 + secondJunk*3375 + thirdJunk*225 + fourthJunk*15 + fifthJunk;
}

+(NSString *)getNameOfhandFromValue:(int)handValue
{
	NSArray *names = [NSArray arrayWithObjects:@"Junk", @"Junk", @"Pair", @"2 Pair", @"Trips", @"Straight", @"Flush", @"Full House", @"Quads", @"Straight-Flush", @"5 of a Kind", @"NO", @"NO", nil];
	int index = handValue/1000000;
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
	return [PokerOddsFunctions calculateTotalsandReturnTheStrings:totals numPlayers:(int)[playerHands count]];
}

+(NSArray *)getPlayerResultsForFlop:(NSArray *)playerHands flop:(NSString *)flop
{
	NSString *burnedCards = [NSString stringWithFormat:@"%@|%@", [playerHands componentsJoinedByString:@"|"], flop];
	
	NSString *totals = @"0|0,0,0,0,0,0,0,0,0,0|0,0,0,0,0,0,0,0,0,0";
	for(int x=1;x<=150;x++) {
		NSString *turn = [PokerOddsFunctions getRandomCard:burnedCards];
		totals = [PokerOddsFunctions getPlayerResultsTotals:totals playerHands:playerHands flop:flop turn:turn];
	}
	return [PokerOddsFunctions calculateTotalsandReturnTheStrings:totals numPlayers:(int)[playerHands count]];
	
	//	NSLog(@"--------Start");
	for(int i=0; i<52; i++) {
		totals = [PokerOddsFunctions getPlayerResultsTotals:totals playerHands:playerHands flop:flop turn:[PokerOddsFunctions getSeededHand:burnedCards seed:i]];
	}
	//	NSLog(@"--------Stop");
	return [PokerOddsFunctions calculateTotalsandReturnTheStrings:totals numPlayers:(int)[playerHands count]];
	
}


+(NSArray *)getPlayerResultsForTurn:(NSArray *)playerHands flop:(NSString *)flop turn:(NSString *)turn
{
	NSString *totals = @"0|0,0,0,0,0,0,0,0,0,0|0,0,0,0,0,0,0,0,0,0";
	NSString *newTotals = [PokerOddsFunctions getPlayerResultsTotals:totals playerHands:playerHands flop:flop turn:turn];
//	NSLog(newTotals);
	return [PokerOddsFunctions calculateTotalsandReturnTheStrings:newTotals numPlayers:(int)[playerHands count]];
	
}










@end
