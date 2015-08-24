//
//  GameGraphVC.h
//  PokerTracker
//
//  Created by Rick Medved on 3/1/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface GameGraphVC : UIViewController



@property (atomic, strong) NSManagedObjectContext *managedObjectContext;
@property (atomic, strong) NSManagedObject *mo;
@property (atomic, strong) IBOutlet UILabel *dateLabel;
@property (atomic, strong) IBOutlet UILabel *timeLabel;
@property (atomic, strong) IBOutlet UILabel *locationLabel;
@property (atomic, strong) IBOutlet UILabel *netLabel;
@property (atomic, strong) IBOutlet UIImageView *gamePPRView;

@property (atomic) BOOL viewEditable;
@property (atomic) BOOL showMainMenuFlg;

@property (atomic, strong) NSMutableArray *cellRowsArray;

@end
