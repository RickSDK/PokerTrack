//
//  ListPicker.h
//  PokerTracker
//
//  Created by Rick Medved on 10/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ListPicker : UIViewController {
	//---Passed In----------------------------
	UIViewController *callBackViewController;
    NSManagedObjectContext *managedObjectContext;
    NSManagedObject *mo;
	NSArray *selectionList;
	NSString *initialDateValue;
	NSString *titleLabel;
	int selectedList;
	int maxFieldLength;
	BOOL allowEditing;
	BOOL hideNumRecords;
	BOOL showNumRecords;
	BOOL countRecords;
	NSString *messageText;

	//---XIB----------------------------
	IBOutlet UIPickerView *picker;
	IBOutlet UILabel *label;
	IBOutlet UITextField *numRecords;
	IBOutlet UITextField *textField;
	IBOutlet UILabel *numRecordsLabel;
	IBOutlet UILabel *typeHereLabel;
	IBOutlet UIButton *addButton;
	IBOutlet UITextView *messageView;

	//---Gloabls----------------------------
	UIBarButtonItem *selectButton;

}

-(void)countNumRecords:(NSString *)value;
-(void)addButtonClicked:(id)sender;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong)  NSManagedObject *mo;

@property (nonatomic, strong) UITextView *messageView;
@property (nonatomic, strong) UIBarButtonItem *selectButton;
@property (nonatomic, strong) UIPickerView *picker;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UITextField *numRecords;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UILabel *numRecordsLabel;
@property (nonatomic, strong) UILabel *typeHereLabel;
@property (nonatomic, strong) UIButton *addButton;

@property (nonatomic, strong) UIViewController *callBackViewController;
@property (nonatomic) int selectedList;
@property (nonatomic) int maxFieldLength;
@property (nonatomic) BOOL allowEditing;
@property (nonatomic) BOOL hideNumRecords;
@property (nonatomic) BOOL showNumRecords;
@property (nonatomic) BOOL countRecords;

@property (nonatomic, copy) NSArray *selectionList;
@property (nonatomic, copy) NSString *messageText;
@property (nonatomic, copy) NSString *titleLabel;
@property (nonatomic, copy) NSString *initialDateValue;

@end
