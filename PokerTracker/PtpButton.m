//
//  PtpButton.m
//  PokerTracker
//
//  Created by Rick Medved on 8/11/17.
//
//

#import "PtpButton.h"
#import "ProjectFunctions.h"

@implementation PtpButton

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
	[self assignMode:(int)self.tag];
	[self setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
}

-(void)assignMode:(int)mode {
	// 0 = yellow
	// 1 = green
	// 2 = light-gray
	// 3 = red
	// 4 = gray (disabled)
	self.mode=mode;
	[ProjectFunctions newButtonLook:self mode:mode];
}

-(void)setEnabled:(BOOL)enabled {
	[super setEnabled:enabled];
	if(enabled) {
		[ProjectFunctions newButtonLook:self mode:self.mode];
		self.alpha=1;
	} else {
		[ProjectFunctions newButtonLook:self mode:4];
		[self setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
		self.alpha=.8;
	}
}


@end
