//
//  PlayerTrackerVC.h
//  PokerTracker
//
//  Created by Rick Medved on 1/16/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LocationGetter.h"
#import <CoreLocation/CoreLocation.h>


@interface PlayerTrackerVC : UIViewController <CLLocationManagerDelegate> {
	NSManagedObjectContext *managedObjectContext;
	IBOutlet UITableView *mainTableView;
	IBOutlet UIButton *locationButton;
	int selectedObjectForEdit;
	IBOutlet UIActivityIndicatorView *activityIndicator;
	IBOutlet UILabel *latLngLabel;

	CLLocationManager *locationManager;
	CLLocation *currentLocation;

	NSMutableArray *playerList;
}

- (IBAction) locationButtonPressed: (id) sender;
- (IBAction) allButtonPressed: (id) sender;
-(void)reloadData;

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *currentLocation;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) UITableView *mainTableView;
@property (nonatomic, strong) UIButton *locationButton;
@property (nonatomic, strong) NSMutableArray *playerList;
@property (nonatomic) int selectedObjectForEdit;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) UILabel *latLngLabel;

@end
