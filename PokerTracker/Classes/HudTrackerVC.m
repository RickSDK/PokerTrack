//
//  HudTrackerVC.m
//  PokerTracker
//
//  Created by Rick Medved on 7/9/17.
//
//

#import "HudTrackerVC.h"
#import "MinuteEnterVC.h"
#import "CoreDataLib.h"
#import "PlayerTrackerObj.h"
#import "MainMenuVC.h"
#import "GameCell.h"
#import "QuadWithImageTableViewCell.h"

@interface HudTrackerVC ()

@end

@implementation HudTrackerVC

- (void)viewDidLoad {
    [super viewDidLoad];
	[self setTitle:@"HUD Tracker"];
	[self changeNavToIncludeType:5];

	self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:
											   [ProjectFunctions UIBarButtonItemWithIcon:[NSString fontAwesomeIconStringForEnum:FAPencil] target:self action:@selector(editButtonClicked)],
											   [ProjectFunctions UIBarButtonItemWithIcon:[NSString fontAwesomeIconStringForEnum:FAInfoCircle] target:self action:@selector(popupButtonClicked)],
											   nil];
	
	self.heroObj = [[PlayerObj alloc] init];
	self.villianObj = [[PlayerObj alloc] init];
	
	[ProjectFunctions makeFAButton:self.trashbutton1 type:0 size:18];
	[ProjectFunctions makeFAButton:self.trashbutton2 type:0 size:18];
	self.trashbutton1.enabled=NO;
	self.trashbutton2.enabled=NO;
	self.editModeLabel2.hidden=YES;
	
	[ProjectFunctions makeFAButton:self.vpipInfoButton type:20 size:18];
	[ProjectFunctions makeFAButton:self.pfrInfoButton type:20 size:18];
	[ProjectFunctions makeFAButton:self.afInfoButton type:20 size:18];

	[ProjectFunctions makeFAButton:self.foldButton1 type:21 size:18];
	[ProjectFunctions makeFAButton:self.checkButton1 type:22 size:18];
	[ProjectFunctions makeFAButton:self.callButton1 type:23 size:18];
	[ProjectFunctions makeFAButton:self.raiseButton1 type:24 size:18];
	
	[ProjectFunctions makeFAButton:self.foldButton2 type:21 size:18];
	[ProjectFunctions makeFAButton:self.checkButton2 type:22 size:18];
	[ProjectFunctions makeFAButton:self.callButton2 type:23 size:18];
	[ProjectFunctions makeFAButton:self.raiseButton2 type:24 size:18];
	
	[ProjectFunctions makeFAButton:self.linkPlayerButton type:36 size:16];
	[ProjectFunctions makeFAButton:self.linkGameButton type:36 size:16];
	
	self.playersView.hidden=YES;
	[self setupScreen];
	[self loadDataIntoPlayer:self.heroObj heroFlag:YES];
	[self loadDataIntoPlayer:self.villianObj heroFlag:NO];
	[self updateDisplay];
	[self initializeVillian];
	
}

-(void)initializeVillian {
	if (self.playerMo) {
		self.villianObj.playerId = [[self.playerMo valueForKey:@"player_id"] intValue];
		self.villianObj.name = [self.playerMo valueForKey:@"name"];
		self.villianActionLabel.text = [NSString stringWithFormat:@"%@'s Pre-Flop Action", [self.playerMo valueForKey:@"name"]];
	}
}

