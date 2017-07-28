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
#import "GameCell.h"
#import "GameObj.h"

@implementation FriendLast10GamesVC
@synthesize gameList, selfFlg;
@synthesize netUserObj;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTitle:[NSString stringWithFormat:@"%@ Last 10", self.netUserObj.name]];
	[self changeNavToIncludeType:18];

	[self addHomeButton];
    self.gameList = [[NSMutableArray alloc] init];
	
	if(self.selfFlg) {
		UIBarButtonItem *moreButton = [[UIBarButtonItem alloc] initWithTitle:@"Refresh" style:UIBarButtonItemStylePlain target:self action:@selector(refreshButtonClicked:)];
		self.navigationItem.rightBarButtonItem = moreButton;
	}

	[self.webServiceView startWithTitle:@"Loading..."];
	[self performSelectorInBackground:@selector(loadTable) withObject:nil];
}

-(void)refreshButtonClicked:(id)sender {
	[self.webServiceView startWithTitle:@"Working..."];
	[self performSelectorInBackground:@selector(uploadStatsFunction) withObject:nil];
}

-(void)uploadStatsFunction
{
	@autoreleasepool {
        [ProjectFunctions uploadUniverseStats:self.managedObjectContext];
		[self.webServiceView stop];
	}
}

-(void)loadTable
{
	@autoreleasepool {
		NSArray *nameList = [NSArray arrayWithObjects:@"Username", @"Password", @"friend_id", nil];
		NSString *friendId = [NSString stringWithFormat:@"%d", self.netUserObj.userId];
		NSArray *valueList = [NSArray arrayWithObjects:[ProjectFunctions getUserDefaultValue:@"userName"], [ProjectFunctions getUserDefaultValue:@"password"], friendId, nil];
		NSString *webAddr = @"http://www.appdigity.com/poker/pokerGetLast10.php";
		NSString *responseStr = [WebServicesFunctions getResponseFromServerUsingPost:webAddr fieldList:nameList valueList:valueList];
		if([WebServicesFunctions validateStandardResponse:responseStr delegate:nil]) {
			NSLog(@"pokerGetLast10: %@", responseStr);
			NSArray *games = [responseStr componentsSeparatedByString:@"[li]"];
			for(NSString *line in games) {
				if([line length]>15) {
					GameObj *gameObj = [GameObj populateGameFromNetUserString:line];
					[gameList addObject:gameObj];
				}
			}
		}
		
		[self.webServiceView stop];
		[self.mainTableView reloadData];
	}
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
 	NSString *CellIdentifier = [NSString stringWithFormat:@"cellIdentifierSection%dRow%d", (int)indexPath.section, (int)indexPath.row];

	GameCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[GameCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
	}
	
	GameObj *gameObj = [gameList objectAtIndex:indexPath.row];
	[GameCell populateGameCell:cell gameObj:gameObj evenFlg:indexPath.row%2==0];

	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	FriendInProgressVC *detailViewController = [[FriendInProgressVC alloc] initWithNibName:@"FriendInProgressVC" bundle:nil];
	detailViewController.netUserObj=self.netUserObj;
	detailViewController.gameObj = [gameList objectAtIndex:indexPath.row];
	[self.navigationController pushViewController:detailViewController animated:YES];
}

@end
