//
//  PieChartVC.h
//  PokerTracker
//
//  Created by Rick Medved on 7/21/17.
//
//

#import "TemplateVC.h"

@interface PieChartVC : TemplateVC

@property (atomic, strong) IBOutlet CustomSegment *filterSegment;
@property (atomic, strong) IBOutlet CustomSegment *typeSegment;
@property (atomic, strong) IBOutlet UIImageView *graphImageView;
@property (nonatomic) CGPoint startTouchPosition;

- (IBAction) typeSegmentChanged: (id) sender;
- (IBAction) filterSegmentChanged: (id) sender;

@end
