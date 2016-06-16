//
//  ReviewsVC.m
//  PokerTracker
//
//  Created by Rick Medved on 6/15/16.
//
//

#import "ReviewsVC.h"

@interface ReviewsVC ()

@end

@implementation ReviewsVC

- (void)viewDidLoad {
    [super viewDidLoad];
	[self setTitle:@"Reviews"];
	
	float version = [ProjectFunctions projectVersionNumber];
	self.yourVersionLabel.text = [NSString stringWithFormat:@"%g", version];
	
	self.stepper.value = self.numReviews;
	self.numReviewsLabel.text = [NSString stringWithFormat:@"%d", (int)self.stepper.value];
	self.currentVersionLabel.text = [NSString stringWithFormat:@"%g", self.currentVersion];
	
	self.updateNeededLabel.hidden = (self.currentVersion==version);
	
	self.updateButton = [ProjectFunctions navigationButtonWithTitle:@"Update" selector:@selector(updateButtonClicked) target:self];
	self.navigationItem.rightBarButtonItem = self.updateButton;
	self.updateButton.enabled=NO;

}

-(void)updateButtonClicked {
	[self performSelectorInBackground:@selector(updateCount) withObject:nil];
}

-(void)updateCount {
	@autoreleasepool {
		NSString *webSite = [NSString stringWithFormat:@"http://www.appdigity.com/poker/pokerUpdateReviewCount.php?count=%d", (int)self.stepper.value];
		NSString *result = [WebServicesFunctions getResponseFromWeb:webSite];
		NSLog(@"+++result %@", result);
		[self.navigationController popViewControllerAnimated:YES];
	}
}

-(IBAction)reviewButtonClicked:(id)sender {
	[ProjectFunctions writeAppReview];
}

-(IBAction)stepperButtonClicked:(id)sender {
	self.numReviewsLabel.text = [NSString stringWithFormat:@"%d", (int)self.stepper.value];
	self.updateButton.enabled=YES;
}


@end
