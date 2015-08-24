//
//  Last10NewVC.h
//  PokerTracker
//
//  Created by Rick Medved on 12/11/12.
//
//

#import <UIKit/UIKit.h>

@interface Last10NewVC : UIViewController
{
    NSManagedObjectContext *managedObjectContext;
	IBOutlet UITableView *mainTableView;
    
	NSMutableArray *bestGames;
	NSMutableArray *worstGames;
}

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) UITableView *mainTableView;

@property (nonatomic, strong) NSMutableArray *bestGames;
@property (nonatomic, strong) NSMutableArray *worstGames;

@end
