//
//  GoalsVC.h
//  PokerTracker
//
//  Created by Rick Medved on 11/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TemplateVC.h"


@interface GoalsVC : TemplateVC {
 	//---Passed In----------------------------
	NSManagedObjectContext *managedObjectContext;
	int displayYear;

	//---XIB----------------------------
	IBOutlet UITableView *mainTableView;
	IBOutlet UILabel *yearLabel;
	IBOutlet UIButton *leftYear;
	IBOutlet UIButton *rightYear;
	IBOutlet UIImageView *activityBGView;
	IBOutlet UIActivityIndicatorView *activityIndicator;
	IBOutlet UIButton *profitButton;
	IBOutlet UIButton *hourlyButton;
	IBOutlet UIToolbar *yearToolbar;
	IBOutlet UISegmentedControl *bankRollSegment;
    IBOutlet UIButton *bankrollButton;

	//---Gloabls----------------------------
	NSMutableArray *monthlyProfits;
	NSMutableArray *hourlyProfits;
	UIImageView *chart1ImageView;
	UIImageView *chart2ImageView;
	int selectedObjectForEdit;
    BOOL coreDataLocked;

}

- (IBAction) yearGoesUp: (id) sender;
- (IBAction) yearGoesDown: (id) sender;
- (IBAction) monthlyProfitGoalChanged: (id) sender;
- (IBAction) hourlyGoalChanged: (id) sender;
- (void) computeStats;
- (IBAction) bankrollPressed: (id) sender;
- (IBAction) bankrollSegmentChanged: (id) sender;

@property (atomic, strong) NSManagedObjectContext *managedObjectContext;
@property (atomic, strong) UITableView *mainTableView;
@property (atomic, strong) UIImageView *activityBGView;
@property (atomic, strong) UIActivityIndicatorView *activityIndicator;

@property (atomic) int displayYear;
@property (atomic) BOOL coreDataLocked;
@property (atomic, strong) UILabel *yearLabel;
@property (atomic, strong) UIButton *leftYear;
@property (atomic, strong) UIButton *rightYear;
@property (atomic, strong) UISegmentedControl *bankRollSegment;
@property (atomic, strong) UIButton *bankrollButton;

@property (atomic) int selectedObjectForEdit;
@property (atomic, strong) UIButton *profitButton;
@property (atomic, strong) UIButton *hourlyButton;

@property (atomic, strong) NSMutableArray *monthlyProfits;
@property (atomic, strong) NSMutableArray *hourlyProfits;

@property (atomic, strong) UIImageView *chart1ImageView;
@property (atomic, strong) UIImageView *chart2ImageView;

@property (atomic, strong) UIToolbar *yearToolbar;



@end

