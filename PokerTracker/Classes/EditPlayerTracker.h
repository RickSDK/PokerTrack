//
//  EditPlayerTracker.h
//  PokerTracker
//
//  Created by Rick Medved on 1/16/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface EditPlayerTracker : UIViewController <UIActionSheetDelegate> {
	NSManagedObjectContext *managedObjectContext;
	UIViewController *callBackViewController;
	NSManagedObject *managedObject;
	NSString *casino;
	
	IBOutlet UITextField *nameField;
	IBOutlet UISegmentedControl *looseTightSeg;
	IBOutlet UISegmentedControl *passAgrSeg;
	IBOutlet UISegmentedControl *overallPlaySeg;
	IBOutlet UITextView *strengthsText;
	IBOutlet UITextView *weaknessText;
	IBOutlet UIButton *casinoButton;
	IBOutlet UIButton *sEditButton;
	IBOutlet UIButton *wEditButton;
	IBOutlet UIButton *deleteButton;
	IBOutlet UIImageView *playerPic;
	IBOutlet UILabel *picLabel;
	IBOutlet UILabel *typeLabel;
	IBOutlet UILabel *skillLabel;
	IBOutlet UILabel *playerNumLabel;
	IBOutlet UISlider *passagrSlider;
	IBOutlet UISlider *tightlooseSlider;

	UIBarButtonItem *saveButton;
	int selectedObjectForEdit;
	int user_id;
	BOOL readOnlyFlg;
	BOOL showMenuFlg;
}

- (IBAction) editSPressed: (id) sender;
- (IBAction) editWPressed: (id) sender;
- (IBAction) casinoButtonPressed: (id) sender;
- (IBAction) savePressed: (id) sender;
- (IBAction) deletePressed: (id) sender;
- (IBAction) segmentPressed:(id)sender;
- (IBAction) slider1changed:(id)sender;
- (IBAction) slider2changed:(id)sender;
-(void)updateImage;


@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSManagedObject *managedObject;
@property (nonatomic, strong) UIViewController *callBackViewController;
@property (nonatomic, strong) UISlider *passagrSlider;
@property (nonatomic, strong) UISlider *tightlooseSlider;
@property (nonatomic, strong) NSString *casino;
@property (nonatomic, strong) UITextField *nameField;
@property (nonatomic, strong) UISegmentedControl *looseTightSeg;
@property (nonatomic, strong) UISegmentedControl *passAgrSeg;
@property (nonatomic, strong) UISegmentedControl *overallPlaySeg;
@property (nonatomic, strong) UITextView *strengthsText;
@property (nonatomic, strong) UITextView *weaknessText;
@property (nonatomic, strong) UIButton *casinoButton;
@property (nonatomic, strong) UIButton *sEditButton;
@property (nonatomic, strong) UIButton *wEditButton;
@property (nonatomic, strong) UIButton *deleteButton;
@property (nonatomic, strong) UIImageView *playerPic;
@property (nonatomic, strong) UILabel *picLabel;
@property (nonatomic, strong) UILabel *typeLabel;
@property (nonatomic, strong) UILabel *skillLabel;
@property (nonatomic, strong) UILabel *playerNumLabel;

@property (nonatomic, strong) UIBarButtonItem *saveButton;
@property (nonatomic) int selectedObjectForEdit;
@property (nonatomic) int user_id;
@property (nonatomic) BOOL readOnlyFlg;
@property (nonatomic) BOOL showMenuFlg;



@end
