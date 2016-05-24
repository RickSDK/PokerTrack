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
	gameObj.name = [mo valueForKey:@"name"];
	gameObj.startTime = [mo valueForKey:@"startTime"];
	gameObj.hours = [mo valueForKey:@"hours"];
	gameObj.minutes = [[mo valueForKey:@"minutes"] intValue];
	gameObj.profit = [[mo valueForKey:@"winnings"] intValue];
	gameObj.location = [mo valueForKey:@"location"];
	gameObj.status = [mo valueForKey:@"status"];
	
	gameObj.buyInAmount = [[mo valueForKey:@"buyInAmount"] intValue];
	gameObj.reBuyAmount = [[mo valueForKey:@"rebuyAmount"] intValue];
	gameObj.profit = [[mo valueForKey:@"winnings"] intValue];
	gameObj.ppr = [ProjectFunctions calculatePprAmountRisked:gameObj.buyInAmount+gameObj.reBuyAmount netIncome:gameObj.profit];
	
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
