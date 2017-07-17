//
//  UniverseTrackerVC.h
//  PokerTracker
//
//  Created by Rick Medved on 6/5/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>
#import "CustomSegment.h"
#import "NetUserObj.h"
#import "TemplateVC.h"

@interface UniverseTrackerVC : TemplateVC {
 	//---Passed In----------------------------
	NSManagedObjectContext *managedObjectContext;
	IBOutlet UIActivityIndicatorView *activityIndicator;
	IBOutlet UIImageView *activityPopup;
	IBOutlet UILabel *activityLabel;
	IBOutlet UILabel *datelabel;
	IBOutlet UITableView *mainTableView;
	IBOutlet CustomSegment *topSegment;
	IBOutlet CustomSegment *sortSegment;
	IBOutlet CustomSegment *timeFrameSegment;
	IBOutlet UIButton *profileButton;
	IBOutlet UIButton *friendButton;
    IBOutlet UIBarButtonItem *prevButton;
    IBOutlet UIBarButtonItem *nextButton;
    
	NSMutableArray *netUserList;

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
	int skip;
    BOOL friendModeOn;
	BOOL keepGoing;
	
}

- (IBAction) segmentChanged: (id) sender;
- (IBAction) profileButtonPressed: (id) sender;
- (IBAction) sortSegmentChanged: (id) sender;
- (IBAction) timeSegmentChanged: (id) sender;
- (IBAction) prevButtonPressed: (id) sender;
- (IBAction) nextButtonPressed: (id) sender;
-(void)startBackgroundProcess;

@property (atomic, strong) UIActivityIndicatorView *activityIndicator;
@property (atomic, strong) UIImageView *activityPopup;
@property (atomic, strong) UILabel *activityLabel;
@property (atomic, strong) UILabel *datelabel;
@property (atomic, strong) UISegmentedControl *topSegment;
@property (atomic, strong) UISegmentedControl *sortSegment;
@property (atomic, strong) UISegmentedControl *timeFrameSegment;
@property (atomic, strong) UIButton *profileButton;
@property (atomic, strong) UIButton *friendButton;

@property (atomic, strong) NSMutableArray *netUserList;

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
@property (atomic) BOOL keepGoing;
@property (atomic) int skip;


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
