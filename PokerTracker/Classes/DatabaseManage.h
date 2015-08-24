//
//  DatabaseManage.h
//  PokerTracker
//
//  Created by Rick Medved on 10/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface DatabaseManage : UIViewController {
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
	
}

- (IBAction) laterPressed: (id) sender;
- (IBAction) importPressed: (id) sender;
- (void)executeThreadedJob:(SEL)aSelector;
- (void)completeThreadedjob;


@property (atomic, strong) NSManagedObjectContext *managedObjectContext;
@property (atomic, strong) UIViewController *callBackViewController;


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
@property (atomic, strong) UIImageView *activityBG;
@property (atomic, strong) UIImageView *activityPopup;
@property (atomic, strong) UITableView *mainTableView;

@property (atomic, strong) NSMutableArray *menuArray;
@property (atomic, strong) NSMutableArray *secondMenuArray;
@property (atomic, copy) NSString *messageString;

@end
