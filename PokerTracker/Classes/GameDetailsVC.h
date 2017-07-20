//
//  GameDetailsVC.h
//  PokerTracker
//
//  Created by Rick Medved on 10/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GameObj.h"
#import "TemplateVC.h"


@interface GameDetailsVC : TemplateVC {
	//---Passed In----------------------------
	NSManagedObject *mo;
	BOOL viewEditable;

	//---XIB----------------------------
	IBOutlet UIButton *doneButton;
	IBOutlet UILabel *topProgressLabel;
	IBOutlet UIBarButtonItem *saveEditButton;
	IBOutlet UIActivityIndicatorView *activityIndicatorServer;
	IBOutlet UIImageView *textViewBG;
	IBOutlet UILabel *activityLabel;

	IBOutlet UIButton *graphButton;
	IBOutlet UILabel *dateLabel;
	IBOutlet UILabel *timeLabel;
	IBOutlet UILabel *amountLabel;

	//---Gloabls----------------------------
	NSMutableArray *labelValues;
	NSMutableArray *labelTypes;
	NSMutableArray *formDataArray;
	NSMutableArray *detailItems;
	int selectedFieldIndex;
	BOOL changesMade;
	int buttonForm;

}

- (IBAction) deleteButtonPressed: (id) sender;

@property (atomic, strong) NSMutableArray *formDataArray;
@property (atomic, strong) NSMutableArray *labelValues;
@property (atomic, strong) NSMutableArray *labelTypes;
@property (atomic, strong) NSMutableArray *detailItems;

@property (atomic, strong) UIButton *doneButton;
@property (atomic, strong) UILabel *topProgressLabel;
@property (atomic, strong) UIBarButtonItem *saveEditButton;
@property (atomic) BOOL viewEditable;
@property (atomic) BOOL changesMade;
@property (atomic) int buttonForm;
@property (atomic) int selectedFieldIndex;

@property (atomic, strong) NSManagedObject *mo;

@property (atomic, strong) UIActivityIndicatorView *activityIndicatorServer;
@property (atomic, strong) UIImageView *textViewBG;
@property (atomic, strong) UILabel *activityLabel;

@property (atomic, strong) UIButton *graphButton;
@property (atomic, strong) IBOutlet UIButton *deleteButton;
@property (atomic, strong) UILabel *dateLabel;
@property (atomic, strong) UILabel *timeLabel;
@property (atomic, strong) UILabel *amountLabel;




@end
