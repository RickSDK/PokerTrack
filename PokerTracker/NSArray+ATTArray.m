//
//  NSArray+ATTArray.m
//  PokerTracker
//
//  Created by Rick Medved on 11/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NSArray+ATTArray.h"

@implementation NSArray (ATTArray)

-(NSString *)stringAtIndex:(int)index
{
	// this function fixes two problems inherent in object c arrays:
	// 1) returns a string even if the array is out of range
	// 2) returns a copy of the value rather than a pointer to the array
	
	if([self count]>index)
		return [NSString stringWithFormat:@"%@", [self objectAtIndex:index]];
	else 
		return @"-outOfRange-";
}

@end
