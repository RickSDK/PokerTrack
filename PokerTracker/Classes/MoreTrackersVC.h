//
//  MoreTrackersVC.h
//  PokerTracker
//
//  Created by Rick Medved on 6/1/13.
//
//

#import <UIKit/UIKit.h>
#import "TemplateVC.h"

@interface MoreTrackersVC : TemplateVC {
	
}

- (IBAction) buttonPressed: (UIButton *) button;


@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) IBOutlet UIButton *playerTrackerButton;
@property (nonatomic, strong) IBOutlet UIButton *handTrackerButton;
@property (nonatomic, strong) IBOutlet UIButton *hudTrackerButton;

@end
