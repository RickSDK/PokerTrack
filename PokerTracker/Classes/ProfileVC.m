//
//  ProfileVC.m
//  PokerTracker
//
//  Created by Rick Medved on 6/6/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "ProfileVC.h"
#import "SelectionCell.h"
#import "ListPicker.h"
#import "ProjectFunctions.h"
#import "WebServicesFunctions.h"

@implementation ProfileVC
@synthesize managedObjectContext, activityIndicator, activityPopup, activityLabel, mainTableView;
@synthesize saveEditButton, viewEditable, changesMade;
@synthesize nameField, emailField, cityField, selectedRow, statsSwitch, passwordField;


-(BOOL)textField:(UITextField *)textFieldlocal shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
	changesMade=YES;
	saveEditButton.enabled=YES;
	return [ProjectFunctions limitTextFieldLength:textFieldlocal currentText:textFieldlocal.text string:string limit:50 saveButton:saveEditButton resignOnReturn:YES];
}

-(void)resignkeyboards
{
	[nameField resignFirstResponder];
	[emailField resignFirstResponder];
	[cityField resignFirstResponder];
	[passwordField resignFirstResponder];
	saveEditButton.enabled=YES;
	changesMade=YES;
}
-(BOOL)textFieldShouldReturn:(UITextField *)aTextField {
	[self resignkeyboards];
	return YES;
}

-(void)backgroundProcess
{
	@autoreleasepool {
	
	
		NSArray *nameList = [NSArray arrayWithObjects:@"Username", @"Password", @"data", nil];
		NSString *userStatsFlg = (statsSwitch.on)?@"Y":@"N";
		NSArray *items = [NSArray arrayWithObjects:nameField.text, emailField.text, cityField.text, [ProjectFunctions getUserDefaultValue:@"UserState"], [ProjectFunctions getUserDefaultValue:@"UserCountry"], userStatsFlg , passwordField.text, nil];
		NSString *data = [items componentsJoinedByString:@"|"];
		
		NSArray *valueList = [NSArray arrayWithObjects:[ProjectFunctions getUserDefaultValue:@"userName"], [ProjectFunctions getUserDefaultValue:@"password"], data, nil];
		NSString *webAddr = @"http://www.appdigity.com/poker/pokerProfileUpdate.php";
		NSString *responseStr = [WebServicesFunctions getResponseFromServerUsingPost:webAddr fieldList:nameList valueList:valueList];
    
		if([WebServicesFunctions validateStandardResponse:responseStr delegate:nil]) {
			[ProjectFunctions setUserDefaultValue:cityField.text forKey:@"userCity"];
			[ProjectFunctions setUserDefaultValue:userStatsFlg forKey:@"userStatsFlg"];
			[ProjectFunctions setUserDefaultValue:passwordField.text forKey:@"password"];
			[ProjectFunctions showAlertPopup:@"Success!" message:@"User profile updated"];
		}
		
		activityLabel.alpha=0;
		activityPopup.alpha=0;
		[activityIndicator stopAnimating];
	
	}
}


- (void) saveButtonClicked:(id)sender {
	[self resignkeyboards];
	if(!viewEditable) {
		[saveEditButton setTitle:@"Save"];
		self.viewEditable = YES;
		self.saveEditButton.enabled=NO;
		self.changesMade=NO;
		nameField.enabled=YES;
		emailField.enabled=YES;
		cityField.enabled=YES;
		statsSwitch.enabled=YES;
        passwordField.enabled=YES;
		[mainTableView reloadData];
		return;
	}
	if([nameField.text length]==0) {
		[ProjectFunctions showAlertPopup:@"Error" message:@"First name field cannot be blank"];
		return;
	}
	if([emailField.text length]==0) {
		[ProjectFunctions showAlertPopup:@"Error" message:@"Email field cannot be blank"];
		return;
	}
	if([cityField.text length]==0) {
		[ProjectFunctions showAlertPopup:@"Error" message:@"City field cannot be blank"];
		return;
	}
	self.saveEditButton.enabled=NO;
	self.changesMade=NO;
	[activityIndicator startAnimating];
	[self disableFields];
	activityPopup.alpha=1;
	activityLabel.alpha=1;
	[mainTableView reloadData];
	[self performSelectorInBackground:@selector(backgroundProcess) withObject:nil];

}

