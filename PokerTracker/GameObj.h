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
@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSString *game;
@property (nonatomic, strong) NSString *stakes;
@property (nonatomic, strong) NSString *limit;
@property (nonatomic, strong) NSString *location;
@property (nonatomic, strong) NSString *hours;

@property (nonatomic, strong) NSDate *startTime;
@property (nonatomic, strong) NSDate *endTime;

@property (nonatomic) int profit;
@property (nonatomic) int buyInAmount;
@property (nonatomic) int foodDrink;
@property (nonatomic) int reBuyAmount;
@property (nonatomic) int minutes;
@property (nonatomic) int breakMinutes;

+(GameObj *)gameObjFromDBObj:(NSManagedObject *)mo;

@end
