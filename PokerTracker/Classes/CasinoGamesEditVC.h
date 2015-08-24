//
//  CasinoGamesEditVC.h
//  PokerTracker
//
//  Created by Rick Medved on 1/21/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CasinoGamesEditVC : UIViewController {
	NSManagedObjectContext *managedObjectContext;
	UIBarButtonItem *editButton;
	NSString *casino;

	IBOutlet UILabel *nameLabel;
	IBOutlet UIButton *addNewButton;
	IBOutlet UIButton *removeButton;
	IBOutlet UITableView *mainTableView;
	IBOutlet UIActivityIndicatorView *activityIndicator;
	IBOutlet UIImageView *activityPopup;
	IBOutlet UILabel *activityLabel;
	
	NSMutableArray *gamesArray;
	NSMutableArray *checkboxes;
	
	int casino_id;

}

- (IBAction) newPressed: (id) sender;
- (IBAction) removePressed: (id) sender;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic) int casino_id;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) UIImageView *activityPopup;
@property (nonatomic, strong) UILabel *activityLabel;

@property (nonatomic, strong) UIBarButtonItem *editButton;
@property (nonatomic, strong) NSString *casino;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIButton *addNewButton;
@property (nonatomic, strong) UIButton *removeButton;
@property (nonatomic, strong) NSMutableArray *gamesArray;
@property (nonatomic, strong) NSMutableArray *checkboxes;
@property (nonatomic, strong) UITableView *mainTableView;

@end
