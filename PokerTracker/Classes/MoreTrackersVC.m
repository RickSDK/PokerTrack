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

@interface MoreTrackersVC ()

@end

@implementation MoreTrackersVC
@synthesize managedObjectContext;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (IBAction) handsPressed: (id) sender
{
	BigHandsVC *detailViewController = [[BigHandsVC alloc] initWithNibName:@"BigHandsVC" bundle:nil];
	detailViewController.showMainMenuButton=NO;
	detailViewController.managedObjectContext = self.managedObjectContext;
	[self.navigationController pushViewController:detailViewController animated:YES];
}
- (IBAction) playersPressed: (id) sender {
 	PlayerTrackerVC *detailViewController = [[PlayerTrackerVC alloc] initWithNibName:@"PlayerTrackerVC" bundle:nil];
	detailViewController.managedObjectContext = self.managedObjectContext;
	[self.navigationController pushViewController:detailViewController animated:YES];
   
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTitle:@"More Trackers"];
 
	self.playerTrackerButton.titleLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:20.f];
	[self.playerTrackerButton setTitle:[NSString stringWithFormat:@"%@ Player Tracker", [NSString fontAwesomeIconStringForEnum:FAUser]] forState:UIControlStateNormal];
	
	self.handTrackerButton.titleLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:20.f];
	[self.handTrackerButton setTitle:[NSString stringWithFormat:@"%@ Hand Tracker", [NSString fontAwesomeIconStringForEnum:FAhandPaperO]] forState:UIControlStateNormal];

    // Do any additional setup after loading the view from its nib.
}



@end
