//
//  StatsPage.h
//  PokerTracker
//
//  Created by Rick Medved on 10/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TemplateVC.h"
#import "MultiCellObj.h"

@interface StatsPage : TemplateVC {
 	//---Passed In----------------------------
	NSManagedObject *filterObj;
	NSString *gameType;
	BOOL hideMainMenuButton;

	//---XIB----------------------------
	IBOutlet UIToolbar *analysisToolbar;
	IBOutlet UIToolbar *top5Toolbar;
	IBOutlet CustomSegment *gameSegment;
	IBOutlet CustomSegment *customSegment;
	IBOutlet UIImageView *activityBGView;
	IBOutlet UIActivityIndicatorView *activityIndicator;
	IBOutlet UIImageView *largeGraph;

    IBOutlet UIButton *chartsButton;
    IBOutlet UIButton *reportsButton;
    IBOutlet UIButton *goalsButton;
    IBOutlet UIButton *analysisButton;

	//---Gloabls----------------------------
	NSMutableArray *labelValues;
	NSMutableArray *statsArray;
	NSMutableArray *profitArray;
	NSMutableArray *formDataArray;
	UIImageView *chartImageView;
	UIBarButtonItem *dateSessionButton;
	int selectedFieldIndex;
	BOOL displayBySession;
	BOOL viewLocked;
	BOOL rotateLock;
    BOOL viewUnLoaded;

	NSMutableArray *multiDimenArray;

}

- (IBAction) gameSegmentPressed: (id) sender;
- (IBAction) customSegmentPressed: (id) sender;
- (IBAction) analysisPressed: (id) sender;
- (IBAction) reportsPressed: (id) sender;
- (IBAction) chartsPressed: (id) sender;
- (IBAction) goalsPressed: (id) sender;

-(void) computeStats;
-(void)initializeFormData;

@property (atomic, strong) NSMutableArray *profitArray;
@property (atomic, strong) NSManagedObject *filterObj;
@property (atomic) int selectedFieldIndex;
@property (atomic) BOOL hideMainMenuButton;
@property (atomic) BOOL displayBySession;
@property (atomic) BOOL viewLocked;
@property (atomic) BOOL rotateLock;
@property (atomic) BOOL viewUnLoaded;
@property (atomic, strong) CustomSegment *gameSegment;
@property (atomic, strong) CustomSegment *customSegment;
@property (atomic, strong) UIToolbar *analysisToolbar;
@property (atomic, strong) UIToolbar *top5Toolbar;

@property (atomic, strong) UIImageView *activityBGView;
@property (atomic, strong) IBOutlet UIImageView *chartImageView;
@property (atomic, strong) IBOutlet UIImageView *chartImageView2;
@property (atomic, strong) IBOutlet UIImageView *playerTypeImageView;
@property (atomic, strong) UIImageView *largeGraph;
@property (atomic, strong) UIActivityIndicatorView *activityIndicator;

@property (atomic, strong) NSMutableArray *labelValues;
@property (atomic, strong) NSMutableArray *statsArray;
@property (atomic, strong) NSMutableArray *formDataArray;
@property (atomic, copy) NSString *gameType;
@property (atomic, strong) UIBarButtonItem *dateSessionButton;
@property (atomic, strong) UIButton *chartsButton;
@property (atomic, strong) UIButton *reportsButton;
@property (atomic, strong) UIButton *goalsButton;
@property (atomic, strong) UIButton *analysisButton;

@property (atomic, strong) NSMutableArray *multiDimenArray;

@property (atomic, strong) IBOutlet UILabel *chartsLabel;
@property (atomic, strong) IBOutlet UILabel *reportsLabel;
@property (atomic, strong) IBOutlet UILabel *goalsLabel;
@property (atomic, strong) IBOutlet UILabel *analysisLabel;

@property (atomic, strong) MultiCellObj *gameStatsSection;
@property (atomic, strong) MultiCellObj *quarterStatsSection;
@property (atomic, strong) MultiCellObj *gamesWonSection;
@property (atomic, strong) MultiCellObj *gamesLostSection;




@end
