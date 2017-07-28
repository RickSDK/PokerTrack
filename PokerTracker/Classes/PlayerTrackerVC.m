//
//  PlayerTrackerVC.m
//  PokerTracker
//
//  Created by Rick Medved on 1/16/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "PlayerTrackerVC.h"
//#import "ListPicker.h"
#import "CoreDataLib.h"
#import "ProjectFunctions.h"
#import "EditPlayerTracker.h"
#import "QuadWithImageTableViewCell.h"
#import "PlayerTrackerObj.h"
#import "EditSegmentVC.h"


@implementation PlayerTrackerVC
@synthesize managedObjectContext, mainTableView, locationButton, selectedObjectForEdit, playerList;
@synthesize activityIndicator, locationManager, currentLocation, latLngLabel;

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


- (IBAction) locationButtonPressed: (id) sender
{
	self.selectedObjectForEdit=2;
	EditSegmentVC *localViewController = [[EditSegmentVC alloc] initWithNibName:@"EditSegmentVC" bundle:nil];
	localViewController.callBackViewController=self;
	localViewController.managedObjectContext = managedObjectContext;
	localViewController.initialDateValue = locationButton.titleLabel.text;
	localViewController.readyOnlyFlg = YES;
	localViewController.databaseField = @"location";
	[self.navigationController pushViewController:localViewController animated:YES];
}

- (IBAction) createPressed: (id) sender 
{
	EditPlayerTracker *detailViewController = [[EditPlayerTracker alloc] initWithNibName:@"EditPlayerTracker" bundle:nil];
	detailViewController.managedObjectContext = managedObjectContext;
	detailViewController.callBackViewController=self;
	detailViewController.casino = locationButton.titleLabel.text;
	[self.navigationController pushViewController:detailViewController animated:YES];
}

-(void)reloadData
{
	NSPredicate *predicate = nil;
	if(![locationButton.titleLabel.text isEqualToString:@"All Locations"] )
		predicate = [NSPredicate predicateWithFormat:@"status = %@", locationButton.titleLabel.text];
	
    NSArray *newPlayers = [CoreDataLib selectRowsFromEntity:@"EXTRA" predicate:predicate sortColumn:@"name" mOC:managedObjectContext ascendingFlg:YES];
	[playerList removeAllObjects];
	[playerList addObjectsFromArray:newPlayers];
	[mainTableView reloadData];
}

- (IBAction) allButtonPressed: (id) sender
{
	[locationButton setTitle:@"All Locations" forState:UIControlStateNormal];
	locationButton.titleLabel.text = @"All Locations";
	[self reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [playerList count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 44;
}

-(void)checkCurrentLocation
{
	@autoreleasepool {
		[NSThread sleepForTimeInterval:3];
		
		[activityIndicator stopAnimating];
		[locationManager stopUpdatingLocation];
		locationButton.enabled=YES;
		if(currentLocation!=nil) {
			NSString *location = [ProjectFunctions getDefaultLocation:currentLocation.coordinate.latitude long:currentLocation.coordinate.longitude moc:managedObjectContext];
			[locationButton setTitle:location forState:UIControlStateNormal];
			locationButton.titleLabel.text = location;
			[self reloadData];
		}
	}
}


-(void)executeThreadedJob:(SEL)aSelector
{
	[activityIndicator startAnimating];
	[self performSelectorInBackground:aSelector withObject:nil];
}

-(void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	[self setTitle:@"Player Tracker"];
	[self changeNavToIncludeType:4];
	
	self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:
											   [ProjectFunctions UIBarButtonItemWithIcon:[NSString fontAwesomeIconStringForEnum:FAPlus] target:self action:@selector(createPressed:)],
											   [ProjectFunctions UIBarButtonItemWithIcon:[NSString fontAwesomeIconStringForEnum:FAInfoCircle] target:self action:@selector(popupButtonClicked)],
											   nil];
	
	self.popupView.titleLabel.text = self.title;
	self.popupView.textView.text = @"Track players you often play against to record useful information.";
	self.popupView.textView.hidden=NO;

	
	playerList = [[NSMutableArray alloc] init];
								
	[locationButton setBackgroundImage:[UIImage imageNamed:@"yellowGlossButton.png"] forState:UIControlStateNormal];
	
	
	[locationButton setTitle:@"All Locations" forState:UIControlStateNormal];
	locationButton.titleLabel.text = @"All Locations";
}

- (IBAction) localButtonPressed: (id) sender {
	locationButton.enabled=NO;
	
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

-(void) setReturningValue:(NSString *) value {
	if(selectedObjectForEdit==2) {
		[locationButton setTitle:value forState:UIControlStateNormal];
		locationButton.titleLabel.text = value;
	}

	[self reloadData];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *cellIdentifier = [NSString stringWithFormat:@"cellIdentifierSection%dRow%d", (int)indexPath.section, (int)indexPath.row];
    
    QuadWithImageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[QuadWithImageTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
	
	NSManagedObject *mo = [playerList objectAtIndex:(int)indexPath.row];
	PlayerTrackerObj *obj = [PlayerTrackerObj createObjWithMO:mo managedObjectContext:self.managedObjectContext];
	
	return [QuadWithImageTableViewCell cellForPlayer:obj cell:cell];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	EditPlayerTracker *detailViewController = [[EditPlayerTracker alloc] initWithNibName:@"EditPlayerTracker" bundle:nil];
	detailViewController.managedObjectContext = managedObjectContext;
	detailViewController.callBackViewController=self;
	detailViewController.managedObject=[playerList objectAtIndex:indexPath.row];
	[self.navigationController pushViewController:detailViewController animated:YES];
}

@end
