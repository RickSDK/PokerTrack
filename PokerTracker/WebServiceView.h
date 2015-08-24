//
//  WebServiceView.h
//  PokerTracker
//
//  Created by Rick Medved on 6/26/15.
//
//

#import <UIKit/UIKit.h>
#import "CustomButton.h"

@interface WebServiceView : UIView

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *messageLabel;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) CustomButton *cancelButton;

-(void)showCancelButton;
-(void)startWithTitle:(NSString *)title;
-(void)stop;

@end
