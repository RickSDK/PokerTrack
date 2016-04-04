//
//  UserSummaryVC.h
//  PokerTracker
//
//  Created by Rick Medved on 6/6/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>
#import "NetUserObj.h"


@interface UserSummaryVC : UIViewController <ADBannerViewDelegate> {
	NSManagedObjectContext *managedObjectContext;
	IBOutlet UITableView *mainTableView;
	IBOutlet UIButton *addFriendButton;
	IBOutlet UIButton *removeFriendButton;
	IBOutlet UIButton *viewgameButton;
	IBOutlet UILabel *nameLabel;
	IBOutlet UILabel *locationLabel;
	IBOutlet UILabel *dateLabel;
    IBOutlet ADBannerView *adView;
    IBOutlet UISegmentedControl *topSegment;
	
	IBOutlet UIActivityIndicatorView *activityIndicator;
	IBOutlet UIImageView *imageViewBG;
	IBOutlet UIImageView *playerImageView;
	IBOutlet UILabel *activityLabel;
	IBOutlet UILabel *versionLabel;
	IBOutlet UILabel *moneySymbolLabel;

	NSString *user;
	NSMutableArray *values;
    NSString *friendName;
    NSString *latestMonth;
    NSString *nameString;
    NSString *cityString;
    int friend_id;
    int selectedSegment;
    int popupBoxNumber;
    BOOL loadedFlg;
    BOOL selfFlg;
}

- (IBAction) addButtonPressed: (id) sender;
- (IBAction) removeButtonPressed: (id) sender;
- (IBAction) viewButtonPressed: (id) sender;
- (IBAction) segmentChanged: (id) sender;


@property (atomic, strong) NSManagedObjectContext *managedObjectContext;
@property (atomic, strong) UITableView *mainTableView;
@property (atomic, copy) NSString *user;
@property (atomic, strong) ADBannerView *adView;
@property (atomic, strong) NetUserObj *netUserObj;
@property (atomic, strong) NSMutableArray *values;
@property (atomic, strong) UIButton *addFriendButton;
@property (atomic, strong) UIButton *removeFriendButton;
@property (atomic, strong) UIButton *viewgameButton;
@property (atomic, strong) UISegmentedControl *topSegment;

@property (atomic, strong) UILabel *nameLabel;
@property (atomic, strong) UILabel *locationLabel;
@property (atomic, strong) UILabel *dateLabel;

@property (atomic, copy) NSString *friendName;
@property (atomic, copy) NSString *latestMonth;
@property (atomic, copy) NSString *nameString;
@property (atomic, copy) NSString *cityString;
@property (atomic) int friend_id;
@property (atomic) int selectedSegment;
@property (atomic) int popupBoxNumber;
@property (atomic) BOOL loadedFlg;
@property (atomic) BOOL selfFlg;


@property (atomic, strong) UIActivityIndicatorView *activityIndicator;
@property (atomic, strong) UIImageView *imageViewBG;
@property (atomic, strong) UIImageView *playerImageView;
@property (atomic, strong) UILabel *activityLabel;
@property (atomic, strong) UILabel *versionLabel;
@property (atomic, strong) UILabel *moneySymbolLabel;



@end
