//
//  CasinoGamesAddVC.m
//  PokerTracker
//
//  Created by Rick Medved on 1/21/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "CasinoGamesAddVC.h"
#import "TextLineEnterVC.h" 
#import "MoneyPickerVC.h"
#import "NSArray+ATTArray.h"
#import "ProjectFunctions.h"

@implementation CasinoGamesAddVC
@synthesize game, limit, stakes, selectedRow, callBackViewController, managedObjectContext;
@synthesize gameTypeSegment, dayOfWeekSegment, gameName, buyinLabel;
@synthesize buyinAmount, but11, but12, but13, but14, but15, but21, but22, but23, but24;

-(void)updateGameName
{
	gameName.text = [NSString stringWithFormat:@"%@,%@,%@", game.text, stakes.text, limit.text];
}
- (IBAction) button11Pressed: (id) sender
{
	game.text = @"Hold 'Em";
	[self updateGameName];
}
- (IBAction) button12Pressed: (id) sender
{
	game.text = @"Omaha";
	[self updateGameName];
}

- (IBAction) button13Pressed: (id) sender
{
	game.text = @"Razz";
	[self updateGameName];
}

- (IBAction) button14Pressed: (id) sender
{
	game.text = @"7-Card";
	[self updateGameName];
}
- (IBAction) button15Pressed: (id) sender
{
	self.selectedRow=0;
	TextLineEnterVC *detailViewController = [[TextLineEnterVC alloc] initWithNibName:@"TextLineEnterVC" bundle:nil];
	detailViewController.initialDateValue = @"";
	detailViewController.titleLabel = NSLocalizedString(@"Game", nil);
	detailViewController.callBackViewController = self;
	[self.navigationController pushViewController:detailViewController animated:YES];
}
- (IBAction) daySegmentPressed: (id) sender
{
	NSArray *days = [ProjectFunctions namesOfAllWeekdays];
	limit.text = [days stringAtIndex:(int)dayOfWeekSegment.selectedSegmentIndex];
	[self updateGameName];
}

- (IBAction) buyinButtonPressed: (id) sender
{
	self.selectedRow=3;
	MoneyPickerVC *detailViewController = [[MoneyPickerVC alloc] initWithNibName:@"MoneyPickerVC" bundle:nil];
	detailViewController.initialDateValue = buyinAmount.titleLabel.text;
	detailViewController.titleLabel = NSLocalizedString(@"Buyin", nil);
	detailViewController.callBackViewController = self;
	[self.navigationController pushViewController:detailViewController animated:YES];
}


- (IBAction) button21Pressed: (id) sender
{
	limit.text = @"Limit";
	[self updateGameName];
}
- (IBAction) button22Pressed: (id) sender
{
	limit.text = @"No-Limit";
	[self updateGameName];
}
- (IBAction) button23Pressed: (id) sender
{
	limit.text = @"Pot-Limit";
	[self updateGameName];
}
- (IBAction) button24Pressed: (id) sender
{
	limit.text = @"Spread";
	[self updateGameName];
}

- (IBAction) button31Pressed: (id) sender
{
	stakes.text = @"$1/$2";
	[self updateGameName];
}
- (IBAction) button32Pressed: (id) sender
{
	stakes.text = @"$1/$3";
	[self updateGameName];
}
- (IBAction) button33Pressed: (id) sender
{
	stakes.text = @"$3/$5";
	[self updateGameName];
}
- (IBAction) button34Pressed: (id) sender
{
	stakes.text = @"$5/$10";
	[self updateGameName];
}
- (IBAction) button35Pressed: (id) sender
{
	self.selectedRow=2;
	TextLineEnterVC *detailViewController = [[TextLineEnterVC alloc] initWithNibName:@"TextLineEnterVC" bundle:nil];
	detailViewController.initialDateValue = @"";
	detailViewController.titleLabel = NSLocalizedString(@"Stakes", nil);
	detailViewController.callBackViewController = self;
	[self.navigationController pushViewController:detailViewController animated:YES];
}

- (IBAction) addButtonClicked: (id) sender
{
	NSString *type = (gameTypeSegment.selectedSegmentIndex==0)?@"(c)":@"(t)";
	[(ProjectFunctions *)callBackViewController setReturningValue:[NSString stringWithFormat:@"%@ %@, %@, %@", type, game.text, stakes.text, limit.text]];
	[self.navigationController popViewControllerAnimated:YES];
}

- (IBAction) segmentClicked: (id) sender
{
	if(gameTypeSegment.selectedSegmentIndex==0) {
		dayOfWeekSegment.alpha=0;
		buyinAmount.alpha=0;
		buyinLabel.alpha=0;
		but11.alpha=1;
		but12.alpha=1;
		but13.alpha=1;
		but14.alpha=1;
		but15.alpha=1;
		but21.alpha=1;
		but22.alpha=1;
		but23.alpha=1;
		but24.alpha=1;
		stakes.text = @"$1/$2";
		limit.text = @"No-Limit";
	} else {
		dayOfWeekSegment.alpha=1;
		buyinAmount.alpha=1;
		buyinLabel.alpha=1;
		but11.alpha=0;
		but12.alpha=0;
		but13.alpha=0;
		but14.alpha=0;
		but15.alpha=0;
		but21.alpha=0;
		but22.alpha=0;
		but23.alpha=0;
		but24.alpha=0;
		stakes.text = @"$30";
		buyinLabel.text = @"$30";
		dayOfWeekSegment.selectedSegmentIndex=0;
		limit.text = @"Mondays";
	}
	[self updateGameName];
}



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];

	UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithTitle:@"Add" style:UIBarButtonItemStylePlain target:self action:@selector(addButtonClicked:)];
	self.navigationItem.rightBarButtonItem = addButton;
	
	dayOfWeekSegment.alpha=0;
	buyinAmount.alpha=0;
	buyinLabel.alpha=0;
	
	gameName.text = @"Hold 'Em,$1/$2,No Limit";
	
}

-(void) setReturningValue:(NSString *) value {
	if(selectedRow==0)
		game.text = value;
	else
		stakes.text = value;
	
	if(selectedRow==3)
		buyinAmount.titleLabel.text = [NSString stringWithFormat:@"%@%@", [ProjectFunctions getMoneySymbol], value];
	[self updateGameName];

}



/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}




@end
