//
//  NewGameBuyin.h
//  PokerTracker
//
//  Created by Rick Medved on 2/10/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "CustomSegment.h"


@interface NewGameBuyin : UIViewController <CLLocationManagerDelegate> {
    NSManagedObjectContext *managedObjectContext;
	IBOutlet CustomSegment *gameTypeSegmentBar;
	IBOutlet UIButton *buyinAmountButton;
	IBOutlet UIButton *continueButton;
	IBOutlet UILabel *gpslabel;
	IBOutlet UIActivityIndicatorView *activityIndicator;
	IBOutlet UILabel *locationlabel;
	IBOutlet UIButton *retryButton;
	IBOutlet UIImageView *locationLight;
	IBOutlet UIImageView *dbLight;
	
	CLLocationManager *locationManager;
	CLLocation *currentLocation;
	
	int gpsCounter;
	BOOL keepChecking;

}

- (IBAction) gameTypeSegmentPressed: (id) sender;
- (IBAction) buyinButtonPressed: (id) sender;
- (IBAction) continueButtonPressed: (id) sender;
- (IBAction) completedButtonPressed: (id) sender;
- (IBAction) retryButtonPressed: (id) sender;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) CustomSegment *gameTypeSegmentBar;
@property (nonatomic, strong) UIButton *buyinAmountButton;
@property (nonatomic, strong) UIButton *retryButton;
@property (nonatomic, strong) UIButton *continueButton;
@property (nonatomic, strong) UILabel *gpslabel;
@property (nonatomic, strong) UILabel *locationlabel;

@property (nonatomic, strong) UIImageView *locationLight;
@property (nonatomic, strong) UIImageView *dbLight;

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *currentLocation;
@property (nonatomic) int gpsCounter;
@property (nonatomic) BOOL keepChecking;


@end
