//
//  ListPicker.m
//  PokerTracker
//
//  Created by Rick Medved on 10/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ListPicker.h"
#import "CoreDataLib.h"
#import "ProjectFunctions.h"
#import "ListPickerCustom.h"
#import "ListPickerCustomDate.h"
#import "NSArray+ATTArray.h"


@implementation ListPicker
@synthesize picker, label, textField, titleLabel, initialDateValue, callBackViewController;
@synthesize selectedList, allowEditing, selectionList, numRecords, numRecordsLabel, selectButton, showNumRecords;
@synthesize managedObjectContext, typeHereLabel, hideNumRecords, addButton, messageView, messageText, mo, countRecords, maxFieldLength;


-(BOOL)textField:(UITextField *)textFieldlocal shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if(maxFieldLength<1)
        maxFieldLength=20;
	return [ProjectFunctions limitTextFieldLength:textFieldlocal currentText:textField.text string:string limit:maxFieldLength saveButton:selectButton resignOnReturn:YES];
}

-(BOOL)textFieldShouldReturn:(UITextField *)aTextField {
	[aTextField resignFirstResponder];
	return YES;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
	return 1;
}


- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
	return [self.selectionList count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
	return [self.selectionList stringAtIndex:(int)row];
	
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
	self.textField.text = [self.selectionList stringAtIndex:(int)row];
	if(managedObjectContext==nil)
		return;
	if(selectedList<=6)
		[self countNumRecords:[self.selectionList stringAtIndex:(int)row]];
	
	if([[self.selectionList stringAtIndex:(int)row] isEqualToString:@"*Custom*"]) {
		if([label.text isEqualToString:@"Timeframe"]) {
			ListPickerCustomDate *detailViewController = [[ListPickerCustomDate alloc] initWithNibName:@"ListPickerCustomDate" bundle:nil];
			detailViewController.managedObjectContext=managedObjectContext;
			detailViewController.callBackViewController = self;
			[self.navigationController pushViewController:detailViewController animated:YES];
		} else {
			ListPickerCustom *detailViewController = [[ListPickerCustom alloc] initWithNibName:@"ListPickerCustom" bundle:nil];
			detailViewController.managedObjectContext=managedObjectContext;
			detailViewController.callBackViewController = self;
			detailViewController.entityname = [NSString stringWithFormat:@"%@", label.text];
			[self.navigationController pushViewController:detailViewController animated:YES];
		}

	}
}

- (IBAction)cancel:(id)sender {
	[self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)save:(id)sender {
	if([textField.text length]>0) {
		[ProjectFunctions setUserDefaultValue:[NSString stringWithFormat:@"%@", textField.text] forKey:@"returnValue"];
		[(ProjectFunctions *)callBackViewController setReturningValue:textField.text];
		[self.navigationController popViewControllerAnimated:YES];
	} else {
		[ProjectFunctions showAlertPopup:@"Error" message:@"No value selected"];
	}

}

-(void)countNumRecords:(NSString *)value
{
	NSMutableArray *filterArray = [[NSMutableArray alloc] init];
	[filterArray addObject:@"LifeTime"];
	[filterArray addObject:@"All Game Types"];
	[filterArray addObject:@"All Games"];
	[filterArray addObject:@"All Limits"];
	[filterArray addObject:@"All Stakes"];
	[filterArray addObject:@"All Locations"];
	[filterArray addObject:@"All Bankrolls"];
	[filterArray addObject:@"All Types"];
	
	[filterArray replaceObjectAtIndex:selectedList withObject:value];
	NSPredicate *predicate = [ProjectFunctions getPredicateForFilter:filterArray mOC:managedObjectContext buttonNum:0];
	NSArray *items = [CoreDataLib selectRowsFromEntity:@"GAME" predicate:predicate sortColumn:@"startTime" mOC:managedObjectContext ascendingFlg:YES];
	self.numRecords.text = [NSString stringWithFormat:@"%d", (int)[items count]];
}

-(void)addButtonClicked:(id)sender
{
	typeHereLabel.alpha=1;
	self.textField.enabled = YES;
	addButton.enabled=NO;
	[textField becomeFirstResponder];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	[self setTitle:@"List Picker"];
    
	
    if(maxFieldLength>0)
        typeHereLabel.text = [NSString stringWithFormat:@"(Maxiumum of %d characters)", maxFieldLength];
    
	messageView.alpha=0;
	if(self.messageText) {
		messageView.text = self.messageText;
		messageView.alpha=1;
	}
	if(!allowEditing)
		addButton.alpha=0;

	typeHereLabel.alpha=0;

	if(selectedList<=7 && showNumRecords)
		[self countNumRecords:[NSString stringWithFormat:@"%@", self.initialDateValue]];
	else {
		self.numRecords.alpha = 0;
		self.numRecordsLabel.alpha = 0;
	}
	
	if(hideNumRecords) {
		self.numRecords.alpha = 0;
		self.numRecordsLabel.alpha = 0;
	}

	UIBarButtonItem *modalButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancel:)];
	self.navigationItem.leftBarButtonItem = modalButton;
	
	self.selectButton = [[UIBarButtonItem alloc] initWithTitle:@"Select" style:UIBarButtonItemStyleBordered target:self action:@selector(save:)];
	self.navigationItem.rightBarButtonItem = selectButton;
	
	
	int i=0;
	for(NSString *value in self.selectionList) {
		if([value isEqualToString:self.initialDateValue])
			[picker selectRow:i inComponent:0 animated:YES];
		i++;
	}

	self.label.text = [NSString stringWithFormat:@"%@", self.titleLabel];
	self.textField.text = [NSString stringWithFormat:@"%@", self.initialDateValue];
	self.textField.enabled = NO;
	
}



-(void) setReturningValue:(NSString *) value2 {
	[(ProjectFunctions *)callBackViewController setReturningValue:value2];
	
	int count = (int)[self.navigationController.viewControllers count];
	if(count>2)
		count-=3;
	[self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:count] animated:YES];
}







@end
