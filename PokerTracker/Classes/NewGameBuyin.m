//
//  NewGameBuyin.m
//  PokerTracker
//
//  Created by Rick Medved on 2/10/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "NewGameBuyin.h"
#import "StartNewGameVC.h"
#import "ProjectFunctions.h"
#import "MoneyPickerVC.h"
#import "CreateOldGameVC.h"
#import "WebServicesFunctions.h"


@implementation NewGameBuyin
@synthesize managedObjectContext, gameTypeSegmentBar, buyinAmountButton, gpslabel, dbLight, locationLight;
@synthesize locationManager, currentLocation, gpsCounter, keepChecking, locationlabel, activityIndicator, retryButton, continueButton;


// Delegate method from the CLLocationManagerDelegate protocol.
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
		   fromLocation:(CLLocation *)oldLocation
{
	{// diagnostics
		NSLog(@"entering...");
		NSMutableString *update = [[NSMutableString alloc] init];
		
		// Timestamp
		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
		[dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
		[update appendFormat:@"%@\n\n", [dateFormatter stringFromDate:newLocation.timestamp]];
		
		// Horizontal coordinates
		if (signbit(newLocation.horizontalAccuracy)) {
			// Negative accuracy means an invalid or unavailable measurement
			[update appendString:(@"Latitude / Longitude unavailable")];
		} else {
			// CoreLocation returns positive for North & East, negative for South & West
			[update appendFormat:(@"Location: %.4f° %@, %.4f° %@"), // This format takes 4 args: 2 pairs of the form coordinate + compass direction
			 fabs(newLocation.coordinate.latitude), signbit(newLocation.coordinate.latitude) ? (@"South") : (@"North"),
			 fabs(newLocation.coordinate.longitude),	signbit(newLocation.coordinate.longitude) ? (@"West") : (@"East")];
			[update appendString:@"\n"];
			[update appendFormat:(@"(accuracy %.0f meters)"), newLocation.horizontalAccuracy];
		}
		[update appendString:@"\n\n"];
		
		// Altitude
		if (signbit(newLocation.verticalAccuracy)) {
			// Negative accuracy means an invalid or unavailable measurement
			[update appendString:(@"AltUnavailable")];
		} else {
			// Positive and negative in altitude denote above & below sea level, respectively
			[update appendFormat:(@"Altitude: %.2f meters %@"), fabs(newLocation.altitude),	(signbit(newLocation.altitude)) ? (@"BelowSeaLevel") : (@"AboveSeaLevel")];
			[update appendString:@"\n"];
			[update appendFormat:(@"(accuracy %.0f meters)"), newLocation.verticalAccuracy];
		}
		NSLog(@"%@", update);
	}
	
    // If it's a relatively recent event, turn off updates to save power
    NSDate* eventDate = newLocation.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    if (abs(howRecent) < 5.0)
    {
 //       [manager stopUpdatingLocation];
		
		self.currentLocation = newLocation;
		
        NSLog(@"latitude %+.6f, longitude %+.6f\n",
			  newLocation.coordinate.latitude,
			  newLocation.coordinate.longitude);
    }
    // else skip the event and process the next one.
}


- (IBAction) gameTypeSegmentPressed: (id) sender
{
	[gameTypeSegmentBar changeSegment];
	NSString *buyinAmount = @"";
	if(gameTypeSegmentBar.selectedSegmentIndex==0) {
		[ProjectFunctions setUserDefaultValue:@"Cash" forKey:@"gameTypeDefault"];
		buyinAmount = [ProjectFunctions getUserDefaultValue:@"buyinDefault"];
	} else {
		[ProjectFunctions setUserDefaultValue:@"Tournament" forKey:@"gameTypeDefault"];
		buyinAmount = [ProjectFunctions getUserDefaultValue:@"tournbuyinDefault"];
	}
	[buyinAmountButton setTitle:[NSString stringWithFormat:@"%@%@", [ProjectFunctions getMoneySymbol], buyinAmount] forState:UIControlStateNormal];
}

- (IBAction) buyinButtonPressed: (id) sender
{
	MoneyPickerVC *detailViewController = [[MoneyPickerVC alloc] initWithNibName:@"MoneyPickerVC" bundle:nil];
	detailViewController.managedObjectContext=managedObjectContext;
	detailViewController.callBackViewController = self;
	detailViewController.titleLabel = @"Buy-in";
	detailViewController.initialDateValue = [NSString stringWithFormat:@"%@", buyinAmountButton.titleLabel.text];
	[self.navigationController pushViewController:detailViewController animated:YES];
}

- (IBAction) continueButtonPressed: (id) sender
{
	self.keepChecking=NO;
	StartNewGameVC *detailViewController = [[StartNewGameVC alloc] initWithNibName:@"StartNewGameVC" bundle:nil];
	detailViewController.managedObjectContext = managedObjectContext;
	[self.navigationController pushViewController:detailViewController animated:YES];
}

- (IBAction) retryButtonPressed: (id) sender
{
	[locationManager startUpdatingLocation];
	[activityIndicator startAnimating];
	retryButton.enabled=NO;
	continueButton.enabled=NO;
	locationlabel.text=@"Searching...";
	[self executeThreadedJob:@selector(checkCurrentLocation)];
}

- (IBAction) completedButtonPressed: (id) sender
{
	self.keepChecking=NO;
	CreateOldGameVC *detailViewController = [[CreateOldGameVC alloc] initWithNibName:@"CreateOldGameVC" bundle:nil];
	detailViewController.managedObjectContext = managedObjectContext;
	[self.navigationController pushViewController:detailViewController animated:YES];
}

-(void)executeThreadedJob:(SEL)aSelector
{
	[self performSelectorInBackground:aSelector withObject:nil];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if([self respondsToSelector:@selector(edgesForExtendedLayout)])
        [self setEdgesForExtendedLayout:UIRectEdgeBottom];
}


-(void)checkLocManager
{
	@autoreleasepool {
		[NSThread sleepForTimeInterval:1];
		if(currentLocation) {
			locationLight.image = [UIImage imageNamed:@"yellow.png"];
			dbLight.image = [UIImage imageNamed:@"yellow.png"];
		}
	}
}

-(void)checkCurrentLocation
{
	@autoreleasepool {
		[NSThread sleepForTimeInterval:3];
		
		self.gpsCounter++;

		NSString *gpslabelText=[NSString stringWithFormat:@"Lat: %.4f    Lng: %.4f", currentLocation.coordinate.latitude, currentLocation.coordinate.longitude];
		[gpslabel performSelectorOnMainThread:@selector(setText: ) withObject:gpslabelText waitUntilDone:YES];
		[locationlabel performSelectorOnMainThread:@selector(setText: ) withObject:[ProjectFunctions getBestLocation:currentLocation MoC:managedObjectContext] waitUntilDone:YES];
		
		
		[activityIndicator stopAnimating];
		[locationManager stopUpdatingHeading];
		[locationManager stopUpdatingLocation];
		
		retryButton.enabled=YES;
		continueButton.enabled=YES;

	}
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[self setTitle:@"New Game"];
    [super viewDidLoad];
	
	self.gpsCounter=0;
	self.keepChecking=YES;
	
	NSString *gameType = [ProjectFunctions getUserDefaultValue:@"gameTypeDefault"];
	if([gameType isEqualToString:@"Tournament"]) {
		gameTypeSegmentBar.selectedSegmentIndex=1;
		[buyinAmountButton setTitle:[NSString stringWithFormat:@"%@%@", [ProjectFunctions getMoneySymbol], [ProjectFunctions getUserDefaultValue:@"tournbuyinDefault"]] forState:UIControlStateNormal];
	} else {
		[buyinAmountButton setTitle:[NSString stringWithFormat:@"%@%@", [ProjectFunctions getMoneySymbol], [ProjectFunctions getUserDefaultValue:@"buyinDefault"]] forState:UIControlStateNormal];
	}


	self.locationManager = [[CLLocationManager alloc] init];
	self.locationManager.delegate = self;
	self.locationManager.distanceFilter = kCLDistanceFilterNone;
	self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
	
	if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
		[self.locationManager requestWhenInUseAuthorization];
		[self.locationManager startMonitoringSignificantLocationChanges];
	}
	[self.locationManager startUpdatingLocation];
	
	retryButton.enabled=NO;
	continueButton.enabled=NO;
	[activityIndicator startAnimating];
	[self executeThreadedJob:@selector(checkCurrentLocation)];
	
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
	[ProjectFunctions ptpLocationAuthorizedCheck:status];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
	NSLog(@"+++didUpdateLocations!!");
	self.currentLocation = [locations lastObject];
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
	NSLog(@"%@", error.localizedDescription);
}


-(void) setReturningValue:(NSString *) value {
	
	[buyinAmountButton setTitle:[NSString stringWithFormat:@"%@%@", [ProjectFunctions getMoneySymbol], value] forState:UIControlStateNormal];
	NSString *gameType = [ProjectFunctions getUserDefaultValue:@"gameTypeDefault"];
	if([gameType isEqualToString:@"Tournament"])
		[ProjectFunctions setUserDefaultValue:value forKey:@"tournbuyinDefault"];
	else 
		[ProjectFunctions setUserDefaultValue:value forKey:@"buyinDefault"];
	
}




- (void)viewDidUnload {
    [super viewDidUnload];
	self.keepChecking=NO;
	[locationManager stopUpdatingLocation];
	self.locationManager=nil;
	self.currentLocation=nil;
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}




@end
