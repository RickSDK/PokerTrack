//
//  GameGraphVC.m
//  PokerTracker
//
//  Created by Rick Medved on 3/1/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "GameGraphVC.h"
#import "NSDate+ATTDate.h"
#import "ProjectFunctions.h"
#import "GameDetailsVC.h"
#import "CoreDataLib.h"
#import "MainMenuVC.h"
#import "QuadWithImageTableViewCell.h"
#import "EditPlayerTracker.h"
#import "ListPicker.h"
#import "NSArray+ATTArray.h"
#import "MultiLineDetailCellWordWrap.h"
#import "MultiLineObj.h"


@implementation GameGraphVC
@synthesize managedObjectContext, mo, locationLabel;

-(void)detailsButtonClicked:(id)sender {
	GameDetailsVC *detailViewController = [[GameDetailsVC alloc] initWithNibName:@"GameDetailsVC" bundle:nil];
	detailViewController.managedObjectContext = self.managedObjectContext;
	detailViewController.viewEditable = self.viewEditable;
	detailViewController.mo = self.mo;
	[self.navigationController pushViewController:detailViewController animated:YES];
}

-(void)mainMenuButtonClicked:(id)sender {
	MainMenuVC *detailViewController = [[MainMenuVC alloc] initWithNibName:@"MainMenuVC" bundle:nil];
	detailViewController.managedObjectContext = managedObjectContext;
	[detailViewController calculateStats];
	[self.navigationController pushViewController:detailViewController animated:YES];
}

