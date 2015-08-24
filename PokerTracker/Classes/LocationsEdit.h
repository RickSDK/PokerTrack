//
//  LocationsEdit.h
//  PokerTracker
//
//  Created by Rick Medved on 1/17/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface LocationsEdit : UIViewController {
	NSManagedObjectContext *managedObjectContext;
	IBOutlet UITableView *mainTableView;
	IBOutlet UIButton *deleteButton;
	
	NSMutableArray *locations;
	NSMutableArray *checkBoxes;

}

- (IBAction) deletePressed: (id) sender;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) UITableView *mainTableView;

@property (nonatomic, strong) NSMutableArray *locations;
@property (nonatomic, strong) NSMutableArray *checkBoxes;
@property (nonatomic, strong) UIButton *deleteButton;

@end
