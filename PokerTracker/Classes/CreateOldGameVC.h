//
//  CreateOldGameVC.h
//  PokerTracker
//
//  Created by Rick Medved on 10/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CreateOldGameVC : UIViewController {
	//---Passed In----------------------------
    NSManagedObjectContext *managedObjectContext;
	NSManagedObject *mo;

	//---XIB----------------------------
	IBOutlet UISegmentedControl *gameTypeSegmentBar;
	IBOutlet UISegmentedControl *gameNameSegmentBar;
	IBOutlet UISegmentedControl *blindTypeSegmentBar;
	IBOutlet UISegmentedControl *limitTypeSegmentBar;
	IBOutlet UISegmentedControl *TourneyTypeSegmentBar;
    IBOutlet UIDatePicker *datePicker;
	IBOutlet UITextField *hoursPlayed;
	IBOutlet UITextField *buyinAmount;
	IBOutlet UITextField *cashOutAmount;
	IBOutlet UIButton *keyboardButton;
	IBOutlet UIActivityIndicatorView *activityIndicatorServer;
	IBOutlet UIImageView *textViewBG;
	IBOutlet UILabel *activityLabel;
	IBOutlet UILabel *hoursLabel;
	IBOutlet UILabel *buyinLabel;
	IBOutlet UILabel *cashoutLabel;
	IBOutlet UILabel *buyinMoneyLabel;
	IBOutlet UILabel *cashoutMoneyLabel;

	//---Gloabls----------------------------
	int selectedObjectForEdit;
	
}

- (IBAction) keyboardPressed: (id) sender;
- (IBAction) gameTypeSegmentPressed: (id) sender;
-(void)setSegmentForType;
- (IBAction) gameSegmentPressed: (id) sender;
- (IBAction) stakesSegmentPressed: (id) sender; 
- (IBAction) limitSegmentPressed: (id) sender;


@property (nonatomic, strong) UISegmentedControl *gameTypeSegmentBar;
@property (nonatomic, strong) UISegmentedControl *gameNameSegmentBar;
@property (nonatomic, strong) UISegmentedControl *blindTypeSegmentBar;
@property (nonatomic, strong) UISegmentedControl *limitTypeSegmentBar;
@property (nonatomic, strong) UISegmentedControl *TourneyTypeSegmentBar;
@property (nonatomic, strong) UIDatePicker *datePicker;
@property (nonatomic, strong) UITextField *hoursPlayed;
@property (nonatomic, strong) UITextField *buyinAmount;
@property (nonatomic, strong) UITextField *cashOutAmount;
@property (nonatomic, strong) UIButton *keyboardButton;
@property (nonatomic, strong) UILabel *hoursLabel;
@property (nonatomic, strong) UILabel *buyinLabel;
@property (nonatomic, strong) UILabel *cashoutLabel;
@property (nonatomic, strong) UILabel *buyinMoneyLabel;
@property (nonatomic, strong) UILabel *cashoutMoneyLabel;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSManagedObject *mo;

@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorServer;
@property (nonatomic, strong) UIImageView *textViewBG;
@property (nonatomic, strong) UILabel *activityLabel;

@property (nonatomic) int selectedObjectForEdit;

@end
