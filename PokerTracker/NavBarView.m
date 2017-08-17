//
//  NavBarView.m
//  PokerTracker
//
//  Created by Rick Medved on 8/16/17.
//
//

#import "NavBarView.h"
#import "ProjectFunctions.h"

@implementation NavBarView

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
	self.backgroundColor = [ProjectFunctions segmentThemeColor];
}

@end
