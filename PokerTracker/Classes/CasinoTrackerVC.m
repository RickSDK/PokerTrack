//
//  CasinoTrackerVC.m
//  PokerTracker
//
//  Created by Rick Medved on 1/17/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "CasinoTrackerVC.h"
#import "CasinoTrackerEditVC.h"
#import "ProjectFunctions.h"
#import "WebServicesFunctions.h"
#import "QuadWithImageTableViewCell.h"
#import "NSArray+ATTArray.h"
#import "CasinoEditorVC.h"
#import "CasinoStatsVC.h"


@implementation CasinoTrackerVC
@synthesize managedObjectContext, progressView, progress, casinoNameArray, nameBut, distBut, latestCasino;
@synthesize locateButton, distanceSegment, latitudeLabel, lngLabel, recordsLabel, viewButton, casinoDistArray, currentLyLookingFlg;
@synthesize activityIndicator, locationManager, currentLocation, activityPopup, activityLabel, casinoArray, mainTableView;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[super viewDidLoad];
	[self setTitle:@"Casino Locator"];
	
	[self.mainTableView setBackgroundView:nil];
	
	
	casinoArray = [[NSMutableArray alloc] init];
	casinoDistArray = [[NSMutableArray alloc] init];
	casinoNameArray = [[NSMutableArray alloc] init];
	
	locateButton.enabled=NO;
	self.locationManager = [[CLLocationManager alloc] init];
	self.locationManager.delegate = self;
	self.locationManager.distanceFilter = kCLDistanceFilterNone;
	self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
	
	if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
		[self.locationManager requestWhenInUseAuthorization];
		[self.locationManager startMonitoringSignificantLocationChanges];
	}
	[self.locationManager startUpdatingLocation];
	
	activityPopup.alpha=0;
	activityLabel.alpha=0;
	self.progress=0;
	nameBut.enabled=NO;
	distBut.enabled=YES;
	self.mainTableView.alpha=0;
	
	
	UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(createPressed:)];
	self.navigationItem.rightBarButtonItem = addButton;
	
	progressView.alpha=1;
	progressView.progress=0;
	activityLabel.text = @"Locating GPS Coords";
	[self executeThreadedJob:@selector(locateGPSCoords)];
	
	
	
}

- (IBAction) goHomePressed: (id) sender
{
	[self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
}

- (IBAction) viewPressed: (id) sender
{
	CasinoStatsVC *detailViewController = [[CasinoStatsVC alloc] initWithNibName:@"CasinoStatsVC" bundle:nil];
	detailViewController.managedObjectContext=managedObjectContext;
	detailViewController.currentLocation=currentLocation;
	[self.navigationController pushViewController:detailViewController animated:YES];
}
/*
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
	NSLog(@"didUpdateToLocation: %@", newLocation);
	self.currentLocation = newLocation;
	
	if (self.currentLocation != nil) {
		
		
		NSLog(@"latitude %+.6f, longitude %+.6f\n",
			  self.currentLocation.coordinate.latitude,
			  self.currentLocation.coordinate.longitude);

//		longitudeLabel.text = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.longitude];
//		latitudeLabel.text = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.latitude];
	}
}
*/


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


-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if([self respondsToSelector:@selector(edgesForExtendedLayout)])
        [self setEdgesForExtendedLayout:UIRectEdgeBottom];
}



- (IBAction) createPressed: (id) sender 
{
	if([ProjectFunctions isLiteVersion]) {
		[ProjectFunctions showAlertPopup:@"Notice" message:@"This feature only available in full version."];
		return;
	}
	
	CasinoTrackerEditVC *detailViewController = [[CasinoTrackerEditVC alloc] initWithNibName:@"CasinoTrackerEditVC" bundle:nil];
	detailViewController.managedObjectContext=managedObjectContext;
	detailViewController.currentLocation=currentLocation;
	[self.navigationController pushViewController:detailViewController animated:YES];
}

- (IBAction) sortByNamePressed: (id) sender
{
	[casinoArray removeAllObjects];
	[casinoArray addObjectsFromArray:casinoNameArray];
	nameBut.enabled=NO;
	distBut.enabled=YES;
	[mainTableView reloadData];
}

- (IBAction) sortByDistPressed: (id) sender
{
	[casinoArray removeAllObjects];
	[casinoArray addObjectsFromArray:casinoDistArray];
	nameBut.enabled=YES;
	distBut.enabled=NO;
	[mainTableView reloadData];
}


