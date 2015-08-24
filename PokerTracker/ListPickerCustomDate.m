//
//  ListPickerCustomDate.m
//  PokerTracker
//
//  Created by Rick Medved on 11/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ListPickerCustomDate.h"
#import "NSDate+ATTDate.h"
#import "NSString+ATTString.h"
#import "CoreDataLib.h"
#import "ProjectFunctions.h"


@implementation ListPickerCustomDate
@synthesize picker, fromLabel, toLabel, toFromSegment, callBackViewController;
@synthesize managedObjectContext;


- (IBAction) segmentPressed: (id) sender
{
	if(self.toFromSegment.selectedSegmentIndex==0)
		self.picker.date = [self.fromLabel.text convertStringToDateWithFormat:@"date"];
	else 
		self.picker.date = [self.toLabel.text convertStringToDateWithFormat:@"date"];
}

- (IBAction)dateChanged:(id)sender {
	if(self.toFromSegment.selectedSegmentIndex==0)
		self.fromLabel.text = [self.picker.date convertDateToStringWithFormat:@"date"];
	else 
		self.toLabel.text = [self.picker.date convertDateToStringWithFormat:@"date"];
}

- (IBAction)cancel:(id)sender {
	[self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)save:(id)sender {
	NSDate *startDate = [self.fromLabel.text convertStringToDateWithFormat:@"date"];
	NSDate *endDate = [[NSString stringWithFormat:@"%@ 12:59:59 PM", self.toLabel.text] convertStringToDateWithFormat:nil];

	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"type = %@ AND searchNum = 0", @"Timeframe"];
	[CoreDataLib insertOrUpdateManagedObjectForEntity:@"SEARCH" valueList:[NSArray arrayWithObjects:@"Timeframe", @"", [startDate convertDateToStringWithFormat:nil], [endDate convertDateToStringWithFormat:nil], @"", @"0", nil] mOC:self.managedObjectContext predicate:predicate];

	[ProjectFunctions setUserDefaultValue:@"*Custom*" forKey:@"returnValue"];
	[(ProjectFunctions *)self.callBackViewController setReturningValue:nil];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	[self setTitle:@"Date Range"];
	
	NSDate *today = [NSDate date];
	NSDate *lastMonth = [today dateByAddingTimeInterval:-1*60*60*24*30];
	self.fromLabel.text = [lastMonth convertDateToStringWithFormat:@"date"];
	self.toLabel.text = [today convertDateToStringWithFormat:@"date"];
	self.picker.date = lastMonth;
	
	
	UIBarButtonItem *modalButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancel:)];
	self.navigationItem.leftBarButtonItem = modalButton;
	
	UIBarButtonItem *selectButton = [[UIBarButtonItem alloc] initWithTitle:@"Select" style:UIBarButtonItemStyleBordered target:self action:@selector(save:)];
	self.navigationItem.rightBarButtonItem = selectButton;
	
}







@end