-(void)setupScreen {
	self.vpipObj = [[HudStatObj alloc] init];

	self.vpipObj = [HudStatObj createObjWithPercentLabel1:self.vpipPercentLabel1 percentLabel2:self.vpipPercentLabel2 countLabel1:self.vpipCountLabel1 countLabel2:self.vpipCountLabel2 bGImageView:self.vpipBGImageView playerType1ImageView:self.vpipPlayerType1ImageView playerType2ImageView:self.vpipPlayerType2ImageView barView1:self.vpipBarView1 barView2:self.vpipBarView2];
	self.pfrObj = [[HudStatObj alloc] init];
	self.pfrObj = [HudStatObj createObjWithPercentLabel1:self.pfrPercentLabel1 percentLabel2:self.pfrPercentLabel2 countLabel1:self.pfrCountLabel1 countLabel2:self.pfrCountLabel2 bGImageView:self.pfrBGImageView playerType1ImageView:self.pfrPlayerType1ImageView playerType2ImageView:self.pfrPlayerType2ImageView barView1:self.pfrBarView1 barView2:self.pfrBarView2];
	self.afObj = [[HudStatObj alloc] init];
	self.afObj = [HudStatObj createObjWithPercentLabel1:self.afPercentLabel1 percentLabel2:self.afPercentLabel2 countLabel1:self.afCountLabel1 countLabel2:self.afCountLabel2 bGImageView:self.afBGImageView playerType1ImageView:self.afPlayerType1ImageView playerType2ImageView:self.afPlayerType2ImageView barView1:self.afBarView1 barView2:self.afBarView2];
	self.villianActionObj = [[HudActionObj alloc] init];
	self.villianActionObj = [HudActionObj createObjWithFoldLabel:self.foldCountLabel1 checkLabel:self.checkCountLabel1 callLabel:self.callCountLabel1 raiseLabel:self.raiseCountLabel1 styleLabel:self.styleLabel1 skillImageView:self.skillImageView1];
	self.heroActionObj = [[HudActionObj alloc] init];
	self.heroActionObj = [HudActionObj createObjWithFoldLabel:self.foldCountLabel2 checkLabel:self.checkCountLabel2 callLabel:self.callCountLabel2 raiseLabel:self.raiseCountLabel2 styleLabel:self.styleLabel2 skillImageView:self.skillImageView2];
}

- (IBAction) linkButtonPressed: (UIButton *) button {
	[self.mainArray removeAllObjects];
	self.linkButtonTag = (int)button.tag;
	if(self.linkButtonTag==0) {
		self.playersView.titleLabel.text = @"Link a Player";
		NSArray *newPlayers = [CoreDataLib selectRowsFromEntity:@"EXTRA" predicate:nil sortColumn:@"name" mOC:self.managedObjectContext ascendingFlg:YES];
		[self.mainArray addObjectsFromArray:newPlayers];
		if(newPlayers.count==0) {
			[ProjectFunctions showAlertPopup:@"Notice" message:@"No players saved on this device. Go to Player Tracker to create one."];
		}
	} else {
		NSArray *games = [CoreDataLib selectRowsFromEntityWithLimit:@"GAME" predicate:nil sortColumn:@"startTime" mOC:self.managedObjectContext ascendingFlg:NO limit:20];
		[self.mainArray addObjectsFromArray:games];
		self.playersView.titleLabel.text = @"Link a Game";
		if(games.count==0) {
			[ProjectFunctions showAlertPopup:@"Notice" message:@"No games saved on this device."];
		}
	}
	[self.mainTableView reloadData];
	self.playersView.hidden=NO;
}

-(void)editButtonClicked {
	self.editMode=!self.editMode;
	self.trashbutton1.enabled = self.editMode;
	self.trashbutton2.enabled = self.editMode;
	self.hudView.alpha=(self.editMode)?.5:1;
	self.editModeLabel2.hidden=!self.editMode;
	if (self.defaultButtonLock) {
		self.foldButton1.enabled=self.editMode;
		self.foldButton2.enabled=self.editMode;
		self.callButton1.enabled=self.editMode;
		self.callButton2.enabled=self.editMode;
		self.checkButton1.enabled=self.editMode;
		self.checkButton2.enabled=self.editMode;
		self.raiseButton1.enabled=self.editMode;
		self.raiseButton2.enabled=self.editMode;
	}
}

-(void)popupButtonClicked {
	[self populatePopupWithTitle:@"Heads up Display" text:@"Use HUD to track the first pre-flop action of yourself and/or ONE other player at the table.\n\nSimply press the correct button for each hand: Fold, Check, Call or Raise.  Note you are only tracking pre-flop betting. And specifically, first action of pre-flop. HUD will then calculate values for Passive/Aggressive play and Tight/Loose play.\n\nIt will then chart your values and the opponent’s values side by side for comparison. It also calculates overall skill level and displays the appropriate PTP skill Icon.\n\nIf you have a player or game linked, the stats are automatically saved every time you press a button.\n\nUse this tool to measure your own play or use it to compare how you are playing versus someone else at the table.\n\nGood Luck!"];
}

