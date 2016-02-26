//
//  GameObj.m
//  PokerTracker
//
//  Created by Rick Medved on 1/22/16.
//
//

#import "GameObj.h"
#import "ProjectFunctions.h"

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




@end
