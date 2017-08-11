//
//  PopupView.m
//  PokerTracker
//
//  Created by Rick Medved on 7/16/17.
//
//

#import "PopupView.h"

#define CORNER_RADIUS          7.0

@implementation PopupView

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
	self.layer.cornerRadius = CORNER_RADIUS;
	self.layer.borderColor = [UIColor blackColor].CGColor;
	self.layer.borderWidth = 1;
	self.backgroundColor = [UIColor colorWithRed:0 green:.5 blue:0 alpha:1];
	self.layer.masksToBounds = NO;
	self.layer.shadowOffset = CGSizeMake(15, 15);
	self.layer.shadowRadius = 5;
	self.layer.shadowOpacity = 0.8;

	self.insideView = [[UIView alloc] initWithFrame:CGRectMake(3, 3, self.frame.size.width-6, self.frame.size.height-6)];
	self.insideView.layer.cornerRadius = CORNER_RADIUS;
	self.insideView.layer.masksToBounds = YES;				// clips background images to rounded corners
	self.insideView.layer.borderColor = [UIColor blackColor].CGColor;
	self.insideView.layer.borderWidth = 1;
	self.insideView.backgroundColor = [UIColor grayColor];
	[self addSubview:self.insideView];
	
	self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 5, self.frame.size.width-60, 25)];
	self.titleLabel.font = [UIFont boldSystemFontOfSize:18];	// label is 17, system is 14
	self.titleLabel.textAlignment = NSTextAlignmentCenter;
	self.titleLabel.textColor = [UIColor whiteColor];
	self.titleLabel.text = @"Title";
	[self addSubview:self.titleLabel];

	self.xButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	self.xButton.frame = CGRectMake(self.frame.size.width-29, -2, 30, 30);
	self.xButton.titleLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:18];
	self.xButton.titleLabel.shadowColor = [UIColor blackColor];
	self.xButton.titleLabel.shadowOffset = CGSizeMake(1, 1);
	self.xButton.tintColor=[UIColor whiteColor];
	[self.xButton setTitle:[NSString fontAwesomeIconStringForEnum:FATimes] forState:UIControlStateNormal];
	[self.xButton addTarget:self action:@selector(xButtonClicked) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:self.xButton];
	
	self.textView = [[UITextView alloc] initWithFrame:CGRectMake(5, 35, self.frame.size.width-10, self.frame.size.height-40)];
	self.textView.backgroundColor=[UIColor clearColor];
	self.textView.textColor = [UIColor whiteColor];
	self.textView.editable=NO;
	self.textView.hidden=YES;
	[self addSubview:self.textView];
	if(self.tag==1) { // just background
		[self hideXButton];
	}
	if(self.tag==2) { // include text
		self.textView.hidden=NO;
		[self hideXButton];
	}
	
	[self sendSubviewToBack:self.insideView];
}

-(void)xButtonClicked {
	self.hidden=YES;
}

-(void)hideXButton {
	self.xButton.hidden=YES;
	self.titleLabel.text = @"";
	self.hidden=NO;
}



@end
