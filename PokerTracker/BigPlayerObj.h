//
//  BigPlayerObj.h
//  PokerTracker
//
//  Created by Rick Medved on 8/6/17.
//
//

#import <Foundation/Foundation.h>

@interface BigPlayerObj : NSObject

@property (nonatomic, strong)  NSString *name;
@property (nonatomic, strong)  NSString *hand;
@property (nonatomic, strong)  NSString *preflopOdds;
@property (nonatomic, strong)  NSString *flopOdds;
@property (nonatomic, strong)  NSString *turnOdds;
@property (nonatomic, strong)  NSString *finalOdds;

@property (nonatomic, strong)  NSString *preflopHand;
@property (nonatomic, strong)  NSString *flopHand;
@property (nonatomic, strong)  NSString *turnHand;
@property (nonatomic, strong)  NSString *finalHand;

@property (nonatomic, strong)  NSString *preflopAction;
@property (nonatomic, strong)  NSString *flopAction;
@property (nonatomic, strong)  NSString *turnAction;
@property (nonatomic, strong)  NSString *finalAction;

@property (nonatomic)  int playerNum;

@property (nonatomic)  float startingChips;
@property (nonatomic)  float preflopBet;
@property (nonatomic)  float flopBet;
@property (nonatomic)  float turnBet;
@property (nonatomic)  float finalBet;

@property (nonatomic)  BOOL winFlg;
@property (nonatomic)  BOOL buttonFlg;

@end
