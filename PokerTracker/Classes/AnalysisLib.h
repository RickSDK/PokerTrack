//
//  AnalysisLib.h
//  PokerTracker
//
//  Created by Rick Medved on 2/7/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface AnalysisLib : NSObject {

}


+(NSString *)getAnalysisForPlayer:(NSManagedObjectContext *)managedObjectContext
						predicate:(NSPredicate *)predicate
					  displayYear:(int)displayYear
						 gameType:(NSString *)gameType
						last10Flg:(BOOL)last10Flg
					 amountRisked:(int)amountRisked
					   foodDrinks:(int)foodDrinks
							tokes:(int)tokes
					 grosssIncome:(int)grosssIncome
				   takehomeIncome:(int)takehomeIncome
						netIncome:(int)netIncome
							limit:(int)limit;

+(NSString *)getPokerQuote:(int)number;
+(NSString *)getBestTimes:(int)displayYear gameType:(NSString *)gameType moc:(NSManagedObjectContext *)managedObjectContext;

+(NSString *)openingBasedOnStats:(int)lastMonthLevel
                  thisMonthLevel:(int)thisMonthLevel
                           games:(int)games
                           month:(NSString *)month
               winningsLastMonth:(int)winningsLastMonth
               winningsThisMonth:(int)winningsThisMonth;

+(NSString *)getOpeningForTop5Games:(NSString *)opening
                           numGames:(int)numGames
                          predicate:(NSPredicate *)predicate
                                moc:(NSManagedObjectContext *)managedObjectContext
                               name:(NSString *)name;
+(NSString *)getOpeningForFirst2GamesOfMonth:(BOOL)gameWon numGames:(int)numGames streak:(int)streak monthName:(NSString *)monthName;

@end
