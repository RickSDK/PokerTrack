//
//  DatePickerViewController.m
//  Orders
//
//

#import "DatePickerViewController.h"
#import "NSDate+ATTDate.h"
#import "NSString+ATTString.h"
#import "ProjectFunctions.h"
#import "OddsFormVC.h"

// Date Format: MM/dd/yyyy


@implementation DatePickerViewController

@synthesize datePicker, textField, fieldLabel, navItem, clearButton;
@synthesize initialDateValue, callBackViewController, initialValueString, refusePastDates, allowClearField;
@synthesize dateOnlyMode, labelString;


-(BOOL)textFieldShouldReturn:(UITextField *)aTextField {
	[aTextField resignFirstResponder];
	datePicker.date = [self.textField.text convertStringToDateWithFormat:nil];
	[self dateChanged:self];
	return YES;
}

// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
	}
    return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	[self setTitle:NSLocalizedString(self.labelString, nil)];
	
	if(dateOnlyMode)
		self.datePicker.datePickerMode = UIDatePickerModeDate;
	
	self.fieldLabel.text = self.labelString;
	
	// Adjust the text field size and font.
	CGRect frame = textField.frame;
	frame.size.height += 4;
	self.textField.frame = frame;
	self.textField.font = [UIFont boldSystemFontOfSize:16];
	self.textField.text = self.initialValueString;
	self.clearButton.enabled = allowClearField;

	self.navigationItem.rightBarButtonItem = navItem.rightBarButtonItem;
	self.navigationItem.leftBarButtonItem = navItem.leftBarButtonItem;
	
	self.navigationItem.leftBarButtonItem = [ProjectFunctions UIBarButtonItemWithIcon:[NSString fontAwesomeIconStringForEnum:FATimes] target:self action:@selector(cancel:)];
	
	self.navigationItem.rightBarButtonItem = [ProjectFunctions UIBarButtonItemWithIcon:[NSString fontAwesomeIconStringForEnum:FACheck] target:self action:@selector(save:)];


	NSString *dateFormat = nil;
	if(dateOnlyMode)
		dateFormat = @"yyyy-MM-dd";
	
	self.textField.enabled = YES;
	self.datePicker.date = (initialDateValue == nil ? [NSDate date] : initialDateValue);
	if([self.initialValueString isEqualToString:@"-select-"])
		self.datePicker.date = [NSDate date];
	else
		self.datePicker.date = [self.initialValueString convertStringToDateWithFormat:dateFormat];

	[self dateChanged:self];
}

-(void)setTextFieldValue:(NSString *)value
{
	self.textField.text = [NSString stringWithFormat:@"%@", value];
}

- (IBAction)clearField:(id)sender {
	self.datePicker.date = [NSDate date];
	[self setTextFieldValue:@""];
}
	
- (IBAction)cancel:(id)sender {
	[self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)dateChanged:(id)sender {
	NSString *dateFormat = nil;
	if(dateOnlyMode)
		dateFormat = @"yyyy-MM-dd";
	[self setTextFieldValue:[datePicker.date convertDateToStringWithFormat:dateFormat]];
	self.localDateLabel.text = [ProjectFunctions displayLocalFormatDate:datePicker.date showDay:YES showTime:YES];
}

- (IBAction)setDateToToday:(id)sender {
	self.datePicker.date = [NSDate date];
	[self dateChanged:self];
}

- (IBAction)save:(id)sender {
	// User clicks Done
	[ProjectFunctions setUserDefaultValue:[NSString stringWithFormat:@"%@", textField.text] forKey:@"returnValue"];

	if([textField.text isEqualToString:@""])
		[(OddsFormVC *)callBackViewController setReturningValue:@""];
	
	else if(refusePastDates && [[NSDate date] compareDatesIgnoringTime:datePicker.date] == NSOrderedDescending) {
		[ProjectFunctions showAlertPopup:@"Error" message:@"Date cannot be in the past"];
		return;
	}
	else {
		[(OddsFormVC *)callBackViewController setReturningValue:textField.text];
	}
	[self.navigationController popViewControllerAnimated:YES];

}



@end
