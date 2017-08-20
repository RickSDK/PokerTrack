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
	BOOL isCalculating;
	BOOL preFlopStillWorking;
	BOOL postFlopStillWorking;
	BOOL turnStillWorking;
	BOOL boardFilledOut;
	

	
}

-(void)completeWithRandomCards;
-(void) setReturningValue:(NSString *) value2;
- (IBAction) clearButtonPressed: (UIButton *) button;
- (IBAction) randomButtonPressed: (UIButton *) button;
- (IBAction) calculateButtonPressed: (UIButton *) button;

@property (atomic, strong) NSMutableArray *labelValues;
@property (atomic, strong) NSMutableArray *formDataArray;
@property (atomic) int numPlayers;
@property (atomic) int selectedRow;
@property (atomic) int highHandValue;
@property (atomic) int numberOfPreflopHandsProcessed;
@property (atomic) BOOL postFlopStillWorking;
@property (atomic) BOOL isCalculating;
@property (atomic) BOOL preFlopStillWorking;
@property (atomic) BOOL turnStillWorking;
@property (atomic) BOOL boardFilledOut;
@property (atomic) BOOL doneCalculating;
@property (nonatomic, strong) UITableView *mainTableView;
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

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) IBOutlet UIButton *clearButton;
@property (nonatomic, strong) IBOutlet UIButton *randomButton;
@property (nonatomic, strong) IBOutlet UIButton *calculateBotButton;

@property (atomic, strong) NSManagedObject *mo;

@end
