//
//  ForumVC.h
//  PokerTracker
//
//  Created by Rick Medved on 6/1/13.
//
//

#import <UIKit/UIKit.h>
#import "TemplateVC.h"

@interface ForumVC : TemplateVC <UIActionSheetDelegate> {
	IBOutlet UIActivityIndicatorView *activityIndicator;
    
    NSMutableArray *forumPostings;

}

@property (atomic, strong) NSMutableArray *forumPostings;
@property (atomic, strong) UIActivityIndicatorView *activityIndicator;

@end
