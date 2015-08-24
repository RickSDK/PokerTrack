//
//  LocationsVC.m
//  PokerTracker
//
//  Created by Rick Medved on 11/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LocationsVC.h"
#import "MultiLineDetailCellWordWrap.h"
#import "CoreDataLib.h"
#import "ProjectFunctions.h"
#import "LocationsEdit.h"


@implementation LocationsVC
@synthesize managedObjectContext;
@synthesize dataset, locationLabel, locationManager, currentLocation, activityIndicator, mainTableView;


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
        [manager stopUpdatingLocation];
		
		self.currentLocation = newLocation;
		

        NSLog(@"latitude %+.6f, longitude %+.6f\n",
			  newLocation.coordinate.latitude,
			  newLocation.coordinate.longitude);
    }
    // else skip the event and process the next one.
}

-(void)checkCurrentLocation
{
	@autoreleasepool {
		[NSThread sleepForTimeInterval:4];

		if(currentLocation==nil)
			[ProjectFunctions showAlertPopup:@"GPS Error" message:@"Sorry, unable to locate your current position. Make sure you have GPS turned on."];
		
		locationLabel.text = [ProjectFunctions getBestLocation:currentLocation MoC:managedObjectContext];
		
		[locationManager stopUpdatingLocation];
		[activityIndicator stopAnimating];
		[mainTableView reloadData];
	}
}

-(void)executeThreadedJob:(SEL)aSelector
{
	[activityIndicator startAnimating];
	[self performSelectorInBackground:aSelector withObject:nil];
}

-(void)editButtonClicked:(id)sender {
	LocationsEdit *localViewController = [[LocationsEdit alloc] initWithNibName:@"LocationsEdit" bundle:nil];
	localViewController.managedObjectContext=managedObjectContext;
	[self.navigationController pushViewController:localViewController animated:YES];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if([self respondsToSelector:@selector(edgesForExtendedLayout)])
        [self setEdgesForExtendedLayout:UIRectEdgeBottom];
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	[self setTitle:@"Locations"];
    
    [self.mainTableView setBackgroundView:nil];

	
	dataset = [[NSMutableArray alloc] initWithArray:[CoreDataLib selectRowsFromTable:@"LOCATION" mOC:managedObjectContext]];
	
	UIBarButtonItem *menuButton2 = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStylePlain target:self action:@selector(editButtonClicked:)];
	self.navigationItem.rightBarButtonItem = menuButton2;
	
	
	self.locationManager = [[CLLocationManager alloc] init];
	self.locationManager.delegate = self;
	self.locationManager.distanceFilter = kCLDistanceFilterNone;
	self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
	
	if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
		[self.locationManager requestWhenInUseAuthorization];
		[self.locationManager startMonitoringSignificantLocationChanges];
	}
	[self.locationManager startUpdatingLocation];

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


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return [dataset count]*18+25;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
    
	NSString *cellIdentifier = [NSString stringWithFormat:@"cellIdentifierSection%dRow%d", indexPath.section, indexPath.row];
	MultiLineDetailCellWordWrap *cell = (MultiLineDetailCellWordWrap *) [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (cell == nil) {
		cell = [[MultiLineDetailCellWordWrap alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier withRows:[dataset count] labelProportion:0.5];
	}
	NSMutableArray *values = [[NSMutableArray alloc] init];
	NSMutableArray *lables = [[NSMutableArray alloc] init];
	NSMutableArray *colors = [[NSMutableArray alloc] init];
	NSArray *items = [CoreDataLib selectRowsFromTable:@"LOCATION" mOC:managedObjectContext];
	for(NSManagedObject *mo in items) {
		[lables addObject:[NSString stringWithFormat:@"%@", [mo valueForKey:@"name"]]];
		NSString *lat = [NSString stringWithFormat:@"%@", [mo valueForKey:@"latitude"]];
		NSString *longitude = [NSString stringWithFormat:@"%@", [mo valueForKey:@"longitude"]];
		NSString *CoordStr = @"-";
		float distance = 99;
		if([mo valueForKey:@"latitude"]) {
			distance = [ProjectFunctions getDistanceFromTarget:currentLocation.coordinate.latitude fromLong:currentLocation.coordinate.longitude toLat:[lat floatValue] toLong:[longitude floatValue]];
			if(distance<0)
				distance=0;
			CoordStr = [NSString stringWithFormat:@"%.1f miles", distance];
		}
		[values addObject:CoordStr];

		if(distance<1.5)
			[colors addObject:[UIColor colorWithRed:0 green:.5 blue:0 alpha:1]];
		else
			[colors addObject:[UIColor blackColor]];
			
	}
	cell.mainTitle = @"Location";
	cell.alternateTitle = @"Distance";
	cell.titleTextArray = lables;
	cell.fieldTextArray = values;
	cell.fieldColorArray = colors;
	
	cell.selectionStyle = UITableViewCellSelectionStyleGray;
	cell.selectionStyle = UITableViewCellSelectionStyleNone;

	return cell;
}



@end
