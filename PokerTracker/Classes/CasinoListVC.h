//
//  CasinoListVC.h
//  PokerTracker
//
//  Created by Rick Medved on 1/25/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "TemplateVC.h"


@interface CasinoListVC : TemplateVC {
	NSManagedObjectContext *managedObjectContext;
	IBOutlet UIActivityIndicatorView *activityIndicator;
	IBOutlet UITableView *mainTableView;
	IBOutlet UILabel *topLabel;
	
	NSString *stateCountry;
	CLLocation *currentLocation;
	NSMutableArray *statsArray;
}

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) UITableView *mainTableView;
@property (nonatomic, strong) NSMutableArray *statsArray;
@property (nonatomic, strong) UILabel *topLabel;
@property (nonatomic, strong) NSString *stateCountry;
@property (nonatomic, strong) CLLocation *currentLocation;

@end
