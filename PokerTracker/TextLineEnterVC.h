//
//  TextLineEnterVC.h
//  PokerTracker
//
//  Created by Rick Medved on 1/20/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TemplateVC.h"


@interface TextLineEnterVC : TemplateVC {
	UIViewController *callBackViewController;
	NSString *initialDateValue;
	NSString *titleLabel;
	
	//---XIB----------------------------
	IBOutlet UITextField *textField;
	IBOutlet UILabel *topLabel;
	
	//---Gloabls----------------------------
	
}

@property (nonatomic, strong) NSString *titleLabel;
@property (nonatomic, strong) NSString *initialDateValue;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UIViewController *callBackViewController;
@property (nonatomic, strong) UILabel *topLabel;

@end
