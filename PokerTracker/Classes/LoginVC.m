//
//  LoginVC.m
//  PokerTracker
//
//  Created by Rick Medved on 10/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LoginVC.h"
#import "ProjectFunctions.h"
#import "WebServicesFunctions.h"
#import "CreateNewAccount.h"
#import "NSArray+ATTArray.h"
#import "MainMenuVC.h"
#import "UpgradeVC.h"


@implementation LoginVC
@synthesize managedObjectContext, loginEmail, loginPassword, loginButton, forgotButton;
@synthesize rickButton, robbButton, testButton;



- (void)viewDidLoad {
	[super viewDidLoad];
	[self setTitle:@"Login"];
	
	self.navigationItem.rightBarButtonItem = [ProjectFunctions UIBarButtonItemWithIcon:[NSString fontAwesomeIconStringForEnum:FAPlus] target:self action:@selector(createNewAccountPressed:)];
	
	if([ProjectFunctions getProductionMode]) {
		rickButton.alpha=0;
		robbButton.alpha=0;
		testButton.alpha=0;
	}
}

- (IBAction) createNewPressed: (id) sender {
	[self createNewAccountPressed:sender];
}

- (IBAction) rickPressed: (id) sender {
	loginEmail.text = @"rickmedved@hotmail.com";
	loginPassword.text = @"rick23";
}

- (IBAction) testPressed: (id) sender {
    //-- test
	loginEmail.text = @"testaol.com";
	loginPassword.text = @"test123";

	//-- pokerJounral
//  loginEmail.text = @"austinworrell@comcast.net";
//	loginPassword.text = @"austin8520";

	//-- pokerIncome
//    loginEmail.text = @"al@azouri.net";
//	loginPassword.text = @"5225mkat";
}

- (IBAction) robbPressed: (id) sender {
	loginEmail.text = @"robbmedvedyahoo.com";
	loginPassword.text = @"7004175St$w";
}

-(void)createNewAccountPressed:(id)sender {
	if([ProjectFunctions isLiteVersion]) {
		[ProjectFunctions showConfirmationPopup:@"Upgrade Now?" message:@"You will need to upgrade to use this feature." delegate:self tag:104];
		return;
	}
	CreateNewAccount *detailViewController = [[CreateNewAccount alloc] initWithNibName:@"CreateNewAccount" bundle:nil];
	detailViewController.managedObjectContext = managedObjectContext;
	[self.navigationController pushViewController:detailViewController animated:YES];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if(alertView.tag==104 && buttonIndex != alertView.cancelButtonIndex) {
		UpgradeVC *detailViewController = [[UpgradeVC alloc] initWithNibName:@"UpgradeVC" bundle:nil];
		detailViewController.managedObjectContext = managedObjectContext;
		[self.navigationController pushViewController:detailViewController animated:YES];
	} else
		[self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
}

-(void)showLoginPopupWithTitle:(NSString *)title andMessage:(NSString *)message andDefaultUser:(NSString *)defaultUser delegate:(id)delegate
{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
													message:message
												   delegate:delegate
										  cancelButtonTitle:nil
										  otherButtonTitles: @"OK", nil];
	[alert setAlertViewStyle:UIAlertViewStyleLoginAndPasswordInput];
    [alert textFieldAtIndex:0].text = defaultUser;
    [alert show];
	//-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
}


