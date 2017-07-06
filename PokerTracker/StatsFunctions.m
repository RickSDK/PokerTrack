//
//  StatsFunctions.m
//  PokerTracker
//
//  Created by Rick Medved on 11/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "StatsFunctions.h"
#import "MultiLineDetailCellWordWrap.h"
#import "ProjectFunctions.h"
#import "CoreDataLib.h"


@implementation StatsFunctions

+(UITableViewCell *)statsBreakdown:(UITableView *)tableView CellIdentifier:(NSString *)CellIdentifier title:(NSString *)title stats:(NSArray *)statsArray

{
	int NumberOfRows=(int)[statsArray count];
	MultiLineDetailCellWordWrap *cell = (MultiLineDetailCellWordWrap *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[MultiLineDetailCellWordWrap alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier withRows:NumberOfRows labelProportion:0.4];
	}
	
	cell.mainTitle = @"Game Stats";
	cell.alternateTitle = title;
	
	NSArray *titles = [NSArray arrayWithObjects:NSLocalizedString(@"Profit", nil), NSLocalizedString(@"Risked", nil), NSLocalizedString(@"Games", nil), @"Current Streak", @"Long Win Streak", @"Long Lose Streak", NSLocalizedString(@"Hours", nil), NSLocalizedString(@"Hourly", nil), @"ROI", nil];
	NSMutableArray *colorArray = [[NSMutableArray alloc] init];
	
	[colorArray addObject:[CoreDataLib getFieldColor:[[statsArray objectAtIndex:0] intValue]]];
	[colorArray addObject:[UIColor blackColor]];
	[colorArray addObject:[UIColor blackColor]];
	[colorArray addObject:[CoreDataLib getFieldColor:[[statsArray objectAtIndex:3] intValue]]];
	[colorArray addObject:[CoreDataLib getFieldColor:[[statsArray objectAtIndex:4] intValue]]];
	[colorArray addObject:[CoreDataLib getFieldColor:[[statsArray objectAtIndex:5] intValue]]];
	[colorArray addObject:[UIColor blackColor]];
	[colorArray addObject:[CoreDataLib getFieldColor:[[statsArray objectAtIndex:7] intValue]]];
	[colorArray addObject:[CoreDataLib getFieldColor:[[statsArray objectAtIndex:8] intValue]]];
	
	NSMutableArray *valueArray = [[NSMutableArray alloc] initWithArray:statsArray];
	double money = [[statsArray objectAtIndex:0] doubleValue];
	double risked = [[statsArray objectAtIndex:1] doubleValue];
	[valueArray replaceObjectAtIndex:0 withObject:[ProjectFunctions convertIntToMoneyString:money]];
	[valueArray replaceObjectAtIndex:1 withObject:[ProjectFunctions convertIntToMoneyString:risked]];
	int streak = [[statsArray objectAtIndex:3] intValue];
	[valueArray replaceObjectAtIndex:3 withObject:[ProjectFunctions getWinLossStreakString:streak]];
	streak = [[statsArray objectAtIndex:4] intValue];
	[valueArray replaceObjectAtIndex:4 withObject:[ProjectFunctions getWinLossStreakString:streak]];
	streak = [[statsArray objectAtIndex:5] intValue];
	[valueArray replaceObjectAtIndex:5 withObject:[ProjectFunctions getWinLossStreakString:streak]];
	
	[valueArray replaceObjectAtIndex:7 withObject:[NSString stringWithFormat:@"%@%@/hr", [ProjectFunctions getMoneySymbol], [statsArray objectAtIndex:7]]];
	[valueArray replaceObjectAtIndex:8 withObject:[NSString stringWithFormat:@"%@%%", [statsArray objectAtIndex:8]]];
	
	cell.titleTextArray = titles;
	cell.fieldTextArray = valueArray;
	cell.fieldColorArray = colorArray;
	
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	
	return cell;
}

+(UITableViewCell *)mainChartCell:(UITableView *)tableView CellIdentifier:(NSString *)CellIdentifier chartImageView:(UIImageView *)chartImageView
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
	}
	
	cell.backgroundView = chartImageView; 
	cell.backgroundColor = [UIColor whiteColor];
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	
	return cell;
}	


+(MultiLineDetailCellWordWrap *)quarterlyStats:(UITableView *)tableView CellIdentifier:(NSString *)CellIdentifier title:(NSString *)title statsArray:(NSArray *)statsArray{
	int NumberOfRows=(int)[statsArray count];
//	MultiLineDetailCellWordWrap *cell = (MultiLineDetailCellWordWrap *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//	if (cell == nil) {
		MultiLineDetailCellWordWrap *cell = [[MultiLineDetailCellWordWrap alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier withRows:NumberOfRows labelProportion:0.3];
//	}
	
	cell.mainTitle = title;
	
	cell.alternateTitle = NSLocalizedString(@"Profit", nil);
	
	
	NSMutableArray *titles = [[NSMutableArray alloc] init];
	NSMutableArray *valueArray = [[NSMutableArray alloc] init];
	NSMutableArray *colorArray = [[NSMutableArray alloc] init];
	
	
	for(NSString *line in statsArray) {
		NSArray *components = [line componentsSeparatedByString:@"|"];
		[titles addObject:[components objectAtIndex:0]];
		int money = [[components objectAtIndex:1] intValue];
		int numGames = [[components objectAtIndex:2] intValue];
		NSString *gamesTxt = (numGames==1)?@"Game":@"Games";
		[valueArray addObject:[NSString stringWithFormat:@"%@ (%d %@)", [ProjectFunctions convertIntToMoneyString:money], numGames, gamesTxt]];
		[colorArray addObject:[CoreDataLib getFieldColor:money]];
	}
	
	cell.titleTextArray = titles;
	cell.fieldTextArray = valueArray;
	cell.fieldColorArray = colorArray;
	
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	return cell;
}


@end
