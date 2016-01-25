//
//  FriendAlertsVC.m
//  PokerTracker
//
//  Created by Rick Medved on 11/16/13.
//
//

#import "FriendAlertsVC.h"
#import "ProjectFunctions.h"
#import "WebServicesFunctions.h"

@interface FriendAlertsVC ()

@end

@implementation FriendAlertsVC
@synthesize saveButton, phoneField, startSwitch, updateSwitch, activityIndicator, carrierSegment;



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTitle:@"Friend Alerts"];
    
    NSLog(@"viewDidLoad");
    
    if([[ProjectFunctions getUserDefaultValue:@"cellNumber"] length]>0)
        phoneField.text=[ProjectFunctions getUserDefaultValue:@"cellNumber"];

    if([phoneField.text length]<10)
        startSwitch.enabled=NO;
    
    carrierSegment.selectedSegmentIndex = [[ProjectFunctions getUserDefaultValue:@"carrierNum"] intValue];
    
    if([@"on" isEqualToString:[ProjectFunctions getUserDefaultValue:@"toggleStr"]])
        startSwitch.on=YES;
    
    // Do any additional setup after loading the view from its nib.
}

-(void)sendMessageWebRequest
{
	@autoreleasepool {

        NSArray *nameList = [NSArray arrayWithObjects:@"Username", @"Password", @"carrierNum", @"phone", @"toggle", nil];
        NSString *toggleStr = startSwitch.on?@"on":@"off";
        NSString *carrierNum = [NSString stringWithFormat:@"%d", (int)carrierSegment.selectedSegmentIndex];
        NSArray *valueList = [NSArray arrayWithObjects:[ProjectFunctions getUserDefaultValue:@"userName"], [ProjectFunctions getUserDefaultValue:@"password"], carrierNum, phoneField.text, toggleStr, nil];
        NSString *webAddr = @"http://www.appdigity.com/poker/pokerFriendAlertCall.php";
        NSString *responseStr = [WebServicesFunctions getResponseFromServerUsingPost:webAddr fieldList:nameList valueList:valueList];
        NSLog(@"+++%@", responseStr);
	if([WebServicesFunctions validateStandardResponse:responseStr delegate:nil]) {
		[ProjectFunctions showAlertPopupWithDelegate:@"Success" message:@"Alerts Updated" delegate:self];
            [ProjectFunctions setUserDefaultValue:phoneField.text forKey:@"cellNumber"];
            [ProjectFunctions setUserDefaultValue:carrierNum forKey:@"carrierNum"];
            [ProjectFunctions setUserDefaultValue:toggleStr forKey:@"toggleStr"];
            [self endTask];
	}
    
	}
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if([self respondsToSelector:@selector(edgesForExtendedLayout)])
        [self setEdgesForExtendedLayout:UIRectEdgeBottom];
}

-(void)endTask {
	[activityIndicator stopAnimating];
    saveButton.enabled=YES;
    phoneField.enabled=YES;
    startSwitch.enabled=YES;
    updateSwitch.enabled=YES;
}

-(void)executeThreadedJob:(SEL)aSelector
{
    [activityIndicator startAnimating];
    saveButton.enabled=NO;
    phoneField.enabled=NO;
    startSwitch.enabled=NO;
    updateSwitch.enabled=NO;
	[self performSelectorInBackground:aSelector withObject:nil];
	
}



- (IBAction) savePressed: (id) sender {
    NSLog(@"save button pressed");
    if([[ProjectFunctions getUserDefaultValue:@"userName"] length]==0) {
        [ProjectFunctions showAlertPopup:@"Notice" message:@"You must be signed in to use this feature."];
        return;
    }
    if([phoneField.text length]<10)
        [ProjectFunctions showAlertPopup:@"Notice" message:@"Enter your cell number first to receive text messages"];
    else {
        [phoneField resignFirstResponder];
        [self executeThreadedJob:@selector(sendMessageWebRequest)];
    }
}

- (IBAction) startPressed: (id) sender {
    [self executeThreadedJob:@selector(sendMessageWebRequest)];
    
}

- (IBAction) updatePressed: (id) sender {
    [self executeThreadedJob:@selector(sendMessageWebRequest)];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
