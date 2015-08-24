//
//  MoreTrackersVC.h
//  PokerTracker
//
//  Created by Rick Medved on 6/1/13.
//
//

#import <UIKit/UIKit.h>

@interface MoreTrackersVC : UIViewController {
	NSManagedObjectContext *managedObjectContext;
    
}

- (IBAction) handsPressed: (id) sender;
- (IBAction) playersPressed: (id) sender;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end
