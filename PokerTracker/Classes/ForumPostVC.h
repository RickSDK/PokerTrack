//
//  ForumPostVC.h
//  PokerTracker
//
//  Created by Rick Medved on 6/3/13.
//
//

#import <UIKit/UIKit.h>

@interface ForumPostVC : UIViewController {
    IBOutlet UITableView *mainTableView;
	IBOutlet UIActivityIndicatorView *activityIndicator;
    IBOutlet UILabel *titleLabel;
    IBOutlet UILabel *userLabel;
    IBOutlet UILabel *locationLabel;
    IBOutlet UILabel *dateLabel;
    IBOutlet UITextView *bodyTextView;
    IBOutlet UIButton *playerImageButton;
    
    NSManagedObjectContext *managedObjectContext;
    int category;
    int postId;
    int masterPostId;
    int user_id;
    int risked;
    int profit;
    BOOL postSelectedFlg;
    BOOL selectAllFlg;
    int postSelectedRow;

    NSMutableArray *forumPostings;

    NSString *postStr;
    NSString *replyBody;
    NSString *postTitle;
    NSString *postBody;
    NSString *postUser;
    NSString *postLoc;
    NSString *postDate;
    
}



- (IBAction) playerButtonPressed: (id) sender;


@property (atomic, strong) NSManagedObjectContext *managedObjectContext;
@property (atomic, strong) UITableView *mainTableView;
@property (atomic, strong) UILabel *titleLabel;
@property (atomic, strong) UILabel *userLabel;
@property (atomic, strong) UILabel *locationLabel;
@property (atomic, strong) UILabel *dateLabel;
@property (atomic, strong) UITextView *bodyTextView;

@property (atomic, strong) NSMutableArray *forumPostings;
@property (atomic, strong) UIActivityIndicatorView *activityIndicator;
@property (atomic, strong) UIButton *playerImageButton;
@property (atomic) int category;
@property (atomic) int postId;
@property (atomic) int masterPostId;
@property (atomic) int user_id;
@property (atomic) int risked;
@property (atomic) int profit;
@property (atomic) BOOL postSelectedFlg;
@property (atomic) BOOL selectAllFlg;
@property (atomic) int postSelectedRow;


@property (atomic, copy)  NSString *postStr;
@property (atomic, copy) NSString *postTitle;
@property (atomic, copy) NSString *postBody;
@property (atomic, copy) NSString *postUser;
@property (atomic, copy) NSString *postLoc;
@property (atomic, copy) NSString *postDate;
@property (atomic, copy) NSString *replyBody;


@end
