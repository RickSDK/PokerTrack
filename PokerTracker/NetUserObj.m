//
//  NetUserObj.m
//  PokerTracker
//
//  Created by Rick Medved on 3/23/16.
//
//

#import "NetUserObj.h"

@implementation NetUserObj

+(NetUserObj *)userObjFromString:(NSString *)line {
	NetUserObj *netUserObj = [NetUserObj new];
	NSArray *elements = [line componentsSeparatedByString:@"<xx>"];
	if(elements.count>4) {
		netUserObj.basicsStr = [elements objectAtIndex:0];
		netUserObj.last10Str = [elements objectAtIndex:1];
		netUserObj.yearStats = [elements objectAtIndex:2];
		netUserObj.monthStats = [elements objectAtIndex:3];
		netUserObj.lastGameStr = [elements objectAtIndex:4];
		
		NSArray *basicsElements = [netUserObj.basicsStr componentsSeparatedByString:@"|"];
		if(basicsElements.count>10) {
			netUserObj.name = [basicsElements objectAtIndex:0];
			netUserObj.userId = [basicsElements objectAtIndex:1];
			netUserObj.email = [basicsElements objectAtIndex:2];
			netUserObj.city = [basicsElements objectAtIndex:3];
			netUserObj.state = [basicsElements objectAtIndex:4];
			netUserObj.country = [basicsElements objectAtIndex:5];
			netUserObj.friendStatus = [basicsElements objectAtIndex:7];
			netUserObj.nowPlayingFlg = [[basicsElements objectAtIndex:8] isEqualToString:@"Y"];
			netUserObj.moneySymbol = [basicsElements objectAtIndex:9];
			netUserObj.version = [basicsElements objectAtIndex:10];
		}
		if(basicsElements.count>11)
			netUserObj.iconGroupNumber = [basicsElements objectAtIndex:11];

		NSArray *monthElements = [netUserObj.monthStats componentsSeparatedByString:@"|"];
		if(monthElements.count>6) {
			int pprInt = [[monthElements objectAtIndex:6] intValue];
			netUserObj.ppr	= [NSString stringWithFormat:@"%d", pprInt-100];
		}
	}
	if(netUserObj.country.length>0) {
		NSString *fileName = [NSString stringWithFormat:@"%@.png", netUserObj.country];
		fileName = [fileName stringByReplacingOccurrencesOfString:@" " withString:@"_"];
		netUserObj.flagImage = [UIImage imageNamed:fileName];
		if (netUserObj.flagImage) {
			netUserObj.hasFlag = YES;
		} else {
			NSLog(@"need it!: %@", fileName);
		}
	}

	return netUserObj;
}

+(NetUserObj *)friendObjFromLine:(NSString *)line {
	NetUserObj *netUserObj = [NetUserObj new];
	NSArray *elements = [line componentsSeparatedByString:@"<xx>"];
	
	if(elements.count>7) {
		netUserObj.basicsStr = [elements objectAtIndex:0];
		netUserObj.last10Str = [elements objectAtIndex:1];
		netUserObj.yearStats = [elements objectAtIndex:2];
		netUserObj.monthStats = [elements objectAtIndex:3];
		netUserObj.lastGameStr = [elements objectAtIndex:4];
		
		netUserObj.last90Days = [elements objectAtIndex:5];
		netUserObj.thisMonthGames = [elements objectAtIndex:6];
		netUserObj.last10Games = [elements objectAtIndex:7];
	}

	NSArray *basicsElements = [netUserObj.basicsStr componentsSeparatedByString:@"|"];
	netUserObj.last10Elements = [netUserObj.last10Str componentsSeparatedByString:@"|"];
	netUserObj.yearElements = [netUserObj.yearStats componentsSeparatedByString:@"|"];
	netUserObj.monthElements = [netUserObj.monthStats componentsSeparatedByString:@"|"];

	if(basicsElements.count>10) {
		netUserObj.name = [basicsElements objectAtIndex:0];
		netUserObj.userId = [basicsElements objectAtIndex:1];
		netUserObj.email = [basicsElements objectAtIndex:2];
		netUserObj.city = [basicsElements objectAtIndex:3];
		netUserObj.state = [basicsElements objectAtIndex:4];
		netUserObj.country = [basicsElements objectAtIndex:5];
		netUserObj.friendStatus = [basicsElements objectAtIndex:7];
		netUserObj.nowPlayingFlg = [[basicsElements objectAtIndex:8] isEqualToString:@"Y"];
		netUserObj.moneySymbol = [basicsElements objectAtIndex:9];
		netUserObj.version = [basicsElements objectAtIndex:10];
	}

	return netUserObj;
}

@end
