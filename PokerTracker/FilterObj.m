//
//  FilterObj.m
//  PokerTracker
//
//  Created by Rick Medved on 7/20/17.
//
//

#import "FilterObj.h"

@implementation FilterObj

+(FilterObj *)objectFromMO:(NSManagedObject *)mo {
	FilterObj *obj = [[FilterObj alloc] init];
	obj.button = [[mo valueForKey:@"button"] intValue];
	obj.name = [mo valueForKey:@"name"];
	obj.shortName=obj.name;
	if(obj.shortName.length>11)
		obj.shortName = [obj.shortName substringToIndex:11];

	return obj;
}

@end
