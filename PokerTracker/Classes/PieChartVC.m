//
//  PieChartVC.m
//  PokerTracker
//
//  Created by Rick Medved on 7/21/17.
//
//

#import "PieChartVC.h"
#import "CoreDataLib.h"
#import "GraphObject.h"
#import "GrabphLib.h"

@interface PieChartVC ()

@end

@implementation PieChartVC

- (void)viewDidLoad {
    [super viewDidLoad];
	[self setTitle:@"Pie Charts"];
	[self changeNavToIncludeType:35];
	[self.filterSegment turnIntoFilterSegment:self.managedObjectContext];
	[self.typeSegment turnIntoTypeSegment];
	[self addHomeButton];
	[self computeStats];
}

-(void)ptpGameSegmentChanged:(id)sender {
	[self.ptpGameSegment gameSegmentChanged];
	[self computeStats];
}

-(void)yearChanged {
	self.filterSegment.selectedSegmentIndex=0;
	[self computeStats];
}

-(void)computeStats {
	NSString *gameType = [ProjectFunctions labelForGameSegment:(int)self.ptpGameSegment.selectedSegmentIndex];
	NSString *predStr = [ProjectFunctions getBasicPredicateString:self.yearChangeView.statYear type:gameType];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:predStr];
	
	if(self.filterSegment.selectedSegmentIndex>0) {
		NSMutableArray *formDataArray = [[NSMutableArray alloc] init];
		NSString *gameType = [ProjectFunctions labelForGameSegment:(int)self.ptpGameSegment.selectedSegmentIndex];
		NSString *button = [NSString stringWithFormat:@"%d", (int)self.filterSegment.selectedSegmentIndex];
		NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"button = %@", button];
		NSArray *filters = [CoreDataLib selectRowsFromEntity:@"FILTER" predicate:predicate2 sortColumn:@"button" mOC:self.managedObjectContext ascendingFlg:YES];
		if([filters count]>0) {
			NSManagedObject *mo = [filters objectAtIndex:0];
			[formDataArray addObject:[self scrubFilterValue:[mo valueForKey:@"timeframe"]]];
			[formDataArray addObject:[self scrubFilterValue:NSLocalizedString(gameType, nil)]];
			[formDataArray addObject:[self scrubFilterValue:[mo valueForKey:@"game"]]];
			[formDataArray addObject:[self scrubFilterValue:[mo valueForKey:@"limit"]]];
			[formDataArray addObject:[self scrubFilterValue:[mo valueForKey:@"stakes"]]];
			[formDataArray addObject:[self scrubFilterValue:[mo valueForKey:@"location"]]];
			[formDataArray addObject:[self scrubFilterValue:[mo valueForKey:@"bankroll"]]];
			[formDataArray addObject:[self scrubFilterValue:[mo valueForKey:@"tournamentType"]]];
			NSLog(@"+++formDataArray: %@", formDataArray);
			predicate = [ProjectFunctions getPredicateForFilter:formDataArray mOC:self.managedObjectContext  buttonNum:(int)self.filterSegment.selectedSegmentIndex];
		} else {
			[ProjectFunctions showAlertPopup:@"Notice" message:@"No filter currently saved to that button"];
			self.filterSegment.selectedSegmentIndex=0;
			return;
		}
	}
	
	NSArray *games = [CoreDataLib selectRowsFromEntity:@"GAME" predicate:predicate sortColumn:@"startTime" mOC:self.managedObjectContext ascendingFlg:YES];
	[self.gameSummaryView populateViewWithObj:[GameStatObj gameStatObjForGames:games]];
	
	NSMutableDictionary *typeDict = [[NSMutableDictionary alloc] init];
	for(NSManagedObject *game in games) {
		NSString *item = @"";
		switch (self.typeSegment.selectedSegmentIndex) {
			case 0:
    item = [game valueForKey:@"Type"];
    break;
			case 1:
    item = [game valueForKey:@"gametype"];
    break;
			case 2:
    item = [game valueForKey:@"limit"];
    break;
			case 3:
    item = [game valueForKey:@"stakes"];
				if(self.ptpGameSegment.selectedSegmentIndex==2)
					item = [game valueForKey:@"tournamentType"];
    break;
			case 4:
    item = [game valueForKey:@"location"];
    break;
				
			default:
    break;
		}
		if(item.length>0) {
			int count = [[typeDict valueForKey:item] intValue];
			count++;
			[typeDict setValue:[NSString stringWithFormat:@"%d", count] forKey:item];
		}
	}
	[self. mainArray removeAllObjects];
	int i=0;
	for(NSString *key in [typeDict allKeys]) {
		int count = [[typeDict valueForKey:key] intValue];
		[self. mainArray addObject:[GraphObject graphObjectWithName:key amount:count rowId:i++ reverseColorFlg:NO currentMonthFlg:NO]];
	}

	self.graphImageView.image = [GrabphLib pieChartWithItems:self. mainArray startDegree:self.startDegree];
}


- (IBAction) filterSegmentChanged: (id) sender {
	[self.filterSegment changeSegment];
	[self computeStats];
}

-(NSString *)scrubFilterValue:(NSString *)value {
	if(value.length>3 && [@"All" isEqualToString:[value substringToIndex:3]])
		return NSLocalizedString(@"All", nil);
	
	return value;
}

- (IBAction) typeSegmentChanged: (id) sender {
	[self.typeSegment changeSegment];
	[self computeStats];
}

-(void)bankrollSegmentChanged {
	[self computeStats];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [[event allTouches] anyObject];
	self.startTouchPosition = [touch locationInView:self.view];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [[event allTouches] anyObject];
	CGPoint newTouchPosition = [touch locationInView:self.view];
	
	self.startDegree = [GrabphLib spinPieChart:self.graphImageView startTouchPosition:self.startTouchPosition newTouchPosition:newTouchPosition startDegree:self.startDegree barGraphObjects:self. mainArray];
	self.startTouchPosition=newTouchPosition;
}

@end
