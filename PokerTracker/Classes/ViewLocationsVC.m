//
//  ViewLocationsVC.m
//  PokerTracker
//
//  Created by Rick Medved on 7/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewLocationsVC.h"
#import "SelectionCell.h"
#import "ProjectFunctions.h"
#import "CoreDataLib.h"
#import "NSArray+ATTArray.h"
#import "WebServicesFunctions.h"
#import "UIColor+ATTColor.h"
#import "StartNewGameVC.h"

@implementation ViewLocationsVC
@synthesize managedObjectContext, activityIndicator, activityPopup, activityLabel;
@synthesize deviceLocs, serverLocs, currentLocation, mainTableView, callBackViewController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if(section==0)
		return [deviceLocs count];
    else
        return [serverLocs count];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 44;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	NSArray *titles = [NSArray arrayWithObjects:@"Device Locations", @"Server Locations", nil];
	return [ProjectFunctions getViewForHeaderWithText:[titles objectAtIndex:section]];
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return 22;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
    
	NSString *cellIdentifier = [NSString stringWithFormat:@"cellIdentifierSection%dRow%d", (int)indexPath.section, (int)indexPath.row];
    
    SelectionCell *cell = (SelectionCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[SelectionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.backgroundColor = [UIColor ATTFaintBlue];
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    
    if(indexPath.section==0) {
        NSString *cellVal = [deviceLocs objectAtIndex:indexPath.row];
        NSArray *items = [cellVal componentsSeparatedByString:@"|"];
    
        cell.textLabel.text = [items stringAtIndex:0];
        cell.selection.text = [items stringAtIndex:1];
    } else {
        NSString *cellVal = [serverLocs objectAtIndex:indexPath.row];
        NSArray *items = [cellVal componentsSeparatedByString:@"|"];
        
        cell.textLabel.text = [items stringAtIndex:0];
        cell.selection.text = [items stringAtIndex:1];
    }
    
    return cell;
}

-(void)loadCloseCasinos:(CLLocation *)currentLoc moc:(NSManagedObjectContext *)moc
{
	
	if(currentLoc==nil)	
		return;
    
    float fromLatitude = currentLoc.coordinate.latitude;
    float fromLongitude = currentLoc.coordinate.longitude;
    float distance=99.1;
    
	NSArray *items = [CoreDataLib selectRowsFromTable:@"LOCATION" mOC:moc];
	for(NSManagedObject *mo in items) {
		NSString *lat = [mo valueForKey:@"latitude"];
		NSString *longitude = [mo valueForKey:@"longitude"];
		if([lat length]>1) {
			distance = [ProjectFunctions getDistanceFromTarget:fromLatitude fromLong:fromLongitude toLat:[lat floatValue] toLong:[longitude floatValue]];
            if(distance<10)
                [deviceLocs addObject:[NSString stringWithFormat:@"%@|%.1f", [mo valueForKey:@"name"], distance]];
		}
	} // <-- for
}

-(void)loadServerCasinos:(CLLocation *)currentLoc
{
	NSString *latitude = [NSString stringWithFormat:@"%.6f", currentLoc.coordinate.latitude];
	NSString *longitutde = [NSString stringWithFormat:@"%.6f", currentLoc.coordinate.longitude];
	NSArray *nameList = [NSArray arrayWithObjects:@"Username", @"Password", @"lat", @"lng", @"distance", nil];
	
	NSString *userName = @"test@test.com";
	NSString *password = @"test";
	if([[ProjectFunctions getUserDefaultValue:@"userName"] length]>0)
		userName = [ProjectFunctions getUserDefaultValue:@"userName"];
	if([ProjectFunctions getUserDefaultValue:@"password"])
		password = [ProjectFunctions getUserDefaultValue:@"password"];
	
	NSArray *valueList = [NSArray arrayWithObjects:userName, password, latitude, longitutde, @"10", nil];
	NSString *webAddr = @"http://www.appdigity.com/poker/pokerCasinoLookup.php";
	NSString *responseStr = [WebServicesFunctions getResponseFromServerUsingPost:webAddr fieldList:nameList valueList:valueList];
	if([WebServicesFunctions validateStandardResponse:responseStr delegate:nil]) {
		NSArray *casinos = [responseStr componentsSeparatedByString:@"<li>"];
		
		float distance = 3;
		for(NSString *casino in casinos) {
			NSArray *items = [casino componentsSeparatedByString:@"|"];
			NSString *lat = [items stringAtIndex:6];
			NSString *lng = [items stringAtIndex:7];
			distance = 30;
			if([lat length]>1 && [lat floatValue]!=0) {
				distance = [ProjectFunctions getDistanceFromTarget:currentLoc.coordinate.latitude fromLong:currentLoc.coordinate.longitude toLat:[lat floatValue] toLong:[lng floatValue]];
			}
			if(distance<10) {
                [serverLocs addObject:[NSString stringWithFormat:@"%@|%.1f", [items stringAtIndex:1], distance]];
			}
		} // <-- for
	}
    
}


-(void)refreshWebRequest
{
	@autoreleasepool {
    
        [self loadServerCasinos:currentLocation];
        
        [activityIndicator stopAnimating];
        activityPopup.alpha=0;
        activityLabel.alpha=0;
        [mainTableView reloadData];
	}
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if([self respondsToSelector:@selector(edgesForExtendedLayout)])
        [self setEdgesForExtendedLayout:UIRectEdgeBottom];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	[self setTitle:@"Locations"];
    
    [self.mainTableView setBackgroundView:nil];

    
    deviceLocs = [[NSMutableArray alloc] initWithCapacity:100];
    serverLocs = [[NSMutableArray alloc] initWithCapacity:100];
    
    [activityIndicator startAnimating];
    activityPopup.alpha=1;
    activityLabel.alpha=1;
    
    [self loadCloseCasinos:currentLocation moc:managedObjectContext];
    [mainTableView reloadData];
    [self performSelectorInBackground:@selector(refreshWebRequest) withObject:nil];

    
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *casinoName = @"";
    if(indexPath.section==0) {
        NSArray *components = [[deviceLocs objectAtIndex:indexPath.row] componentsSeparatedByString:@"|"];
        casinoName = [components stringAtIndex:0];
    } else {
        NSArray *components = [[serverLocs objectAtIndex:indexPath.row] componentsSeparatedByString:@"|"];
        casinoName = [components stringAtIndex:0];
    }
    [(StartNewGameVC *)callBackViewController setLocationValue:casinoName];
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


@end
