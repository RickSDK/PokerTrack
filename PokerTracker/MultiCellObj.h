//
//  MultiCellObj.h
//  PokerTracker
//
//  Created by Rick Medved on 7/7/17.
//
//

#import <Foundation/Foundation.h>
#import "GameObj.h"

@interface MultiCellObj : NSObject

@property (nonatomic, strong) NSString *mainTitle;
@property (nonatomic, strong) NSString *altTitle;
@property (nonatomic, strong) NSMutableArray *titles;
@property (nonatomic, strong) NSMutableArray *values;
@property (nonatomic, strong) NSMutableArray *colors;
@property (nonatomic) float labelPercent;

-(void)removeAllObjects;
-(void)addLineWithTitle:(NSString *)title value:(NSString *)value color:(UIColor *)color;
-(void)addBlackLineWithTitle:(NSString *)title value:(NSString *)value;
-(void)addMoneyLineWithTitle:(NSString *)title amount:(double)amount;
-(void)addIntLineWithTitle:(NSString *)title value:(int)value color:(UIColor *)color;
-(void)addColoredLineWithTitle:(NSString *)title value:(NSString *)value amount:(double)amount;
-(void)populateObjWithGame:(GameObj *)gameObj;

+(MultiCellObj *)initWithTitle:(NSString *)mainTitle altTitle:(NSString *)altTitle labelPercent:(float)labelPercent;

+(MultiCellObj *)multiCellObjWithTitle:(NSString *)title altTitle:(NSString *)altTitle titles:(NSArray *)titles values:(NSArray *)values colors:(NSArray *)colors labelPercent:(float)labelPercent;
//+(MultiCellObj *)buildsMultiLineObjWithGame:(GameObj *)gameObj;

@end
