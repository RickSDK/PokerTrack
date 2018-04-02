//
//  CreateOldGameVC.h
//  PokerTracker
//
//  Created by Rick Medved on 10/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TemplateVC.h"


@interface CreateOldGameVC : TemplateVC {
}

- (IBAction) gameTypeSegmentPressed: (id) sender;
-(void)setSegmentForType;
- (IBAction) gameSegmentPressed: (id) sender;
- (IBAction) stakesSegmentPressed: (id) sender; 
- (IBAction) limitSegmentPressed: (id) sender;
- (IBAction) actioButtonPressed: (id) sender;


@property (nonatomic, strong) IBOutlet CustomSegment *gameTypeSegmentBar;
@property (nonatomic, strong) IBOutlet UISegmentedControl *gameNameSegmentBar;
@property (nonatomic, strong) IBOutlet UISegmentedControl *blindTypeSegmentBar;
@property (nonatomic, strong) IBOutlet UISegmentedControl *limitTypeSegmentBar;
@property (nonatomic, strong) IBOutlet UISegmentedControl *TourneyTypeSegmentBar;
@property (nonatomic, strong) IBOutlet UIButton *button1;
@property (nonatomic, strong) IBOutlet UIButton *button2;
@property (nonatomic, strong) IBOutlet UIButton *button3;
@property (nonatomic, strong) IBOutlet UIButton *button4;
@property (nonatomic, strong) IBOutlet UIButton *button5;
@property (nonatomic, strong) IBOutlet UIButton *button6;
@property (nonatomic, strong) IBOutlet UIButton *button7;
@property (nonatomic, strong) IBOutlet UIButton *button8;
@property (nonatomic, strong) NSArray *buttons;



@property (nonatomic) int selectedObjectForEdit;

@end