-(void)addressLookup
{
	@autoreleasepool {
	
	

		latitudeLabel.text = [NSString stringWithFormat:@"Lat: %.6f", currentLocation.coordinate.latitude];
		lngLabel.text = [NSString stringWithFormat:@"Lng: %.6f", currentLocation.coordinate.longitude];

		NSString *lat = [ProjectFunctions getLatitudeFromLocation:currentLocation decimalPlaces:6];
		NSString *lng = [ProjectFunctions getLongitudeFromLocation:currentLocation decimalPlaces:6];

		NSArray *distances = [NSArray arrayWithObjects:@"10", @"25", @"100", nil];
		NSString *distanceStr = [distances stringAtIndex:(int)distanceSegment.selectedSegmentIndex];

		NSArray *nameList = [NSArray arrayWithObjects:@"Username", @"Password", @"lat", @"lng", @"distance", nil];
		NSArray *valueList = [NSArray arrayWithObjects:@"test@test.com", @"test", lat, lng, distanceStr, nil];
		NSString *webAddr = @"http://www.appdigity.com/poker/pokerCasinoLookup.php";
		NSString *responseStr = [WebServicesFunctions getResponseFromServerUsingPost:webAddr fieldList:nameList valueList:valueList];
		
		[casinoArray removeAllObjects];
		[casinoNameArray removeAllObjects];
		[casinoDistArray removeAllObjects];
		
		if([WebServicesFunctions validateStandardResponse:responseStr delegate:nil]) {
			NSArray *LatCasinos = [responseStr componentsSeparatedByString:@"<a>"];
        if([LatCasinos count]>1)
            self.latestCasino = [LatCasinos objectAtIndex:1];
        NSLog(@"+++%@", responseStr);
        
			NSArray *casinos = [responseStr componentsSeparatedByString:@"<li>"];
			int x=0;
			for(__strong NSString *casino in casinos) {
				if(x++==1)
					recordsLabel.text = [NSString stringWithFormat:@"Total Casinos in DataBase: %d", [casino intValue]];
					
				NSArray *items = [casino componentsSeparatedByString:@"|"];
				int distance = [[items stringAtIndex:13] intValue];
				if(distance==100)
					distanceSegment.selectedSegmentIndex=2;
					
				if([items count]>1) {
					float lat = [[items stringAtIndex:6] floatValue];
					float lng = [[items stringAtIndex:7] floatValue];
					float distance = [ProjectFunctions getDistanceFromTarget:lat fromLong:lng toLat:currentLocation.coordinate.latitude toLong:currentLocation.coordinate.longitude];
					if(distance <= [distanceStr floatValue]) {
						distance += 10000;
						casino = [NSString stringWithFormat:@"%f|%@", distance, casino];
						[casinoNameArray addObject:casino];
						[casinoDistArray addObject:casino];
					}
				}
			}
			[casinoDistArray sortUsingSelector:@selector(compare:)];
			if([casinoNameArray count]==0) {
				if(distanceSegment.selectedSegmentIndex<2)
					[ProjectFunctions showAlertPopupWithDelegate:@"Sorry" message:@"No casinos found. Help build the database by entering local casinos." delegate:self];
				distanceSegment.selectedSegmentIndex=2;
			}
		}

		[activityIndicator stopAnimating];
		activityPopup.alpha=0;
		activityLabel.alpha=0;
		locateButton.enabled=YES;
		self.currentLyLookingFlg=NO;

		if(nameBut.enabled)
			[casinoArray addObjectsFromArray:casinoDistArray];
		else 
			[casinoArray addObjectsFromArray:casinoNameArray];

    self.mainTableView.alpha=1;
		[mainTableView reloadData];
	}
}




-(void)executeThreadedJob:(SEL)aSelector
{
	[activityIndicator startAnimating];
	activityPopup.alpha=1;
	activityLabel.alpha=1;
	[self performSelectorInBackground:aSelector withObject:nil];
}

