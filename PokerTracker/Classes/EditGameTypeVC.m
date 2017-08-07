//
//  EditGameTypeVC.m
//  PokerTracker
//
//  Created by Rick Medved on 8/6/17.
//
//

#import "EditGameTypeVC.h"

@interface EditGameTypeVC ()

@end

@implementation EditGameTypeVC

- (void)viewDidLoad {
    [super viewDidLoad];
	[self setTitle:@"Game Type"];
	self.navigationItem.leftBarButtonItem = [ProjectFunctions UIBarButtonItemWithIcon:[NSString fontAwesomeIconStringForEnum:FATimes] target:self action:@selector(backButtonClicked)];
	
	self.selectButton = [ProjectFunctions UIBarButtonItemWithIcon:[NSString fontAwesomeIconStringForEnum:FACheck] target:self action:@selector(selectValue)];
	self.navigationItem.rightBarButtonItem = self.selectButton;
	if([self.initialDateValue isEqualToString:@"Tournament"])
		self.ptpGameSegment.selectedSegmentIndex=1;
	[self enableSegmentsTo:NO];
	
	[ProjectFunctions initializeSegmentBar:self.blindTypeSegmentBar defaultValue:[ProjectFunctions getUserDefaultValue:@"blindDefault"] field:@"stakes"];
	[ProjectFunctions initializeSegmentBar:self.tourneyTypeSegmentBar defaultValue:[ProjectFunctions getUserDefaultValue:@"tourneyTypeDefault"] field:@"tournamentType"];
	
}

- (void)selectValue {
	NSArray *types = [NSArray arrayWithObjects:@"Cash", @"Tournament", nil];
	NSString *tournyValue = [self.tourneyTypeSegmentBar titleForSegmentAtIndex:self.tourneyTypeSegmentBar.selectedSegmentIndex];
	NSString *blindsValue = [self.blindTypeSegmentBar titleForSegmentAtIndex:self.blindTypeSegmentBar.selectedSegmentIndex];
	NSString *altValue = (self.ptpGameSegment.selectedSegmentIndex==1)?tournyValue:blindsValue;
	
	[(ProjectFunctions *)self.callBackViewController setReturningValue:[NSString stringWithFormat:@"%@|%@", [types objectAtIndex:self.ptpGameSegment.selectedSegmentIndex], altValue]];
	[self.navigationController popViewControllerAnimated:YES];
}

- (IBAction) ptpGameSegmentChanged:(id)sender {
	[self enableSegmentsTo:YES];
}

-(void)enableSegmentsTo:(BOOL)enabled {
	[self.ptpGameSegment gameSegmentChanged];
	self.selectButton.enabled=enabled;
	self.blindTypeSegmentBar.hidden=self.ptpGameSegment.selectedSegmentIndex==1;
	self.tourneyTypeSegmentBar.hidden=self.ptpGameSegment.selectedSegmentIndex==0;
	self.blindTypeSegmentBar.enabled=enabled;
	self.tourneyTypeSegmentBar.enabled=enabled;
}

@end
