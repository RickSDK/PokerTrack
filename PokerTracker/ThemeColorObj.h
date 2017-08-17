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
@property (nonatomic, strong)  UIColor *primaryColor;
@property (nonatomic, strong)  UIColor *themeBGColor;
@property (nonatomic, strong)  UIColor *navBarColor;
@property (nonatomic, strong)  UIColor *grayColor;

+(ThemeColorObj *)themeWithName:(NSString *)name
				   primaryColor:(UIColor *)primaryColor
				   themeBGColor:(UIColor *)themeBGColor
					navBarColor:(UIColor *)navBarColor
					  grayColor:(UIColor *)grayColor;
+(ThemeColorObj *)objectOfGroup:(int)group category:(int)category number:(int)number;
+(NSArray *)mainMenuList;
+(NSArray *)subMenuListForGroup:(int)group level:(int)level category:(int)category;
+(BOOL)showThemesForGroup:(int)group level:(int)level;

@end
