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
@synthesize button1, button2, button3, button4, button5;

-(void)gotoFormVC:(int)number
{
	if(bigHandsFlag) {
		BigHandsFormVC *detailViewController = [[BigHandsFormVC alloc] initWithNibName:@"BigHandsFormVC" bundle:nil];
		detailViewController.managedObjectContext = managedObjectContext;
		detailViewController.viewEditable = NO;
		detailViewController.drilldown=NO;
		detailViewController.mo = nil;
		detailViewController.numPlayers=number;
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

- (IBAction) actionButtonPressed: (UIButton *) button
{
	[self gotoFormVC:(int)button.tag];
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	if(bigHandsFlag) {
		[self setTitle:@"Hand Tracker"];
		[self changeNavToIncludeType:37];
	}
	else {
		[self setTitle:@"Odds Calculator"];
		[self changeNavToIncludeType:28];
	}

	[self showButtonTitle:self.button1];
	[self showButtonTitle:self.button2];
	[self showButtonTitle:self.button3];
	[self showButtonTitle:self.button4];
	[self showButtonTitle:self.button5];
	[ProjectFunctions newButtonLook:self.button1 mode:0];
	[ProjectFunctions newButtonLook:self.button2 mode:0];
	[ProjectFunctions newButtonLook:self.button3 mode:0];
	[ProjectFunctions newButtonLook:self.button4 mode:0];
	[ProjectFunctions newButtonLook:self.button5 mode:0];
    [super viewDidLoad];
}

-(void)showButtonTitle:(UIButton *)button {
	button.titleLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:24];
	[button setTitle:[NSString stringWithFormat:@"%d %@", (int)button.tag, [NSString fontAwesomeIconStringForEnum:FAUser]] forState:UIControlStateNormal];
}







@end
