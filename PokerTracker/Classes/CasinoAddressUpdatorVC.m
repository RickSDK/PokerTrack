//
//  CasinoAddressUpdatorVC.m
//  PokerTracker
//
//  Created by Rick Medved on 1/20/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "CasinoAddressUpdatorVC.h"
#import "SelectionCell.h"
#import "ListPicker.h"
#import "ProjectFunctions.h"
#import "TextLineEnterVC.h"
#import "WebServicesFunctions.h"

@implementation CasinoAddressUpdatorVC
@synthesize mainTableView, casinoName, casinoLabel, fieldArray, valueArray, selection, managedObjectContext;
@synthesize activityBGView, activityIndicator, activityLabel, casinoType, indianFlg;

#pragma mark -
#pragma mark View lifecycle

-(NSString *)parseCoord:(NSString *)line
{
	NSArray *components = [line componentsSeparatedByString:@":"];
	if([components count]>1)
		return [components objectAtIndex:1];
	return @"";
}

-(NSString *)parseJSON:(NSString *)json value:(NSString *)value
{
	NSArray *lines = [json componentsSeparatedByString:@"\n"];
	for(NSString *line in lines) {
		NSString *newline = [line stringByReplacingOccurrencesOfString:@" " withString:@""];
		newline = [newline stringByReplacingOccurrencesOfString:@"," withString:@""];
		if([newline length]>5) {
			if([[newline substringToIndex:5] isEqualToString:[NSString stringWithFormat:@"\"%@\"", value]])
				return [self parseCoord:newline];
		}
	}
	return @"";
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	[self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
}

-(void)submitAddress
{
	@autoreleasepool {

		NSString *googleAPI = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/geocode/json?address=%@&sensor=true", [valueArray componentsJoinedByString:@"+"]];
		NSString *response = [WebServicesFunctions getResponseFromWeb:googleAPI];
		NSString *lat = [self parseJSON:response value:@"lat"];
		NSString *lng = [self parseJSON:response value:@"lng"];
		
//	NSString  *lat = @"48.08805220";
//	NSString  *lng = @"-122.18625820";
		NSString *address = [NSString stringWithFormat:@"%@|%@|%@|%@|%@|%@", casinoName, casinoType, indianFlg, lat, lng, [valueArray componentsJoinedByString:@"|"]];
		NSArray *nameList = [NSArray arrayWithObjects:@"Username", @"Password", @"address", nil];
		NSArray *valueList = [NSArray arrayWithObjects:[ProjectFunctions getUserDefaultValue:@"userName"], [ProjectFunctions getUserDefaultValue:@"password"], address, nil];
		if([valueList count]==0) {
			valueList = [NSArray arrayWithObjects:@"test@aol.com", @"test123", address, nil];
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

-(void)submitPressed:(id)sender {
	for(NSString *field in valueArray)
		if([field length]==0) {
			[ProjectFunctions showAlertPopup:@"Error" message:@"All fields must be filled out!"];
			return;
		}
	
	[self executeThreadedJob:@selector(submitAddress)];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	[self setTitle:@"Enter Address"];
	
	NSLog(@"indianFlg: %@", indianFlg);
	casinoLabel.text = casinoName;
	
	fieldArray = [[NSMutableArray alloc] init];
	[fieldArray addObject:@"Country"];
	[fieldArray addObject:@"Street"];
	[fieldArray addObject:@"City"];
	[fieldArray addObject:@"State"];
	[fieldArray addObject:@"Postal"];
	[fieldArray addObject:@"Phone"];
	valueArray = [[NSMutableArray alloc] init];
	[valueArray addObject:@"USA"];
	[valueArray addObject:@""];
	[valueArray addObject:@""];
	[valueArray addObject:@"AK"];
	[valueArray addObject:@""];
	[valueArray addObject:@""];

	UIBarButtonItem *submitButton = [[UIBarButtonItem alloc] initWithTitle:@"Submit" style:UIBarButtonItemStylePlain target:self action:@selector(submitPressed:)];
	self.navigationItem.rightBarButtonItem = submitButton;
	
	activityBGView.alpha=0;
	activityLabel.alpha=0;


    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [fieldArray count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    SelectionCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[SelectionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    cell.textLabel.text = [fieldArray objectAtIndex:indexPath.row];
	cell.selection.text = [valueArray objectAtIndex:indexPath.row];
    return cell;
}





#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	selection=indexPath.row;
	if(selection==0) {
		ListPicker *detailViewController = [[ListPicker alloc] initWithNibName:@"ListPicker" bundle:nil];
		detailViewController.initialDateValue = [valueArray objectAtIndex:indexPath.row];
		detailViewController.titleLabel = [fieldArray objectAtIndex:indexPath.row];
		detailViewController.callBackViewController = self;
		detailViewController.selectionList = [ProjectFunctions getCountryArray];
		detailViewController.allowEditing=YES;
		[self.navigationController pushViewController:detailViewController animated:YES];
	} else if(selection==3 && [[valueArray objectAtIndex:0] isEqualToString:@"USA"]) {
		ListPicker *detailViewController = [[ListPicker alloc] initWithNibName:@"ListPicker" bundle:nil];
		detailViewController.initialDateValue = [valueArray objectAtIndex:indexPath.row];
		detailViewController.titleLabel = [fieldArray objectAtIndex:indexPath.row];
		detailViewController.callBackViewController = self;
		detailViewController.selectionList = [ProjectFunctions getStateArray];
		detailViewController.allowEditing=YES;
		[self.navigationController pushViewController:detailViewController animated:YES];
	} else {
		TextLineEnterVC *detailViewController = [[TextLineEnterVC alloc] initWithNibName:@"TextLineEnterVC" bundle:nil];
		detailViewController.initialDateValue = [valueArray objectAtIndex:indexPath.row];
		detailViewController.titleLabel = [fieldArray objectAtIndex:indexPath.row];
		detailViewController.callBackViewController = self;
		[self.navigationController pushViewController:detailViewController animated:YES];
	}		
}

-(void) setReturningValue:(NSString *) value2 {
	NSString *value = [ProjectFunctions getUserDefaultValue:@"returnValue"];
	[valueArray replaceObjectAtIndex:selection withObject:value];
	[mainTableView reloadData];
}

#pragma mark -





@end

