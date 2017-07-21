//
//  AnalysisDetailsVC.h
//  PokerTracker
//
//  Created by Rick Medved on 2/9/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TemplateVC.h"

@interface AnalysisDetailsVC : TemplateVC {
	NSManagedObjectContext *managedObjectContext;

}

- (IBAction) igaButtonPressed: (id) sender;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) IBOutlet UIImageView *image0;
@property (nonatomic, strong) IBOutlet UIImageView *image1;
@property (nonatomic, strong) IBOutlet UIImageView *image2;
@property (nonatomic, strong) IBOutlet UIImageView *image3;
@property (nonatomic, strong) IBOutlet UIImageView *image4;
@property (nonatomic, strong) IBOutlet UIImageView *image5;

@end
