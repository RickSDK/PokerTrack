//
//  BankrollView.h
//  PokerTracker
//
//  Created by Rick Medved on 8/12/17.
//
//

#import <UIKit/UIKit.h>
#import "PtpButton.h"
#import "CustomSegment.h"

@interface BankrollView : UIView

@property (nonatomic, strong) PtpButton *editButton;
@property (nonatomic, strong) PtpButton *xButton;
@property (nonatomic, strong) PtpButton *allBankrollsButton;
@property (nonatomic, strong) CustomSegment *bankRollSegment;
@property (nonatomic) SEL selector;
@property (nonatomic) id target;
@property (nonatomic) SEL segmentSelector;

-(void)addTargetSelector:(SEL)selector target:(id)target;
-(void)addSegmentTargetSelector:(SEL)selector target:(id)target;
-(void)applyTheme;
-(void)xButtonPressed;

@end
