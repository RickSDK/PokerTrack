//
//  UniverseTrackerVC.h
//  PokerTracker
//
//  Created by Rick Medved on 6/5/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>


@interface UniverseTrackerVC : UIViewController {
 	//---Passed In----------------------------
	NSManagedObjectContext *managedObjectContext;
	IBOutlet UIActivityIndicatorView *activityIndicator;
	IBOutlet UIImageView *activityPopup;
	IBOutlet UILabel *activityLabel;
	IBOutlet UILabel *datelabel;
	IBOutlet UITableView *mainTableView;
	IBOutlet UISegmentedControl *topSegment;
	IBOutlet UISegmentedControl *sortSegment;
	IBOutlet UISegmentedControl *timeFrameSegment;
	IBOutlet UIButton *profileButton;
	IBOutlet UIButton *friendButton;
    IBOutlet UIBarButtonItem *prevButton;
    IBOutlet UIBarButtonItem *nextButton;
    
	
	NSMutableArray *userList;
	NSMutableArray *profitList;
	NSMutableArray *moneyList;
	NSMutableArray *gamesList;
    
    NSMutableArray *last10MoneyAllList;
    NSMutableArray *last10ProfitAllList;
    NSMutableArray *last10GamesAllList;
    NSMutableArray *monthMoneyAllList;
    NSMutableArray *monthProfitAllList;
    NSMutableArray *monthGamesAllList;

    NSMutableArray *yearMoneyFriendsList;
    NSMutableArray *yearProfitFriendsList;
    NSMutableArray *yearGamesFriendsList;
    
    NSString *friendList;
    
    int processYear;
    int processMonth;
    BOOL friendModeOn;
	
}

- (IBAction) segmentChanged: (id) sender;
- (IBAction) profileButtonPressed: (id) sender;
- (IBAction) sortSegmentChanged: (id) sender;
- (IBAction) timeSegmentChanged: (id) sender;
- (IBAction) prevButtonPressed: (id) sender;
- (IBAction) nextButtonPressed: (id) sender;
-(void)startBackgroundProcess;

@property (atomic, strong) NSManagedObjectContext *managedObjectContext;
@property (atomic, strong) UIActivityIndicatorView *activityIndicator;
@property (atomic, strong) UIImageView *activityPopup;
@property (atomic, strong) UILabel *activityLabel;
@property (atomic, strong) UILabel *datelabel;
@property (atomic, strong) UITableView *mainTableView;
@property (atomic, strong) UISegmentedControl *topSegment;
@property (atomic, strong) UISegmentedControl *sortSegment;
@property (atomic, strong) UISegmentedControl *timeFrameSegment;
@property (atomic, strong) UIButton *profileButton;
@property (atomic, strong) UIButton *friendButton;


@property (atomic, strong) NSMutableArray *userList;
@property (atomic, strong) NSMutableArray *profitList;
@property (atomic, strong) NSMutableArray *moneyList;
@property (atomic, strong) NSMutableArray *gamesList;
@property (atomic, copy) NSString *friendList;

@property (atomic, strong) UIBarButtonItem *prevButton;
@property (atomic, strong) UIBarButtonItem *nextButton;
@property (atomic, strong) UIBarButtonItem *syncButton;

@property (atomic) int processYear;
@property (atomic) int processMonth;
@property (atomic) BOOL friendModeOn;

@property (atomic, strong) NSMutableArray *last10MoneyAllList;
@property (atomic, strong) NSMutableArray *last10ProfitAllList;
@property (atomic, strong) NSMutableArray *last10GamesAllList;
@property (atomic, strong) NSMutableArray *monthMoneyAllList;
@property (atomic, strong) NSMutableArray *monthProfitAllList;
@property (atomic, strong) NSMutableArray *monthGamesAllList;

@property (atomic, strong) NSMutableArray *yearMoneyFriendsList;
@property (atomic, strong) NSMutableArray *yearProfitFriendsList;
@property (atomic, strong) NSMutableArray *yearGamesFriendsList;




@end
