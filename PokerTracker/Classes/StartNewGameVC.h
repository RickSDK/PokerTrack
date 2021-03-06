//
//  StartNewGameVC.h
//  PokerTracker
//
//  Created by Rick Medved on 10/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "TemplateVC.h"
#import "CustomSegment.h"


@interface StartNewGameVC : TemplateVC <CLLocationManagerDelegate> {
	//---Passed In----------------------------
    NSManagedObjectContext *managedObjectContext;

	//---XIB----------------------------
	IBOutlet UIActivityIndicatorView *activityIndicator;
	IBOutlet CustomSegment *gameTypeSegmentBar;
	IBOutlet CustomSegment *gameNameSegmentBar;
	IBOutlet CustomSegment *blindTypeSegmentBar;
	IBOutlet CustomSegment *limitTypeSegmentBar;
	IBOutlet CustomSegment *TourneyTypeSegmentBar;
	IBOutlet UILabel *buyinLabel;
	IBOutlet UILabel *locationLabel;
	IBOutlet UILabel *bankrollLabel;
	
	//---Gloabls----------------------------
	int selectedObjectForEdit;
	int addCasinoFlg;
	CLLocationManager *locationManager;
	CLLocation *currentLocation;

}

- (IBAction) gameTypeSegmentPressed: (id) sender;
- (IBAction) bankrollButtonPressed: (id) sender;
- (IBAction) buyinButtonPressed: (id) sender; 
- (IBAction) startButtonPressed: (id) sender;
- (IBAction) completedButtonPressed: (id) sender; 
- (IBAction) locationButtonPressed: (id) sender; 
- (IBAction) gameSegmentPressed: (id) sender;
- (IBAction) stakesSegmentPressed: (id) sender;
- (IBAction) limitSegmentPressed: (id) sender;
- (IBAction) retryButtonPressed: (id) sender;
- (IBAction) mapButtonPressed: (id) sender;
- (IBAction) viewLocationsButtonPressed: (id) sender;
- (IBAction) tournSegmentPressed: (id) sender;
- (IBAction) addCasinoButtonPressed: (id) sender;
- (IBAction) okButtonPressed: (id) sender;
-(void)setLocationValue:(NSString *)value;
- (IBAction) trackChipsSwitchPressed: (id) sender;
- (IBAction) trackChipsInfoPressed: (id) sender;


//@property (atomic, strong) NSManagedObjectContext *managedObjectContext;
@property (atomic, strong) UIActivityIndicatorView *activityIndicator;

@property (atomic, strong) CustomSegment *gameTypeSegmentBar;
@property (atomic, strong) CustomSegment *gameNameSegmentBar;
@property (atomic, strong) CustomSegment *blindTypeSegmentBar;
@property (atomic, strong) CustomSegment *limitTypeSegmentBar;
@property (atomic, strong) CustomSegment *TourneyTypeSegmentBar;

@property (atomic, strong) IBOutlet UIButton *retryButton;
@property (atomic, strong) IBOutlet UIButton *editButton;
@property (atomic, strong) IBOutlet UIButton *bankrollButton;
@property (atomic, strong) IBOutlet UIButton *buyinButton;
@property (atomic, strong) IBOutlet UIButton *startLiveButton;
@property (atomic, strong) IBOutlet UIButton *completedButton;
@property (atomic, strong) IBOutlet UIButton *completed2Button;
@property (atomic, strong) IBOutlet UIButton *locationButton;
@property (atomic, strong) IBOutlet UIButton *addCasinoButton;
@property (atomic, strong) IBOutlet UIButton *buyinPopupButton;
@property (atomic, strong) IBOutlet UIButton *chipsPopupButton;

@property (atomic, strong) IBOutlet UILabel *locationTextLabel;
@property (atomic, strong) IBOutlet UILabel *buyinPopupLabel;
@property (atomic, strong) IBOutlet UILabel *chipsPopupLabel;
@property (atomic, strong) UILabel *buyinLabel;
@property (atomic, strong) UILabel *locationLabel;
@property (atomic, strong) UILabel *bankrollLabel;

@property (atomic, strong) IBOutlet PopupView *tournyPopupView;
@property (atomic, strong) IBOutlet UIView *trackChipsView;
@property (atomic, strong) IBOutlet UISwitch *trackChipsSwitch;


@property (atomic) int selectedObjectForEdit;
@property (atomic) int addCasinoFlg;


@property (atomic, strong) CLLocationManager *locationManager;
@property (atomic, strong) CLLocation *currentLocation;

@end

