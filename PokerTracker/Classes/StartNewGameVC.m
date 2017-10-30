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
@synthesize managedObjectContext, bankrollLabel, locationLabel;
@synthesize gameTypeSegmentBar, gameNameSegmentBar, blindTypeSegmentBar, limitTypeSegmentBar, TourneyTypeSegmentBar;
@synthesize locationManager, currentLocation;
@synthesize selectedObjectForEdit, activityIndicator, buyinLabel, addCasinoFlg;


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[super viewDidLoad];
	[self setTitle:NSLocalizedString(@"Game", nil)];
	
	self.popupView.titleLabel.text=@"Options";
	
	self.selectedObjectForEdit=0;
	self.addCasinoButton.enabled=NO;
	
	self.navigationItem.rightBarButtonItem = [ProjectFunctions UIBarButtonItemWithIcon:[NSString fontAwesomeIconStringForEnum:FACog] target:self action:@selector(popupButtonClicked)];

	self.buyinLabel.text = NSLocalizedString(@"Buyin", nil);
	self.locationTextLabel.text = NSLocalizedString(@"location", nil);
	
	self.bankrollLabel.text = NSLocalizedString(@"bankroll", nil);
	[self.completedButton setTitle:NSLocalizedString(@"Completed", nil) forState:UIControlStateNormal];
	[self.completed2Button setTitle:NSLocalizedString(@"Completed", nil) forState:UIControlStateNormal];
	[ProjectFunctions makeFALabel:self.locationLabel type:13 size:22];
	[ProjectFunctions makeFAButton:self.retryButton type:12 size:18];
	[ProjectFunctions makeFAButton:self.addCasinoButton type:1 size:18];
	[ProjectFunctions makeFAButton:self.startLiveButton type:9 size:30 text:NSLocalizedString(@"Start", nil)];
	
	[ProjectFunctions newButtonLook:self.completedButton mode:2];
	[ProjectFunctions newButtonLook:self.completed2Button mode:2];
	[ProjectFunctions newButtonLook:self.buyinButton mode:0];
	[ProjectFunctions newButtonLook:self.buyinPopupButton mode:0];
	[ProjectFunctions newButtonLook:self.chipsPopupButton mode:0];
	
	[ProjectFunctions populateSegmentBar:self.blindTypeSegmentBar mOC:self.managedObjectContext];
	
	[ProjectFunctions initializeSegmentBar:gameNameSegmentBar defaultValue:[ProjectFunctions getUserDefaultValue:@"gameNameDefault"] field:@"gametype"];
	[ProjectFunctions initializeSegmentBar:blindTypeSegmentBar defaultValue:[ProjectFunctions getUserDefaultValue:@"blindDefault"] field:@"stakes"];
	[ProjectFunctions initializeSegmentBar:limitTypeSegmentBar defaultValue:[ProjectFunctions getUserDefaultValue:@"limitDefault"] field:@"limit"];
	[ProjectFunctions initializeSegmentBar:TourneyTypeSegmentBar defaultValue:[ProjectFunctions getUserDefaultValue:@"tourneyTypeDefault"] field:@"tournamentType"];
	
	gameNameSegmentBar.selectedSegmentIndex = [ProjectFunctions getSegmentValueForSegment:0 currentValue:[ProjectFunctions getUserDefaultValue:@"gameNameDefault"] startGameScreen:YES];
	limitTypeSegmentBar.selectedSegmentIndex = [ProjectFunctions getSegmentValueForSegment:2 currentValue:[ProjectFunctions getUserDefaultValue:@"limitDefault"] startGameScreen:YES];
	TourneyTypeSegmentBar.selectedSegmentIndex = [ProjectFunctions getSegmentValueForSegment:3 currentValue:[ProjectFunctions getUserDefaultValue:@"tourneyTypeDefault"] startGameScreen:YES];
	
	[self.bankrollButton setTitle:[ProjectFunctions getUserDefaultValue:@"bankrollDefault"] forState:UIControlStateNormal];
	[self.locationButton setTitle:[ProjectFunctions getUserDefaultValue:@"locationDefault"] forState:UIControlStateNormal];
	
	self.tournyPopupView.titleLabel.text = @"Tournament Buy-in";
	self.buyinPopupLabel.text = NSLocalizedString(@"buyInAmount", nil);
	self.chipsPopupLabel.text = NSLocalizedString(@"Starting Chips", nil);
	self.tournyPopupView.hidden=YES;
	
	[self.gameTypeSegmentBar turnIntoGameSegment];
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
	
	self.trackChipsSwitch.on = [ProjectFunctions trackChipsSwitchValue];
	[self setupSegments];
	
	[self startLocationManager];
	[self checkLocation];
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

