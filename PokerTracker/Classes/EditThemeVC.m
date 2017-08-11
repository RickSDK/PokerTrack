//
//  EditThemeVC.m
//  PokerTracker
//
//  Created by Rick Medved on 8/8/17.
//
//

#import "EditThemeVC.h"
#import <QuartzCore/QuartzCore.h>

@interface EditThemeVC ()

@end

@implementation EditThemeVC

- (void)viewDidLoad {
    [super viewDidLoad];
	[self setTitle:@"Edit Theme"];
	self.mainSegment.selectedSegmentIndex = [ProjectFunctions appThemeNumber];
	[self.mainSegment changeSegment];
	self.imageBGSegment.selectedSegmentIndex = [ProjectFunctions getThemeBGImageColor];
	[self.imageBGSegment changeSegment];
	[ProjectFunctions makeFAButton:self.bgDownButton type:43 size:24];
	[ProjectFunctions makeFAButton:self.bgUpButton type:44 size:24];
	[ProjectFunctions makeFAButton:self.colorsDownButton type:43 size:24];
	[ProjectFunctions makeFAButton:self.colorsUpButton type:44 size:24];
	[ProjectFunctions makeFAButton:self.segmentDownButton type:43 size:24];
	[ProjectFunctions makeFAButton:self.segmentUpButton type:44 size:24];
	self.colorNumber = [ProjectFunctions primaryColorNumber];
	self.segmentColorNumber = [ProjectFunctions segmentColorNumber];
	self.bgNumber = [ProjectFunctions themeBGNumber];
	self.imageBGSwitch.on = [ProjectFunctions getThemeBGImageFlg];

	self.navigationItem.rightBarButtonItem = [ProjectFunctions UIBarButtonItemWithIcon:[NSString fontAwesomeIconStringForEnum:FARepeat] target:self action:@selector(resetPressed)];

	[self drawColors];
	[self styleButtons];
}

-(void)drawColors {
	self.yVal1=150;
	self.yVal2=250;
	self.yVal3=350;
	[self drawColors:[ProjectFunctions primaryButtonColors] index:0 yVal:self.yVal1 imageView:self.selectedButtonImageView];
	[self drawColors:[ProjectFunctions bgThemeColors] index:0 yVal:self.yVal2 imageView:self.selectedSegmentImageView];
	[self drawColors:[ProjectFunctions bgThemeColors] index:0 yVal:self.yVal3 imageView:self.selectedbgImageView];
	
	self.selectedButtonImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, self.yVal1, self.width1, 10)];
	[self styleSelectionView:self.selectedButtonImageView color:[UIColor redColor]];
	[self.view addSubview:self.selectedButtonImageView];
	
	self.selectedSegmentImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, self.yVal2, self.width2, 10)];
	[self styleSelectionView:self.selectedSegmentImageView color:[UIColor yellowColor]];
	[self.view addSubview:self.selectedSegmentImageView];
	
	self.selectedbgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, self.yVal3, self.width3, 10)];
	[self styleSelectionView:self.selectedbgImageView color:[UIColor yellowColor]];
	[self.view addSubview:self.selectedbgImageView];
	
}

-(void)styleSelectionView:(UIImageView *)imageView color:(UIColor *)color {
	imageView.backgroundColor = [UIColor clearColor];
	imageView.layer.masksToBounds = YES;				// clips background images to rounded corners
	imageView.layer.borderColor = color.CGColor;
	imageView.layer.borderWidth = 2;
}

-(void)drawColors:(NSArray *)colors index:(int)index yVal:(float)yVal imageView:(UIImageView *)imageView {
	if(colors.count>0) {
		float x=0;
		float width=self.view.frame.size.width/colors.count;
		if(yVal==self.yVal1)
			self.width1=width;
		if(yVal==self.yVal2)
			self.width2=width;
		if(yVal==self.yVal3)
			self.width3=width;
		int i=0;
		for(UIColor *color in colors) {
			UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(x, yVal, width, 10)];
			imageView.backgroundColor = color;
			[self.view addSubview:imageView];
			x+=width;
			i++;
		}
	}
}

-(void)resetPressed {
	self.bgNumber=0;
	self.colorNumber=0;
	self.segmentColorNumber=0;
	[ProjectFunctions setUserDefaultValue:[NSString stringWithFormat:@"%d", self.bgNumber] forKey:@"bgThemeColorNumber"];
	[ProjectFunctions setUserDefaultValue:[NSString stringWithFormat:@"%d", self.colorNumber] forKey:@"primaryColorNumber"];
	[ProjectFunctions setUserDefaultValue:[NSString stringWithFormat:@"%d", self.segmentColorNumber] forKey:@"segmentColorNumber"];
	self.mainSegment.selectedSegmentIndex=0;
	[self setThemeBGImageFlg:NO];
	[self segmentDidChange];
}

