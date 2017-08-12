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

	//---XIB----------------------------
	IBOutlet UITableView *mainTableView;

	//---Gloabls----------------------------
	NSMutableArray *gamesList;

}

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (atomic, strong) NSMutableArray *gamesList;
@property (atomic, strong) IBOutlet UIImageView *playerTypeImageView;
@property (atomic, strong) IBOutlet UIButton *top5Button;
@property (atomic, strong) IBOutlet UIButton *last10Button;
@property (nonatomic, strong) IBOutlet GameSummaryView *gameSummaryView;

@property (atomic) BOOL fetchIsReady;

- (IBAction) createPressed: (id) sender;
- (IBAction) segmentChanged:(id)sender;
- (void) computeStats;
- (IBAction) top5Pressed: (id) sender;
- (IBAction) last10Pressed: (id) sender;


@end
