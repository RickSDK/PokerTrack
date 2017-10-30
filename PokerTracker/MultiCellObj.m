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
	if(title)
		[self.titles addObject:[ProjectFunctions localizedTitle:title]];
	else
		[self.titles addObject:@"-error-"];
	if(value)
		[self.values addObject:value];
	else
		[self.values addObject:@"-"];
	if(color)
		[self.colors addObject:color];
	else
		[self.colors addObject:[UIColor blackColor]];
}

-(void)addIntLineWithTitle:(NSString *)title value:(int)value color:(UIColor *)color {
	[self addLineWithTitle:title value:[NSString stringWithFormat:@"%d", value] color:color];
}

-(void)addBlackLineWithTitle:(NSString *)title value:(NSString *)value {
	[self addLineWithTitle:title value:value color:nil];
}

-(void)addMoneyLineWithTitle:(NSString *)title amount:(double)amount {
	[self addLineWithTitle:title value:[ProjectFunctions convertNumberToMoneyString:amount] color:[ProjectFunctions colorForProfit:amount]];
}

-(void)addColoredLineWithTitle:(NSString *)title value:(NSString *)value amount:(double)amount {
	[self addLineWithTitle:title value:value color:[ProjectFunctions colorForProfit:amount]];
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
	if(gameObj.tournamentGameFlg)
		currentChips = @"Current Value";
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
	if(![@"Default" isEqualToString:gameObj.bankroll])
		[self addBlackLineWithTitle:@"bankroll" value:gameObj.bankroll];
		
	[self addBlackLineWithTitle:@"Buyin" value:gameObj.buyInAmountStr];
	[self addBlackLineWithTitle:@"numRebuys" value:gameObj.numRebuysStr];
	if(gameObj.numRebuys>0)
		[self addBlackLineWithTitle:@"rebuyAmount" value:gameObj.reBuyAmountStr];
	[self addBlackLineWithTitle:currentChips value:gameObj.cashoutAmountStr];
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
		[self addMoneyLineWithTitle:@"Starting Chips" amount:gameObj.startingChips];
		if(gameObj.rebuyChips>0)
			[self addMoneyLineWithTitle:@"Rebuy Chips" amount:gameObj.rebuyChips];
		if(![@"Completed" isEqualToString:gameObj.status])
			[self addMoneyLineWithTitle:@"Current Chips" amount:gameObj.currentChips];
		[self addIntLineWithTitle:@"tournamentSpots" value:gameObj.tournamentSpots color:nil];
		[self addIntLineWithTitle:@"tournamentSpotsPaid" value:gameObj.tournamentSpotsPaid color:nil];
		[self addLineWithTitle:@"tournamentFinish" value:gameObj.tournamentFinishStr color:[UIColor purpleColor]];
	}
	if(gameObj.hudStatsFlg) {
		[self addLineWithTitle:@"VPIP / PFR (AF)" value:gameObj.hudVpip color:[UIColor colorWithRed:0 green:0 blue:.5 alpha:1]];
		[self addLineWithTitle:@"HUD Play" value:gameObj.hudPlayerType color:[UIColor colorWithRed:0 green:0 blue:.5 alpha:1]];
		[self addLineWithTitle:@"HUD Detailed Play" value:gameObj.hudPlayerTypeLong color:[UIColor colorWithRed:0 green:0 blue:.5 alpha:1]];
		[self addLineWithTitle:@"HUD Skill Level" value:gameObj.hudSkillLevel color:[UIColor colorWithRed:0 green:0 blue:.5 alpha:1]];
		if(gameObj.hudVillianName.length>0) {
			[self addLineWithTitle:@"HUD Villian" value:gameObj.hudVillianName color:[UIColor colorWithRed:.5 green:0 blue:0 alpha:1]];
			[self addLineWithTitle:@"HUD Villian Play" value:gameObj.hudVillianTypeLong color:[UIColor colorWithRed:.5 green:0 blue:0 alpha:1]];
		}
		
	}
	[self addBlackLineWithTitle:@"notes" value:gameObj.notes];
}

@end
