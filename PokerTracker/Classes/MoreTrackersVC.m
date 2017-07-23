//
//  MoreTrackersVC.m
//  PokerTracker
//
//  Created by Rick Medved on 6/1/13.
//
//

#import "MoreTrackersVC.h"
#import "BigHandsVC.h"
#import "PlayerTrackerVC.h"
#import "HudTrackerVC.h"

@interface MoreTrackersVC ()

@end

@implementation MoreTrackersVC
@synthesize managedObjectContext;

- (IBAction) buttonPressed: (UIButton *) button {
	switch (button.tag) {
  case 0: {
	  PlayerTrackerVC *detailViewController = [[PlayerTrackerVC alloc] initWithNibName:@"PlayerTrackerVC" bundle:nil];
	  detailViewController.managedObjectContext = self.managedObjectContext;
	  [self.navigationController pushViewController:detailViewController animated:YES];
  }
			break;
  case 1: {
			BigHandsVC *detailViewController = [[BigHandsVC alloc] initWithNibName:@"BigHandsVC" bundle:nil];
			detailViewController.showMainMenuButton=NO;
			detailViewController.managedObjectContext = self.managedObjectContext;
			[self.navigationController pushViewController:detailViewController animated:YES];
  }
			break;
  case 2: {
			HudTrackerVC *detailViewController = [[HudTrackerVC alloc] initWithNibName:@"HudTrackerVC" bundle:nil];
			detailViewController.managedObjectContext = self.managedObjectContext;
			[self.navigationController pushViewController:detailViewController animated:YES];
  }
			break;
			
  default:
			break;
	}
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTitle:@"More Trackers"];
 
	[ProjectFunctions makeFAButton:self.playerTrackerButton type:3 size:20 text:@"Player Tracker"];
	[ProjectFunctions makeFAButton:self.handTrackerButton type:29 size:20 text:@"Hand Tracker"];
	[ProjectFunctions makeFAButton:self.hudTrackerButton type:5 size:20 text:@"HUD Tracker"];
}



@end
