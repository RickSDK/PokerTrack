//
//  PokerOddsFunctions.h
//  PokerTracker
//
//  Created by Rick Medved on 10/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface PokerOddsFunctions : UIViewController {

}
+(NSString *)getBurnedCardsMinusThese:(NSArray *)playerHands flop:(NSString *)flop turn:(NSString *)turn river:(NSString *)river removeIndex:(int)removeIndex;
+(NSString *)getBurnedCards:(NSArray *)playerHands flop:(NSString *)flop turn:(NSString *)turn river:(NSString *)river;
+(NSString *)getRandomCard:(NSString *)burnedCards;
+(NSString *)getRandomHand:(NSString *)burnedCards;
+(NSString *)getRandomFlop:(NSString *)burnedCards;
+(int)getFlushHandValue:(NSArray *)handValues;
+(int)determinHandStrength:(NSString *)startingHand flop:(NSString *)flop turn:(NSString *)turn river:(NSString *)river;
+(NSString *)getNameOfhandFromValue:(int)handValue;
+(NSArray *)getPlayerResultsForHand:(NSArray *)playerHands flop:(NSString *)flop turn:(NSString *)turn river:(NSString *)river includeHandString:(BOOL)includeHandString;
+(NSString *)getSeededHand:(NSString *)burnedCards seed:(int)seed;
+(NSArray *)calculateTotalsandReturnTheStrings:(NSString *)newTotals numPlayers:(int)numPlayers;
+(NSString *)getPlayerResultsTotals:(NSString *)totals playerHands:(NSArray *)playerHands flop:(NSString *)flop turn:(NSString *)turn;
+(NSArray *)getPlayerResultsForPreFlop:(NSArray *)playerHands;
+(NSArray *)getPlayerResultsForFlop:(NSArray *)playerHands flop:(NSString *)flop;
+(NSArray *)getPlayerResultsForTurn:(NSArray *)playerHands flop:(NSString *)flop turn:(NSString *)turn;


@end