-(void)loginToSystem
{
	@autoreleasepool {
    
		NSArray *nameList = [NSArray arrayWithObjects:@"Username", @"Password", nil];
		NSArray *valueList = [NSArray arrayWithObjects:loginEmail.text, loginPassword.text, nil];
		NSString *webAddr = @"http://www.appdigity.com/poker/pokerLogin.php";
		int gamesOnServer = [[ProjectFunctions getUserDefaultValue:@"gamesOnServer"] intValue];
		int gamesOnDevice = [[ProjectFunctions getUserDefaultValue:@"gamesOnDevice"] intValue];;
		NSString *responseStr = @"";
		responseStr = [WebServicesFunctions getResponseFromServerUsingPost:webAddr fieldList:nameList valueList:valueList];
		
		NSLog(@"loginToSystem responseStr: %@", responseStr);
		if([WebServicesFunctions validateStandardResponse:responseStr delegate:nil]) {
			NSArray *items = [responseStr componentsSeparatedByString:@"|"];
			NSString *firstName = @"";
			if([items count]>6) {
				firstName = [items objectAtIndex:1];
				[ProjectFunctions setUserDefaultValue:loginEmail.text forKey:@"emailAddress"];
				[ProjectFunctions setUserDefaultValue:loginEmail.text forKey:@"userName"];
				[ProjectFunctions setUserDefaultValue:firstName forKey:@"firstName"];
				[ProjectFunctions setUserDefaultValue:loginPassword.text forKey:@"password"];
				[ProjectFunctions setUserDefaultValue:[items stringAtIndex:2] forKey:@"userCity"];
				[ProjectFunctions setUserDefaultValue:[items stringAtIndex:3] forKey:@"UserState"];
				[ProjectFunctions setUserDefaultValue:[items stringAtIndex:4] forKey:@"UserCountry"];
				[ProjectFunctions setUserDefaultValue:[items stringAtIndex:5] forKey:@"userStatsFlg"];
				gamesOnServer = [[items stringAtIndex:6] intValue];
				[ProjectFunctions setUserDefaultValue:[NSString stringWithFormat:@"%d", gamesOnServer] forKey:@"gamesOnServer"];
			}
			
			if(gamesOnServer > gamesOnDevice)
				[ProjectFunctions showAlertPopupWithDelegateBG:@"Success!" message:@"Note: You have games stored on the server. You can import these games from the 'More' menu." delegate:self];
			else
				[ProjectFunctions showAlertPopupWithDelegateBG:@"Success!" message:@"User Logged in" delegate:self];
			
		}
		
		[self.webServiceView stop];
		
   
	}
}



-(void)forgotPassword
{
	@autoreleasepool {
		NSArray *nameList = [NSArray arrayWithObjects:@"Username", @"Password", nil];
		NSArray *valueList = [NSArray arrayWithObjects:loginEmail.text, loginPassword.text, nil];
		NSString *webAddr = @"http://www.appdigity.com/poker/pokerForgotPassword.php";
		NSString *responseStr = @"";
		responseStr = [WebServicesFunctions getResponseFromServerUsingPost:webAddr fieldList:nameList valueList:valueList];
//	NSLog(@"responseStr: %@", responseStr);
		if([WebServicesFunctions validateStandardResponse:responseStr delegate:nil]) {
			[ProjectFunctions showAlertPopupWithDelegate:@"Success!" message:@"Your password has been emailed." delegate:self];
		}
		[self.webServiceView stop];
	
	}
}

-(void)executeThreadedJob:(SEL)aSelector
{
	[self.webServiceView startWithTitle:@"Working..."];
	[self performSelectorInBackground:aSelector withObject:nil];
}


- (IBAction) loginPressed: (id) sender
{
	if([ProjectFunctions isLiteVersion]) {
		[ProjectFunctions showConfirmationPopup:@"Upgrade Now?" message:@"You will need to upgrade to use this feature." delegate:self tag:99];
		return;
	}
	[loginEmail resignFirstResponder];
	[loginPassword resignFirstResponder];
	BOOL passChecks=YES;
	if([loginEmail.text length]<5) {
		[ProjectFunctions showAlertPopup:@"Error" message:@"Enter a valid Emaill Address"];
		passChecks=NO;
	}
	if(passChecks && [loginPassword.text length]<2) {
		[ProjectFunctions showAlertPopup:@"Error" message:@"Enter a valid password"];
		passChecks=NO;
	}
	if(passChecks) {
		[self executeThreadedJob:@selector(loginToSystem)];
	}
}


- (IBAction) forgotPressed: (id) sender
{
	if([loginEmail.text length]<5) {
		[ProjectFunctions showAlertPopup:@"Error" message:@"Enter a valid Emaill Address"];
		return;
	}
	[self executeThreadedJob:@selector(forgotPassword)];
}

-(BOOL)textFieldShouldReturn:(UITextField *)aTextField {
	[aTextField resignFirstResponder];
	return YES;
}

@end
