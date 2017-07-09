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
	NSArray *titles = [NSArray arrayWithObjects:
					   NSLocalizedString(@"Type", nil),
					   NSLocalizedString(@"Date", nil),
					   NSLocalizedString(@"Weekday", nil),
					   NSLocalizedString(@"Hours", nil),
					   NSLocalizedString(@"Buyin", nil),
					   NSLocalizedString(@"Number of Rebuys", nil),
					   NSLocalizedString(@"Re-buy Amount", nil),
					   NSLocalizedString(@"Current Chips", nil),
					   NSLocalizedString(@"IncomeTotal", nil),
					   NSLocalizedString(@"Take-Home", nil),
					   NSLocalizedString(@"Profit", nil),
					   NSLocalizedString(@"ROI", nil),
					   NSLocalizedString(@"Notes", nil),
					   nil];
	NSArray *values = [NSArray arrayWithObjects:
					   gameObj.type,
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
					   nil];
	NSArray *colors = [NSArray arrayWithObjects:
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
					   nil];
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
