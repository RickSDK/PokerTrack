//
//  MultiCellObj.m
//  PokerTracker
//
//  Created by Rick Medved on 7/7/17.
//
//

#import "MultiCellObj.h"
#import "ProjectFunctions.h"

@implementation MultiCellObj

-(void)removeAllObjects {
	[self.titles removeAllObjects];
	[self.values removeAllObjects];
	[self.colors removeAllObjects];
}

-(void)addLineWithTitle:(NSString *)title value:(NSString *)value color:(UIColor *)color {
	[self.titles addObject:NSLocalizedString(title, nil)];
	[self.values addObject:value];
	[self.colors addObject:color];
}

-(void)addIntLineWithTitle:(NSString *)title value:(int)value color:(UIColor *)color {
	if(color==nil)
		color = [UIColor blackColor];
	[self.titles addObject:NSLocalizedString(title, nil)];
	[self.values addObject:[NSString stringWithFormat:@"%d", value]];
	[self.colors addObject:color];
}

-(void)addBlackLineWithTitle:(NSString *)title value:(NSString *)value {
	if(!value)
		value=@"-";
	[self.titles addObject:NSLocalizedString(title, nil)];
	[self.values addObject:value];
	[self.colors addObject:[UIColor blackColor]];
}

-(void)addMoneyLineWithTitle:(NSString *)title amount:(double)amount {
	[self.titles addObject:NSLocalizedString(title, nil)];
	[self.values addObject:[ProjectFunctions convertNumberToMoneyString:amount]];
	[self.colors addObject:[ProjectFunctions colorForProfit:amount]];
}

-(void)addColoredLineWithTitle:(NSString *)title value:(NSString *)value amount:(double)amount {
	[self.titles addObject:NSLocalizedString(title, nil)];
	[self.values addObject:value];
	[self.colors addObject:[ProjectFunctions colorForProfit:amount]];
}

+(MultiCellObj *)initWithTitle:(NSString *)mainTitle altTitle:(NSString *)altTitle labelPercent:(float)labelPercent {
	MultiCellObj *obj = [[MultiCellObj alloc] init];
	obj.mainTitle = mainTitle;
	obj.altTitle = altTitle;
	obj.labelPercent = labelPercent;
	obj.titles = [[NSMutableArray alloc] init];
	obj.values = [[NSMutableArray alloc] init];
	obj.colors = [[NSMutableArray alloc] init];
	return obj;
}

+(MultiCellObj *)multiCellObjWithTitle:(NSString *)mainTitle altTitle:(NSString *)altTitle titles:(NSMutableArray *)titles values:(NSMutableArray *)values colors:(NSMutableArray *)colors labelPercent:(float)labelPercent {
	MultiCellObj *obj = [MultiCellObj initWithTitle:mainTitle altTitle:altTitle labelPercent:labelPercent];
	obj.mainTitle = mainTitle;
	obj.altTitle = altTitle;
	obj.titles = titles;
	obj.values = values;
	obj.colors = colors;
	obj.labelPercent = labelPercent;
	return obj;
}

-(void)populateObjWithGame:(GameObj *)gameObj {
	[self removeAllObjects];
	self.mainTitle = gameObj.name;
	self.altTitle = gameObj.location;
	NSString *currentChips = @"Current Chips";
	if([@"Completed" isEqualToString:gameObj.status])
		currentChips = @"cashoutAmount";
	[self addBlackLineWithTitle:@"Type" value:NSLocalizedString(gameObj.type, nil)];
	[self addBlackLineWithTitle:@"Game" value:gameObj.gametype];
	if(gameObj.tournamentGameFlg)
		[self addBlackLineWithTitle:@"Tournament Type" value:gameObj.tournamentType];
	else
		[self addBlackLineWithTitle:@"stakes" value:gameObj.stakes];
	[self addBlackLineWithTitle:@"limit" value:gameObj.limit];
	[self addBlackLineWithTitle:@"Date" value:gameObj.startTimeStr];
	[self addBlackLineWithTitle:@"weekday" value:gameObj.weekdayAltStr];
	[self addMoneyLineWithTitle:@"Buyin" amount:gameObj.buyInAmount];
	[self addBlackLineWithTitle:@"numRebuys" value:gameObj.numRebuysStr];
	if(gameObj.numRebuys>0)
		[self addMoneyLineWithTitle:@"rebuyAmount" amount:gameObj.reBuyAmount];
	[self addMoneyLineWithTitle:currentChips amount:gameObj.cashoutAmount];
	if(gameObj.foodDrink>0) {
		[self addMoneyLineWithTitle:@"Take-Home" amount:gameObj.takeHome];
		[self addBlackLineWithTitle:@"foodDrink" value:gameObj.foodDrinkStr];
	}
	[self addMoneyLineWithTitle:@"Profit" amount:gameObj.profit];
	[self addBlackLineWithTitle:@"Hours" value:gameObj.hours];
	if(gameObj.breakMinutes>0) {
		[self addIntLineWithTitle:@"breakMinutes" value:gameObj.breakMinutes color:nil];
	}
	[self addLineWithTitle:@"Hourly" value:gameObj.hourlyStr color:[ProjectFunctions colorForProfit:gameObj.profit]];
	[self addLineWithTitle:@"ROI" value:gameObj.pprStr color:[ProjectFunctions colorForProfit:gameObj.profit]];
	if(gameObj.tokes>0) {
		[self addBlackLineWithTitle:@"Tips" value:gameObj.tokesStr];
		[self addMoneyLineWithTitle:@"IncomeTotal" amount:gameObj.grossIncome];
	}
	
	if(gameObj.isTourney) {
		[self addIntLineWithTitle:@"tournamentSpots" value:gameObj.tournamentSpots color:nil];
		[self addIntLineWithTitle:@"tournamentSpotsPaid" value:gameObj.tournamentSpotsPaid color:nil];
		[self addIntLineWithTitle:@"tournamentFinish" value:gameObj.tournamentFinish color:[UIColor blueColor]];
	}
	if(gameObj.hudStatsFlg) {
		[self addLineWithTitle:@"VPIP / PFR" value:gameObj.hudVpip color:[UIColor purpleColor]];
		[self addLineWithTitle:@"HUD Play" value:gameObj.hudPlayerType color:[UIColor purpleColor]];
		[self addLineWithTitle:@"HUD Skill Level" value:gameObj.hudSkillLevel color:[UIColor purpleColor]];
	}
	[self addBlackLineWithTitle:@"notes" value:gameObj.notes];
}

