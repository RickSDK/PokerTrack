//
//  ForumCategoryVC.h
//  PokerTracker
//
//  Created by Rick Medved on 6/3/13.
//
//

#import <UIKit/UIKit.h>
#import "TemplateVC.h"

@interface ForumCategoryVC : TemplateVC {
	IBOutlet UIActivityIndicatorView *activityIndicator;
	IBOutlet UITextView *headertextView;
    
    NSMutableArray *forumPostings;
    int category;
    
}


@property (atomic, strong) NSMutableArray *forumPostings;
@property (atomic, strong) UIActivityIndicatorView *activityIndicator;
@property (atomic, strong) UITextView *headertextView;
@property (atomic) int category;



@end
