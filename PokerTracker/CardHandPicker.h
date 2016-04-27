//
//  CardHandPicker.h
//  PokerTracker
//
//  Created by Rick Medved on 10/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TemplateVC.h"


@interface CardHandPicker : TemplateVC {
	//---Passed In----------------------------
	NSManagedObjectContext *managedObjectContext;
	UIViewController *callBackViewController;
	NSString *titleLabel;
	NSString *initialDateValue;
	NSString *burnedcards;
	int numberCards;

	//---XIB----------------------------
	IBOutlet UILabel *label;
	IBOutlet UILabel *conflictLabel;
	IBOutlet UITextField *textField;
	IBOutlet UIButton *randomButton;
	IBOutlet UIBarButtonItem *selectButton;
	
	IBOutlet UISegmentedControl *card1Segment;
	IBOutlet UISegmentedControl *suit1Segment;
	IBOutlet UISegmentedControl *card2Segment;
	IBOutlet UISegmentedControl *suit2Segment;
	IBOutlet UISegmentedControl *card3Segment;
	IBOutlet UISegmentedControl *suit3Segment;
	
	IBOutlet UIImageView *card1BG;
	IBOutlet UIImageView *card2BG;
	IBOutlet UIImageView *card3BG;
	IBOutlet UIImageView *suit1Image;
	IBOutlet UIImageView *suit2Image;
	IBOutlet UIImageView *suit3Image;
	IBOutlet UILabel *card1Label;
	IBOutlet UILabel *card2Label;
	IBOutlet UILabel *card3Label;
	
	//---Gloabls----------------------------
	
	
}

- (IBAction) segmentPressed: (id) sender;
- (IBAction)randomButtonPressed:(id)sender;
- (IBAction)unknownButtonPressed:(id)sender;
-(void)setUpSegments:(NSString *)textValue;

+(void)displayCardGraphic:(UIImageView *)suitImage cardlabel:(UILabel *)cardlabel card:(NSString *)card suit:(NSString *)suit;


@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UILabel *conflictLabel;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UIButton *randomButton;
@property (nonatomic, strong) UIViewController *callBackViewController;
@property (nonatomic, copy) NSString *titleLabel;
@property (nonatomic, copy) NSString *initialDateValue;
@property (nonatomic, copy) NSString *burnedcards;
@property (nonatomic) int numberCards;

@property (nonatomic, strong) UIBarButtonItem *selectButton;

@property (nonatomic, strong) UISegmentedControl *card1Segment;
@property (nonatomic, strong) UISegmentedControl *suit1Segment;
@property (nonatomic, strong) UISegmentedControl *card2Segment;
@property (nonatomic, strong) UISegmentedControl *suit2Segment;
@property (nonatomic, strong) UISegmentedControl *card3Segment;
@property (nonatomic, strong) UISegmentedControl *suit3Segment;

@property (nonatomic, strong) UIImageView *card1BG;
@property (nonatomic, strong) UIImageView *card2BG;
@property (nonatomic, strong) UIImageView *card3BG;
@property (nonatomic, strong) UIImageView *suit1Image;
@property (nonatomic, strong) UIImageView *suit2Image;
@property (nonatomic, strong) UIImageView *suit3Image;
@property (nonatomic, strong) UILabel *card1Label;
@property (nonatomic, strong) UILabel *card2Label;
@property (nonatomic, strong) UILabel *card3Label;


@end
