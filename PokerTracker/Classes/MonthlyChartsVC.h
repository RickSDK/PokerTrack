//
//  MonthlyChartsVC.h
//  PokerTracker
//
//  Created by Rick Medved on 11/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TemplateVC.h"


@interface MonthlyChartsVC : TemplateVC {
	//---Passed In----------------------------
    NSManagedObjectContext *managedObjectContext;
	int displayYear;

	//---XIB----------------------------
	IBOutlet UITableView *mainTableView;
	IBOutlet UIButton *profitButton;
	IBOutlet UIButton *hourlyButton;
	IBOutlet UILabel *yearLabel;
	IBOutlet UIButton *leftYear;
	IBOutlet UIButton *rightYear;
	IBOutlet UIImageView *activityBGView;
	IBOutlet UIActivityIndicatorView *activityIndicator;
	IBOutlet UIToolbar *yearToolbar;
	IBOutlet UISegmentedControl *moneySegment;
	IBOutlet UISegmentedControl *bankRollSegment;
    IBOutlet UIButton *bankrollButton;
	
	//---Gloabls----------------------------
	NSMutableArray *yearlyProfits;
	NSMutableArray *yearHourlyProfits;
	NSMutableArray *monthlyProfits;
	NSMutableArray *hourlyProfits;

	NSMutableArray *dayProfits;
	NSMutableArray *dayHourly;
	NSMutableArray *timeProfits;
	NSMutableArray *timeHourly;
	
	int selectedObjectForEdit;
	UIImageView *chartMonth1ImageView;
	UIImageView *chartMonth2ImageView;
	UIImageView *chart3ImageView;
	UIImageView *chart4ImageView;
	UIImageView *chart5ImageView;
	UIImageView *chart6ImageView;
	UIImageView *chartYear1ImageView;
	UIImageView *chartYear2ImageView;
	
	BOOL showBreakdownFlg;
    BOOL lockScreen;
    BOOL viewUnLoaded;
}

- (IBAction) yearGoesUp: (id) sender;
- (IBAction) yearGoesDown: (id) sender;
- (IBAction) moneySegmentChanged: (id) sender;
- (IBAction) bankrollPressed: (id) sender;
- (IBAction) bankrollSegmentChanged: (id) sender;
- (void) computeStats;

@property (atomic, strong) UIImageView *activityBGView;
@property (atomic, strong) UIActivityIndicatorView *activityIndicator;
@property (atomic, strong) UIToolbar *yearToolbar;
@property (atomic, strong) UISegmentedControl *bankRollSegment;
@property (atomic, strong) UIButton *bankrollButton;

@property (atomic) int displayYear;
@property (atomic) BOOL showBreakdownFlg;
@property (atomic) BOOL lockScreen;
@property (atomic) BOOL viewUnLoaded;
@property (atomic, strong) UILabel *yearLabel;
@property (atomic, strong) UIButton *leftYear;
@property (atomic, strong) UIButton *rightYear;

@property (atomic) int selectedObjectForEdit;
@property (atomic, strong) UIButton *profitButton;
@property (atomic, strong) UIButton *hourlyButton;

@property (atomic, strong) NSMutableArray *yearlyProfits;
@property (atomic, strong) NSMutableArray *yearHourlyProfits;
@property (atomic, strong) NSMutableArray *monthlyProfits;
@property (atomic, strong) NSMutableArray *hourlyProfits;
@property (atomic, strong) NSMutableArray *dayProfits;
@property (atomic, strong) NSMutableArray *dayHourly;
@property (atomic, strong) NSMutableArray *timeProfits;
@property (atomic, strong) NSMutableArray *timeHourly;

@property (atomic, strong) UIImageView *chartMonth1ImageView;
@property (atomic, strong) UIImageView *chartMonth2ImageView;
@property (atomic, strong) UIImageView *chart3ImageView;
@property (atomic, strong) UIImageView *chart4ImageView;
@property (atomic, strong) UIImageView *chart5ImageView;
@property (atomic, strong) UIImageView *chart6ImageView;
@property (atomic, strong) UIImageView *chartYear1ImageView;
@property (atomic, strong) UIImageView *chartYear2ImageView;
@property (atomic, strong) UISegmentedControl *moneySegment;



@end
