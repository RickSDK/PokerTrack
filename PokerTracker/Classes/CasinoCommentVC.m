//
//  CasinoCommentVC.m
//  PokerTracker
//
//  Created by Rick Medved on 1/23/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "CasinoCommentVC.h"
#import "ProjectFunctions.h"
#import "WebServicesFunctions.h"


@implementation CasinoCommentVC
@synthesize nameLabel, textView, casino, casino_id;
@synthesize activityBGView, activityIndicator, activityLabel, submitButton, managedObjectContext;

- (BOOL)textView:(UITextView *)textViewLocal shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)string
{
	int textlength=100;
	if(!submitButton.enabled)
		submitButton.enabled=YES;
	
	return [ProjectFunctions limitTextViewLength:textViewLocal currentText:textView.text string:string limit:textlength saveButton:nil resignOnReturn:NO];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	[self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
}

-(void) submitComment {
	@autoreleasepool {
	
		NSString *casino_idStr = [NSString stringWithFormat:@"%d", casino_id];
		NSString *data = textView.text;
		NSArray *nameList = [NSArray arrayWithObjects:@"Username", @"Password", @"casino_id", @"data", nil];
		NSArray *valueList = [NSArray arrayWithObjects:[ProjectFunctions getUserDefaultValue:@"userName"], [ProjectFunctions getUserDefaultValue:@"password"], casino_idStr, data, nil];

		if([valueList count]==0) {
			[ProjectFunctions showAlertPopup:@"Notice" message:@"You must be logged in to use this feature. From the main menu click 'More' at the top, then 'Login'"];
			return;
		}
		NSString *webAddr = @"http://www.appdigity.com/poker/pokerCasinoSubmitComment.php";
		NSString *responseStr = [WebServicesFunctions getResponseFromServerUsingPost:webAddr fieldList:nameList valueList:valueList];
		
		if([WebServicesFunctions validateStandardResponse:responseStr delegate:nil]) {
			[ProjectFunctions showAlertPopupWithDelegate:@"Success" message:@"Comment updated!" delegate:self];
		}
		
		activityBGView.alpha=0;
		activityLabel.alpha=0;
		[activityIndicator stopAnimating];
	}
}


-(void)executeThreadedJob:(SEL)aSelector
{
	activityBGView.alpha=1;
	activityLabel.alpha=1;
	[activityIndicator startAnimating];
	[self performSelectorInBackground:aSelector withObject:nil];
}

- (IBAction) submitButtonClicked: (id) sender
{
	[self executeThreadedJob:@selector(submitComment)];
}

-(void)viewDidLoad {
    [super viewDidLoad];
	[self setTitle:@"Leave Comment"];

	activityBGView.alpha=0;
	activityLabel.alpha=0;

	submitButton = [[UIBarButtonItem alloc] initWithTitle:@"Submit" style:UIBarButtonItemStylePlain target:self action:@selector(submitButtonClicked:)];
	self.navigationItem.rightBarButtonItem = submitButton;
	submitButton.enabled=NO;
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
