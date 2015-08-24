//
//  CasinoTrackerEditVC.m
//  PokerTracker
//
//  Created by Rick Medved on 1/18/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "CasinoTrackerEditVC.h"
#import "ProjectFunctions.h"
#import "CasinoAddressUpdatorVC.h"
#import "LoginVC.h"
#import "WebServicesFunctions.h"
#import "NSArray+ATTArray.h"

@implementation CasinoTrackerEditVC
@synthesize locationButton, addressButton, casinoType, checkbox, casinoName, indianCasino, currentLocation, managedObjectContext;
@synthesize activityBGView, activityIndicator, activityLabel, latLabel, cityLabel, cityFound, gpsTextView, addressString;


#pragma mark -
#pragma mark View lifecycle

-(BOOL)textField:(UITextField *)textFieldlocal shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
	if([casinoName.text length]>0) {
		addressButton.enabled=YES;
		if(currentLocation!=nil)
			locationButton.enabled=YES;
	}
	
	return [ProjectFunctions limitTextFieldLength:textFieldlocal currentText:casinoName.text string:string limit:20 saveButton:nil resignOnReturn:YES];
}

-(BOOL)textFieldShouldReturn:(UITextField *)aTextField {
	[aTextField resignFirstResponder];
	return YES;
}

- (IBAction) checkboxPressed: (id) sender
{
	if(indianCasino) {
		[checkbox setImage:[UIImage imageNamed:@"UnSelectedCheckBox.png"] forState:UIControlStateNormal];
		indianCasino=NO;
	} else {
		indianCasino=YES;
		[checkbox setImage:[UIImage imageNamed:@"SelectedCheckBox.png"] forState:UIControlStateNormal];
	}
}

- (IBAction) addressPressed: (id) sender
{
	if([casinoName.text length]<3) {
		[ProjectFunctions showAlertPopup:@"Error" message:@"Invalid Casino Name"];
		return;
	}
	CasinoAddressUpdatorVC *localViewController = [[CasinoAddressUpdatorVC alloc] initWithNibName:@"CasinoAddressUpdatorVC" bundle:nil];
	localViewController.casinoName=casinoName.text;
	localViewController.casinoType=(casinoType.selectedSegmentIndex==0)?@"Casino":@"Card Room";
	localViewController.indianFlg=(indianCasino)?@"Y":@"N";
	localViewController.managedObjectContext=managedObjectContext;
	[self.navigationController pushViewController:localViewController animated:YES];
}

-(NSString *)parseCoord:(NSString *)line
{
	NSString *final = @"";
	NSArray *components = [line componentsSeparatedByString:@":"];
	if([components count]>1) {
		final = [components objectAtIndex:1];
		NSArray *groups = [final componentsSeparatedByString:@"\""];
		if([groups count]>1) {
			NSString *goodstuff = [groups objectAtIndex:1];
			NSArray *mixes = [goodstuff componentsSeparatedByString:@", "];
			if([mixes count]>3) {
				NSArray *stateZip = [[mixes objectAtIndex:2] componentsSeparatedByString:@" "];
				final = [NSString stringWithFormat:@"%@|%@|%@|%@|%@", [mixes stringAtIndex:3], [mixes stringAtIndex:0], [mixes stringAtIndex:1], [stateZip stringAtIndex:0], [stateZip stringAtIndex:1]];
			}
		}
	}
	return final;
}

