//
//  OddsCalculatorVC.h
//  PokerTracker
//
//  Created by Rick Medved on 10/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface OddsCalculatorVC : UIViewController {
	//---Passed In----------------------------
	NSManagedObjectContext *managedObjectContext;
	BOOL bigHandsFlag;

	//---XIB----------------------------
	IBOutlet UIButton *button1;
	IBOutlet UIButton *button2;
	IBOutlet UIButton *button3;
	IBOutlet UIButton *button4;
	IBOutlet UIButton *button5;

	//---Gloabls----------------------------
 	
}

- (IBAction) actionButtonPressed: (UIButton *) button;

@property (nonatomic) BOOL bigHandsFlag;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, strong) UIButton *button1;
@property (nonatomic, strong) UIButton *button2;
@property (nonatomic, strong) UIButton *button3;
@property (nonatomic, strong) UIButton *button4;
@property (nonatomic, strong) UIButton *button5;

@end
