//
//  FriendLast10GamesVC.h
//  PokerTracker
//
//  Created by Rick Medved on 7/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NetUserObj.h"
#import "TemplateVC.h"

@interface FriendLast10GamesVC : TemplateVC {
    NSMutableArray *gameList;
	BOOL selfFlg;
	NetUserObj *netUserObj;
}

@property (nonatomic, strong) NSMutableArray *gameList;

@property (atomic, strong) NetUserObj *netUserObj;
@property (atomic) BOOL selfFlg;

@end
