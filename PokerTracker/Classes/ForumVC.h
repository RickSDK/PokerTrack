//
//  ForumVC.h
//  PokerTracker
//
//  Created by Rick Medved on 6/1/13.
//
//

#import <UIKit/UIKit.h>

@interface ForumVC : UIViewController <UIActionSheetDelegate> {
    IBOutlet UITableView *mainTableView;
	IBOutlet UIActivityIndicatorView *activityIndicator;
    
    NSManagedObjectContext *managedObjectContext;
    NSMutableArray *forumPostings;

}

@property (atomic, strong) NSManagedObjectContext *managedObjectContext;
@property (atomic, strong) UITableView *mainTableView;

@property (atomic, strong) NSMutableArray *forumPostings;
@property (atomic, strong) UIActivityIndicatorView *activityIndicator;

@end
