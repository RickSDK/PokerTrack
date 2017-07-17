//
//  TextEnterVC.h
//  PokerTracker
//
//  Created by Rick Medved on 10/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TemplateVC.h"


@interface TextEnterVC : TemplateVC {
	//---Passed In----------------------------
	UIViewController *callBackViewController;
	NSString *initialDateValue;
	NSString *titleLabel;
	NSManagedObjectContext *managedObjectContext;
	int strlen;

	//---XIB----------------------------
	IBOutlet UITextView *textView;
	IBOutlet UILabel *topLabel;
	IBOutlet UILabel *charMaxLabel;

	//---Gloabls----------------------------

}

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSString *titleLabel;
@property (nonatomic, strong) NSString *initialDateValue;
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) UIViewController *callBackViewController;
@property (nonatomic, strong) UILabel *topLabel;
@property (nonatomic, strong) UILabel *charMaxLabel;
@property (nonatomic) int strlen;

@end
