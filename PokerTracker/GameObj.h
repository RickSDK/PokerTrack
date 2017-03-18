//
//  GameObj.h
//  PokerTracker
//
//  Created by Rick Medved on 1/22/16.
//
//

#import <Foundation/Foundation.h>

@interface GameObj : NSObject

@property (nonatomic) BOOL cashGameFlg;

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *gametype;
@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSString *game;
@property (nonatomic, strong) NSString *stakes;
@property (nonatomic, strong) NSString *limit;
@property (nonatomic, strong) NSString *location;
@property (nonatomic, strong) NSString *hours;
@property (nonatomic, strong) NSString *daytime;
@property (nonatomic, strong) NSString *month;
@property (nonatomic, strong) NSString *weekday;
@property (nonatomic, strong) NSString *year;
@property (nonatomic, strong) NSString *notes;
@property (nonatomic, strong) NSString *tournamentType;

@property (nonatomic, strong) NSDate *startTime;
@property (nonatomic, strong) NSDate *endTime;
@property (nonatomic, strong) NSDate *lastUpd;

@property (nonatomic) int game_id;
@property (nonatomic) int user_id;
@property (nonatomic) double profit; // winnings
@property (nonatomic) double buyInAmount;
@property (nonatomic) double cashoutAmount;
@property (nonatomic) int foodDrink;
@property (nonatomic) int tokes;
@property (nonatomic) int reBuyAmount;
@property (nonatomic) int minutes;
@property (nonatomic) int breakMinutes;
@property (nonatomic) int ppr;
@property (nonatomic) int numPlayers;
@property (nonatomic) int numRebuys;
@property (nonatomic) int tournamentFinish;
@property (nonatomic) int tournamentSpots;
@property (nonatomic) int tournamentSpotsPaid;

@property (nonatomic) BOOL onBreakFlag;

+(GameObj *)gameObjFromDBObj:(NSManagedObject *)mo;
+(GameObj *)populateGameFromString:(NSString *)line;

@end
