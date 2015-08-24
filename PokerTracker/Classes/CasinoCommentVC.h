//
//  CasinoCommentVC.h
//  PokerTracker
//
//  Created by Rick Medved on 1/23/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CasinoCommentVC : UIViewController {
	NSManagedObjectContext *managedObjectContext;
	IBOutlet UILabel *nameLabel;
	IBOutlet UITextView *textView;

	IBOutlet UIImageView *activityBGView;
	IBOutlet UIActivityIndicatorView *activityIndicator;
	IBOutlet UILabel *activityLabel;


	NSString *casino;
	int casino_id;
	UIBarButtonItem *submitButton;
}

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UITextView *textView;

@property (nonatomic, strong) UIImageView *activityBGView;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) UILabel *activityLabel;

@property (nonatomic, strong) NSString *casino;
@property (nonatomic) int casino_id;

@property (nonatomic, strong) UIBarButtonItem *submitButton;

@end
