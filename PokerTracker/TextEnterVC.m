//
//  TextEnterVC.m
//  PokerTracker
//
//  Created by Rick Medved on 10/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TextEnterVC.h"
#import "ProjectFunctions.h"


@implementation TextEnterVC
@synthesize titleLabel, initialDateValue, textView, callBackViewController, topLabel, strlen, charMaxLabel, managedObjectContext;


- (IBAction)save:(id)sender {
	[ProjectFunctions setUserDefaultValue:textView.text forKey:@"returnValue"];
	[(ProjectFunctions *)callBackViewController setReturningValue:textView.text];
	[self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)cancel:(id)sender {
	[self.navigationController popViewControllerAnimated:YES];
}


- (BOOL)textView:(UITextView *)textViewLocal shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)string
{
	return [ProjectFunctions limitTextViewLength:textViewLocal currentText:textView.text string:string limit:strlen saveButton:nil resignOnReturn:NO];
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	[self setTitle:@"Enter Text"];
	
	if(strlen==0)
		strlen=500;
	
	charMaxLabel.text = [NSString stringWithFormat:@"%d char max", strlen];

	self.textView.text = [NSString stringWithFormat:@"%@", self.initialDateValue];
	topLabel.text = [ NSString stringWithFormat:@"%@", self.titleLabel];
	
	self.navigationItem.leftBarButtonItem = [ProjectFunctions UIBarButtonItemWithIcon:[NSString fontAwesomeIconStringForEnum:FATimes] target:self action:@selector(cancel:)];
	
	self.navigationItem.rightBarButtonItem = [ProjectFunctions UIBarButtonItemWithIcon:[NSString fontAwesomeIconStringForEnum:FACheck] target:self action:@selector(save:)];
}








@end
