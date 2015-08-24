//
//  CoreDataLib.h
//  PokerTracker
//
//  Created by Rick Medved on 10/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CoreDataLib : UIViewController {

}

+(UIColor *)getFieldColor:(int)value;
+(NSArray *)selectRowsFromTable:(NSString *)entityName mOC:(NSManagedObjectContext *)mOC;
+(NSArray *)selectRowsFromEntity:(NSString *)entityName predicate:(NSPredicate *)predicate sortColumn:(NSString *)sortColumn mOC:(NSManagedObjectContext *)mOC ascendingFlg:(BOOL)ascendingFlg;
+(NSArray *)selectRowsFromEntityWithLimit:(NSString *)entityName predicate:(NSPredicate *)predicate sortColumn:(NSString *)sortColumn mOC:(NSManagedObjectContext *)mOC ascendingFlg:(BOOL)ascendingFlg limit:(int)limit;
+(void)dumpContentsOfTable:(NSString *)entityName mOC:(NSManagedObjectContext *)mOC key:(NSString *)key;
+(NSString *)getGameStat:(NSManagedObjectContext *)mOC dataField:(NSString *)dataField predicate:(NSPredicate *)predicate;
+(NSString *)getGameStatWithLimit:(NSManagedObjectContext *)mOC dataField:(NSString *)dataField predicate:(NSPredicate *)predicate limit:(int)limit;
+(NSString *)getThisGameStat:(NSManagedObjectContext *)mOC dataField:(NSString *)dataField items:(NSArray *)items;
+(BOOL) insertAttributeManagedObject:(NSString *)entityName valueList:(NSArray *)valueList mOC:(NSManagedObjectContext *)mOC;
+(NSManagedObject *)insertManagedObjectForEntity:(NSString *)entityName valueList:(NSArray *)valueList mOC:(NSManagedObjectContext *)mOC;
+(BOOL) insertManagedObject:(NSString *)entityName keyList:(NSArray *)keyList valueList:(NSArray *)valueList typeList:(NSArray *)typeList mOC:(NSManagedObjectContext *)mOC;
+(BOOL) updateManagedObject:(NSManagedObject *)newManagedObject keyList:(NSArray *)keyList valueList:(NSArray *)valueList typeList:(NSArray *)typeList mOC:(NSManagedObjectContext *)mOC;
+(BOOL)updateManagedObjectForEntity:(NSManagedObject *)mo entityName:(NSString *)entityName valueList:(NSArray *)valueList mOC:(NSManagedObjectContext *)mOC;

+(NSString *)getFieldValueForEntity:(NSManagedObjectContext *)mOC entityName:(NSString *)entityName field:(NSString *)field predString:(NSString *)predString indexPathRow:(int)indexPathRow;
+(NSString *)getFieldValueForEntityWithPredicate:(NSManagedObjectContext *)mOC entityName:(NSString *)entityName field:(NSString *)field predicate:(NSPredicate *)predicate indexPathRow:(int)indexPathRow;
+(NSArray *)getEntityNameList:(NSString *)entityName mOC:(NSManagedObjectContext *)mOC;
+(NSArray *)getFieldList:(NSString *)name mOC:(NSManagedObjectContext *)mOC addAllTypesFlg:(BOOL)addAllTypesFlg;
+(int)calculateActiveYearsPlaying:(NSManagedObjectContext *)mOC;
+(BOOL)insertOrUpdateManagedObjectForEntity:(NSString *)entityName valueList:(NSArray *)valueList mOC:(NSManagedObjectContext *)mOC predicate:(NSPredicate *)predicate;
+(int)updateStreak:(int)streak winAmount:(int)winAmount;
+(int)updateWinLoss:(int)gameCount winAmount:(int)winAmount winFlag:(BOOL)winFlag;
+(NSString *)getGameString:(int)wins losses:(int)losses;
+(NSString *)getStandardDeviation:(NSManagedObjectContext *)mOC items:(NSArray *)items amount:(int)amount targetDev:(int)targetDev type:(int)type;
+(NSManagedObjectContext *)getLocalContext;


@end
