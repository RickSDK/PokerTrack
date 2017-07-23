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
#import "MultiCellObj.h"
#import "AnalysisDetailsVC.h"
#import "HudTrackerVC.h"


@implementation GameGraphVC
@synthesize managedObjectContext, mo, locationLabel;

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.cellRowsArray = [[NSMutableArray alloc] init];
	self.pointsArray = [[NSArray alloc] init];
	
	[self setTitle:[NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Game", nil), NSLocalizedString(@"Charts", nil)]];
	
	[ProjectFunctions makeFAButton:self.hudButton type:5 size:18];
	self.popupView.titleLabel.text=@"Chipstack Comment";
	
	[self addGameID];
	[self setupGraphView];
	
	self.navigationItem.rightBarButtonItem = [ProjectFunctions UIBarButtonItemWithIcon:[NSString fontAwesomeIconStringForEnum:FAArrowCircleRight] target:self action:@selector(detailsButtonClicked:)];
	
	[self deselectChart];
}

-(void)detailsButtonClicked:(id)sender {
	[self gotoDetails];
}

-(void)gotoDetails {
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

- (IBAction) hudButtonPressed: (id) sender {
	HudTrackerVC *detailViewController = [[HudTrackerVC alloc] initWithNibName:@"HudTrackerVC" bundle:nil];
	detailViewController.managedObjectContext = managedObjectContext;
	detailViewController.gameMo = self.mo;
	[self.navigationController pushViewController:detailViewController animated:YES];
}

-(void)setupData {
	self.pprLabel.text = [NSString stringWithFormat:@"%d%%", self.gameObj.ppr];
	self.pprLabel.textColor = (self.gameObj.ppr>=0)?[UIColor greenColor]:[UIColor orangeColor];
	self.hudButton.hidden=!self.gameObj.hudStatsFlg;
	self.locationLabel.text = self.gameObj.location;
	
	self.popupView.hidden=YES;
	
	self.gamePPRView.image = [ProjectFunctions getPlayerTypeImage:self.gameObj.risked winnings:self.gameObj.profit];
	
	[ProjectFunctions updateMoneyFloatLabel:self.netLabel money:self.gameObj.profit];
	
	if(self.showMainMenuFlg) {
		self.navigationItem.leftBarButtonItem = [ProjectFunctions UIBarButtonItemWithIcon:[NSString fontAwesomeIconStringForEnum:FAHome] target:self action:@selector(mainMenuButtonClicked:)];
	}
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"game = %@", mo];
	NSArray *items = [CoreDataLib selectRowsFromEntity:@"CHIPSTACK" predicate:predicate sortColumn:@"timeStamp" mOC:managedObjectContext ascendingFlg:YES];
	
	if([items count]==0) {
		NSDate *startTime = [mo valueForKey:@"startTime"];
		NSDate *endTime = [mo valueForKey:@"endTime"];
		
		[ProjectFunctions createChipTimeStamp:managedObjectContext mo:mo timeStamp:startTime amount:0 rebuyFlg:NO];
		[ProjectFunctions createChipTimeStamp:managedObjectContext mo:mo timeStamp:endTime amount:self.gameObj.profit rebuyFlg:NO];
	}
	
	self.dateLabel.text = [ProjectFunctions displayLocalFormatDate:self.gameObj.startTime showDay:YES showTime:NO];
	self.timeLabel.text = [ProjectFunctions displayLocalFormatDate:self.gameObj.startTime showDay:NO showTime:YES];
	self.dateLabel.textColor = [self colorForType:self.gameObj.type];
	self.timeLabel.textColor = [self colorForType:self.gameObj.type];
}

-(UIColor *)colorForType:(NSString *)type {
	return ([@"Cash" isEqualToString:self.gameObj.type])?[UIColor colorWithRed:1 green:.9 blue:.3 alpha:1]:[UIColor colorWithRed:.5 green:.8 blue:1 alpha:1];
}

-(void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	if([self respondsToSelector:@selector(edgesForExtendedLayout)])
		[self setEdgesForExtendedLayout:UIRectEdgeBottom];
	
	self.gameObj = [GameObj gameObjFromDBObj:mo];
	self.multiCellObj = [MultiCellObj buildsMultiLineObjWithGame:self.gameObj];
	
	[self setupData];
	
	ChipStackObj *chipStackObj = [ProjectFunctions plotGameChipsChart:managedObjectContext mo:mo predicate:nil displayBySession:NO];
	self.pointsArray = chipStackObj.pointArray;
	[self drawNotes];
	
	self.gameGraphView.image = chipStackObj.image;
	[self.mainTableView reloadData];
}

-(void)setupGraphView {
	self.gameGraphView.layer.cornerRadius = 7;
	self.gameGraphView.layer.masksToBounds = YES;				// clips background images to rounded corners
	self.gameGraphView.layer.borderColor = [UIColor blackColor].CGColor;
	self.gameGraphView.layer.borderWidth = 2.;
}

-(void)addGameID {
	int game_id = [[mo valueForKey:@"game_id"] intValue];
	if(game_id==0) {
		NSLog(@"Adding GameID!");
		game_id = [ProjectFunctions generateUniqueId];
		[mo setValue:[NSNumber numberWithInt:game_id] forKey:@"game_id"];
		[managedObjectContext save:nil];
	}
}
 
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if(self.touchesFlg) {
		NSString *note = @"";
		if([ProjectFunctions getUserDefaultValue:[self noteIdforRow:self.closestPoint]].length>0)
			note=[ProjectFunctions getUserDefaultValue:[self noteIdforRow:self.closestPoint]];

		if(note.length>0) {
			MultiLineDetailCellWordWrap *cell = [[MultiLineDetailCellWordWrap alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell1" withRows:1 labelProportion:0];
			cell.mainTitle = NSLocalizedString(@"Chip Stack Comment", nil);
			cell.alternateTitle = @"";
			cell.titleTextArray = [NSArray arrayWithObject:NSLocalizedString(@"Chip Notes", nil)];
			cell.fieldTextArray = [NSArray arrayWithObject:note];
			cell.fieldColorArray = [NSArray arrayWithObject:[UIColor blackColor]];
			cell.accessoryType= UITableViewCellAccessoryNone;
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			return cell;
		}
		
	}	
	return [MultiLineDetailCellWordWrap multiCellForID:@"cell2" obj:self.multiCellObj tableView:tableView];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return [MultiLineDetailCellWordWrap heightForMultiCellObj:self.multiCellObj tableView:self.mainTableView];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[self gotoDetails];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [[event allTouches] anyObject];
	CGPoint touchPosition =[touch locationInView:self.view];
	if (CGRectContainsPoint(self.gamePPRView.frame, touchPosition))
	{
		AnalysisDetailsVC *detailViewController = [[AnalysisDetailsVC alloc] initWithNibName:@"AnalysisDetailsVC" bundle:nil];
		detailViewController.managedObjectContext = managedObjectContext;
		[self.navigationController pushViewController:detailViewController animated:YES];
	}
	if (CGRectContainsPoint(self.gameGraphView.frame, touchPosition)) {
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
	} else {
		[self deselectChart];
	}
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
				self.commentTimeLabel.text = [items objectAtIndex:3];
				self.commentProfitLabel.text = [ProjectFunctions convertIntToMoneyString:[[items objectAtIndex:2] intValue]];

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
	self.popupView.hidden=!self.popupView.hidden;
	self.textField.text=[ProjectFunctions getUserDefaultValue:[self noteIdforRow:self.closestPoint]];
	if(self.popupView.hidden)
		[self.textField resignFirstResponder];
	else
		[self.textField becomeFirstResponder];
}

- (IBAction) enterButtonPressed: (id) sender {
	self.popupView.hidden=YES;
	[self.textField resignFirstResponder];
	
	[ProjectFunctions setUserDefaultValue:self.textField.text forKey:[self noteIdforRow:self.closestPoint]];
	[self drawNotes];

	[self.mainTableView reloadData];
}

-(NSString *)noteIdforRow:(int)row {
	return [NSString stringWithFormat:@"Note%d.%d", [[self.mo valueForKey:@"game_id"] intValue], row];
}

@end
