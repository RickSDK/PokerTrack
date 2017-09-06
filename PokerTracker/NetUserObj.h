//
//  NetUserObj.h
//  PokerTracker
//
//  Created by Rick Medved on 3/23/16.
//
//

#import <Foundation/Foundation.h>
#import "GameObj.h"
#import "ThemeColorObj.h"

@interface NetUserObj : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic) int userId;
@property (nonatomic) int viewingUserId;
@property (nonatomic) int rowId;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *state;
@property (nonatomic, strong) NSString *country;
@property (nonatomic, strong) NSString *location;
@property (nonatomic, strong) NSString *friendStatus;
@property (nonatomic, strong) NSString *moneySymbol;
@property (nonatomic, strong) NSString *version;

@property (nonatomic, strong) ThemeColorObj *themeColorObj;

@property (nonatomic, strong) NSString *games;
@property (nonatomic, strong) NSString *streak;
@property (nonatomic) int streakCount;
@property (nonatomic) double risked;
@property (nonatomic) double profit;
@property (nonatomic, strong) NSString *profitStr;
@property (nonatomic, strong) NSString *ppr;
@property (nonatomic) float hours;
@property (nonatomic) int gameCount;
@property (nonatomic) int pprCount;
@property (nonatomic) int minutes;
@property (nonatomic) int sortType;
@property (nonatomic) BOOL hasFlag;
@property (nonatomic) BOOL currentVersionFlg;
@property (nonatomic) BOOL themeFlg;
@property (nonatomic) BOOL customFlg;
@property (nonatomic) int themeGroupNumber;
@property (nonatomic, strong) UIImage *flagImage;
@property (nonatomic, strong) UIImage *leftImage;
@property (nonatomic, strong) NSString *hourly;
@property (nonatomic, strong) GameObj *lastGame;

@property (nonatomic, strong) NSString *basicsStr;
@property (nonatomic, strong) NSString *last10Str;
@property (nonatomic, strong) NSString *yearStats;
@property (nonatomic, strong) NSString *monthStats;
@property (nonatomic, strong) NSString *lastGameStr;

@property (nonatomic, strong) NSString *last90Days;
@property (nonatomic, strong) NSString *thisMonthGames;
@property (nonatomic, strong) NSString *last10Games;

@property (nonatomic, strong) NSArray *last10Elements;
@property (nonatomic, strong) NSArray *yearElements;
@property (nonatomic, strong) NSArray *monthElements;
@property (nonatomic, strong) NSArray *statsTitles;
@property (nonatomic, strong) NSArray *last10StatsValues;
@property (nonatomic, strong) NSArray *last10StatsColors;
@property (nonatomic, strong) NSArray *monthStatsValues;
@property (nonatomic, strong) NSArray *monthStatsColors;
@property (nonatomic, strong) NSArray *yearStatsValues;
@property (nonatomic, strong) NSArray *yearStatsColors;

@property (nonatomic) BOOL nowPlayingFlg;
@property (nonatomic) BOOL friendFlg;
@property (nonatomic) int iconGroupNumber;

+(NetUserObj *)userObjFromString:(NSString *)line type:(int)type;
+(NetUserObj *)friendObjFromLine:(NSString *)line;
+(void)populateGameStats:(NetUserObj *)netUserObj line:(NSString *)line type:(int)type;
- (NSComparisonResult)compare:(NetUserObj *)otherObject;
- (NSComparisonResult)compareGames:(NetUserObj *)otherObject;
- (NSComparisonResult)comparePpr:(NetUserObj *)otherObject;

@end
