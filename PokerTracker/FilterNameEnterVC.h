//
//  FilterNameEnterVC.h
//  PokerTracker
//
//  Created by Rick Medved on 10/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface FilterNameEnterVC : UIViewController {
	//---Passed In----------------------------
	NSManagedObjectContext *managedObjectContext;
    NSManagedObject *filerObj;
	UIViewController *callBackViewController;

	//---XIB----------------------------
	IBOutlet UITextField *filterName;
	IBOutlet UISegmentedControl *customButtonSegment;
	IBOutlet UIButton *deleteButton;

	//---Gloabls----------------------------
	UIBarButtonItem *saveButton;
}

- (IBAction) deleteButtonPressed: (id) sender;
- (IBAction) segChanged: (id) sender;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSManagedObject *filerObj;

@property (nonatomic, strong) UITextField *filterName;
@property (nonatomic, strong) UIViewController *callBackViewController;
@property (nonatomic, strong) UISegmentedControl *customButtonSegment;
@property (nonatomic, strong) UIBarButtonItem *saveButton;
@property (nonatomic, strong) UIButton *deleteButton;

@end
