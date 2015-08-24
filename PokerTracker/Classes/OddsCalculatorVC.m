//
//  OddsCalculatorVC.m
//  PokerTracker
//
//  Created by Rick Medved on 10/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "OddsCalculatorVC.h"
#import "OddsFormVC.h"
#import "BigHandsFormVC.h"


@implementation OddsCalculatorVC
@synthesize bigHandsFlag;
@synthesize managedObjectContext;
@synthesize button1, button2, button3, button4;

-(void)gotoFormVC:(int)number
{
	if(bigHandsFlag) {
		BigHandsFormVC *detailViewController = [[BigHandsFormVC alloc] initWithNibName:@"BigHandsFormVC" bundle:nil];
		detailViewController.managedObjectContext = managedObjectContext;
		detailViewController.numPlayers = number;
		detailViewController.viewEditable = NO;
		detailViewController.drilldown=NO;
		detailViewController.mo = nil;
		[self.navigationController pushViewController:detailViewController animated:YES];
	} else {
		OddsFormVC *detailViewController = [[OddsFormVC alloc] initWithNibName:@"OddsFormVC" bundle:nil];
		detailViewController.numPlayers = number;
		detailViewController.managedObjectContext = managedObjectContext;
		detailViewController.mo = nil;
		detailViewController.preLoaedValues = nil;
		[self.navigationController pushViewController:detailViewController animated:YES];
	}
}

- (IBAction) players2Pressed: (id) sender
{
	[self gotoFormVC:2];
}

- (IBAction) players3Pressed: (id) sender
{
	[self gotoFormVC:3];
}

- (IBAction) players4Pressed: (id) sender
{
	[self gotoFormVC:4];
}

- (IBAction) players5Pressed: (id) sender
{
	[self gotoFormVC:5];
}

- (IBAction) players6Pressed: (id) sender
{
	[self gotoFormVC:6];
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	if(bigHandsFlag)
		[self setTitle:@"Hand Tracker"];
	else
		[self setTitle:@"Odds Calculator"];

	[button1 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	[button1 setBackgroundImage:[UIImage imageNamed:@"yellowButton.png"] forState:UIControlStateNormal];

	[button2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	[button2 setBackgroundImage:[UIImage imageNamed:@"yellowButton.png"] forState:UIControlStateNormal];

	[button3 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	[button3 setBackgroundImage:[UIImage imageNamed:@"yellowButton.png"] forState:UIControlStateNormal];

	[button4 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	[button4 setBackgroundImage:[UIImage imageNamed:@"yellowButton.png"] forState:UIControlStateNormal];

    [super viewDidLoad];
}







@end