-(void)startLocationManager {
	if(self.locationManager==nil)
		self.locationManager = [[CLLocationManager alloc] init];
	self.locationManager.delegate = self;
//	self.locationManager.distanceFilter = kCLDistanceFilterNone;
	self.locationManager.distanceFilter = 500;
	self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
	[self.locationManager startUpdatingLocation];
	if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
		[self.locationManager requestWhenInUseAuthorization];
		[self.locationManager startMonitoringSignificantLocationChanges];
	}
}

-(void)checkLocation {
	self.startLiveButton.enabled=NO;
	self.locationButton.enabled=NO;
	[activityIndicator startAnimating];
	[self setLocationButtonTitle:@"Searching..." mode:0];
	[self performSelectorInBackground:@selector(checkCurrentLocation) withObject:nil];
}

- (void)startSignificantChangeUpdates
{
	// Create the location manager if this object does not
	// already have one.
	if (nil == locationManager)
		locationManager = [[CLLocationManager alloc] init];
 
	locationManager.delegate = self;
	[locationManager startMonitoringSignificantLocationChanges];
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
		
		currentLocation = newLocation;
		
        NSLog(@"latitude %+.6f, longitude %+.6f\n",
			  newLocation.coordinate.latitude,
			  newLocation.coordinate.longitude);
    }
 }

