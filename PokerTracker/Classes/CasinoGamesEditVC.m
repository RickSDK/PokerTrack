//
//  CasinoGamesEditVC.m
//  PokerTracker
//
//  Created by Rick Medved on 1/21/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "CasinoGamesEditVC.h"
#import "NSString+ATTString.h"
#import "CasinoGamesAddVC.h"
#import "NSArray+ATTArray.h"
#import "ProjectFunctions.h"
#import "WebServicesFunctions.h"


@implementation CasinoGamesEditVC
@synthesize editButton, casino, nameLabel, addNewButton, removeButton, gamesArray, mainTableView, checkboxes, casino_id;
@synthesize activityIndicator, activityPopup, activityLabel, managedObjectContext;

- (IBAction) newPressed: (id) sender
{
	CasinoGamesAddVC *detailViewController = [[CasinoGamesAddVC alloc] initWithNibName:@"CasinoGamesAddVC" bundle:nil];
	detailViewController.managedObjectContext=managedObjectContext;
	detailViewController.callBackViewController=self;
	[self.navigationController pushViewController:detailViewController animated:YES];
}

-(void) resetBoxes {
	[checkboxes removeAllObjects];
	for(int i=0; i<gamesArray.count; i++)
		[checkboxes addObject:@"N"];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if([self respondsToSelector:@selector(edgesForExtendedLayout)])
        [self setEdgesForExtendedLayout:UIRectEdgeBottom];
}


- (IBAction) removePressed: (id) sender
{
	editButton.enabled=YES;
	int i=0;
	for(NSString *check in checkboxes) {
		if([check isEqualToString:@"Y"])
			[gamesArray removeObjectAtIndex:i];
		else 
			i++;
	}
	[self resetBoxes];
	[mainTableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [gamesArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
	
	cell.textLabel.text = [gamesArray objectAtIndex:indexPath.row];
	if([[checkboxes stringAtIndex:(int)indexPath.row] isEqualToString:@"Y"])
		cell.imageView.image = [UIImage imageNamed:@"SelectedCheckBox.png"];
	else 
		cell.imageView.image = [UIImage imageNamed:@"UnSelectedCheckBox.png"];

	return cell;
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	[self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
}

-(void) editGamesForCasino {
	@autoreleasepool {
	
		NSString *casino_idStr = [NSString stringWithFormat:@"%d", casino_id];
		NSString *data = [gamesArray componentsJoinedByString:@"|"];
		NSArray *nameList = [NSArray arrayWithObjects:@"Username", @"Password", @"casino_id", @"data", nil];
		NSArray *valueList = [NSArray arrayWithObjects:[ProjectFunctions getUserDefaultValue:@"userName"], [ProjectFunctions getUserDefaultValue:@"password"], casino_idStr, data, nil];
		if([valueList count]==0) {
			[ProjectFunctions displayLoginMessage];
			return;
		}
		NSString *webAddr = @"http://www.appdigity.com/poker/pokerCasinoUpdateGames.php";
		NSString *responseStr = [WebServicesFunctions getResponseFromServerUsingPost:webAddr fieldList:nameList valueList:valueList];
		
		if([WebServicesFunctions validateStandardResponse:responseStr delegate:nil]) {
			[ProjectFunctions showAlertPopupWithDelegate:@"Success" message:@"Games updated!" delegate:self];
		}
		
		activityPopup.alpha=0;
		activityLabel.alpha=0;
		[activityIndicator stopAnimating];
	}
}


-(void)executeThreadedJob:(SEL)aSelector
{
	activityPopup.alpha=1;
	activityLabel.alpha=1;
	[activityIndicator startAnimating];
	[self performSelectorInBackground:aSelector withObject:nil];
}

- (IBAction) saveButtonClicked: (id) sender
{
	[self executeThreadedJob:@selector(editGamesForCasino)];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	[self setTitle:@"Edit Games"];

	activityPopup.alpha=0;
	activityLabel.alpha=0;

	checkboxes = [[NSMutableArray alloc] init];
	
	editButton = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(saveButtonClicked:)];
	self.navigationItem.rightBarButtonItem = editButton;
	editButton.enabled=NO;

	NSArray *items = [casino componentsSeparatedByString:@"|"];
	gamesArray = [[NSMutableArray alloc] initWithArray:[[items stringAtIndex:15] componentsSeparatedByString:@"<hr>"]];
	if([gamesArray count]>0)
		[gamesArray removeLastObject];

	[self resetBoxes];

	nameLabel.text = [items stringAtIndex:1];
	removeButton.enabled=NO;
	
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if([[checkboxes stringAtIndex:(int)indexPath.row] isEqualToString:@"Y"])
		[checkboxes replaceObjectAtIndex:indexPath.row withObject:@"N"];
	else 
		[checkboxes replaceObjectAtIndex:indexPath.row withObject:@"Y"];
	removeButton.enabled=YES;
	[mainTableView reloadData];
}

-(void) setReturningValue:(NSString *) value {

	editButton.enabled=YES;
	[gamesArray addObject:value];
	[checkboxes addObject:@"N"];
	[mainTableView reloadData];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

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
