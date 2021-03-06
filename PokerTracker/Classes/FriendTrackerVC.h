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
	IBOutlet UILabel *datelabel;
	IBOutlet CustomSegment *topSegment;
	IBOutlet CustomSegment *sortSegment;
	IBOutlet CustomSegment *timeFrameSegment;
	IBOutlet UIButton *friendButton;
    IBOutlet UIImageView *chartImageView;
    IBOutlet UIImageView *chartLast10ImageView;
    IBOutlet UIImageView *chartThisMonthImageView;
    NSMutableDictionary *playerDict;
    
    int processYear;
    int processMonth;
    BOOL friendModeOn;
    BOOL showRefreshFlg;
}

- (IBAction) sortSegmentChanged: (id) sender;
- (IBAction) timeSegmentChanged: (id) sender;
- (IBAction) addButtonPressed: (id) sender;

-(void)startBackgroundProcess;

@property (atomic, strong) UIImageView *chartImageView;
@property (atomic, strong) UIImageView *chartLast10ImageView;
@property (atomic, strong) UIImageView *chartThisMonthImageView;
@property (atomic, strong) UILabel *datelabel;
@property (atomic, strong) CustomSegment *topSegment;
@property (atomic, strong) CustomSegment *sortSegment;
@property (atomic, strong) CustomSegment *timeFrameSegment;
@property (atomic, strong) UIButton *friendButton;

@property (atomic, strong) IBOutlet UIView *addFriendView;

@property (atomic) int processYear;
@property (atomic) int processMonth;
@property (atomic) BOOL friendModeOn;
@property (atomic) BOOL showRefreshFlg;

@property (atomic, strong) NSMutableDictionary *playerDict;

@end
