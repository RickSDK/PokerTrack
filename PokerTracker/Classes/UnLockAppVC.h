//
//  UnLockAppVC.h
//  PokerTracker
//
//  Created by Rick Medved on 1/9/13.
//
//

#import <UIKit/UIKit.h>

@interface UnLockAppVC : UIViewController {
    
    IBOutlet UILabel *hintLabel;
    IBOutlet UITextField *passField;
	IBOutlet UIButton *hintButton;
    IBOutlet UIImageView *bgImage;;
}

- (IBAction) hintPressed: (id) sender;
- (IBAction) but1Pressed: (id) sender;
- (IBAction) but2Pressed: (id) sender;
- (IBAction) but3Pressed: (id) sender;
- (IBAction) but4Pressed: (id) sender;
- (IBAction) but5Pressed: (id) sender;
- (IBAction) but6Pressed: (id) sender;
- (IBAction) but7Pressed: (id) sender;
- (IBAction) but8Pressed: (id) sender;
- (IBAction) but9Pressed: (id) sender;
- (IBAction) but0Pressed: (id) sender;
- (IBAction) clearPressed: (id) sender;


@property (nonatomic, strong)  UILabel *hintLabel;
@property (nonatomic, strong)  UITextField *passField;
@property (nonatomic, strong)  UIButton *hintButton;
@property (nonatomic, strong)  UIImageView *bgImage;

@end
