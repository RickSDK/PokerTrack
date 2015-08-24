//
//  ListPickerCustom.h
//  PokerTracker
//
//  Created by Rick Medved on 11/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ListPickerCustom : UIViewController {
	//---Passed In----------------------------
	NSManagedObjectContext *managedObjectContext;
	UIViewController *callBackViewController;
	NSString *entityname;

	//---XIB----------------------------
	//---Gloabls----------------------------
	NSMutableArray *itemList;
	NSMutableArray *checkList;

}

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, strong) NSMutableArray *itemList;
@property (nonatomic, strong) NSMutableArray *checkList;
@property (nonatomic, strong) NSString *entityname;
@property (nonatomic, strong) UIViewController *callBackViewController;


@end
