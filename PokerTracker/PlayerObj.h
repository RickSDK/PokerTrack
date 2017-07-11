//
//  PlayerObj.h
//  PokerTracker
//
//  Created by Rick Medved on 7/9/17.
//
//

#import <Foundation/Foundation.h>

@interface PlayerObj : NSObject

@property (nonatomic, strong) NSString *mainTitle;

@property (nonatomic) int foldCount;
@property (nonatomic) int callCount;
@property (nonatomic) int raiseCount;
@property (nonatomic) int handCount;

@property (nonatomic) int vpip;
@property (nonatomic) int pfr;
@property (nonatomic) int af;

@property (nonatomic, strong) NSString *playerStyleStr;


@end
