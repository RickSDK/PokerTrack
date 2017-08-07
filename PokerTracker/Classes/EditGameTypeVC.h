//
//  EditGameTypeVC.h
//  PokerTracker
//
//  Created by Rick Medved on 8/6/17.
//
//

#import "TemplateVC.h"

@interface EditGameTypeVC : TemplateVC

@property (atomic, strong) UIBarButtonItem *selectButton;
@property (nonatomic, strong) UIViewController *callBackViewController;
@property (nonatomic, strong) IBOutlet CustomSegment *blindTypeSegmentBar;
@property (nonatomic, strong) IBOutlet CustomSegment *tourneyTypeSegmentBar;
@property (atomic, strong) NSString *initialDateValue;

@end
