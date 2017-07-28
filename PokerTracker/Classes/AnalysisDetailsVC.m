//
//  AnalysisDetailsVC.m
//  PokerTracker
//
//  Created by Rick Medved on 2/9/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "AnalysisDetailsVC.h"
#import "IGAVC.h"
#import "ChangeIconVC.h"


@implementation AnalysisDetailsVC
@synthesize managedObjectContext;


- (IBAction) igaButtonPressed: (id) sender
{
 	IGAVC *detailViewController = [[IGAVC alloc] initWithNibName:@"IGAVC" bundle:nil];
	[self.navigationController pushViewController:detailViewController animated:YES];
}

- (IBAction) changeIconButtonPressed: (id) sender {
	[self gotoChangeIcon];
}

-(void)editButtonClicked {
	[self gotoChangeIcon];
}

-(void)gotoChangeIcon {
	ChangeIconVC *detailViewController = [[ChangeIconVC alloc] initWithNibName:@"ChangeIconVC" bundle:nil];
	[self.navigationController pushViewController:detailViewController animated:YES];
}

-(void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	self.image0.image = [ProjectFunctions playerImageOfType:0];
	self.image1.image = [ProjectFunctions playerImageOfType:1];
	self.image2.image = [ProjectFunctions playerImageOfType:2];
	self.image3.image = [ProjectFunctions playerImageOfType:3];
	self.image4.image = [ProjectFunctions playerImageOfType:4];
	self.image5.image = [ProjectFunctions playerImageOfType:5];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	[self setTitle:@"Player Types"];
	[self changeNavToIncludeType:3];
	self.navigationItem.rightBarButtonItem = [ProjectFunctions UIBarButtonItemWithIcon:[NSString fontAwesomeIconStringForEnum:FAPencil] target:self action:@selector(editButtonClicked)];
	
}







@end
