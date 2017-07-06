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
#import "ChipStackObj.h"
#import "IGAVC.h"


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

- (IBAction) pprButtonPressed: (id) sender {
	IGAVC *detailViewController = [[IGAVC alloc] initWithNibName:@"IGAVC" bundle:nil];
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
	
	int tokes = [[mo valueForKey:@"tokes"] intValue];
	if([[mo valueForKey:@"Type"] isEqualToString:@"Tournament"]) {
		tokes=0;
		foodMoney=0;
	}
	double winnings = cashoutAmount+foodMoney-buyInAmount-rebuyAmount;
	
	self.notesView.hidden=YES;
	
	self.gamePPRView.image = [ProjectFunctions getPlayerTypeImage:(buyInAmount+rebuyAmount) winnings:winnings];
	
	[ProjectFunctions updateMoneyFloatLabel:self.netLabel money:winnings];
	
	if(self.showMainMenuFlg) {
		self.navigationItem.leftBarButtonItem = [ProjectFunctions UIBarButtonItemWithIcon:[NSString fontAwesomeIconStringForEnum:FAHome] target:self action:@selector(mainMenuButtonClicked:)];
	}
	
	
	[self.cellRowsArray addObject:[MultiLineDetailCellWordWrap multiObjectWithName:NSLocalizedString(@"Day", nil) value:[[mo valueForKey:@"startTime"] convertDateToStringWithFormat:@"MMM d, yyyy"] color:[UIColor blackColor]]];
	
	[self.cellRowsArray addObject:[MultiLineDetailCellWordWrap multiObjectWithName:NSLocalizedString(@"Weekday", nil) value:[NSString stringWithFormat:@"%@ %@", [mo valueForKey:@"weekday"], [mo valueForKey:@"daytime"]] color:[UIColor blackColor]]];
	
	[self.cellRowsArray addObject:[MultiLineDetailCellWordWrap multiObjectWithName:NSLocalizedString(@"StartTime", nil) value:[[mo valueForKey:@"startTime"] convertDateToStringWithFormat:@"hh:mm a"] color:[UIColor blackColor]]];
	
	NSDate *endTime = [mo valueForKey:@"endTime"];
	if([[mo valueForKey:@"status"] isEqualToString:@"In Progress"])
		endTime = [NSDate date];
	else
		[self.cellRowsArray addObject:[MultiLineDetailCellWordWrap multiObjectWithName:NSLocalizedString(@"EndTime", nil) value:[[mo valueForKey:@"endTime"] convertDateToStringWithFormat:@"hh:mm a"] color:[UIColor blackColor]]];
	
	int minutes = [ProjectFunctions getMinutesPlayedUsingStartTime:[mo valueForKey:@"startTime"] andEndTime:endTime andBreakMin:[[mo valueForKey:@"breakMinutes"] intValue]];
	
	[self.cellRowsArray addObject:[MultiLineDetailCellWordWrap multiObjectWithName:NSLocalizedString(@"Hours", nil) value:[ProjectFunctions getHoursPlayedUsingStartTime:[mo valueForKey:@"startTime"] andEndTime:endTime andBreakMin:[[mo valueForKey:@"breakMinutes"] intValue]] color:[UIColor blackColor]]];
	
	[self.cellRowsArray addObject:[MultiLineDetailCellWordWrap multiObjectWithName:NSLocalizedString(@"Location", nil) value:[mo valueForKey:@"location"] color:[UIColor blackColor]]];
	
	[self.cellRowsArray addObject:[MultiLineDetailCellWordWrap multiObjectWithName:NSLocalizedString(@"Buyin", nil) value:[ProjectFunctions convertNumberToMoneyString:buyInAmount] color:[UIColor blackColor]]];
	
	if(rebuyAmount>0) {
		int numRebuys = [[mo valueForKey:@"numRebuys"] intValue];
		if(numRebuys<1)
			numRebuys=1;
		[self.cellRowsArray addObject:[MultiLineDetailCellWordWrap multiObjectWithName:@"Rebuys" value:[NSString stringWithFormat:@"%d", numRebuys] color:[UIColor blackColor]]];
		
		[self.cellRowsArray addObject:[MultiLineDetailCellWordWrap multiObjectWithName:@"Rebuy Amount" value:[ProjectFunctions convertNumberToMoneyString:rebuyAmount] color:[UIColor blackColor]]];
		
	}
	
	[self.cellRowsArray addObject:[MultiLineDetailCellWordWrap multiObjectWithName:NSLocalizedString(@"foodDrink", nil) value:[NSString stringWithFormat:@"%d", foodMoney] color:[UIColor blackColor]]];
	[self.cellRowsArray addObject:[MultiLineDetailCellWordWrap multiObjectWithName:NSLocalizedString(@"Tips", nil) value:[NSString stringWithFormat:@"%d", tokes] color:[UIColor blackColor]]];
	
	[self.cellRowsArray addObject:[MultiLineDetailCellWordWrap multiObjectWithName:NSLocalizedString(@"Cashout", nil) value:[ProjectFunctions convertNumberToMoneyString:cashoutAmount] color:[UIColor blackColor]]];
	
	if([[mo valueForKey:@"Type"] isEqualToString:@"Tournament"]) {
		minutes = [endTime timeIntervalSinceDate:[mo valueForKey:@"startTime"]]/60;
	}
	
	UIColor *profitColor = (winnings>=0)?[UIColor colorWithRed:0 green:.5 blue:0 alpha:1]:[UIColor redColor];
	
	[self.cellRowsArray addObject:[MultiLineDetailCellWordWrap multiObjectWithName:NSLocalizedString(@"Profit", nil) value:[ProjectFunctions convertNumberToMoneyString:winnings] color:profitColor]];
	
	[self.cellRowsArray addObject:[MultiLineDetailCellWordWrap multiObjectWithName:@"ROI" value:[NSString stringWithFormat:@"%d%%", self.gameObj.ppr] color:profitColor]];
	
	NSString *hourlyStr = @"-";
	if(minutes>0)
		hourlyStr = [NSString stringWithFormat:@"%@/hr", [ProjectFunctions convertNumberToMoneyString:(int)winnings*60/minutes]];
	
	[self.cellRowsArray addObject:[MultiLineDetailCellWordWrap multiObjectWithName:NSLocalizedString(@"Hourly", nil) value:hourlyStr color:profitColor]];
 
	
	float grossIncome = winnings+tokes;
	profitColor = (grossIncome>=0)?[UIColor colorWithRed:0 green:.5 blue:0 alpha:1]:[UIColor redColor];
	[self.cellRowsArray addObject:[MultiLineDetailCellWordWrap multiObjectWithName:NSLocalizedString(@"IncomeTotal", nil) value:[ProjectFunctions convertNumberToMoneyString:grossIncome] color:profitColor]];
	
	float takehomeIncome = winnings-foodMoney;
	profitColor = (takehomeIncome>=0)?[UIColor colorWithRed:0 green:.5 blue:0 alpha:1]:[UIColor redColor];
	[self.cellRowsArray addObject:[MultiLineDetailCellWordWrap multiObjectWithName:NSLocalizedString(@"Take-Home", nil) value:[ProjectFunctions convertNumberToMoneyString:takehomeIncome] color:profitColor]];
	
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

	[self.cellRowsArray addObject:[MultiLineDetailCellWordWrap multiObjectWithName:NSLocalizedString(@"Notes", nil) value:[mo valueForKey:@"notes"] color:[UIColor blackColor]]];

}

