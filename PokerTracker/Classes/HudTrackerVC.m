//
//  HudTrackerVC.m
//  PokerTracker
//
//  Created by Rick Medved on 7/9/17.
//
//

#import "HudTrackerVC.h"
#import "MinuteEnterVC.h"

@interface HudTrackerVC ()

@end

@implementation HudTrackerVC

- (void)viewDidLoad {
    [super viewDidLoad];
	[self setTitle:@"HUD Tracker"];

	self.navigationItem.rightBarButtonItem = [ProjectFunctions UIBarButtonItemWithIcon:[NSString fontAwesomeIconStringForEnum:FAPencil] target:self action:@selector(editButtonClicked)];
	
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
	
	[self setupScreen];
	[self loadDataIntoPlayer:self.heroObj heroFlag:YES];
	[self loadDataIntoPlayer:self.villianObj heroFlag:NO];
	[self updateDisplay];

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

-(void)updateHudStat:(HudStatObj *)stat top1:(int)top1 bottom1:(int)bottom1 top2:(int)top2 bottom2:(int)bottom2 {
	stat.percentLabel1.text = @"-";
	stat.percentLabel2.text = @"-";
	int percent1= 50;
	int percent2= 50;
	
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
	
	[self positionBarsForsStat:stat percent1:percent1 percent2:percent2];
	
}

-(void)calculateVPIP {
	self.villianObj.handCount = self.villianObj.foldCount+self.villianObj.callCount+self.villianObj.raiseCount;
	self.heroObj.handCount = self.heroObj.foldCount+self.heroObj.callCount+self.heroObj.raiseCount;
	int top1 = self.villianObj.callCount+self.villianObj.raiseCount;
	int top2 = self.heroObj.callCount+self.heroObj.raiseCount;
	self.heroObj.vpip=50;
	self.villianObj.vpip=50;
	if (self.heroObj.handCount>0)
		self.heroObj.vpip = top2*100/self.heroObj.handCount;
	if (self.villianObj.handCount>0)
		self.villianObj.vpip = top1*100/self.villianObj.handCount;
	
	[self updateHudStat:self.vpipObj top1:top1 bottom1:self.villianObj.handCount top2:top2 bottom2:self.heroObj.handCount];
}

-(void)calculatePFR {
	self.villianObj.handCount = self.villianObj.foldCount+self.villianObj.callCount+self.villianObj.raiseCount;
	self.heroObj.handCount = self.heroObj.foldCount+self.heroObj.callCount+self.heroObj.raiseCount;
	int top1 = self.villianObj.raiseCount;
	int top2 = self.heroObj.raiseCount;
	self.heroObj.pfr=50;
	self.villianObj.pfr=50;
	if (self.heroObj.handCount>0)
		self.heroObj.pfr = top2*100/self.heroObj.handCount;
	if (self.villianObj.handCount>0)
		self.villianObj.pfr = top1*100/self.villianObj.handCount;
	
	[self updateHudStat:self.pfrObj top1:top1 bottom1:self.villianObj.handCount top2:top2 bottom2:self.heroObj.handCount];
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
	
	[self updateHudStat:self.afObj top1:self.villianObj.raiseCount bottom1:bottom1 top2:self.heroObj.raiseCount bottom2:bottom2];
	
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
}

-(void)updatePlayerSkillImage:(HudActionObj *)obj player:(PlayerObj *)player vpip:(UIImageView *)vpip pfr:(UIImageView *)pfr af:(UIImageView *)af {
	if (player.handCount==0) {
		obj.styleLabel.text = @"-";
		obj.skillImageView.image = [UIImage imageNamed:@"Icon.png"];
		vpip.image = [UIImage imageNamed:@"Icon.png"];
		pfr.image = [UIImage imageNamed:@"Icon.png"];
		af.image = [UIImage imageNamed:@"Icon.png"];
	} else {
		float skill1 = [self trimSkill:7.15-(float)player.vpip/6.5];
		
		float skill2Percent = 0;
		if(player.vpip>0)
			skill2Percent = player.pfr*100/player.vpip;
		float skill2 = [self trimSkill:ceil(skill2Percent/10)-2];
		float skill3 = [self trimSkill:(float)player.af/8];
		
		vpip.image = [self playerImageForNumber:skill1];
		pfr.image = [self playerImageForNumber:skill2];
		af.image = [self playerImageForNumber:skill3];

		obj.skillImageView.image = [self playerImageForNumber:(skill1+skill3)/2];

		NSString *style1 = (skill1>=3)?@"Tight":@"Loose";
		NSString *style2 = (skill2+skill3>=6)?@"Aggressive":@"Passive";
		player.playerStyleStr = [NSString stringWithFormat:@"%@-%@", style1, style2];
		obj.styleLabel.text = player.playerStyleStr;
	}
}

-(float)trimSkill:(float)skill {
	if(skill<0)
		skill=0;
	if(skill>5)
		skill=5;
	return skill;
}

-(UIImage *)playerImageForNumber:(float)number {
	number = [self trimSkill:number];
	int picId = (int)floor(number);
	return [UIImage imageNamed:[NSString stringWithFormat:@"playerType%d.png", picId]];
}

-(void)positionBarsForsStat:(HudStatObj *)stat percent1:(int)percent1  percent2:(int)percent2 {
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
		[self.gameMo setValue:[self packageDataForObj:self.heroObj] forKey:@"attrib01"];
		[self.gameMo setValue:[self packageDataForObj:self.villianObj] forKey:@"attrib02"];
		[self.managedObjectContext save:nil];
	}
	if(self.playerMo) {
		[self.playerMo setValue:[self packageDataForObj:self.heroObj] forKey:@"attrib_05"];
		[self.playerMo setValue:[self packageDataForObj:self.villianObj] forKey:@"desc"];
		[self.managedObjectContext save:nil];
	}
}

