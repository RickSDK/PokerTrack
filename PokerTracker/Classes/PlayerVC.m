//
//  PlayerVC.m
//  PokerTracker
//
//  Created by Rick Medved on 8/22/15.
//
//

#import "PlayerVC.h"

@interface PlayerVC ()

@end

@implementation PlayerVC

/*
-(void)detailsButtonClicked:(id)sender {
	GameDetailsVC *detailViewController = [[GameDetailsVC alloc] initWithNibName:@"GameDetailsVC" bundle:nil];
	detailViewController.managedObjectContext = managedObjectContext;
	detailViewController.viewEditable = viewEditable;
	detailViewController.mo = mo;
	[self.navigationController pushViewController:detailViewController animated:YES];
}

-(void)mainMenuButtonClicked:(id)sender {
	MainMenuVC *detailViewController = [[MainMenuVC alloc] initWithNibName:@"MainMenuVC" bundle:nil];
	detailViewController.managedObjectContext = managedObjectContext;
	[detailViewController calculateStats];
	[self.navigationController pushViewController:detailViewController animated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if([self.playerList count]==0)
		playerTable.alpha=0;
	else
		playerTable.alpha=1;
	return [self.playerList count];
}

-(NSString *)playerTypeString:(int)playerType
{
	int looseNum=playerType/1000;
	int passNum=playerType-(looseNum*1000);
	
	int playerTypeNum=0;
	if(looseNum<=50 && passNum<=50) {
		playerTypeNum=0;
	}
	if(looseNum<=50 && passNum>50) {
		playerTypeNum=1;
	}
	if(looseNum>50 && passNum<=50) {
		playerTypeNum=2;
	}
	if(looseNum>50 && passNum>50) {
		playerTypeNum=3;
	}
	
	if(playerType==0) {
		playerTypeNum=0;
	}
	if(playerType==1) {
		playerTypeNum=1;
	}
	if(playerType==2) {
		playerTypeNum=2;
	}
	if(playerType==3) {
		playerTypeNum=3;
	}
	
	
	NSArray *types = [NSArray arrayWithObjects:@"Loose-Passive", @"Loose-Aggressive", @"Tight-Passive", @"Tight-Aggressive", nil];
	return [types stringAtIndex:playerTypeNum];
}

-(UIImage *)getUserPic:(int)user_id playerSkill:(int)playerSkill
{
	UIImage *image=nil;
	NSString *jpgPath = [ProjectFunctions getPicPath:user_id];
	
	NSFileHandle *fh = [NSFileHandle fileHandleForReadingAtPath:jpgPath];
	if(fh==nil)
		image = [UIImage imageNamed:[NSString stringWithFormat:@"playerType%d.png", playerSkill+1]];
	else {
		image = [UIImage imageWithContentsOfFile:jpgPath];
	}
	[fh closeFile];
	
	return image;
	
	
}

-(NSManagedObject *)getPlayerFromList:(int)row
{
	NSManagedObject *gamePlayer = [self.playerList objectAtIndex:row];
	int player_id = [[gamePlayer valueForKey:@"player_id"] intValue];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"player_id = %d", player_id];
	NSArray *items = [CoreDataLib selectRowsFromEntity:@"EXTRA" predicate:predicate sortColumn:nil mOC:managedObjectContext ascendingFlg:NO];
	if([items count]>0)
		return [items objectAtIndex:0];
	return nil;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	NSString *cellIdentifier = [NSString stringWithFormat:@"cellIdentifierSection%dRow%d", indexPath.section, indexPath.row];
	QuadWithImageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (cell == nil) {
		cell = [[QuadWithImageTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
	}
	
	
	NSManagedObject *player = [self getPlayerFromList:indexPath.row];
	if(player==nil)
		return cell;
	
	cell.aa.text = [player valueForKey:@"name"];
	int playerType = [[player valueForKey:@"attrib_01"] intValue];
	int playerSkill = [[player valueForKey:@"attrib_02"] intValue];
	
	
	NSArray *skills = [NSArray arrayWithObjects:@"Weak", @"Average", @"Strong", @"Pro", nil];
	cell.bb.text = [self playerTypeString:playerType];
	cell.cc.text = [player valueForKey:@"status"];
	cell.dd.text = [skills objectAtIndex:playerSkill];
	cell.ccColor = [UIColor orangeColor];
	
	int user_id = [[player valueForKey:@"user_id"] intValue];
	
	cell.leftImage.image = [self getUserPic:user_id playerSkill:playerSkill];
	if(playerEditFlg)
		cell.accessoryType = UITableViewCellAccessoryNone;
	else
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	cell.selectionStyle = UITableViewCellSelectionStyleBlue;
	
	return cell;
}

- (IBAction) editButtonPressed: (id) sender
{
	self.playerEditFlg = !playerEditFlg;
	[playerTable reloadData];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if(buttonIndex==1) {
		int game_id = [[mo valueForKey:@"game_id"] intValue];
		NSManagedObject *player = [self.playerList objectAtIndex:selectedRow];
		int player_id = [[player valueForKey:@"player_id"] intValue];
		
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"game_id = %d AND player_id = %d", game_id, player_id];
		NSArray *items = [CoreDataLib selectRowsFromEntity:@"GAMEPLAYER" predicate:predicate sortColumn:nil mOC:managedObjectContext ascendingFlg:NO];
		if([items count]>0) {
			NSManagedObject *m1 = [items objectAtIndex:0];
			[managedObjectContext deleteObject:m1];
			[managedObjectContext save:nil];
		}
		[self setUpData:game_id];
		[playerTable reloadData];
	}
}

- (IBAction) removeButtonPressed: (id) sender
{
	[ProjectFunctions showConfirmationPopup:@"Remove Player?" message:@"Remove this player from this game?" delegate:self tag:1];
	
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	self.selectedRow=indexPath.row;
	if(!playerEditFlg) {
		EditPlayerTracker *detailViewController = [[EditPlayerTracker alloc] initWithNibName:@"EditPlayerTracker" bundle:nil];
		detailViewController.managedObjectContext = managedObjectContext;
		detailViewController.callBackViewController=self;
		detailViewController.managedObject=[self getPlayerFromList:selectedRow];
		[self.navigationController pushViewController:detailViewController animated:YES];
	}
}

-(void)setUpData:(int)game_id
{
	[self.playerList removeAllObjects];
	NSPredicate *predicateP = [NSPredicate predicateWithFormat:@"game_id = %d", game_id];
	[self.playerList addObjectsFromArray:[CoreDataLib selectRowsFromEntity:@"GAMEPLAYER" predicate:predicateP sortColumn:nil mOC:managedObjectContext ascendingFlg:YES]];
}



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[super viewDidLoad];
	[self setTitle:@"Game Graph "];
	
	int game_id = [[mo valueForKey:@"game_id"] intValue];
	if(game_id==0) {
		game_id = [ProjectFunctions generateUniqueId];
		[mo setValue:[NSNumber numberWithInt:game_id] forKey:@"game_id"];
		[managedObjectContext save:nil];
	}
	
	self.graphView.layer.cornerRadius = 8.0;
	self.graphView.layer.masksToBounds = YES;
	self.graphView.layer.borderColor = [UIColor blackColor].CGColor;
	self.graphView.layer.borderWidth = 2.0;
	
	[playerTable setBackgroundColor:[UIColor blackColor]];
	
	dateLabel.text = [[mo valueForKey:@"startTime"] convertDateToStringWithFormat:@"MMM d, yyyy"];
	timeLabel.text = [[mo valueForKey:@"startTime"] convertDateToStringWithFormat:@"hh:mm a"];
	
	
	locationLabel.text = [mo valueForKey:@"location"];
	playerLocLabel.text = [mo valueForKey:@"location"];
	playerDateLabel.text = [[mo valueForKey:@"startTime"] convertDateToStringWithFormat:@"MMM d, yyyy"];
	
	float cashoutAmount = [[mo valueForKey:@"cashoutAmount"] floatValue];
	int tokes = [[mo valueForKey:@"tokes"] intValue];
	int foodMoney = [[mo valueForKey:@"foodDrinks"] intValue];
	if([[mo valueForKey:@"Type"] isEqualToString:@"Tournament"]) {
		tokes=0;
		foodMoney=0;
	}
	NSDate *endTime = [mo valueForKey:@"endTime"];
	if([[mo valueForKey:@"status"] isEqualToString:@"In Progress"])
		endTime = [NSDate date];
	int minutes = [ProjectFunctions getMinutesPlayedUsingStartTime:[mo valueForKey:@"startTime"] andEndTime:endTime andBreakMin:[[mo valueForKey:@"breakMinutes"] intValue]];
	
	if([[mo valueForKey:@"Type"] isEqualToString:@"Tournament"]) {
		minutes = [endTime timeIntervalSinceDate:[mo valueForKey:@"startTime"]]/60;
	}
	NSLog(@"+++minutes: %d %d", minutes, [[mo valueForKey:@"breakMinutes"] intValue]);
	
	int numRebuys = [[mo valueForKey:@"numRebuys"] intValue];
	float buyInAmount = [[mo valueForKey:@"buyInAmount"] floatValue];
	float rebuyAmount = [[mo valueForKey:@"rebuyAmount"] floatValue];
	float winnings = cashoutAmount+foodMoney-buyInAmount-rebuyAmount;
	float grossIncome = winnings+tokes;
	float takehomeIncome = winnings-foodMoney;
	
	gamePPRView.image = [ProjectFunctions getPlayerTypeImage:(buyInAmount+rebuyAmount) winnings:winnings];
	
	
	dayLabel.text = [NSString stringWithFormat:@"%@ %@", [mo valueForKey:@"weekday"], [mo valueForKey:@"daytime"]];
	
	NSString *hourlyStr = @"-";
	if(minutes>0)
		hourlyStr = [NSString stringWithFormat:@"%@%d/hr", [ProjectFunctions getMoneySymbol], (int)winnings*60/minutes];
	
	
	buyinLabel.text = [ProjectFunctions convertNumberToMoneyString:buyInAmount];
	rebuysLabel.text = [NSString stringWithFormat:@"%d", numRebuys];
	minutesLabel.text = [NSString stringWithFormat:@"%d", minutes];
	
	gametimeLabel.text = [ProjectFunctions getHoursPlayedUsingStartTime:[mo valueForKey:@"startTime"] andEndTime:endTime andBreakMin:[[mo valueForKey:@"breakMinutes"] intValue]];
	
	rebuyTotalLabel.text = [ProjectFunctions convertNumberToMoneyString:rebuyAmount];
	riskedLabel.text = [ProjectFunctions convertNumberToMoneyString:(rebuyAmount+buyInAmount)];
	cashOutLabel.text = [ProjectFunctions convertNumberToMoneyString:cashoutAmount];
	
	[ProjectFunctions updateMoneyFloatLabel:grossLabel money:grossIncome];
	[ProjectFunctions updateMoneyFloatLabel:takehomeLabel money:takehomeIncome];
	[ProjectFunctions updateMoneyFloatLabel:netLabel money:winnings];
	[ProjectFunctions updateMoneyFloatLabel:hourlyLabel money:winnings];
	
	hourlyLabel.text = hourlyStr;
	
	if(showMainMenuFlg) {
		self.navigationItem.leftBarButtonItem = [ProjectFunctions navigationButtonWithTitle:@"Main Menu" selector:@selector(mainMenuButtonClicked:) target:self];
	}
	
	self.navigationItem.rightBarButtonItem = [ProjectFunctions navigationButtonWithTitle:@"Details" selector:@selector(detailsButtonClicked:) target:self];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"game = %@", mo];
	NSArray *items = [CoreDataLib selectRowsFromEntity:@"CHIPSTACK" predicate:predicate sortColumn:@"timeStamp" mOC:managedObjectContext ascendingFlg:YES];
	
	if([items count]==0) {
		NSDate *startTime = [mo valueForKey:@"startTime"];
		NSDate *endTime = [mo valueForKey:@"endTime"];
		
		[ProjectFunctions createChipTimeStamp:managedObjectContext mo:mo timeStamp:startTime amount:0 rebuyFlg:NO];
		[ProjectFunctions createChipTimeStamp:managedObjectContext mo:mo timeStamp:endTime amount:winnings rebuyFlg:NO];
	}
	
	
	NSString *predString = [ProjectFunctions getBasicPredicateString:[[[NSDate date] convertDateToStringWithFormat:@"yyyy"] intValue] type:@"All"];
	NSPredicate *pred = [NSPredicate predicateWithFormat:predString];
	self.graphView.image = [ProjectFunctions plotGameChipsChart:managedObjectContext mo:mo predicate:pred displayBySession:NO];
	
	if([[mo valueForKey:@"Type"] isEqualToString:@"Tournament"]) {
		[self setTitle:@"Tournament"];
		graphView.alpha=0;
		entrantsLabel.alpha=1;
		spotsLabel.alpha=1;
		placeLabel.alpha=1;
		entrantsValLabel.alpha=1;
		spotsValLabel.alpha=1;
		placeValLabel.alpha=1;
		tournamentLabel.alpha=1;
		int entrants = [[mo valueForKey:@"tournamentSpots"] intValue];
		int spotsPaid = [[mo valueForKey:@"breakMinutes"] intValue];
		int place = [[mo valueForKey:@"tournamentFinish"] intValue];
		
		if(entrants==0) {
			entrants = [[mo valueForKey:@"attrib03"] intValue];
			//			spotsPaid = [[mo valueForKey:@"tournamentSpotsPaid"] intValue];
			place = [[mo valueForKey:@"attrib04"] intValue];
			
			if(entrants==0)
				entrants=10;
			if(spotsPaid==0)
				spotsPaid=entrants/10;
			if(place==0)
				place=5;
			
			[mo setValue:[NSNumber numberWithInt:entrants] forKey:@"tournamentSpots"];
			[mo setValue:[NSNumber numberWithInt:spotsPaid] forKey:@"breakMinutes"];
			[mo setValue:[NSNumber numberWithInt:place] forKey:@"tournamentFinish"];
			[managedObjectContext save:nil];
		}
		entrantsValLabel.text = [NSString stringWithFormat:@"%d", entrants];
		spotsValLabel.text = [NSString stringWithFormat:@"%d", spotsPaid];
		placeValLabel.text = [NSString stringWithFormat:@"%d", place];
	} else {
		graphView.alpha=1;
		entrantsLabel.alpha=0;
		spotsLabel.alpha=0;
		placeLabel.alpha=0;
		entrantsValLabel.alpha=0;
		spotsValLabel.alpha=0;
		placeValLabel.alpha=0;
		tournamentLabel.alpha=0;
	}
	
	mainView.center = CGPointMake(160, 208);
	playerView.center = CGPointMake(160, 208);
	playerView.alpha=0;
	
	
	
	self.playerList = [[NSMutableArray alloc] init];
	[self setUpData:game_id];
	
	
}

-(void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	if([self respondsToSelector:@selector(edgesForExtendedLayout)])
		[self setEdgesForExtendedLayout:UIRectEdgeBottom];
}

- (IBAction) addButtonPressed: (id) sender
{
	self.playerEditFlg=NO;
	ListPicker *detailViewController = [[ListPicker alloc] initWithNibName:@"ListPicker" bundle:nil];
	detailViewController.titleLabel = @"Add Player";
	detailViewController.initialDateValue=@"";
	detailViewController.managedObjectContext = managedObjectContext;
	detailViewController.allowEditing=NO;
	detailViewController.selectionList = [CoreDataLib getEntityNameList:@"EXTRA" mOC:managedObjectContext];
	detailViewController.callBackViewController = self;
	[self.navigationController pushViewController:detailViewController animated:YES];
}


-(void) setReturningValue:(NSString *) value {
	if([value length]==0) {
		[ProjectFunctions showAlertPopup:@"Error" message:@"No value selected"];
		return;
	}
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name = %@", value];
	NSArray *items = [CoreDataLib selectRowsFromEntity:@"EXTRA" predicate:predicate sortColumn:nil mOC:managedObjectContext ascendingFlg:NO];
	if([items count]==0) {
		[ProjectFunctions showAlertPopup:@"Error" message:@"No entry found for that name!"];
		return;
	}
	
	int game_id = [[mo valueForKey:@"game_id"] intValue];
	NSManagedObject *player = [items objectAtIndex:0];
	int player_id = [[player valueForKey:@"player_id"] intValue];
	if(player_id==0) {
		player_id = [ProjectFunctions generateUniqueId];
		[player setValue:[NSNumber numberWithInt:player_id] forKey:@"player_id"];
		[managedObjectContext save:nil];
	}
	NSArray *values = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%d", game_id], [NSString stringWithFormat:@"%d", player_id], @"", @"", nil];
	[CoreDataLib insertManagedObjectForEntity:@"GAMEPLAYER" valueList:values mOC:managedObjectContext];
	[self setUpData:game_id];
	playerTable.alpha=1;
	[playerTable reloadData];
	
	
}
 
 */

@end
