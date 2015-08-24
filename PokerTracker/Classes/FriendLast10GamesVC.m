//
//  FriendLast10GamesVC.m
//  PokerTracker
//
//  Created by Rick Medved on 7/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FriendLast10GamesVC.h"
#import "ProjectFunctions.h"
#import "WebServicesFunctions.h"
#import "QuadWithImageTableViewCell.h"
#import "NSArray+ATTArray.h"
#import "FriendInProgressVC.h"

@implementation FriendLast10GamesVC
@synthesize user_id, friendName, gameList, managedObjectContext, selfFlg;
@synthesize activityIndicator, imageViewBG, activityLabel, mainTableView;


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTitle:friendName];

    gameList = [[NSMutableArray alloc] init];
    
    [activityIndicator startAnimating];
	self.imageViewBG.alpha=1;
	self.activityLabel.alpha=1;
	[self performSelectorInBackground:@selector(loadTable) withObject:nil];
	
	if(self.selfFlg) {
		UIBarButtonItem *moreButton = [[UIBarButtonItem alloc] initWithTitle:@"Refresh" style:UIBarButtonItemStylePlain target:self action:@selector(refreshButtonClicked:)];
		self.navigationItem.rightBarButtonItem = moreButton;
	}

}

-(void)refreshButtonClicked:(id)sender {
	[activityIndicator startAnimating];
	activityLabel.alpha=1;
	
	[self performSelectorInBackground:@selector(uploadStatsFunction) withObject:nil];
}


-(void)uploadStatsFunction
{
	@autoreleasepool {
        [ProjectFunctions uploadUniverseStats:self.managedObjectContext];
		[activityIndicator stopAnimating];
		activityLabel.alpha=0;
	}
}

-(void)loadTable
{
	@autoreleasepool {
		NSArray *nameList = [NSArray arrayWithObjects:@"Username", @"Password", @"friend_id", nil];
    NSString *friendId = [NSString stringWithFormat:@"%d", user_id];
		NSArray *valueList = [NSArray arrayWithObjects:[ProjectFunctions getUserDefaultValue:@"userName"], [ProjectFunctions getUserDefaultValue:@"password"], friendId, nil];
		NSString *webAddr = @"http://www.appdigity.com/poker/pokerGetLast10.php";
		NSString *responseStr = [WebServicesFunctions getResponseFromServerUsingPost:webAddr fieldList:nameList valueList:valueList];
		if([WebServicesFunctions validateStandardResponse:responseStr delegate:nil]) {
        NSLog(@"pokerGetLast10: %@", responseStr);
        NSArray *games = [responseStr componentsSeparatedByString:@"[li]"];
        for(NSString *line in games) {
            if([line length]>15)
                [gameList addObject:line];
        }
		}

		[activityIndicator stopAnimating];
		self.imageViewBG.alpha=0;
		self.activityLabel.alpha=0;
		[mainTableView reloadData];
	}
}


- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return CGFLOAT_MIN;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if([self respondsToSelector:@selector(edgesForExtendedLayout)])
        [self setEdgesForExtendedLayout:UIRectEdgeBottom];
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [gameList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
 	NSString *CellIdentifier = [NSString stringWithFormat:@"cellIdentifierSection%dRow%d", indexPath.section, indexPath.row];

	QuadWithImageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[QuadWithImageTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
	}
	
	NSString *game = [gameList objectAtIndex:indexPath.row];
    NSArray *fields = [game componentsSeparatedByString:@"|"];
	
	NSString *type = [fields stringAtIndex:6];
	cell.aa.text = [NSString stringWithFormat:@"%@ (%@)", [fields stringAtIndex:4], [type substringToIndex:1]];
	cell.bb.text = [NSString stringWithFormat:@"%@", [fields stringAtIndex:0]];
	cell.cc.text = [fields stringAtIndex:6];
    int buyIn = [[fields stringAtIndex:1] intValue];
    int rebuy = [[fields stringAtIndex:2] intValue];
    int chips = [[fields stringAtIndex:3] intValue];
    int food = [[fields stringAtIndex:15] intValue];
    int winnings = chips+food-(buyIn+rebuy);
	cell.dd.text = [NSString stringWithFormat:@"%@", [ProjectFunctions convertIntToMoneyString:winnings]];
	if(winnings>=0)
		cell.ddColor = [UIColor colorWithRed:0 green:.5 blue:0 alpha:1];
	else
		cell.ddColor = [UIColor redColor];
	
	if([type isEqualToString:@"Cash"])
		cell.backgroundColor = [UIColor colorWithRed:.97 green:1 blue:.97 alpha:1];
	else
		cell.backgroundColor = [UIColor colorWithRed:.97 green:.97 blue:1 alpha:1];

    cell.leftImage.image = [ProjectFunctions getPlayerTypeImage:buyIn+rebuy winnings:winnings];
    cell.imageView.image=nil;
	
	if([[fields stringAtIndex:7] isEqualToString:@"Y"]) {
		cell.backgroundColor = [UIColor yellowColor];
		cell.dd.text = @"In Progress";
		cell.ddColor = [UIColor redColor];
	} else {
		if([type isEqualToString:@"Cash"])
			cell.backgroundColor = [UIColor whiteColor];
		else			
			cell.backgroundColor = [UIColor colorWithRed:.9 green:.9 blue:1 alpha:1];
	}
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    
     FriendInProgressVC *detailViewController = [[FriendInProgressVC alloc] initWithNibName:@"FriendInProgressVC" bundle:nil];
    detailViewController.userValues = [NSString stringWithFormat:@"<xx><xx>%@<xx>%@", friendName, [gameList objectAtIndex:indexPath.row]];
     [self.navigationController pushViewController:detailViewController animated:YES];
    
}



@end
