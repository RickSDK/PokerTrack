//
//  EditPlayerTracker.m
//  PokerTracker
//
//  Created by Rick Medved on 1/16/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "EditPlayerTracker.h"
#import "ProjectFunctions.h"
#import "TextEnterVC.h"
//#import "ListPicker.h"
#import "CoreDataLib.h"
#import "AddPhotoVC.h"
#import "NSArray+ATTArray.h"
#import "PlayerTrackerVC.h"
#import "MultiLineDetailCellWordWrap.h"
#import "HudTrackerVC.h"
#import "EditSegmentVC.h"


@implementation EditPlayerTracker
@synthesize managedObjectContext, nameField, looseTightSeg, passAgrSeg, typeLabel, skillLabel;
@synthesize overallPlaySeg, casinoButton, saveButton, playerPic, picLabel, deleteButton;
@synthesize selectedObjectForEdit, callBackViewController, managedObject;
@synthesize playerNumLabel, readOnlyFlg, casino, showMenuFlg, hudStyleLabel;

- (void)viewDidLoad {
	[super viewDidLoad];
	[self setTitle:@"Player"];
	[self changeNavToIncludeType:3];
	
	deleteButton.alpha=0;
	
	[ProjectFunctions makeFAButton:deleteButton type:0 size:24];
	
	saveButton = [ProjectFunctions UIBarButtonItemWithIcon:[NSString fontAwesomeIconStringForEnum:FAFloppyO] target:self action:@selector(savePressed:)];
	self.navigationItem.rightBarButtonItem = saveButton;
	if(managedObject)
		[saveButton setTitle:[NSString fontAwesomeIconStringForEnum:FAPencil]];
	
	[casinoButton setBackgroundImage:[UIImage imageNamed:@"yellowGlossButton.png"] forState:UIControlStateNormal];
	if([casino isEqualToString:@"All Locations"])
		casino = @"Select";
	[casinoButton setTitle:casino forState:UIControlStateNormal];
	
	[ProjectFunctions makeFAButton:self.hudButton type:5 size:16 text:@"HUD Tracker"];
	
	if(managedObject) {
		self.playerTrackerObj = [PlayerTrackerObj createObjWithMO:managedObject managedObjectContext:self.managedObjectContext];
		if(self.playerTrackerObj.user_id==0)
			[self generateUserId];
		readOnlyFlg=YES;
	} else {
		self.playerTrackerObj = [[PlayerTrackerObj alloc] init];
		self.playerTrackerObj.strengths=@"";
		self.playerTrackerObj.weaknesses=@"";
		self.playerTrackerObj.playerSkill = 1; //average
		self.playerTrackerObj.picId = 3;
		deleteButton.alpha=0;
		readOnlyFlg=NO;
	}
	[self updateButtonsEnabled:!readOnlyFlg];
}

-(void)updateImage
{
	// This is called directly from AddPhotoVC
	NSLog(@"updateImage!!");

	NSString *jpgPath = [ProjectFunctions getPicPath:self.playerTrackerObj.user_id];
	NSFileHandle *fh = [NSFileHandle fileHandleForReadingAtPath:jpgPath];
	if(fh==nil)
		NSLog(@"nil!");
	else {
		self.playerTrackerObj.pic  = [UIImage imageWithContentsOfFile:jpgPath];
		playerPic.image = self.playerTrackerObj.pic;
		picLabel.alpha=0;
	}
	[fh closeFile];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if(buttonIndex!=actionSheet.cancelButtonIndex) {
		AddPhotoVC *detailViewController = [[AddPhotoVC alloc] initWithNibName:@"AddPhotoVC" bundle:nil];
		detailViewController.managedObject = managedObject;
		detailViewController.managedObjectContext = managedObjectContext;
		detailViewController.menuNumber = self.playerTrackerObj.user_id;
		detailViewController.cameraMode=buttonIndex;
		detailViewController.callBackViewController=self;
		[self.navigationController pushViewController:detailViewController animated:YES];
	}
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if(buttonIndex==1 && managedObject != nil) {
		[managedObjectContext deleteObject:managedObject];
		[managedObjectContext save:nil];
		[(PlayerTrackerVC *)callBackViewController reloadData];
		[self.navigationController popViewControllerAnimated:YES];	
	}
}

- (IBAction) deletePressed: (id) sender
{
	[ProjectFunctions showConfirmationPopup:@"Delete Record" message:@"Are you sure you want to delete this player?" delegate:self tag:1];
}

