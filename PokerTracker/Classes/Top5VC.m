//
//  Top5VC.m
//  PokerTracker
//
//  Created by Rick Medved on 3/9/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "Top5VC.h"
#import "ProjectFunctions.h"
#import "CoreDataLib.h"
#import "GameInProgressVC.h"
#import "GameGraphVC.h"
#import "MainMenuVC.h"
#import "NSArray+ATTArray.h"
#import "GameCell.h"


@implementation Top5VC
@synthesize bestGames, worstGames;

- (void)viewDidLoad {
    [super viewDidLoad];
	[self setTitle:NSLocalizedString(@"Top5", nil)];
	[self changeNavToIncludeType:19];
	bestGames = [[NSMutableArray alloc] init];
	worstGames = [[NSMutableArray alloc] init];
	
	[self addHomeButton];
	
	[self.mainSegment turnIntoTop5Segment];
	
	[self calculate];
}

-(void)calculate {
	[bestGames removeAllObjects];
	[worstGames removeAllObjects];
	NSLog(@"Calculating!!!");
	if(self.mainSegment.selectedSegmentIndex==0) {
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"winnings > 0 AND user_id = 0"];
		[bestGames addObjectsFromArray:[CoreDataLib selectRowsFromEntityWithLimit:@"GAME" predicate:predicate sortColumn:@"winnings" mOC:self.managedObjectContext ascendingFlg:NO limit:5]];
		NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"winnings < 0 AND user_id = 0"];
		[worstGames addObjectsFromArray:[CoreDataLib selectRowsFromEntityWithLimit:@"GAME" predicate:predicate2 sortColumn:@"winnings" mOC:self.managedObjectContext ascendingFlg:YES limit:5]];
	} else if(self.mainSegment.selectedSegmentIndex==1) {
		int currentMinYear = [[ProjectFunctions getUserDefaultValue:@"minYear2"] intValue];
		int currentMaxYear = [[ProjectFunctions getUserDefaultValue:@"maxYear"] intValue];
		NSMutableArray *allmonths = [[NSMutableArray alloc] init];
		for(int year=currentMinYear; year<=currentMaxYear; year++) {
			NSArray *months = [ProjectFunctions namesOfAllMonths];
			for (NSString *month in months) {
				NSPredicate *predicate = [NSPredicate predicateWithFormat:@"user_id = 0 AND month = %@ AND year = %d", month, year];
				NSArray *games = [CoreDataLib selectRowsFromEntity:@"GAME" predicate:predicate sortColumn:nil mOC:self.managedObjectContext ascendingFlg:NO];
				double profit=0;
				double risked=0;
				float hours=0;
				for (NSManagedObject *mo in games) {
					hours += [[mo valueForKey:@"hours"] floatValue];
					profit += [[mo valueForKey:@"winnings"] doubleValue];
					risked += [[mo valueForKey:@"buyInAmount"] doubleValue]+[[mo valueForKey:@"rebuyAmount"] doubleValue];
				}
				if(games.count>0)
					[allmonths addObject:[NSString stringWithFormat:@"%09d|%@ %d|%d|%f|%f", (int)profit+100000, month, year, (int)games.count, risked, hours]];
			}
		}
		NSArray *sortedMonths = [ProjectFunctions sortArray:allmonths];
		for(int i=0; i<5; i++) {
			int number = (int)sortedMonths.count-i-1;
			if(sortedMonths.count>number)
				[bestGames addObject:[sortedMonths objectAtIndex:number]];
			if(sortedMonths.count>i)
				[worstGames addObject:[sortedMonths objectAtIndex:i]];
		}
	} else {
		int currentMinYear = [[ProjectFunctions getUserDefaultValue:@"minYear2"] intValue];
		int currentMaxYear = [[ProjectFunctions getUserDefaultValue:@"maxYear"] intValue];
		NSMutableArray *allmonths = [[NSMutableArray alloc] init];
		for(int year=currentMinYear; year<=currentMaxYear; year++) {
			NSArray *months = [ProjectFunctions namesOfAllMonths];
			if(months.count>=12) {
				for (int i=0; i<4; i++) {
					NSString *month1 = [months objectAtIndex:i*3+0];
					NSString *month2 = [months objectAtIndex:i*3+1];
					NSString *month3 = [months objectAtIndex:i*3+2];
					NSPredicate *predicate = [NSPredicate predicateWithFormat:@"user_id = 0 AND (month = %@ OR month = %@ OR month = %@) AND year = %d", month1, month2, month3, year];
					NSArray *games = [CoreDataLib selectRowsFromEntity:@"GAME" predicate:predicate sortColumn:nil mOC:self.managedObjectContext ascendingFlg:NO];
					double profit=0;
					double risked=0;
					float hours=0;
					for (NSManagedObject *mo in games) {
						hours += [[mo valueForKey:@"hours"] floatValue];
						profit += [[mo valueForKey:@"winnings"] doubleValue];
						risked += [[mo valueForKey:@"buyInAmount"] doubleValue]+[[mo valueForKey:@"rebuyAmount"] doubleValue];
					}
					if(games.count>0)
						[allmonths addObject:[NSString stringWithFormat:@"%09d|%@ %d %d|%d|%f|%f", (int)profit+100000, NSLocalizedString(@"Quarter", nil), i+1, year, (int)games.count, risked, hours]];
				}
			}
		}
		NSArray *sortedMonths = [ProjectFunctions sortArray:allmonths];
		for(int i=0; i<5; i++) {
			int number = (int)sortedMonths.count-i-1;
			if(sortedMonths.count>number)
				[bestGames addObject:[sortedMonths objectAtIndex:number]];
			if(sortedMonths.count>i)
				[worstGames addObject:[sortedMonths objectAtIndex:i]];
		}
	}
	[self.mainTableView reloadData];
}

