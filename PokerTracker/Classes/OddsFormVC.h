//
//  OddsFormVC.h
//  PokerTracker
//
//  Created by Rick Medved on 10/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TemplateVC.h"


@interface OddsFormVC : TemplateVC {
	//---Passed In----------------------------
    NSManagedObjectContext *managedObjectContext;
	NSManagedObject *mo;
	NSArray *preLoaedValues;
	int numPlayers;

	//---XIB----------------------------
	IBOutlet UIActivityIndicatorView *activityView;
	IBOutlet UILabel *activityLabel;
	IBOutlet UIProgressView *progressView;
	IBOutlet UIImageView *activityPopup;
	IBOutlet UITableView *mainTableView;

	//---Gloabls----------------------------
	NSMutableArray *labelValues;
	UIBarButtonItem *calculateButton;
	UIBarButtonItem *leftButton;
	
	NSMutableArray *playerPreFlopResults;
	NSMutableArray *playerFlopResults;
	NSMutableArray *playerTurnResults;
	NSMutableArray *playerWinResults;
	NSMutableArray *formDataArray;
	
	int selectedRow;
	int highHandValue;
	int numberOfPreflopHandsProcessed;
	BOOL startedCalculating;
	BOOL doneCalculating;
	BOOL postFlopStillWorking;
	BOOL boardFilledOut;
	

	
}

-(void)completeWithRandomCards;
-(void) setReturningValue:(NSString *) value2;

@property (atomic, strong) NSMutableArray *labelValues;
@property (atomic, strong) NSMutableArray *formDataArray;
@property (atomic) int numPlayers;
@property (atomic) int selectedRow;
@property (atomic) int highHandValue;
@property (atomic) int numberOfPreflopHandsProcessed;
@property (atomic) BOOL postFlopStillWorking;
@property (atomic) BOOL startedCalculating;
@property (atomic) BOOL doneCalculating;
@property (atomic) BOOL boardFilledOut;
@property (atomic, strong) UITableView *mainTableView;
@property (atomic, strong) UIBarButtonItem *calculateButton;
@property (atomic, strong) UIBarButtonItem *leftButton;

@property (atomic, strong) NSMutableArray *playerPreFlopResults;
@property (atomic, strong) NSMutableArray *playerFlopResults;
@property (atomic, strong) NSMutableArray *playerTurnResults;
@property (atomic, strong) NSMutableArray *playerWinResults;

@property (atomic, strong) UIActivityIndicatorView *activityView;
@property (atomic, strong) UILabel *activityLabel;
@property (atomic, strong) UIProgressView *progressView;
@property (atomic, strong) UIImageView *activityPopup;

@property (atomic, copy) NSArray *preLoaedValues;

@property (atomic, strong) NSManagedObjectContext *managedObjectContext;
@property (atomic, strong) NSManagedObject *mo;

@end
