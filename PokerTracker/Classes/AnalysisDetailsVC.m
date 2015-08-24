//
//  AnalysisDetailsVC.m
//  PokerTracker
//
//  Created by Rick Medved on 2/9/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "AnalysisDetailsVC.h"
#import "IGAVC.h"


@implementation AnalysisDetailsVC
@synthesize managedObjectContext;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/

- (IBAction) igaButtonPressed: (id) sender
{
 	IGAVC *detailViewController = [[IGAVC alloc] initWithNibName:@"IGAVC" bundle:nil];
	[self.navigationController pushViewController:detailViewController animated:YES];
}

-(void)mainMenuButtonClicked:(id)sender {
	[self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	[self setTitle:@"Player Types"];
	UIBarButtonItem *homeButton = [[UIBarButtonItem alloc] initWithTitle:@"Main Menu" style:UIBarButtonItemStylePlain target:self action:@selector(mainMenuButtonClicked:)];
	self.navigationItem.rightBarButtonItem = homeButton;
}







@end
