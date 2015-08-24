//
//  AnalysisDetailsVC.h
//  PokerTracker
//
//  Created by Rick Medved on 2/9/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AnalysisDetailsVC : UIViewController {
	NSManagedObjectContext *managedObjectContext;

}

- (IBAction) igaButtonPressed: (id) sender;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end
