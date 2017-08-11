//
//  EditThemeVC.h
//  PokerTracker
//
//  Created by Rick Medved on 8/8/17.
//
//

#import "TemplateVC.h"

@interface EditThemeVC : TemplateVC

@property (nonatomic, strong) IBOutlet UIButton *testButton1;
@property (nonatomic, strong) IBOutlet UIButton *testButton2;
@property (nonatomic, strong) IBOutlet UIButton *testButton3;
@property (nonatomic, strong) IBOutlet UIButton *testButton4;

@property (nonatomic, strong) IBOutlet UIButton *bgUpButton;
@property (nonatomic, strong) IBOutlet UIButton *bgDownButton;
@property (nonatomic, strong) IBOutlet UIButton *colorsUpButton;
@property (nonatomic, strong) IBOutlet UIButton *colorsDownButton;
@property (nonatomic, strong) IBOutlet UIButton *segmentUpButton;
@property (nonatomic, strong) IBOutlet UIButton *segmentDownButton;

@property (nonatomic, strong) UIImageView *selectedButtonImageView;
@property (nonatomic, strong) UIImageView *selectedSegmentImageView;
@property (nonatomic, strong) UIImageView *selectedbgImageView;

@property (nonatomic, strong) IBOutlet UISwitch *imageBGSwitch;
@property (nonatomic, strong) IBOutlet CustomSegment *imageBGSegment;


@property (atomic) int bgNumber;
@property (atomic) int colorNumber;
@property (atomic) int segmentColorNumber;

@property (atomic) float width1;
@property (atomic) float width2;
@property (atomic) float width3;

@property (atomic) float yVal1;
@property (atomic) float yVal2;
@property (atomic) float yVal3;

- (IBAction) bgButtonPressed: (UIButton *) button;
- (IBAction) colorsButtonPressed: (UIButton *) button;
- (IBAction) segmentColorButtonPressed: (UIButton *) button;
- (IBAction) imageBGSwitchPressed: (UISwitch *) uiSwitch;
- (IBAction) imageBGSegmentPressed: (UISegmentedControl *) segment;

@end
