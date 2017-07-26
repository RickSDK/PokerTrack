//
//  Scrub2017VC.m
//  PokerTracker
//
//  Created by Rick Medved on 7/25/17.
//
//

#import "Scrub2017VC.h"
#import "CoreDataLib.h"

@interface Scrub2017VC ()

@end

@implementation Scrub2017VC

- (void)viewDidLoad {
    [super viewDidLoad];
	[self setTitle:@"Data Scrub"];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"Type = %@", @"Tournament"];
	NSArray *games = [CoreDataLib selectRowsFromEntity:@"GAME" predicate:predicate sortColumn:nil mOC:self.managedObjectContext ascendingFlg:NO];
	float totalFoodAndTokes=0;
	for(NSManagedObject *game in games) {
		totalFoodAndTokes += [[game valueForKey:@"tokes"] intValue];
		totalFoodAndTokes += [[game valueForKey:@"foodDrinks"] intValue];
	}
	if(totalFoodAndTokes>0) {
		[self populatePopupWithTitle:@"Important Notice!" text:@"If you had any tournament games entered before version 11.4, they should NOT have any values populated for food and tips. But we have found some records with bad data. Press the button below to set the amount of food and tips for your tournament games to $0.\n\nPress the button below to fix the data in your database."];
	} else {
		self.scrubButton.enabled=NO;
		self.cancelButton.enabled=NO;
		[self populatePopupWithTitle:@"Database in Sync" text:@"You do not have any food or tips recorded for your tournaments."];
	}
	
	self.popupView.hidden=NO;
	self.amountLabel.text = [ProjectFunctions convertNumberToMoneyString:totalFoodAndTokes];
}

-(IBAction)scrubButtonClicked:(id)sender {
	[self.webServiceView startWithTitle:@"Working..."];
	self.scrubButton.enabled=NO;
	self.cancelButton.enabled=NO;
	[ProjectFunctions setUserDefaultValue:@"Y" forKey:@"tourneyScrub2017"];
	[self scrubdata];
	[self performSelectorInBackground:@selector(fakeJob) withObject:nil];
}

-(IBAction)cancelButtonClicked:(id)sender {
	self.cancelButton.enabled=NO;
	[ProjectFunctions showConfirmationPopup:@"Cancel Scrub" message:@"Note if you haven't manually added food and tips to your tournaments, your numbers will be off." delegate:self tag:99];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if(buttonIndex==alertView.cancelButtonIndex)
		return;
	if(alertView.tag==99) {
		[ProjectFunctions setUserDefaultValue:@"Y" forKey:@"tourneyScrub2017"];
		[ProjectFunctions showAlertPopup:@"Scrub Notice Cancelled" message:@""];
	}
}

-(void)fakeJob {
	[NSThread sleepForTimeInterval:3];
	[self.webServiceView stop];
	[ProjectFunctions showAlertPopup:@"Success!" message:@""];
}

-(void)scrubdata {
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"Type = %@", @"Tournament"];
	NSArray *games = [CoreDataLib selectRowsFromEntity:@"GAME" predicate:predicate sortColumn:nil mOC:self.managedObjectContext ascendingFlg:NO];
	for(NSManagedObject *game in games) {
		float totalFoodAndTokes = [[game valueForKey:@"tokes"] intValue] + [[game valueForKey:@"foodDrinks"] intValue];
		if(totalFoodAndTokes>0) {
			[game setValue:[NSNumber numberWithInt:0] forKey:@"tokes"];
			[game setValue:[NSNumber numberWithInt:0] forKey:@"foodDrinks"];
		}
	}
	[self saveDatabase];
	self.amountLabel.text = [ProjectFunctions convertNumberToMoneyString:0];
	
}



@end
