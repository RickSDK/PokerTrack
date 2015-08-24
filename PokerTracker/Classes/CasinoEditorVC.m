//
//  CasinoEditorVC.m
//  PokerTracker
//
//  Created by Rick Medved on 1/21/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "CasinoEditorVC.h"
#import "NSArray+ATTArray.h"
#import "SelectionCell.h"
#import "MapKitTut.h"
#import "ListPicker.h"
#import "TextLineEnterVC.h"
#import "ProjectFunctions.h"
#import "WebServicesFunctions.h"
#import "CasinoGamesEditVC.h"
#import "CasinoCommentVC.h"
#import "MultiLineDetailCellWordWrap.h"
#import "QuadWithImageTableViewCell.h"
#import "CasinoMapVC.h"
#import "LoginVC.h"
#import "ImageCell.h"
#import "NSString+ATTString.h"


@implementation CasinoEditorVC
@synthesize mainTableView, managedObjectContext, activityIndicator, activityPopup, activityLabel;
@synthesize fieldArray, valueArray, repinButton, gpsLabel, currentLocation;
@synthesize nameLabel, streetLabel, cityLabel, phoneLabel, phoneButton, deleteButton;
@synthesize casino, mainPic, editButton, selectedRow, editModeOn, casino_id, gamesButton, commentsButton, gamesArray, commentsArray;
@synthesize casinoFlg, casinoType;

-(void) repinCasino {
	@autoreleasepool {
	
		NSString *casino_idStr = [NSString stringWithFormat:@"%d", casino_id];
		NSString *data = [NSString stringWithFormat:@"%.6f|%.6f", currentLocation.coordinate.latitude, currentLocation.coordinate.longitude];
		NSArray *nameList = [NSArray arrayWithObjects:@"Username", @"Password", @"casino_id", @"data", nil];
		NSArray *valueList = [NSArray arrayWithObjects:[ProjectFunctions getUserDefaultValue:@"userName"], [ProjectFunctions getUserDefaultValue:@"password"], casino_idStr, data, nil];
		if([valueList count]==0) {
			valueList = [NSArray arrayWithObjects:@"test@aol.com", @"test123", casino_idStr, data, nil];
		}
		NSString *webAddr = @"http://www.appdigity.com/poker/pokerCasinoRepin.php";
		NSString *responseStr = [WebServicesFunctions getResponseFromServerUsingPost:webAddr fieldList:nameList valueList:valueList];
		
		if([WebServicesFunctions validateStandardResponse:responseStr delegate:nil]) {
			[ProjectFunctions showAlertPopupWithDelegate:@"Success" message:@"Casino updated!" delegate:self];
			self.selectedRow=111;
		}
		
		activityPopup.alpha=0;
		activityLabel.alpha=0;
		[activityIndicator stopAnimating];
	}
}

-(NSString *)parseCoord:(NSString *)line
{
	NSArray *components = [line componentsSeparatedByString:@":"];
	if([components count]>1)
		return [components objectAtIndex:1];
	return @"";
}

-(NSString *)parseJSON:(NSString *)json value:(NSString *)value
{
	NSArray *lines = [json componentsSeparatedByString:@"\n"];
	for(NSString *line in lines) {
		NSString *newline = [line stringByReplacingOccurrencesOfString:@" " withString:@""];
		newline = [newline stringByReplacingOccurrencesOfString:@"," withString:@""];
		if([newline length]>5) {
			if([[newline substringToIndex:5] isEqualToString:[NSString stringWithFormat:@"\"%@\"", value]])
				return [self parseCoord:newline];
		}
	}
	return @"";
}