-(NSString *)getFormattedAddress:(NSString *)response value:(NSString *)value
{
	NSArray *lines = [response componentsSeparatedByString:@"\n"];
	for(NSString *line in lines) {
		NSString *newline = [line stringByReplacingOccurrencesOfString:@" " withString:@""];
		if([newline length]>19) {
			if([[newline substringToIndex:19] isEqualToString:[NSString stringWithFormat:@"\"%@\"", value]])
				return [self parseCoord:line];
		}
	}
	return @"";
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	[self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
}



-(void)addCasino
{
	@autoreleasepool {
		NSString *lat = [NSString stringWithFormat:@"%.6f", currentLocation.coordinate.latitude];
		NSString *lng = [NSString stringWithFormat:@"%.6f", currentLocation.coordinate.longitude];

		if(currentLocation==nil) {
			[ProjectFunctions showAlertPopup:@"Error" message:@"Sorry, location not found!"];
			return;
		}
		if(lat==0 && lng==0) {
			[ProjectFunctions showAlertPopup:@"Error" message:@"Sorry, lat and lng not found!"];
			return;
		}
		
//	NSString  *lat = @"48.08805220";
//	NSString  *lng = @"-122.18625820";
		
		NSString *address=addressString;
		if(0) {
		
			NSString *googleAPI = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/geocode/json?latlng=%@,%@&sensor=true", lat, lng];
			NSString *response = [WebServicesFunctions getResponseFromWeb:googleAPI];
		
			address = [self getFormattedAddress:response value:@"formatted_address"];
		}
		
		
		NSString *indianFlg = (indianCasino)?@"Y":@"N";
		NSArray *valueArray = [address componentsSeparatedByString:@"|"];
		NSString *type = (casinoType.selectedSegmentIndex==0)?@"Casino":@"Card Room";
		
		NSString *casinoNameStr = [ProjectFunctions formatFieldForWebService:casinoName.text];
		
		NSString *xml = [NSString stringWithFormat:@"%@|%@|%@|%@|%@|%@", casinoNameStr, type, indianFlg, lat, lng, [valueArray componentsJoinedByString:@"|"]];
		NSArray *nameList = [NSArray arrayWithObjects:@"Username", @"Password", @"address", nil];
		NSArray *valueList = [NSArray arrayWithObjects:[ProjectFunctions getUserDefaultValue:@"userName"], [ProjectFunctions getUserDefaultValue:@"password"], xml, nil];
		if([valueList count]==0) {
			valueList = [NSArray arrayWithObjects:@"test@aol.com", @"test123", xml, nil];
		}
		NSString *webAddr = @"http://www.appdigity.com/poker/pokerCasinoAddress.php";
		NSString *responseStr = [WebServicesFunctions getResponseFromServerUsingPost:webAddr fieldList:nameList valueList:valueList];
		if([WebServicesFunctions validateStandardResponse:responseStr delegate:nil]) {
			[ProjectFunctions showAlertPopupWithDelegate:@"Success" message:@"Casino added!" delegate:self];
		}
		
		activityBGView.alpha=0;
		activityLabel.alpha=0;
		[activityIndicator stopAnimating];
	}
	
}

-(void)executeThreadedJob:(SEL)aSelector
{
	activityBGView.alpha=1;
	activityLabel.alpha=1;
	[activityIndicator startAnimating];
	[self performSelectorInBackground:aSelector withObject:nil];
}

- (IBAction) locationPressed: (id) sender {
	[casinoName resignFirstResponder];
	if([casinoName.text length]<3) {
		[ProjectFunctions showAlertPopup:@"Error" message:@"Invalid Casino Name"];
		return;
	}
	if([cityLabel.text isEqualToString:@"OVER_QUERY_LIMIT"]) {
		[ProjectFunctions showAlertPopup:@"Sorry" message:@"Unable to use Google API today. Enter address manually."];
		return;
	}
	if(!cityFound) {
		[ProjectFunctions showAlertPopup:@"Sorry" message:@"Unable to locate city using GPS. Press refresh below or enter address manually."];
		return;
	}
	[self executeThreadedJob:@selector(addCasino)];
}

-(void)loginButtonClicked:(id)sender {
	if([ProjectFunctions getUserDefaultValue:@"userName"]) {
		[ProjectFunctions setUserDefaultValue:nil forKey:@"emailAddress"];
		[ProjectFunctions setUserDefaultValue:nil forKey:@"userName"];
	}
	LoginVC *detailViewController = [[LoginVC alloc] initWithNibName:@"LoginVC" bundle:nil];
	detailViewController.managedObjectContext = managedObjectContext;
	[self.navigationController pushViewController:detailViewController animated:YES];
}

-(void)locateCity
{
	@autoreleasepool {
		[NSThread sleepForTimeInterval:.5];
		NSString *lat = [NSString stringWithFormat:@"%.6f", currentLocation.coordinate.latitude];
		NSString *lng = [NSString stringWithFormat:@"%.6f", currentLocation.coordinate.longitude];
		if(0) {
			lat = @"48.08805220";
			lng = @"-122.18625820";
		}
		
		if(currentLocation != nil) {
		
			NSString *googleAPI = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/geocode/json?latlng=%@,%@&sensor=true", lat, lng];
			NSString *response = [WebServicesFunctions getResponseFromWeb:googleAPI];
			gpsTextView.alpha=0;
			gpsTextView.text=response;
			
			NSString *address = [self getFormattedAddress:response value:@"formatted_address"];
			self.addressString = address;
			NSArray *parts = [address componentsSeparatedByString:@"|"];
			NSString *city = @"";
			if([parts count]>2)
				city = [parts stringAtIndex:2];
			if([city length]>0)
				self.cityFound=YES;
			
			if([response rangeOfString:@"OVER_QUERY_LIMIT"].location != NSNotFound)
				city=@"OVER_QUERY_LIMIT";

        [cityLabel performSelectorOnMainThread:@selector(setText: ) withObject:city waitUntilDone:YES];
		}
		[activityIndicator stopAnimating];
	}
}

-(void)findCity
{
	[activityIndicator startAnimating];
	cityLabel.text=@"";
	[self performSelectorInBackground:@selector(locateCity) withObject:nil];
}

- (IBAction) refreshPressed: (id) sender
{
	[self findCity];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	[self setTitle:@"Add Casino"];
	
	locationButton.enabled=NO;
	addressButton.enabled=NO;
	indianCasino=NO;
	
	[self findCity];

	/*
	if(![ProjectFunctions getUserDefaultValue:@"userName"]) {
		[ProjectFunctions showAlertPopup:@"Notice" :@"You must create a username before using this feature. Click the 'Login' button at the top of this screen to get started."];
		UIBarButtonItem *moreButton = [[UIBarButtonItem alloc] initWithTitle:@"Login" style:UIBarButtonItemStylePlain target:self action:@selector(loginButtonClicked:)];
		self.navigationItem.rightBarButtonItem = moreButton;
		[moreButton release];
		casinoName.enabled=NO;
		casinoType.enabled=NO;
		
	}
	 */

	activityBGView.alpha=0;
	activityLabel.alpha=0;
	
	latLabel.text = [NSString stringWithFormat:@"Lat: %.6f    Lng: %.6f", currentLocation.coordinate.latitude, currentLocation.coordinate.longitude];
	

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}



#pragma mark -
#pragma mark Memory management





@end

