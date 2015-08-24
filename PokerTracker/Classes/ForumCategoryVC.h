//
//  ForumCategoryVC.h
//  PokerTracker
//
//  Created by Rick Medved on 6/3/13.
//
//

#import <UIKit/UIKit.h>

@interface ForumCategoryVC : UIViewController {
    IBOutlet UITableView *mainTableView;
	IBOutlet UIActivityIndicatorView *activityIndicator;
	IBOutlet UITextView *headertextView;
    
    NSManagedObjectContext *managedObjectContext;
    NSMutableArray *forumPostings;
    int category;
    
}

@property (atomic, strong) NSManagedObjectContext *managedObjectContext;
@property (atomic, strong) UITableView *mainTableView;

@property (atomic, strong) NSMutableArray *forumPostings;
@property (atomic, strong) UIActivityIndicatorView *activityIndicator;
@property (atomic, strong) UITextView *headertextView;
@property (atomic) int category;



@end
