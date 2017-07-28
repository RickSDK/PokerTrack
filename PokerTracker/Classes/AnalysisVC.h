//
//  AnalysisVC.h
//  PokerTracker
//
//  Created by Rick Medved on 2/7/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TemplateVC.h"


@interface AnalysisVC : TemplateVC {
	NSManagedObjectContext *managedObjectContext;
	
	IBOutlet UISegmentedControl *gameSegment;
	IBOutlet UIActivityIndicatorView *activityIndicator;
	
	double gRisked;
	double gIncome;
	BOOL last10Flg;
	NSString *analysisText;
    
    NSMutableArray *playerBasicsArray;
    NSMutableArray *playerStatsArray;
    NSMutableArray *colorArray1;
    NSMutableArray *colorArray2;

    UIBarButtonItem *top5Button;
	IBOutlet UISegmentedControl *bankRollSegment;
    IBOutlet UIButton *bankrollButton;
    IBOutlet UITableView *mainTableView;

}

- (IBAction) gameSegmentChanged: (id) sender;
- (IBAction) detailsButtonPressed: (id) sender;
- (IBAction) bankrollPressed: (id) sender;
- (IBAction) bankrollSegmentChanged: (id) sender;
- (void) computeStats;

@property (atomic, strong) UIBarButtonItem *top5Button;
@property (atomic, strong) UILabel *playerTypeLabel;
@property (atomic, strong) NSMutableArray *playerBasicsArray;
@property (atomic, strong) NSMutableArray *playerStatsArray;
@property (atomic, strong) NSMutableArray *colorArray1;
@property (atomic, strong) NSMutableArray *colorArray2;

@property (atomic, strong) UISegmentedControl *bankRollSegment;
@property (atomic, strong) UIButton *bankrollButton;
@property (atomic, copy) NSString *analysisText;


@property (atomic) BOOL last10Flg;
@property (atomic) double gRisked;
@property (atomic) double gIncome;

@property (atomic, strong) UIActivityIndicatorView *activityIndicator;
@property (atomic, strong) UILabel *thLabel;
@property (atomic, strong) UISegmentedControl *gameSegment;
@property (atomic, strong) UIToolbar *yearToolbar;


@end
