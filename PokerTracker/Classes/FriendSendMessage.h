//
//  FriendSendMessage.h
//  PokerTracker
//
//  Created by Rick Medved on 11/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface FriendSendMessage : UIViewController {
	//---Passed In----------------------------
    NSManagedObjectContext *managedObjectContext;
	NSManagedObject *mo;

	//---XIB----------------------------
	IBOutlet UITextView *message;
	IBOutlet UIActivityIndicatorView *activityIndicatorServer;
	IBOutlet UIImageView *textViewBG;
	IBOutlet UILabel *activityLabel;
	IBOutlet UILabel *toPersonLabel;
	IBOutlet UIButton *sendMessageButton;

	//---Gloabls----------------------------
	

}

- (IBAction) messageButtonPressed: (id) sender;


@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSManagedObject *mo;

@property (nonatomic, strong) UITextView *message;

@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorServer;
@property (nonatomic, strong) UIImageView *textViewBG;
@property (nonatomic, strong) UILabel *activityLabel;
@property (nonatomic, strong) UILabel *toPersonLabel;
@property (nonatomic, strong) UIButton *sendMessageButton;

@end