-(void)updateHudStat:(HudStatObj *)stat top1:(int)top1 bottom1:(int)bottom1 top2:(int)top2 bottom2:(int)bottom2 midPoint:(float)midpoint midPoint2:(float)midpoint2 {
	stat.percentLabel1.text = @"-";
	stat.percentLabel2.text = @"-";
	int percent1= midpoint;
	int percent2= midpoint2;
	
	stat.countLabel1.text = [NSString stringWithFormat:@"%d/%d", top1, bottom1];
	stat.countLabel2.text = [NSString stringWithFormat:@"%d/%d", top2, bottom2];

	if(bottom1>0) {
		percent1 = top1*100/bottom1;
		stat.percentLabel1.text = [NSString stringWithFormat:@"%d%%", percent1];
	}
	if(bottom2>0) {
		percent2 = top2*100/bottom2;
		stat.percentLabel2.text = [NSString stringWithFormat:@"%d%%", percent2];
	}
	if(midpoint>1)
		percent1 = percent1*100/(midpoint*2);
	if(midpoint2>1)
		percent2 = percent2*100/(midpoint2*2);

	
	[self positionBarsForsStat:stat percent1:percent1 percent2:percent2];
}

-(void)calculateVPIP {
	self.villianObj.handCount = self.villianObj.foldCount+self.villianObj.callCount+self.villianObj.raiseCount;
	self.heroObj.handCount = self.heroObj.foldCount+self.heroObj.callCount+self.heroObj.raiseCount;
	int top1 = self.villianObj.callCount+self.villianObj.raiseCount;
	int top2 = self.heroObj.callCount+self.heroObj.raiseCount;
	
	self.heroObj.vpip = [PlayerObj vpipForPlayer:self.heroObj];
	self.villianObj.vpip = [PlayerObj vpipForPlayer:self.villianObj];
	
	[self updateHudStat:self.vpipObj top1:top1 bottom1:self.villianObj.handCount top2:top2 bottom2:self.heroObj.handCount midPoint:26.975 midPoint2:26.975];
}

-(void)calculatePFR {
	self.villianObj.handCount = self.villianObj.foldCount+self.villianObj.callCount+self.villianObj.raiseCount;
	self.heroObj.handCount = self.heroObj.foldCount+self.heroObj.callCount+self.heroObj.raiseCount;
	int top1 = self.villianObj.raiseCount;
	int top2 = self.heroObj.raiseCount;

	self.heroObj.pfr = [PlayerObj pfrForPlayer:self.heroObj];
	self.villianObj.pfr = [PlayerObj pfrForPlayer:self.villianObj];
	
	[self updateHudStat:self.pfrObj top1:top1 bottom1:self.villianObj.handCount top2:top2 bottom2:self.heroObj.handCount midPoint:self.villianObj.vpip/2 midPoint2:self.heroObj.vpip/2];
}

-(void)calculateAF {
	int bottom1 = self.villianObj.callCount+self.villianObj.raiseCount;
	int bottom2 = self.heroObj.callCount+self.heroObj.raiseCount;
	self.heroObj.af=16; // rounder
	self.villianObj.af=16; // rounder
	if (bottom2>0)
		self.heroObj.af = self.heroObj.raiseCount*100/bottom2;
	if (bottom1>0)
		self.villianObj.af = self.villianObj.raiseCount*100/bottom1;
	
	[self updateHudStat:self.afObj top1:self.villianObj.raiseCount bottom1:bottom1 top2:self.heroObj.raiseCount bottom2:bottom2 midPoint:24 midPoint2:24];
	
	self.afAmountLabel1.text = @"-";
	if(self.villianObj.callCount>0)
		self.afAmountLabel1.text = [NSString stringWithFormat:@"%.1f", (float)self.villianObj.raiseCount/self.villianObj.callCount];
	self.afAmountLabel2.text = @"-";
	if(self.heroObj.callCount>0)
		self.afAmountLabel2.text = [NSString stringWithFormat:@"%.1f", (float)self.heroObj.raiseCount/self.heroObj.callCount];
}

