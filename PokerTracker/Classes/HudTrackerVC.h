//
//  HudTrackerVC.h
//  PokerTracker
//
//  Created by Rick Medved on 7/9/17.
//
//

#import "TemplateVC.h"
#import "PlayerObj.h"
#import "HudStatObj.h"
#import "HudActionObj.h"

@interface HudTrackerVC : TemplateVC


@property (nonatomic, strong) IBOutlet UIView *hudView;

@property (nonatomic, strong) IBOutlet UIButton *vpipInfoButton;
@property (nonatomic, strong) IBOutlet UILabel *vpipPercentLabel1;
@property (nonatomic, strong) IBOutlet UILabel *vpipPercentLabel2;
@property (nonatomic, strong) IBOutlet UILabel *vpipCountLabel1;
@property (nonatomic, strong) IBOutlet UILabel *vpipCountLabel2;
@property (nonatomic, strong) IBOutlet UIImageView *vpipBGImageView;
@property (nonatomic, strong) IBOutlet UIImageView *vpipPlayerType1ImageView;
@property (nonatomic, strong) IBOutlet UIImageView *vpipPlayerType2ImageView;
@property (nonatomic, strong) IBOutlet UIView *vpipBarView1;
@property (nonatomic, strong) IBOutlet UIView *vpipBarView2;

@property (nonatomic, strong) IBOutlet UIButton *pfrInfoButton;
@property (nonatomic, strong) IBOutlet UILabel *pfrPercentLabel1;
@property (nonatomic, strong) IBOutlet UILabel *pfrPercentLabel2;
@property (nonatomic, strong) IBOutlet UILabel *pfrCountLabel1;
@property (nonatomic, strong) IBOutlet UILabel *pfrCountLabel2;
@property (nonatomic, strong) IBOutlet UIImageView *pfrBGImageView;
@property (nonatomic, strong) IBOutlet UIImageView *pfrPlayerType1ImageView;
@property (nonatomic, strong) IBOutlet UIImageView *pfrPlayerType2ImageView;
@property (nonatomic, strong) IBOutlet UIView *pfrBarView1;
@property (nonatomic, strong) IBOutlet UIView *pfrBarView2;

@property (nonatomic, strong) IBOutlet UIButton *afInfoButton;
@property (nonatomic, strong) IBOutlet UILabel *afPercentLabel1;
@property (nonatomic, strong) IBOutlet UILabel *afPercentLabel2;
@property (nonatomic, strong) IBOutlet UILabel *afCountLabel1;
@property (nonatomic, strong) IBOutlet UILabel *afCountLabel2;
@property (nonatomic, strong) IBOutlet UIImageView *afBGImageView;
@property (nonatomic, strong) IBOutlet UIImageView *afPlayerType1ImageView;
@property (nonatomic, strong) IBOutlet UIImageView *afPlayerType2ImageView;
@property (nonatomic, strong) IBOutlet UIView *afBarView1;
@property (nonatomic, strong) IBOutlet UIView *afBarView2;
@property (nonatomic, strong) IBOutlet UILabel *afAmountLabel1;
@property (nonatomic, strong) IBOutlet UILabel *afAmountLabel2;


@property (nonatomic, strong) IBOutlet UIButton *trashbutton1;
@property (nonatomic, strong) IBOutlet UILabel *foldCountLabel1;
@property (nonatomic, strong) IBOutlet UILabel *checkCountLabel1;
@property (nonatomic, strong) IBOutlet UILabel *callCountLabel1;
@property (nonatomic, strong) IBOutlet UILabel *raiseCountLabel1;
@property (nonatomic, strong) IBOutlet UILabel *styleLabel1;
@property (nonatomic, strong) IBOutlet UIImageView *skillImageView1;
@property (nonatomic, strong) IBOutlet UIButton *foldButton1;
@property (nonatomic, strong) IBOutlet UIButton *checkButton1;
@property (nonatomic, strong) IBOutlet UIButton *callButton1;
@property (nonatomic, strong) IBOutlet UIButton *raiseButton1;

@property (nonatomic, strong) IBOutlet UIButton *trashbutton2;
@property (nonatomic, strong) IBOutlet UILabel *foldCountLabel2;
@property (nonatomic, strong) IBOutlet UILabel *checkCountLabel2;
@property (nonatomic, strong) IBOutlet UILabel *callCountLabel2;
@property (nonatomic, strong) IBOutlet UILabel *raiseCountLabel2;
@property (nonatomic, strong) IBOutlet UILabel *styleLabel2;
@property (nonatomic, strong) IBOutlet UIImageView *skillImageView2;
@property (nonatomic, strong) IBOutlet UIButton *foldButton2;
@property (nonatomic, strong) IBOutlet UIButton *checkButton2;
@property (nonatomic, strong) IBOutlet UIButton *callButton2;
@property (nonatomic, strong) IBOutlet UIButton *raiseButton2;

@property (nonatomic, strong) IBOutlet UILabel *editModeLabel2;
@property (nonatomic, strong) IBOutlet UILabel *villianActionLabel;

@property (nonatomic, strong) PlayerObj *heroObj;
@property (nonatomic, strong) PlayerObj *villianObj;
@property (nonatomic, strong) PlayerObj *selectedPlayerObj;
@property (nonatomic, strong) HudStatObj *vpipObj;
@property (nonatomic, strong) HudStatObj *pfrObj;
@property (nonatomic, strong) HudStatObj *afObj;
@property (nonatomic, strong) HudActionObj *heroActionObj;
@property (nonatomic, strong) HudActionObj *villianActionObj;
@property (atomic, strong) NSManagedObject *gameMo;
@property (atomic, strong) NSManagedObject *playerMo;
@property (atomic) BOOL editMode;
@property (atomic) BOOL defaultButtonLock;
@property (atomic) int selectedTag;

- (IBAction) buttonPressed1: (UIButton *) button;
- (IBAction) buttonPressed2: (UIButton *) button;
- (IBAction) trashButtonPressed1: (UIButton *) button;
- (IBAction) trashButtonPressed2: (UIButton *) button;

@end
