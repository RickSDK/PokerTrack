//
//  ProfitReportsVC.h
//  PokerTracker
//
//  Created by Rick Medved on 3/20/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//
/*
#import <UIKit/UIKit.h>


@interface ProfitReportsVC : UIViewController {
	NSManagedObjectContext *managedObjectContext;
	int displayYear;
	NSString *gameType;

	IBOutlet UITableView *mainTableView;
	IBOutlet UIImageView *activityBGView;
	IBOutlet UIActivityIndicatorView *activityIndicator;
	IBOutlet UILabel *yearLabel;
	IBOutlet UIBarButtonItem *leftYear;
	IBOutlet UIBarButtonItem *rightYear;
	IBOutlet UISegmentedControl *gameSegment;
	IBOutlet UIToolbar *yearToolbar;
	
	BOOL last10Flg;
	BOOL viewLocked;
	NSMutableArray *multiDimenArray;
	
}

- (IBAction) gameSegmentChanged: (id) sender;
- (IBAction) yearGoesUp: (id) sender;
- (IBAction) yearGoesDown: (id) sender;
- (void)calculateData;
- (IBAction) last10Pressed: (id) sender;


@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic) int displayYear;
@property (nonatomic, retain) NSString *gameType;

@property (nonatomic, retain) UITableView *mainTableView;
@property (nonatomic, retain) UIImageView *activityBGView;
@property (nonatomic, retain) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, retain) UILabel *yearLabel;
@property (nonatomic, retain) UIBarButtonItem *leftYear;
@property (nonatomic, retain) UIBarButtonItem *rightYear;
@property (nonatomic, retain) UISegmentedControl *gameSegment;
@property (nonatomic, retain) UIToolbar *yearToolbar;
@property (nonatomic, retain) NSMutableArray *multiDimenArray;

@property (nonatomic) BOOL last10Flg;




//@property (nonatomic, retain) NSMutableArray *sectionTitles;
//@property (nonatomic, retain) NSMutableArray *multiDimentionalValues;
//@property (nonatomic, retain) UISegmentedControl *topSegment;
//@property (nonatomic, retain) UIButton *refreshButton;
@property (nonatomic) BOOL viewLocked;




@end
