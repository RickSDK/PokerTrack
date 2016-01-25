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
#import "ListPicker.h"
#import "CoreDataLib.h"
#import "AddPhotoVC.h"
#import "NSArray+ATTArray.h"
#import "PlayerTrackerVC.h"


@implementation EditPlayerTracker
@synthesize managedObjectContext, nameField, looseTightSeg, passAgrSeg, user_id, typeLabel, skillLabel, passagrSlider, tightlooseSlider;
@synthesize overallPlaySeg, strengthsText, weaknessText, casinoButton, saveButton, playerPic, picLabel, deleteButton;
@synthesize sEditButton, wEditButton, selectedObjectForEdit, callBackViewController, managedObject;
@synthesize playerNumLabel, readOnlyFlg, casino, showMenuFlg;


-(void)changeTypeLabel
{
	if(tightlooseSlider.value<=.5 && passagrSlider.value<=.5)
		typeLabel.text = @"Loose - Passive";
	if(tightlooseSlider.value<=.5 && passagrSlider.value>.5)
		typeLabel.text = @"Loose - Aggresive";
	if(tightlooseSlider.value>.5 && passagrSlider.value<=.5)
		typeLabel.text = @"Tight - Passive";
	if(tightlooseSlider.value>.5 && passagrSlider.value>.5)
		typeLabel.text = @"Tight - Aggresive";
}

- (IBAction) slider1changed:(id)sender
{
	[self changeTypeLabel];
}

- (IBAction) slider2changed:(id)sender
{
	[self changeTypeLabel];
}


