//
//  FilterNameEnterVC.m
//  PokerTracker
//
//  Created by Rick Medved on 10/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FilterNameEnterVC.h"
#import "ProjectFunctions.h"
#import "CoreDataLib.h"
#import "FilterListVC.h"


@implementation FilterNameEnterVC
@synthesize managedObjectContext;
@synthesize filterName, callBackViewController, customButtonSegment;
@synthesize saveButton, filerObj, deleteButton, filterNameString;

- (IBAction)save:(id)sender {
	
	int button = (int)customButtonSegment.selectedSegmentIndex+1;
	[self clearExistingFiltersForButton:button];
    if(filerObj) {
        [self.filerObj setValue:filterName.text forKey:@"name"];
		[self.filerObj setValue:[NSNumber numberWithInt:button] forKey:@"button"];
        [self.managedObjectContext save:nil];
 //       [(FilterListVC *)callBackViewController reloadView];
    } 
        [ProjectFunctions setUserDefaultValue:[NSString stringWithFormat:@"%@|%d", filterName.text, (int)customButtonSegment.selectedSegmentIndex] forKey:@"returnValue"];
        [(ProjectFunctions *)callBackViewController setReturningValue:@"test"];
 //   }
    
	[self.navigationController popViewControllerAnimated:YES];
}

-(void)clearExistingFiltersForButton:(int)button
{
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"button = %d", button];
	NSArray *filters = [CoreDataLib selectRowsFromEntity:@"FILTER" predicate:predicate sortColumn:@"button" mOC:self.managedObjectContext ascendingFlg:YES];
	for(NSManagedObject *mo in filters) {
        [mo setValue:[NSNumber numberWithInt:99] forKey:@"button"];
	}
	
}



- (IBAction)cancel:(id)sender {
	[self.navigationController popViewControllerAnimated:YES];
}

-(BOOL)textFieldShouldReturn:(UITextField *)aTextField {
	[aTextField resignFirstResponder];
	return YES;
}

-(BOOL)textField:(UITextField *)textFieldlocal shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
	return [ProjectFunctions limitTextFieldLength:textFieldlocal currentText:filterName.text string:string limit:10 saveButton:saveButton resignOnReturn:YES];
}



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[self setTitle:@"Filter Name"];
    [super viewDidLoad];

	
	UIBarButtonItem *modalButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancel:)];
	self.navigationItem.leftBarButtonItem = modalButton;
	
	
	saveButton =  [ProjectFunctions navigationButtonWithTitle:@"Save" selector:@selector(save:) target:self];
	self.navigationItem.rightBarButtonItem = saveButton;


	self.customButtonSegment.selectedSegmentIndex=0;
	
	NSArray *filters = [CoreDataLib selectRowsFromEntity:@"FILTER" predicate:nil sortColumn:@"button" mOC:self.managedObjectContext ascendingFlg:YES];
	int i=0;
	for(NSManagedObject *mo in filters) {
		NSString *name = [mo valueForKey:@"name"];
		if(i<3)
			[customButtonSegment setTitle:name forSegmentAtIndex:i];
		i++;
	}
    
	if(i==2)
		self.customButtonSegment.selectedSegmentIndex=2;
	else 
		self.customButtonSegment.selectedSegmentIndex=3;

    deleteButton.alpha=0;
    
    if(filerObj) {
        filterName.text = [filerObj valueForKey:@"name"];
        self.customButtonSegment.selectedSegmentIndex=[[filerObj valueForKey:@"button"] intValue]-1;
        deleteButton.alpha=1;
    }
	
	self.saveButton.enabled = NO;
	
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex==1) {
        [self.managedObjectContext deleteObject:filerObj];
        [self.managedObjectContext save:nil];
        
        [(FilterListVC *)callBackViewController reloadView];

        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (IBAction) deleteButtonPressed: (id) sender {
    [ProjectFunctions showConfirmationPopup:@"delete?" message:@"" delegate:self tag:1];
}

- (IBAction) segChanged: (id) sender {
	[self.customButtonSegment changeSegment];
    [saveButton setEnabled:YES];
    
}




@end
