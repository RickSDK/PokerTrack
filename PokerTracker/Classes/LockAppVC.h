//
//  LockAppVC.h
//  PokerTracker
//
//  Created by Rick Medved on 1/9/13.
//
//

#import <UIKit/UIKit.h>

@interface LockAppVC : UIViewController {

    IBOutlet UILabel *messageLabel;
    IBOutlet UITextField *passField;
    IBOutlet UITextField *hintField;
	IBOutlet UIButton *cancelButton;
	IBOutlet UIButton *goButton;
}

- (IBAction) cancelPressed: (id) sender;
- (IBAction) setPressed: (id) sender;


@property (nonatomic, strong)  UILabel *messageLabel;
@property (nonatomic, strong)  UITextField *passField;
@property (nonatomic, strong)  UITextField *hintField;
@property (nonatomic, strong)  UIButton *cancelButton;
@property (nonatomic, strong)  UIButton *goButton;


@end