-(void)updateImage
{
	UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] initWithTitle:@"Main Menu" style:UIBarButtonItemStylePlain target:self action:@selector(mainMenuButtonClicked:)];
	self.navigationItem.leftBarButtonItem = menuButton;
	
	saveButton = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(savePressed:)];
	self.navigationItem.rightBarButtonItem = saveButton;
	saveButton.enabled=YES;

	NSString *jpgPath = [ProjectFunctions getPicPath:user_id];
	NSFileHandle *fh = [NSFileHandle fileHandleForReadingAtPath:jpgPath];
	if(fh==nil)
		NSLog(@"nil!");
	else {
		playerPic.image = [UIImage imageWithContentsOfFile:jpgPath];
		picLabel.alpha=0;
	}
	[fh closeFile];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if(buttonIndex<2) {
		AddPhotoVC *detailViewController = [[AddPhotoVC alloc] initWithNibName:@"AddPhotoVC" bundle:nil];
		detailViewController.managedObject = managedObject;
		detailViewController.managedObjectContext = managedObjectContext;
		detailViewController.menuNumber = user_id;
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

-(void)setUserPic
{
	user_id = [[managedObject valueForKey:@"user_id"] intValue];
	NSString *jpgPath = [ProjectFunctions getPicPath:user_id];
	
	NSFileHandle *fh = [NSFileHandle fileHandleForReadingAtPath:jpgPath];
	if(fh==nil)
		playerPic.image = [UIImage imageNamed:[NSString stringWithFormat:@"playerType%d.png", (int)overallPlaySeg.selectedSegmentIndex+1]];
	else {
		playerPic.image = [UIImage imageWithContentsOfFile:jpgPath];
		picLabel.alpha=0;
	}
	[fh closeFile];

	
}

-(IBAction) segmentPressed:(id)sender
{
	NSArray *skills = [NSArray arrayWithObjects:@"Weak", @"Average", @"Strong", @"Pro", nil];
	skillLabel.text = [skills stringAtIndex:(int)overallPlaySeg.selectedSegmentIndex];
	[self setUserPic];
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
			[ProjectFunctions showAlertPopup:@"Notice" message:@"Save record before adding photo"];
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
	saveButton.enabled=YES;
	if([nameField.text length]==0)
		saveButton.enabled=NO;
//	if([casinoButton.titleLabel.text isEqualToString:@"Select"])
//		saveButton.enabled=NO;
	[aTextField resignFirstResponder];
	return YES;
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
	[textView resignFirstResponder];
	return YES;
}

- (IBAction) editSPressed: (id) sender
{
	self.selectedObjectForEdit=1;
	TextEnterVC *localViewController = [[TextEnterVC alloc] initWithNibName:@"TextEnterVC" bundle:nil];
	localViewController.managedObjectContext=managedObjectContext;
	[localViewController setCallBackViewController:self];
	localViewController.initialDateValue = strengthsText.text;
	localViewController.titleLabel = @"Player Strengths";
	localViewController.strlen=500;
	[self.navigationController pushViewController:localViewController animated:YES];
}

- (IBAction) editWPressed: (id) sender
{
	self.selectedObjectForEdit=2;
	TextEnterVC *localViewController = [[TextEnterVC alloc] initWithNibName:@"TextEnterVC" bundle:nil];
	[localViewController setCallBackViewController:self];
	localViewController.managedObjectContext=managedObjectContext;
	localViewController.initialDateValue = weaknessText.text;
	localViewController.titleLabel = @"Player Weaknesses";
	localViewController.strlen=500;
	[self.navigationController pushViewController:localViewController animated:YES];
}

- (IBAction) casinoButtonPressed: (id) sender
{
	self.selectedObjectForEdit=3;
	ListPicker *localViewController = [[ListPicker alloc] initWithNibName:@"ListPicker" bundle:nil];
	localViewController.callBackViewController=self;
	localViewController.managedObjectContext = managedObjectContext;
	localViewController.initialDateValue = [NSString stringWithFormat:@"%@", casinoButton.titleLabel.text];
	localViewController.titleLabel = @"Location";
	localViewController.selectedList=0;
	localViewController.selectionList = [CoreDataLib getFieldList:@"Location" mOC:managedObjectContext addAllTypesFlg:YES];
	localViewController.allowEditing=NO;
	[self.navigationController pushViewController:localViewController animated:YES];
}

- (IBAction) savePressed: (id) sender
{
	if(readOnlyFlg) {
		[saveButton setTitle:@"Save"];
		readOnlyFlg=NO;
		sEditButton.alpha=1;
		wEditButton.alpha=1;
		casinoButton.enabled=YES;
		nameField.enabled=YES;
		passAgrSeg.enabled=YES;
		looseTightSeg.enabled=YES;
		overallPlaySeg.enabled=YES;
		tightlooseSlider.enabled=YES;
		passagrSlider.enabled=YES;
		deleteButton.alpha=1;
		return;
	}
	if([casinoButton.titleLabel.text isEqualToString:@"Select"]) {
		[ProjectFunctions showAlertPopup:@"Notice" message:@"Select Primary Casino"];
		return;
	}

	NSMutableArray *valueList = [[NSMutableArray alloc] init];
	[valueList addObject:@"PLAYER"];
	[valueList addObject:[NSString stringWithFormat:@"%@", nameField.text]];
	
	int tightlooseSliderVal=100*tightlooseSlider.value;
	if(tightlooseSliderVal>99)
		tightlooseSliderVal=99;
	int passagrSliderVal=100*passagrSlider.value;
	if(passagrSliderVal>99)
		passagrSliderVal=99;
	
	int playerType=(tightlooseSliderVal*100) + passagrSliderVal;
	int player_id=0;
	if(managedObject)
		player_id = [[managedObject valueForKey:@"player_id"] intValue];
	
	[valueList addObject:[NSString stringWithFormat:@"%d", playerType]];
	[valueList addObject:[NSString stringWithFormat:@"%d", (int)overallPlaySeg.selectedSegmentIndex]];
	[valueList addObject:[NSString stringWithFormat:@"%@", strengthsText.text]];
	[valueList addObject:[NSString stringWithFormat:@"%@", weaknessText.text]];
	[valueList addObject:[NSString stringWithFormat:@"%@", casinoButton.titleLabel.text]];
	[valueList addObject:[NSString stringWithFormat:@"%d", user_id]];
	[valueList addObject:[NSString stringWithFormat:@"%d", player_id]];
	[valueList addObject:[NSString stringWithFormat:@"%d", tightlooseSliderVal]];
	[valueList addObject:[NSString stringWithFormat:@"%d", passagrSliderVal]];

	if(managedObject == nil)
		[CoreDataLib insertManagedObjectForEntity:@"EXTRA" valueList:valueList mOC:managedObjectContext];
	else
		[CoreDataLib updateManagedObjectForEntity:managedObject entityName:@"EXTRA" valueList:valueList mOC:managedObjectContext];

	[(PlayerTrackerVC *)callBackViewController reloadData];
	[self.navigationController popViewControllerAnimated:YES];
}


-(void)mainMenuButtonClicked:(id)sender {
	[self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	[self setTitle:@"Player"];
	
	deleteButton.alpha=0;
	

	saveButton = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(savePressed:)];
	self.navigationItem.rightBarButtonItem = saveButton;
	saveButton.enabled=NO;
	
	if(showMenuFlg) {
		UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] initWithTitle:@"Main Menu" style:UIBarButtonItemStylePlain target:self action:@selector(mainMenuButtonClicked:)];
		self.navigationItem.leftBarButtonItem = menuButton;

		UIBarButtonItem *menuButton2 = [[UIBarButtonItem alloc] initWithTitle:@"Main Menu" style:UIBarButtonItemStylePlain target:self action:@selector(mainMenuButtonClicked:)];
		self.navigationItem.rightBarButtonItem = menuButton2;
	}

	[casinoButton setBackgroundImage:[UIImage imageNamed:@"yellowGlossButton.png"] forState:UIControlStateNormal];
	if([casino isEqualToString:@"All Locations"])
		casino = @"Select";
	[casinoButton setTitle:casino forState:UIControlStateNormal];
	
    user_id = [[managedObject valueForKey:@"user_id"] intValue];
    if(user_id==0) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"type = %@", @"PLAYER"];
        NSArray *items = [CoreDataLib selectRowsFromEntity:@"EXTRA" predicate:predicate sortColumn:@"user_id" mOC:managedObjectContext ascendingFlg:NO];
        user_id = 1;
        if([items count]>0) {
            NSManagedObject *mo = [items objectAtIndex:0];
            user_id = [[mo valueForKey:@"user_id"] intValue];
            user_id++;
            [managedObject setValue:[NSNumber numberWithInt:user_id] forKey:@"user_id"];
			[managedObjectContext save:nil];
        }
    }
	
	if(managedObject != nil) {
		int player_id = [[managedObject valueForKey:@"player_id"] intValue];
		if(player_id==0) {
			player_id = [ProjectFunctions generateUniqueId];
			[managedObject setValue:[NSNumber numberWithInt:player_id] forKey:@"player_id"];
			[managedObjectContext save:nil];
		}

        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"type = %@ AND user_id = %d", @"PLAYER", user_id];
        NSArray *items = [CoreDataLib selectRowsFromEntity:@"EXTRA" predicate:predicate sortColumn:nil mOC:managedObjectContext ascendingFlg:YES];
        if([items count]>1) {
			player_id = [ProjectFunctions generateUniqueId];
			[managedObject setValue:[NSNumber numberWithInt:player_id] forKey:@"player_id"];
			[managedObjectContext save:nil];
        }

        playerNumLabel.text = [NSString stringWithFormat:@"user_id: %d, player_id: %d", [[managedObject valueForKey:@"user_id"] intValue], [[managedObject valueForKey:@"player_id"] intValue]];
		
		nameField.text = [managedObject valueForKey:@"name"];
		strengthsText.text = [managedObject valueForKey:@"attrib_03"];
		weaknessText.text = [managedObject valueForKey:@"attrib_04"];
		[casinoButton setTitle:[NSString stringWithFormat:@"%@", [managedObject valueForKey:@"status"]] forState:UIControlStateNormal];
		
		int looseNum = [[managedObject valueForKey:@"looseNum"] intValue];
		int agressiveNum = [[managedObject valueForKey:@"agressiveNum"] intValue];

		passagrSlider.value=(float)agressiveNum/100;
		tightlooseSlider.value=(float)looseNum/100;
		[self changeTypeLabel];
		
		int playerSkill = [[managedObject valueForKey:@"attrib_02"] intValue];