-(void)setupData {
	[self.cellRowsArray removeAllObjects];
	
	self.dateLabel.text = [[self.mo valueForKey:@"startTime"] convertDateToStringWithFormat:@"MMM d, yyyy"];
	self.timeLabel.text = [[self.mo valueForKey:@"startTime"] convertDateToStringWithFormat:@"hh:mm a"];
	
	
	self.locationLabel.text = [self.mo valueForKey:@"location"];
	
	int foodMoney = [[self.mo valueForKey:@"foodDrinks"] intValue];
	float cashoutAmount = [[self.mo valueForKey:@"cashoutAmount"] floatValue];
	float buyInAmount = [[self.mo valueForKey:@"buyInAmount"] floatValue];
	float rebuyAmount = [[self.mo valueForKey:@"rebuyAmount"] floatValue];
	float winnings = cashoutAmount+foodMoney-buyInAmount-rebuyAmount;
	
	int tokes = [[mo valueForKey:@"tokes"] intValue];
	if([[mo valueForKey:@"Type"] isEqualToString:@"Tournament"]) {
		tokes=0;
	}
	
	self.gamePPRView.image = [ProjectFunctions getPlayerTypeImage:(buyInAmount+rebuyAmount) winnings:winnings];
	
	[ProjectFunctions updateMoneyFloatLabel:self.netLabel money:winnings];
	
	if(self.showMainMenuFlg) {
		self.navigationItem.leftBarButtonItem = [ProjectFunctions navigationButtonWithTitle:@"Main Menu" selector:@selector(mainMenuButtonClicked:) target:self];
	}
	
	self.navigationItem.rightBarButtonItem = [ProjectFunctions navigationButtonWithTitle:@"Details" selector:@selector(detailsButtonClicked:) target:self];
	
	
	[self.cellRowsArray addObject:[MultiLineDetailCellWordWrap multiObjectWithName:@"Start Day" value:[[mo valueForKey:@"startTime"] convertDateToStringWithFormat:@"MMM d, yyyy"] color:[UIColor blackColor]]];
	
	[self.cellRowsArray addObject:[MultiLineDetailCellWordWrap multiObjectWithName:@"Day" value:[NSString stringWithFormat:@"%@ %@", [mo valueForKey:@"weekday"], [mo valueForKey:@"daytime"]] color:[UIColor blackColor]]];
	
	[self.cellRowsArray addObject:[MultiLineDetailCellWordWrap multiObjectWithName:@"Start Time" value:[[mo valueForKey:@"startTime"] convertDateToStringWithFormat:@"hh:mm a"] color:[UIColor blackColor]]];
	
	NSDate *endTime = [mo valueForKey:@"endTime"];
	if([[mo valueForKey:@"status"] isEqualToString:@"In Progress"])
		endTime = [NSDate date];
	else
		[self.cellRowsArray addObject:[MultiLineDetailCellWordWrap multiObjectWithName:@"End Time" value:[[mo valueForKey:@"endTime"] convertDateToStringWithFormat:@"hh:mm a"] color:[UIColor blackColor]]];
	
	int minutes = [ProjectFunctions getMinutesPlayedUsingStartTime:[mo valueForKey:@"startTime"] andEndTime:endTime andBreakMin:[[mo valueForKey:@"breakMinutes"] intValue]];
	
	[self.cellRowsArray addObject:[MultiLineDetailCellWordWrap multiObjectWithName:@"Playing Time" value:[ProjectFunctions getHoursPlayedUsingStartTime:[mo valueForKey:@"startTime"] andEndTime:endTime andBreakMin:[[mo valueForKey:@"breakMinutes"] intValue]] color:[UIColor blackColor]]];
	
	[self.cellRowsArray addObject:[MultiLineDetailCellWordWrap multiObjectWithName:@"Location" value:[mo valueForKey:@"location"] color:[UIColor blackColor]]];
	
	[self.cellRowsArray addObject:[MultiLineDetailCellWordWrap multiObjectWithName:@"Buyin" value:[ProjectFunctions convertNumberToMoneyString:buyInAmount] color:[UIColor blackColor]]];
	
	[self.cellRowsArray addObject:[MultiLineDetailCellWordWrap multiObjectWithName:@"Cashout" value:[ProjectFunctions convertNumberToMoneyString:cashoutAmount] color:[UIColor blackColor]]];
	
	[self.cellRowsArray addObject:[MultiLineDetailCellWordWrap multiObjectWithName:@"Food/Drink" value:[NSString stringWithFormat:@"%d", foodMoney] color:[UIColor blackColor]]];
	[self.cellRowsArray addObject:[MultiLineDetailCellWordWrap multiObjectWithName:@"Tokes" value:[NSString stringWithFormat:@"%d", tokes] color:[UIColor blackColor]]];
	
	if(rebuyAmount>0) {
		int numRebuys = [[mo valueForKey:@"numRebuys"] intValue];
		if(numRebuys<1)
			numRebuys=1;
		[self.cellRowsArray addObject:[MultiLineDetailCellWordWrap multiObjectWithName:@"Rebuys" value:[NSString stringWithFormat:@"%d", numRebuys] color:[UIColor blackColor]]];
		
		[self.cellRowsArray addObject:[MultiLineDetailCellWordWrap multiObjectWithName:@"Rebuy Amount" value:[ProjectFunctions convertNumberToMoneyString:rebuyAmount] color:[UIColor blackColor]]];
		
	}
	
	if([[mo valueForKey:@"Type"] isEqualToString:@"Tournament"]) {
		minutes = [endTime timeIntervalSinceDate:[mo valueForKey:@"startTime"]]/60;
	}
	
	UIColor *profitColor = (winnings>=0)?[UIColor colorWithRed:0 green:.5 blue:0 alpha:1]:[UIColor redColor];
	
	[self.cellRowsArray addObject:[MultiLineDetailCellWordWrap multiObjectWithName:@"Net Profit" value:[ProjectFunctions convertNumberToMoneyString:winnings] color:profitColor]];
	
	NSString *hourlyStr = @"-";
	if(minutes>0)
		hourlyStr = [NSString stringWithFormat:@"%@%d/hr", [ProjectFunctions getMoneySymbol], (int)winnings*60/minutes];
	
	[self.cellRowsArray addObject:[MultiLineDetailCellWordWrap multiObjectWithName:@"Hourly" value:hourlyStr color:profitColor]];
 
	
	float grossIncome = winnings+tokes;
	profitColor = (grossIncome>=0)?[UIColor colorWithRed:0 green:.5 blue:0 alpha:1]:[UIColor redColor];
	[self.cellRowsArray addObject:[MultiLineDetailCellWordWrap multiObjectWithName:@"Gross Profit" value:[ProjectFunctions convertNumberToMoneyString:grossIncome] color:profitColor]];
	
	float takehomeIncome = winnings-foodMoney;
	profitColor = (takehomeIncome>=0)?[UIColor colorWithRed:0 green:.5 blue:0 alpha:1]:[UIColor redColor];
	[self.cellRowsArray addObject:[MultiLineDetailCellWordWrap multiObjectWithName:@"Takehome" value:[ProjectFunctions convertNumberToMoneyString:takehomeIncome] color:profitColor]];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"game = %@", mo];
	NSArray *items = [CoreDataLib selectRowsFromEntity:@"CHIPSTACK" predicate:predicate sortColumn:@"timeStamp" mOC:managedObjectContext ascendingFlg:YES];
	
	if([items count]==0) {
		NSDate *startTime = [mo valueForKey:@"startTime"];
		NSDate *endTime = [mo valueForKey:@"endTime"];
		
		[ProjectFunctions createChipTimeStamp:managedObjectContext mo:mo timeStamp:startTime amount:0 rebuyFlg:NO];
		[ProjectFunctions createChipTimeStamp:managedObjectContext mo:mo timeStamp:endTime amount:winnings rebuyFlg:NO];
	}
	
	if([[mo valueForKey:@"Type"] isEqualToString:@"Tournament"]) {
		int entrants = [[mo valueForKey:@"tournamentSpots"] intValue];
		int spotsPaid = [[mo valueForKey:@"breakMinutes"] intValue];
		int place = [[mo valueForKey:@"tournamentFinish"] intValue];
		
		if(entrants==0) {
			entrants = [[mo valueForKey:@"attrib03"] intValue];
			place = [[mo valueForKey:@"attrib04"] intValue];
			
			if(entrants==0)
				entrants=10;
			if(spotsPaid==0)
				spotsPaid=entrants/10;
			if(place==0)
				place=5;
			
			[mo setValue:[NSNumber numberWithInt:entrants] forKey:@"tournamentSpots"];
			[mo setValue:[NSNumber numberWithInt:spotsPaid] forKey:@"breakMinutes"];
			[mo setValue:[NSNumber numberWithInt:place] forKey:@"tournamentFinish"];
			[managedObjectContext save:nil];
		}
		[self.cellRowsArray addObject:[MultiLineDetailCellWordWrap multiObjectWithName:@"Entrants" value:[NSString stringWithFormat:@"%d", entrants] color:[UIColor blackColor]]];
		[self.cellRowsArray addObject:[MultiLineDetailCellWordWrap multiObjectWithName:@"Spots Paid" value:[NSString stringWithFormat:@"%d", spotsPaid] color:[UIColor blackColor]]];
		[self.cellRowsArray addObject:[MultiLineDetailCellWordWrap multiObjectWithName:@"Your Place" value:[NSString stringWithFormat:@"%d", place] color:[UIColor blackColor]]];
		
	}

	[self.cellRowsArray addObject:[MultiLineDetailCellWordWrap multiObjectWithName:@"Notes" value:[mo valueForKey:@"notes"] color:[UIColor blackColor]]];

}

