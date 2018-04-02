//
//  CreateNewAccount.m
//  PokerTracker
//
//  Created by Rick Medved on 10/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CreateNewAccount.h"
#import "WebServicesFunctions.h"
#import "ProjectFunctions.h"
#import "MainMenuVC.h"
#import "EULAVC.h"


@implementation CreateNewAccount
@synthesize managedObjectContext;
@synthesize fieldNewEmail, fieldNewPassword, rePassword, firstname, createButton;
@synthesize homeButton;





-(void)createAccount
{
	@autoreleasepool {

		NSString *email = [NSString stringWithFormat:@"%@", fieldNewEmail.text];
		NSArray *nameList = [NSArray arrayWithObjects:@"Username", @"Firstname", @"Password", @"appName", nil];
		NSArray *valueList = [NSArray arrayWithObjects:fieldNewEmail.text, firstname.text, fieldNewPassword.text, [ProjectFunctions getProjectDisplayVersion], nil];
		NSString *responseStr = [WebServicesFunctions getResponseFromServerUsingPost:@"http://www.appdigity.com/poker/createPokerAccount.php" fieldList:nameList valueList:valueList];
		if([WebServicesFunctions validateStandardResponse:responseStr delegate:nil]) {
			[ProjectFunctions showAlertPopupWithDelegate:@"Success!" message:@"Account Created" delegate:self];
			[ProjectFunctions setUserDefaultValue:email forKey:@"emailAddress"];
			[ProjectFunctions setUserDefaultValue:email forKey:@"userName"];
			[ProjectFunctions setUserDefaultValue:firstname.text forKey:@"firstName"];
			
			[ProjectFunctions setUserDefaultValue:fieldNewPassword.text forKey:@"password"];
		}
		
		[self.webServiceView stop];
		homeButton.enabled=YES;
		
	}
}

-(void)createPressed:(id)sender {
    homeButton.enabled=NO;
    
	[fieldNewEmail resignFirstResponder];
	[fieldNewPassword resignFirstResponder];
	[rePassword resignFirstResponder];
	[firstname resignFirstResponder];

	BOOL passChecks=YES;
	if(passChecks && self.termsSwitch.on==NO) {
		[ProjectFunctions showAlertPopup:@"Error" message:@"Please view and accept the privacy policy."];
		passChecks=NO;
	}
	if(passChecks && [fieldNewEmail.text length]<5) {
		[ProjectFunctions showAlertPopup:@"Error" message:@"Enter a valid Email Address"];
		passChecks=NO;
	}
	if(passChecks && [firstname.text length]==0) {
		[ProjectFunctions showAlertPopup:@"Error" message:@"Enter a first name"];
		passChecks=NO;
	}
	if(passChecks && [fieldNewPassword.text length]<2) {
		[ProjectFunctions showAlertPopup:@"Error" message:@"Enter a valid password"];
		passChecks=NO;
	}
	if(passChecks && [rePassword.text length]<2) {
		[ProjectFunctions showAlertPopup:@"Error" message:@"Re-enter your password"];
		passChecks=NO;
	}
	if(passChecks && ![fieldNewPassword.text isEqualToString:rePassword.text]) {
		[ProjectFunctions showAlertPopup:@"Error" message:@"Passwords do not match!"];
		passChecks=NO;
	}
	
	if(passChecks) {
		[self.webServiceView startWithTitle:@"Working"];
		[self performSelectorInBackground:@selector(createAccount) withObject:nil];
	} else
        homeButton.enabled=YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)aTextField {
	[aTextField resignFirstResponder];
	return YES;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if([self respondsToSelector:@selector(edgesForExtendedLayout)])
        [self setEdgesForExtendedLayout:UIRectEdgeBottom];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
	[self setTitle:@"Create Account"];

	
	homeButton = [ProjectFunctions navigationButtonWithTitle:@"Create" selector:@selector(createPressed:) target:self];

	self.navigationItem.rightBarButtonItem = homeButton;
	
	self.termsSwitch.on=NO;
	self.termsSwitch.enabled=NO;
	[self setupFields];
    
}




-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	[self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
}

- (IBAction) termsSwitchPressed: (id) sender {
	[self setupFields];
}

-(void)setupFields {
	if (self.termsSwitch.on) {
		self.fieldNewEmail.enabled=YES;
		self.firstname.enabled=YES;
		self.fieldNewPassword.enabled=YES;
		self.rePassword.enabled=YES;
	} 
}

- (IBAction) privacyButtonPressed: (id) sender {
	self.termsSwitch.enabled=YES;
	EULAVC *detailViewController = [[EULAVC alloc] initWithNibName:@"EULAVC" bundle:nil];
	[self.navigationController pushViewController:detailViewController animated:YES];
}





@end
