//
//  Top5VC.h
//  PokerTracker
//
//  Created by Rick Medved on 3/9/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface Top5VC : UIViewController {
	NSManagedObjectContext *managedObjectContext;

	IBOutlet UITableView *mainTableView;
	
	NSMutableArray *bestGames;
	NSMutableArray *worstGames;
}

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) UITableView *mainTableView;
@property (nonatomic, strong) NSMutableArray *bestGames;
@property (nonatomic, strong) NSMutableArray *worstGames;

@end