-(void)locateGPSCoords
{
	@autoreleasepool {
	
		float timeInt = 0.2;
//	float timeInt = 0.05;
		if([[ProjectFunctions getUserDefaultValue:@"GPSLoc"] length]>0)
			timeInt = 0.05;

		for(int i=1; i<=20; i++) {
			[NSThread sleepForTimeInterval:timeInt];
			self.progress += 5;
			[self executeThreadedJob:@selector(updateProgressBar)];
		}

    [activityLabel performSelectorOnMainThread:@selector(setText: ) withObject:@"Finding Local Casinos" waitUntilDone:YES];
		progressView.alpha=0;
		
		[locationManager stopUpdatingLocation];
		if(currentLocation==nil) {
			locateButton.enabled=NO;
			[ProjectFunctions showAlertPopup:@"GPS Error" message:@"Sorry, unable to locate your current position. Make sure you have GPS turned on."];
			[activityIndicator stopAnimating];
			activityPopup.alpha=0;
			activityLabel.alpha=0;
			locateButton.enabled=YES;
		} else {
        self.mainTableView.alpha=0;
			[self executeThreadedJob:@selector(addressLookup)];
			[ProjectFunctions setUserDefaultValue:[NSString stringWithFormat:@"%.6f|%.6f", currentLocation.coordinate.latitude, currentLocation.coordinate.longitude] forKey:@"GPSLoc"];
		}
	
	}
}

-(void)locateCasinos
{
	self.currentLyLookingFlg=YES;
    self.mainTableView.alpha=0;

	locateButton.enabled=NO;
	if(currentLocation==nil) {
		progressView.alpha=1;
		progressView.progress=0;
		self.progress=0;
		activityLabel.text = @"Locating GPS Coords";		
		[self executeThreadedJob:@selector(locateGPSCoords)];
	} else 
		[self executeThreadedJob:@selector(addressLookup)];
}

- (IBAction) locatePressed: (id) sender 
{
	[self locateCasinos];
}

- (IBAction) segmentPressed: (id) sender
{
	[distanceSegment changeSegment];
	if(!currentLyLookingFlg)
		[self locateCasinos];
}

-(void)updateProgressBar
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [progressView setProgress:(float)progress/100];
    }
                   );
	
}
	



- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
	[ProjectFunctions ptpLocationAuthorizedCheck:status];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
	NSLog(@"+++didUpdateLocations!!");
	self.currentLocation = [locations lastObject];
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
	NSLog(@"+++didFailWithError!!");
	NSLog(@"%@", error.localizedDescription);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [casinoArray count];
}



// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	NSString *cellIdentifier = [NSString stringWithFormat:@"cellIdentifierSection%dRow%d", (int)indexPath.section, (int)indexPath.row];
    
    QuadWithImageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[QuadWithImageTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    // Configure the cell...
	NSString *casino = [casinoArray objectAtIndex:indexPath.row];
	NSArray *items = [casino componentsSeparatedByString:@"|"];
	
	cell.aa.text = [items stringAtIndex:2];
	cell.bb.text = [items stringAtIndex:5];
	if([[items stringAtIndex:6] isEqualToString:@"Y"])
		cell.bb.text = [NSString stringWithFormat:@"%@ (I)", [items stringAtIndex:5]];
		
	cell.bb.text = [NSString stringWithFormat:@"%@, %@", [items stringAtIndex:3],[items stringAtIndex:4]];
	float lat = [[items stringAtIndex:7] floatValue];
	float lng = [[items stringAtIndex:8] floatValue];
	float distance = [ProjectFunctions getDistanceFromTarget:lat fromLong:lng toLat:currentLocation.coordinate.latitude toLong:currentLocation.coordinate.longitude];
	cell.dd.text = [NSString stringWithFormat:@"%.1f miles", distance];
	cell.bbColor = [UIColor colorWithRed:0 green:.5 blue:0 alpha:1];
	
	
	cell.leftImage.image = [CasinoEditorVC getCasinoImage:[items stringAtIndex:5] indianFlg:[items stringAtIndex:6]];

	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	cell.selectionStyle = UITableViewCellSelectionStyleBlue;

	return cell;
}

- (IBAction) latestPressed: (id) sender
{
	CasinoEditorVC *detailViewController = [[CasinoEditorVC alloc] initWithNibName:@"CasinoEditorVC" bundle:nil];
	detailViewController.managedObjectContext = managedObjectContext;
	detailViewController.casino = self.latestCasino;
	detailViewController.currentLocation=currentLocation;
	[self.navigationController pushViewController:detailViewController animated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *casino = [casinoArray objectAtIndex:indexPath.row];
	NSMutableArray *items = [NSMutableArray arrayWithArray:[casino componentsSeparatedByString:@"|"]];
	[items removeObjectAtIndex:0];
	CasinoEditorVC *detailViewController = [[CasinoEditorVC alloc] initWithNibName:@"CasinoEditorVC" bundle:nil];
	detailViewController.managedObjectContext = managedObjectContext;
	detailViewController.casino = [items componentsJoinedByString:@"|"];
	detailViewController.currentLocation=currentLocation;
	[self.navigationController pushViewController:detailViewController animated:YES];
}







@end
