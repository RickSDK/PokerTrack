//
//  ViewLocationsVC.h
//  PokerTracker
//
//  Created by Rick Medved on 7/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "TemplateVC.h"

@interface ViewLocationsVC : TemplateVC {
    NSManagedObjectContext *managedObjectContext;
	UIViewController *callBackViewController;

	IBOutlet UIActivityIndicatorView *activityIndicator;
	IBOutlet UILabel *activityLabel;
	IBOutlet UIImageView *activityPopup;
	IBOutlet UITableView *mainTableView;

    NSMutableArray *deviceLocs;
    NSMutableArray *serverLocs;
 	CLLocation *currentLocation;
   
}

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) UIViewController *callBackViewController;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) UIImageView *activityPopup;
@property (nonatomic, strong) UILabel *activityLabel;
@property (nonatomic, strong) UITableView *mainTableView;

@property (nonatomic, strong) NSMutableArray *deviceLocs;
@property (nonatomic, strong) NSMutableArray *serverLocs;
@property (nonatomic, strong) CLLocation *currentLocation;




@end
