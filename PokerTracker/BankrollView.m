//
//  BankrollView.m
//  PokerTracker
//
//  Created by Rick Medved on 8/12/17.
//
//

#import "BankrollView.h"
#import "ProjectFunctions.h"

#define buttonY			7
#define buttonWidth		44
#define buttonHeight	30

@implementation BankrollView

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
	self.editButton = [PtpButton buttonWithType:UIButtonTypeRoundedRect];
	[self.editButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	self.editButton.frame = CGRectMake(255, buttonY, buttonWidth, buttonHeight);
	self.editButton.tag=2;
	[self.editButton setTitle:@"Edit" forState:UIControlStateNormal];
	[self.editButton addTarget:self action:@selector(editBankroll) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:self.editButton];
	[ProjectFunctions makeFAButton:self.editButton type:2 size:14];
	[self.editButton assignMode:2];

	self.xButton = [PtpButton buttonWithType:UIButtonTypeRoundedRect];
	[self.xButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	self.xButton.frame = CGRectMake(255, buttonY, buttonWidth, buttonHeight);
	self.xButton.tag=2;
	[self.xButton setTitle:@"X" forState:UIControlStateNormal];
	[self.xButton addTarget:self action:@selector(xButtonPressed) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:self.xButton];
	[ProjectFunctions makeFAButton:self.xButton type:23 size:14];
	[self.xButton assignMode:2];
	
	NSString *bankrollDefault = [ProjectFunctions getUserDefaultValue:@"bankrollDefault"];
	if(bankrollDefault.length==0)
		bankrollDefault = @"Default";
	self.bankRollSegment = [[CustomSegment alloc] initWithItems:[NSArray arrayWithObjects:bankrollDefault, @"All Bankrolls", nil]];
	[self.bankRollSegment addTarget:self action:@selector(changeBankroll) forControlEvents:UIControlEventValueChanged];
	self.bankRollSegment.segmentedControlStyle = UISegmentedControlStyleBar;
	self.bankRollSegment.selectedSegmentIndex=0;
	[self addSubview:self.bankRollSegment];
	[self.bankRollSegment changeSegment];
	
	self.allBankrollsButton = [PtpButton buttonWithType:UIButtonTypeRoundedRect];
	[self.allBankrollsButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	self.allBankrollsButton.frame = CGRectMake(5, buttonY, 100, buttonHeight);
	self.allBankrollsButton.tag=2;
	[self.allBankrollsButton setTitle:@"Bankroll" forState:UIControlStateNormal];
	[self.allBankrollsButton addTarget:self action:@selector(allBankrollButtonPressed) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:self.allBankrollsButton];
	[ProjectFunctions makeFAButton:self.allBankrollsButton type:45 size:12 text:[self currentBankroll]];
	
	[self showButtons:NO];
	int numBanks = [[ProjectFunctions getUserDefaultValue:@"numBanks"] intValue];
	self.hidden = (numBanks == 0);
}

-(NSString *)currentBankroll {
	if([@"YES" isEqualToString:[ProjectFunctions getUserDefaultValue:@"limitBankRollGames"]])
		return [ProjectFunctions getUserDefaultValue:@"bankrollDefault"];
	else
		return @"All Bankrolls";
}

- (void)layoutSubviews {
	[super layoutSubviews];
	
	float width = [[UIScreen mainScreen] bounds].size.width;
	self.bankRollSegment.frame = CGRectMake(5, buttonY, width-110, 30);
	self.editButton.frame = CGRectMake(width-100, buttonY, buttonWidth, buttonHeight);
	self.xButton.frame = CGRectMake(width-50, buttonY, buttonWidth, buttonHeight);
}

-(void)showButtons:(BOOL)allFlg {
	self.allBankrollsButton.hidden=allFlg;
	self.bankRollSegment.hidden=!allFlg;
	self.editButton.hidden=!allFlg;
	self.xButton.hidden=!allFlg;
	if(allFlg) {
		[self applyTheme];
	} else {
		self.backgroundColor = [UIColor clearColor];
	}
}

-(void)allBankrollButtonPressed {
	[self showButtons:YES];
}

-(void)xButtonPressed {
	self.hidden=YES;
}

-(void)applyTheme {
	if([ProjectFunctions appThemeNumber] == 1)
		self.backgroundColor = [ProjectFunctions segmentThemeColor];
	else if([ProjectFunctions segmentColorNumber]==0)
		self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"greenGradWide.png"]];
	else
		self.backgroundColor = [UIColor colorWithPatternImage:[ProjectFunctions gradientImageNavbarOfWidth:self.frame.size.width]];
}

-(void)changeBankroll {
	NSLog(@"changeBankroll");
	if(self.bankRollSegment.selectedSegmentIndex==1) {
		[ProjectFunctions setUserDefaultValue:@"" forKey:@"limitBankRollGames"];
	} else {
		[ProjectFunctions setUserDefaultValue:@"YES" forKey:@"limitBankRollGames"];
	}
	[self showButtons:NO];
	[ProjectFunctions makeFAButton:self.allBankrollsButton type:45 size:12 text:[self currentBankroll]];
	
	if(self.segmentSelector && self.target) {
		if([self.target respondsToSelector:self.segmentSelector])
			[self.target performSelector:self.segmentSelector
							  withObject:nil
							  afterDelay:0];
	}
}

-(void)editBankroll {
	NSLog(@"editBankroll");
	if(self.selector && self.target) {
		if([self.target respondsToSelector:self.selector])
			[self.target performSelector:self.selector
							  withObject:nil
							  afterDelay:0];
	}
}

-(void)addTargetSelector:(SEL)selector target:(id)target {
	self.selector = selector;
	self.target = target;
}

-(void)addSegmentTargetSelector:(SEL)selector target:(id)target {
	self.segmentSelector = selector;
	self.target = target;
}


@end
