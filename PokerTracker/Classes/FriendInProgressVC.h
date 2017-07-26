//
//  FriendInProgressVC.h
//  PokerTracker
//
//  Created by Rick Medved on 3/23/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NetUserObj.h"
#import "GameObj.h"
#import "TemplateVC.h"
#import "MultiCellObj.h"


@interface FriendInProgressVC : TemplateVC {
}

@property (nonatomic, strong) NSManagedObject *mo;
@property (atomic, strong) NetUserObj *netUserObj;

@property (nonatomic, strong) IBOutlet UILabel *nowPlayingLabel;
@property (nonatomic, strong) IBOutlet UILabel *lastUpdLabel;
@property (nonatomic, strong) IBOutlet UILabel *userLabel;
@property (nonatomic, strong) IBOutlet UILabel *gameTypeLabel;
@property (nonatomic, strong) MultiCellObj *multiCellObj;

@end
