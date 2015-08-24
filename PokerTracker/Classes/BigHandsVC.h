//
//  BigHandsVC.h
//  PokerTracker
//
//  Created by Rick Medved on 10/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface BigHandsVC : UIViewController {
	//---Passed In----------------------------
    NSManagedObjectContext *managedObjectContext;
	BOOL showMainMenuButton;
	IBOutlet UITableView *mainTableView;
	
	//---XIB----------------------------
	//---Gloabls----------------------------
	NSMutableArray *bigHands;

}
@property (nonatomic) BOOL showMainMenuButton;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, strong) NSMutableArray *bigHands;
@property (nonatomic, strong) UITableView *mainTableView;

@end