-(void)updateDisplay {
	self.heroActionObj.foldLabel.text = [NSString stringWithFormat:@"%d", self.heroObj.foldCount];
	self.heroActionObj.checkLabel.text = [NSString stringWithFormat:@"%d", self.heroObj.checkCount];
	self.heroActionObj.callLabel.text = [NSString stringWithFormat:@"%d", self.heroObj.callCount];
	self.heroActionObj.raiseLabel.text = [NSString stringWithFormat:@"%d", self.heroObj.raiseCount];
	self.villianActionObj.foldLabel.text = [NSString stringWithFormat:@"%d", self.villianObj.foldCount];
	self.villianActionObj.checkLabel.text = [NSString stringWithFormat:@"%d", self.villianObj.checkCount];
	self.villianActionObj.callLabel.text = [NSString stringWithFormat:@"%d", self.villianObj.callCount];
	self.villianActionObj.raiseLabel.text = [NSString stringWithFormat:@"%d", self.villianObj.raiseCount];

	[self calculateVPIP];
	[self calculatePFR];
	[self calculateAF];
	
	[self updatePlayerSkillImage:self.heroActionObj player:self.heroObj vpip:self.vpipObj.playerType2ImageView pfr:self.pfrObj.playerType2ImageView af:self.afObj.playerType2ImageView];
	[self updatePlayerSkillImage:self.villianActionObj player:self.villianObj vpip:self.vpipObj.playerType1ImageView pfr:self.pfrObj.playerType1ImageView af:self.afObj.playerType1ImageView];
	
	if(self.playerMo) {
		self.linkPlayerButton.hidden=YES;
		self.linkPlayerImageView.image=[UIImage imageNamed:@"green.png"];
	} else {
		self.linkPlayerButton.hidden=NO;
		self.linkPlayerImageView.image=[UIImage imageNamed:@"red.png"];
	}
	if(self.gameMo) {
		self.linkGameButton.hidden=YES;
		self.linkGameImageView.image=[UIImage imageNamed:@"green.png"];
	} else {
		self.linkGameButton.hidden=NO;
		self.linkGameImageView.image=[UIImage imageNamed:@"red.png"];
	}
//	if(self.villianObj.handCount>0)
//		self.linkPlayerButton.hidden=YES;
	if(self.heroObj.handCount>0)
		self.linkGameButton.hidden=YES;

}

-(void)updatePlayerSkillImage:(HudActionObj *)obj player:(PlayerObj *)player vpip:(UIImageView *)vpip pfr:(UIImageView *)pfr af:(UIImageView *)af {
	if (player.handCount==0) {
		obj.styleLabel.text = @"-";
		obj.skillImageView.image = [UIImage imageNamed:@"Icon.png"];
		vpip.image = [UIImage imageNamed:@"Icon.png"];
		pfr.image = [UIImage imageNamed:@"Icon.png"];
		af.image = [UIImage imageNamed:@"Icon.png"];
	} else {
		float skill1 = [self boxValue:7.15-(float)player.vpip/6.5 min:0 max:5];
		
		float skill2Percent = 0;
		if(player.vpip>0)
			skill2Percent = player.pfr*100/player.vpip;
		float skill2 = [self boxValue:ceil(skill2Percent/10)-2 min:0 max:5];
		float skill3 = [self boxValue:(float)player.af/8 min:0 max:5];
		
		vpip.image = [self playerImageForNumber:skill1];
		pfr.image = [self playerImageForNumber:skill2];
		af.image = [self playerImageForNumber:skill3];

		obj.skillImageView.image = [self playerImageForNumber:(skill1+skill3)/2];
		float finalNumber = [self boxValue:(skill1+skill3)/2 min:0 max:5];
		player.picId = (int)floor(finalNumber);

		player.looseNum = skill1*20;
		player.agressiveNum = (skill2+skill3)*10;
		NSString *style1 = (skill1>=3)?@"Tight":@"Loose";
		NSString *style2 = (skill2+skill3>=6)?@"Aggressive":@"Passive";
		player.playerStyleStr = [NSString stringWithFormat:@"%@-%@", style1, style2];
		obj.styleLabel.text = player.playerStyleStr;
	}
}

