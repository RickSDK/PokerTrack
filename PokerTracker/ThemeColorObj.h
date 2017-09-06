//
//  ThemeColorObj.h
//  PokerTracker
//
//  Created by Rick Medved on 8/16/17.
//
//

#import <Foundation/Foundation.h>

@interface ThemeColorObj : NSObject

@property (nonatomic, strong)  NSString *name;
@property (nonatomic, strong)  NSString *longName;
@property (nonatomic, strong)  UIColor *primaryColor;
@property (nonatomic, strong)  UIColor *themeBGColor;
@property (nonatomic, strong)  UIColor *navBarColor;
@property (nonatomic, strong)  UIColor *grayColor;
@property (nonatomic) int themeTypeNumber;
@property (nonatomic) int appThemeNumber;
@property (nonatomic) int primaryColorNumber;
@property (nonatomic) int themeBGNumber;
@property (nonatomic) int segmentColorNumber;
@property (nonatomic) int themeGroupNumber;
@property (nonatomic) int themeCategoryNumber;

+(ThemeColorObj *)themeWithName:(NSString *)name
				   primaryColor:(UIColor *)primaryColor
				   themeBGColor:(UIColor *)themeBGColor
					navBarColor:(UIColor *)navBarColor
					  grayColor:(UIColor *)grayColor;
+(ThemeColorObj *)objectOfGroup:(int)group category:(int)category;
+(NSArray *)mainMenuList;
+(NSArray *)themesOfGroup:(int)group;

+(NSString *)packageThemeAsString;
+(ThemeColorObj *)convertToThemeFromString:(NSString *)string;
+(void)applyTheme:(NSString *)themeString;
+(void)applyThemeObj:(ThemeColorObj *)themeObj;

@end
