//
//  FiltersVC.h
//  PokerTracker
//
//  Created by Rick Medved on 11/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TemplateVC.h"


@interface FiltersVC : TemplateVC {
 	//---Passed In----------------------------
	NSManagedObjectContext *managedObjectContext;
	NSManagedObject *filterObj;
	int displayYear;
	NSString *gameType;

	//---XIB----------------------------
	IBOutlet UITableView *mainTableView;
	IBOutlet CustomSegment *gameSegment;
	IBOutlet CustomSegment *customSegment;
	IBOutlet UIImageView *activityBGView;
	IBOutlet UIImageView *chartImageView;
	IBOutlet UIActivityIndicatorView *activityIndicator;
	IBOutlet UILabel *yearLabel;
	IBOutlet UILabel *currentFilterLabel;
	IBOutlet UILabel *timeFramLabel;
	IBOutlet UILabel *messageLabel;
	IBOutlet UIButton *leftYear;
	IBOutlet UIButton *rightYear;
	IBOutlet UIToolbar *yearToolbar;

	//---Gloabls----------------------------
	NSMutableArray *labelValues;
	NSMutableArray *displayLabelValues;
	NSMutableArray *statsArray;
	NSMutableArray *formDataArray;
	NSMutableArray *gamesList;
	int selectedFieldIndex;
	int buttonNum;
	BOOL displayBySession;
	BOOL viewLocked;
	
	
}

//-(void)setFilterIndex:(int)row_id;
-(void)chooseFilterObj:(NSManagedObject *)mo;

-(void) computeStats;
-(void)initializeFormData;
-(BOOL)saveNewFilter:(NSString *)valueCombo;
-(IBAction)saveButtonPressed:(id)sender;
-(IBAction)viewButtonPressed:(id)sender;
-(IBAction)popupSaveButtonPressed:(id)sender;
-(IBAction)deleteButtonPressed:(id)sender;

@property (atomic, strong) UILabel *currentFilterLabel;
@property (atomic, strong) UILabel *timeFramLabel;
@property (atomic, strong) NSMutableArray *gamesList;
@property (atomic, strong) NSManagedObject *filterObj;
@property (atomic) int selectedFieldIndex;
@property (atomic) BOOL displayBySession;
@property (atomic) BOOL viewLocked;
@property (atomic, strong) CustomSegment *gameSegment;
@property (atomic, strong) CustomSegment *customSegment;

@property (atomic) int displayYear;
@property (atomic) int buttonNum;

@property (atomic, strong) UILabel *yearLabel;
@property (atomic, strong) UILabel *messageLabel;
@property (atomic, strong) UIButton *leftYear;
@property (atomic, strong) UIButton *rightYear;

@property (atomic, strong) UIImageView *activityBGView;
@property (atomic, strong) UIImageView *chartImageView;
@property (atomic, strong) UIActivityIndicatorView *activityIndicator;

@property (atomic, strong) NSMutableArray *labelValues;
@property (atomic, strong) NSMutableArray *displayLabelValues;
@property (atomic, strong) NSMutableArray *statsArray;
@property (atomic, strong) NSMutableArray *formDataArray;
@property (atomic, copy) NSString *gameType;
@property (atomic, strong) UIToolbar *yearToolbar;

@property (atomic, strong) IBOutlet UIButton *saveButton;
@property (atomic, strong) IBOutlet UIButton *viewButton;
@property (atomic, strong) IBOutlet PopupView *saveView;
@property (atomic, strong) IBOutlet UIButton *popupSaveButton;
@property (atomic, strong) IBOutlet UIButton *deleteButton;


@end
