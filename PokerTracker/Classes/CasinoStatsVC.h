//
//  CasinoStatsVC.h
//  PokerTracker
//
//  Created by Rick Medved on 1/24/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>


@interface CasinoStatsVC : UIViewController {
	NSManagedObjectContext *managedObjectContext;
	IBOutlet UIActivityIndicatorView *activityIndicator;
	IBOutlet UITableView *mainTableView;

	NSMutableArray *statsArray;
	CLLocation *currentLocation;
}

- (IBAction) goHomePressed: (id) sender;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) UITableView *mainTableView;
@property (nonatomic, strong) NSMutableArray *statsArray;
@property (nonatomic, strong) CLLocation *currentLocation;

@end
