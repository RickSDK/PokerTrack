//
//  AppInitialVC.h
//  PokerTracker
//
//  Created by Rick Medved on 3/19/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AppInitialVC : UIViewController {
	NSManagedObjectContext *managedObjectContext;
	IBOutlet UIButton *bankrollButton;
	IBOutlet UIButton *enterButton;
	IBOutlet UILabel *liteLabel;
}

-(void)bankrollButtonClicked:(id)sender;
-(void)enterButtonClicked:(id)sender;


@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) UIButton *bankrollButton;
@property (nonatomic, strong) UIButton *enterButton;
@property (nonatomic, strong) UILabel *liteLabel;


@end
