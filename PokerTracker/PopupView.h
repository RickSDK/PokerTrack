//
//  PopupView.h
//  PokerTracker
//
//  Created by Rick Medved on 7/16/17.
//
//

#import <UIKit/UIKit.h>
#import "NSString+FontAwesome.h"
#import "UIFont+FontAwesome.h"
#import "PtpButton.h"

@interface PopupView : UIView

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIView *insideView;
@property (nonatomic, strong) UIButton *xButton;
@property (nonatomic, strong) PtpButton *okButton;
@property (nonatomic, strong) UITextView *textView;

-(void)hideXButton;

@end
