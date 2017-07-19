//
//  GameSegmentView.m
//  PokerTracker
//
//  Created by Rick Medved on 7/19/17.
//
//

#import "GameSegmentView.h"

@implementation GameSegmentView

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
	self.backgroundColor = [UIColor colorWithRed:0 green:.5 blue:0 alpha:1];
}

@end
