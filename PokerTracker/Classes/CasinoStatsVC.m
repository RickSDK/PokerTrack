//
//  CasinoStatsVC.m
//  PokerTracker
//
//  Created by Rick Medved on 1/24/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "CasinoStatsVC.h"
#import "WebServicesFunctions.h"
#import "CasinoListVC.h"
#import "NSArray+ATTArray.h"


@implementation CasinoStatsVC
@synthesize activityIndicator, mainTableView, statsArray, currentLocation, managedObjectContext;

#pragma mark -
#pragma mark View lifecycle

- (IBAction) goHomePressed: (id) sender
{
	[self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
}

-(void)statLookup
{
	@autoreleasepool {
	
	
		NSArray *nameList = [NSArray arrayWithObjects:@"Username", @"Password", nil];
		NSArray *valueList = [NSArray arrayWithObjects:@"test@test.com", @"test", nil];
		NSString *webAddr = @"http://www.appdigity.com/poker/pokerCasinoStats.php";
		NSString *responseStr = [WebServicesFunctions getResponseFromServerUsingPost:webAddr fieldList:nameList valueList:valueList];
		[statsArray removeAllObjects];
		
		if([WebServicesFunctions validateStandardResponse:responseStr delegate:nil]) {
			responseStr = [responseStr substringFromIndex:11];
			NSArray *casinos = [responseStr componentsSeparatedByString:@"|"];
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

- (void)viewDidLoad {
    [super viewDidLoad];
	
	statsArray = [[NSMutableArray alloc] init];
    
    [self.mainTableView setBackgroundView:nil];


	[self setTitle:@"Casinos"];
	[self executeThreadedJob:@selector(statLookup)];

}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if([self respondsToSelector:@selector(edgesForExtendedLayout)])
        [self setEdgesForExtendedLayout:UIRectEdgeBottom];
}

#pragma mark -
#pragma mark Table view data source

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
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
//    cell.textLabel.text = [statsArray stringAtIndex:indexPath.row];
    [cell.textLabel performSelectorOnMainThread:@selector(setText: ) withObject:[statsArray stringAtIndex:(int)indexPath.row] waitUntilDone:YES];
 	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	cell.selectionStyle = UITableViewCellSelectionStyleBlue;
   return cell;
}




#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
    CasinoListVC *detailViewController = [[CasinoListVC alloc] initWithNibName:@"CasinoListVC" bundle:nil];
	detailViewController.stateCountry = [statsArray stringAtIndex:(int)indexPath.row];
	detailViewController.managedObjectContext = managedObjectContext;
	detailViewController.currentLocation=currentLocation;
    [self.navigationController pushViewController:detailViewController animated:YES];
}


#pragma mark -
#pragma mark Memory management





@end