-(void) repinCasinoByAddress {
	@autoreleasepool {
	
		NSString *casino_idStr = [NSString stringWithFormat:@"%d", casino_id];

		NSString *address = [NSString stringWithFormat:@"%@+%@+%@+%@", [valueArray stringAtIndex:3], [valueArray stringAtIndex:4], [valueArray stringAtIndex:5], [valueArray stringAtIndex:6]];
		NSString *googleAPI = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/geocode/json?address=%@&sensor=true", address];
		NSString *response = [WebServicesFunctions getResponseFromWeb:googleAPI];
		NSString *lat = [self parseJSON:response value:@"lat"];
		NSString *lng = [self parseJSON:response value:@"lng"];

		NSString *data = [NSString stringWithFormat:@"%@|%@", lat, lng];
		NSArray *nameList = [NSArray arrayWithObjects:@"Username", @"Password", @"casino_id", @"data", nil];
		NSArray *valueList = [NSArray arrayWithObjects:[ProjectFunctions getUserDefaultValue:@"userName"], [ProjectFunctions getUserDefaultValue:@"password"], casino_idStr, data, nil];
		if([valueList count]==0) {
			valueList = [NSArray arrayWithObjects:@"test@aol.com", @"test123", casino_idStr, data, nil];
		}
		NSString *webAddr = @"http://www.appdigity.com/poker/pokerCasinoRepin.php";
		NSString *responseStr = [WebServicesFunctions getResponseFromServerUsingPost:webAddr fieldList:nameList valueList:valueList];
		
		if([WebServicesFunctions validateStandardResponse:responseStr delegate:nil]) {
			[ProjectFunctions showAlertPopupWithDelegate:@"Success" message:@"Casino updated!" delegate:self];
			self.selectedRow=111;
		}
		
		activityPopup.alpha=0;
		activityLabel.alpha=0;
		[activityIndicator stopAnimating];
	}
}

-(void) editCasino {
	@autoreleasepool {
	
		NSString *casino_idStr = [NSString stringWithFormat:@"%d", casino_id];
		NSString *data = [valueArray componentsJoinedByString:@"|"];
		NSArray *nameList = [NSArray arrayWithObjects:@"Username", @"Password", @"casino_id", @"data", nil];
		NSArray *valueList = [NSArray arrayWithObjects:[ProjectFunctions getUserDefaultValue:@"userName"], [ProjectFunctions getUserDefaultValue:@"password"], casino_idStr, data, nil];
		if([valueList count]==0) {
			[ProjectFunctions showAlertPopup:@"Notice" message:@"You must be logged in to use this feature. From the main menu click 'More' at the top, then 'Login'"];
			return;
		}
		NSString *webAddr = @"http://www.appdigity.com/poker/pokerCasinoUpdate.php";
		NSString *responseStr = [WebServicesFunctions getResponseFromServerUsingPost:webAddr fieldList:nameList valueList:valueList];
		
		if([WebServicesFunctions validateStandardResponse:responseStr delegate:nil]) {
			[ProjectFunctions showAlertPopupWithDelegate:@"Success" message:@"Casino updated!" delegate:self];
			self.selectedRow=99;
		}
		
		activityPopup.alpha=0;
		activityLabel.alpha=0;
		[activityIndicator stopAnimating];
	}
}

