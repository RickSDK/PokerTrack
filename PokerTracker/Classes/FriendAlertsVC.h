//
//  FriendAlertsVC.h
//  PokerTracker
//
//  Created by Rick Medved on 11/16/13.
//
//

#import <UIKit/UIKit.h>

@interface FriendAlertsVC : UIViewController {
    IBOutlet UIButton *saveButton;
    IBOutlet UITextField *phoneField;
    IBOutlet UISwitch *startSwitch;
    IBOutlet UISwitch *updateSwitch;
    IBOutlet UISegmentedControl *carrierSegment;
    IBOutlet UIActivityIndicatorView *activityIndicator;
}

- (IBAction) savePressed: (id) sender;
- (IBAction) startPressed: (id) sender;
- (IBAction) updatePressed: (id) sender;

@property (nonatomic, strong) UIButton *saveButton;
@property (nonatomic, strong) UITextField *phoneField;
@property (nonatomic, strong) UISwitch *startSwitch;
@property (nonatomic, strong) UISwitch *updateSwitch;
@property (nonatomic, strong) UISegmentedControl *carrierSegment;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;


@end
