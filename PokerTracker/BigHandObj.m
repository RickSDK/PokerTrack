//
//  BigHandObj.m
//  PokerTracker
//
//  Created by Rick Medved on 8/5/17.
//
//

#import "BigHandObj.h"

@implementation BigHandObj

+(BigHandObj *)objectFromMO:(NSManagedObject *)mo {
	BigHandObj *obj = [[BigHandObj alloc] init];
	obj.details = [mo valueForKey:@"details"];
	obj.finalHands = [mo valueForKey:@"finalHands"];
	obj.flop = [mo valueForKey:@"flop"];
	obj.name = [mo valueForKey:@"name"];
	obj.player1Hand = [mo valueForKey:@"player1Hand"];
	obj.player2Hand = [mo valueForKey:@"player2Hand"];
	obj.player3Hand = [mo valueForKey:@"player3Hand"];
	obj.player4Hand = [mo valueForKey:@"player4Hand"];
	obj.player5Hand = [mo valueForKey:@"player5Hand"];
	obj.player6Hand = [mo valueForKey:@"player6Hand"];
	obj.player7Hand = [mo valueForKey:@"player7Hand"];
	obj.player8Hand = [mo valueForKey:@"player8Hand"];
	obj.player9Hand = [mo valueForKey:@"player9Hand"];
	obj.player10Hand = [mo valueForKey:@"player10Hand"];
	obj.postflopAction = [mo valueForKey:@"postflopAction"];
	obj.postFlopOdds = [mo valueForKey:@"postFlopOdds"];
	obj.preflopAction = [mo valueForKey:@"preflopAction"];
	obj.preFlopOdds = [mo valueForKey:@"preFlopOdds"];
	obj.river = [mo valueForKey:@"river"];
	obj.riverAction = [mo valueForKey:@"riverAction"];
	obj.riverOdds = [mo valueForKey:@"riverOdds"];
	obj.turn = [mo valueForKey:@"turn"];
	obj.turnAction = [mo valueForKey:@"turnAction"];
	obj.turnOdds = [mo valueForKey:@"turnOdds"];
	obj.winStatus = [mo valueForKey:@"winStatus"];
	
	obj.gameDate = [mo valueForKey:@"gameDate"];
	obj.lastUpd = [mo valueForKey:@"lastUpd"];
	
	obj.numPlayers = [[mo valueForKey:@"numPlayers"] intValue];
	obj.potsize = [[mo valueForKey:@"potsize"] intValue];
	obj.rating = [[mo valueForKey:@"rating"] intValue];
	
	obj.preFlopRaise = [[mo valueForKey:@"preFlopRaise"] boolValue];
	obj.button = [mo valueForKey:@"attrib02"];
	if(obj.button.length==0 || [@"(null)" isEqualToString:obj.button])
		obj.button = @"You";
	
	return obj;
}

+(void)createCard:(UIImageView *)suitImageView label:(UILabel *)label card:(NSString *)card suit:(NSString *)suit {
	label.text = card;
	suitImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"card%@.png", suit]];
}

+(void)createCard2:(UILabel *)suitlabel label:(UILabel *)label card:(NSString *)card suit:(NSString *)suit {
	label.text = card;
	if([@"s" isEqualToString:suit])
		suitlabel.text = @"♠️";
	if([@"c" isEqualToString:suit])
		suitlabel.text = @"♣️";
	if([@"h" isEqualToString:suit])
		suitlabel.text = @"♥️";
	if([@"d" isEqualToString:suit])
		suitlabel.text = @"♦️";
}

+(void)createHand:(NSString *)hand suit1:(UILabel *)suit1 label1:(UILabel *)label1 suit2:(UILabel *)suit2 label2:(UILabel *)label2 {
	NSArray *cards = [hand componentsSeparatedByString:@"-"];
	if(cards.count>1) {
		NSString *card1 = [cards objectAtIndex:0];
		NSString *card2 = [cards objectAtIndex:1];
		if(card1.length==2 && card2.length==2) {
			[BigHandObj createCard2:suit1 label:label1 card:[card1 substringToIndex:1] suit:[card1 substringFromIndex:1]];
			[BigHandObj createCard2:suit2 label:label2 card:[card2 substringToIndex:1] suit:[card2 substringFromIndex:1]];
		}
	}
}

@end