-(IBAction) segmentPressed:(id)sender
{
	if(readOnlyFlg) {
		[self updateSegment];
	} else {
		self.playerTrackerObj.playerSkill = (int)overallPlaySeg.selectedSegmentIndex;
		self.playerTrackerObj.picId = (self.playerTrackerObj.playerSkill==0)?1:self.playerTrackerObj.playerSkill+2;
		[self updatePlayerTypeImage];
	}
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	if(readOnlyFlg) {
		[ProjectFunctions showAlertPopup:@"Read Only" message:@"Press 'Edit' to update this player."];
		return;
	}
	
	UITouch *touch = [[event allTouches] anyObject];
	CGPoint startTouchPosition = [touch locationInView:touch.view];
	if(startTouchPosition.x >= 15 && startTouchPosition.x <= 126 && startTouchPosition.y>=51 && startTouchPosition.y<=168) {
		if(managedObject==nil)
			[ProjectFunctions showAlertPopup:NSLocalizedString(@"notice", nil) message:@"Save record before adding photo"];
		else {
			UIActionSheet *actionSheet;
			actionSheet=[[UIActionSheet alloc] initWithTitle:@"Add a Photo" 
												delegate:self 
									   cancelButtonTitle:@"Cancel" 
								  destructiveButtonTitle:nil 
									   otherButtonTitles:@"Use Camera", @"Select Photo From Library", nil];
			[actionSheet showInView:self.view];
		}
	}		
}

-(BOOL)textField:(UITextField *)textFieldlocal shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
	return [ProjectFunctions limitTextFieldLength:textFieldlocal currentText:nameField.text string:string limit:20 saveButton:saveButton resignOnReturn:YES];
}

-(BOOL)textFieldShouldReturn:(UITextField *)aTextField {
	NSLog(@"Return!");
	[aTextField resignFirstResponder];
	self.playerTrackerObj.name = aTextField.text;
	return YES;
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
	NSLog(@"change!");
	[textView resignFirstResponder];
	return YES;
}

- (IBAction) hudButtonPressed: (id) sender
{
	if(managedObject) {
		HudTrackerVC *localViewController = [[HudTrackerVC alloc] initWithNibName:@"HudTrackerVC" bundle:nil];
		localViewController.managedObjectContext=managedObjectContext;
		localViewController.playerMo = self.managedObject;
		[self.navigationController pushViewController:localViewController animated:YES];
	} else
		[ProjectFunctions showAlertPopup:@"Notice" message:@"Save record first"];
}

- (IBAction) casinoButtonPressed: (id) sender
{
	self.selectedObjectForEdit=3;
	EditSegmentVC *localViewController = [[EditSegmentVC alloc] initWithNibName:@"EditSegmentVC" bundle:nil];
	localViewController.callBackViewController=self;
	localViewController.managedObjectContext = managedObjectContext;
	localViewController.initialDateValue = casinoButton.titleLabel.text;
	localViewController.readyOnlyFlg = YES;
	localViewController.databaseField = @"location";
	[self.navigationController pushViewController:localViewController animated:YES];
}

- (IBAction) savePressed: (id) sender
{
	if(readOnlyFlg) {
		[saveButton setTitle:[NSString fontAwesomeIconStringForEnum:FAFloppyO]];
		readOnlyFlg=NO;
		[self updateButtonsEnabled:!readOnlyFlg];
		[self.mainTableView reloadData];
		return;
	}
	if([casinoButton.titleLabel.text isEqualToString:@"Select"]) {
		[ProjectFunctions showAlertPopup:NSLocalizedString(@"notice", nil) message:@"Select Primary Casino"];
		return;
	}
	if(nameField.text.length==0) {
		[ProjectFunctions showAlertPopup:NSLocalizedString(@"notice", nil) message:@"Enter a first name."];
		return;
	}
	
	if (self.playerTrackerObj.user_id==0)
		[self generateUserId];

	NSMutableArray *valueList = [[NSMutableArray alloc] init];
	[valueList addObject:@"PLAYER"];
	[valueList addObject:[NSString stringWithFormat:@"%@", nameField.text]];
	[valueList addObject:[NSString stringWithFormat:@"%d", 0]]; // playerType
	[valueList addObject:[NSString stringWithFormat:@"%d", (int)overallPlaySeg.selectedSegmentIndex]];
	[valueList addObject:[NSString stringWithFormat:@"%@", self.playerTrackerObj.strengths]];
	[valueList addObject:[NSString stringWithFormat:@"%@", self.playerTrackerObj.weaknesses]];
	[valueList addObject:[NSString stringWithFormat:@"%@", casinoButton.titleLabel.text]];
	[valueList addObject:[NSString stringWithFormat:@"%d", self.playerTrackerObj.user_id]];
	[valueList addObject:[NSString stringWithFormat:@"%d", self.playerTrackerObj.player_id]];
	[valueList addObject:[NSString stringWithFormat:@"%d", self.playerTrackerObj.looseNum]];
	[valueList addObject:[NSString stringWithFormat:@"%d", self.playerTrackerObj.agressiveNum]];

	if(managedObject == nil) {
		[CoreDataLib insertManagedObjectForEntity:@"EXTRA" valueList:valueList mOC:managedObjectContext];
	} else
		[CoreDataLib updateManagedObjectForEntity:managedObject entityName:@"EXTRA" valueList:valueList mOC:managedObjectContext];

	[(PlayerTrackerVC *)callBackViewController reloadData];
	[self.navigationController popViewControllerAnimated:YES];
}


