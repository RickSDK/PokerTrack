//
//  MoneyPickerVC.m
//  PokerTracker
//
//  Created by Rick Medved on 10/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MoneyPickerVC.h"
#import "ProjectFunctions.h"
#import "OddsFormVC.h"


@implementation MoneyPickerVC
@synthesize picker, label, textField, titleLabel, callBackViewController, initialDateValue, numberOfWheels;
@synthesize clearButton, currencySymbol, buttonClicked;
@synthesize managedObjectContext;

-(void)spinPicker
{
    if([textField.text intValue] != [textField.text floatValue])
        return;
    
	[picker reloadAllComponents];

	NSString *padded = [NSString stringWithFormat:@"%03d", [textField.text intValue]];
	if(numberOfWheels>padded.length)
		numberOfWheels=(int)padded.length;
	
	for(int i=0; i<padded.length; i++)
		[picker selectRow:[[padded substringWithRange:NSMakeRange(i,1)] intValue] inComponent:i animated:YES];
	
	[picker reloadAllComponents];
}

-(void)clearValue {
	self.textField.text = @"0";
	self.numberOfWheels=3;
	[self spinPicker];
    
}

- (IBAction) clearPressed: (id) sender 
{
    [self clearValue];
}

- (IBAction) numPlus1Pressed: (id) sender {
	int amount = [textField.text intValue];
	amount ++;
	self.textField.text = [NSString stringWithFormat:@"%d", amount];;
	[self spinPicker];
}

- (IBAction) num100Pressed: (id) sender {
	int amount = [textField.text intValue];
	amount += 100;
	self.textField.text = [NSString stringWithFormat:@"%d", amount];;
	[self spinPicker];
    
}

- (IBAction) num20Pressed: (id) sender {
	int amount = [textField.text intValue];
    if(!self.buttonClicked) {
        self.buttonClicked=YES;
        self.textField.text = @".";
        return;
    }
	self.textField.text = [NSString stringWithFormat:@"%d.", amount];
    self.buttonClicked=YES;
}

-(void)addMoney:(int)value
{
    if(!self.buttonClicked) {
        self.buttonClicked=YES;
        self.textField.text = [NSString stringWithFormat:@"%d", value];
        [self spinPicker];
        return;
    }
	
	self.textField.text = [NSString stringWithFormat:@"%@%d", self.textField.text, value];
	NSLog(@"Here!!", self.textField.text);

	[self spinPicker];
}

- (IBAction) num1Pressed: (id) sender {
    [self addMoney:1];
}
- (IBAction) num2Pressed: (id) sender {
    [self addMoney:2];
}
- (IBAction) num3Pressed: (id) sender {
    [self addMoney:3];
}
- (IBAction) num4Pressed: (id) sender {
    [self addMoney:4];
}
- (IBAction) num5Pressed: (id) sender {
    [self addMoney:5];
}
- (IBAction) num6Pressed: (id) sender {
    [self addMoney:6];
}
- (IBAction) num7Pressed: (id) sender {
    [self addMoney:7];
}
- (IBAction) num8Pressed: (id) sender {
    [self addMoney:8];
}
- (IBAction) num9Pressed: (id) sender {
    [self addMoney:9];
}
- (IBAction) num0Pressed: (id) sender {
    [self addMoney:0];
}



- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
	self.numberOfWheels = (int)[textField.text length];
	if(numberOfWheels<3)
		self.numberOfWheels=3;
	return numberOfWheels;
}


- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
	return 10;	
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
	return [NSString stringWithFormat:@"%d", (int)row];
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
	NSMutableString *value = [NSMutableString stringWithCapacity:100];
	for(int i=0; i<numberOfWheels; i++)
		[value appendFormat:@"%d", (int)[pickerView selectedRowInComponent:i]];

	self.textField.text = [NSString stringWithFormat:@"%d", [value intValue]]; // needed to remove leading zeros
}

- (IBAction)cancel:(id)sender {
	[self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)save:(id)sender {
	[ProjectFunctions setUserDefaultValue:[NSString stringWithFormat:@"%@", textField.text] forKey:@"returnValue"];
	[(ProjectFunctions *)callBackViewController setReturningValue:textField.text];
	[self.navigationController popViewControllerAnimated:YES];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {

    [super viewDidLoad];
    
    NSString *title = self.titleLabel;
    if([title length]==0)
        title = @"Money";
	[self setTitle:title];
    
	self.numberOfWheels=3;
	
	UIBarButtonItem *modalButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancel:)];
	self.navigationItem.leftBarButtonItem = modalButton;

	UIBarButtonItem *selectButton = [[UIBarButtonItem alloc] initWithTitle:@"Select" style:UIBarButtonItemStyleBordered target:self action:@selector(save:)];
	self.navigationItem.rightBarButtonItem = selectButton;
	
	self.label.text = [NSString stringWithFormat:@"%@", self.titleLabel];

	self.textField.text = [NSString stringWithFormat:@"%d", (int)[ProjectFunctions convertMoneyStringToDouble:self.initialDateValue]];
	
	currencySymbol.text = [ProjectFunctions getMoneySymbol2];
	
	textField.keyboardType = UIKeyboardTypeDecimalPad;

	[self spinPicker];
}








@end
