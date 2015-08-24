//
//  UIColor+ATTColor.h
//  BASE
//
//

#import <UIKit/UIKit.h>


typedef enum _AWColorScheme {
	ColorSchemeVanilla = 0,
	ColorSchemeBlueOrange,
} AWColorScheme;


@interface UIColor (ATTColor)

+ (UIColor *)ATTBlue;
+ (UIColor *)ATTDarkBlue;
+ (UIColor *)ATTLightBlue;
+ (UIColor *)ATTOrange;
+ (UIColor *)ATTLightOrange;
+ (UIColor *)ATTLime;
+ (UIColor *)ATTLightLime;
+ (UIColor *)ATTGreen;
+ (UIColor *)ATTLightGreen;
+ (UIColor *)ATTBurgundy;
+ (UIColor *)ATTLightBurgundy;
+ (UIColor *)ATTPurple;
+ (UIColor *)ATTLightPurple;
+ (UIColor *)ATTSilver;
+ (UIColor *)ATTFaintBlue;

+ (UIColor *)ATTTableBackground;

+ (UIColor *)ATTCellRowShading;
+ (UIColor *)ATTListRowShading;

+ (UIColor *)ATTStatusGreen;
+ (UIColor *)ATTStatusRed;
+ (UIColor *)ATTStatusOrange;

+ (UIColor *)ATTStatusGreenFill;
+ (UIColor *)ATTStatusRedFill;
+ (UIColor *)ATTStatusYellowFill;

@end
