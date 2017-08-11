//
//  ForumCreateVC.h
//  PokerTracker
//
//  Created by Rick Medved on 6/3/13.
//
//

#import <UIKit/UIKit.h>
#import "TemplateVC.h"

@interface ForumCreateVC : TemplateVC {
	IBOutlet UILabel *categoryLabel;
 	IBOutlet UIActivityIndicatorView *activityIndicator;
    IBOutlet UIImageView *actImageView;
    IBOutlet UITextField *titleTextField;
    IBOutlet UITextView *bodyTextView;

    
    int category;
    int postId;
    NSString *postStr;
    UIBarButtonItem *postButton;
   
}

@property (atomic) int category;
@property (atomic) int postId;
@property (atomic, strong) UILabel *categoryLabel;
@property (atomic, strong) UIBarButtonItem *postButton;
@property (atomic, strong) UIActivityIndicatorView *activityIndicator;
@property (atomic, strong) UIImageView *actImageView;

@property (atomic, strong) UITextField *titleTextField;
@property (atomic, strong) UITextView *bodyTextView;
@property (atomic, copy) NSString *postStr;

@end
