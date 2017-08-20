//
//  ThemeColorObj.m
//  PokerTracker
//
//  Created by Rick Medved on 8/16/17.
//
//

#import "ThemeColorObj.h"
#import "ColorSchemes.h"

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



+(NSArray *)themesOfGroup:(int)group category:(int)category {
	if(group==0) { // nfl
		if(category==0)
			return [ColorSchemes afcEastThemes];
		if(category==1)
			return [ColorSchemes afcNorthThemes];
		if(category==2)
			return [ColorSchemes afcSouthThemes];
		if(category==3)
			return [ColorSchemes afcWestThemes];
		if(category==4)
			return [ColorSchemes nfcEastThemes];
		if(category==5)
			return [ColorSchemes nfcNorthThemes];
		if(category==6)
			return [ColorSchemes nfcSouthThemes];
		if(category==7)
			return [ColorSchemes nfcWestThemes];
	}
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

+(ThemeColorObj *)objectOfGroup:(int)group category:(int)category number:(int)number {
	NSArray *themes = [self themesOfGroup:group category:category];
	if(themes.count>number)
		return [themes objectAtIndex:number];
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

+(NSArray *)subMenuListForGroup:(int)group level:(int)level category:(int)category {
	if(group==0) { // nfl
		if(level==1)
			return [NSArray arrayWithObjects:@"AFC East", @"AFC North", @"AFC South", @"AFC West", @"NFC East", @"NFC North", @"NFC South", @"NFC West", nil];
	}
	return [self themesOfGroup:group category:category];
}

+(BOOL)showThemesForGroup:(int)group level:(int)level {
	if(group==0)
		return level>2;

	return level>1;
}

@end
