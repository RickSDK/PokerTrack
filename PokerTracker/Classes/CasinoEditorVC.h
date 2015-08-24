//
//  CasinoEditorVC.h
//  PokerTracker
//
//  Created by Rick Medved on 1/21/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>


@interface CasinoEditorVC : UIViewController <UIActionSheetDelegate> {
	NSManagedObjectContext *managedObjectContext;
	IBOutlet UIActivityIndicatorView *activityIndicator;
	IBOutlet UIImageView *activityPopup;
	IBOutlet UILabel *activityLabel;
	IBOutlet UITableView *mainTableView;
	
	CLLocation *currentLocation;
	IBOutlet UILabel *nameLabel;
	IBOutlet UILabel *streetLabel;
	IBOutlet UILabel *cityLabel;
	IBOutlet UILabel *phoneLabel;
	IBOutlet UIButton *phoneButton;
	IBOutlet UIButton *deleteButton;
	IBOutlet UIButton *gamesButton;
	IBOutlet UIButton *commentsButton;
	IBOutlet UIButton *repinButton;
	IBOutlet UILabel *gpsLabel;
	
	IBOutlet UIImageView *mainPic;
	
	NSString *casino;
	NSString *casinoType;
	NSString *casinoFlg;
	
	NSMutableArray *fieldArray;
	NSMutableArray *valueArray;
	NSMutableArray *gamesArray;
	NSMutableArray *commentsArray;
	
	UIBarButtonItem *editButton;
	
	int selectedRow;
	int casino_id;
	BOOL editModeOn;
	
}
+(UIImage *)getCasinoImage:(NSString *)type indianFlg:(NSString *)indianFlg;
- (IBAction) mapPressed: (id) sender;
- (IBAction) phonePressed: (id) sender;
- (IBAction) deleteButtonClicked: (id) sender;
- (IBAction) gamesPressed: (id) sender;
- (IBAction) commentsPressed: (id) sender;
- (IBAction) repinClicked: (id) sender;


@property (nonatomic, strong) UITableView *mainTableView;
@property (nonatomic, strong) CLLocation *currentLocation;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) UIImageView *activityPopup;
@property (nonatomic, strong) UILabel *activityLabel;
@property (nonatomic, strong) UIImageView *mainPic;

@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *streetLabel;
@property (nonatomic, strong) UILabel *cityLabel;
@property (nonatomic, strong) UILabel *phoneLabel;
@property (nonatomic, strong) UIButton *phoneButton;
@property (nonatomic, strong) UIButton *deleteButton;
@property (nonatomic, strong) UIButton *gamesButton;
@property (nonatomic, strong) UIButton *commentsButton;
@property (nonatomic, strong) NSString *casinoType;
@property (nonatomic, strong) NSString *casinoFlg;

@property (nonatomic, strong) NSString *casino;

@property (nonatomic, strong) NSMutableArray *fieldArray;
@property (nonatomic, strong) NSMutableArray *valueArray;
@property (nonatomic, strong) NSMutableArray *gamesArray;
@property (nonatomic, strong) NSMutableArray *commentsArray;

@property (nonatomic, strong) UIBarButtonItem *editButton;
@property (nonatomic) int selectedRow;
@property (nonatomic) int casino_id;
@property (nonatomic) BOOL editModeOn;

@property (nonatomic, strong) UIButton *repinButton;
@property (nonatomic, strong) UILabel *gpsLabel;


@end

