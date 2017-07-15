//
//  BigHandsFormVC.m
//  PokerTracker
//
//  Created by Rick Medved on 10/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BigHandsFormVC.h"
#import "BigHandsVC.h"
#import "SelectionCell.h"
#import "DatePickerViewController.h"
#import "CardHandPicker.h"
#import "MoneyPickerVC.h"
#import "TextEnterVC.h"
#import "ProjectFunctions.h"
#import "PokerOddsFunctions.h"
#import "CoreDataLib.h"
#import "NSDate+ATTDate.h"
#import "ActionCell.h"
#import "OddsFormVC.h"
#import "MultiLineDetailCellWordWrap.h"
#import "UIColor+ATTColor.h"
#import "PokerCell.h"
#import "NSString+ATTString.h"
#import "NSArray+ATTArray.h"
#import "BigHandsPlayersFormVC.h"
#import "ListPicker.h"

#define kLeftMargine	0.2


@implementation BigHandsFormVC
@synthesize numPlayers, labelValues, formDataArray, selectedRow, mainTableView, winLossSegment, indexPathRow;
@synthesize saveButton, drilldown, viewEditable, oddsDataArray, visualView;
@synthesize managedObjectContext, mo, viewDisplayFlg, oddsButton;
@synthesize preflopView, flopView, turnView, viewNumber, nextButton, viewButton, deleteButton, buttonNumber;

#pragma mark -
#pragma mark View lifecycle

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
}

- (IBAction) playButtonPressed: (id) sender
{
	[self advanceScreen];
}

-(void)advanceScreen {
	self.viewNumber++;
	if(viewNumber>3)
		self.viewNumber=0;
	switch (viewNumber) {
		case 0:
			visualView.alpha=0;
			preflopView.alpha=1;
			flopView.alpha=0;
			turnView.alpha=0;
			break;
		case 1:
			visualView.alpha=0;
			preflopView.alpha=0;
			flopView.alpha=1;
			turnView.alpha=0;
			break;
		case 2:
			visualView.alpha=0;
			preflopView.alpha=0;
			flopView.alpha=0;
			turnView.alpha=1;
			break;
		case 3:
			visualView.alpha=1;
			preflopView.alpha=0;
			flopView.alpha=0;
			turnView.alpha=0;
			break;
		default:
			break;
	}
}

- (IBAction) deleteButtonPressed: (id) sender
{ 
	self.buttonNumber=1;
	[ProjectFunctions showConfirmationPopup:@"Delete Record" message:@"Are you sure you want to delete?"  delegate:self tag:1];
}

- (IBAction) viewButtonPressed: (id) sender
{
	if([mo valueForKey:@"preFlopOdds"]==nil) {
		[ProjectFunctions showAlertPopup:@"Notice" message:@"Load Odds Calculator first"];
		return;
	}
	self.viewDisplayFlg=!viewDisplayFlg;
	self.playButton.enabled=self.viewDisplayFlg;

	if(viewDisplayFlg) {
		mainTableView.alpha=0;
		preflopView.alpha=1;
		nextButton.alpha=1;
		self.viewNumber=0;
		if([mo valueForKey:@"preFlopOdds"]==nil)
			oddsButton.alpha=1;
	} else {
		saveButton.enabled=YES;
		mainTableView.alpha=1;
		preflopView.alpha=0;
		flopView.alpha=0;
		turnView.alpha=0;
		visualView.alpha=0;
		nextButton.alpha=0;
		oddsButton.alpha=0;
	}
    
	
		
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if(buttonNumber==1) {
		if(mo) {
			[managedObjectContext deleteObject:mo];
			[managedObjectContext save:nil];
		}
		[self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
	}
}


-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if(buttonIndex<numPlayers) {
		
		BigHandsPlayersFormVC *detailViewController = [[BigHandsPlayersFormVC alloc] initWithNibName:@"BigHandsPlayersFormVC" bundle:nil];
		detailViewController.managedObjectContext = managedObjectContext;
		detailViewController.mo = mo;
		detailViewController.playersHand=(int)buttonIndex+1;
		detailViewController.callBackViewController=self;
		[self.navigationController pushViewController:detailViewController animated:YES];
	}
}

- (IBAction) editButtonPressed: (id) sender {
	NSMutableArray *values = [[NSMutableArray alloc] init];
	[values addObject:@"Your Hand"];
	for(int i=1; i<numPlayers; i++)
		[values addObject:[NSString stringWithFormat:@"Player %d", i+1]];
	[ProjectFunctions showActionSheet:self view:self.view title:@"Edit Hand Details" buttons:values];
	return;
}

