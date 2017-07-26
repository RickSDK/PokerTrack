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
	IBOutlet UILabel *datelabel;
	IBOutlet CustomSegment *sortSegment;
	IBOutlet UIButton *profileButton;
	
    int processYear;
	int processMonth;
	int skip;
    BOOL friendModeOn;
	BOOL keepGoing;
	
}

- (IBAction) profileButtonPressed: (id) sender;
- (IBAction) sortSegmentChanged: (id) sender;
-(void)startBackgroundProcess;

@property (atomic, strong) UILabel *datelabel;
@property (atomic, strong) UISegmentedControl *sortSegment;
@property (atomic, strong) UIButton *profileButton;

@property (atomic) int processYear;
@property (atomic) int processMonth;
@property (atomic) BOOL friendModeOn;
@property (atomic) BOOL keepGoing;
@property (atomic) int skip;

@end
