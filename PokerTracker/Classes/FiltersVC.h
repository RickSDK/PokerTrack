//
//  FiltersVC.h
//  PokerTracker
//
//  Created by Rick Medved on 11/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface FiltersVC : UIViewController {
 	//---Passed In----------------------------
	NSManagedObjectContext *managedObjectContext;
	int displayYear;
	NSString *gameType;

	//---XIB----------------------------
	IBOutlet UITableView *mainTableView;
	IBOutlet UISegmentedControl *gameSegment;
	IBOutlet UISegmentedControl *customSegment;
	IBOutlet UIImageView *activityBGView;
	IBOutlet UIImageView *chartImageView;
	IBOutlet UIActivityIndicatorView *activityIndicator;
	IBOutlet UILabel *yearLabel;
	IBOutlet UIButton *leftYear;
	IBOutlet UIButton *rightYear;
	IBOutlet UIToolbar *yearToolbar;

	//---Gloabls----------------------------
	NSMutableArray *labelValues;
	NSMutableArray *statsArray;
	NSMutableArray *formDataArray;
	NSMutableArray *gamesList;
	int selectedFieldIndex;
	BOOL displayBySession;
	BOOL viewLocked;
	
	
}

-(void)setFilterIndex:(int)row_id;

- (IBAction) yearSegmentPressed: (id) sender;
- (IBAction) gameSegmentPressed: (id) sender;
- (IBAction) customSegmentPressed: (id) sender;
- (IBAction) yearGoesDown: (id) sender;
- (IBAction) yearGoesUp: (id) sender;
-(void) computeStats;
-(void)initializeFormData;
-(BOOL)saveNewFilter:(NSString *)valueCombo;

@property (atomic, strong) NSMutableArray *gamesList;
@property (atomic, strong) NSManagedObjectContext *managedObjectContext;
@property (atomic) int selectedFieldIndex;
@property (atomic) BOOL displayBySession;
@property (atomic) BOOL viewLocked;
@property (atomic, strong) UITableView *mainTableView;
@property (atomic, strong) UISegmentedControl *gameSegment;
@property (atomic, strong) UISegmentedControl *customSegment;

@property (atomic) int displayYear;
@property (atomic, strong) UILabel *yearLabel;
@property (atomic, strong) UIButton *leftYear;
@property (atomic, strong) UIButton *rightYear;

@property (atomic, strong) UIImageView *activityBGView;
@property (atomic, strong) UIImageView *chartImageView;
@property (atomic, strong) UIActivityIndicatorView *activityIndicator;

@property (atomic, strong) NSMutableArray *labelValues;
@property (atomic, strong) NSMutableArray *statsArray;
@property (atomic, strong) NSMutableArray *formDataArray;
@property (atomic, copy) NSString *gameType;
@property (atomic, strong) UIToolbar *yearToolbar;

@end
