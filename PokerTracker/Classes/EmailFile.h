//
//  EmailFile.h
//  PokerTracker
//
//  Created by Rick Medved on 1/16/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MFMailComposeViewController.h>


@interface EmailFile : UIViewController <MFMailComposeViewControllerDelegate> {
	NSManagedObjectContext *managedObjectContext;

}

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end
