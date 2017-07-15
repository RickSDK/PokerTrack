//
//  GraphObject.h
//  WealthTracker
//
//  Created by Rick Medved on 7/25/15.
//  Copyright (c) 2015 Rick Medved. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GraphObject : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic) int rowId;
@property (nonatomic) double amount;
@property (nonatomic) double prevAmount;
@property (nonatomic) BOOL reverseColorFlg;
@property (nonatomic) BOOL confirmFlg;
@property (nonatomic) BOOL existsFlg;
@property (nonatomic) BOOL currentMonthFlg;

+(GraphObject *)graphObjectWithName:(NSString *)name amount:(double)amout rowId:(int)rowId reverseColorFlg:(BOOL)reverseColorFlg currentMonthFlg:(BOOL)currentMonthFlg;

@end