-(void) deleteCasino {
	@autoreleasepool {
	
		NSString *casino_idStr = [NSString stringWithFormat:@"%d", casino_id];
		NSString *data = [valueArray componentsJoinedByString:@"|"];
		NSArray *nameList = [NSArray arrayWithObjects:@"Username", @"Password", @"casino_id", @"data", nil];
		NSArray *valueList = [NSArray arrayWithObjects:[ProjectFunctions getUserDefaultValue:@"userName"], [ProjectFunctions getUserDefaultValue:@"password"], casino_idStr, data, nil];
		if([valueList count]==0) {
			[ProjectFunctions showAlertPopup:@"Notice" message:@"You must be logged in to use this feature. From the main menu click 'More' at the top, then 'Login'"];
			return;
		}
		NSString *webAddr = @"http://www.appdigity.com/poker/pokerCasinoDelete.php";
		NSString *responseStr = [WebServicesFunctions getResponseFromServerUsingPost:webAddr fieldList:nameList valueList:valueList];
		
		if([WebServicesFunctions validateStandardResponse:responseStr delegate:nil]) {
			[ProjectFunctions showAlertPopupWithDelegate:@"Success" message:@"Casino removed." delegate:self];
			self.selectedRow=99;
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

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if(selectedRow==101 && buttonIndex==1) {
		[self executeThreadedJob:@selector(deleteCasino)];
		return;
	}
	
	if(buttonIndex==1 || selectedRow==99) {
		[self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
	}
	
	if(selectedRow==111)
		[self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
		
	
	if(selectedRow==201 && buttonIndex==1) {
		NSLog(@"Login: %d", selectedRow);
		LoginVC *detailViewController = [[LoginVC alloc] initWithNibName:@"LoginVC" bundle:nil];
		detailViewController.managedObjectContext = managedObjectContext;
		[self.navigationController pushViewController:detailViewController animated:YES];
	}
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if(buttonIndex==0)
		[self executeThreadedJob:@selector(repinCasino)];
	if(buttonIndex==1)
		[self executeThreadedJob:@selector(repinCasinoByAddress)];
}
 
- (IBAction) repinClicked: (id) sender;
{
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"RePin" 
															 delegate:self 
													cancelButtonTitle:@"Cancel" 
											   destructiveButtonTitle:nil 
													otherButtonTitles:@"By Current Location", @"By Address", nil];
	[actionSheet showInView:self.view];
	
	self.selectedRow=102;
	
}

- (IBAction) deleteButtonClicked: (id) sender
{
	self.selectedRow=101;
	[ProjectFunctions showConfirmationPopup:@"Delete Casino?" message:@"Are you sure you want to remove this casino from the database?" delegate:self tag:1];
}

- (IBAction) editButtonClicked: (id) sender
{
	if([ProjectFunctions isLiteVersion]) {
		[ProjectFunctions showAlertPopup:@"Notice" message:@"This feature only available in full version."];
		return;
	}
	
	if(![ProjectFunctions getUserDefaultValue:@"userName"]) {
		LoginVC *detailViewController = [[LoginVC alloc] initWithNibName:@"LoginVC" bundle:nil];
		detailViewController.managedObjectContext = managedObjectContext;
		[self.navigationController pushViewController:detailViewController animated:YES];
		[ProjectFunctions showAlertPopup:@"Notice" message:@"You must be logged in to edit casino information"];
		return;
	}
	if(editModeOn) {
		[editButton setTitle:@"Edit"];
		editButton.enabled=YES;
		editModeOn=NO;
		[mainTableView reloadData];
		deleteButton.alpha=0;
		repinButton.alpha=0;
		commentsButton.enabled=NO;
		gamesButton.enabled=NO;
		[self executeThreadedJob:@selector(editCasino)];
	} else {
		[editButton setTitle:@"Save"];
		editButton.enabled=NO;
		editModeOn=YES;
		[mainTableView reloadData];
		deleteButton.alpha=1;
		repinButton.alpha=1;
		commentsButton.enabled=YES;
		gamesButton.enabled=YES;
	}
}

- (IBAction) mapPressed: (id) sender
{
	NSArray *items = [casino componentsSeparatedByString:@"|"];
		MapKitTut *detailViewController = [[MapKitTut alloc] initWithNibName:@"MapKitTut" bundle:nil];
		detailViewController.lat = [[items stringAtIndex:6] floatValue];
		detailViewController.lng = [[items stringAtIndex:7] floatValue];
		detailViewController.casino=casino;
		[self.navigationController pushViewController:detailViewController animated:YES];
		
}

- (IBAction) gamesPressed: (id) sender
{
	if(![ProjectFunctions getUserDefaultValue:@"userName"]) {
		LoginVC *detailViewController = [[LoginVC alloc] initWithNibName:@"LoginVC" bundle:nil];
		detailViewController.managedObjectContext = managedObjectContext;
		[self.navigationController pushViewController:detailViewController animated:YES];
		[ProjectFunctions showAlertPopup:@"Notice" message:@"You must be logged in to edit casino information"];
		return;
	}
	CasinoGamesEditVC *detailViewController = [[CasinoGamesEditVC alloc] initWithNibName:@"CasinoGamesEditVC" bundle:nil];
	detailViewController.managedObjectContext=managedObjectContext;
	detailViewController.casino=casino;
	detailViewController.casino_id=casino_id;
	[self.navigationController pushViewController:detailViewController animated:YES];
}

- (IBAction) commentsPressed: (id) sender
{
	if(![ProjectFunctions getUserDefaultValue:@"userName"]) {
		LoginVC *detailViewController = [[LoginVC alloc] initWithNibName:@"LoginVC" bundle:nil];
		detailViewController.managedObjectContext = managedObjectContext;
		[self.navigationController pushViewController:detailViewController animated:YES];
		[ProjectFunctions showAlertPopup:@"Notice" message:@"You must be logged in to edit casino information"];
		return;
	}
	CasinoCommentVC *detailViewController = [[CasinoCommentVC alloc] initWithNibName:@"CasinoCommentVC" bundle:nil];
	detailViewController.managedObjectContext=managedObjectContext;
	detailViewController.casino=casino;
	detailViewController.casino_id=casino_id;
	[self.navigationController pushViewController:detailViewController animated:YES];
}

- (IBAction) phonePressed: (id) sender
{
	NSString *value = phoneLabel.text;
	NSString *phoneNumber = [ProjectFunctions formatTelNumberForCalling:value];
	if([phoneNumber length]>6)
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", phoneNumber]]];			
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if([self respondsToSelector:@selector(edgesForExtendedLayout)])
        [self setEdgesForExtendedLayout:UIRectEdgeBottom];
}


+(UIImage *)getCasinoImage:(NSString *)type indianFlg:(NSString *)indianFlg
{
	if([indianFlg isEqualToString:@"Y"])
		return [UIImage imageNamed:@"indian.jpg"];
	if([type isEqualToString:@"Card Room"])
		return [UIImage imageNamed:@"cardroom.jpg"];
	
	return [UIImage imageNamed:@"casino.jpg"];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
    
    [self.mainTableView setBackgroundView:nil];

	editModeOn=NO;
	activityPopup.alpha=0;
	activityLabel.alpha=0;

	fieldArray = [[NSMutableArray alloc] init];
	valueArray = [[NSMutableArray alloc] init];
	
	[fieldArray addObject:@"Name"];
	[fieldArray addObject:@"Type"];
	[fieldArray addObject:@"Tribal Owned"];
	[fieldArray addObject:@"Street"];
	[fieldArray addObject:@"City"];
	[fieldArray addObject:@"State"];
	[fieldArray addObject:@"Zip"];
	[fieldArray addObject:@"Country"];
	[fieldArray addObject:@"Phone"];

	NSMutableArray *items = [NSMutableArray arrayWithArray:[casino componentsSeparatedByString:@"|"]];
	[valueArray addObject:[items stringAtIndex:1]];
	[valueArray addObject:[items stringAtIndex:4]];
	[valueArray addObject:[items stringAtIndex:5]];
	[valueArray addObject:[items stringAtIndex:8]];
	[valueArray addObject:[items stringAtIndex:2]];
	[valueArray addObject:[items stringAtIndex:3]];
	[valueArray addObject:[items stringAtIndex:9]];
	[valueArray addObject:[items stringAtIndex:11]];
	[valueArray addObject:[items stringAtIndex:10]];
	
	gamesArray = [[NSMutableArray alloc] initWithArray:[[items stringAtIndex:15] componentsSeparatedByString:@"<hr>"]];
	if([gamesArray count]>0)
		[gamesArray removeLastObject];
	
	commentsArray = [[NSMutableArray alloc] initWithArray:[[items stringAtIndex:16] componentsSeparatedByString:@"<hr>"]];
	if([commentsArray count]>0)
		[commentsArray removeLastObject];
	
	[self setTitle:[items stringAtIndex:4]];

    self.casinoType = [items stringAtIndex:4];
    self.casinoFlg = [items stringAtIndex:5];
	
	mainPic.image = [CasinoEditorVC getCasinoImage:self.casinoType indianFlg:self.casinoFlg];
	
	casino_id = [[items stringAtIndex:0] intValue];

	
	nameLabel.text = [items stringAtIndex:1];
	streetLabel.text = [items stringAtIndex:8];
	cityLabel.text = [NSString stringWithFormat:@"%@, %@ %@", [items stringAtIndex:2], [items stringAtIndex:3], [items stringAtIndex:9]];
	phoneLabel.text = [items stringAtIndex:10];
	
	if([[items stringAtIndex:10] length]<7)
		phoneButton.enabled=NO;
	
	editButton = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStylePlain target:self action:@selector(editButtonClicked:)];
	self.navigationItem.rightBarButtonItem = editButton;
	
	deleteButton.alpha=0;
	repinButton.alpha=0;
//	gamesButton.enabled=NO;
//	commentsButton.enabled=NO;
	
	if(currentLocation != nil)
		gpsLabel.text = [NSString stringWithFormat:@"Lat: %.6f    Lng: %.6f", currentLocation.coordinate.latitude, currentLocation.coordinate.longitude];
	
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 4;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if(section==0) {
        NSString *phone = [valueArray objectAtIndex:8];

        if([phone length]>4)
            return 3;
        else
            return 2;
    }
    
	if(section==1)
		return [fieldArray count];
	if(section==2)
		return [gamesArray count];
	if(section==3)
		return [commentsArray count];
	
    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	NSArray *titles = [NSArray arrayWithObjects:@"", @"Details", @"Games", @"Comments", nil];
	return [ProjectFunctions getViewForHeaderWithText:[titles stringAtIndex:section]];
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section==0)
        return 0;
    
	return 44.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section==0 && indexPath.row==0)
        return 90;
    else
        return 44;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	NSArray *titles = [NSArray arrayWithObjects:@"Basics", @"Details", @"Games", @"Comments", nil];
    return [titles objectAtIndex:section];
	
	
	return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	NSString *cellIdentifier = [NSString stringWithFormat:@"cellIdentifierSection%dRow%d", indexPath.section, indexPath.row];
    
    if(indexPath.section==0) {
        if(indexPath.row==0) {
            ImageCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (cell == nil) {
                cell = [[ImageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            }
            if([valueArray count]>5) {
                cell.accessoryType = UITableViewCellAccessoryNone;
                cell.nameLabel.text=[valueArray objectAtIndex:0];
                NSString *city = [valueArray objectAtIndex:4];
                NSString *state = [valueArray objectAtIndex:5];
                NSString *country = [valueArray objectAtIndex:7];
                NSString *address = [NSString stringWithFormat:@"%@, %@", city, country];
                if([@"USA" isEqualToString:country])
                    address = [NSString stringWithFormat:@"%@, %@", city, state];
                cell.cityLabel.text=address;
                cell.imageView.image = [CasinoEditorVC getCasinoImage:self.casinoType indianFlg:self.casinoFlg];
            }
            return cell;
        } else {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            }
            cell.textLabel.text=@"test";
            if(indexPath.row==1) {
                cell.textLabel.text=@"Directions";
                cell.accessoryType = UITableViewCellAccessoryNone;
                cell.imageView.image = [UIImage imageNamed:@"globe.png"];
                
            }
            if(indexPath.row==2) {
                cell.accessoryType = UITableViewCellAccessoryNone;
                NSString *phone = [valueArray objectAtIndex:8];
                cell.textLabel.text=@"No Phone";
                if([phone length]>5)
                    cell.textLabel.text= [NSString stringWithFormat:@"Call: %@", [NSString formatAsTelephone:phone]];
                
                cell.imageView.image = [UIImage imageNamed:@"phoneicon.png"];
                
            }
            return cell;
        }
        
    }
    
	if(indexPath.section==1) {
		SelectionCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
		if (cell == nil) {
			cell = [[SelectionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
		}
		
		// Configure the cell...
		cell.textLabel.text = [fieldArray objectAtIndex:indexPath.row];
		cell.selection.text = [valueArray objectAtIndex:indexPath.row];
		
		if(editModeOn) {
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			cell.selectionStyle = UITableViewCellSelectionStyleBlue;
		} else {
			cell.accessoryType = UITableViewCellAccessoryNone;
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
		}
		
		return cell;
	}
	if(indexPath.section==2) {
		QuadWithImageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
		if (cell == nil) {
			cell = [[QuadWithImageTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
		}
		
		NSArray *items = [[gamesArray stringAtIndex:indexPath.row] componentsSeparatedByString:@", "];
		NSString *name = [items stringAtIndex:0];
		cell.aa.text = name;
		if([name length]>4)
			cell.aa.text = [name substringFromIndex:4];
		
		if([name length]>3 && [[name substringToIndex:3] isEqualToString:@"(c)"]) {
			cell.bb.text = @"Cash Game";
			cell.leftImage.image = [UIImage imageNamed:@"cashGame.jpg"];
		} else {
			cell.bb.text = @"Tournament";
			cell.leftImage.image = [UIImage imageNamed:@"tournament.jpg"];
		}
		cell.cc.text = [items stringAtIndex:2];
		cell.dd.text = [items stringAtIndex:1];
		cell.ddColor = [UIColor colorWithRed:0 green:.5 blue:0 alpha:1];
		cell.accessoryType = UITableViewCellAccessoryNone;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		return cell;
	}

	if(indexPath.section==3) {
		MultiLineDetailCellWordWrap *cell = (MultiLineDetailCellWordWrap *) [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
		if (cell == nil) {
			cell = [[MultiLineDetailCellWordWrap alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier withRows:1 labelProportion:0.0];
		}
		
		NSArray *items = [[commentsArray stringAtIndex:indexPath.row] componentsSeparatedByString:@"<xx>"];
		cell.mainTitle = [items stringAtIndex:0];
		cell.titleTextArray = [NSArray arrayWithObject:@""];
		cell.fieldTextArray = [NSArray arrayWithObject:[items stringAtIndex:1]];

		cell.accessoryType = UITableViewCellAccessoryNone;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		return cell;
	}
	return nil;	
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(indexPath.section==0) {
        if(indexPath.row==0)
            return;
        if(indexPath.row==1) {
            NSArray *items = [casino componentsSeparatedByString:@"|"];
            if([items count]>7 && [[items stringAtIndex:6] length]>0) {
                MapKitTut *detailViewController = [[MapKitTut alloc] initWithNibName:@"MapKitTut" bundle:nil];
                detailViewController.lat = [[items stringAtIndex:6] floatValue];
                detailViewController.lng = [[items stringAtIndex:7] floatValue];
                detailViewController.casino=casino;
                [self.navigationController pushViewController:detailViewController animated:YES];
            }
        }
        if(indexPath.row==2) {
            NSString *value = [valueArray objectAtIndex:8];
            if([value length]>6) {
                NSString *phoneNumber = [ProjectFunctions formatTelNumberForCalling:value];
                NSLog(@"phoneNumber: %@", phoneNumber);
                if([phoneNumber length]>6)
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", phoneNumber]]];
            }
        }
    }
    
	if(!editModeOn)
		return;
	
	selectedRow=indexPath.row;
	if(indexPath.section==1) {
		if(selectedRow==1) {
			ListPicker *detailViewController = [[ListPicker alloc] initWithNibName:@"ListPicker" bundle:nil];
			detailViewController.initialDateValue = [valueArray objectAtIndex:indexPath.row];
			detailViewController.titleLabel = [fieldArray objectAtIndex:indexPath.row];
			detailViewController.callBackViewController = self;
			detailViewController.selectionList = [NSArray arrayWithObjects:@"Casino", @"Card Room", nil];
			detailViewController.allowEditing=YES;
			[self.navigationController pushViewController:detailViewController animated:YES];
		} else if(selectedRow==2) {
			ListPicker *detailViewController = [[ListPicker alloc] initWithNibName:@"ListPicker" bundle:nil];
			detailViewController.initialDateValue = [valueArray objectAtIndex:indexPath.row];
			detailViewController.titleLabel = [fieldArray objectAtIndex:indexPath.row];
			detailViewController.callBackViewController = self;
			detailViewController.selectionList = [NSArray arrayWithObjects:@"Y", @"N", nil];
			detailViewController.allowEditing=YES;
			[self.navigationController pushViewController:detailViewController animated:YES];
		} else if(selectedRow==7) {
			ListPicker *detailViewController = [[ListPicker alloc] initWithNibName:@"ListPicker" bundle:nil];
			detailViewController.initialDateValue = [valueArray objectAtIndex:indexPath.row];
			detailViewController.titleLabel = [fieldArray objectAtIndex:indexPath.row];
			detailViewController.callBackViewController = self;
			detailViewController.selectionList = [ProjectFunctions getCountryArray];
			detailViewController.allowEditing=YES;
			[self.navigationController pushViewController:detailViewController animated:YES];
		} else if(selectedRow==5 && ([[valueArray objectAtIndex:7] isEqualToString:@"United States"] || [[valueArray objectAtIndex:7] isEqualToString:@"USA"])) {
			ListPicker *detailViewController = [[ListPicker alloc] initWithNibName:@"ListPicker" bundle:nil];
			detailViewController.initialDateValue = [valueArray objectAtIndex:indexPath.row];
			detailViewController.titleLabel = [fieldArray objectAtIndex:indexPath.row];
			detailViewController.callBackViewController = self;
			detailViewController.selectionList = [ProjectFunctions getStateArray];
			detailViewController.allowEditing=YES;
			[self.navigationController pushViewController:detailViewController animated:YES];
		} else {
			TextLineEnterVC *detailViewController = [[TextLineEnterVC alloc] initWithNibName:@"TextLineEnterVC" bundle:nil];
			detailViewController.initialDateValue = [valueArray objectAtIndex:indexPath.row];
			detailViewController.titleLabel = [fieldArray objectAtIndex:indexPath.row];
			detailViewController.callBackViewController = self;
			[self.navigationController pushViewController:detailViewController animated:YES];
		}
	} 
}

-(void) setReturningValue:(NSString *) value2 {
	commentsButton.enabled=NO;
	gamesButton.enabled=NO;
	NSString *value = [ProjectFunctions getUserDefaultValue:@"returnValue"];
	[valueArray replaceObjectAtIndex:selectedRow withObject:value];
	editButton.enabled=YES;
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
