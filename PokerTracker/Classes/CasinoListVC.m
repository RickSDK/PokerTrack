//
//  CasinoListVC.m
//  PokerTracker
//
//  Created by Rick Medved on 1/25/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "CasinoListVC.h"
#import "WebServicesFunctions.h"
#import "QuadWithImageTableViewCell.h"
#import "ProjectFunctions.h"
#import "CasinoEditorVC.h"
#import "NSArray+ATTArray.h"


@implementation CasinoListVC
@synthesize activityIndicator, mainTableView, statsArray, topLabel, stateCountry, currentLocation, managedObjectContext;
-(void)statLookup
{
	@autoreleasepool {
	
	
		NSArray *nameList = [NSArray arrayWithObjects:@"Username", @"Password", @"data", nil];
		NSArray *valueList = [NSArray arrayWithObjects:@"test@test.com", @"test", stateCountry, nil];
		NSString *webAddr = @"http://www.appdigity.com/poker/pokerCasinoList.php";
		NSString *responseStr = [WebServicesFunctions getResponseFromServerUsingPost:webAddr fieldList:nameList valueList:valueList];
		[statsArray removeAllObjects];
		
		if([WebServicesFunctions validateStandardResponse:responseStr delegate:nil]) {
			responseStr = [responseStr substringFromIndex:11];
			NSArray *casinos = [responseStr componentsSeparatedByString:@"<li>"];
			for(NSString *casino in casinos) {
				if([casino length]>2)
					[statsArray addObject:casino];
			}
		}
		[activityIndicator stopAnimating];
		[mainTableView reloadData];
	}
}

-(void)executeThreadedJob:(SEL)aSelector
{
	[activityIndicator startAnimating];
	[self performSelectorInBackground:aSelector withObject:nil];
}


-(void)mainMenuButtonClicked:(id)sender {
	[self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if([self respondsToSelector:@selector(edgesForExtendedLayout)])
        [self setEdgesForExtendedLayout:UIRectEdgeBottom];
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	statsArray = [[NSMutableArray alloc] init];
	
	[self setTitle:@"Casinos"];
    
    [self.mainTableView setBackgroundView:nil];

	
	UIBarButtonItem *mainMenuButton = [[UIBarButtonItem alloc] initWithTitle:@"Main Menu" style:UIBarButtonItemStylePlain target:self action:@selector(mainMenuButtonClicked:)];
	self.navigationItem.rightBarButtonItem = mainMenuButton;

	
	topLabel.text = [NSString stringWithFormat:@"Casinos for %@", stateCountry];
	[self executeThreadedJob:@selector(statLookup)];
    [super viewDidLoad];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [statsArray count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *cellIdentifier = [NSString stringWithFormat:@"cellIdentifierSection%dRow%d", indexPath.section, indexPath.row];
    
    QuadWithImageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[QuadWithImageTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    // Configure the cell...
    dispatch_async(dispatch_get_main_queue(), ^{
	NSString *casino = [statsArray objectAtIndex:indexPath.row];
	NSArray *items = [casino componentsSeparatedByString:@"|"];
	
	cell.aa.text = [items stringAtIndex:1];
	cell.cc.text = [items stringAtIndex:4];
	if([[items stringAtIndex:5] isEqualToString:@"Y"])
		cell.cc.text = [NSString stringWithFormat:@"%@ (I)", [items stringAtIndex:4]];
	
	cell.bb.text = [NSString stringWithFormat:@"%@, %@", [items stringAtIndex:2],[items stringAtIndex:3]];
	float lat = [[items stringAtIndex:6] floatValue];
	float lng = [[items stringAtIndex:7] floatValue];
	float distance = [ProjectFunctions getDistanceFromTarget:lat fromLong:lng toLat:currentLocation.coordinate.latitude toLong:currentLocation.coordinate.longitude];
	cell.dd.text = [NSString stringWithFormat:@"%.1f miles", distance];
	cell.bbColor = [UIColor colorWithRed:0 green:.5 blue:0 alpha:1];
	
	
	cell.leftImage.image = [CasinoEditorVC getCasinoImage:[items stringAtIndex:4] indianFlg:[items stringAtIndex:5]];
	
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    }
                   );

	return cell;
}




#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
 	CasinoEditorVC *detailViewController = [[CasinoEditorVC alloc] initWithNibName:@"CasinoEditorVC" bundle:nil];
	detailViewController.managedObjectContext = managedObjectContext;
	detailViewController.casino = [statsArray objectAtIndex:indexPath.row];
	detailViewController.currentLocation=currentLocation;
	[self.navigationController pushViewController:detailViewController animated:YES];
}



- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}




@end
