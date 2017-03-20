//
//  FriendTrackerVC.h
//  PokerTracker
//
//  Created by Rick Medved on 4/29/13.
//
//

#import <UIKit/UIKit.h>
#import "TemplateVC.h"

@interface FriendTrackerVC : TemplateVC {
	IBOutlet UIActivityIndicatorView *activityIndicator;
	IBOutlet UIImageView *activityPopup;
	IBOutlet UILabel *activityLabel;
	IBOutlet UILabel *datelabel;
	IBOutlet UISegmentedControl *topSegment;
	IBOutlet UISegmentedControl *sortSegment;
	IBOutlet UISegmentedControl *timeFrameSegment;
	IBOutlet UIButton *profileButton;
	IBOutlet UIButton *friendButton;
	IBOutlet UIButton *refreshButton;
    IBOutlet UIBarButtonItem *prevButton;
    IBOutlet UIBarButtonItem *nextButton;
    IBOutlet UIImageView *chartImageView;
    IBOutlet UIImageView *chartLast10ImageView;
    IBOutlet UIImageView *chartThisMonthImageView;
	IBOutlet UIImageView *blackBG;
	
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
    NSMutableDictionary *playerDict;
    
    int processYear;
    int processMonth;
    BOOL friendModeOn;
    BOOL showRefreshFlg;

	
}

- (IBAction) segmentChanged: (id) sender;
- (IBAction) profileButtonPressed: (id) sender;
- (IBAction) sortSegmentChanged: (id) sender;
- (IBAction) timeSegmentChanged: (id) sender;
- (IBAction) prevButtonPressed: (id) sender;
- (IBAction) nextButtonPressed: (id) sender;
- (IBAction) refreshButtonPressed: (id) sender;
- (IBAction) addButtonPressed: (id) sender;
-(void)startBackgroundProcess;

@property (atomic, strong) UIActivityIndicatorView *activityIndicator;
@property (atomic, strong) UIImageView *chartImageView;
@property (atomic, strong) UIImageView *chartLast10ImageView;
@property (atomic, strong) UIImageView *chartThisMonthImageView;
@property (atomic, strong) UIImageView *activityPopup;
@property (atomic, strong) UILabel *activityLabel;
@property (atomic, strong) UILabel *datelabel;
@property (atomic, strong) UISegmentedControl *topSegment;
@property (atomic, strong) UISegmentedControl *sortSegment;
@property (atomic, strong) UISegmentedControl *timeFrameSegment;
@property (atomic, strong) UIButton *profileButton;
@property (atomic, strong) UIButton *friendButton;
@property (atomic, strong) UIButton *refreshButton;

@property (atomic, strong) UIImageView *blackBG;

@property (atomic, strong) UIBarButtonItem *prevButton;
@property (atomic, strong) UIBarButtonItem *nextButton;

@property (atomic) int processYear;
@property (atomic) int processMonth;
@property (atomic) BOOL friendModeOn;
@property (atomic) BOOL showRefreshFlg;

@property (atomic, strong) NSMutableDictionary *playerDict;

@property (atomic, strong) NSMutableArray *userList;
@property (atomic, strong) NSMutableArray *profitList;
@property (atomic, strong) NSMutableArray *moneyList;
@property (atomic, strong) NSMutableArray *gamesList;
@property (atomic, copy) NSString *friendList;

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
