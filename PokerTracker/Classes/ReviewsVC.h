//
//  ReviewsVC.h
//  PokerTracker
//
//  Created by Rick Medved on 6/15/16.
//
//

#import "TemplateVC.h"

@interface ReviewsVC : TemplateVC

@property (nonatomic, strong) IBOutlet UILabel *yourVersionLabel;
@property (nonatomic, strong) IBOutlet UILabel *currentVersionLabel;
@property (nonatomic, strong) IBOutlet UILabel *numReviewsLabel;
@property (nonatomic, strong) IBOutlet UILabel *updateNeededLabel;
@property (nonatomic, strong) IBOutlet UIStepper *stepper;

@property (nonatomic, strong) UIBarButtonItem *updateButton;

@property (nonatomic) int numReviews;
@property (nonatomic) float currentVersion;

-(IBAction)reviewButtonClicked:(id)sender;
-(IBAction)stepperButtonClicked:(id)sender;

@end
