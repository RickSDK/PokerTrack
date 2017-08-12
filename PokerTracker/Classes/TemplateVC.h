//
//  TemplateVC.h
//  PokerTracker
//
//  Created by Rick Medved on 1/21/16.
//
//

#import <UIKit/UIKit.h>
#import "ProjectFunctions.h"
#import "WebServicesFunctions.h"
#import "WebServiceView.h"
#import "CustomSegment.h"
#import "GameObj.h"
#import "MultiCellObj.h"
#import "PopupView.h"
#import "GameSummaryView.h"
#import "YearChangeView.h"
#import "PtpButton.h"
#import "BankrollView.h"

@interface TemplateVC : UIViewController

@property (strong, nonatomic) IBOutlet UITextField *mainTextfield;
@property (strong, nonatomic) IBOutlet UITableView *mainTableView;

@property (strong, nonatomic) IBOutlet PopupView *popupView;
@property (strong, nonatomic) IBOutlet CustomSegment *mainSegment;
@property (strong, nonatomic) IBOutlet CustomSegment *ptpGameSegment;
@property (strong, nonatomic) IBOutlet WebServiceView *webServiceView;
@property (strong, nonatomic) IBOutlet YearChangeView *yearChangeView;
@property (strong, nonatomic) IBOutlet BankrollView *bankrollView;
@property (nonatomic, strong) IBOutlet GameSummaryView *gameSummaryView;

@property (strong, nonatomic) UIImageView *bgImageView;
@property (strong, nonatomic) NSMutableArray *webServiceElements;
@property (strong, nonatomic) NSMutableArray *textFieldElements;
@property (strong, nonatomic) NSMutableArray *mainArray;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (strong, nonatomic) GameObj *gameObj;
@property (strong, nonatomic) MultiCellObj *multiCellObj;

@property (nonatomic) float startDegree;

-(void)startWebService:(SEL)aSelector message:(NSString *)message;
-(void)stopWebService;
-(void)resignResponders;
-(void)addHomeButton;
-(void)saveDatabase;
-(void)populatePopupWithTitle:(NSString *)title text:(NSString *)text;
-(void)changeNavToIncludeType:(int)type;
-(void)changeNavToIncludeType:(int)type title:(NSString *)title;
-(NSString *)updateTitleForBar:(UISegmentedControl *)segment title:(NSString *)title type:(int)type;
- (IBAction) segmentChanged: (id) sender;
- (IBAction) ptpGameSegmentChanged: (id) sender;
- (IBAction) xButtonClicked: (id) sender;
-(BOOL)isPokerZilla;
-(void)bankrollSegmentChanged;
-(void)checkBankrollSegment;

@end
