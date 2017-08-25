//
//  ThemeColorObj.m
//  PokerTracker
//
//  Created by Rick Medved on 8/16/17.
//
//

#import "ThemeColorObj.h"
#import "ColorSchemes.h"
#import "ProjectFunctions.h"

@implementation ThemeColorObj

// primaryColor	- must be light color
// themeBGColor	- must be dark
// navBarColor	- dark color
// grayColor	- some shade of gray or neutral color

+(ThemeColorObj *)themeWithName:(NSString *)name
				   primaryColor:(UIColor *)primaryColor
				   themeBGColor:(UIColor *)themeBGColor
					navBarColor:(UIColor *)navBarColor
					  grayColor:(UIColor *)grayColor {
	ThemeColorObj *obj = [[ThemeColorObj alloc] init];
	obj.name = name;
	BOOL greatDesign = YES;
	if (CGColorEqualToColor(themeBGColor.CGColor, navBarColor.CGColor)) {
		greatDesign = NO;
		
		CGFloat r1, g1, b1, a1;
		[themeBGColor getRed:&r1 green:&g1 blue:&b1 alpha:&a1];
		navBarColor = [UIColor colorWithRed:[self nonNeg:r1-.15] green:[self nonNeg:g1-.15] blue:[self nonNeg:b1-.15] alpha:a1];
	}
	if (CGColorEqualToColor(primaryColor.CGColor, [UIColor colorWithRed:255.0/255 green:255.0/255 blue:255.0/255 alpha:1].CGColor))
		greatDesign = NO;
	
	if (CGColorEqualToColor(navBarColor.CGColor, [UIColor colorWithRed:0.0/255 green:0.0/255 blue:0.0/255 alpha:1].CGColor))
		greatDesign = NO;
	
	if(greatDesign)
		obj.longName = [NSString stringWithFormat:@"⭐️ %@", name];
	else
		obj.longName = name;
	obj.primaryColor = primaryColor;
	obj.themeBGColor = themeBGColor;
	obj.navBarColor = navBarColor;
	obj.grayColor = grayColor;
	return obj;
}
					   
+(float)nonNeg:(float)number {
	if(number>=0)
		return number;
	else
		return 0;
}



+(NSArray *)themesOfGroup:(int)group {
	if(group==0)
		return [ColorSchemes nflThemes];
	if(group==1)
		return [ColorSchemes mlbThemes];
	if(group==2)
		return [ColorSchemes nbaThemes];
	if(group==3)
		return [ColorSchemes ncaaThemes];
	if(group==4)
		return [ColorSchemes nhlThemes];
	if(group==5)
		return [ColorSchemes mlsThemes];
	if(group==6)
		return [ColorSchemes disneyThemes];
	if(group==7)
		return [ColorSchemes chineseThemes];
	
	return nil;
}

+(ThemeColorObj *)objectOfGroup:(int)group category:(int)category {
	NSArray *themes = [self themesOfGroup:group];
	if(themes.count>category)
		return [themes objectAtIndex:category];
	else
		return nil;
}

+(NSArray *)mainMenuList {
	return [NSArray arrayWithObjects:
			@"NFL",
			@"MLB",
			@"NBA",
			@"NCAA",
			@"NHL",
			@"MLS Soccer",
			@"Disney",
			@"Chinese",
			nil];
}

+(NSString *)packageThemeAsString {
	NSArray *components = [NSArray arrayWithObjects:
						   [NSString stringWithFormat:@"%d", [ProjectFunctions themeTypeNumber]], // custom/theme
						   [NSString stringWithFormat:@"%d", [ProjectFunctions appThemeNumber]], // modern, classic etc
						   [NSString stringWithFormat:@"%d", [ProjectFunctions primaryColorNumber]],
						   [NSString stringWithFormat:@"%d", [ProjectFunctions themeBGNumber]],
						   [NSString stringWithFormat:@"%d", [ProjectFunctions segmentColorNumber]],
						   [NSString stringWithFormat:@"%d", [ProjectFunctions themeGroupNumber]],
						   [NSString stringWithFormat:@"%d", [ProjectFunctions themeCategoryNumber]],
						   nil];
	return [components componentsJoinedByString:@":"];
}

+(ThemeColorObj *)convertToThemeFromString:(NSString *)string {
	ThemeColorObj *obj = [[ThemeColorObj alloc] init];
	NSLog(@"+++%@", string);
	if(string.length<5)
		string = @"0:0:0:0:0:0:0";
	NSArray *components = [string componentsSeparatedByString:@":"];
	if(components.count>6) {
		int themeTypeNumber = [[components objectAtIndex:0] intValue];
//		int appThemeNumber = [[components objectAtIndex:1] intValue];
		if(themeTypeNumber==0) { // custom
			int primaryColorNumber = [[components objectAtIndex:2] intValue];
			int themeBGNumber = [[components objectAtIndex:3] intValue];
			int segmentColorNumber = [[components objectAtIndex:4] intValue];
			NSArray *primaryButtonColors = [ProjectFunctions primaryButtonColors];
			if(primaryButtonColors.count>primaryColorNumber)
				obj.primaryColor = [primaryButtonColors objectAtIndex:primaryColorNumber];
			
			NSArray *bgThemeColors = [ProjectFunctions bgThemeColors];
			if(bgThemeColors.count>themeBGNumber)
				obj.themeBGColor = [bgThemeColors objectAtIndex:themeBGNumber];

			NSArray *navBarThemeColors = [ProjectFunctions navBarThemeColors];
			if(navBarThemeColors.count>segmentColorNumber)
				obj.navBarColor = [navBarThemeColors objectAtIndex:segmentColorNumber];
			obj.grayColor = [UIColor colorWithRed:180.0/255 green:180.0/255 blue:180.0/255 alpha:1];
		} else { // theme
			int themeGroupNumber = [[components objectAtIndex:5] intValue];
			int themeCategoryNumber = [[components objectAtIndex:6] intValue];
			obj = [ThemeColorObj objectOfGroup:themeGroupNumber category:themeCategoryNumber];
		}
	}
	return obj;
}

@end