-(NSString *)packageDataForObj:(PlayerObj *)obj {
	return [NSString stringWithFormat:@"%d:%d:%d:%d:%d:%d:%d:%@", obj.foldCount, obj.checkCount, obj.callCount, obj.raiseCount, obj.vpip, obj.pfr, obj.af, obj.playerStyleStr];
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
	}
	if(self.playerMo) {
		NSString *field = (heroFlag)?@"attrib_05":@"desc";
		NSString *packagedData = [self.playerMo valueForKey:field];
		[self populateHUDWithData:packagedData obj:obj];
	}
}

-(void)populateHUDWithData:(NSString *)packagedData obj:(PlayerObj *)obj {
	NSArray *components = [packagedData componentsSeparatedByString:@":"];
	if(components.count>3) {
		obj.foldCount=[[components objectAtIndex:0] intValue];
		obj.checkCount=[[components objectAtIndex:1] intValue];
		obj.callCount=[[components objectAtIndex:2] intValue];
		obj.raiseCount=[[components objectAtIndex:3] intValue];
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
	[self saveRecord];
	[self updateDisplay];
}

- (IBAction) trashButtonPressed1: (UIButton *) button {
	[self emptyTrashForPlayer:self.villianObj];
}
- (IBAction) trashButtonPressed2: (UIButton *) button {
	[self emptyTrashForPlayer:self.heroObj];
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
			[ProjectFunctions showAlertPopup:@"VPIP" message:@"Voluntarily Puts money In Pot. This is the percentage of hands a player calls or raises pre-flop."];
			break;
  case 1:
			[ProjectFunctions showAlertPopup:@"PFR" message:@"Pre-Flop Raise. This is the percentage of hands a player raises pre-flop."];
			break;
  case 2:
			[ProjectFunctions showAlertPopup:@"AF" message:@"Aggression Factor. This is the percentage of VPIP hands that are raised. It measures raises versus calls. The number in red is the traditional AF notation written as raises per call."];
			break;
			
  default:
			break;
	}
}

@end
