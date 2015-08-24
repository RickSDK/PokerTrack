//
//  MoneyPickerVC.h
//  PokerTracker
//
//  Created by Rick Medved on 10/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface MoneyPickerVC : UIViewController {
	//---Passed In----------------------------
	NSManagedObjectContext *managedObjectContext;
	UIViewController *callBackViewController;
	NSString *titleLabel;
	NSString *initialDateValue;
    BOOL buttonClicked;

	//---XIB----------------------------
	IBOutlet UIPickerView *picker;
	IBOutlet UILabel *label;
	IBOutlet UITextField *textField;
	IBOutlet UILabel *currencySymbol;
	IBOutlet UIButton *clearButton;
	
	//---Gloabls----------------------------
	int numberOfWheels;

}

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) UIPickerView *picker;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UILabel *currencySymbol;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, copy) NSString *titleLabel;
@property (nonatomic, copy) NSString *initialDateValue;
@property (nonatomic, strong) UIButton *clearButton;
@property (nonatomic, strong) UIViewController *callBackViewController;
@property (nonatomic) int numberOfWheels;
@property (nonatomic) BOOL buttonClicked;

- (IBAction) clearPressed: (id) sender;
- (IBAction) num1Pressed: (id) sender;
- (IBAction) num2Pressed: (id) sender;
- (IBAction) num3Pressed: (id) sender;
- (IBAction) num4Pressed: (id) sender;
- (IBAction) num5Pressed: (id) sender;
- (IBAction) num6Pressed: (id) sender;
- (IBAction) num7Pressed: (id) sender;
- (IBAction) num8Pressed: (id) sender;
- (IBAction) num9Pressed: (id) sender;
- (IBAction) num0Pressed: (id) sender;
- (IBAction) num100Pressed: (id) sender;
- (IBAction) num20Pressed: (id) sender;
- (IBAction) numPlus1Pressed: (id) sender;


@end
