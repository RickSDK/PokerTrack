//
//  PlayerObj.h
//  PokerTracker
//
//  Created by Rick Medved on 7/9/17.
//
//

#import <Foundation/Foundation.h>

@interface PlayerObj : NSObject

@property (nonatomic, strong) NSString *mainTitle;

@property (nonatomic) int foldCount;
@property (nonatomic) int checkCount;
@property (nonatomic) int callCount;
@property (nonatomic) int raiseCount;
@property (nonatomic) int handCount;
@property (nonatomic) int picId;
@property (nonatomic) int looseNum;
@property (nonatomic) int agressiveNum;
@property (nonatomic) int playerId;

@property (nonatomic) int vpip;
@property (nonatomic) int pfr;
@property (nonatomic) int af;

@property (nonatomic, strong) NSString *playerStyleStr;
@property (nonatomic, strong) NSString *name;

+(int)vpipForPlayer:(PlayerObj *)player;
+(int)pfrForPlayer:(PlayerObj *)player;
+(NSString *)afForPlayer:(PlayerObj *)player;

@end
