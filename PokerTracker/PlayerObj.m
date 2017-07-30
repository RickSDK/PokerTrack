//
//  PlayerObj.m
//  PokerTracker
//
//  Created by Rick Medved on 7/9/17.
//
//

#import "PlayerObj.h"

@implementation PlayerObj

+(int)vpipForPlayer:(PlayerObj *)player {
	int handCount = player.foldCount+player.callCount+player.raiseCount;
	int top = player.callCount+player.raiseCount;
	int vpip = 50;
	if(handCount>0)
		vpip = top*100/handCount;
	return vpip;
}

+(int)pfrForPlayer:(PlayerObj *)player {
	int handCount = player.foldCount+player.callCount+player.raiseCount;
	int top = player.raiseCount;
	int pfr = 25;
	if(handCount>0)
		pfr = top*100/handCount;
	return pfr;
}

+(NSString *)afForPlayer:(PlayerObj *)player {
	int handCount = player.callCount+player.raiseCount;
	NSString *af = @"-";
	if(handCount>0)
		af = [NSString stringWithFormat:@"%d%%", player.raiseCount*100/handCount];
	return af;
}


@end
