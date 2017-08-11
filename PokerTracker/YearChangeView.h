//
//  YearChangeView.h
//  PokerTracker
//
//  Created by Rick Medved on 7/22/17.
//
//

#import <UIKit/UIKit.h>
#import "PtpButton.h"

@interface YearChangeView : UIView

@property (nonatomic, strong) PtpButton *yearDownButton;
@property (nonatomic, strong) PtpButton *yearUpButton;
@property (nonatomic, strong) UILabel *yearLabel;
@property (nonatomic) SEL selector;
@property (nonatomic) id target;
@property (nonatomic, strong) NSInvocation *invocation;

@property (nonatomic) int minYear;
@property (nonatomic) int nowYear;
@property (nonatomic) int statYear;

-(void)setYear:(int)year min:(int)min;
-(void)yearGoesUp;
-(void)yearGoesDown;
-(void)addTargetSelector:(SEL)selector target:(id)target;
-(void)applyTheme;

@end
