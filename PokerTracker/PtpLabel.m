//
//  PtpLabel.m
//  PokerTracker
//
//  Created by Rick Medved on 8/13/17.
//
//

#import "PtpLabel.h"
#import "ProjectFunctions.h"

@implementation PtpLabel

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
	self.textColor = [ProjectFunctions primaryButtonColor];
}


@end
