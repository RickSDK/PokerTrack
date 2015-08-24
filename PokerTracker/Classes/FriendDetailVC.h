//
//  FriendDetailVC.h
//  PokerTracker
//
//  Created by Rick Medved on 10/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface FriendDetailVC : UIViewController {
 	//---Passed In----------------------------
	NSManagedObjectContext *managedObjectContext;
	NSManagedObject *mo;

	//---XIB----------------------------
	IBOutlet UITableView *mainTableView;
	IBOutlet UISegmentedControl *yearSegment;
	IBOutlet UIActivityIndicatorView *activityIndicator;
	IBOutlet UIImageView *imageViewBG;
	IBOutlet UILabel *activityLabel;
	IBOutlet UILabel *userLabel;
	IBOutlet UILabel *emailLabel;
	IBOutlet UIButton *removeButton;
	IBOutlet UIButton *sendMessageButton;

	//---Gloabls----------------------------
	NSMutableArray *friendGames;
	int displayYear;
	int processForm;
	
	
}

- (IBAction) segmentChanged: (id) sender;
- (IBAction) messageButtonPressed: (id) sender;
- (IBAction) removeButtonPressed: (id) sender;

@property (nonatomic, strong) UITableView *mainTableView;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSManagedObject *mo;

@property (nonatomic, strong) UISegmentedControl *yearSegment;
@property (nonatomic) int displayYear;
@property (nonatomic) int processForm;

@property (nonatomic, strong) NSMutableArray *friendGames;

@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) UIImageView *imageViewBG;
@property (nonatomic, strong) UILabel *activityLabel;
@property (nonatomic, strong) UILabel *userLabel;
@property (nonatomic, strong) UILabel *emailLabel;

@property (nonatomic, strong) UIButton *removeButton;
@property (nonatomic, strong) UIButton *sendMessageButton;

 
@end

