//
//  MyToolbar.m
//  PokerTracker
//
//  Created by Rick Medved on 2/23/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "MyToolbar.h"


@implementation MyToolbar

-(void)drawRect:(CGRect)rect {
	UIImage *backgroundImage = [UIImage imageNamed:@"greenGradWide.png"];
	[backgroundImage drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
}

@end
