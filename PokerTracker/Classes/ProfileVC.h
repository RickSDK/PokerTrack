//
//  ProfileVC.h
//  PokerTracker
//
//  Created by Rick Medved on 6/6/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TemplateVC.h"


@interface ProfileVC : TemplateVC {
	NSManagedObjectContext *managedObjectContext;
	IBOutlet UIActivityIndicatorView *activityIndicator;
	IBOutlet UIImageView *activityPopup;
	IBOutlet UILabel *activityLabel;
	IBOutlet UITableView *mainTableView;
	IBOutlet UIBarButtonItem *saveEditButton;
	
	IBOutlet UITextField *nameField;
	IBOutlet UITextField *emailField;
	IBOutlet UITextField *cityField;
	IBOutlet UITextField *passwordField;
	
	IBOutlet UISwitch *statsSwitch;
	
	BOOL viewEditable;
	BOOL changesMade;
	int selectedRow;
	
}

- (IBAction) switchPressed: (id) sender;
-(void)disableFields;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) UIImageView *activityPopup;
@property (nonatomic, strong) UILabel *activityLabel;
@property (nonatomic, strong) UITableView *mainTableView;
@property (nonatomic, strong) UIBarButtonItem *saveEditButton;

@property (nonatomic, strong) UITextField *nameField;
@property (nonatomic, strong) UITextField *emailField;
@property (nonatomic, strong) UITextField *cityField;
@property (nonatomic, strong) UITextField *passwordField;
@property (nonatomic, strong) UISwitch *statsSwitch;

@property (nonatomic) BOOL viewEditable;
@property (nonatomic) BOOL changesMade;
@property (nonatomic) int selectedRow;





@end