-(void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	if([self respondsToSelector:@selector(edgesForExtendedLayout)])
		[self setEdgesForExtendedLayout:UIRectEdgeBottom];
	
	[self setupData];
	
	ChipStackObj *chipStackObj = [ProjectFunctions plotGameChipsChart:managedObjectContext mo:mo predicate:nil displayBySession:NO];
	self.pointsArray = chipStackObj.pointArray;
	[self drawNotes];
	
	self.gameGraphView.image = chipStackObj.image;

}


- (void)viewDidLoad {
    [super viewDidLoad];
	[self setTitle:NSLocalizedString(@"Game", nil)];
	
	self.cellRowsArray = [[NSMutableArray alloc] init];
	self.pointsArray = [[NSArray alloc] init];
	
	[self deselectChart];
	self.gameObj = [GameObj gameObjFromDBObj:mo];

	
	self.gameGraphView.layer.cornerRadius = 7;
	self.gameGraphView.layer.masksToBounds = YES;				// clips background images to rounded corners
	self.gameGraphView.layer.borderColor = [UIColor blackColor].CGColor;
	self.gameGraphView.layer.borderWidth = 2.;

	self.pprLabel.text = [NSString stringWithFormat:@"%d%%", self.gameObj.ppr];
	self.pprLabel.textColor = (self.gameObj.ppr>=0)?[UIColor greenColor]:[UIColor orangeColor];

	
	int game_id = [[mo valueForKey:@"game_id"] intValue];
	if(game_id==0) {
		game_id = [ProjectFunctions generateUniqueId];
		[mo setValue:[NSNumber numberWithInt:game_id] forKey:@"game_id"];
		[managedObjectContext save:nil];
	}
	
	self.navigationItem.rightBarButtonItem = [ProjectFunctions UIBarButtonItemWithIcon:[NSString fontAwesomeIconStringForEnum:FAPencil] target:self action:@selector(detailsButtonClicked:)];
	
}
 
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	NSString *cellIdentifier = [NSString stringWithFormat:@"cellIdentifierSection%dRow%d", (int)indexPath.section, (int)indexPath.row];
	
	int rows = (int)[self.cellRowsArray count];
	if(self.touchesFlg)
		rows=1;
	
		MultiLineDetailCellWordWrap *cell = [[MultiLineDetailCellWordWrap alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier withRows:rows labelProportion:0.5];
	
	if(self.touchesFlg) {
		cell.mainTitle = NSLocalizedString(@"Notes", nil);
		cell.alternateTitle = @"";
		cell.titleTextArray = [NSArray arrayWithObject:NSLocalizedString(@"Notes", nil)];
		NSString *note = @"";
		if([ProjectFunctions getUserDefaultValue:[self noteIdforRow:self.closestPoint]].length>0)
			note=[ProjectFunctions getUserDefaultValue:[self noteIdforRow:self.closestPoint]];
		cell.fieldTextArray = [NSArray arrayWithObject:note];
		cell.fieldColorArray = [NSArray arrayWithObject:[UIColor blackColor]];
		
	} else {
		cell.mainTitle = [mo valueForKey:@"name"];
		cell.alternateTitle = NSLocalizedString([mo valueForKey:@"Type"], nil);
		cell.titleTextArray = [MultiLineDetailCellWordWrap arrayOfType:0 objList:self.cellRowsArray];
		cell.fieldTextArray = [MultiLineDetailCellWordWrap arrayOfType:1 objList:self.cellRowsArray];
		cell.fieldColorArray = [MultiLineDetailCellWordWrap arrayOfType:2 objList:self.cellRowsArray];
	}

		cell.accessoryType= UITableViewCellAccessoryNone;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		return cell;
		
}





- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
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
	return [MultiLineDetailCellWordWrap cellHeightForMultiCellData:self.cellRowsArray
																   tableView:tableView
																 labelWidthProportion:0.5];

}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [[event allTouches] anyObject];
	CGPoint touchPosition = [touch locationInView:self.gameGraphView];
	if(touchPosition.y>0 && touchPosition.y<self.gameGraphView.frame.size.height) {
		int closestPoint2 = [self findClosestPointToPoint:touchPosition];
		if(!self.touchesFlg) {
			self.touchesFlg=YES;
			self.arrow.hidden=NO;
			self.notesButton.enabled=YES;
			self.bottomView.hidden=NO;
		} else {
			if(closestPoint2==self.closestPoint)
				[self deselectChart];
		}
		self.closestPoint=closestPoint2;
	} else
		[self deselectChart];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [[event allTouches] anyObject];
	CGPoint touchPosition = [touch locationInView:self.gameGraphView];
	if(touchPosition.y>0 && touchPosition.y<self.gameGraphView.frame.size.height)
		self.closestPoint = [self findClosestPointToPoint:touchPosition];
	else
		[self deselectChart];
}

-(void)deselectChart {
	self.arrow.hidden=YES;
	self.notesButton.enabled=NO;
	self.chipAmountLabel.text = @"-";
	self.chipTimeLabel.text = @"-";
	self.touchesFlg=NO;
	self.notesView.hidden=!self.notesFlg;
	self.bottomView.hidden=YES;
	[self.mainTableView reloadData];
}