-(void)setupSegments
{
	NSString *buyinAmount = @"";
	[gameTypeSegmentBar gameSegmentChanged];
	if(gameTypeSegmentBar.selectedSegmentIndex==0) {
 		blindTypeSegmentBar.alpha=1;
		TourneyTypeSegmentBar.alpha=0;
		[ProjectFunctions setUserDefaultValue:@"Cash" forKey:@"gameTypeDefault"];
		buyinAmount = [ProjectFunctions getUserDefaultValue:@"buyinDefault"];
		[self setTitle:[NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Cash", nil), NSLocalizedString(@"Game", nil)]];
		[self.buyinButton setTitle:[NSString stringWithFormat:@"%@", [ProjectFunctions convertStringToMoneyString:buyinAmount]] forState:UIControlStateNormal];
		self.locationButton.frame = CGRectMake(20, 154, 280, 50);
	} else {
		blindTypeSegmentBar.alpha=0;
		TourneyTypeSegmentBar.alpha=1;
		[ProjectFunctions setUserDefaultValue:@"Tournament" forKey:@"gameTypeDefault"];
		[self setTitle:NSLocalizedString(@"Tournament", nil)];
		[self setupTournamentBuyinButton];
		self.locationButton.frame = CGRectMake(20, 154, 225, 50);
	}
	self.trackChipsView.hidden=(gameTypeSegmentBar.selectedSegmentIndex==0);
}

-(void)setupTournamentBuyinButton {
	NSString *buyinAmount = [ProjectFunctions getUserDefaultValue:@"tournbuyinDefault"];
	[self.buyinPopupButton setTitle:[NSString stringWithFormat:@"%@", [ProjectFunctions convertStringToMoneyString:buyinAmount]] forState:UIControlStateNormal];
	if ([ProjectFunctions trackChipsSwitchValue]) {
		[self.buyinButton setTitle:NSLocalizedString(@"-Click Here-", nil) forState:UIControlStateNormal];
	} else {
		[self.buyinButton setTitle:[ProjectFunctions convertStringToMoneyString:buyinAmount] forState:UIControlStateNormal];
	}
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
		[gameNameSegmentBar changeSegment];
		[self gotoListPicker:@"gametype" initialDateValue:@""];
	}
}
- (IBAction) stakesSegmentPressed: (id) sender 
{
	self.selectedObjectForEdit=5;
	if(blindTypeSegmentBar.selectedSegmentIndex==4) {
		blindTypeSegmentBar.selectedSegmentIndex=0;
		[blindTypeSegmentBar changeSegment];
		[self gotoListPicker:@"stakes" initialDateValue:@""];
	}
}
- (IBAction) limitSegmentPressed: (id) sender 
{
	self.selectedObjectForEdit=6;
	if(limitTypeSegmentBar.selectedSegmentIndex==3) {
		limitTypeSegmentBar.selectedSegmentIndex=0;
		[limitTypeSegmentBar changeSegment];
		[self gotoListPicker:@"limit" initialDateValue:@""];
	}
}

- (IBAction) tournSegmentPressed: (id) sender 
{
	self.selectedObjectForEdit=7;
	if(TourneyTypeSegmentBar.selectedSegmentIndex==3) {
		TourneyTypeSegmentBar.selectedSegmentIndex=0;
		[TourneyTypeSegmentBar changeSegment];
		[self gotoListPicker:@"tournamentType" initialDateValue:@""];
	}
}


- (IBAction) locationButtonPressed: (id) sender
{
	self.selectedObjectForEdit=2;
	[self gotoListPicker:@"location" initialDateValue:[self.locationButton titleForState:UIControlStateNormal]];
}

- (IBAction) bankrollButtonPressed: (id) sender 
{
	self.selectedObjectForEdit=1;
	[self gotoListPicker:@"bankroll" initialDateValue:[self.bankrollButton titleForState:UIControlStateNormal]];
}
- (IBAction) buyinPopupButtonPressed: (id) sender
{
	self.selectedObjectForEdit=0;
	MoneyPickerVC *detailViewController = [[MoneyPickerVC alloc] initWithNibName:@"MoneyPickerVC" bundle:nil];
	detailViewController.managedObjectContext=managedObjectContext;
	detailViewController.callBackViewController = self;
	detailViewController.titleLabel = @"Buy-in";
	detailViewController.initialDateValue = [NSString stringWithFormat:@"%@", [self.buyinButton titleForState:UIControlStateNormal]];
	[self.navigationController pushViewController:detailViewController animated:YES];
}
- (IBAction) chipsPopupButtonPressed: (id) sender
{
	self.selectedObjectForEdit=13;
	MoneyPickerVC *detailViewController = [[MoneyPickerVC alloc] initWithNibName:@"MoneyPickerVC" bundle:nil];
	detailViewController.managedObjectContext=managedObjectContext;
	detailViewController.callBackViewController = self;
	detailViewController.titleLabel = @"Starting Chips";
	detailViewController.initialDateValue = [NSString stringWithFormat:@"%@", [self.chipsPopupButton titleForState:UIControlStateNormal]];
	[self.navigationController pushViewController:detailViewController animated:YES];
}
- (IBAction) buyinButtonPressed: (id) sender
{
	if(self.gameTypeSegmentBar.selectedSegmentIndex==1) {
		self.tournyPopupView.hidden=!self.tournyPopupView.hidden;
		return;
	}
	self.selectedObjectForEdit=0;
	MoneyPickerVC *detailViewController = [[MoneyPickerVC alloc] initWithNibName:@"MoneyPickerVC" bundle:nil];
	detailViewController.managedObjectContext=managedObjectContext;
	detailViewController.callBackViewController = self;
	detailViewController.titleLabel = @"Buy-in";
	detailViewController.initialDateValue = [NSString stringWithFormat:@"%@", [self.buyinButton titleForState:UIControlStateNormal]];
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
	NSString *game = [self scrubValue:[gameNameSegmentBar titleForSegmentAtIndex:gameNameSegmentBar.selectedSegmentIndex]];
	NSString *stakes = [self scrubValue:[blindTypeSegmentBar titleForSegmentAtIndex:blindTypeSegmentBar.selectedSegmentIndex]];
	NSString *limit = [self scrubValue:[limitTypeSegmentBar titleForSegmentAtIndex:limitTypeSegmentBar.selectedSegmentIndex]];
	NSString *tourney = [self scrubValue:[TourneyTypeSegmentBar titleForSegmentAtIndex:TourneyTypeSegmentBar.selectedSegmentIndex]];
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
	float buyInAmount = [ProjectFunctions convertMoneyStringToDouble:[self.buyinButton titleForState:UIControlStateNormal]];
	float startingChipsAmount = [ProjectFunctions convertMoneyStringToDouble:[self.chipsPopupButton titleForState:UIControlStateNormal]];
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
						   [NSString stringWithFormat:@"%@", [self.locationButton titleForState:UIControlStateNormal]],
						   [NSString stringWithFormat:@"%@", [self.bankrollButton titleForState:UIControlStateNormal]],
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
	[mo setValue:[NSString stringWithFormat:@"%d", (int)startingChipsAmount] forKey:@"attrib05"];
	[mo setValue:[NSString stringWithFormat:@"%d", (int)startingChipsAmount] forKey:@"hudHeroLine"];
	[ProjectFunctions scrubDataForObj:mo context:self.managedObjectContext];
	return mo;
}

-(NSString *)scrubValue:(NSString *)value {
	return [value stringByReplacingOccurrencesOfString:[NSString fontAwesomeIconStringForEnum:FACheck] withString:@""];
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
	self.locationButton.titleLabel.text = title;
	[self.locationButton setTitle:title forState:UIControlStateNormal];
}

-(void)checkCurrentLocation
{
	@autoreleasepool {
		NSLog(@"+++latitude: %f", currentLocation.coordinate.latitude);
		[NSThread sleepForTimeInterval:4];
		NSLog(@"+++latitude (after 4 seconds): %f", currentLocation.coordinate.latitude);
		
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
		
		[activityIndicator stopAnimating];
		[self.locationManager stopUpdatingLocation];
		self.locationButton.enabled=YES;
		self.startLiveButton.enabled=YES;
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

-(BOOL)chipCheckBuyin:(NSString *)buyinStr {
	float buyInAmount = [ProjectFunctions convertMoneyStringToDouble:buyinStr];
	if(buyInAmount==0) {
		[ProjectFunctions showAlertPopup:NSLocalizedString(@"notice", nil) message:NSLocalizedString(@"Buy-in amount must be greater than 0", nil)];
		return NO;
	}
	if(self.gameTypeSegmentBar.selectedSegmentIndex==1 && [ProjectFunctions trackChipsSwitchValue]) {
		float buyInAmount = [ProjectFunctions convertMoneyStringToDouble:[self.chipsPopupButton titleForState:UIControlStateNormal]];
		if(buyInAmount==0) {
			self.tournyPopupView.hidden=NO;
			[ProjectFunctions showAlertPopup:NSLocalizedString(@"notice", nil) message:NSLocalizedString(@"Starting chips must be greater than 0", nil)];
			return NO;
		}
	}
	return YES;
}

- (IBAction) trackChipsSwitchPressed: (id) sender {
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults setObject:[NSNumber numberWithBool:self.trackChipsSwitch.on] forKey:@"trackChipsSwitch"];
	[self setupTournamentBuyinButton];
}

- (IBAction) trackChipsInfoPressed: (id) sender {
	[ProjectFunctions showAlertPopup:@"Track Chips" message:@"With this feature activated you can track your tournament chips throughout the tournament which will be plotted on the game graph."];
}

- (IBAction) okButtonPressed: (id) sender {
	[self.buyinButton setTitle:[self.buyinPopupButton titleForState:UIControlStateNormal] forState:UIControlStateNormal];
	if(![self chipCheckBuyin:[self.buyinPopupButton titleForState:UIControlStateNormal]])
		return;
	self.tournyPopupView.hidden=YES;
}

- (IBAction) startButtonPressed: (id) sender 
{
	if(![self chipCheckBuyin:[self.buyinButton titleForState:UIControlStateNormal]])
		return;

	NSString *location = [self.locationButton titleForState:UIControlStateNormal];
	
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
	[self checkLocation];
}

-(void)setSegmentBarToNewvalue:(UISegmentedControl *)segmentBar value:(NSString *)value
{
	[segmentBar setTitle:value forSegmentAtIndex:0];
	segmentBar.selectedSegmentIndex=0;
}

-(void)setLocationValue:(NSString *)value
{
    [self.locationButton setTitle:[NSString stringWithFormat:@"%@", value] forState:UIControlStateNormal];
}

-(void) setReturningValue:(NSString *) value {
	NSLog(@"setReturningValue: %@", value);
	if(selectedObjectForEdit==0) {
		double amount = [ProjectFunctions convertMoneyStringToDouble:value];
		[self.buyinButton setTitle:[ProjectFunctions convertNumberToMoneyString:amount] forState:UIControlStateNormal];
		[self.buyinPopupButton setTitle:[ProjectFunctions convertNumberToMoneyString:amount] forState:UIControlStateNormal];
	}
	if(selectedObjectForEdit==13) {
//		double amount = [ProjectFunctions convertMoneyStringToDouble:value];
		[self.chipsPopupButton setTitle:value forState:UIControlStateNormal];
	}
	if(selectedObjectForEdit==1)
		[self.bankrollButton setTitle:value forState:UIControlStateNormal];
	if(selectedObjectForEdit==2)
		[self.locationButton setTitle:value forState:UIControlStateNormal];
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
