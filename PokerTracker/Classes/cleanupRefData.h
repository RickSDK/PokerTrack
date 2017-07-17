//
//  cleanupRefData.h
//  PokerTracker
//
//  Created by Rick Medved on 5/22/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TemplateVC.h"


@interface cleanupRefData : TemplateVC {
	NSManagedObjectContext *managedObjectContext;

}

- (IBAction) cleanupPressed: (id) sender;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end
