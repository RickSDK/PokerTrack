//
//  CasinoTrackerEditVC.h
//  PokerTracker
//
//  Created by Rick Medved on 1/18/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LocationGetter.h"
#import <CoreLocation/CoreLocation.h>
#import "TemplateVC.h"


@interface CasinoTrackerEditVC : TemplateVC {
	NSManagedObjectContext *managedObjectContext;
	IBOutlet UITextField *casinoName;
	IBOutlet UIButton *locationButton;
	IBOutlet UIButton *addressButton;
	
	IBOutlet UISegmentedControl *casinoType;
	IBOutlet UIButton *checkbox;
	
	BOOL indianCasino;
	BOOL cityFound;
	CLLocation *currentLocation;

	IBOutlet UIImageView *activityBGView;
	IBOutlet UIActivityIndicatorView *activityIndicator;
	IBOutlet UILabel *activityLabel;
	IBOutlet UILabel *latLabel;
	IBOutlet UILabel *cityLabel;
	
	IBOutlet UILabel *gpsTextView;
	
	NSString *addressString;
	
}

- (IBAction) checkboxPressed: (id) sender;
- (IBAction) addressPressed: (id) sender;
- (IBAction) locationPressed: (id) sender;
- (IBAction) refreshPressed: (id) sender;


@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) UITextField *casinoName;
@property (nonatomic, strong) UIButton *locationButton;
@property (nonatomic, strong) UIButton *addressButton;
@property (nonatomic, strong) UISegmentedControl *casinoType;
@property (nonatomic, strong) UIButton *checkbox;
@property (nonatomic, strong) CLLocation *currentLocation;
@property (nonatomic) BOOL indianCasino;
@property (nonatomic) BOOL cityFound;

@property (nonatomic, strong) UIImageView *activityBGView;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) UILabel *activityLabel;
@property (nonatomic, strong) UILabel *latLabel;
@property (nonatomic, strong) UILabel *cityLabel;
@property (nonatomic, strong) UILabel *gpsTextView;
@property (nonatomic, strong) NSString *addressString;


@end
