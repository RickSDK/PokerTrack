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

@interface TemplateVC : UIViewController

@property (strong, nonatomic) IBOutlet UITableView *mainTableView;
@property (strong, nonatomic) IBOutlet CustomSegment *mainSegment;

@property (strong, nonatomic) WebServiceView *webServiceView;
@property (strong, nonatomic) UIImageView *bgImageView;
@property (strong, nonatomic) NSMutableArray *webServiceElements;
@property (strong, nonatomic) NSMutableArray *textFieldElements;
@property (strong, nonatomic) NSMutableArray *mainArray;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;


-(void)startWebService:(SEL)aSelector message:(NSString *)message;
-(void)stopWebService;
-(void)resignResponders;
- (IBAction) segmentChanged: (id) sender;
-(BOOL)isPokerZilla;

@end
