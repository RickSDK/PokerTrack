//
//  PlayerTrackerVC.m
//  PokerTracker
//
//  Created by Rick Medved on 1/16/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "PlayerTrackerVC.h"
#import "ListPicker.h"
#import "CoreDataLib.h"
#import "ProjectFunctions.h"
#import "EditPlayerTracker.h"
#import "QuadWithImageTableViewCell.h"


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
	NSArray *listOfVals = [CoreDataLib getFieldList:@"Location" mOC:managedObjectContext addAllTypesFlg:YES];
	self.selectedObjectForEdit=2;
	ListPicker *localViewController = [[ListPicker alloc] initWithNibName:@"ListPicker" bundle:nil];
	localViewController.callBackViewController=self;
	localViewController.managedObjectContext = managedObjectContext;
	localViewController.initialDateValue = [NSString stringWithFormat:@"%@", locationButton.titleLabel.text];
	localViewController.titleLabel = @"Location";
	localViewController.selectedList=0;
	localViewController.selectionList = [[NSArray alloc] initWithArray:listOfVals];
	localViewController.allowEditing=NO;
	[self.navigationController pushViewController:localViewController animated:YES];
	
}

- (IBAction) createPressed: (id) sender 
{
	EditPlayerTracker *detailViewController = [[EditPlayerTracker alloc] initWithNibName:@"EditPlayerTracker" bundle:nil];
	detailViewController.managedObjectContext = managedObjectContext;
	detailViewController.callBackViewController=self;
	detailViewController.casino = [NSString stringWithFormat:@"%@", locationButton.titleLabel.text];
	[self.navigationController pushViewController:detailViewController animated:YES];
}

-(void)reloadData
{
	NSPredicate *predicate = nil;
	if(![locationButton.titleLabel.text isEqualToString:@"All Locations"] )
		predicate = [NSPredicate predicateWithFormat:@"status = %@", locationButton.titleLabel.text];
	
	if([locationButton.titleLabel.text isEqualToString:@"*Custom*"]) {
		NSString *searchStr = [CoreDataLib getFieldValueForEntity:managedObjectContext entityName:@"SEARCH" field:@"searchStr" predString:@"type = 'Location'" indexPathRow:0];
		searchStr = [searchStr stringByReplacingOccurrencesOfString:@"location" withString:@"status"];
		predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"1=1 %@", searchStr]];
	}
    
    NSArray *newPlayers = [CoreDataLib selectRowsFromEntity:@"EXTRA" predicate:predicate sortColumn:@"name" mOC:managedObjectContext ascendingFlg:YES];
	if([newPlayers count]>0) {
        [playerList removeAllObjects];
        [playerList addObjectsFromArray:newPlayers];
        [mainTableView reloadData];
    }
}

