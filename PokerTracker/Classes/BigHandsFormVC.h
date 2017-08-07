//
//  BigHandsFormVC.h
//  PokerTracker
//
//  Created by Rick Medved on 10/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TemplateVC.h"
#import "BigHandObj.h"


@interface BigHandsFormVC : TemplateVC {
	//---Passed In----------------------------
    NSManagedObjectContext *managedObjectContext;
	NSManagedObject *mo;
	BOOL drilldown;
	BOOL viewEditable;

	//---XIB----------------------------
	IBOutlet UITableView *mainTableView;
	IBOutlet UIView *visualView;
	IBOutlet UIView *preflopView;
	IBOutlet UIView *flopView;
	IBOutlet UIView *turnView;
	IBOutlet UISegmentedControl *winLossSegment;
	IBOutlet UIButton *nextButton;
	IBOutlet UIButton *viewButton;
	IBOutlet UIButton *oddsButton;
	IBOutlet UIButton *deleteButton;

	//---Gloabls----------------------------
	NSMutableArray *labelValues;
	NSMutableArray *formDataArray;
	NSMutableArray *oddsDataArray;
	UIBarButtonItem *saveButton;
	int selectedRow;
	int indexPathRow;
	BOOL viewDisplayFlg;
	int viewNumber;
	int buttonNumber;


	
}

- (IBAction) viewButtonPressed: (id) sender;
- (IBAction) deleteButtonPressed: (id) sender;
- (IBAction) oddsButtonPressed: (id) sender;
-(void)setupVisualView;
- (IBAction) playButtonPressed: (id) sender;
- (IBAction) editButtonPressed: (id) sender;

@property (nonatomic) int selectedRow;
@property (nonatomic) int indexPathRow;
@property (nonatomic) int viewNumber;
@property (nonatomic) int buttonNumber;
@property (nonatomic) int numPlayers;
@property (nonatomic) BOOL drilldown;
@property (nonatomic) BOOL viewEditable;
@property (nonatomic) BOOL viewDisplayFlg;
@property (nonatomic) BOOL hideHomeButton;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) BigHandObj *bigHandObj;
@property (nonatomic, strong) NSManagedObject *mo;
@property (nonatomic, strong) UIButton *nextButton;
@property (nonatomic, strong) UIButton *viewButton;
@property (nonatomic, strong) UIButton *oddsButton;
@property (nonatomic, strong) UIButton *deleteButton;
@property (nonatomic, strong) IBOutlet UIButton *playButton;
@property (nonatomic, strong) IBOutlet UIButton *editButton;
@property (nonatomic, strong) IBOutlet UIButton *calcOddsButton;
@property (nonatomic, strong) IBOutlet UITextView *analysisTextView;
@property (nonatomic, strong) IBOutlet UIView *analysisView;

@property (nonatomic, strong) NSMutableArray *labelValues;
@property (nonatomic, strong) NSMutableArray *formDataArray;
@property (nonatomic, strong) NSMutableArray *oddsDataArray;
@property (nonatomic, strong) NSMutableArray *playersArray;
@property (nonatomic, strong) UITableView *mainTableView;
@property (nonatomic, strong) UISegmentedControl *winLossSegment;

@property (nonatomic, strong) UIBarButtonItem *saveButton;
@property (nonatomic, strong) UIView *visualView;
@property (nonatomic, strong) UIView *preflopView;
@property (nonatomic, strong) UIView *flopView;
@property (nonatomic, strong) UIView *turnView;




@end
