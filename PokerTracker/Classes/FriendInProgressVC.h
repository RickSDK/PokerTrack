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


@interface FriendInProgressVC : TemplateVC {
	NSManagedObjectContext *managedObjectContext;
	NSManagedObject *mo;
	
	IBOutlet UILabel *locationLabel;
	IBOutlet UILabel *timeLabel;
	IBOutlet UILabel *buyinLabel;
	IBOutlet UILabel *rebuyLabel;
	IBOutlet UILabel *chipsLabel;

	IBOutlet UILabel *timeRunningLabel;
	IBOutlet UILabel *profitLabel;
	IBOutlet UILabel *hourlyLabel;
	
	IBOutlet UILabel *lastUpdLabel;
	IBOutlet UILabel *currentChipsLabel;
	IBOutlet UILabel *nowPlayingLabel;
	IBOutlet UILabel *userLabel;
	IBOutlet UILabel *gameTypeLabel;
	IBOutlet UILabel *gameSpecslabel;
	
	IBOutlet UIImageView *playerTypeImg;
	IBOutlet UITableView *mainTableView;
	IBOutlet UIButton *mapButton;
	
//	NSString *userValues;
	NSString *gpsValues;
    NSString *casinoName;
    NSString *gameTypeStr;
    NSString *chipAmountString;
    NSString *chipAmountLabelString;
    NSString *profitStr;
    
    NSMutableArray *basicsArray;
	NetUserObj *netUserObj;
    BOOL profitFlg;
    BOOL playingFlg;

}

- (IBAction) mapPressed: (id) sender;


@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSManagedObject *mo;

@property (nonatomic, strong) UILabel *locationLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *buyinLabel;
@property (nonatomic, strong) UILabel *rebuyLabel;
@property (nonatomic, strong) UILabel *chipsLabel;
@property (nonatomic, strong) UILabel *currentChipsLabel;
@property (nonatomic, strong) UITableView *mainTableView;
@property (atomic, strong) NetUserObj *netUserObj;

@property (nonatomic, strong) UILabel *timeRunningLabel;
@property (nonatomic, strong) UILabel *profitLabel;
@property (nonatomic, strong) UILabel *hourlyLabel;
@property (nonatomic, strong) UILabel *lastUpdLabel;
@property (nonatomic, strong) UILabel *nowPlayingLabel;
@property (nonatomic, strong) UIImageView *playerTypeImg;
@property (nonatomic, strong) UILabel *gameTypeLabel;
@property (nonatomic, strong) UILabel *gameSpecslabel;
@property (nonatomic, strong) UILabel *userLabel;
@property (nonatomic, strong) UIButton *mapButton;

@property (nonatomic, copy) NSString *profitStr;
//@property (nonatomic, copy) NSString *userValues;
@property (nonatomic, copy) NSString *gpsValues;
@property (nonatomic, copy) NSString *casinoName;
@property (nonatomic, copy) NSString *gameTypeStr;
@property (nonatomic, copy) NSString *chipAmountString;
@property (nonatomic, copy) NSString *chipAmountLabelString;

@property (nonatomic, strong) NSMutableArray *basicsArray;
@property (nonatomic, strong) NSMutableArray *profitArray;
@property (nonatomic) BOOL profitFlg;
@property (nonatomic) BOOL playingFlg;



@end
