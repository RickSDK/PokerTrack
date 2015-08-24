//
//  BankrollsVC.h
//  PokerTracker
//
//  Created by Rick Medved on 7/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BankrollsVC : UIViewController {
    NSManagedObjectContext *managedObjectContext;
    UIViewController *callBackViewController;
    
    IBOutlet UILabel *bankrollLabel;
    IBOutlet UILabel *bankrollSmallLabel;
    IBOutlet UIButton *bankrollButton;
    IBOutlet UIButton *deleteButton;
    IBOutlet UIButton *editAmountButton;
    IBOutlet UIButton *editDateButton;
    IBOutlet UIButton *showAllButton;
	IBOutlet UITableView *mainTableView;
	IBOutlet UISwitch *bankrollSwitch;
    
    int menuOption;
    int rowNum;
    NSMutableArray *logItems;
    NSMutableArray *logObjects;
    NSString *createdDate;
    NSString *transType;
    NSString *amountString;
    int indexpathRow;
    BOOL selectedFlg;

}

- (IBAction) bankrollButtonClicked:(id)sender;
- (IBAction) withdrawButtonClicked:(id)sender;
- (IBAction) depositButtonClicked:(id)sender;
- (IBAction) deleteButtonClicked:(id)sender;
- (IBAction) editAmountButtonClicked:(id)sender;
- (IBAction) editDateButtonClicked:(id)sender;
- (IBAction) showAllButtonClicked:(id)sender;
- (IBAction) bankrollSwitchClicked:(id)sender;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) UIViewController *callBackViewController;
@property (nonatomic, strong) UITableView *mainTableView;
@property (nonatomic, strong) UILabel *bankrollLabel;
@property (nonatomic, strong) UILabel *bankrollSmallLabel;
@property (nonatomic, strong) UIButton *bankrollButton;
@property (nonatomic, strong) UIButton *deleteButton;
@property (nonatomic, strong) UIButton *editAmountButton;
@property (nonatomic, strong) UIButton *editDateButton;
@property (nonatomic, strong) NSMutableArray *logItems;
@property (nonatomic, strong) NSMutableArray *logObjects;
@property (nonatomic, strong) NSString *createdDate;
@property (nonatomic, strong) NSString *transType;
@property (nonatomic, strong) NSString *amountString;
@property (nonatomic) int menuOption;
@property (nonatomic) int rowNum;
@property (nonatomic) int indexpathRow;
@property (nonatomic) BOOL selectedFlg;
@property (nonatomic, strong) UIButton *showAllButton;
@property (nonatomic, strong) UISwitch *bankrollSwitch;



@end
