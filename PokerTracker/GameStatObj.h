//
//  GameStatObj.h
//  PokerTracker
//
//  Created by Rick Medved on 7/19/17.
//
//

#import <Foundation/Foundation.h>

@interface GameStatObj : NSObject

@property (nonatomic, strong)  NSString *name;
@property (nonatomic, strong)  NSString *shortName;
@property (nonatomic) double profit;
@property (nonatomic) double risked;
@property (nonatomic) int foodDrinks;
@property (nonatomic) int tokes;
@property (nonatomic) double cashoutAmount;
@property (nonatomic) double grossIncome;
@property (nonatomic) double takehomeAmount;
@property (nonatomic) double quarter1Profit;
@property (nonatomic) double quarter2Profit;
@property (nonatomic) double quarter3Profit;
@property (nonatomic) double quarter4Profit;
@property (nonatomic) int games;
@property (nonatomic) int wins;
@property (nonatomic) int losses;
@property (nonatomic) int hudGames;
@property (nonatomic) float bestDayAmount;
@property (nonatomic) float worstDayAmount;
@property (nonatomic) float bestTimeAmount;
@property (nonatomic) float worstTimeAmount;

//-------------detailed stats-----------
@property (nonatomic, strong)  NSString *hudVpvp_Pfr;
@property (nonatomic, strong)  NSString *hudPlayerType;
@property (nonatomic, strong)  NSString *hudPlayerTypeLong;
@property (nonatomic, strong)  NSString *hudSkillLevel;
@property (nonatomic, strong)  NSString *hudGamesStr;
@property (nonatomic, strong)  NSString *profitString;
@property (nonatomic, strong)  NSString *riskedString;
@property (nonatomic, strong)  NSString *gameCount;
@property (nonatomic, strong)  NSString *streak;
@property (nonatomic, strong)  NSString *streakReverse;
@property (nonatomic, strong)  NSString *winStreak;
@property (nonatomic, strong)  NSString *loseStreak;
@property (nonatomic, strong)  NSString *hours;
@property (nonatomic, strong)  NSString *hourly;
@property (nonatomic, strong)  NSString *roi;
@property (nonatomic, strong)  NSString *roiLong;
@property (nonatomic, strong)  NSString *profitHigh;
@property (nonatomic, strong)  NSString *profitLow;
@property (nonatomic, strong)  NSString *bestWeekday;
@property (nonatomic, strong)  NSString *worstWeekday;
@property (nonatomic, strong)  NSString *bestDaytime;
@property (nonatomic, strong)  NSString *worstDaytime;

@property (nonatomic, strong)  NSString *quarter1;
@property (nonatomic, strong)  NSString *quarter2;
@property (nonatomic, strong)  NSString *quarter3;
@property (nonatomic, strong)  NSString *quarter4;
@property (nonatomic, strong)  NSString *totals;

@property (nonatomic, strong)  NSString *gamesWon;
@property (nonatomic, strong)  NSString *gamesWonAverageBuyin;
@property (nonatomic, strong)  NSString *gamesWonMinProfit;
@property (nonatomic, strong)  NSString *gamesWonMaxProfit;
@property (nonatomic, strong)  NSString *gamesWonAverageProfit;
@property (nonatomic, strong)  NSString *gamesWonHourly;
@property (nonatomic, strong)  NSString *gamesWonAverageRisked;
@property (nonatomic, strong)  NSString *gamesWonAverageRebuy;

@property (nonatomic, strong)  NSString *gamesLost;
@property (nonatomic, strong)  NSString *gamesLostAverageBuyin;
@property (nonatomic, strong)  NSString *gamesLostMinProfit;
@property (nonatomic, strong)  NSString *gamesLostMaxProfit;
@property (nonatomic, strong)  NSString *gamesLostAverageProfit;
@property (nonatomic, strong)  NSString *gamesLostHourly;
@property (nonatomic, strong)  NSString *gamesLostAverageRisked;
@property (nonatomic, strong)  NSString *gamesLostAverageRebuy;

+(GameStatObj *)gameStatObjForGames:(NSArray *)games;
+(GameStatObj *)gameStatObjDetailedForGames:(NSArray *)games;

@end
