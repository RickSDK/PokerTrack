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
@property (nonatomic, strong) NSArray *titles;
@property (nonatomic, strong) NSArray *values;
@property (nonatomic, strong) NSArray *colors;
@property (nonatomic) float labelPercent;

+(MultiCellObj *)multiCellObjWithTitle:(NSString *)title altTitle:(NSString *)altTitle titles:(NSArray *)titles values:(NSArray *)values colors:(NSArray *)colors labelPercent:(float)labelPercent;

+(MultiCellObj *)buildsMultiLineObjWithGame:(GameObj *)gameObj;

@end