-(void)saveButtonClicked:(id)sender {
	if(!viewEditable) {
		[saveButton setTitle:[NSString fontAwesomeIconStringForEnum:FAFloppyO]];
		deleteButton.alpha=1;
        viewButton.alpha=0;
		viewEditable = YES;
		[mainTableView reloadData];
		return;
	}

	int yourHand = [PokerOddsFunctions determinHandStrength:[formDataArray stringAtIndex:1] flop:[formDataArray stringAtIndex:numPlayers+1] turn:[formDataArray stringAtIndex:numPlayers+2] river:[formDataArray stringAtIndex:numPlayers+3]];
	int oppHand = [PokerOddsFunctions determinHandStrength:[formDataArray stringAtIndex:2] flop:[formDataArray stringAtIndex:numPlayers+1] turn:[formDataArray stringAtIndex:numPlayers+2] river:[formDataArray stringAtIndex:numPlayers+3]];
	NSString *name = [NSString stringWithFormat:@"%@ (%@ vs %@)", [formDataArray stringAtIndex:1], [PokerOddsFunctions getNameOfhandFromValue:yourHand], [PokerOddsFunctions getNameOfhandFromValue:oppHand]];
	
	NSArray *winList = [NSArray arrayWithObjects:@"Win", @"Loss", @"Chop", nil];
	
	NSMutableArray *valueList = [[NSMutableArray alloc] init];
	[valueList addObject:[winList stringAtIndex:(int)winLossSegment.selectedSegmentIndex]];
	[valueList addObject:[formDataArray stringAtIndex:0]];
	for(int i=1; i<=numPlayers; i++)
		[valueList addObject:[formDataArray stringAtIndex:i]];
	for(int i=numPlayers+1; i<=6; i++)
		[valueList addObject:@"-"];
	
	[valueList addObject:[formDataArray stringAtIndex:numPlayers+1]];
	[valueList addObject:[formDataArray stringAtIndex:numPlayers+2]];
	[valueList addObject:[formDataArray stringAtIndex:numPlayers+3]];
	[valueList addObject:[formDataArray stringAtIndex:numPlayers+4]];
	[valueList addObject:[NSString stringWithFormat:@"%d",numPlayers]];
	[valueList addObject:name];
	[valueList addObject:[formDataArray stringAtIndex:numPlayers+5]];
	[valueList addObject:[formDataArray stringAtIndex:numPlayers+6]];
	[valueList addObject:[formDataArray stringAtIndex:numPlayers+7]];
	[valueList addObject:[formDataArray stringAtIndex:numPlayers+8]];
	[valueList addObject:[formDataArray stringAtIndex:numPlayers+9]];
	
	if(drilldown) {
		NSLog(@"---updating: %d", indexPathRow);
	} else {
		NSLog(@"---inserting");
		mo = [NSEntityDescription insertNewObjectForEntityForName:@"BIGHAND" inManagedObjectContext:self.managedObjectContext];
	}
	
	[ProjectFunctions updateEntityInDatabase:self.managedObjectContext mo:mo valueList:valueList entityName:@"BIGHAND"];
	
	[mo setValue:nil forKey:@"preFlopOdds"];
	NSLog(@"---Done");
	
	
	BigHandsVC *detailViewController = [[BigHandsVC alloc] initWithNibName:@"BigHandsVC" bundle:nil];
	detailViewController.managedObjectContext = managedObjectContext;
	detailViewController.showMainMenuButton=YES;
	[self.navigationController pushViewController:detailViewController animated:YES];
	 
}

-(NSString *)unpackOdds:(NSString *)line number:(int)number
{
	if([line length]==0)
		return @"-";
	NSArray *components = [line componentsSeparatedByString:@"|"];
	NSString *item = [components stringAtIndex:number];
	item = [item stringByReplacingOccurrencesOfString:@"W" withString:@"Win "];
	item = [item stringByReplacingOccurrencesOfString:@"(C" withString:@" (Chop "];
	return item;
}


-(void)setupdata
{
	
	NSString *yourHandDefault = @"-select-";
	NSString *flopDefault = @"-select-";
	NSString *turnDefault = @"-select-";
	NSString *riverDefault = @"-select-";
	NSString *potsizeDefault = @"0";
	NSString *preflopDefault = @"";
	NSMutableArray *playerhands = [[NSMutableArray alloc] init];
	[playerhands addObject:@"-select-"];
	[playerhands addObject:@"-select-"];
	[playerhands addObject:@"-select-"];
	[playerhands addObject:@"-select-"];
	[playerhands addObject:@"-select-"];
	[playerhands addObject:@"-select-"];
	[playerhands addObject:@"-select-"];
	if(mo != nil) {
		yourHandDefault = [mo valueForKey:@"player1Hand"];
		flopDefault = [mo valueForKey:@"flop"];
		turnDefault = [mo valueForKey:@"turn"];
		riverDefault = [mo valueForKey:@"river"];
		numPlayers = [[mo valueForKey:@"numPlayers"] intValue];
		potsizeDefault = [NSString stringWithFormat:@"%d", [[mo valueForKey:@"potsize"] intValue]];
		if([mo valueForKey:@"preflopAction"])
			preflopDefault = [mo valueForKey:@"preflopAction"];
		[playerhands replaceObjectAtIndex:2 withObject:[mo valueForKey:@"player2Hand"]];
		[playerhands replaceObjectAtIndex:3 withObject:[mo valueForKey:@"player3Hand"]];
		[playerhands replaceObjectAtIndex:4 withObject:[mo valueForKey:@"player4Hand"]];
		[playerhands replaceObjectAtIndex:5 withObject:[mo valueForKey:@"player5Hand"]];
		[playerhands replaceObjectAtIndex:6 withObject:[mo valueForKey:@"player6Hand"]];
	}
	
	[labelValues addObject:@"Date"];
	[formDataArray addObject:[[NSDate date] convertDateToStringWithFormat:@"yyyy-MM-dd"]];
	
	[labelValues addObject:@"Your Hand"];
	[formDataArray addObject:yourHandDefault];
	
	for(int i=2; i<=numPlayers; i++) {
		[labelValues addObject:[NSString stringWithFormat:@"Player %i Hand", i]];
		[formDataArray addObject:[playerhands stringAtIndex:i]];
	}
	
	NSString *buttonText = [mo valueForKey:@"attrib02"];
	if([buttonText length]==0 || [buttonText length]>20)
		buttonText = @"You";
	
	[labelValues addObject:@"Flop"];
	[formDataArray addObject:flopDefault];

	[labelValues addObject:@"Turn"];
	[formDataArray addObject:turnDefault];

	[labelValues addObject:@"River"];
	[formDataArray addObject:riverDefault];
	
	[labelValues addObject:@"Pot Size"];
	[formDataArray addObject:potsizeDefault];
	
	[labelValues addObject:@"Analysis"];
	[formDataArray addObject:preflopDefault];
	
	[labelValues addObject:@"Button"];
	[formDataArray addObject:buttonText];
	
//	[labelValues addObject:@"Turn Action"];
//	[formDataArray addObject:turnADefault];
	
//	[labelValues addObject:@"River Action"];
//	[formDataArray addObject:riverADefault];
	
//	[labelValues addObject:@"Final Analysis"];
//	[formDataArray addObject:detailsDefault];
	
	[oddsDataArray addObject:[self unpackOdds:[mo valueForKey:@"preFlopOdds"] number:0]];
	[oddsDataArray addObject:[self unpackOdds:[mo valueForKey:@"postFlopOdds"] number:0]];
	[oddsDataArray addObject:[self unpackOdds:[mo valueForKey:@"turnOdds"] number:0]];
	[oddsDataArray addObject:[self unpackOdds:[mo valueForKey:@"riverOdds"] number:0]];
	[oddsDataArray addObject:[self unpackOdds:[mo valueForKey:@"finalHands"] number:0]];
	
}

