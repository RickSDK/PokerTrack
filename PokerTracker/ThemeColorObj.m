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
	obj.primaryColor = primaryColor;
	obj.themeBGColor = themeBGColor;
	obj.navBarColor = navBarColor;
	obj.grayColor = grayColor;
	return obj;
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