- (IBAction) segmentChanged:(id)sender {
	[self segmentDidChange];
}

-(void)segmentDidChange {
	[self.mainSegment changeSegment];
	[ProjectFunctions setUserDefaultValue:[NSString stringWithFormat:@"%d", (int)self.mainSegment.selectedSegmentIndex] forKey:@"themeNumber"];
	if(self.mainSegment.selectedSegmentIndex==1 && self.imageBGSwitch.on) {
		[self setThemeBGImageFlg:NO];
	}
	
	[self styleButtons];
}

-(void)styleButtons {
	self.colorNumber = [ProjectFunctions primaryColorNumber];
	self.segmentColorNumber = [ProjectFunctions segmentColorNumber];
	self.bgNumber = [ProjectFunctions themeBGNumber];
	
	[ProjectFunctions newButtonLook:self.testButton1 mode:0];
	[ProjectFunctions newButtonLook:self.testButton2 mode:1];
	[ProjectFunctions newButtonLook:self.testButton3 mode:2];
	[ProjectFunctions newButtonLook:self.testButton4 mode:3];

	[ProjectFunctions newButtonLook:self.bgDownButton mode:0];
	[ProjectFunctions newButtonLook:self.bgUpButton mode:0];
	[ProjectFunctions newButtonLook:self.colorsDownButton mode:0];
	[ProjectFunctions newButtonLook:self.colorsUpButton mode:0];
	[ProjectFunctions newButtonLook:self.segmentDownButton mode:0];
	[ProjectFunctions newButtonLook:self.segmentUpButton mode:0];

	self.colorsUpButton.enabled=self.mainSegment.selectedSegmentIndex!=2;
	self.colorsDownButton.enabled=self.mainSegment.selectedSegmentIndex!=2;
	self.view.backgroundColor = [ProjectFunctions themeBGColor];
	[self.yearChangeView applyTheme];
	[self.mainSegment applyThemeColor];
	[self.imageBGSegment applyThemeColor];
	[ProjectFunctions tintNavigationBar:self.navigationController.navigationBar];
	
	self.selectedButtonImageView.center = CGPointMake(self.colorNumber*self.width1+self.width1/2, self.yVal1+5);
	self.selectedSegmentImageView.center = CGPointMake(self.segmentColorNumber*self.width2+self.width2/2, self.yVal2+5);
	self.selectedbgImageView.center = CGPointMake(self.bgNumber*self.width3+self.width3/2, self.yVal3+5);

	self.bgImageView.hidden = !self.imageBGSwitch.on;
	self.bgImageView.image = [ProjectFunctions bgThemeImage];
	self.imageBGSegment.enabled=self.imageBGSwitch.on;

}

- (IBAction) bgButtonPressed: (UIButton *) button {
	if(button.tag==1)
		self.bgNumber++;
	else
		self.bgNumber--;
	
	if(self.imageBGSwitch.on) {
		[self setThemeBGImageFlg:NO];
	}
	[ProjectFunctions setUserDefaultValue:[NSString stringWithFormat:@"%d", self.bgNumber] forKey:@"bgThemeColorNumber"];
	[self styleButtons];
}

- (IBAction) colorsButtonPressed: (UIButton *) button {
	if(button.tag==1)
		self.colorNumber++;
	else
		self.colorNumber--;
	[ProjectFunctions setUserDefaultValue:[NSString stringWithFormat:@"%d", self.colorNumber] forKey:@"primaryColorNumber"];
	[self styleButtons];
}

- (IBAction) segmentColorButtonPressed: (UIButton *) button {
	if(button.tag==1)
		self.segmentColorNumber++;
	else
		self.segmentColorNumber--;
	[ProjectFunctions setUserDefaultValue:[NSString stringWithFormat:@"%d", self.segmentColorNumber] forKey:@"segmentColorNumber"];
	[self styleButtons];
}

- (IBAction) imageBGSwitchPressed: (UISwitch *) uiSwitch {
	[self setThemeBGImageFlg:uiSwitch.on];
	[self styleButtons];
}

- (IBAction) imageBGSegmentPressed: (UISegmentedControl *) segment {
	[self setThemeBGImageColor:(int)segment.selectedSegmentIndex];
	[self.imageBGSegment changeSegment];
	[self styleButtons];
}

-(void)setThemeBGImageFlg:(BOOL)flag {
	if(self.imageBGSwitch.on != flag)
		self.imageBGSwitch.on=flag;
	[ProjectFunctions setUserDefaultValue:(flag)?@"Y":@"N" forKey:@"themBGImageFlg"];
}

-(void)setThemeBGImageColor:(int)number {
	[ProjectFunctions setUserDefaultValue:[NSString stringWithFormat:@"%d", number] forKey:@"themeBGImageColor"];
}

@end
