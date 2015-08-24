//
//  CasinoAddressUpdatorVC.h
//  PokerTracker
//
//  Created by Rick Medved on 1/20/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CasinoAddressUpdatorVC : UIViewController {
	NSManagedObjectContext *managedObjectContext;
	IBOutlet UITableView *mainTableView;
	IBOutlet UILabel *casinoLabel;
	NSString *casinoName;
	NSString *casinoType;
	NSString *indianFlg;
	
	NSMutableArray *fieldArray;
	NSMutableArray *valueArray;
	
	int selection;

	IBOutlet UIImageView *activityBGView;
	IBOutlet UIActivityIndicatorView *activityIndicator;
	IBOutlet UILabel *activityLabel;

}

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) UITableView *mainTableView;
@property (nonatomic, strong) UILabel *casinoLabel;
@property (nonatomic, strong) NSString *casinoName;
@property (nonatomic, strong) NSString *casinoType;
@property (nonatomic, strong) NSString *indianFlg;

@property (nonatomic, strong) NSMutableArray *fieldArray;
@property (nonatomic, strong) NSMutableArray *valueArray;
@property (nonatomic) int selection;

@property (nonatomic, strong) UIImageView *activityBGView;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) UILabel *activityLabel;

@end