-(void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	if([self respondsToSelector:@selector(edgesForExtendedLayout)])
		[self setEdgesForExtendedLayout:UIRectEdgeBottom];
	
	[self setupData];
}


- (void)viewDidLoad {
    [super viewDidLoad];
	[self setTitle:@"Game Graph "]; 
	
	self.cellRowsArray = [[NSMutableArray alloc] init];
	
	int game_id = [[mo valueForKey:@"game_id"] intValue];
	if(game_id==0) {
		game_id = [ProjectFunctions generateUniqueId];
		[mo setValue:[NSNumber numberWithInt:game_id] forKey:@"game_id"];
		[managedObjectContext save:nil];
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	NSString *cellIdentifier = [NSString stringWithFormat:@"cellIdentifierSection%dRow%d", (int)indexPath.section, (int)indexPath.row];
	
	if(indexPath.section==0) {
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
		
		if(cell==nil)
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
		
		NSString *predString = [ProjectFunctions getBasicPredicateString:[[[NSDate date] convertDateToStringWithFormat:@"yyyy"] intValue] type:@"All"];
		NSPredicate *pred = [NSPredicate predicateWithFormat:predString];
		cell.backgroundView = [[UIImageView alloc] initWithImage:[ProjectFunctions plotGameChipsChart:managedObjectContext mo:mo predicate:pred displayBySession:NO]];
		cell.accessoryType= UITableViewCellAccessoryNone;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		return cell;
	} else {
		MultiLineDetailCellWordWrap *cell = (MultiLineDetailCellWordWrap *) [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
		if (cell == nil) {
			cell = [[MultiLineDetailCellWordWrap alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier withRows:[self.cellRowsArray count] labelProportion:0.5];
		}
		
		
		cell.mainTitle = [mo valueForKey:@"name"];
		cell.alternateTitle = [mo valueForKey:@"Type"];
		cell.titleTextArray = [MultiLineDetailCellWordWrap arrayOfType:0 objList:self.cellRowsArray];
		cell.fieldTextArray = [MultiLineDetailCellWordWrap arrayOfType:1 objList:self.cellRowsArray];
		cell.fieldColorArray = [MultiLineDetailCellWordWrap arrayOfType:2 objList:self.cellRowsArray];

		cell.accessoryType= UITableViewCellAccessoryNone;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		return cell;
		
	}
}





- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return CGFLOAT_MIN;
}


-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if(indexPath.section==0)
		return [ProjectFunctions chartHeightForSize:190];
	else
		return [MultiLineDetailCellWordWrap cellHeightForMultiCellData:self.cellRowsArray
																   tableView:tableView
																 labelWidthProportion:0.5];
;
}







@end
