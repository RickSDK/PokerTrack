//
//  EditPlayerTracker.h
//  PokerTracker
//
//  Created by Rick Medved on 1/16/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TemplateVC.h"
#import "PlayerTrackerObj.h"

@interface EditPlayerTracker : TemplateVC <UIActionSheetDelegate> {
	NSManagedObjectContext *managedObjectContext;
	UIViewController *callBackViewController;
	NSManagedObject *managedObject;
	NSString *casino;
	
	IBOutlet UITextField *nameField;
	IBOutlet UISegmentedControl *looseTightSeg;
	IBOutlet UISegmentedControl *passAgrSeg;
	IBOutlet UISegmentedControl *overallPlaySeg;
	IBOutlet UIButton *casinoButton;
	IBOutlet UIButton *deleteButton;
	IBOutlet UIImageView *playerPic;
	IBOutlet UILabel *picLabel;
	IBOutlet UILabel *typeLabel;
	IBOutlet UILabel *skillLabel;
	IBOutlet UILabel *hudStyleLabel;
	IBOutlet UILabel *playerNumLabel;

	UIBarButtonItem *saveButton;
	int selectedObjectForEdit;
//	int user_id;
	BOOL readOnlyFlg;
	BOOL showMenuFlg;
}

- (IBAction) casinoButtonPressed: (id) sender;
- (IBAction) savePressed: (id) sender;
- (IBAction) deletePressed: (id) sender;
- (IBAction) segmentPressed:(id)sender;
- (IBAction) hudButtonPressed: (id) sender;
- (IBAction) plusMinusButtonPressed: (UIButton *) button;
-(void)updateImage;


@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSManagedObject *managedObject;
@property (nonatomic, strong) PlayerTrackerObj *playerTrackerObj;
@property (nonatomic, strong) UIViewController *callBackViewController;
@property (nonatomic, strong) NSString *casino;
@property (nonatomic, strong) UITextField *nameField;
@property (nonatomic, strong) UISegmentedControl *looseTightSeg;
@property (nonatomic, strong) UISegmentedControl *passAgrSeg;
@property (nonatomic, strong) UISegmentedControl *overallPlaySeg;
@property (nonatomic, strong) UIButton *casinoButton;
@property (nonatomic, strong) UIButton *deleteButton;
@property (nonatomic, strong) UIImageView *playerPic;
@property (nonatomic, strong) UILabel *picLabel;
@property (nonatomic, strong) UILabel *typeLabel;
@property (nonatomic, strong) UILabel *skillLabel;
@property (nonatomic, strong) UILabel *playerNumLabel;
@property (nonatomic, strong) UILabel *hudStyleLabel;

@property (nonatomic, strong) IBOutlet UIImageView *playerTypeImageView;
@property (nonatomic, strong) IBOutlet UIImageView *hudPlayerTypeImageView;
@property (nonatomic, strong) IBOutlet UIButton *hudButton;
@property (nonatomic, strong) IBOutlet UIImageView *bgImage1;
@property (nonatomic, strong) IBOutlet UIImageView *bgImage2;
@property (nonatomic, strong) IBOutlet UIView *bar1;
@property (nonatomic, strong) IBOutlet UIView *bar2;
@property (nonatomic, strong) IBOutlet UIButton *minusButton1;
@property (nonatomic, strong) IBOutlet UIButton *plusButton1;
@property (nonatomic, strong) IBOutlet UIButton *minusButton2;
@property (nonatomic, strong) IBOutlet UIButton *plusButton2;


@property (nonatomic, strong) UIBarButtonItem *saveButton;
@property (nonatomic) int selectedObjectForEdit;
//@property (nonatomic) int user_id;
@property (nonatomic) BOOL readOnlyFlg;
@property (nonatomic) BOOL showMenuFlg;



@end