-(void)drawCardBack:(UIView *)myView card:(NSString *)card suit:(NSString *)suit x:(int)x y:(int)y
{
	UIImageView *flop1Bg = [ [UIImageView alloc ] initWithFrame:CGRectMake((float)x+2, (float)y+2, 31.0, 38.0) ];
	[flop1Bg setImage:[UIImage imageNamed:@"cardBack.png"]];
	[myView addSubview:flop1Bg];
}

-(void)drawCard:(UIView *)myView card:(NSString *)card suit:(NSString *)suit x:(int)x y:(int)y
{
	// 50 190
	UIImageView *flop1Bg = [ [UIImageView alloc ] initWithFrame:CGRectMake((float)x, (float)y, 35.0, 42.0) ];
	[flop1Bg setImage:[UIImage imageNamed:@"blankCard.png"]];
	[myView addSubview:flop1Bg];
	
	UILabel *card1Label = [[UILabel alloc] initWithFrame:CGRectZero];
	card1Label.text = card;
	card1Label.frame = CGRectMake((float)x+12, (float)y+2, 20, 20);
	card1Label.backgroundColor = [UIColor clearColor];
	if([suit isEqualToString:@"d"] || [suit isEqualToString:@"h"])
		card1Label.textColor = [UIColor redColor];
	else 
		card1Label.textColor = [UIColor blackColor];
		
	[myView addSubview:card1Label];
	
	UIImageView *suitView = [ [UIImageView alloc ] initWithFrame:CGRectMake((float)x+8, (float)y+21, 20.0, 18.0) ];
	[suitView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"card%@.png", suit]]];
	[myView addSubview:suitView];
}

-(void)drawLabel:(UIView *)myView string:(NSString *)string x:(int)x y:(int)y size:(int)size color:(UIColor *)color
{
	float width=150.0;
	if(x<0) {
		width+=(x*2);
		x=0;
	}
	if(y<0)
		y=0;
	if(x+width>320) {
		int overRun = x+width-320;
		x+=overRun;
		width = 320-x;
	}
	if(width<100) {
		x-=10;
		width+=20;
	}
	UILabel *youLabel = [ [UILabel alloc ] initWithFrame:CGRectMake((float)x, (float)y, width, 43.0) ];
	youLabel.textAlignment =  NSTextAlignmentCenter;
	youLabel.textColor = color;
	youLabel.backgroundColor = [UIColor clearColor];
	youLabel.font = [UIFont fontWithName:@"Arial Rounded MT Bold" size:((float)size)];
	[myView addSubview:youLabel];
	youLabel.text = string;
}

-(void)drawImageInView:(UIView *)myView imageName:(NSString *)imageName x:(int)x y:(int)y width:(int)width height:(int)height
{
	UIImageView *buttonView = [ [UIImageView alloc ] initWithFrame:CGRectMake((float)x, (float)y, (float)width, (float)height) ];
	[buttonView setImage:[UIImage imageNamed:imageName]];
	[myView addSubview:buttonView];
	
}

-(void)drawAction:(UIView *)myView action:(NSString *)action bet:(int)bet x:(int)x y:(int)y {
	if([action isEqualToString:@"-Select-"])
		action = @"";
	NSString *betStr = @"";
	if(bet>0)
		betStr = [ProjectFunctions convertIntToMoneyString:bet];
	NSString *actionStr = [NSString stringWithFormat:@"%@ %@", action, betStr];
	[self drawLabel:myView string:actionStr x:x y:y size:12 color:[UIColor colorWithRed:1 green:1 blue:1 alpha:1]];
}

