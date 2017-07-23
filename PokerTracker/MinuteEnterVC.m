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
@synthesize textField, titleLabel, initialDateValue, callBackViewController, sendTitle;

- (void)viewDidLoad {
	[super viewDidLoad];
	[self setTitle:NSLocalizedString(self.sendTitle, nil)];
	
	self.textField.text = [NSString stringWithFormat:@"%@", self.initialDateValue];
	self.titleLabel.text = @"";
	
	self.navigationItem.leftBarButtonItem = [ProjectFunctions UIBarButtonItemWithIcon:[NSString fontAwesomeIconStringForEnum:FATimes] target:self action:@selector(cancel:)];
	
	self.navigationItem.rightBarButtonItem = [ProjectFunctions UIBarButtonItemWithIcon:[NSString fontAwesomeIconStringForEnum:FACheck] target:self action:@selector(save:)];
	
}

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

@end
