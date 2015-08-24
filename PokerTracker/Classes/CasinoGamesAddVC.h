//
//  CasinoGamesAddVC.h
//  PokerTracker
//
//  Created by Rick Medved on 1/21/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CasinoGamesAddVC : UIViewController {
	NSManagedObjectContext *managedObjectContext;
	IBOutlet UITextField *game;
	IBOutlet UITextField *limit;
	IBOutlet UITextField *stakes;
	
	IBOutlet UISegmentedControl *gameTypeSegment;
	IBOutlet UISegmentedControl *dayOfWeekSegment;
	IBOutlet UIButton *buyinAmount;
	IBOutlet UIButton *but11;
	IBOutlet UIButton *but12;
	IBOutlet UIButton *but13;
	IBOutlet UIButton *but14;
	IBOutlet UIButton *but15;
	IBOutlet UIButton *but21;
	IBOutlet UIButton *but22;
	IBOutlet UIButton *but23;
	IBOutlet UIButton *but24;
	
	IBOutlet UITextField *gameName;
	IBOutlet UILabel *buyinLabel;
	
	UIViewController *callBackViewController;
	int selectedRow;
}

- (IBAction) button11Pressed: (id) sender;
- (IBAction) button12Pressed: (id) sender;
- (IBAction) button13Pressed: (id) sender;
- (IBAction) button14Pressed: (id) sender;
- (IBAction) button15Pressed: (id) sender;

- (IBAction) button21Pressed: (id) sender;
- (IBAction) button22Pressed: (id) sender;
- (IBAction) button23Pressed: (id) sender;
- (IBAction) button24Pressed: (id) sender;

- (IBAction) button31Pressed: (id) sender;
- (IBAction) button32Pressed: (id) sender;
- (IBAction) button33Pressed: (id) sender;
- (IBAction) button34Pressed: (id) sender;
- (IBAction) button35Pressed: (id) sender;

- (IBAction) segmentClicked: (id) sender;
- (IBAction) daySegmentPressed: (id) sender;
- (IBAction) buyinButtonPressed: (id) sender;

@property (nonatomic, strong) UITextField *gameName;
@property (nonatomic, strong) UILabel *buyinLabel;


@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) UITextField *game;
@property (nonatomic, strong) UITextField *limit;
@property (nonatomic, strong) UITextField *stakes;
@property (nonatomic, strong) UIViewController *callBackViewController;
@property (nonatomic) int selectedRow;

@property (nonatomic, strong) UISegmentedControl *gameTypeSegment;
@property (nonatomic, strong) UISegmentedControl *dayOfWeekSegment;
@property (nonatomic, strong) UIButton *buyinAmount;
@property (nonatomic, strong) UIButton *but11;
@property (nonatomic, strong) UIButton *but12;
@property (nonatomic, strong) UIButton *but13;
@property (nonatomic, strong) UIButton *but14;
@property (nonatomic, strong) UIButton *but15;
@property (nonatomic, strong) UIButton *but21;
@property (nonatomic, strong) UIButton *but22;
@property (nonatomic, strong) UIButton *but23;
@property (nonatomic, strong) UIButton *but24;



@end
