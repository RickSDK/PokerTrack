//
//  WebServiceView.m
//  PokerTracker
//
//  Created by Rick Medved on 6/26/15.
//
//

#import "WebServiceView.h"

#define kWidth	240
#define kHeight	128

@implementation WebServiceView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

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
	CGRect frame = CGRectMake([[UIScreen mainScreen] bounds].size.width/2-kWidth/2, [[UIScreen mainScreen] bounds].size.height/2-kHeight, kWidth, kHeight);
	self.frame = frame;
	self.backgroundColor = [UIColor clearColor];
	
	UIImageView *bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"activityPopup.png"]];
	bgImageView.frame = CGRectMake(0, 0, kWidth, kHeight);
	[self addSubview:bgImageView];
	
	self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, kWidth, 30)];
	self.titleLabel.font = [UIFont boldSystemFontOfSize:18];	// label is 17, system is 14
	self.titleLabel.textAlignment = NSTextAlignmentCenter;
	self.titleLabel.textColor = [UIColor whiteColor];
	self.titleLabel.text = @"";
	[self addSubview:self.titleLabel];
	
	self.messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 40, kWidth, 30)];
	self.messageLabel.font = [UIFont boldSystemFontOfSize:14];	// label is 17, system is 14
	self.messageLabel.textAlignment = NSTextAlignmentCenter;
	self.messageLabel.textColor = [UIColor yellowColor];
	self.messageLabel.text = @"";
	[self addSubview:self.messageLabel];
	
	self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	self.activityIndicator.frame = CGRectMake(240/2-20, kHeight/2-20, 40, 40);
	[self addSubview:self.activityIndicator];
	
	self.cancelButton = [CustomButton buttonWithType:UIButtonTypeRoundedRect];
	self.cancelButton.frame = CGRectMake(240/2-50, kHeight/2+20, 100, 30);
	[self.cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
	[self.cancelButton addTarget:self action:@selector(cancelButtonClicked) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:self.cancelButton];
	
	self.cancelButton.hidden=YES;
	self.hidden=YES;
}

-(void)showCancelButton {
	self.cancelButton.hidden=NO;
}

-(void)startWithTitle:(NSString *)title {
	self.titleLabel.text = title;
	[self.activityIndicator startAnimating];
	self.hidden=NO;
}

-(void)stop {
	[self.activityIndicator stopAnimating];
	self.hidden=YES;
}

-(void)cancelButtonClicked {
	self.hidden=YES;
}

@end