//		NSString *jpgPath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"player%d.jpg", user_id]];
//		NSString *jpgPath = [NSString stringWithFormat:@"player%d.jpg", user_id];
		
		[self setUserPic];
		
		overallPlaySeg.selectedSegmentIndex=playerSkill;
		[saveButton setTitle:@"Edit"];
		saveButton.enabled=YES;
		sEditButton.alpha=0;
		wEditButton.alpha=0;
		casinoButton.enabled=NO;
		nameField.enabled=NO;
		passAgrSeg.enabled=NO;
		looseTightSeg.enabled=NO;
		overallPlaySeg.enabled=NO;
		tightlooseSlider.enabled=NO;
		passagrSlider.enabled=NO;
		readOnlyFlg=YES;
	}
	
	NSArray *skills = [NSArray arrayWithObjects:@"Weak", @"Average", @"Strong", @"Pro", nil];
	skillLabel.text = [skills stringAtIndex:(int)overallPlaySeg.selectedSegmentIndex];
	
}

-(void) setReturningValue:(NSString *) value2 {
	
	NSString *value = [NSString stringWithFormat:@"%@", [ProjectFunctions getUserDefaultValue:@"returnValue"]];
	if(selectedObjectForEdit==1)
		strengthsText.text=value2;
	if(selectedObjectForEdit==2)
		weaknessText.text=value2;
	if(selectedObjectForEdit==3)
		[casinoButton setTitle:[NSString stringWithFormat:@"%@", value] forState:UIControlStateNormal];
	
	saveButton.enabled=YES;
	if([nameField.text length]==0)
		saveButton.enabled=NO;
//	if([casinoButton.titleLabel.text isEqualToString:@"Select"])
//		saveButton.enabled=NO;
	
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
