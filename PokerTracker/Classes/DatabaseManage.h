//
//  DatabaseManage.h
//  PokerTracker
//
//  Created by Rick Medved on 10/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TemplateVC.h"


@interface DatabaseManage : TemplateVC {
	//---Passed In----------------------------
	NSManagedObjectContext *managedObjectContext;
	UIViewController *callBackViewController;
	

	//---XIB----------------------------
	IBOutlet UIActivityIndicatorView *activityIndicator;
	IBOutlet UIImageView *activityBG;
	IBOutlet UIImageView *activityPopup;
	IBOutlet UILabel *activityLabel;
	IBOutlet UILabel *gamesImportedLabel;
	IBOutlet UIProgressView *progressView;
	IBOutlet UILabel *userLabel;
	IBOutlet UILabel *emailLabel;
	IBOutlet UILabel *importProgressLabel;
	IBOutlet UILabel *exportTextLabel;
	IBOutlet UITableView *mainTableView;

	IBOutlet UIImageView *importPopup;
	IBOutlet UITextView *importTextView;
	IBOutlet UIButton *laterButton;
	IBOutlet UIButton *importButton;

	//---Gloabls----------------------------
	NSMutableArray *menuArray;
	NSMutableArray *secondMenuArray;
	int gSelectedRow;
	int totalNumGamesImported;
	int totalImportedLines;
	int numImportedLinesRead;
	BOOL importInProgress;
    BOOL coreDataLocked;
	int importType;
	NSString *messageString;
	NSString *activityLabelString;
	
}

- (IBAction) laterPressed: (id) sender;
- (IBAction) importPressed: (id) sender;
- (IBAction) upgradePressed: (id) sender;
- (IBAction) loginPressed: (id) sender;
- (void)executeThreadedJob:(SEL)aSelector;
- (void)completeThreadedjob;


@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (atomic, strong) UIViewController *callBackViewController;
@property (atomic, strong) IBOutlet UIButton *upgradeButton;
@property (atomic, strong) IBOutlet UIButton *loginButton;


@property (atomic, strong) UIImageView *importPopup;
@property (atomic, strong) UITextView *importTextView;
@property (atomic, strong) UIButton *laterButton;
@property (atomic, strong) UIButton *importButton;

@property (atomic) int gSelectedRow;
@property (atomic) int totalNumGamesImported;
@property (atomic) int totalImportedLines;
@property (atomic) int numImportedLinesRead;
@property (atomic) int importType;
@property (atomic) BOOL importInProgress;
@property (atomic) BOOL coreDataLocked;
@property (atomic, strong) UIActivityIndicatorView *activityIndicator;
@property (atomic, strong) UILabel *activityLabel;
@property (atomic, strong) UILabel *gamesImportedLabel;
@property (atomic, strong) UIProgressView *progressView;
@property (atomic, strong) UILabel *userLabel;
@property (atomic, strong) UILabel *emailLabel;
@property (atomic, strong) UILabel *importProgressLabel;
@property (atomic, strong) UILabel *exportTextLabel;
@property (atomic, strong) UIImageView *activityBG;
@property (atomic, strong) UIImageView *activityPopup;
@property (nonatomic, strong) UITableView *mainTableView;

@property (atomic, strong) NSMutableArray *menuArray;
@property (atomic, strong) NSMutableArray *secondMenuArray;
@property (atomic, copy) NSString *messageString;
@property (atomic, copy) NSString *activityLabelString;

@end
