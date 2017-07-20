//
//  FilterObj.h
//  PokerTracker
//
//  Created by Rick Medved on 7/20/17.
//
//

#import <Foundation/Foundation.h>

@interface FilterObj : NSObject

@property (nonatomic, strong)  NSString *name;
@property (nonatomic, strong)  NSString *shortName;
@property (nonatomic) int row_id;
@property (nonatomic) int button;

+(FilterObj *)objectFromMO:(NSManagedObject *)mo;

@end
