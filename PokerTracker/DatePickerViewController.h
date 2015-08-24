//
//  DatePickerViewController.h
//  Orders
//
//

#import <UIKit/UIKit.h>


@interface DatePickerViewController : UIViewController {
	//---Passed In----------------------------
	UIViewController *callBackViewController;
	NSDate *initialDateValue;
	BOOL allowClearField;
	BOOL dateOnlyMode;
	NSString *initialValueString;
	NSString *labelString;
	BOOL refusePastDates;

	//---XIB----------------------------
    IBOutlet UIDatePicker *datePicker;
    IBOutlet UITextField *textField;
	IBOutlet UILabel *fieldLabel;
	IBOutlet UINavigationItem *navItem;
	IBOutlet UIBarItem *clearButton;
	
	//---Gloabls----------------------------
	
}

- (IBAction)cancel:(id)sender;
- (IBAction)dateChanged:(id)sender;
- (IBAction)save:(id)sender;
- (IBAction)setDateToToday:(id)sender;
- (IBAction)clearField:(id)sender;

@property (nonatomic, strong) IBOutlet UIDatePicker *datePicker;
@property (nonatomic, strong) IBOutlet NSString *labelString;
@property (nonatomic, strong) IBOutlet UITextField *textField;
@property (nonatomic, strong) IBOutlet UILabel *fieldLabel;
@property (nonatomic, strong) IBOutlet UINavigationItem *navItem;
@property (nonatomic, strong) IBOutlet UIBarItem *clearButton;

@property (nonatomic, strong) NSString *initialValueString;
@property (nonatomic, strong) NSDate *initialDateValue;
@property (nonatomic, strong) UIViewController *callBackViewController;
@property (nonatomic) BOOL refusePastDates;
@property (nonatomic) BOOL allowClearField;
@property (nonatomic) BOOL dateOnlyMode;

@end
