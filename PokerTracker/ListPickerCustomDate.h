//
//  ListPickerCustomDate.h
//  PokerTracker
//
//  Created by Rick Medved on 11/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ListPickerCustomDate : UIViewController {
	//---Passed In----------------------------
	NSManagedObjectContext *managedObjectContext;
	UIViewController *callBackViewController;

	//---XIB----------------------------
 	IBOutlet UIDatePicker *picker;
	IBOutlet UITextField *fromLabel;
	IBOutlet UITextField *toLabel;
	IBOutlet UISegmentedControl *toFromSegment;
	
	//---Gloabls----------------------------
}

- (IBAction) segmentPressed: (id) sender;
- (IBAction)dateChanged:(id)sender;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) UIDatePicker *picker;
@property (nonatomic, strong) UITextField *fromLabel;
@property (nonatomic, strong) UITextField *toLabel;
@property (nonatomic, strong) UISegmentedControl *toFromSegment;
@property (nonatomic, strong) UIViewController *callBackViewController;



@end
