//
//  GraphObject.m
//  WealthTracker
//
//  Created by Rick Medved on 7/25/15.
//  Copyright (c) 2015 Rick Medved. All rights reserved.
//

#import "GraphObject.h"

@implementation GraphObject

+(GraphObject *)graphObjectWithName:(NSString *)name amount:(double)amout rowId:(int)rowId reverseColorFlg:(BOOL)reverseColorFlg currentMonthFlg:(BOOL)currentMonthFlg {
	GraphObject *obj = [[GraphObject alloc] init];
	obj.name=name;
	obj.amount=amout;
	obj.rowId=rowId;
	obj.reverseColorFlg=reverseColorFlg;
	obj.currentMonthFlg=currentMonthFlg;
	return obj;
}

- (NSComparisonResult)compare:(GraphObject *)otherObject {
	//	NSString *amount = [NSString stringWithFormat:@"%f", self.amount];
	//	NSString *othertAmount = [NSString stringWithFormat:@"%f", otherObject.amount];
	//	return [amount compare:othertAmount];
	//	return [[NSNumber numberWithDouble:self.amount] compare:[NSNumber numberWithDouble:otherObject.amount]];
	return [[NSNumber numberWithDouble:otherObject.amount] compare:[NSNumber numberWithDouble:self.amount]];
}

@end
