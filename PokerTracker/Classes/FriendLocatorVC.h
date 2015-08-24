//
//  FriendLocatorVC.h
//  PokerTracker
//
//  Created by Rick Medved on 10/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface FriendLocatorVC : UIViewController {
 	//---Passed In----------------------------
	NSManagedObjectContext *managedObjectContext;

	//---XIB----------------------------
	IBOutlet UITextField *email;
	IBOutlet UIActivityIndicatorView *activityIndicator;
	IBOutlet UIImageView *activityPopup;
	IBOutlet UILabel *activityLabel;
	IBOutlet UIButton *addButton;

	//---Gloabls----------------------------

}

- (IBAction) addFriendPressed: (id) sender;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) IBOutlet UITextField *email;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) UILabel *activityLabel;

@property (nonatomic, strong) UIImageView *activityPopup;
@property (nonatomic, strong) UIButton *addButton;


@end
