//
//  ThemeBGView.m
//  PokerTracker
//
//  Created by Rick Medved on 8/16/17.
//
//

#import "ThemeBGView.h"
#import "ProjectFunctions.h"

@implementation ThemeBGView

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
	self.backgroundColor = [ProjectFunctions themeBGColor];
}


@end
