//
//  NetUserObj.h
//  PokerTracker
//
//  Created by Rick Medved on 3/23/16.
//
//

#import <Foundation/Foundation.h>

@interface NetUserObj : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic) int userId;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *state;
@property (nonatomic, strong) NSString *country;
@property (nonatomic, strong) NSString *friendStatus;
@property (nonatomic, strong) NSString *moneySymbol;
@property (nonatomic, strong) NSString *version;

@property (nonatomic, strong) NSString *lastGame;

@property (nonatomic, strong) NSString *games;
@property (nonatomic, strong) NSString *streak;
@property (nonatomic) int risked;
@property (nonatomic) int profit;
@property (nonatomic, strong) NSString *ppr;
@property (nonatomic) int hours;
@property (nonatomic, strong) NSString *hourly;
@property (nonatomic, strong) NSString *lastStartTime;
@property (nonatomic, strong) NSString *lastLocation;

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

@property (nonatomic) BOOL nowPlayingFlg;
@property (nonatomic) BOOL friendFlg;

+(NetUserObj *)userObjFromString:(NSString *)line;
+(NetUserObj *)friendObjFromLine:(NSString *)line;

@end
