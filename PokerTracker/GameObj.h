//
//  GameObj.h
//  PokerTracker
//
//  Created by Rick Medved on 1/22/16.
//
//

#import <Foundation/Foundation.h>

@interface GameObj : NSObject

@property (nonatomic) BOOL tournamentGameFlg;

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *gametype;
@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSString *game;
@property (nonatomic, strong) NSString *stakes;
@property (nonatomic, strong) NSString *limit;
@property (nonatomic, strong) NSString *location;
@property (nonatomic, strong) NSString *bankroll;
@property (nonatomic, strong) NSString *hours;
@property (nonatomic, strong) NSString *daytime;
@property (nonatomic, strong) NSString *month;
@property (nonatomic, strong) NSString *weekday;
@property (nonatomic, strong) NSString *year;
@property (nonatomic, strong) NSString *notes;
@property (nonatomic, strong) NSString *hourlyStr;
@property (nonatomic, strong) NSString *tournamentType;

@property (nonatomic, strong) NSDate *startTime;
@property (nonatomic, strong) NSDate *endTime;
@property (nonatomic, strong) NSDate *lastUpd;

@property (nonatomic) int game_id;
@property (nonatomic) int user_id;
@property (nonatomic) double profit; // winnings
@property (nonatomic) double buyInAmount;
@property (nonatomic) double cashoutAmount;
@property (nonatomic) double risked;
@property (nonatomic) double grossIncome;
@property (nonatomic) double takeHome;
@property (nonatomic) int foodDrink;
@property (nonatomic) int tokes;
@property (nonatomic) double reBuyAmount;
@property (nonatomic) int minutes;
@property (nonatomic) int breakMinutes;
@property (nonatomic) int ppr;
@property (nonatomic) int numPlayers;
@property (nonatomic) int numRebuys;
@property (nonatomic) int tournamentFinish;
@property (nonatomic) int tournamentSpots;
@property (nonatomic) int tournamentSpotsPaid;
@property (nonatomic) BOOL hudStatsFlg;
@property (nonatomic) BOOL isTourney;

@property (nonatomic, strong) NSString *startTimeStr;
@property (nonatomic, strong) NSString *startTimeAltStr;
@property (nonatomic, strong) NSString *startTimePTP;
@property (nonatomic, strong) NSString *weekdayAltStr;
@property (nonatomic, strong) NSString *endTimeStr;
@property (nonatomic, strong) NSString *endTimePTP;
@property (nonatomic, strong) NSString *profitStr;
@property (nonatomic, strong) NSString *profitLongStr;
@property (nonatomic, strong) NSString *buyInAmountStr;
@property (nonatomic, strong) NSString *cashoutAmountStr;
@property (nonatomic, strong) NSString *riskedStr;
@property (nonatomic, strong) NSString *grossIncomeStr;
@property (nonatomic, strong) NSString *takeHomeStr;
@property (nonatomic, strong) NSString *foodDrinkStr;
@property (nonatomic, strong) NSString *tokesStr;
@property (nonatomic, strong) NSString *reBuyAmountStr;
@property (nonatomic, strong) NSString *roiStr;
@property (nonatomic, strong) NSString *numRebuysStr;
@property (nonatomic, strong) NSString *breakMinutesStr;
@property (nonatomic, strong) NSString *tournamentFinishStr;
@property (nonatomic, strong) NSString *tournamentSpotsStr;
@property (nonatomic, strong) NSString *tournamentSpotsPaidStr;
@property (nonatomic, strong) NSString *hudHeroStr;
@property (nonatomic, strong) NSString *hudVillianStr;


@property (nonatomic) BOOL onBreakFlag;

+(GameObj *)gameObjFromDBObj:(NSManagedObject *)mo;
+(GameObj *)populateGameFromString:(NSString *)line;

@end
