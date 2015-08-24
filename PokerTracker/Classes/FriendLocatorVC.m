//
//  FriendLocatorVC.m
//  PokerTracker
//
//  Created by Rick Medved on 10/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FriendLocatorVC.h"
#import "ProjectFunctions.h"
#import "WebServicesFunctions.h"
#import "NSDate+ATTDate.h"
#import "CoreDataLib.h"


@implementation FriendLocatorVC
@synthesize managedObjectContext;
@synthesize email, activityIndicator, activityLabel;
@synthesize activityPopup, addButton;


-(BOOL)textFieldShouldReturn:(UITextField *)aTextField {
	[aTextField resignFirstResponder];
	return YES;
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	[self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
}

-(void)addFriendWebRequest
{
	@autoreleasepool {
		NSArray *nameList = [NSArray arrayWithObjects:@"Username", @"Password", @"friendEmail", nil];
		NSArray *valueList = [NSArray arrayWithObjects:[ProjectFunctions getUserDefaultValue:@"userName"], [ProjectFunctions getUserDefaultValue:@"password"], email.text, nil];
		NSString *webAddr = @"http://www.appdigity.com/poker/pokerAddFriend.php";
		NSString *responseStr = [WebServicesFunctions getResponseFromServerUsingPost:webAddr fieldList:nameList valueList:valueList];
		
		if([[responseStr substringToIndex:7] isEqualToString:@"Success"]) {
			NSArray *components = [responseStr componentsSeparatedByString:@"|"];
			NSString *firstName = @"Error";
			NSString *user_id = @"0";
			if([components count]>2) {
				firstName = [components objectAtIndex:1];
				user_id = [components objectAtIndex:2];
			}
			NSArray *valueList = [NSArray arrayWithObjects:
								  [[NSDate date] convertDateToStringWithFormat:nil], 
								  [[NSDate date] convertDateToStringWithFormat:nil], 
								  firstName, 
								  @"Request Pending", 
								  email.text, 
								  @"", 
								  user_id, 
								  @"", 
								  nil];

			NSPredicate *predicate = [NSPredicate predicateWithFormat:@"email = %@", email.text];
			NSArray *items = [CoreDataLib selectRowsFromEntity:@"FRIEND" predicate:predicate sortColumn:nil mOC:managedObjectContext ascendingFlg:YES];
			if([items count]==0)
				[ProjectFunctions insertRecordIntoEntity:managedObjectContext EntityName:@"FRIEND" valueList:valueList];
			[ProjectFunctions showAlertPopupWithDelegate:@"Success" message:[NSString stringWithFormat:@"Friend %@ added. Awaiting acceptance.", firstName] delegate:self];
		}
		else {
			if(responseStr==nil || [responseStr isEqualToString:@""])
				responseStr = @"No network Connection.";
			[ProjectFunctions showAlertPopup:@"ERROR" message:[NSString stringWithFormat:@"%@", responseStr]];
		}
		activityLabel.alpha=0;
		activityPopup.alpha=0;
		[activityIndicator stopAnimating];
	}
}

-(void)executeThreadedJob:(SEL)aSelector
{
	[activityIndicator startAnimating];
	activityLabel.alpha=1;
	activityPopup.alpha=1;
	[self performSelectorInBackground:aSelector withObject:nil];
}

- (IBAction) addFriendPressed: (id) sender
{
	[email resignFirstResponder];
	BOOL passChecks=YES;
	if([email.text length]<5) {
		[ProjectFunctions showAlertPopup:@"Error" message:@"Enter a valid Emaill Address"];
		passChecks=NO;
	}
	if(passChecks) {
		[self executeThreadedJob:@selector(addFriendWebRequest)];
	}
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	[self setTitle:@"Friend Request"];
	activityLabel.alpha=0;
	activityPopup.alpha=0;

	[addButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	[addButton setBackgroundImage:[UIImage imageNamed:@"yellowButton.png"] forState:UIControlStateNormal];

}



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
