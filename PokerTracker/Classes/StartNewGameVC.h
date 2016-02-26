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
	IBOutlet UISegmentedControl *gameNameSegmentBar;
	IBOutlet UISegmentedControl *blindTypeSegmentBar;
	IBOutlet UISegmentedControl *limitTypeSegmentBar;
	IBOutlet UISegmentedControl *TourneyTypeSegmentBar;
	IBOutlet UIButton *editButton;
	IBOutlet UIButton *bankrollButton;
	IBOutlet UIButton *buyinButton;
	IBOutlet UIButton *startLiveButton;
	IBOutlet UIButton *completedButton;
	IBOutlet UIButton *locationButton;
	IBOutlet UILabel *buyinLabel;
	
	//---Gloabls----------------------------
	int selectedObjectForEdit;
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
-(void)setLocationValue:(NSString *)value;


//@property (atomic, strong) NSManagedObjectContext *managedObjectContext;
@property (atomic, strong) UIActivityIndicatorView *activityIndicator;

@property (atomic, strong) UISegmentedControl *gameTypeSegmentBar;
@property (atomic, strong) UISegmentedControl *gameNameSegmentBar;
@property (atomic, strong) UISegmentedControl *blindTypeSegmentBar;
@property (atomic, strong) UISegmentedControl *limitTypeSegmentBar;
@property (atomic, strong) UISegmentedControl *TourneyTypeSegmentBar;

@property (atomic, strong) UIButton *editButton;
@property (atomic, strong) UILabel *buyinLabel;
@property (atomic, strong) UIButton *bankrollButton;
@property (atomic, strong) UIButton *buyinButton;
@property (atomic, strong) UIButton *startLiveButton;
@property (atomic, strong) UIButton *completedButton;
@property (atomic, strong) UIButton *locationButton;

@property (atomic) int selectedObjectForEdit;

@property (atomic, strong) CLLocationManager *locationManager;
@property (atomic, strong) CLLocation *currentLocation;

@end

