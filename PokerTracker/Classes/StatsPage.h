//
//  StatsPage.h
//  PokerTracker
//
//  Created by Rick Medved on 10/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>

@interface StatsPage : UIViewController {
 	//---Passed In----------------------------
	NSManagedObjectContext *managedObjectContext;
	NSManagedObject *filterObj;
	int displayYear;
	NSString *gameType;
	BOOL hideMainMenuButton;

	//---XIB----------------------------
	IBOutlet UITableView *mainTableView;
	IBOutlet UIToolbar *analysisToolbar;
	IBOutlet UIToolbar *yearToolbar;
	IBOutlet UIToolbar *top5Toolbar;
	IBOutlet UISegmentedControl *gameSegment;
	IBOutlet UISegmentedControl *customSegment;
	IBOutlet UIImageView *activityBGView;
	IBOutlet UIActivityIndicatorView *activityIndicator;
	IBOutlet UILabel *yearLabel;
	IBOutlet UIButton *leftYear;
	IBOutlet UIButton *rightYear;
	IBOutlet UIImageView *largeGraph;
    IBOutlet UIButton *bankrollButton;

	IBOutlet UIButton *top5Button;
    IBOutlet UIButton *last10Button;
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
	IBOutlet UISegmentedControl *bankRollSegment;

	NSMutableArray *multiDimenArray;

}

- (IBAction) yearSegmentPressed: (id) sender;
- (IBAction) gameSegmentPressed: (id) sender;
- (IBAction) customSegmentPressed: (id) sender;
- (IBAction) yearGoesDown: (id) sender;
- (IBAction) yearGoesUp: (id) sender;
- (IBAction) analysisPressed: (id) sender;
- (IBAction) reportsPressed: (id) sender;
- (IBAction) chartsPressed: (id) sender;
- (IBAction) goalsPressed: (id) sender;
- (IBAction) bankrollPressed: (id) sender;
- (IBAction) bankrollSegmentChanged: (id) sender;
- (IBAction) top5Pressed: (id) sender;
- (IBAction) last10Pressed: (id) sender;


-(void) computeStats;
-(void)initializeFormData;
//-(BOOL)saveNewFilter:(NSString *)valueCombo;

@property (atomic, strong) NSMutableArray *profitArray;
@property (atomic, strong) UIButton *top5Button;
@property (atomic, strong) UIButton *last10Button;
@property (atomic, strong) NSManagedObjectContext *managedObjectContext;
@property (atomic, strong) NSManagedObject *filterObj;
@property (atomic) int selectedFieldIndex;
@property (atomic) BOOL hideMainMenuButton;
@property (atomic) BOOL displayBySession;
@property (atomic) BOOL viewLocked;
@property (atomic) BOOL rotateLock;
@property (atomic) BOOL viewUnLoaded;
@property (atomic, strong) UITableView *mainTableView;
@property (atomic, strong) UISegmentedControl *gameSegment;
@property (atomic, strong) UISegmentedControl *customSegment;
@property (atomic, strong) UIToolbar *analysisToolbar;
@property (atomic, strong) UIToolbar *yearToolbar;
@property (atomic, strong) UIToolbar *top5Toolbar;
@property (atomic, strong) UISegmentedControl *bankRollSegment;

@property (atomic) int displayYear;
@property (atomic, strong) UILabel *yearLabel;
@property (atomic, strong) UIButton *leftYear;
@property (atomic, strong) UIButton *rightYear;

@property (atomic, strong) UIImageView *activityBGView;
@property (atomic, strong) IBOutlet UIImageView *chartImageView;
@property (atomic, strong) IBOutlet UIImageView *chartImageView2;
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
@property (atomic, strong) UIButton *bankrollButton;




@end
