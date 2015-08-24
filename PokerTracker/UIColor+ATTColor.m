//
//  UIColor+ATTColor.m
//  BASE
//
//

#import "UIColor+ATTColor.h"


@implementation UIColor (ATTColor)

+ (UIColor *)ATTBlue {
	return [UIColor colorWithRed:(6/255.0) green:(122/255.0) blue:(180/255.0) alpha:1.0];
}

+ (UIColor *)ATTLightBlue {
	return [UIColor colorWithRed:(58/255.0) green:(165/255.0) blue:(220/255.0) alpha:1.0];
}

+ (UIColor *)ATTDarkBlue {
	return [UIColor colorWithRed:(12/255.0) green:(37/255.0) blue:(119/255.0) alpha:1.0];
}

+ (UIColor *)ATTOrange {
	return [UIColor colorWithRed:(255/255.0) green:(114/255.0) blue:(0/255.0) alpha:1.0];
}

+ (UIColor *)ATTLightOrange {
	return [UIColor colorWithRed:(252/255.0) green:(179/255.0) blue:(20/255.0) alpha:1.0];
}

+ (UIColor *)ATTLime {
	return [UIColor colorWithRed:(182/255.0) green:(191/255.0) blue:(0/255.0) alpha:1.0];
}

+ (UIColor *)ATTLightLime {
	return [UIColor colorWithRed:(219/255.0) green:(216/255.0) blue:(16/255.0) alpha:1.0];
}

+ (UIColor *)ATTGreen {
	return [UIColor colorWithRed:(110/255.0) green:(187/255.0) blue:(31/255.0) alpha:1.0];
}

+ (UIColor *)ATTLightGreen {
	return [UIColor colorWithRed:(196/255.0) green:(216/255.0) blue:(45/255.0) alpha:1.0];
}

+ (UIColor *)ATTBurgundy {
	return [UIColor colorWithRed:(179/255.0) green:(10/255.0) blue:(60/255.0) alpha:1.0];
}

+ (UIColor *)ATTLightBurgundy {
	return [UIColor colorWithRed:(218/255.0) green:(56/255.0) blue:(114/255.0) alpha:1.0];
}

+ (UIColor *)ATTPurple {
	return [UIColor colorWithRed:(129/255.0) green:(1/255.0) blue:(126/255.0) alpha:1.0];
}

+ (UIColor *)ATTLightPurple {
	return [UIColor colorWithRed:(184/255.0) green:(80/255.0) blue:(158/255.0) alpha:1.0];
}

+ (UIColor *)ATTSilver {
	return [UIColor colorWithRed:(205/255.0) green:(207/255.0) blue:(208/255.0) alpha:1.0];
}

+ (UIColor *)ATTFaintBlue {
	return [UIColor colorWithRed:237/255.0 green:243/255.0 blue:254/255.0 alpha:1.0];
}

//
// For methods below, return nil to get default SDK colors
//

+ (UIColor *)ATTTableBackground {
	return [UIColor groupTableViewBackgroundColor];
}


+ (UIColor *)ATTCellRowShading {
	return [UIColor ATTFaintBlue];
}

+ (UIColor *)ATTListRowShading {
	return [UIColor ATTFaintBlue];
}

+ (UIColor *)ATTStatusGreen {
	return [UIColor colorWithRed:0 green:128/255.0 blue:0 alpha:1.0];
}

+ (UIColor *)ATTStatusRed {
	return [UIColor redColor];
}

+ (UIColor *)ATTStatusOrange {
	return [UIColor orangeColor];
}

+ (UIColor *)ATTStatusGreenFill {
	return [UIColor greenColor];
}

+ (UIColor *)ATTStatusRedFill {
	return [UIColor redColor];
}

+ (UIColor *)ATTStatusYellowFill {
	return [UIColor yellowColor];
}

@end
