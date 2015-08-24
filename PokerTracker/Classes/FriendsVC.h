//
//  FriendsVC.h
//  PokerTracker
//
//  Created by Rick Medved on 10/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface FriendsVC : UIViewController {
 	//---Passed In----------------------------
	NSManagedObjectContext *managedObjectContext;

	//---XIB----------------------------
	IBOutlet UIButton *refreshButton;
	IBOutlet UIButton *mboxButton;
	IBOutlet UIButton *sampleButton;
	IBOutlet UISwitch *autoSyncSwitch;
	IBOutlet UILabel *refreshDateLabel;
	IBOutlet UILabel *mailCount;
	IBOutlet UIActivityIndicatorView *activityIndicator;
	IBOutlet UITextView *textViewBG;
	IBOutlet UIImageView *activityPopup;
	IBOutlet UILabel *activityLabel;
	IBOutlet UITableView *mainTableView;
	IBOutlet UISegmentedControl *timeSegment;
	IBOutlet UISegmentedControl *categorySegment;
	
	//---Gloabls----------------------------
	NSMutableArray *friendsList;
	BOOL updFlg;
	BOOL hasMailFlg;
	
	
	
}

- (IBAction) samplePressed: (id) sender;
- (IBAction) switchPressed: (id) sender;
- (IBAction) refreshPressed: (id) sender; 
- (IBAction) mailButtonClicked:(id)sender;
- (IBAction) timeSegmentChanged: (id) sender;
- (IBAction) categorySegmentChanged: (id) sender;
- (IBAction) universeButtonPressed: (id) sender;
-(void)setUpData;


@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, strong) UIButton *refreshButton;
@property (nonatomic, strong) UIButton *mboxButton;
@property (nonatomic, strong) UIButton *sampleButton;
@property (nonatomic, strong) UISwitch *autoSyncSwitch;
@property (nonatomic, strong) UILabel *refreshDateLabel;
@property (nonatomic, strong) NSMutableArray *friendsList;

@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) UITextView *textViewBG;
@property (nonatomic, strong) UIImageView *activityPopup;
@property (nonatomic, strong) UILabel *activityLabel;
@property (nonatomic, strong) UILabel *mailCount;
@property (nonatomic, strong) UITableView *mainTableView;

@property (nonatomic, strong) UISegmentedControl *timeSegment;
@property (nonatomic, strong) UISegmentedControl *categorySegment;
@property (nonatomic) BOOL updFlg;
@property (nonatomic) BOOL hasMailFlg;





@end
