//
//  YearChangeView.m
//  PokerTracker
//
//  Created by Rick Medved on 7/22/17.
//
//

#import "YearChangeView.h"
#import "ProjectFunctions.h"

@implementation YearChangeView

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
	
	self.yearDownButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	self.yearDownButton.frame = CGRectMake(5, 5, 80, 34);
	[self.yearDownButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	[self.yearDownButton setTitle:@"Down" forState:UIControlStateNormal];
	[self.yearDownButton setBackgroundImage:[UIImage imageNamed:@"yellowChromeBut.png"] forState:UIControlStateNormal];
	[self.yearDownButton addTarget:self action:@selector(yearGoesDown) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:self.yearDownButton];
	
	self.yearUpButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[self.yearUpButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	self.yearUpButton.frame = CGRectMake(255, 5, 80, 34);
	[self.yearUpButton setTitle:@"Up" forState:UIControlStateNormal];
	[self.yearUpButton setBackgroundImage:[UIImage imageNamed:@"yellowChromeBut.png"] forState:UIControlStateNormal];
	[self.yearUpButton addTarget:self action:@selector(yearGoesUp) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:self.yearUpButton];
	
	self.yearLabel = [[UILabel alloc] initWithFrame:CGRectMake(150, 5, 190, 25)];
	self.yearLabel.font = [UIFont boldSystemFontOfSize:16];	// label is 17, system is 14
	self.yearLabel.textAlignment = NSTextAlignmentCenter;
	self.yearLabel.minimumScaleFactor=.5;
	self.yearLabel.adjustsFontSizeToFitWidth = YES;
	self.yearLabel.textColor = [UIColor whiteColor];
	self.yearLabel.backgroundColor = [UIColor clearColor];
	self.yearLabel.text = @"2015";
	[self addSubview:self.yearLabel];
	
	self.layer.cornerRadius = 7;
	self.layer.masksToBounds = YES;				// clips background images to rounded corners
	self.layer.borderColor = [UIColor blackColor].CGColor;
	self.layer.borderWidth = 2.;
	self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"greenGradWide.png"]];
	
	self.nowYear = [ProjectFunctions getNowYear];
	self.invocation = [[NSInvocation alloc] init];

}

- (void)layoutSubviews {
	[super layoutSubviews];
	
	float width = [[UIScreen mainScreen] bounds].size.width;
	self.yearUpButton.frame = CGRectMake(width-85, 5, 80, 34);
	self.yearLabel.frame = CGRectMake(85, 0, width-(85*2), 44);
}

-(void)addTargetSelector:(SEL)selector target:(id)target {
	self.selector = selector;
	self.target = target;
}

-(void)setYear:(int)year min:(int)min {
	self.minYear = min;
	if(year<0)
		year=self.nowYear;
	
	if(year>self.nowYear)
		year=0;
	
	self.statYear=year;
	
	if(year>0)
		self.yearLabel.text = [NSString stringWithFormat:@"%d", year];
	else
		self.yearLabel.text = NSLocalizedString(@"All", nil);
	
	if(year==min)
		[self.yearDownButton setTitle:@"-" forState:UIControlStateNormal];
	else
		[self.yearDownButton setTitle:[NSString stringWithFormat:@"%d", year-1] forState:UIControlStateNormal];
	if(year==self.nowYear)
		[self.yearUpButton setTitle:NSLocalizedString(@"All", nil) forState:UIControlStateNormal];
	else if (year==0) {
		[self.yearUpButton setTitle:@"-" forState:UIControlStateNormal];
		[self.yearDownButton setTitle:[NSString stringWithFormat:@"%d", self.nowYear] forState:UIControlStateNormal];
	} else
		[self.yearUpButton setTitle:[NSString stringWithFormat:@"%d", year+1] forState:UIControlStateNormal];

	self.yearDownButton.enabled=year!=min;
	self.yearUpButton.enabled=year>0;
	if(self.selector && self.target) {
		if([self.target respondsToSelector:self.selector])
			[self.target performSelector:self.selector
						  withObject:nil
						  afterDelay:0];
	}
}

-(void)yearGoesUp {
	int year = [self.yearLabel.text intValue];
	year++;
	[self setYear:year min:self.minYear];
}

-(void)yearGoesDown {
	int year = [self.yearLabel.text intValue];
	year--;
	[self setYear:year min:self.minYear];
}

@end
