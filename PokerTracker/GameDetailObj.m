//
//  GameDetailObj.m
//  PokerTracker
//
//  Created by Rick Medved on 7/7/17.
//
//

#import "GameDetailObj.h"

@implementation GameDetailObj

+(GameDetailObj *)detailObjWithName:(NSString *)name value:(NSString *)value type:(int)type {
	GameDetailObj *obj = [[GameDetailObj alloc] init];
	obj.name = name;
	obj.value = value;
	obj.type = type;
	return obj;
}

@end