-(UIImage *)playerImageForNumber:(float)number {
	number = [self boxValue:number min:0 max:5];
	int picId = (int)floor(number);
	return [ProjectFunctions playerImageOfType:picId];
}

-(int)boxValue:(int)value min:(int)min max:(int)max {
	if(value<min)
		value=min;
	if(value>max)
		value=max;
	return value;
}

-(void)positionBarsForsStat:(HudStatObj *)stat percent1:(int)percent1  percent2:(int)percent2 {
	percent1=[self boxValue:percent1 min:0 max:100];
	percent2=[self boxValue:percent2 min:0 max:100];
	UIImageView *bg = stat.bGImageView;
	stat.barView1.center = CGPointMake(bg.center.x-16, bg.frame.origin.y+bg.frame.size.height*percent1/100);
	stat.barView2.center = CGPointMake(bg.center.x+16, bg.frame.origin.y+bg.frame.size.height*percent2/100);
	stat.playerType1ImageView.center = CGPointMake(bg.center.x-40, bg.frame.origin.y+bg.frame.size.height*percent1/100);
	stat.playerType2ImageView.center = CGPointMake(bg.center.x+40, bg.frame.origin.y+bg.frame.size.height*percent2/100);
}

- (IBAction) buttonPressed1: (UIButton *) button {
	[self buttonPressedForObj:self.villianObj button:button];
}

- (IBAction) buttonPressed2: (UIButton *) button {
	[self buttonPressedForObj:self.heroObj button:button];
}

-(void)buttonPressedForObj:(PlayerObj *)obj button:(UIButton *)button {
	if(self.editMode) {
		int amount = obj.foldCount;
		if(button.tag==1)
			amount = obj.checkCount;
		if(button.tag==2)
			amount = obj.callCount;
		if(button.tag==3)
			amount = obj.raiseCount;
		NSArray *titles = [NSArray arrayWithObjects:@"Fold", @"Check", @"Call", @"Raise", nil];

		self.selectedPlayerObj = obj;
		self.selectedTag = (int)button.tag;
		MinuteEnterVC *localViewController = [[MinuteEnterVC alloc] initWithNibName:@"MinuteEnterVC" bundle:nil];
		[localViewController setCallBackViewController:self];
		localViewController.initialDateValue = [NSString stringWithFormat:@"%d", amount];
		localViewController.sendTitle = [titles objectAtIndex:button.tag];
		localViewController.managedObjectContext=self.managedObjectContext;
		[self.navigationController pushViewController:localViewController animated:YES];
		return;
	}
	if(self.heroObj.handCount==0 && self.villianObj.handCount==0 && self.heroObj.checkCount==0 && self.villianObj.checkCount==0 && !self.gameMo && !self.playerMo) {
		self.linkGameButton.hidden=YES;
		self.linkPlayerButton.hidden=YES;
		[ProjectFunctions showAlertPopup:@"Notice" message:@"You don't have a player or game linked so these stats will not be saved."];
	}
	switch (button.tag) {
  case 0:
			obj.foldCount++;
			break;
  case 1:
			obj.checkCount++;
			break;
  case 2:
			obj.callCount++;
			break;
  case 3:
			obj.raiseCount++;
			break;
  default:
			break;
	}
	[self updateDisplay];
	[self saveRecord];
}

-(void)saveRecord {
	if(self.gameMo) {
		NSLog(@"+++Saving gameMo data: %@ (hero)", [self packageDataForObj:self.heroObj]);
		NSLog(@"+++Saving gameMo data: %@ (vil)", [self packageDataForObj:self.villianObj]);
		[self.gameMo setValue:[self packageDataForObj:self.heroObj] forKey:@"attrib01"];
		[self.gameMo setValue:[self packageDataForObj:self.villianObj] forKey:@"attrib02"];
		[self saveDatabase];
	}
	if(self.playerMo) {
		NSLog(@"+++Saving playerMo data");
		[self.playerMo setValue:[self packageDataForObj:self.heroObj] forKey:@"attrib_05"];
		[self.playerMo setValue:[self packageDataForObj:self.villianObj] forKey:@"desc"];
		[self.playerMo setValue:[NSNumber numberWithInt:self.villianObj.looseNum] forKey:@"looseNum"];
		[self.playerMo setValue:[NSNumber numberWithInt:self.villianObj.agressiveNum] forKey:@"agressiveNum"];
		int segment = [self boxValue:self.villianObj.picId-2 min:0 max:3];
		[self.playerMo setValue:[NSNumber numberWithInt:segment] forKey:@"attrib_02"];
		[self saveDatabase];
	}
}

