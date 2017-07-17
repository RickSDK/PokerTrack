//
//  StartNewGameVC.m
//  PokerTracker
//
//  Created by Rick Medved on 10/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "StartNewGameVC.h"
#import "ProjectFunctions.h"
#import "MoneyPickerVC.h"
#import "ListPicker.h"
#import "CoreDataLib.h"
#import "GameInProgressVC.h"
#import "GameDetailsVC.h"
#import "NSDate+ATTDate.h"
#import "NSArray+ATTArray.h"
#import "CasinoTrackerEditVC.h"
#import "WebServicesFunctions.h"
#import "CreateOldGameVC.h"
#import "ViewLocationsVC.h"
#import "MapKitTut.h"
#import "EditSegmentVC.h"


@implementation StartNewGameVC
@synthesize managedObjectContext, bankrollLabel, locationLabel, retryButton;
@synthesize gameTypeSegmentBar, gameNameSegmentBar, blindTypeSegmentBar, limitTypeSegmentBar, TourneyTypeSegmentBar;
@synthesize editButton, bankrollButton, buyinButton, startLiveButton, completedButton, locationButton, locationManager, currentLocation;
@synthesize selectedObjectForEdit, activityIndicator, buyinLabel, addCasinoButton, addCasinoFlg;


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[super viewDidLoad];
	[self setTitle:NSLocalizedString(@"Game", nil)];
	
	self.popupView.titleLabel.text=@"Options";
	
	self.selectedObjectForEdit=0;
	startLiveButton.enabled=NO;
	self.addCasinoButton.enabled=NO;
	
	self.navigationItem.rightBarButtonItem = [ProjectFunctions UIBarButtonItemWithIcon:[NSString fontAwesomeIconStringForEnum:FACog] target:self action:@selector(popupButtonClicked)];

	self.buyinLabel.text = NSLocalizedString(@"Buyin", nil);
	self.bankrollLabel.text = NSLocalizedString(@"bankroll", nil);
	[self.completedButton setTitle:NSLocalizedString(@"Completed", nil) forState:UIControlStateNormal];
	[ProjectFunctions makeFALabel:self.locationLabel type:13 size:22];
	[ProjectFunctions makeFAButton:self.retryButton type:12 size:18];
	[ProjectFunctions makeFAButton:self.addCasinoButton type:1 size:18];
	
	self.startLiveButton.titleLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:30];
	[self.startLiveButton setTitle:[NSString fontAwesomeIconStringForEnum:FAPlay] forState:UIControlStateNormal];
	
	[ProjectFunctions populateSegmentBar:self.blindTypeSegmentBar mOC:self.managedObjectContext];
	
	[ProjectFunctions initializeSegmentBar:gameNameSegmentBar defaultValue:[ProjectFunctions getUserDefaultValue:@"gameNameDefault"] field:@"gametype"];
	[ProjectFunctions initializeSegmentBar:blindTypeSegmentBar defaultValue:[ProjectFunctions getUserDefaultValue:@"blindDefault"] field:@"stakes"];
	[ProjectFunctions initializeSegmentBar:limitTypeSegmentBar defaultValue:[ProjectFunctions getUserDefaultValue:@"limitDefault"] field:@"limit"];
	[ProjectFunctions initializeSegmentBar:TourneyTypeSegmentBar defaultValue:[ProjectFunctions getUserDefaultValue:@"tourneyTypeDefault"] field:@"tournamentType"];
	
	gameNameSegmentBar.selectedSegmentIndex = [ProjectFunctions getSegmentValueForSegment:0 currentValue:[ProjectFunctions getUserDefaultValue:@"gameNameDefault"] startGameScreen:YES];
	limitTypeSegmentBar.selectedSegmentIndex = [ProjectFunctions getSegmentValueForSegment:2 currentValue:[ProjectFunctions getUserDefaultValue:@"limitDefault"] startGameScreen:YES];
	TourneyTypeSegmentBar.selectedSegmentIndex = [ProjectFunctions getSegmentValueForSegment:3 currentValue:[ProjectFunctions getUserDefaultValue:@"tourneyTypeDefault"] startGameScreen:YES];
	
	[bankrollButton setTitle:[ProjectFunctions getUserDefaultValue:@"bankrollDefault"] forState:UIControlStateNormal];
	[locationButton setTitle:[ProjectFunctions getUserDefaultValue:@"locationDefault"] forState:UIControlStateNormal];
	
	self.locationManager = [[CLLocationManager alloc] init];
	self.locationManager.delegate = self;
	self.locationManager.distanceFilter = kCLDistanceFilterNone;
	self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
	
	if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
		[self.locationManager requestWhenInUseAuthorization];
		[self.locationManager startMonitoringSignificantLocationChanges];
	}
	[self.locationManager startUpdatingLocation];
	
	[self setLocationButtonTitle:@"Searching..." mode:0];
	[activityIndicator startAnimating];
	[self performSelectorInBackground:@selector(checkCurrentLocation) withObject:nil];
	
	[ProjectFunctions makeGameSegment:self.gameTypeSegmentBar color:[UIColor colorWithRed:.8 green:.7 blue:0 alpha:1]];
	[ProjectFunctions makeSegment:self.gameNameSegmentBar color:[UIColor colorWithRed:0 green:.2 blue:0 alpha:1]];
	[ProjectFunctions makeSegment:self.blindTypeSegmentBar color:[UIColor colorWithRed:0 green:.2 blue:0 alpha:1]];
	[ProjectFunctions makeSegment:self.limitTypeSegmentBar color:[UIColor colorWithRed:0 green:.2 blue:0 alpha:1]];
	[ProjectFunctions makeSegment:self.TourneyTypeSegmentBar color:[UIColor colorWithRed:0 green:.2 blue:0 alpha:1]];
	
	
	NSString *gameType = [ProjectFunctions getUserDefaultValue:@"gameTypeDefault"];
	if([gameType isEqualToString:@"Tournament"]) {
		gameTypeSegmentBar.selectedSegmentIndex=1;
		[self.gameTypeSegmentBar changeSegment];
	} else {
		gameTypeSegmentBar.selectedSegmentIndex=0;
	}
	
	[self setupSegments];
}

