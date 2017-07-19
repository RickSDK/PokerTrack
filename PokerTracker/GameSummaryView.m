//
//  GameSummaryView.m
//  PokerTracker
//
//  Created by Rick Medved on 7/19/17.
//
//

#import "GameSummaryView.h"
#import "ProjectFunctions.h"

@implementation GameSummaryView

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
		[self commonInit];
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self) {
		[self commonInit];
	}
	return self;
}

- (void)commonInit
{
	self.backgroundColor = [UIColor blackColor];
	
	self.skillButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	self.skillButton.frame = CGRectMake(0, 0, 44, 55);
	[self.skillButton setTitle:@"" forState:UIControlStateNormal];
	[self.skillButton setBackgroundImage:[ProjectFunctions getPlayerTypeImage:0 winnings:0] forState:UIControlStateNormal];	[self addSubview:self.skillButton];

	self.gameSummaryLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 5, 190, 25)];
	self.gameSummaryLabel.font = [UIFont boldSystemFontOfSize:16];	// label is 17, system is 14
	self.gameSummaryLabel.textAlignment = NSTextAlignmentLeft;
	self.gameSummaryLabel.minimumScaleFactor=.5;
	self.gameSummaryLabel.adjustsFontSizeToFitWidth = YES;
	self.gameSummaryLabel.textColor = [UIColor whiteColor];
	self.gameSummaryLabel.backgroundColor = [UIColor clearColor];
	self.gameSummaryLabel.text = @"Games";
	[self addSubview:self.gameSummaryLabel];
	
	UILabel *roiNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 25, 200, 25)];
	roiNameLabel.font = [UIFont systemFontOfSize:14];	// label is 17, system is 14
	roiNameLabel.textAlignment = NSTextAlignmentLeft;
	roiNameLabel.textColor = [UIColor whiteColor];
	roiNameLabel.text = @"Return on Investment (ROI)";
	[self addSubview:roiNameLabel];

	self.profitLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width-85, 5, 80, 25)];
	self.profitLabel.font = [UIFont boldSystemFontOfSize:17];	// label is 17, system is 14
	self.profitLabel.textAlignment = NSTextAlignmentRight;
	self.profitLabel.minimumScaleFactor=.5;
	self.profitLabel.adjustsFontSizeToFitWidth = YES;
	self.profitLabel.textColor = [UIColor greenColor];
	self.profitLabel.text = @"$0";
	[self addSubview:self.profitLabel];
	
	self.roiLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width-65, 25, 60, 25)];
	self.roiLabel.font = [UIFont boldSystemFontOfSize:14];	// label is 17, system is 14
	self.roiLabel.textAlignment = NSTextAlignmentRight;
	self.roiLabel.textColor = [UIColor greenColor];
	self.roiLabel.text = @"-";
	[self addSubview:self.roiLabel];
}

-(void)addTarget:(SEL)selector target:(id)target {
	[self.skillButton addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
}

-(void)populateViewWithObj:(GameStatObj *)obj {
	self.gameSummaryLabel.text=obj.name;
	self.profitLabel.text = [ProjectFunctions convertNumberToMoneyString:obj.profit];
	if(obj.risked>0) {
		int roi = obj.profit*100/obj.risked;
		self.roiLabel.text = [NSString stringWithFormat:@"%d%%", roi];
	}
	[self.skillButton setBackgroundImage:[ProjectFunctions getPlayerTypeImage:obj.risked winnings:obj.profit] forState:UIControlStateNormal];
	
	if(obj.profit==0) {
		self.profitLabel.textColor=[UIColor whiteColor];
		self.roiLabel.textColor=[UIColor whiteColor];
	} else {
		self.profitLabel.textColor=(obj.profit>0)?[UIColor greenColor]:[UIColor orangeColor];
		self.roiLabel.textColor=(obj.profit>0)?[UIColor greenColor]:[UIColor orangeColor];
	}
}

@end