- (IBAction) segmentChanged: (id) sender {
	[self calculate];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if(section==0)
		return [bestGames count];
	else 
		return [worstGames count];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	NSArray *titles = [NSArray arrayWithObjects:
					   [NSString stringWithFormat:@"  %@ 5 %@", [NSString fontAwesomeIconStringForEnum:FAThumbsUp], NSLocalizedString(@"Best", nil)],
					   [NSString stringWithFormat:@"  %@ 5 %@", [NSString fontAwesomeIconStringForEnum:FAThumbsDown], NSLocalizedString(@"Worst", nil)],
					   nil];
	UILabel * headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 22.0)];
	headerLabel.opaque = YES;
	headerLabel.textColor = [UIColor whiteColor];
	headerLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:14];
	headerLabel.text = [titles stringAtIndex:(int)section];
	headerLabel.backgroundColor	= [ProjectFunctions themeBGColor];
	return headerLabel;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return 22;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *cellIdentifier = [NSString stringWithFormat:@"cellIdentifierSection%dRow%d", (int)indexPath.section, (int)indexPath.row];
	
	if(self.mainSegment.selectedSegmentIndex==0) { // games
		NSManagedObject *mo = nil;
		if(indexPath.section==0)
			mo = [bestGames objectAtIndex:indexPath.row];
		else
			mo = [worstGames objectAtIndex:indexPath.row];
		
		return [ProjectFunctions getGameCell:mo CellIdentifier:cellIdentifier tableView:tableView evenFlg:indexPath.row%2==0];
	} else {
		NSString *line = nil;
		if(indexPath.section==0)
			line = [bestGames objectAtIndex:indexPath.row];
		else
			line = [worstGames objectAtIndex:indexPath.row];
		
		GameCell *cell = [[GameCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
		GameObj *obj = [[GameObj alloc] init];
		NSArray *components = [line componentsSeparatedByString:@"|"];
		if(components.count>4) {
			obj.name = [components objectAtIndex:1];
			obj.location = [NSString stringWithFormat:@"%@ Games", [components objectAtIndex:2]];
			obj.profit = [[components objectAtIndex:0] doubleValue]-100000;
			obj.risked = [[components objectAtIndex:3] doubleValue];
			obj.hours = [components objectAtIndex:4];
			obj.type = (self.mainSegment.selectedSegmentIndex==1)?@"Calendar":@"Calendar-o";
		}
		[GameCell populateGameCell:cell gameObj:obj evenFlg:indexPath.row%2==0];
		return cell;
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSManagedObject *mo = nil;
	if(indexPath.section==0)
		mo = [bestGames objectAtIndex:indexPath.row];
	else 
		mo = [worstGames objectAtIndex:indexPath.row];
	[self gotoGame:mo];
}






@end