/*
+(MultiCellObj *)buildsMultiLineObjWithGame:(GameObj *)gameObj {
	MultiCellObj *obj = [MultiCellObj initWithTitle:gameObj.name altTitle:gameObj.location labelPercent:0.5];

	NSString *currentChips = @"Current Chips";
	if([@"Completed" isEqualToString:gameObj.status])
		currentChips = @"cashoutAmount";
	[obj addBlackLineWithTitle:@"Type" value:NSLocalizedString(gameObj.type, nil)];
	[obj addBlackLineWithTitle:@"Game" value:gameObj.gametype];
	if(gameObj.tournamentGameFlg)
		[obj addBlackLineWithTitle:@"Tournament Type" value:gameObj.tournamentType];
	else
		[obj addBlackLineWithTitle:@"stakes" value:gameObj.stakes];
	[obj addBlackLineWithTitle:@"limit" value:gameObj.limit];
	[obj addBlackLineWithTitle:@"Date" value:gameObj.startTimeStr];
	[obj addBlackLineWithTitle:@"weekday" value:gameObj.weekdayAltStr];
	[obj addMoneyLineWithTitle:@"Buyin" amount:gameObj.buyInAmount];
	[obj addBlackLineWithTitle:@"numRebuys" value:gameObj.numRebuysStr];
	if(gameObj.numRebuys>0)
		[obj addMoneyLineWithTitle:@"rebuyAmount" amount:gameObj.reBuyAmount];
	[obj addMoneyLineWithTitle:currentChips amount:gameObj.cashoutAmount];
	if(gameObj.foodDrink>0) {
		[obj addMoneyLineWithTitle:@"Take-Home" amount:gameObj.takeHome];
		[obj addBlackLineWithTitle:@"foodDrink" value:gameObj.foodDrinkStr];
	}
	[obj addMoneyLineWithTitle:@"Profit" amount:gameObj.profit];
	[obj addBlackLineWithTitle:@"Hours" value:gameObj.hours];
	if(gameObj.breakMinutes>0) {
		[obj addIntLineWithTitle:@"breakMinutes" value:gameObj.breakMinutes color:nil];
	}
	[obj addLineWithTitle:@"Hourly" value:gameObj.hourlyStr color:[ProjectFunctions colorForProfit:gameObj.profit]];
	[obj addLineWithTitle:@"ROI" value:gameObj.pprStr color:[ProjectFunctions colorForProfit:gameObj.profit]];
	if(gameObj.tokes>0) {
		[obj addBlackLineWithTitle:@"Tips" value:gameObj.tokesStr];
		[obj addMoneyLineWithTitle:@"IncomeTotal" amount:gameObj.grossIncome];
	}
	
	if(gameObj.isTourney) {
		[obj addIntLineWithTitle:@"tournamentSpots" value:gameObj.tournamentSpots color:nil];
		[obj addIntLineWithTitle:@"tournamentSpotsPaid" value:gameObj.tournamentSpotsPaid color:nil];
		[obj addIntLineWithTitle:@"tournamentFinish" value:gameObj.tournamentFinish color:[UIColor blueColor]];
	}
	if(gameObj.hudStatsFlg) {
		[obj addLineWithTitle:@"HUD Play" value:gameObj.hudPlayerType color:[UIColor purpleColor]];
	}
	[obj addBlackLineWithTitle:@"notes" value:gameObj.notes];
	return obj;
}
*/

@end
