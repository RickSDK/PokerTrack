//
//  FilterListVC.h
//  PokerTracker
//
//  Created by Rick Medved on 11/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TemplateVC.h"


@interface FilterListVC : TemplateVC {
	//---Passed In----------------------------
	NSManagedObjectContext *managedObjectContext;
	NSManagedObject *filterObj;
	UIViewController *callBackViewController;
    IBOutlet UITableView *mainTableView;
    IBOutlet UIButton *detailsButton;
    IBOutlet UIButton *editButton;
    IBOutlet UISegmentedControl *filterSegment;
    
    BOOL editMode;
	int selectedRowId;
	int selectedButton;
	int maxFilterId;

	//---Gloabls----------------------------
	NSMutableArray *filterList;

}

- (void)reloadView;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSManagedObject *filterObj;
@property (nonatomic, strong) UIViewController *callBackViewController;
@property (nonatomic, strong) NSMutableArray *filterList;
@property (nonatomic, strong) UITableView *mainTableView;
@property (nonatomic, strong) UISegmentedControl *filterSegment;
@property (nonatomic, strong) UIButton *detailsButton;
@property (nonatomic, strong) UIButton *editButton;
@property (nonatomic) BOOL editMode;
@property (nonatomic) int selectedRowId;
@property (nonatomic) int selectedButton;
@property (nonatomic) int maxFilterId;


- (IBAction) detailsButtonPressed: (id) sender;
- (IBAction) editButtonPressed: (id) sender;


@end
