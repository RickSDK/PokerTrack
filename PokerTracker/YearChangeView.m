//
//  YearChangeView.m
//  PokerTracker
//
//  Created by Rick Medved on 7/22/17.
//
//

#import "YearChangeView.h"
#import "ProjectFunctions.h"

#define buttonY			7
#define buttonWidth		80
#define buttonHeight	30

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
	self.yearDownButton = [PtpButton buttonWithType:UIButtonTypeRoundedRect];
	self.yearDownButton.frame = CGRectMake(5, buttonY, buttonWidth, buttonHeight);
	[self.yearDownButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	[self.yearDownButton setTitle:@"Down" forState:UIControlStateNormal];
	[self.yearDownButton addTarget:self action:@selector(yearGoesDown) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:self.yearDownButton];
	
	self.yearUpButton = [PtpButton buttonWithType:UIButtonTypeRoundedRect];
	[self.yearUpButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	self.yearUpButton.frame = CGRectMake(255, buttonY, buttonWidth, buttonHeight);
	[self.yearUpButton setTitle:@"Up" forState:UIControlStateNormal];
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
	
	
	self.nowYear = [[ProjectFunctions getUserDefaultValue:@"maxYear"] intValue];
	if(self.nowYear==0)
		self.nowYear = [ProjectFunctions getNowYear];
	self.invocation = [[NSInvocation alloc] init];
	[self applyTheme];
}

-(void)applyTheme {
	[ProjectFunctions newButtonLook:self.yearDownButton mode:0];
	[ProjectFunctions newButtonLook:self.yearUpButton mode:0];
	if([ProjectFunctions appThemeNumber] == 1)
		self.backgroundColor = [ProjectFunctions segmentThemeColor];
	else if([ProjectFunctions segmentColorNumber]==0 && [ProjectFunctions themeTypeNumber]==0)
		self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"greenGradWide.png"]];
	else
		self.backgroundColor = [UIColor colorWithPatternImage:[ProjectFunctions gradientImageNavbarOfWidth:self.frame.size.width]];
}

- (void)layoutSubviews {
	[super layoutSubviews];
	
	float width = self.frame.size.width;
	self.yearUpButton.frame = CGRectMake(width-85, buttonY, buttonWidth, buttonHeight);
	self.yearLabel.frame = CGRectMake(buttonWidth, 0, width-(buttonWidth*2), 44);
}

-(void)addTargetSelector:(SEL)selector target:(id)target {
	self.selector = selector;
	self.target = target;
}

-(void)setYear:(int)year min:(int)min {
	if(self.minYear==0)
		self.minYear = min;
	if(year<0) {
		year=self.nowYear;
	}
	
	if(year>self.nowYear)
		year=0;
	
	self.statYear=year;
	
	if(year>0)
		self.yearLabel.text = [NSString stringWithFormat:@"%d", year];
	else {
		self.yearLabel.text = NSLocalizedString(@"All", nil);
		[self.yearDownButton setTitle:[NSString stringWithFormat:@"%d", self.nowYear] forState:UIControlStateNormal];
	}
	
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
	[self setYear:[self.yearUpButton titleForState:UIControlStateNormal].intValue min:self.minYear];
}

-(void)yearGoesDown {
	[self setYear:[self.yearDownButton titleForState:UIControlStateNormal].intValue min:self.minYear];
}

@end