-(void)addShadowToView:(UIView *)view {
	view.layer.cornerRadius = 7;
	view.layer.borderColor = [UIColor blackColor].CGColor;
	view.layer.borderWidth = 1;
	view.layer.masksToBounds = NO;
	view.layer.shadowOffset = CGSizeMake(15, 15);
	view.layer.shadowRadius = 5;
	view.layer.shadowOpacity = 0.8;
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



// Delegate method from the CLLocationManagerDelegate protocol.
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
		   fromLocation:(CLLocation *)oldLocation
{
	{// diagnostics
		NSLog(@"entering didUpdateToLocation...");
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
    NSLog(@"howRecent: %f", howRecent);
    if (abs(howRecent) < 5.0)
    {
//        [manager stopUpdatingLocation];
		
		currentLocation = newLocation;
		
        NSLog(@"latitude %+.6f, longitude %+.6f\n",
			  newLocation.coordinate.latitude,
			  newLocation.coordinate.longitude);
    }
    // else skip the event and process the next one.
}

-(void)setupSegments
{
	[ProjectFunctions setFontColorForSegment:gameTypeSegmentBar values:[NSArray arrayWithObjects:@"Cash Game", @"Tournament", nil]];
    
	NSString *buyinAmount = @"";
	[ProjectFunctions changeColorForGameBar:gameTypeSegmentBar];
	if(gameTypeSegmentBar.selectedSegmentIndex==0) {
 //       [gameTypeSegmentBar setTintColor:[UIColor colorWithRed:.9 green:.7 blue:0 alpha:1]];
		blindTypeSegmentBar.alpha=1;
		TourneyTypeSegmentBar.alpha=0;
		[ProjectFunctions setUserDefaultValue:@"Cash" forKey:@"gameTypeDefault"];
		buyinAmount = [ProjectFunctions getUserDefaultValue:@"buyinDefault"];
		[self setTitle:[NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Cash", nil), NSLocalizedString(@"Game", nil)]];
	} else {
 //       [self.gameTypeSegmentBar setTintColor:[UIColor colorWithRed:0 green:.7 blue:.9 alpha:1]];
		blindTypeSegmentBar.alpha=0;
		TourneyTypeSegmentBar.alpha=1;
		[ProjectFunctions setUserDefaultValue:@"Tournament" forKey:@"gameTypeDefault"];
		buyinAmount = [ProjectFunctions getUserDefaultValue:@"tournbuyinDefault"];
		[self setTitle:NSLocalizedString(@"Tournament", nil)];
	}
	[buyinButton setTitle:[NSString stringWithFormat:@"%@", [ProjectFunctions convertStringToMoneyString:buyinAmount]] forState:UIControlStateNormal];
    
}

- (IBAction) gameTypeSegmentPressed: (id) sender 
{
	[self.mainSegment changeSegment];
	[gameTypeSegmentBar changeSegment];
    [self setupSegments];
}

-(void)gotoListPicker:(NSString *)databaseField initialDateValue:(NSString *)initialDateValue
{
	EditSegmentVC *localViewController = [[EditSegmentVC alloc] initWithNibName:@"EditSegmentVC" bundle:nil];
	localViewController.callBackViewController=self;
	localViewController.managedObjectContext = managedObjectContext;
	localViewController.initialDateValue = initialDateValue;
	localViewController.databaseField = databaseField;
	[self.navigationController pushViewController:localViewController animated:YES];
}

- (IBAction) gameSegmentPressed: (id) sender 
{
	self.selectedObjectForEdit=4;
	if(gameNameSegmentBar.selectedSegmentIndex==3) {
		gameNameSegmentBar.selectedSegmentIndex=0;
		[self gotoListPicker:@"gametype" initialDateValue:@""];
	}
}
- (IBAction) stakesSegmentPressed: (id) sender 
{
	self.selectedObjectForEdit=5;
	if(blindTypeSegmentBar.selectedSegmentIndex==4) {
		blindTypeSegmentBar.selectedSegmentIndex=0;
		[self gotoListPicker:@"stakes" initialDateValue:@""];
	}
}
- (IBAction) limitSegmentPressed: (id) sender 
{
	self.selectedObjectForEdit=6;
	if(limitTypeSegmentBar.selectedSegmentIndex==3) {
		limitTypeSegmentBar.selectedSegmentIndex=0;
		[self gotoListPicker:@"limit" initialDateValue:@""];
	}
}

- (IBAction) tournSegmentPressed: (id) sender 
{
	self.selectedObjectForEdit=7;
	if(TourneyTypeSegmentBar.selectedSegmentIndex==3) {
		TourneyTypeSegmentBar.selectedSegmentIndex=0;
		[self gotoListPicker:@"tournamentType" initialDateValue:@""];
	}
}


- (IBAction) locationButtonPressed: (id) sender
{
	self.selectedObjectForEdit=2;
	[self gotoListPicker:@"location" initialDateValue:locationButton.titleLabel.text];
}

- (IBAction) bankrollButtonPressed: (id) sender 
{
	self.selectedObjectForEdit=1;
	[self gotoListPicker:@"bankroll" initialDateValue:bankrollButton.titleLabel.text];
}
- (IBAction) buyinButtonPressed: (id) sender 
{
	self.selectedObjectForEdit=0;
	MoneyPickerVC *detailViewController = [[MoneyPickerVC alloc] initWithNibName:@"MoneyPickerVC" bundle:nil];
	detailViewController.managedObjectContext=managedObjectContext;
	detailViewController.callBackViewController = self;
	detailViewController.titleLabel = @"Buy-in";
	detailViewController.initialDateValue = [NSString stringWithFormat:@"%@", buyinButton.titleLabel.text];
	[self.navigationController pushViewController:detailViewController animated:YES];
}

-(NSManagedObject *)insertnewGameIntoDatabase:(NSString *)status
{
	NSManagedObject *mo = [NSEntityDescription insertNewObjectForEntityForName:@"GAME" inManagedObjectContext:self.managedObjectContext];
	[self.managedObjectContext save:nil];
	NSDate *endTime = [NSDate date];
	NSDate *startTime = [endTime dateByAddingTimeInterval:-1*60*60*3];
	if([status isEqualToString:@"In Progress"])
		startTime=[NSDate date];


	NSString *Type = @"";
	NSString *game = [gameNameSegmentBar titleForSegmentAtIndex:gameNameSegmentBar.selectedSegmentIndex];
	NSString *stakes = [blindTypeSegmentBar titleForSegmentAtIndex:blindTypeSegmentBar.selectedSegmentIndex];
	NSString *limit = [limitTypeSegmentBar titleForSegmentAtIndex:limitTypeSegmentBar.selectedSegmentIndex];
	NSString *tourney = [TourneyTypeSegmentBar titleForSegmentAtIndex:TourneyTypeSegmentBar.selectedSegmentIndex];
	NSString *gName = @"";
	NSString *foodDrinks = @"0";
	NSString *tokes = @"0";
	if(gameTypeSegmentBar.selectedSegmentIndex==0) {
		Type = @"Cash";
		tourney = @"";
		gName = [NSString stringWithFormat:@"%@ %@ %@", game, stakes, limit];
	} else {
		Type = @"Tournament";
		stakes = @"";
		gName = [NSString stringWithFormat:@"%@ %@ %@", game, tourney, limit];
	}
	NSString *weekday = [ProjectFunctions getWeekDayFromDate:startTime];
	NSString *month = [ProjectFunctions getMonthFromDate:startTime];
	NSString *dayTime = [ProjectFunctions getDayTimeFromDate:startTime];
	float buyInAmount = [ProjectFunctions convertMoneyStringToDouble:buyinButton.titleLabel.text];
	NSArray *valueArray = [NSArray arrayWithObjects:
						   [startTime convertDateToStringWithFormat:@"MM/dd/yyyy hh:mm:ss a"],
						   [endTime convertDateToStringWithFormat:@"MM/dd/yyyy hh:mm:ss a"],
						   @"3",	// hours
						   [NSString stringWithFormat:@"%.02f", buyInAmount], // buyin
						   @"0",	// rebuy
						   foodDrinks,	// food drinks
						   [NSString stringWithFormat:@"%.02f", buyInAmount],	// cashout
						   @"0",	//winnings
						   gName,
						   game,
						   stakes,
						   limit,
						   [NSString stringWithFormat:@"%@", locationButton.titleLabel.text],
						   [NSString stringWithFormat:@"%@", bankrollButton.titleLabel.text],
						   @"0", // rebuys
						   @"", // notes
						   @"0", // break min
						   tokes, // tokes
						   @"180", // min
						   [[NSDate date] convertDateToStringWithFormat:@"yyyy"],
						   Type,
						   status,
						   tourney,
						   @"0",
						   weekday,
						   month,
						   dayTime,
						   nil];
	
	[ProjectFunctions updateGameInDatabase:managedObjectContext mo:mo valueList:valueArray];
	[ProjectFunctions scrubDataForObj:mo context:self.managedObjectContext];
	return mo;
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if(buttonIndex==1) {
		CasinoTrackerEditVC *detailViewController = [[CasinoTrackerEditVC alloc] initWithNibName:@"CasinoTrackerEditVC" bundle:nil];
		detailViewController.managedObjectContext=managedObjectContext;
		detailViewController.currentLocation=currentLocation;
		[self.navigationController pushViewController:detailViewController animated:YES];
	}
}

-(void)setLocationButtonTitle:(NSString *)title mode:(int)mode
{
	[locationButton setTitle:[NSString stringWithFormat:@"%@", title] forState:UIControlStateNormal];
	if(mode==1) {
		[locationButton setBackgroundImage:[UIImage imageNamed:@"yellowChromeBut.png"] forState:UIControlStateNormal];
		[locationButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
		[locationButton setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
	} else {
		[locationButton setBackgroundImage:[UIImage imageNamed:@"blackChromeBut.png"] forState:UIControlStateNormal];
		[locationButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		[locationButton setTitleShadowColor:[UIColor blackColor] forState:UIControlStateNormal];
	}
}


-(void)executeThreadedJob:(SEL)aSelector
{
	[activityIndicator startAnimating];
	[self performSelectorInBackground:aSelector withObject:nil];
}


-(void)checkCurrentLocation
{
	@autoreleasepool {
		NSLog(@"+++currentLocation.coordinate.latitude: %f", currentLocation.coordinate.latitude);
		[NSThread sleepForTimeInterval:4];
		NSLog(@"+++currentLocation.coordinate.latitude: %f", currentLocation.coordinate.latitude);
		
		[activityIndicator stopAnimating];
		[self.locationManager stopUpdatingLocation];
		
		startLiveButton.enabled=YES;
		
		NSString *locationName = [ProjectFunctions checkLocation1:currentLocation moc:managedObjectContext];
		NSString *latestPos = [NSString stringWithFormat:@"%f:%f:gps", currentLocation.coordinate.latitude, currentLocation.coordinate.longitude];
		
		
		[ProjectFunctions setUserDefaultValue:latestPos forKey:@"latestPos"];
		
		
		if([locationName length]==0) {
			locationName = [ProjectFunctions checkLocation2:currentLocation moc:managedObjectContext];
			if(currentLocation != nil && ![ProjectFunctions isLiteVersion] && ![ProjectFunctions isPokerZilla]) {
				self.addCasinoButton.enabled=YES;
				[self.addCasinoButton setBackgroundColor:[UIColor yellowColor]];
			}
		}
		
		[self setLocationButtonTitle:locationName mode:1];
	}
}

- (IBAction) addCasinoButtonPressed: (id) sender {
				[ProjectFunctions showConfirmationPopup:@"Add Casino?" message:@"Did you want to add this casino to the database? Note: Not needed for home games." delegate:self tag:1];
}

-(void)sendMessageWebRequest
{
	@autoreleasepool {
    
        NSArray *nameList = [NSArray arrayWithObjects:@"Username", @"Password", @"status", nil];
        NSArray *valueList = [NSArray arrayWithObjects:[ProjectFunctions getUserDefaultValue:@"userName"], [ProjectFunctions getUserDefaultValue:@"password"], @"start", nil];
        NSString *webAddr = @"http://www.appdigity.com/poker/pokerFriendSendText.php";
        NSString *responseStr = [WebServicesFunctions getResponseFromServerUsingPost:webAddr fieldList:nameList valueList:valueList];
        NSLog(@"+++%@", responseStr);
    
	}
}


- (IBAction) startButtonPressed: (id) sender 
{
	
	float buyInAmount = [ProjectFunctions convertMoneyStringToDouble:buyinButton.titleLabel.text];
	if(buyInAmount==0) {
		[ProjectFunctions showAlertPopup:@"Buyin must be greater than 0" message:@""];
		return;
	}

	NSString *location = [NSString stringWithFormat:@"%@", locationButton.titleLabel.text];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name = %@", location];
	NSArray *items = [CoreDataLib selectRowsFromEntity:@"LOCATION" predicate:predicate sortColumn:nil mOC:managedObjectContext ascendingFlg:YES];
 
	NSString *GPSLatitude = [NSString stringWithFormat:@"%.6f", currentLocation.coordinate.latitude];
	NSString *GPSLongitude = [NSString stringWithFormat:@"%.6f", currentLocation.coordinate.longitude];
	if([items count]==0 && [GPSLatitude length]>1) {
		[CoreDataLib insertManagedObject:@"LOCATION" keyList:[NSArray arrayWithObjects:@"name", @"latitude", @"longitude", nil] valueList:[NSArray arrayWithObjects:location, GPSLatitude, GPSLongitude, nil] typeList:[NSArray arrayWithObjects:@"text", @"text", @"text", nil] mOC:managedObjectContext];
	}
	if([items count]>0 && [GPSLatitude length]>1) {
		NSManagedObject *mo = [items objectAtIndex:0];
		[mo setValue:[NSString stringWithFormat:@"%@", GPSLatitude] forKey:@"latitude"];
		[mo setValue:[NSString stringWithFormat:@"%@", GPSLongitude] forKey:@"longitude"];
		[managedObjectContext save:nil];
	}
	NSManagedObject *mo = [self insertnewGameIntoDatabase:@"In Progress"];
	[ProjectFunctions createChipTimeStamp:managedObjectContext mo:mo timeStamp:nil amount:0 rebuyFlg:NO];
    
    
    
	[self performSelectorInBackground:@selector(sendMessageWebRequest) withObject:nil];
	
	GameInProgressVC *detailViewController = [[GameInProgressVC alloc] initWithNibName:@"GameInProgressVC" bundle:nil];
	detailViewController.managedObjectContext = managedObjectContext;
	detailViewController.mo = mo;
	detailViewController.newGameStated=YES;
	[self.navigationController pushViewController:detailViewController animated:YES];
}

- (IBAction) viewLocationsButtonPressed: (id) sender
{
    ViewLocationsVC *detailViewController = [[ViewLocationsVC alloc] initWithNibName:@"ViewLocationsVC" bundle:nil];
	detailViewController.managedObjectContext = managedObjectContext;
    detailViewController.currentLocation=currentLocation;
    detailViewController.callBackViewController=self;
	[self.navigationController pushViewController:detailViewController animated:YES];
   
}

- (IBAction) completedButtonPressed: (id) sender 
{
    CreateOldGameVC *detailViewController = [[CreateOldGameVC alloc] initWithNibName:@"CreateOldGameVC" bundle:nil];
	detailViewController.managedObjectContext = managedObjectContext;
	[self.navigationController pushViewController:detailViewController animated:YES];
}

- (IBAction) mapButtonPressed: (id) sender
{
    MapKitTut *detailViewController = [[MapKitTut alloc] initWithNibName:@"MapKitTut" bundle:nil];
    detailViewController.lat = currentLocation.coordinate.latitude;
    detailViewController.lng = currentLocation.coordinate.longitude;
    [self.navigationController pushViewController:detailViewController animated:YES];
 
}

- (IBAction) retryButtonPressed: (id) sender
{
	[self.locationManager startUpdatingLocation];
	if(self.currentLocation) {
		[activityIndicator startAnimating];
		[self setLocationButtonTitle:@"Searching..." mode:0];
		NSLog(@"+++searching...");
		[self performSelectorInBackground:@selector(checkCurrentLocation) withObject:nil];
	} else
		[ProjectFunctions showAlertPopup:@"Error" message:@"Unable to access GPS"];
}




-(void)setSegmentBarToNewvalue:(UISegmentedControl *)segmentBar value:(NSString *)value
{
	[segmentBar setTitle:value forSegmentAtIndex:0];
	segmentBar.selectedSegmentIndex=0;
}

-(void)setLocationValue:(NSString *)value
{
    [locationButton setTitle:[NSString stringWithFormat:@"%@", value] forState:UIControlStateNormal];    
}

-(void) setReturningValue:(NSString *) value {
	
	if(selectedObjectForEdit==0) {
		double amount = [ProjectFunctions convertMoneyStringToDouble:value];
		[buyinButton setTitle:[ProjectFunctions convertNumberToMoneyString:amount] forState:UIControlStateNormal];
	}
	if(selectedObjectForEdit==1)
		[bankrollButton setTitle:[NSString stringWithFormat:@"%@", value] forState:UIControlStateNormal];
	if(selectedObjectForEdit==2)
		[locationButton setTitle:[NSString stringWithFormat:@"%@", value] forState:UIControlStateNormal];
	if(selectedObjectForEdit==4)
		[self setSegmentBarToNewvalue:gameNameSegmentBar value:value];
	if(selectedObjectForEdit==5)
		[self setSegmentBarToNewvalue:blindTypeSegmentBar value:value];
	if(selectedObjectForEdit==6)
		[self setSegmentBarToNewvalue:limitTypeSegmentBar value:value];
	if(selectedObjectForEdit==7)
		[self setSegmentBarToNewvalue:TourneyTypeSegmentBar value:value];
	
	
}

- (void)viewDidUnload {
    [super viewDidUnload];
	[self.locationManager stopUpdatingLocation];
	self.locationManager=nil;
}




@end