- (IBAction) switchPressed: (id) sender
{
	self.saveEditButton.enabled=YES;
	self.changesMade=YES;
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if(buttonIndex==1)
		[self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
}
		

-(void)mainMenuButtonClicked:(id)sender {
//	MainMenuVC *detailViewController = [[MainMenuVC alloc] initWithNibName:@"MainMenuVC" bundle:nil];
//	detailViewController.managedObjectContext=managedObjectContext;
//	[self.navigationController pushViewController:detailViewController animated:YES];
//	[detailViewController release];
	if(changesMade)
		[ProjectFunctions showConfirmationPopup:@"Warning" message:@"Changes have not been saved. Are you sure you want to exit?" delegate:self tag:1];
	else
		[self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
}

-(void)disableFields
{
	nameField.enabled=NO;
	emailField.enabled=NO;
	cityField.enabled=NO;
	passwordField.enabled=NO;
	statsSwitch.enabled=NO;
	self.viewEditable=NO;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if([self respondsToSelector:@selector(edgesForExtendedLayout)])
        [self setEdgesForExtendedLayout:UIRectEdgeBottom];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	[self setTitle:@"Profile"];
	
	if(	[[ProjectFunctions getUserDefaultValue:@"userCity"] length]==0) {
		self.viewEditable=YES;
		self.changesMade=YES;
	} else {
		[self disableFields];
	}

	
	self.navigationItem.leftBarButtonItem = [ProjectFunctions UIBarButtonItemWithIcon:[NSString fontAwesomeIconStringForEnum:FAHome] target:self action:@selector(mainMenuButtonClicked:)];
//	UIBarButtonItem *mainMenuButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Main Menu", nil) style:UIBarButtonItemStylePlain target:self action:@selector(mainMenuButtonClicked:)];
//	self.navigationItem.leftBarButtonItem = mainMenuButton;
	
	NSString *buttonName = (viewEditable)?@"Save":@"Edit";
	saveEditButton = [ProjectFunctions navigationButtonWithTitle:buttonName selector:@selector(saveButtonClicked:) target:self];

	self.navigationItem.rightBarButtonItem = saveEditButton;
	
	
	if(	[[ProjectFunctions getUserDefaultValue:@"UserState"] length]==0)
		[ProjectFunctions setUserDefaultValue:@"WA" forKey:@"UserState"];
	if(	[[ProjectFunctions getUserDefaultValue:@"UserCountry"] length]==0)
		[ProjectFunctions setUserDefaultValue:@"USA" forKey:@"UserCountry"];

	nameField.text = [ProjectFunctions getUserDefaultValue:@"firstName"];
	emailField.text = [ProjectFunctions getUserDefaultValue:@"emailAddress"];
	cityField.text = [ProjectFunctions getUserDefaultValue:@"userCity"];
    passwordField.text = [ProjectFunctions getUserDefaultValue:@"password"];
	
	if([[ProjectFunctions getUserDefaultValue:@"userStatsFlg"] isEqualToString:@"N"])
		statsSwitch.on=NO;
	
	activityPopup.alpha=0;
	activityLabel.alpha=0;
	
	

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	NSString *cellIdentifier = [NSString stringWithFormat:@"cellIdentifierSection%dRow%d", (int)indexPath.section, (int)indexPath.row];
    
	SelectionCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (cell == nil) {
		cell = [[SelectionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
	}
	
	// Configure the cell...
	
	
	if(indexPath.row==0) {
		cell.textLabel.text = @"State";
		cell.selection.text = [ProjectFunctions getUserDefaultValue:@"UserState"];
	} else {
		cell.textLabel.text = @"Country";
		cell.selection.text = [ProjectFunctions getUserDefaultValue:@"UserCountry"];
	}

	if(viewEditable) {
		cell.selectionStyle = UITableViewCellSelectionStyleBlue;
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	} else {
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		cell.accessoryType = UITableViewCellAccessoryNone;
	}

	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if(!viewEditable)
		return;
	
	self.selectedRow=(int)indexPath.row;
    NSString *initalState = [ProjectFunctions getUserDefaultValue:@"UserState"];
    if([initalState length]==0)
        initalState = @"Select";
    
    NSString *initalCountry = [ProjectFunctions getUserDefaultValue:@"UserCountry"];
    if([initalCountry length]==0)
        initalCountry = @"USA";
	if(indexPath.row==0) {
		ListPicker *detailViewController = [[ListPicker alloc] initWithNibName:@"ListPicker" bundle:nil];
		detailViewController.initialDateValue = initalState;
		detailViewController.titleLabel = @"State";
		detailViewController.callBackViewController = self;
		detailViewController.selectionList = [ProjectFunctions getStateArray];
		if([[ProjectFunctions getUserDefaultValue:@"UserCountry"] isEqualToString:@"USA"])
			detailViewController.allowEditing=NO;
		else 
			detailViewController.allowEditing=YES;
		detailViewController.hideNumRecords=YES;
		[self.navigationController pushViewController:detailViewController animated:YES];
	} else {
		ListPicker *detailViewController = [[ListPicker alloc] initWithNibName:@"ListPicker" bundle:nil];
		detailViewController.initialDateValue = initalCountry;
		detailViewController.titleLabel = @"Country";
		detailViewController.callBackViewController = self;
		detailViewController.selectionList = [ProjectFunctions getCountryArray];
		detailViewController.allowEditing=NO;
		detailViewController.hideNumRecords=YES;
		[self.navigationController pushViewController:detailViewController animated:YES];
	} 
}

-(void) setReturningValue:(NSString *) value {
	saveEditButton.enabled=YES;
	changesMade=YES;
	if(selectedRow==0) 
		[ProjectFunctions setUserDefaultValue:value forKey:@"UserState"];
	else 
		[ProjectFunctions setUserDefaultValue:value forKey:@"UserCountry"];
	
	[mainTableView reloadData];
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
