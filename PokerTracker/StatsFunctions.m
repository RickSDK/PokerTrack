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
	
	NSArray *titles = [NSArray arrayWithObjects:@"Profit", @"Games", @"Current Streak", @"Long Win Streak", @"Long Lose Streak", @"Hours Played", @"Hourly Rate", nil];
	NSMutableArray *colorArray = [[NSMutableArray alloc] init];
	
	[colorArray addObject:[CoreDataLib getFieldColor:[[statsArray objectAtIndex:0] intValue]]];
	[colorArray addObject:[UIColor blackColor]];
	[colorArray addObject:[CoreDataLib getFieldColor:[[statsArray objectAtIndex:2] intValue]]];
	[colorArray addObject:[CoreDataLib getFieldColor:[[statsArray objectAtIndex:3] intValue]]];
	[colorArray addObject:[CoreDataLib getFieldColor:[[statsArray objectAtIndex:4] intValue]]];
	[colorArray addObject:[UIColor blackColor]];
	[colorArray addObject:[CoreDataLib getFieldColor:[[statsArray objectAtIndex:6] intValue]]];
	
	NSMutableArray *valueArray = [[NSMutableArray alloc] initWithArray:statsArray];
	int money = [[statsArray objectAtIndex:0] intValue];
	[valueArray replaceObjectAtIndex:0 withObject:[ProjectFunctions convertIntToMoneyString:money]];
	int streak = [[statsArray objectAtIndex:2] intValue];
	[valueArray replaceObjectAtIndex:2 withObject:[ProjectFunctions getWinLossStreakString:streak]];
	streak = [[statsArray objectAtIndex:3] intValue];
	[valueArray replaceObjectAtIndex:3 withObject:[ProjectFunctions getWinLossStreakString:streak]];
	streak = [[statsArray objectAtIndex:4] intValue];
	[valueArray replaceObjectAtIndex:4 withObject:[ProjectFunctions getWinLossStreakString:streak]];
	
	[valueArray replaceObjectAtIndex:6 withObject:[NSString stringWithFormat:@"%@%@/hr", [ProjectFunctions getMoneySymbol], [statsArray objectAtIndex:6]]];
	
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
	
	cell.alternateTitle = @"Profit";
	
	
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
