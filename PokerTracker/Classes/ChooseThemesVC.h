//
//  ChooseThemesVC.h
//  PokerTracker
//
//  Created by Rick Medved on 8/16/17.
//
//

#import "TemplateVC.h"

@interface ChooseThemesVC : TemplateVC

@property (nonatomic, strong) UIViewController *callBackViewController;
@property (nonatomic, strong) IBOutlet UIButton *topButton;
@property (nonatomic) int group;
@property (nonatomic) int category;
@property (nonatomic) int level;

- (IBAction) topButtonPressed: (UIButton *) button;
- (IBAction) restoreButtonPressed: (UIButton *) button;

@end
