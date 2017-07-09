//
//  ReportsVC.h
//  PokerTracker
//
//  Created by Rick Medved on 10/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TemplateVC.h"


@interface ReportsVC : TemplateVC {
	//---Passed In----------------------------
    NSManagedObjectContext *managedObjectContext;
	int displayYear;
	NSString *gameType;

	//---XIB----------------------------
	IBOutlet UITableView *mainTableView;
	IBOutlet UISegmentedControl *topSegment;
	IBOutlet UIImageView *activityBGView;
	IBOutlet UIActivityIndicatorView *activityIndicator;
	IBOutlet UILabel *yearLabel;
	IBOutlet UIButton *leftYear;
	IBOutlet UIButton *rightYear;
	IBOutlet UISegmentedControl *gameSegment;
	IBOutlet UIButton *refreshButton;
	IBOutlet UIToolbar *yearToolbar;
	
	//---Gloabls----------------------------
	NSMutableArray *sectionTitles;
	NSMutableArray *multiDimentionalValues;
	NSMutableArray *multiDimentionalValues0;
	NSMutableArray *multiDimentionalValues1;
	NSMutableArray *multiDimentionalValues2;
	BOOL viewLocked;
    BOOL viewUnLoaded;
	IBOutlet UISegmentedControl *bankRollSegment;
    IBOutlet UIButton *bankrollButton;

}

- (IBAction) segmentChanged: (id) sender;
- (IBAction) gameSegmentChanged: (id) sender;
- (IBAction) yearGoesUp: (id) sender;
- (IBAction) yearGoesDown: (id) sender;
- (IBAction) refreshPressed: (id) sender;
- (void) computeStats;
- (IBAction) bankrollPressed: (id) sender;
- (IBAction) bankrollSegmentChanged: (id) sender;

@property (atomic, strong) NSMutableArray *sectionTitles;
@property (atomic, strong) NSMutableArray *multiDimentionalValues;
@property (atomic, strong) NSMutableArray *multiDimentionalValues0;
@property (atomic, strong) NSMutableArray *multiDimentionalValues1;
@property (atomic, strong) NSMutableArray *multiDimentionalValues2;
@property (atomic, strong) UISegmentedControl *topSegment;
@property (atomic, strong) UIImageView *activityBGView;
@property (atomic, strong) UIActivityIndicatorView *activityIndicator;
@property (atomic, copy) NSString *gameType;
@property (atomic, strong) UIButton *refreshButton;
@property (atomic) BOOL viewLocked;
@property (atomic) BOOL viewUnLoaded;
@property (atomic, strong) UIToolbar *yearToolbar;
@property (atomic, strong) UISegmentedControl *bankRollSegment;
@property (atomic, strong) UIButton *bankrollButton;

@property (atomic) int displayYear;
@property (atomic, strong) UILabel *yearLabel;
@property (atomic, strong) UIButton *leftYear;
@property (atomic, strong) UIButton *rightYear;
@property (atomic, strong) UISegmentedControl *gameSegment;

@end
