//
//  FriendLast10GamesVC.h
//  PokerTracker
//
//  Created by Rick Medved on 7/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NetUserObj.h"

@interface FriendLast10GamesVC : UIViewController {
    int user_id;
    NSString *friendName;
    NSMutableArray *gameList;
	NSManagedObjectContext *managedObjectContext;
	BOOL selfFlg;
	NetUserObj *netUserObj;
    
    IBOutlet UIActivityIndicatorView *activityIndicator;
    IBOutlet UITableView *mainTableView;
	IBOutlet UIImageView *imageViewBG;
	IBOutlet UILabel *activityLabel;

}

@property (nonatomic) int user_id;
@property (nonatomic, strong) NSString *friendName;
@property (nonatomic, strong) NSMutableArray *gameList;

@property (atomic, strong) NetUserObj *netUserObj;
@property (atomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) UIImageView *imageViewBG;
@property (nonatomic, strong) UILabel *activityLabel;
@property (nonatomic, strong) UITableView *mainTableView;
@property (atomic) BOOL selfFlg;

@end