-(NSString *)packageDataForObj:(PlayerObj *)obj {
	NSLog(@"obj.playerId: %d", obj.playerId);
	return [NSString stringWithFormat:@"%d:%d:%d:%d:%d:%d:%d:%d:%@", obj.foldCount, obj.checkCount, obj.callCount, obj.raiseCount, obj.picId, obj.looseNum, obj.agressiveNum, obj.playerId, (obj.name)?obj.name:@""];
}

-(void)loadDataIntoPlayer:(PlayerObj *)obj heroFlag:(BOOL)heroFlag {
	if(self.gameMo) {
		NSString *field = (heroFlag)?@"attrib01":@"attrib02";
		NSString *packagedData = [self.gameMo valueForKey:field];
		NSString *status = [self.gameMo valueForKey:@"status"];
		if([@"Completed" isEqualToString:status]) {
			self.defaultButtonLock=YES;
			self.foldButton1.enabled=NO;
			self.foldButton2.enabled=NO;
			self.callButton1.enabled=NO;
			self.callButton2.enabled=NO;
			self.checkButton1.enabled=NO;
			self.checkButton2.enabled=NO;
			self.raiseButton1.enabled=NO;
			self.raiseButton2.enabled=NO;
		}
		[self populateHUDWithData:packagedData obj:obj];
		if(!heroFlag && obj.playerId>0) {
			NSLog(@"Load player...");
			NSPredicate *predicate = [NSPredicate predicateWithFormat:@"player_id = %d", obj.playerId];
			NSArray *players = [CoreDataLib selectRowsFromEntity:@"EXTRA" predicate:predicate sortColumn:nil mOC:self.managedObjectContext ascendingFlg:YES];
			if (players.count>0) {
				self.playerMo = [players objectAtIndex:0];
				[self initializeVillian];
				return;
			} else {
				[ProjectFunctions showAlertPopup:@"Error" message:@"Unable to load Villian!"];
			}

		}
	}
	if(self.playerMo) {
		NSString *field = (heroFlag)?@"attrib_05":@"desc";
		NSString *packagedData = [self.playerMo valueForKey:field];
		[self populateHUDWithData:packagedData obj:obj];
	}
}

-(void)populateHUDWithData:(NSString *)packagedData obj:(PlayerObj *)obj {
	NSLog(@"populateHUDWithData: %@", packagedData);
	NSArray *components = [packagedData componentsSeparatedByString:@":"];
	if(components.count>3) {
		obj.foldCount=[[components objectAtIndex:0] intValue];
		obj.checkCount=[[components objectAtIndex:1] intValue];
		obj.callCount=[[components objectAtIndex:2] intValue];
		obj.raiseCount=[[components objectAtIndex:3] intValue];
	}
	if(components.count>7) {
		obj.playerId = [[components objectAtIndex:7] intValue];
	}
}

-(void) setReturningValue:(NSString *) value {
	if(self.selectedTag==0)
		self.selectedPlayerObj.foldCount = [value intValue];
	if(self.selectedTag==1)
		self.selectedPlayerObj.checkCount = [value intValue];
	if(self.selectedTag==2)
		self.selectedPlayerObj.callCount = [value intValue];
	if(self.selectedTag==3)
		self.selectedPlayerObj.raiseCount = [value intValue];
	[self updateDisplay];
	[self saveRecord];
}

- (IBAction) trashButtonPressed1: (UIButton *) button {
	[self emptyTrashForPlayer:self.villianObj];
	self.linkPlayerButton.hidden=NO;
}
- (IBAction) trashButtonPressed2: (UIButton *) button {
	[self emptyTrashForPlayer:self.heroObj];
	self.linkGameButton.hidden=NO;
}

