//
//  UserSummaryVC.h
//  PokerTracker
//
//  Created by Rick Medved on 6/6/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NetUserObj.h"
#import "TemplateVC.h"
#import "MultiCellObj.h"


@interface UserSummaryVC : TemplateVC {
	IBOutlet UIButton *addFriendButton;
	IBOutlet UIButton *removeFriendButton;
	IBOutlet UIButton *viewgameButton;
    IBOutlet CustomSegment *topSegment;
	
	IBOutlet UILabel *versionLabel;
	IBOutlet UILabel *moneySymbolLabel;

	NSString *user;
    NSString *friendName;
    NSString *latestMonth;
    NSString *nameString;
    NSString *cityString;
    int selectedSegment;
    int popupBoxNumber;
    BOOL loadedFlg;
    BOOL selfFlg;
}

- (IBAction) addButtonPressed: (id) sender;
- (IBAction) removeButtonPressed: (id) sender;
- (IBAction) viewButtonPressed: (id) sender;
- (IBAction) segmentChanged: (id) sender;


@property (atomic, copy) NSString *user;
@property (atomic, strong) NetUserObj *netUserObj;
@property (atomic, strong) UIButton *addFriendButton;
@property (atomic, strong) UIButton *removeFriendButton;
@property (atomic, strong) UIButton *viewgameButton;
@property (atomic, strong) CustomSegment *topSegment;

@property (atomic, copy) NSString *friendName;
@property (atomic, copy) NSString *latestMonth;
@property (atomic, copy) NSString *nameString;
@property (atomic, copy) NSString *cityString;
@property (atomic) int selectedSegment;
@property (atomic) int popupBoxNumber;
@property (atomic) BOOL loadedFlg;
@property (atomic) BOOL selfFlg;

@property (atomic, strong) UILabel *versionLabel;
@property (atomic, strong) UILabel *moneySymbolLabel;
@property (atomic, strong) IBOutlet UILabel *nameLabel;
@property (atomic, strong) IBOutlet UILabel *cityLabel;
@property (atomic, strong) IBOutlet UIImageView *flagImageView;
@property (nonatomic, strong) MultiCellObj *multiCellObj;



@end
