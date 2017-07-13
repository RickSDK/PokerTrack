//
//  PlayerTrackerObj.h
//  PokerTracker
//
//  Created by Rick Medved on 7/12/17.
//
//

#import <Foundation/Foundation.h>

@interface PlayerTrackerObj : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *playerType;
@property (nonatomic, strong) NSString *location;
@property (nonatomic, strong) NSString *skillLevel;
@property (nonatomic, strong) NSString *strengths;
@property (nonatomic, strong) NSString *weaknesses;
@property (nonatomic, strong) NSString *hudPlayerType;
@property (nonatomic) int looseNum;
@property (nonatomic) int agressiveNum;
@property (nonatomic) int playerSkill;
@property (nonatomic) BOOL hudFlag;

@property (nonatomic, strong) UIImage *pic;

+(PlayerTrackerObj *)createObjWithMO:(NSManagedObject *)mo managedObjectContext:(NSManagedObjectContext *)managedObjectContext;

@end
