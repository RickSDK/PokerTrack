//
//  MinuteEnterVC.m
//  PokerTracker
//
//  Created by Rick Medved on 10/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MinuteEnterVC.h"
#import "ProjectFunctions.h"


@implementation MinuteEnterVC
@synthesize textField, titleLabel, initialDateValue, callBackViewController, sendTitle, managedObjectContext;

- (IBAction)save:(id)sender {
	[ProjectFunctions setUserDefaultValue:textField.text forKey:@"returnValue"];
	[(ProjectFunctions *)callBackViewController setReturningValue:textField.text];
	[self.navigationController popViewControllerAnimated:YES];
}

-(void)changeValue:(int)amount
{
	self.textField.text = [NSString stringWithFormat:@"%d", [textField.text intValue]+amount];
}

- (IBAction)up1minute:(id)sender
{
	[self changeValue:1];
}

- (IBAction)down1minute:(id)sender
{
	[self changeValue:-1];
}

- (IBAction)up5minute:(id)sender
{
	[self changeValue:5];
}

- (IBAction)down5minute:(id)sender
{
	[self changeValue:-5];
}

- (IBAction)up30minute:(id)sender
{
	[self changeValue:30];
}

- (IBAction)down30minute:(id)sender
{
	[self changeValue:-30];
}

- (IBAction)cancel:(id)sender {
	[self.navigationController popViewControllerAnimated:YES];
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
	[self setTitle:@"Number Picker"];

	self.textField.text = [NSString stringWithFormat:@"%@", self.initialDateValue];
	self.titleLabel.text = [NSString stringWithFormat:@"%@", self.sendTitle];
	
	UIBarButtonItem *modalButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancel:)];
	self.navigationItem.leftBarButtonItem = modalButton;
	
	UIBarButtonItem *updateButton = [[UIBarButtonItem alloc] initWithTitle:@"Update" style:UIBarButtonItemStyleBordered target:self action:@selector(save:)];
	self.navigationItem.rightBarButtonItem = updateButton;
}




@end
