//
//  Scrub2017VC.h
//  PokerTracker
//
//  Created by Rick Medved on 7/25/17.
//
//

#import "TemplateVC.h"

@interface Scrub2017VC : TemplateVC

@property (nonatomic, strong) IBOutlet UILabel *amountLabel;
@property (nonatomic, strong) IBOutlet UIButton *scrubButton;
@property (nonatomic, strong) IBOutlet UIButton *cancelButton;

-(IBAction)scrubButtonClicked:(id)sender;
-(IBAction)cancelButtonClicked:(id)sender;

@end
