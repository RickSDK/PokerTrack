//
//  FriendSendMessage.m
//  PokerTracker
//
//  Created by Rick Medved on 11/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FriendSendMessage.h"
#import "ProjectFunctions.h"
#import "WebServicesFunctions.h"


@implementation FriendSendMessage
@synthesize managedObjectContext, mo;
@synthesize message, toPersonLabel, sendMessageButton;
@synthesize activityIndicatorServer, textViewBG, activityLabel;

- (BOOL)textView:(UITextView *)textViewLocal shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)string
{
	return [ProjectFunctions limitTextViewLength:message currentText:message.text string:string limit:500 saveButton:nil resignOnReturn:YES];
}

-(void)mainMenuButtonClicked:(id)sender {
	[self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
}


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	[self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
}

-(void)sendMessageWebRequest
{
	@autoreleasepool {

		int friend_id = [[mo valueForKey:@"user_id"] intValue];
//	NSString *name = [mo valueForKey:@"name"];
		NSArray *nameList = [NSArray arrayWithObjects:@"Username", @"Password", @"friend_id", @"message", nil];
		NSArray *valueList = [NSArray arrayWithObjects:[ProjectFunctions getUserDefaultValue:@"userName"], [ProjectFunctions getUserDefaultValue:@"password"], [NSString stringWithFormat:@"%d", friend_id], message.text, nil];
		NSString *webAddr = @"http://www.appdigity.com/poker/pokerSendMessage.php";
		NSString *responseStr = [WebServicesFunctions getResponseFromServerUsingPost:webAddr fieldList:nameList valueList:valueList];
		if([WebServicesFunctions validateStandardResponse:responseStr delegate:nil]) {
			[ProjectFunctions showAlertPopupWithDelegate:@"Success" message:@"Message sent!" delegate:self];
		}

		textViewBG.alpha=0;
		activityLabel.alpha=0;
		[activityIndicatorServer stopAnimating];
	}
}

-(void)executeThreadedJob:(SEL)aSelector
{
	[self performSelectorInBackground:aSelector withObject:nil];
	
}

- (IBAction) messageButtonPressed: (id) sender 
{
	[message resignFirstResponder];
	if([message.text isEqualToString:@""]) {
		[ProjectFunctions showAlertPopup:@"Error" message:@"Message is blank!"];
	} else {
		[activityIndicatorServer startAnimating];
		textViewBG.alpha=1;
		activityLabel.alpha=1;
		[self executeThreadedJob:@selector(sendMessageWebRequest)];
	}
}



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	[self setTitle:@"Send Message"];
	textViewBG.alpha=0;
	activityLabel.alpha=0;
	toPersonLabel.text = [mo valueForKey:@"name"];

	[sendMessageButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	[sendMessageButton setBackgroundImage:[UIImage imageNamed:@"yellowButton.png"] forState:UIControlStateNormal];

	self.navigationItem.rightBarButtonItem = [ProjectFunctions UIBarButtonItemWithIcon:[NSString fontAwesomeIconStringForEnum:FAHome] target:self action:@selector(mainMenuButtonClicked:)];
//	UIBarButtonItem *homeButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Main Menu", nil) style:UIBarButtonItemStylePlain target:self action:@selector(mainMenuButtonClicked:)];
//	self.navigationItem.rightBarButtonItem = homeButton;
	
}








@end
