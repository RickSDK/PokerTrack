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

	//---XIB----------------------------
	IBOutlet UITableView *mainTableView;
	IBOutlet UIImageView *activityBGView;
	IBOutlet UIActivityIndicatorView *activityIndicator;
	IBOutlet UIButton *profitButton;
	IBOutlet UIButton *hourlyButton;

	//---Gloabls----------------------------
	NSMutableArray *monthlyProfits;
	NSMutableArray *hourlyProfits;
	UIImageView *chart1ImageView;
	UIImageView *chart2ImageView;
	int selectedObjectForEdit;
    BOOL coreDataLocked;

}

- (IBAction) monthlyProfitGoalChanged: (id) sender;
- (IBAction) hourlyGoalChanged: (id) sender;
- (void) computeStats;

@property (atomic, strong) UIImageView *activityBGView;
@property (atomic, strong) UIActivityIndicatorView *activityIndicator;

@property (atomic) BOOL coreDataLocked;
@property (atomic, strong) IBOutlet UILabel *profitGoalLabel;
@property (atomic, strong) IBOutlet UILabel *hourlyGoalLabel;

@property (atomic) int selectedObjectForEdit;
@property (atomic, strong) UIButton *profitButton;
@property (atomic, strong) UIButton *hourlyButton;

@property (atomic, strong) NSMutableArray *monthlyProfits;
@property (atomic, strong) NSMutableArray *hourlyProfits;

@property (atomic, strong) UIImageView *chart1ImageView;
@property (atomic, strong) UIImageView *chart2ImageView;


@end

