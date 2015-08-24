//
//  TextLineEnterVC.m
//  PokerTracker
//
//  Created by Rick Medved on 1/20/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "TextLineEnterVC.h"
#import "ProjectFunctions.h"


@implementation TextLineEnterVC
@synthesize titleLabel, initialDateValue, textField, callBackViewController, topLabel;

-(BOOL)textFieldShouldReturn:(UITextField *)aTextField {
	[aTextField resignFirstResponder];
	return YES;
}

- (IBAction)save:(id)sender {
	[ProjectFunctions setUserDefaultValue:textField.text forKey:@"returnValue"];
	[(ProjectFunctions *)callBackViewController setReturningValue:textField.text];
	[self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)cancel:(id)sender {
	[self.navigationController popViewControllerAnimated:YES];
}


-(BOOL)textField:(UITextField *)textFieldlocal shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
	int textlength=30;
	return [ProjectFunctions limitTextFieldLength:textFieldlocal currentText:textField.text string:string limit:textlength saveButton:nil resignOnReturn:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	[self setTitle:@"Enter Text"];
	
	self.textField.text = [NSString stringWithFormat:@"%@", self.initialDateValue];
	topLabel.text = [ NSString stringWithFormat:@"%@", self.titleLabel];
	
	UIBarButtonItem *modalButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancel:)];
	self.navigationItem.leftBarButtonItem = modalButton;
	
	UIBarButtonItem *updateButton = [[UIBarButtonItem alloc] initWithTitle:@"Update" style:UIBarButtonItemStyleBordered target:self action:@selector(save:)];
	self.navigationItem.rightBarButtonItem = updateButton;
	
}








@end
