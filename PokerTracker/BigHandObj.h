//
//  BigHandObj.h
//  PokerTracker
//
//  Created by Rick Medved on 8/5/17.
//
//

#import <Foundation/Foundation.h>

@interface BigHandObj : NSObject

@property (nonatomic, strong)  NSString *details;
@property (nonatomic, strong)  NSString *finalHands;
@property (nonatomic, strong)  NSString *flop;
@property (nonatomic, strong)  NSString *name;
@property (nonatomic, strong)  NSString *player1Hand;
@property (nonatomic, strong)  NSString *player2Hand;
@property (nonatomic, strong)  NSString *player3Hand;
@property (nonatomic, strong)  NSString *player4Hand;
@property (nonatomic, strong)  NSString *player5Hand;
@property (nonatomic, strong)  NSString *player6Hand;
@property (nonatomic, strong)  NSString *player7Hand;
@property (nonatomic, strong)  NSString *player8Hand;
@property (nonatomic, strong)  NSString *player9Hand;
@property (nonatomic, strong)  NSString *player10Hand;
@property (nonatomic, strong)  NSString *postflopAction;
@property (nonatomic, strong)  NSString *postFlopOdds;
@property (nonatomic, strong)  NSString *preflopAction;
@property (nonatomic, strong)  NSString *preFlopOdds;
@property (nonatomic, strong)  NSString *river;
@property (nonatomic, strong)  NSString *riverAction;
@property (nonatomic, strong)  NSString *riverOdds;
@property (nonatomic, strong)  NSString *turn;
@property (nonatomic, strong)  NSString *turnAction;
@property (nonatomic, strong)  NSString *turnOdds;
@property (nonatomic, strong)  NSString *winStatus;
@property (nonatomic, strong)  NSString *button;

@property (nonatomic, strong)  NSDate *gameDate;
@property (nonatomic, strong)  NSDate *lastUpd;

@property (nonatomic) int numPlayers;
@property (nonatomic) int potsize;
@property (nonatomic) int rating;

@property (nonatomic) BOOL preFlopRaise;

+(BigHandObj *)objectFromMO:(NSManagedObject *)mo;
+(void)createCard:(UIImageView *)suitImageView label:(UILabel *)label card:(NSString *)card suit:(NSString *)suit;
+(void)createHand:(NSString *)hand suit1:(UILabel *)suit1 label1:(UILabel *)label1 suit2:(UILabel *)suit2 label2:(UILabel *)label2;

@end
