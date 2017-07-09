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

@interface TemplateVC : UIViewController

@property (strong, nonatomic) IBOutlet UIView *popupView;
@property (strong, nonatomic) IBOutlet UITextField *mainTextfield;
@property (strong, nonatomic) IBOutlet UITableView *mainTableView;
@property (strong, nonatomic) IBOutlet CustomSegment *mainSegment;

@property (strong, nonatomic) IBOutlet WebServiceView *webServiceView;
@property (strong, nonatomic) UIImageView *bgImageView;
@property (strong, nonatomic) NSMutableArray *webServiceElements;
@property (strong, nonatomic) NSMutableArray *textFieldElements;
@property (strong, nonatomic) NSMutableArray *mainArray;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) GameObj *gameObj;
@property (strong, nonatomic) MultiCellObj *multiCellObj;


-(void)startWebService:(SEL)aSelector message:(NSString *)message;
-(void)stopWebService;
-(void)resignResponders;
- (IBAction) segmentChanged: (id) sender;
- (IBAction) xButtonClicked: (id) sender;
-(BOOL)isPokerZilla;

@end
