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
	IBOutlet UISegmentedControl *gameSegment;
	IBOutlet UIActivityIndicatorView *activityIndicator;
	
	double gRisked;
	double gIncome;
	BOOL last10Flg;
	NSString *analysisText;
    
    NSMutableArray *playerBasicsArray;
    NSMutableArray *colorArray1;
}

- (IBAction) gameSegmentChanged: (id) sender;
- (IBAction) detailsButtonPressed: (id) sender;
- (void) computeStats;

@property (atomic, strong) UILabel *playerTypeLabel;
@property (atomic, strong) NSMutableArray *playerBasicsArray;
@property (atomic, strong) NSMutableArray *colorArray1;

@property (atomic, copy) NSString *analysisText;


@property (atomic) BOOL last10Flg;
@property (atomic) double gRisked;
@property (atomic) double gIncome;

@property (atomic, strong) UIActivityIndicatorView *activityIndicator;
@property (atomic, strong) UILabel *thLabel;
@property (atomic, strong) UISegmentedControl *gameSegment;


@end