-(void)mainMenuButtonClicked:(id)sender {
	[self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
}

-(void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	if(managedObject) {
		// check for HUD change!
		NSString *hudString = [managedObject valueForKey:@"desc"];
		if(hudString && ![hudString isEqualToString:self.playerTrackerObj.hudString]) {
			NSLog(@"Hud update!! %@ to %@", hudString, self.playerTrackerObj.hudString);
			self.playerTrackerObj = [PlayerTrackerObj createObjWithMO:managedObject managedObjectContext:self.managedObjectContext];
		}
	}
	if(self.playerTrackerObj)
		[self updateDisplay];
}

-(void)updateDisplay {
	PlayerTrackerObj *obj = self.playerTrackerObj;
	self.hudStyleLabel.text = obj.hudPlayerType;
	if(obj.hudFlag) {
		self.hudPlayerTypeImageView.image = [ProjectFunctions playerImageOfType:self.playerTrackerObj.hudPicId];
	}
	self.hudPlayerTypeImageView.hidden=!obj.hudFlag;
	
	nameField.text = obj.name;

	if(self.playerTrackerObj.location)
		[casinoButton setTitle:[NSString stringWithFormat:@"%@", self.playerTrackerObj.location] forState:UIControlStateNormal];
	
	[self updateSLider:self.bar1 bgImage:self.bgImage1 number:obj.looseNum];
	[self updateSLider:self.bar2 bgImage:self.bgImage2 number:obj.agressiveNum];
	
	playerPic.image = obj.pic;
	self.typeLabel.text = obj.playerType;
	self.typeLabel.textColor = [ProjectFunctions primaryButtonColor];
	
	[self updateSegment];
	[self.mainTableView reloadData];
}

-(void)updateSegment {
	overallPlaySeg.selectedSegmentIndex=self.playerTrackerObj.playerSkill;
	[overallPlaySeg changeSegment];
	[self updatePlayerTypeImage];
}

-(void)updatePlayerTypeImage {
	self.playerTypeImageView.image = [ProjectFunctions playerImageOfType:self.playerTrackerObj.picId];
}

-(void)updateSLider:(UIView *)bar bgImage:(UIImageView *)bgImage number:(int)number {
	bar.center = CGPointMake(bgImage.frame.origin.x+bgImage.frame.size.width*number/100, bgImage.center.y);
	
}

-(void)updateButtonsEnabled:(BOOL)enabledFlg {
	self.minusButton1.enabled=enabledFlg;
	self.minusButton2.enabled=enabledFlg;
	self.plusButton1.enabled=enabledFlg;
	self.plusButton2.enabled=enabledFlg;
	casinoButton.enabled=enabledFlg;
	nameField.enabled=enabledFlg;
	passAgrSeg.enabled=enabledFlg;
	looseTightSeg.enabled=enabledFlg;
//	overallPlaySeg.enabled=enabledFlg;
	if(managedObject)
		deleteButton.alpha=enabledFlg;
	picLabel.hidden=!enabledFlg;
}

-(void)generateUserId {
	//------------update this stuff for some reason------------------
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"type = %@", @"PLAYER"];
	NSArray *items = [CoreDataLib selectRowsFromEntity:@"EXTRA" predicate:predicate sortColumn:@"user_id" mOC:managedObjectContext ascendingFlg:NO];
	self.playerTrackerObj.user_id = 1;
	if([items count]>0) {
		NSManagedObject *mo2 = [items objectAtIndex:0];
		self.playerTrackerObj.user_id = [[mo2 valueForKey:@"user_id"] intValue];
		self.playerTrackerObj.user_id++;
	}
	if(self.playerTrackerObj.player_id==0) {
		self.playerTrackerObj.player_id = [ProjectFunctions generateUniqueId];
	}
	
	NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"type = %@ AND user_id = %d", @"PLAYER", self.playerTrackerObj.user_id];
	NSArray *items2 = [CoreDataLib selectRowsFromEntity:@"EXTRA" predicate:predicate2 sortColumn:nil mOC:managedObjectContext ascendingFlg:YES];
	if([items2 count]>1) {
		self.playerTrackerObj.player_id = [ProjectFunctions generateUniqueId];
	}
	NSLog(@"generateUserId: user_id: %d, player_id: %d", self.playerTrackerObj.user_id, self.playerTrackerObj.player_id);
	if (managedObject) {
		[managedObject setValue:[NSNumber numberWithInt:self.playerTrackerObj.user_id] forKey:@"user_id"];
		[managedObject setValue:[NSNumber numberWithInt:self.playerTrackerObj.player_id] forKey:@"player_id"];
		[managedObjectContext save:nil];
	}
}