-(void)setupVisualView {
	[self drawLabel:visualView string:@"You" x:160 y:350 size:24 color:[UIColor whiteColor]];
	[self drawLabel:preflopView string:@"You" x:160 y:350 size:24 color:[UIColor whiteColor]];
	[self drawLabel:flopView string:@"You" x:160 y:350 size:24 color:[UIColor whiteColor]];
	[self drawLabel:turnView string:@"You" x:160 y:350 size:24 color:[UIColor whiteColor]];

	NSString *flop = [formDataArray stringAtIndex:numPlayers+1];
	NSString *turn = [formDataArray stringAtIndex:numPlayers+2];
	NSString *river = [formDataArray stringAtIndex:numPlayers+3];
	NSString *pot = [formDataArray stringAtIndex:numPlayers+4];
	NSArray *cards = [flop componentsSeparatedByString:@"-"];


	
	

	NSString *seat1X = @"130";
	NSString *seat1Y = @"350";
	NSString *seat2X = @"5";
	NSString *seat2Y = @"290";
	NSString *seat3X = @"5";
	NSString *seat3Y = @"100";
	NSString *seat4X = @"130";
	NSString *seat4Y = @"35";
	NSString *seat5X = @"250";
	NSString *seat5Y = @"100";
	NSString *seat6X = @"250";
	NSString *seat6Y = @"290";
	
	NSMutableArray *xPos = [[NSMutableArray alloc] init];
	NSMutableArray *yPos = [[NSMutableArray alloc] init];
	[xPos addObject:@"0"]; // empty
	[yPos addObject:@"0"]; // empty

	[xPos addObject:seat1X]; //-- you
	[yPos addObject:seat1Y]; //-- you
	
	if(numPlayers==2) {
		[xPos addObject:seat4X]; //-- 
		[yPos addObject:seat4Y]; //-- 
	}
	
	if(numPlayers==3) {
		[xPos addObject:seat3X]; //-- 
		[yPos addObject:seat3Y]; //-- 
		[xPos addObject:seat5X]; //-- 
		[yPos addObject:seat5Y]; //-- 
	}
	
	if(numPlayers==4) {
		[xPos addObject:seat3X]; //-- 
		[yPos addObject:seat3Y]; //-- 
		[xPos addObject:seat4X]; //-- 
		[yPos addObject:seat4Y]; //-- 
		[xPos addObject:seat5X]; //-- 
		[yPos addObject:seat5Y]; //-- 
	}
	if(numPlayers>4) {
		[xPos addObject:seat2X]; //-- 
		[yPos addObject:seat2Y]; //-- 
		[xPos addObject:seat3X]; //-- 
		[yPos addObject:seat3Y]; //-- 
		[xPos addObject:seat4X]; //-- 
		[yPos addObject:seat4Y]; //-- 
		[xPos addObject:seat5X]; //-- 
		[yPos addObject:seat5Y]; //-- 
		[xPos addObject:seat6X]; //-- 
		[yPos addObject:seat6Y]; //-- 
	}
	
	
	int cardX=0;
	int cardY=0;

	NSString *buttonName = [mo valueForKey:@"attrib02"];
	NSArray *components = [buttonName componentsSeparatedByString:@" "];

	int button= [[components stringAtIndex:1] intValue];
	if(button==0)
		button=1;
	cardX=[[xPos stringAtIndex:button] intValue];
	cardY=[[yPos stringAtIndex:button] intValue];
	if(button>=5)
		cardX-=90;
	[self drawImageInView:preflopView imageName:@"button.png" x:cardX+70 y:cardY-5 width:20 height:20];
	[self drawImageInView:flopView imageName:@"button.png" x:cardX+70 y:cardY-5 width:20 height:20];
	[self drawImageInView:turnView imageName:@"button.png" x:cardX+70 y:cardY-5 width:20 height:20];
	[self drawImageInView:visualView imageName:@"button.png" x:cardX+70 y:cardY-5 width:20 height:20];
	
	int preflopPot=0;
	int flopPot=0;
	int turnPot=0;
	int riverPot=0;
	for(int i=1; i<=numPlayers; i++) {
		NSString *cardStr = [formDataArray stringAtIndex:i];
		cardX=[[xPos stringAtIndex:i] intValue];
		cardY=[[yPos stringAtIndex:i] intValue];
		NSArray *cardsArray = [cardStr componentsSeparatedByString:@"-"];
		[self drawCard:visualView card:[[cardsArray stringAtIndex:0] substringToIndex:1] suit:[[cardsArray stringAtIndex:0] substringFromIndex:1] x:cardX y:cardY];
		[self drawCard:visualView card:[[cardsArray stringAtIndex:1] substringToIndex:1] suit:[[cardsArray stringAtIndex:1] substringFromIndex:1] x:cardX+35 y:cardY];

		[self drawCard:preflopView card:[[cardsArray stringAtIndex:0] substringToIndex:1] suit:[[cardsArray stringAtIndex:0] substringFromIndex:1] x:cardX y:cardY];
		[self drawCard:preflopView card:[[cardsArray stringAtIndex:1] substringToIndex:1] suit:[[cardsArray stringAtIndex:1] substringFromIndex:1] x:cardX+35 y:cardY];

		[self drawCard:flopView card:[[cardsArray stringAtIndex:0] substringToIndex:1] suit:[[cardsArray stringAtIndex:0] substringFromIndex:1] x:cardX y:cardY];
		[self drawCard:flopView card:[[cardsArray stringAtIndex:1] substringToIndex:1] suit:[[cardsArray stringAtIndex:1] substringFromIndex:1] x:cardX+35 y:cardY];

		[self drawCard:turnView card:[[cardsArray stringAtIndex:0] substringToIndex:1] suit:[[cardsArray stringAtIndex:0] substringFromIndex:1] x:cardX y:cardY];
		[self drawCard:turnView card:[[cardsArray stringAtIndex:1] substringToIndex:1] suit:[[cardsArray stringAtIndex:1] substringFromIndex:1] x:cardX+35 y:cardY];

		int handValue = [PokerOddsFunctions determinHandStrength:cardStr flop:flop turn:turn river:river];
		NSString *handName = [PokerOddsFunctions getNameOfhandFromValue:handValue];
		[self drawLabel:visualView string:handName x:cardX-35 y:cardY+30 size:16 color:[UIColor yellowColor]];

		handValue = [PokerOddsFunctions determinHandStrength:cardStr flop:flop turn:@"1y" river:@"0x"];
		handName = [PokerOddsFunctions getNameOfhandFromValue:handValue];
		[self drawLabel:flopView string:handName x:cardX-35 y:cardY+30 size:16 color:[UIColor yellowColor]];

		handValue = [PokerOddsFunctions determinHandStrength:cardStr flop:flop turn:turn river:@"1x"];
		handName = [PokerOddsFunctions getNameOfhandFromValue:handValue];
		[self drawLabel:turnView string:handName x:cardX-35 y:cardY+30 size:16 color:[UIColor yellowColor]];
		
		[self drawLabel:preflopView string:[self unpackOdds:[mo valueForKey:@"preFlopOdds"] number:i-1] x:cardX-40 y:cardY-35 size:14 color:[UIColor colorWithRed:1 green:.8 blue:0 alpha:1]];
		[self drawLabel:flopView string:[self unpackOdds:[mo valueForKey:@"postFlopOdds"] number:i-1] x:cardX-40 y:cardY-35 size:14 color:[UIColor colorWithRed:1 green:.8 blue:0 alpha:1]];
		[self drawLabel:turnView string:[self unpackOdds:[mo valueForKey:@"turnOdds"] number:i-1] x:cardX-40 y:cardY-35 size:14 color:[UIColor colorWithRed:1 green:.8 blue:0 alpha:1]];
		[self drawLabel:visualView string:[self unpackOdds:[mo valueForKey:@"riverOdds"] number:i-1] x:cardX-40 y:cardY-35 size:14 color:[UIColor colorWithRed:1 green:.8 blue:0 alpha:1]];

		NSString *playerText = [NSString stringWithFormat:@"Player %d", i];
		
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"playerNum = %d AND bighand = %@", i, mo];
		NSArray *items = [CoreDataLib selectRowsFromEntity:@"PLAYER" predicate:predicate sortColumn:nil mOC:managedObjectContext ascendingFlg:NO];
		if([items count]>0) {
			NSManagedObject *playerVals = [items objectAtIndex:0];
			[self drawAction:preflopView action:[playerVals valueForKey:@"preflopOdds"] bet:[[playerVals valueForKey:@"preflopBet"] intValue] x:cardX-40 y:cardY-50];
			[self drawAction:flopView action:[playerVals valueForKey:@"flopOdds"] bet:[[playerVals valueForKey:@"flopBet"] intValue] x:cardX-40 y:cardY-50];
			[self drawAction:turnView action:[playerVals valueForKey:@"turnOdds"] bet:[[playerVals valueForKey:@"turnBet"] intValue] x:cardX-40 y:cardY-50];
			[self drawAction:visualView action:[playerVals valueForKey:@"result"] bet:[[playerVals valueForKey:@"riverBet"] intValue] x:cardX-40 y:cardY-50];
			
			preflopPot += [[playerVals valueForKey:@"preflopBet"] intValue];
			flopPot += [[playerVals valueForKey:@"flopBet"] intValue];
			turnPot += [[playerVals valueForKey:@"turnBet"] intValue];
			riverPot += [[playerVals valueForKey:@"riverBet"] intValue];

			int startingChips = [[playerVals valueForKey:@"chips"] intValue];
			if(startingChips>0)
				playerText = [NSString stringWithFormat:@"Player %d (%@)", i, [ProjectFunctions convertIntToMoneyString:startingChips]];
			
		}
		[self drawLabel:preflopView string:playerText x:cardX-40 y:cardY+30 size:11 color:[UIColor colorWithRed:1 green:1 blue:1 alpha:1]];
		
		
	}
	
	[self drawLabel:preflopView string:[ProjectFunctions convertIntToMoneyString:preflopPot] x:90 y:230 size:32 color:[UIColor yellowColor]];
	[self drawLabel:flopView string:[ProjectFunctions convertIntToMoneyString:preflopPot+flopPot] x:90 y:230 size:32 color:[UIColor yellowColor]];
	[self drawLabel:turnView string:[ProjectFunctions convertIntToMoneyString:preflopPot+flopPot+turnPot] x:90 y:230 size:32 color:[UIColor yellowColor]];
	if(preflopPot+flopPot+turnPot+riverPot>0)
		[self drawLabel:visualView string:[ProjectFunctions convertIntToMoneyString:preflopPot+flopPot+turnPot+riverPot] x:90 y:230 size:32 color:[UIColor yellowColor]];
	else 
		[self drawLabel:visualView string:[ProjectFunctions convertIntToMoneyString:[pot intValue]] x:90 y:230 size:32 color:[UIColor yellowColor]];


	int flopx = 65;
	int flopy = 190;
	NSString *c1 = [[cards stringAtIndex:0] substringToIndex:1];
	NSString *s1 = [[cards stringAtIndex:0] substringFromIndex:1];
	NSString *c2 = [[cards stringAtIndex:1] substringToIndex:1];
	NSString *s2 = [[cards stringAtIndex:1] substringFromIndex:1];
	NSString *c3 = [[cards stringAtIndex:2] substringToIndex:1];
	NSString *s3 = [[cards stringAtIndex:2] substringFromIndex:1];
	NSString *c4 = [turn substringToIndex:1];
	NSString *s4 = [turn substringFromIndex:1];
	NSString *c5 = [river substringToIndex:1];
	NSString *s5 = [river substringFromIndex:1];
	// Flop
	[self drawCard:visualView card:c1 suit:s1 x:flopx y:flopy];
	[self drawCard:visualView card:c2 suit:s2 x:flopx+35 y:flopy];
	[self drawCard:visualView card:c3 suit:s3 x:flopx+70 y:flopy];

	[self drawCard:flopView card:c1 suit:s1 x:flopx y:flopy];
	[self drawCard:flopView card:c2 suit:s2 x:flopx+35 y:flopy];
	[self drawCard:flopView card:c3 suit:s3 x:flopx+70 y:flopy];

	[self drawCard:turnView card:c1 suit:s1 x:flopx y:flopy];
	[self drawCard:turnView card:c2 suit:s2 x:flopx+35 y:flopy];
	[self drawCard:turnView card:c3 suit:s3 x:flopx+70 y:flopy];
	
	[self drawCardBack:preflopView card:c1 suit:s1 x:flopx y:flopy];
	[self drawCardBack:preflopView card:c1 suit:s1 x:flopx+35 y:flopy];
	[self drawCardBack:preflopView card:c1 suit:s1 x:flopx+70 y:flopy];

	// turn
	[self drawCard:visualView card:c4 suit:s4 x:flopx+115 y:flopy];
	[self drawCard:turnView card:c4 suit:s4 x:flopx+115 y:flopy];
	[self drawCardBack:preflopView card:c4 suit:s4 x:flopx+115 y:flopy];
	[self drawCardBack:flopView card:c4 suit:s4 x:flopx+115 y:flopy];

	
	//river
	[self drawCard:visualView card:c5 suit:s5 x:flopx+160 y:flopy];
	[self drawCardBack:preflopView card:c5 suit:s5 x:flopx+160 y:flopy];
	[self drawCardBack:flopView card:c5 suit:s5 x:flopx+160 y:flopy];
	[self drawCardBack:turnView card:c5 suit:s5 x:flopx+160 y:flopy];
	
	[self drawLabel:visualView string:@"Final" x:90 y:150 size:18 color:[UIColor whiteColor]];
	[self drawLabel:preflopView string:@"Pre-Flop" x:90 y:150 size:18 color:[UIColor whiteColor]];
	[self drawLabel:flopView string:@"Flop" x:90 y:150 size:18 color:[UIColor whiteColor]];
	[self drawLabel:turnView string:@"Turn" x:90 y:150 size:18 color:[UIColor whiteColor]];
	
}

