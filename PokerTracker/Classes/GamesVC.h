//
//  GamesVC.h
//  PokerTracker
//
//  Created by Rick Medved on 10/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyToolbar.h"
#import "TemplateVC.h"
#import "GameSummaryView.h"


@interface GamesVC : TemplateVC <NSFetchedResultsControllerDelegate> {
	//---Passed In----------------------------
	NSManagedObjectContext *managedObjectContext;
	int displayYear;
	BOOL showMainMenuButton;

	//---XIB----------------------------
	IBOutlet UITableView *mainTableView;
	IBOutlet UILabel *yearLabel;
	IBOutlet UIButton *leftYear;
	IBOutlet UIButton *rightYear;
	IBOutlet UISegmentedControl *gameTypeSegment;
	IBOutlet UISegmentedControl *bankRollSegment;
    IBOutlet UIButton *bankrollButton;
	IBOutlet MyToolbar *yearToolbar;
	IBOutlet UIActivityIndicatorView *activityIndicator;

	//---Gloabls----------------------------
	NSMutableArray *gamesList;

}

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (atomic, strong) NSMutableArray *gamesList;
@property (atomic, strong) UIActivityIndicatorView *activityIndicator;
@property (atomic, strong) UISegmentedControl *gameTypeSegment;
@property (atomic, strong) UISegmentedControl *bankRollSegment;
@property (atomic, strong) UIButton *bankrollButton;
@property (atomic, strong) IBOutlet UIImageView *playerTypeImageView;
@property (atomic, strong) IBOutlet UIButton *top5Button;
@property (atomic, strong) IBOutlet UIButton *last10Button;
@property (nonatomic, strong) IBOutlet GameSummaryView *gameSummaryView;

@property (atomic) BOOL showMainMenuButton;
@property (atomic) BOOL fetchIsReady;

@property (atomic) int displayYear;
@property (atomic, strong) UILabel *yearLabel;
@property (atomic, strong) UIButton *leftYear;
@property (atomic, strong) UIButton *rightYear;
@property (atomic, strong) MyToolbar *yearToolbar;

- (IBAction) createPressed: (id) sender;
- (IBAction) yearGoesUp: (id) sender;
- (IBAction) yearGoesDown: (id) sender;
- (IBAction) segmentChanged:(id)sender;
- (void) computeStats;
- (IBAction) bankrollPressed: (id) sender;
- (IBAction) bankrollSegmentChanged: (id) sender;
- (IBAction) playerTypeButtonPressed: (id) sender;
- (IBAction) top5Pressed: (id) sender;
- (IBAction) last10Pressed: (id) sender;


@end