-(void)emptyTrashForPlayer:(PlayerObj *)player {
	player.foldCount=0;
	player.checkCount=0;
	player.callCount=0;
	player.raiseCount=0;
	[self saveRecord];
	[self updateDisplay];
}

- (IBAction) infoButtonPressed: (UIButton *) button {
	switch (button.tag) {
  case 0:
			[self populatePopupWithTitle:@"VPIP" text:@"VPIP and PFR are two basic but powerful poker statistics. Combined, they give you a clear picture of how your opponents are playing and ways to exploit their mistakes.\n\nVPIP tracks the percentage of hands in which a particular player voluntarily puts money into the pot preflop. VPIP increases when a player could fold but instead commits money to the pot preflop. This includes limping (merely calling the big blind), calling, and raising.\n\nPosting the small and big blinds does not influence the VPIP statistic. These actions are involuntary and therefore give no useful information on player tendencies.\n\nA player with a high VPIP and low PFR is one you want at your table. These opponents play far too many hands, and they usually play them very passively. Players who have a very high VPIP and low PFR call far too much preflop. When they do raise, they are weighted towards value.\n\n-pokercopilot.com"];
			break;
  case 1:
			[self populatePopupWithTitle:@"PFR" text:@"Pre-Flop Raise. PFR tracks the percentage of hands in which a particular player makes a preflop raise when having the opportunity to fold or call instead. This includes reraises.\n\nVPIP is always higher than PFR (or equal). All preflop raises increase VPIP, but not all actions that influence VPIP will affect PFR. For example, limping preflop will increase VPIP but not PFR.\n\nNew players usually call too much preflop. Calling far more often than raising causes your VPIP to rise higher than your PFR, creating a gap between the two stats. This is a warning sign that you are moving away from the aggressive strategy essential to winning at poker. Winning players have a tight gap between their VPIP and their PFR.\n\nA quick rule of the thumb is that the higher the PFR, the more aggressive a player is. The bigger the gap between VPIP and PFR, the more passive a player is.\n\n-pokercopilot.com"];
			break;
  case 2:
			[self populatePopupWithTitle:@"AF" text:@"Aggression Factor. This is the percentage of VPIP hands that are raised. It measures raises versus calls.\n\nEvery time you raise, your AF goes up, and every time you call it goes down. Checking and folding do not influence your AF\n\nHaving a high AF means you are playing more aggressive poker and you generally do not want this number to drop below 25%.\n\nThe number in red is the traditional AF notation written as raises per call."];
			break;
			
  default:
			break;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *cellIdentifier = [NSString stringWithFormat:@"cellIdentifierSection%dRow%d", (int)indexPath.section, (int)indexPath.row];
	NSManagedObject *mo = [self.mainArray objectAtIndex:indexPath.row];
	if(self.linkButtonTag==0) {
		PlayerTrackerObj *obj = [PlayerTrackerObj createObjWithMO:mo managedObjectContext:self.managedObjectContext];
		QuadWithImageTableViewCell *cell = [[QuadWithImageTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
		return [QuadWithImageTableViewCell cellForPlayer:obj cell:cell];
	} else {
		GameCell *cell = [[GameCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
		[GameCell populateCell:cell obj:mo evenFlg:indexPath.row%2==0];
		return cell;
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	self.playersView.hidden=YES;
	NSManagedObject *mo = [self.mainArray objectAtIndex:indexPath.row];
	if(self.linkButtonTag==0) {
		self.playerMo = mo;
		if (self.playerMo) {
			[self loadDataIntoPlayer:self.villianObj heroFlag:NO];
			[self initializeVillian];
			NSLog(@"villianObj.playerId: %d", self.villianObj.playerId);
		}
		if(!self.gameMo)
			[self loadDataIntoPlayer:self.heroObj heroFlag:YES];
	} else {
		self.gameMo = mo;
		[self loadDataIntoPlayer:self.heroObj heroFlag:YES];
		if(!self.playerMo)
			[self loadDataIntoPlayer:self.villianObj heroFlag:NO];
	}
	[self updateDisplay];
}

@end
