//
//  MinuteEnterVC.h
//  PokerTracker
//
//  Created by Rick Medved on 10/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TemplateVC.h"


@interface MinuteEnterVC : TemplateVC {
	//---Passed In----------------------------
	UIViewController *callBackViewController;
	NSString *initialDateValue;
	NSString *sendTitle;

	//---XIB----------------------------
	IBOutlet UITextField *textField;
	IBOutlet UILabel *titleLabel;
	
	//---Gloabls----------------------------

}

- (IBAction)up1minute:(id)sender;
- (IBAction)down1minute:(id)sender;
- (IBAction)up5minute:(id)sender;
- (IBAction)down5minute:(id)sender;
- (IBAction)up30minute:(id)sender;
- (IBAction)down30minute:(id)sender;

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) NSString *initialDateValue;
@property (nonatomic, strong) NSString *sendTitle;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UIViewController *callBackViewController;


@end