- (void)viewDidLoad {
    [super viewDidLoad];
	[self setTitle:@"Hand Tracker"];
    
    [self.mainTableView setBackgroundView:nil];
	
	[ProjectFunctions makeFAButton:self.playButton type:9 size:24];
	[ProjectFunctions makeFAButton:self.editButton type:2 size:24];

	deleteButton.titleLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:24];
	[deleteButton setTitle:[NSString fontAwesomeIconStringForEnum:FAtrash] forState:UIControlStateNormal];

	self.selectedRow=0;
	self.indexPathRow=0;
	self.viewEditable=YES;
	labelValues = [[NSMutableArray alloc] init];
	formDataArray = [[NSMutableArray alloc] init];
	oddsDataArray = [[NSMutableArray alloc] init];
	
	if(mo != nil)
		self.numPlayers = [[mo valueForKey:@"numPlayers"] intValue];
	
	[self setupdata];
	
	winLossSegment.tintColor = [UIColor colorWithRed:.8 green:.6 blue:0 alpha:1];
	nextButton.alpha=0;
	visualView.alpha=0;
	preflopView.alpha=0;
	flopView.alpha=0;
	turnView.alpha=0;
	viewButton.alpha=0;
	oddsButton.alpha=0;
	deleteButton.alpha=0;
	
	if(mo != nil) {
		NSString *winStatus = [mo valueForKey:@"winStatus"];
		
		if([winStatus isEqualToString:@"Loss"])
			winLossSegment.selectedSegmentIndex=1;
		if([winStatus isEqualToString:@"Chop"])
			winLossSegment.selectedSegmentIndex=2;

		self.viewEditable=NO;
		viewButton.alpha=1;
		
		[self setupVisualView];
		
		
	}

	
	
	NSString *buttonName = (drilldown)?[NSString fontAwesomeIconStringForEnum:FAPencil]:[NSString fontAwesomeIconStringForEnum:FAFloppyO];
	saveButton = [[UIBarButtonItem alloc] initWithTitle:buttonName style:UIBarButtonItemStylePlain target:self action:@selector(saveButtonClicked:)];
	
	saveButton = [ProjectFunctions UIBarButtonItemWithIcon:buttonName target:self action:@selector(saveButtonClicked:)];
	self.navigationItem.rightBarButtonItem = saveButton;

	saveButton.enabled=drilldown;
	self.playButton.enabled=NO;
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	if(section==0)
		return [formDataArray count]+1;
	else {
		return 1;
	}

}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if(indexPath.section==2) {
		int height = [MultiLineDetailCellWordWrap cellHeightWithNoMainTitleForData:[NSArray arrayWithObjects:[formDataArray stringAtIndex:numPlayers+5],[formDataArray stringAtIndex:numPlayers+6],[formDataArray stringAtIndex:numPlayers+7],[formDataArray stringAtIndex:numPlayers+8],[formDataArray stringAtIndex:numPlayers+9], nil]
																		 tableView:tableView
															  labelWidthProportion:kLeftMargine]+20;
		return height;
	} 
	if(indexPath.section==1)
		return [MultiLineDetailCellWordWrap cellHeightWithNoMainTitleForData:oddsDataArray
																						 tableView:tableView
																			  labelWidthProportion:0.4]+20;
	
	return 44;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	NSString *cellIdentifier = [NSString stringWithFormat:@"cellIdentifierSection%dRow%d", (int)indexPath.section, (int)indexPath.row];
	
	NSString *mainLabel=@"Error";
	NSString *mainValue=@"Error";
	if(labelValues && indexPath.row<[labelValues count])
		mainLabel = [labelValues stringAtIndex:(int)indexPath.row];
	if(formDataArray && indexPath.row<[formDataArray count])
		mainValue = [formDataArray stringAtIndex:(int)indexPath.row];
	
	if(indexPath.section==0) {
		if(indexPath.row>=[formDataArray count]) {
			ActionCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
			if (cell == nil) {
				cell = [[ActionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
			}
			cell.backgroundColor = [UIColor colorWithRed:1 green:.8 blue:0 alpha:1];
			if(mo != nil && !viewEditable)
				cell.textLabel.text = @"Load Odds Calculator";
			else {
				if(saveButton.enabled)
					cell.textLabel.text = @"-";
				else
					cell.textLabel.text = @"Complete With Random Cards";
			}
			
			return cell;
		}
		if(indexPath.row>=1 && indexPath.row<=numPlayers+3) {
			return [PokerCell pokerCell:tableView cellIdentifier:cellIdentifier cellLabel:mainLabel cellValue:mainValue viewEditable:viewEditable];
		} else {
			SelectionCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
			if (cell == nil) {
				cell = [[SelectionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
			}
			
			cell.textLabel.text = mainLabel;
			cell.selection.text = mainValue;
			if(indexPath.row==numPlayers+4)
				cell.selection.text = [NSString stringWithFormat:@"%@%@", [ProjectFunctions getMoneySymbol], mainValue];
			
			cell.backgroundColor = [UIColor ATTFaintBlue];
			cell.selectionStyle = UITableViewCellSelectionStyleGray;
			if(viewEditable)
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			else
				cell.accessoryType = UITableViewCellAccessoryNone;
			
			return cell;
		}

	}
	if(indexPath.section==1) {

		MultiLineDetailCellWordWrap *cell = (MultiLineDetailCellWordWrap *) [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
		if (cell == nil) {
			cell = [[MultiLineDetailCellWordWrap alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier withRows:5 labelProportion:0.4];
		}
		cell.mainTitle = @"Your Odds";
		NSString *altTitle = @"";
		if(mo != nil)
			altTitle = [mo valueForKey:@"name"];
		cell.alternateTitle = altTitle;
		cell.titleTextArray = [NSArray arrayWithObjects:@"Preflop Odds", @"Postflop Odds", @"Turn Odds", @"Result", @"Final Hands", nil];

		cell.fieldTextArray = oddsDataArray;
		cell.accessoryType = UITableViewCellAccessoryNone;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		return cell;
	} else {
		MultiLineDetailCellWordWrap *cell = (MultiLineDetailCellWordWrap *) [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
		if (cell == nil) {
			cell = [[MultiLineDetailCellWordWrap alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier withRows:5 labelProportion:kLeftMargine];
		}
		cell.mainTitle = @"Details";
		NSString *altTitle = @"";
		if(mo != nil)
			altTitle = [mo valueForKey:@"name"];
		cell.alternateTitle = altTitle;
		if(formDataArray && numPlayers+9<[formDataArray count]) {
			cell.titleTextArray = [NSArray arrayWithObjects:@"Preflop", @"Postflop", @"Turn", @"River", @"Analysis", nil];
			cell.fieldTextArray = [NSArray arrayWithObjects:[formDataArray stringAtIndex:numPlayers+5], [formDataArray stringAtIndex:numPlayers+6], [formDataArray stringAtIndex:numPlayers+7], [formDataArray stringAtIndex:numPlayers+8], [formDataArray stringAtIndex:numPlayers+9], nil];
		}
		cell.accessoryType = UITableViewCellAccessoryNone;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		return cell;
	}

		
}

- (IBAction) oddsButtonPressed: (id) sender
{
	OddsFormVC *detailViewController = [[OddsFormVC alloc] initWithNibName:@"OddsFormVC" bundle:nil];
	detailViewController.numPlayers = numPlayers;
	detailViewController.preLoaedValues = formDataArray;
	detailViewController.managedObjectContext = managedObjectContext;
	detailViewController.mo = mo;
	[self.navigationController pushViewController:detailViewController animated:YES];
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if(indexPath.section>0)
		return;
	
//	NSLog(@"+++%d %d", indexPath.row, numPlayers);
	if(indexPath.row == [formDataArray count]) {
		if(mo != nil && !viewEditable) {	// load calculator
			OddsFormVC *detailViewController = [[OddsFormVC alloc] initWithNibName:@"OddsFormVC" bundle:nil];
			detailViewController.numPlayers = numPlayers;
			detailViewController.preLoaedValues = formDataArray;
			detailViewController.managedObjectContext = managedObjectContext;
			detailViewController.mo = mo;
			[self.navigationController pushViewController:detailViewController animated:YES];
		} else { // complete with random cards
			NSMutableArray *playerHands = [[NSMutableArray alloc] init];
			NSString *burnedCards = [NSString stringWithFormat:@"%@-%@-%@", [formDataArray stringAtIndex:numPlayers+1], [formDataArray stringAtIndex:numPlayers+2], [formDataArray stringAtIndex:numPlayers+3]];
			for(int i=1; i<=numPlayers; i++) {
				NSString *currentValue = [formDataArray stringAtIndex:i];
				if([currentValue isEqualToString:@"-select-"]) {
					NSString *card1 = [PokerOddsFunctions getRandomCard:burnedCards];
					burnedCards = [NSString stringWithFormat:@"%@-%@", burnedCards, card1];
					NSString *card2 = [PokerOddsFunctions getRandomCard:burnedCards];
					burnedCards = [NSString stringWithFormat:@"%@-%@", burnedCards, card2];
					[playerHands addObject:[NSString stringWithFormat:@"%@-%@", card1, card2]];
					[formDataArray replaceObjectAtIndex:i withObject:[NSString stringWithFormat:@"%@-%@", card1, card2]];
				}
			}
			NSString *flop = [formDataArray stringAtIndex:numPlayers+1];
			if([flop isEqualToString:@"-select-"]) {
				NSString *burnedCards = [PokerOddsFunctions getBurnedCards:playerHands flop:@"" turn:[formDataArray stringAtIndex:numPlayers+2] river:[formDataArray stringAtIndex:numPlayers+3]];
				flop = [PokerOddsFunctions getRandomFlop:burnedCards];
				[formDataArray replaceObjectAtIndex:numPlayers+1 withObject:flop];
			}
			burnedCards = [NSString stringWithFormat:@"%@-%@", burnedCards, flop];
			
			NSString *turn = [formDataArray stringAtIndex:numPlayers+2];
			if([turn isEqualToString:@"-select-"]) {
				turn = [PokerOddsFunctions getRandomCard:burnedCards];
				[formDataArray replaceObjectAtIndex:numPlayers+2 withObject:turn];
			}
			NSString *river = [formDataArray stringAtIndex:numPlayers+3];
			if([river isEqualToString:@"-select-"]) {
				burnedCards = [NSString stringWithFormat:@"%@-%@", burnedCards, turn];
				[formDataArray replaceObjectAtIndex:numPlayers+3 withObject:[PokerOddsFunctions getRandomCard:burnedCards]];
			}
			saveButton.enabled=YES;
			[mainTableView reloadData];
			return;
		}

	}
	if(!viewEditable)
		return;
	
	selectedRow = (int)indexPath.row;

	NSMutableArray *playerHands = [[NSMutableArray alloc] init];
	for(int i=1; i<numPlayers+1; i++)
		[playerHands addObject:[formDataArray stringAtIndex:i]];
	
	if(selectedRow==0) {
		DatePickerViewController *localViewController = [[DatePickerViewController alloc] init];
		localViewController.labelString = [labelValues stringAtIndex:(int)indexPath.row];
		[localViewController setCallBackViewController:self];
		localViewController.initialDateValue = nil;
		localViewController.allowClearField = NO;
		localViewController.dateOnlyMode = YES;
		localViewController.refusePastDates=NO;
		localViewController.initialValueString = [formDataArray stringAtIndex:(int)indexPath.row];
		[self.navigationController pushViewController:localViewController animated:YES];
	} else if(selectedRow<=numPlayers) {
		CardHandPicker *detailViewController = [[CardHandPicker alloc] initWithNibName:@"CardHandPicker" bundle:nil];
		detailViewController.managedObjectContext=managedObjectContext;
		detailViewController.titleLabel = [labelValues stringAtIndex:(int)indexPath.row];
		detailViewController.callBackViewController=self;
		detailViewController.numberCards=2;
		detailViewController.initialDateValue = [formDataArray stringAtIndex:(int)indexPath.row];
		detailViewController.burnedcards = [PokerOddsFunctions getBurnedCardsMinusThese:playerHands flop:[formDataArray stringAtIndex:numPlayers+1] turn:[formDataArray stringAtIndex:numPlayers+2] river:[formDataArray stringAtIndex:numPlayers+3] removeIndex:(int)indexPath.row-1];
		[self.navigationController pushViewController:detailViewController animated:YES];
	} else 	if(selectedRow==numPlayers+1) {
		CardHandPicker *detailViewController = [[CardHandPicker alloc] initWithNibName:@"CardHandPicker" bundle:nil];
		detailViewController.managedObjectContext=managedObjectContext;
		detailViewController.titleLabel = [labelValues stringAtIndex:(int)indexPath.row];
		detailViewController.callBackViewController=self;
		detailViewController.initialDateValue = [formDataArray stringAtIndex:(int)indexPath.row];
		detailViewController.burnedcards = [PokerOddsFunctions getBurnedCardsMinusThese:playerHands flop:[formDataArray stringAtIndex:numPlayers+1] turn:[formDataArray stringAtIndex:numPlayers+2] river:[formDataArray stringAtIndex:numPlayers+3] removeIndex:(int)indexPath.row-1];
		detailViewController.numberCards=3;
		[self.navigationController pushViewController:detailViewController animated:YES];
	} else if(selectedRow<=numPlayers+3) {
		CardHandPicker *detailViewController = [[CardHandPicker alloc] initWithNibName:@"CardHandPicker" bundle:nil];
		detailViewController.managedObjectContext=managedObjectContext;
		detailViewController.titleLabel = [labelValues stringAtIndex:(int)indexPath.row];
		detailViewController.callBackViewController=self;
		detailViewController.initialDateValue = [formDataArray stringAtIndex:(int)indexPath.row];
		detailViewController.numberCards=1;
		detailViewController.burnedcards = [PokerOddsFunctions getBurnedCardsMinusThese:playerHands flop:[formDataArray stringAtIndex:numPlayers+1] turn:[formDataArray stringAtIndex:numPlayers+2] river:[formDataArray stringAtIndex:numPlayers+3] removeIndex:(int)indexPath.row-1];
		[self.navigationController pushViewController:detailViewController animated:YES];
	} else if(selectedRow<=numPlayers+4) {
		MoneyPickerVC *localViewController = [[MoneyPickerVC alloc] initWithNibName:@"MoneyPickerVC" bundle:nil];
		localViewController.managedObjectContext=managedObjectContext;
		localViewController.callBackViewController = self;
		localViewController.initialDateValue = [formDataArray stringAtIndex:(int)indexPath.row];
		localViewController.titleLabel = [labelValues stringAtIndex:(int)indexPath.row];
		[self.navigationController pushViewController:localViewController animated:YES];
	} else if(selectedRow==numPlayers+6) {
		ListPicker *detailViewController = [[ListPicker alloc] initWithNibName:@"ListPicker" bundle:nil];
		detailViewController.managedObjectContext=managedObjectContext;
		detailViewController.initialDateValue = [formDataArray stringAtIndex:(int)indexPath.row];
		detailViewController.titleLabel = [labelValues stringAtIndex:(int)indexPath.row];
		detailViewController.callBackViewController = self;
		NSMutableArray *players = [[NSMutableArray alloc] init];
		[players addObject:@"You"];
		for(int i=2; i<=numPlayers; i++)
			[players addObject:[NSString stringWithFormat:@"Player %d", i]];
		detailViewController.selectionList = players;
		detailViewController.allowEditing=NO;
		detailViewController.hideNumRecords=YES;
		[self.navigationController pushViewController:detailViewController animated:YES];
	} else  {
		TextEnterVC *localViewController = [[TextEnterVC alloc] initWithNibName:@"TextEnterVC" bundle:nil];
		[localViewController setCallBackViewController:self];
		localViewController.managedObjectContext=managedObjectContext;
		localViewController.initialDateValue = [formDataArray stringAtIndex:(int)indexPath.row];
		localViewController.titleLabel = [labelValues stringAtIndex:(int)indexPath.row];
		[self.navigationController pushViewController:localViewController animated:YES];
	}	
	
		
}



#pragma mark -
#pragma mark Memory management


-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if([self respondsToSelector:@selector(edgesForExtendedLayout)])
        [self setEdgesForExtendedLayout:UIRectEdgeBottom];
}



-(void) setReturningValue:(NSString *) value2 {
	NSString *value = [ProjectFunctions getUserDefaultValue:@"returnValue"];
	if(selectedRow<[formDataArray count] && value != nil)
		[formDataArray replaceObjectAtIndex:selectedRow withObject:value];
	saveButton.enabled=YES;
	for(NSString *value in formDataArray)
		if([value isEqualToString:@"-select-"])
			saveButton.enabled = NO;
	
	[mainTableView reloadData];
}




@end

