//
//  cleanupRefData.m
//  PokerTracker
//
//  Created by Rick Medved on 5/22/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "cleanupRefData.h"
#import "ProjectFunctions.h"
#import "CoreDataLib.h"


@implementation cleanupRefData
@synthesize managedObjectContext;



-(BOOL)refDataNonStandard:(NSString *)table value:(NSString *)value
{
	NSArray *items=[NSArray arrayWithObjects:@"Casino", @"No-Limit", @"Pot-Limit", @"Limit", @"Spread", 
					@"$1/$2", @"$1/$3", @"$3/$5", @"$3/$6", @"$5/$10", @"$10/$20", @"Hold'em", @"Omaha", @"Razz", @"7-Card", @"5-Card", @"Default", nil];
	for(NSString *item in items)
		if([value isEqualToString:item])
			return NO;
	
	return YES;
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if(buttonIndex==1) {
		NSArray *tables = [NSArray arrayWithObjects:@"LOCATION", @"LIMIT", @"STAKES", @"BANKROLL", @"GAMETYPE", nil];
		
		for(NSString *table in tables) {
			NSArray *items = [CoreDataLib selectRowsFromTable:table mOC:self.managedObjectContext];
			for(NSManagedObject *mo in items) {
				NSString *name = [mo valueForKey:@"name"];
				if([self refDataNonStandard:table value:name]) {
					NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"user_id = 0 AND %@ = %%@", [table lowercaseString]], name];
					NSArray *games = [CoreDataLib selectRowsFromEntity:@"GAME" predicate:predicate sortColumn:nil mOC:self.managedObjectContext ascendingFlg:YES];
					if([games count]==0) {
						[self.managedObjectContext deleteObject:mo];
						NSLog(@"%@ %@ deleted", table, name);
					}
				}
			}
			[self.managedObjectContext save:nil];
		}
		[ProjectFunctions showAlertPopup:@"Notice" message:@"Cleanup done."];
		
	}
}

- (IBAction) cleanupPressed: (id) sender
{ 
	[ProjectFunctions showConfirmationPopup:@"Cleanup Ref Data?" message:@"Delete any ref data not being used?" delegate:self tag:1];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	[self setTitle:@"Cleanup Data"];
}




@end
