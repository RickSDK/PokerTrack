//
//  GameDetailObj.h
//  PokerTracker
//
//  Created by Rick Medved on 7/7/17.
//
//

#import <Foundation/Foundation.h>

@interface GameDetailObj : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *nameId;
@property (nonatomic, strong) NSString *value;

@property (nonatomic) int type;

+(GameDetailObj *)detailObjWithName:(NSString *)name value:(NSString *)value type:(int)type;

@end
