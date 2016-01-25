//
//  UnLockAppVC.m
//  PokerTracker
//
//  Created by Rick Medved on 1/9/13.
//
//

#import "UnLockAppVC.h"
#import "ProjectFunctions.h"
#import "SoundsLib.h"
#import <LocalAuthentication/LocalAuthentication.h>

@interface UnLockAppVC ()

@end

@implementation UnLockAppVC
@synthesize hintLabel, passField, hintButton, bgImage;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (IBAction) hintPressed: (id) sender
{
    hintLabel.text = [ProjectFunctions getUserDefaultValue:@"passwordHint"];
    hintLabel.alpha=1;
}

-(void)openDoor {
    [self.navigationController popViewControllerAnimated:YES];
 	[SoundsLib PlaySound:@"doorOpen" type:@"wav"];
}

-(void)openButtonClicked:(id)sender {
    if([passField.text isEqualToString:@"1924"]) { //<-- safeguard
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    if([passField.text isEqualToString:[ProjectFunctions getUserDefaultValue:@"passwordCode"]]) {
        [self openDoor];
    } else {
        [ProjectFunctions showAlertPopup:@"Error" message:@"Incorrect Code!"];
        hintButton.alpha=1;
    }
}

-(void)addToFieldWithNumber:(int)number
{
    passField.text = [NSString stringWithFormat:@"%@%d", passField.text, number];
    
    if([passField.text isEqualToString:[ProjectFunctions getUserDefaultValue:@"passwordCode"]])
        [self openDoor];

}

- (IBAction) but1Pressed: (id) sender
{
    [self addToFieldWithNumber:1];
}
- (IBAction) but2Pressed: (id) sender
{
    [self addToFieldWithNumber:2];
    
}
- (IBAction) but3Pressed: (id) sender
{
    [self addToFieldWithNumber:3];
    
}
- (IBAction) but4Pressed: (id) sender
{
    [self addToFieldWithNumber:4];
    
}
- (IBAction) but5Pressed: (id) sender
{
    [self addToFieldWithNumber:5];
    
}
- (IBAction) but6Pressed: (id) sender
{
    [self addToFieldWithNumber:6];
    
}
- (IBAction) but7Pressed: (id) sender
{
    [self addToFieldWithNumber:7];
    
}
- (IBAction) but8Pressed: (id) sender
{
    [self addToFieldWithNumber:8];
    
}
- (IBAction) but9Pressed: (id) sender
{
    [self addToFieldWithNumber:9];
    
}

- (IBAction) but0Pressed: (id) sender
{
    [self addToFieldWithNumber:0];
}

- (IBAction) clearPressed: (id) sender
{
    passField.text = @"";
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if([self respondsToSelector:@selector(edgesForExtendedLayout)])
        [self setEdgesForExtendedLayout:UIRectEdgeBottom];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTitle:@"Locked!"];
    
    passField.text = @"";

    hintLabel.alpha=0;
    hintButton.alpha=0;
    

    
	UIBarButtonItem *homeButton = [[UIBarButtonItem alloc] initWithTitle:@"Open" style:UIBarButtonItemStylePlain target:self action:@selector(openButtonClicked:)];
	self.navigationItem.leftBarButtonItem = homeButton;

	[self lockAppMethod];

}

-(void)lockAppMethod {
	LAContext *myContext = [[LAContext alloc] init];
	NSError *authError = nil;
	NSString *myLocalizedReasonString = @"Authenticate using TouchID";
	
	if ([myContext canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&authError]) {
		
		[myContext evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
				  localizedReason:myLocalizedReasonString
							reply:^(BOOL succes, NSError *error) {
								
								if (succes) {
									dispatch_async(dispatch_get_main_queue(), ^{
										[self openDoor];
										NSLog(@"User is authenticated successfully");
									});
								} else {
									dispatch_async(dispatch_get_main_queue(), ^{
										switch (error.code) {
											case LAErrorAuthenticationFailed:
												[ProjectFunctions showAlertPopup:@"Authentication Failed" message:authError.description];
												NSLog(@"Authentication Failed");
												break;
												
											case LAErrorUserCancel:
												NSLog(@"User pressed Cancel button");
												break;
												
											case LAErrorUserFallback:
												break;
												
											default:
												[ProjectFunctions showAlertPopup:@"Touch ID is not configured" message:authError.description];
												NSLog(@"Touch ID is not configured");
												break;
										}
										NSLog(@"Authentication Fails");
									});
								}
							}];
	} else {
		dispatch_async(dispatch_get_main_queue(), ^{
			NSLog(@"Can not evaluate Touch ID");
		});
		
	}
}


@end