- (IBAction) allButtonPressed: (id) sender
{
	[locationButton setTitle:@"All Locations" forState:UIControlStateNormal];
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
			[locationButton setTitle:[NSString stringWithFormat:@"%@", [ProjectFunctions getDefaultLocation:currentLocation.coordinate.latitude long:currentLocation.coordinate.longitude moc:managedObjectContext]] forState:UIControlStateNormal];
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
    if([self respondsToSelector:@selector(edgesForExtendedLayout)])
        [self setEdgesForExtendedLayout:UIRectEdgeBottom];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	[self setTitle:@"Player Tracker"];
    
    [mainTableView setBackgroundView:nil];

	
	playerList = [[NSMutableArray alloc] init];
								
	UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(createPressed:)];
	self.navigationItem.rightBarButtonItem = addButton;

	[locationButton setBackgroundImage:[UIImage imageNamed:@"yellowGlossButton.png"] forState:UIControlStateNormal];
	
	
	[self reloadData];
	if([playerList count]<1) {
		[locationButton setTitle:@"All Locations" forState:UIControlStateNormal];
	} else {
		
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


-(void) setReturningValue:(NSString *) value2 {
	
	NSString *value = [NSString stringWithFormat:@"%@", [ProjectFunctions getUserDefaultValue:@"returnValue"]];
	if(selectedObjectForEdit==2)
		[locationButton setTitle:[NSString stringWithFormat:@"%@", value] forState:UIControlStateNormal];
	
	[self reloadData];
}

-(NSString *)playerTypeString:(int)looseNum passNum:(int)passNum
{
	
	if(looseNum<=50 && passNum<=50)
		return @"Loose-Passive";

	if(looseNum<=50 && passNum>50)
		return @"Loose-Aggressive";

	if(looseNum>50 && passNum<=50)
		return @"Tight-Passive";

	return @"Tight-Aggressive";
	
	
	
}	

-(UIImage *)getUserPic:(int)user_id playerSkill:(int)playerSkill
{
	UIImage *image=nil;
	NSString *jpgPath = [ProjectFunctions getPicPath:user_id];
	
	NSFileHandle *fh = [NSFileHandle fileHandleForReadingAtPath:jpgPath];
	if(fh==nil)
		image = [UIImage imageNamed:[NSString stringWithFormat:@"playerType%d.png", playerSkill+1]];
	else {
		image = [UIImage imageWithContentsOfFile:jpgPath];
	}
	[fh closeFile];
	
	return image;
	
	
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *cellIdentifier = [NSString stringWithFormat:@"cellIdentifierSection%dRow%d", (int)indexPath.section, (int)indexPath.row];
    
    QuadWithImageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[QuadWithImageTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
	
	NSManagedObject *mo = [playerList objectAtIndex:(int)indexPath.row];
	
    [cell.aa performSelectorOnMainThread:@selector(setText: ) withObject:[mo valueForKey:@"name"] waitUntilDone:YES];
	int playerType = [[mo valueForKey:@"attrib_01"] intValue];
	int playerSkill = [[mo valueForKey:@"attrib_02"] intValue];

	int agressiveNum = [[mo valueForKey:@"agressiveNum"] intValue];
	int looseNum = [[mo valueForKey:@"looseNum"] intValue];
	if(agressiveNum==0 && looseNum==0) {
		looseNum=playerType/100;
		agressiveNum=playerType-(looseNum*100);
		
		if(agressiveNum>100)
			agressiveNum=100;
		if(agressiveNum<1)
			agressiveNum=1;
		if(looseNum>100)
			looseNum=100;
		if(looseNum<1)
			looseNum=1;
		
		[mo setValue:[NSNumber numberWithInt:agressiveNum] forKey:@"agressiveNum"];
		[mo setValue:[NSNumber numberWithInt:looseNum] forKey:@"looseNum"];
		[managedObjectContext save:nil];
	}

	
	NSArray *skills = [NSArray arrayWithObjects:@"Weak", @"Average", @"Strong", @"Pro", nil];

    [cell.bb performSelectorOnMainThread:@selector(setText: ) withObject:[self playerTypeString:looseNum passNum:agressiveNum] waitUntilDone:YES];
    [cell.cc performSelectorOnMainThread:@selector(setText: ) withObject:[mo valueForKey:@"status"] waitUntilDone:YES];
    [cell.dd performSelectorOnMainThread:@selector(setText: ) withObject:[skills objectAtIndex:playerSkill] waitUntilDone:YES];

	cell.ccColor = [UIColor orangeColor];
	
	int user_id = [[mo valueForKey:@"user_id"] intValue];
	
	cell.leftImage.image = [self getUserPic:user_id playerSkill:playerSkill];
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	cell.selectionStyle = UITableViewCellSelectionStyleBlue;

	return cell;
}	

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	EditPlayerTracker *detailViewController = [[EditPlayerTracker alloc] initWithNibName:@"EditPlayerTracker" bundle:nil];
	detailViewController.managedObjectContext = managedObjectContext;
	detailViewController.callBackViewController=self;
	detailViewController.managedObject=[playerList objectAtIndex:indexPath.row];
	[self.navigationController pushViewController:detailViewController animated:YES];
}






@end