- (IBAction) plusMinusButtonPressed: (UIButton *) button {
	if(button.tag==0)
		self.playerTrackerObj.looseNum -= 10;
	if(button.tag==1)
		self.playerTrackerObj.looseNum += 10;
	if(button.tag==2)
		self.playerTrackerObj.agressiveNum -= 10;
	if(button.tag==3)
		self.playerTrackerObj.agressiveNum += 10;
	
	self.playerTrackerObj.looseNum = [self limitNumber:self.playerTrackerObj.looseNum];
	self.playerTrackerObj.agressiveNum = [self limitNumber:self.playerTrackerObj.agressiveNum];
	[self updateSLider:self.bar1 bgImage:self.bgImage1 number:self.playerTrackerObj.looseNum];
	[self updateSLider:self.bar2 bgImage:self.bgImage2 number:self.playerTrackerObj.agressiveNum];
	self.playerTrackerObj.playerType = [ProjectFunctions playerTypeFromLlooseNum:self.playerTrackerObj.looseNum agressiveNum:self.playerTrackerObj.agressiveNum];

//	self.playerTrackerObj.playerType = [NSString stringWithFormat:@"%@-%@", (self.playerTrackerObj.looseNum<=50)?@"Loose":@"Tight", (self.playerTrackerObj.agressiveNum<=50)?@"Passive":@"Aggressive"];
	self.typeLabel.text = self.playerTrackerObj.playerType;
}

-(int)limitNumber:(int)number {
	if (number>100)
		return 100;
	if(number<0)
		return 0;
	return number;
}

-(void) setReturningValue:(NSString *) value {
	if(selectedObjectForEdit==1)
		self.playerTrackerObj.strengths = value;// self.strengthsText=value2;
	if(selectedObjectForEdit==2)
		self.playerTrackerObj.weaknesses = value;// self.weaknessText=value2;
	if(selectedObjectForEdit==3)
		self.playerTrackerObj.location = value;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	NSString *cellIdentifier = [NSString stringWithFormat:@"cellIdentifierSection%dRow%d", (int)indexPath.section, (int)indexPath.row];
	MultiLineDetailCellWordWrap *cell = (MultiLineDetailCellWordWrap *) [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (cell == nil) {
		cell = [[MultiLineDetailCellWordWrap alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier withRows:1 labelProportion:0.0];
	}

	cell.mainTitle = (indexPath.row==0)?@"Strengths":@"Weaknesses";
	
	if(self.playerTrackerObj) {
		cell.titleTextArray = [NSArray arrayWithObject:@""];
		cell.fieldTextArray = [NSArray arrayWithObject:(indexPath.row==0)?self.playerTrackerObj.strengths:self.playerTrackerObj.weaknesses];
		cell.fieldColorArray = [NSArray arrayWithObject:[UIColor blackColor]];
	}
	cell.accessoryType= UITableViewCellAccessoryNone;
	if(!readOnlyFlg)
		cell.accessoryType= UITableViewCellAccessoryDisclosureIndicator;
	
	cell.selectionStyle = UITableViewCellSelectionStyleNone;

	return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 2;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if(!readOnlyFlg) {
		self.selectedObjectForEdit=(int)indexPath.row+1;
		TextEnterVC *localViewController = [[TextEnterVC alloc] initWithNibName:@"TextEnterVC" bundle:nil];
		localViewController.managedObjectContext=managedObjectContext;
		[localViewController setCallBackViewController:self];
		localViewController.initialDateValue = (indexPath.row==0)?self.playerTrackerObj.strengths:self.playerTrackerObj.weaknesses;
		localViewController.titleLabel = (indexPath.row==0)?@"Player Strengths":@"Player Weaknesses";
		localViewController.strlen=500;
		[self.navigationController pushViewController:localViewController animated:YES];
	}
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return CGFLOAT_MIN;
}


-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (self.playerTrackerObj)
		return [MultiLineDetailCellWordWrap cellHeightForData:[NSArray arrayWithObject:(indexPath.row==0)?self.playerTrackerObj.strengths:self.playerTrackerObj.weaknesses] tableView:self.mainTableView labelWidthProportion:0];
	else
		return 44;
}




@end
