//
//  CasinoTrackerVC.h
//  PokerTracker
//
//  Created by Rick Medved on 1/17/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LocationGetter.h"
#import <CoreLocation/CoreLocation.h>
#import "CustomSegment.h"
#import "TemplateVC.h"


@interface CasinoTrackerVC : TemplateVC <CLLocationManagerDelegate> {
	NSManagedObjectContext *managedObjectContext;
	IBOutlet UIButton *locateButton;
	IBOutlet CustomSegment *distanceSegment;
	CLLocationManager *locationManager;
	CLLocation *currentLocation;
	IBOutlet UIActivityIndicatorView *activityIndicator;
	IBOutlet UIImageView *activityPopup;
	IBOutlet UILabel *activityLabel;
	IBOutlet UITableView *mainTableView;
	
	IBOutlet UILabel *latitudeLabel;
	IBOutlet UILabel *lngLabel;

	IBOutlet UIButton *viewButton;
	IBOutlet UILabel *recordsLabel;
	IBOutlet UIProgressView *progressView;
	
	IBOutlet UIBarButtonItem *nameBut;
	IBOutlet UIBarButtonItem *distBut;

	
	NSMutableArray *casinoArray;
	NSMutableArray *casinoDistArray;
	NSMutableArray *casinoNameArray;
    NSString *latestCasino;
	
	int progress;
	BOOL currentLyLookingFlg;
	

}

- (IBAction) locatePressed: (id) sender;
- (IBAction) viewPressed: (id) sender;
- (IBAction) goHomePressed: (id) sender;
- (IBAction) sortByNamePressed: (id) sender;
- (IBAction) sortByDistPressed: (id) sender;
- (IBAction) segmentPressed: (id) sender;
- (IBAction) latestPressed: (id) sender;

@property (atomic, strong) UIBarButtonItem *nameBut;
@property (atomic, strong) UIBarButtonItem *distBut;
@property (atomic, strong) NSMutableArray *casinoArray;
@property (atomic, strong) NSMutableArray *casinoDistArray;
@property (atomic, strong) NSMutableArray *casinoNameArray;
@property (atomic, strong) UIButton *locateButton;
@property (atomic, strong) CLLocationManager *locationManager;
@property (atomic, strong) CLLocation *currentLocation;
@property (atomic, strong) UIActivityIndicatorView *activityIndicator;
@property (atomic, strong) UIImageView *activityPopup;
@property (atomic, strong) UILabel *activityLabel;
@property (atomic, strong) UISegmentedControl *distanceSegment;
@property (atomic, strong) UILabel *latitudeLabel;
@property (atomic, strong) UILabel *lngLabel;
@property (atomic, strong) UILabel *recordsLabel;
@property (atomic, strong) UIButton *viewButton;
@property (atomic, strong) UIProgressView *progressView;
@property (atomic) int progress;
@property (atomic) BOOL currentLyLookingFlg;
@property (atomic, copy) NSString *latestCasino;




@end
