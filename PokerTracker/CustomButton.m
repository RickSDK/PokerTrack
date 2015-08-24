//
//  CustomButton.m
//  PokerTracker
//
//  Created by Rick Medved on 6/26/15.
//
//

#import "CustomButton.h"

#define CORNER_RADIUS          7.0

@implementation CustomButton

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
	self.layer.cornerRadius = CORNER_RADIUS;
	self.layer.masksToBounds = YES;				// clips background images to rounded corners
	self.layer.borderColor = [UIColor blackColor].CGColor;
	self.layer.borderWidth = 1.;
	
	// Default is white background and ATTBlue text color
	self.backgroundColor = [UIColor whiteColor];
	[self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
}

- (void)setEnabled:(BOOL)enabled {
	[super setEnabled:enabled];
	
	if (enabled)
		self.layer.borderColor = [UIColor whiteColor].CGColor;
	else
		self.layer.borderColor = [UIColor lightGrayColor].CGColor;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
	[super setBackgroundColor:backgroundColor];
	
	// Get gray equivalent of the color
	CGFloat white, alpha;
	[backgroundColor getWhite:&white alpha:&alpha];
	
	// Normal state - if defined, image is displayed as is
	[self setBackgroundImage:[self imageFromColor:backgroundColor] forState:UIControlStateNormal];
	
	if (white > 0.6) {
		// Highlighted state - if defined, image is displayed with high transparency;  if not defined and Normal state is defined then system display black with high transparency (i.e. slight dark shade)
		//		[self setBackgroundImage:[self imageFromColor:[UIColor grayColor]] forState:UIControlStateHighlighted];
		[self setBackgroundImage:[self imageFromColor:[UIColor whiteColor]] forState:UIControlStateHighlighted];
		[self setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
		
		// Disabled state - image is displayed as is
		// If button color is bright then make disabled state darker
		[self setBackgroundImage:[self imageFromColor:[UIColor colorWithWhite:0.0 alpha:0.2]] forState:UIControlStateDisabled];
		[self setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
	}
	else {
		// Highlighted state - if defined, image is displayed with high transparency;  if not defined and Normal state is defined then system display black with high transparency (i.e. slight dark shade)
		[self setBackgroundImage:[self imageFromColor:[UIColor whiteColor]] forState:UIControlStateHighlighted];
		[self setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
		
		// Disabled state - image is displayed as is
		// If button color is dark then make disabled state lighter
		[self setBackgroundImage:[self imageFromColor:[UIColor colorWithWhite:1.0 alpha:0.4]] forState:UIControlStateDisabled];
		[self setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
	}
}

- (UIImage *)imageFromColor:(UIColor *)color
{
	static NSMutableDictionary *colorImageCache = nil;
	if (colorImageCache == nil) {
		colorImageCache = [[NSMutableDictionary alloc] initWithCapacity:5];
	}
	
	UIImage *img = [colorImageCache objectForKey:color];
	
	if (img == nil) {
		CGRect rect = CGRectMake(0, 0, 1, 1);
		UIGraphicsBeginImageContext(rect.size);
		CGContextRef context = UIGraphicsGetCurrentContext();
		CGContextSetFillColorWithColor(context, [color CGColor]);
		CGContextFillRect(context, rect);
		img = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
		
		[colorImageCache setObject:img forKey:color];
	}
	return img;
}

@end
