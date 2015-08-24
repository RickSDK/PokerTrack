//
//  LocationsVC.h
//  PokerTracker
//
//  Created by Rick Medved on 11/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LocationGetter.h"
#import <CoreLocation/CoreLocation.h>


@interface LocationsVC : UIViewController <CLLocationManagerDelegate> {
	//---Passed In----------------------------
	NSManagedObjectContext *managedObjectContext;

	//---XIB----------------------------
	IBOutlet UITableView *mainTableView;
	IBOutlet UIActivityIndicatorView *activityIndicator;
	IBOutlet UILabel *locationLabel;
	
	//---Gloabls----------------------------
	NSMutableArray *dataset;
	CLLocationManager *locationManager;
	CLLocation *currentLocation;
}

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *currentLocation;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) UITableView *mainTableView;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSMutableArray *dataset;

@property (nonatomic, strong) UILabel *locationLabel;


@end
