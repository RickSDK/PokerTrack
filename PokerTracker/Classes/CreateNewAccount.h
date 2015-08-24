//
//  CreateNewAccount.h
//  PokerTracker
//
//  Created by Rick Medved on 10/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebServiceView.h"

@interface CreateNewAccount : UIViewController {
 	//---Passed In----------------------------
	NSManagedObjectContext *managedObjectContext;
	//---XIB----------------------------
	
	IBOutlet UITextField *fieldNewEmail;
	IBOutlet UITextField *firstname;
	IBOutlet UITextField *fieldNewPassword;
	IBOutlet UITextField *rePassword;
	IBOutlet UIButton *createButton;
	
//	IBOutlet UIActivityIndicatorView *activityIndicator;
//	IBOutlet UILabel *activityLabel;
//	IBOutlet UIImageView *activityBG;
//	IBOutlet UIImageView *activityPopup;
    UIBarButtonItem *homeButton;
	
	//---Gloabls----------------------------
}

- (IBAction) privacyButtonPressed: (id) sender;
- (IBAction) termsSwitchPressed: (id) sender;

@property (nonatomic, strong) IBOutlet WebServiceView *webServiceView;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) IBOutlet UIButton *termsButton;
@property (nonatomic, strong) IBOutlet UISwitch *termsSwitch;


@property (nonatomic, strong) UITextField *fieldNewEmail;
@property (nonatomic, strong) UITextField *firstname;
@property (nonatomic, strong) UITextField *fieldNewPassword;
@property (nonatomic, strong) UITextField *rePassword;
@property (nonatomic, strong) UIButton *createButton;

//@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
//@property (nonatomic, strong) UIImageView *activityBG;
//@property (nonatomic, strong) UIImageView *activityPopup;
//@property (nonatomic, strong) UILabel *activityLabel;
@property (nonatomic, strong) UIBarButtonItem *homeButton;

@end
