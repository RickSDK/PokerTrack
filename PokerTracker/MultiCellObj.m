//
//  MultiCellObj.m
//  PokerTracker
//
//  Created by Rick Medved on 7/7/17.
//
//

#import "MultiCellObj.h"

@implementation MultiCellObj

+(MultiCellObj *)multiCellObjWithTitle:(NSString *)mainTitle altTitle:(NSString *)altTitle titles:(NSArray *)titles values:(NSArray *)values colors:(NSArray *)colors labelPercent:(float)labelPercent {
	MultiCellObj *obj = [[MultiCellObj alloc] init];
	obj.mainTitle = mainTitle;
	obj.altTitle = altTitle;
	obj.titles = titles;
	obj.values = values;
	obj.colors = colors;
	obj.labelPercent = labelPercent;
	return obj;
}

+(MultiCellObj *)buildsMultiLineObjWithGame:(GameObj *)gameObj {
	NSString *currentChips = @"Current Chips";
	if([@"Completed" isEqualToString:gameObj.status])
		currentChips = @"cashoutAmount";
	NSMutableArray *titles = [[NSMutableArray alloc] initWithArray:[NSArray arrayWithObjects:
					   NSLocalizedString(@"Type", nil),
					   NSLocalizedString(@"Date", nil),
					   NSLocalizedString(@"weekday", nil),
					   NSLocalizedString(@"Hours", nil),
					   NSLocalizedString(@"Buyin", nil),
					   NSLocalizedString(@"numRebuys", nil),
					   NSLocalizedString(@"rebuyAmount", nil),
					   NSLocalizedString(currentChips, nil),
					   NSLocalizedString(@"IncomeTotal", nil),
					   NSLocalizedString(@"Take-Home", nil),
					   NSLocalizedString(@"Profit", nil),
					   NSLocalizedString(@"ROI", nil),
					   NSLocalizedString(@"notes", nil),
					   nil]];
	NSMutableArray *values = [[NSMutableArray alloc] initWithArray:[NSArray arrayWithObjects:
					   NSLocalizedString(gameObj.type, nil),
					   gameObj.startTimeStr,
					   gameObj.weekdayAltStr,
					   gameObj.hours,
					   gameObj.buyInAmountStr,
					   gameObj.numRebuysStr,
					   gameObj.reBuyAmountStr,
					   gameObj.cashoutAmountStr,
					   gameObj.grossIncomeStr,
					   gameObj.takeHomeStr,
					   gameObj.profitLongStr,
					   gameObj.roiStr,
					   gameObj.notes,
					   nil]];
	NSMutableArray *colors = [[NSMutableArray alloc] initWithArray:[NSArray arrayWithObjects:
					   [UIColor blackColor],
					   [UIColor blackColor],
					   [UIColor blackColor],
					   [UIColor blackColor],
					   [UIColor blackColor],
					   [UIColor blackColor],
					   [UIColor blackColor],
					   [UIColor blackColor],
					   [self colorForNumber:gameObj.grossIncome],
					   [self colorForNumber:gameObj.takeHome],
					   [self colorForNumber:gameObj.profit],
					   [UIColor blackColor],
					   [UIColor blackColor],
					   nil]];
	if(gameObj.breakMinutes>0) {
		[titles addObject:NSLocalizedString(@"breakMinutes", nil)];
		[values addObject:[NSString stringWithFormat:@"%d", gameObj.breakMinutes]];
		[colors addObject:[UIColor blackColor]];
	}
	if(gameObj.foodDrink>0) {
		[titles addObject:NSLocalizedString(@"foodDrink", nil)];
		[values addObject:gameObj.foodDrinkStr];
		[colors addObject:[UIColor blackColor]];
	}
	if(gameObj.tokes>0) {
		[titles addObject:NSLocalizedString(@"tips", nil)];
		[values addObject:gameObj.tokesStr];
		[colors addObject:[UIColor blackColor]];
	}
	if(gameObj.isTourney) {
		[titles addObject:NSLocalizedString(@"tournamentSpots", nil)];
		[titles addObject:NSLocalizedString(@"tournamentSpotsPaid", nil)];
		[titles addObject:NSLocalizedString(@"tournamentFinish", nil)];

		[values addObject:[NSString stringWithFormat:@"%d", gameObj.tournamentSpots]];
		[values addObject:[NSString stringWithFormat:@"%d", gameObj.tournamentSpotsPaid]];
		[values addObject:[NSString stringWithFormat:@"%d", gameObj.tournamentFinish]];

		[colors addObject:[UIColor blackColor]];
		[colors addObject:[UIColor blackColor]];
		[colors addObject:[UIColor purpleColor]];
	}
	if(gameObj.hudStatsFlg) {
		[titles addObject:@"HUD Play"];
		[values addObject:gameObj.hudPlayerType];
		[colors addObject:[UIColor blackColor]];
	}
	MultiCellObj *obj = [MultiCellObj multiCellObjWithTitle:gameObj.name altTitle:gameObj.location titles:titles values:values colors:colors labelPercent:0.5];
	return obj;
}

+(UIColor *)colorForNumber:(double)number {
	if (number>0)
		return [UIColor colorWithRed:0 green:.5 blue:0 alpha:1];
	if (number<0)
		return [UIColor redColor];
	return [UIColor blackColor];
}


@end