-(void)drawNotes {
	int totalWidth=640;
	int totalHeight=300;
	int i=0;
	for(NSString *pointStr in self.pointsArray) {
		NSArray *items = [pointStr componentsSeparatedByString:@"|"];
		if(items.count>3) {
			float pointX = [[items objectAtIndex:0] intValue];
			float pointY = [[items objectAtIndex:1] intValue];
			float width = self.gameGraphView.frame.size.width;
			float height = self.gameGraphView.frame.size.height;
			CGPoint point2 = CGPointMake(pointX*width/totalWidth, pointY*height/totalHeight);
			if([ProjectFunctions getUserDefaultValue:[self noteIdforRow:i]].length>0) {
				UIImageView *note = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"note.png"]];
				note.frame = CGRectMake(point2.x+3, point2.y+3, 10, 15);
				note.alpha=.5;
				[self.gameGraphView addSubview:note];
			}

		}
		i++;
	}
	
}

-(int)findClosestPointToPoint:(CGPoint)point {
	int totalWidth=640;
	int totalHeight=300;
	CGPoint closestPoint = point;
	float min = 999.0;
	int i=0;
	int finalPoint=0;
	for(NSString *pointStr in self.pointsArray) {
		NSArray *items = [pointStr componentsSeparatedByString:@"|"];
		if(items.count>3) {
			float pointX = [[items objectAtIndex:0] intValue];
			float pointY = [[items objectAtIndex:1] intValue];
			float width = self.gameGraphView.frame.size.width;
			float height = self.gameGraphView.frame.size.height;
			CGPoint point2 = CGPointMake(pointX*width/totalWidth, pointY*height/totalHeight);
			float distance = [self distanceBetweenPoints:point point2:point2];
			if(distance<min) {
				min=distance;
				closestPoint = point2;
				[self updateMoneyLabel:self.chipAmountLabel money:[[items objectAtIndex:2] intValue]];
				self.chipTimeLabel.text = [items objectAtIndex:3];
				finalPoint=i;
				[self.mainTableView reloadData];
			}
		}
		i++;
	}
	
	self.arrow.center = CGPointMake(closestPoint.x, closestPoint.y+30);
	return finalPoint;
}

-(void)updateMoneyLabel:(UILabel *)localLabel money:(int)money
{
	
	if(money<0) {
		localLabel.text = [ProjectFunctions convertIntToMoneyString:money];
		[localLabel performSelectorOnMainThread:@selector(setTextColor: ) withObject:[UIColor colorWithRed:.5 green:0 blue:0 alpha:1] waitUntilDone:NO];
	} else {
		localLabel.text = [NSString stringWithFormat:@"+%@", [ProjectFunctions convertIntToMoneyString:money]];
		[localLabel performSelectorOnMainThread:@selector(setTextColor: ) withObject:[UIColor colorWithRed:0 green:.5 blue:0 alpha:1] waitUntilDone:NO];
	}
	
}

-(float)distanceBetweenPoints:(CGPoint)point1 point2:(CGPoint)point2 {
	CGFloat dx = point2.x - point1.x;
	CGFloat dy = point2.y - point1.y;
	
	return sqrt(dx*dx + dy*dy );
}

- (IBAction) notesButtonPressed: (id) sender {
	self.notesFlg=!self.notesFlg;
	self.notesView.hidden=!self.notesFlg;
	self.textField.text=[ProjectFunctions getUserDefaultValue:[self noteIdforRow:self.closestPoint]];
}

- (IBAction) enterButtonPressed: (id) sender {
	self.notesFlg=NO;
	self.notesView.hidden=!self.notesFlg;
	
	[ProjectFunctions setUserDefaultValue:self.textField.text forKey:[self noteIdforRow:self.closestPoint]];
	[self drawNotes];

	[self.mainTableView reloadData];
}

-(NSString *)noteIdforRow:(int)row {
	return [NSString stringWithFormat:@"Note%d.%d", [[self.mo valueForKey:@"game_id"] intValue], row];
}








@end
