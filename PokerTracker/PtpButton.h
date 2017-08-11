//
//  PtpButton.h
//  PokerTracker
//
//  Created by Rick Medved on 8/11/17.
//
//

#import <UIKit/UIKit.h>

@interface PtpButton : UIButton

@property (nonatomic) int mode;

-(void)assignMode:(int)mode;

@end
