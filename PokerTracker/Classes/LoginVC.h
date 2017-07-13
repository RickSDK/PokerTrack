//
//  LoginVC.h
//  PokerTracker
//
//  Created by Rick Medved on 10/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebServiceView.h"
#import "TemplateVC.h"


@interface LoginVC : TemplateVC {
	//---Passed In----------------------------
    NSManagedObjectContext *managedObjectContext;
	//---XIB----------------------------
	IBOutlet UITextField *loginEmail;
	IBOutlet UITextField *loginPassword;
	IBOutlet UIButton *loginButton;
	IBOutlet UIButton *forgotButton;

	IBOutlet UIButton *rickButton;
	IBOutlet UIButton *robbButton;
	IBOutlet UIButton *testButton;

	//---Gloabls----------------------------
	
}



- (IBAction) rickPressed: (id) sender;
- (IBAction) robbPressed: (id) sender;
- (IBAction) testPressed: (id) sender;
- (IBAction) loginPressed: (id) sender;
- (IBAction) forgotPressed: (id) sender;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, strong) UITextField *loginEmail;
@property (nonatomic, strong) UITextField *loginPassword;
@property (nonatomic, strong) UIButton *loginButton;
@property (nonatomic, strong) UIButton *forgotButton;

@property (nonatomic, strong) IBOutlet WebServiceView *webServiceView;

@property (nonatomic, strong) UIButton *rickButton;
@property (nonatomic, strong) UIButton *robbButton;
@property (nonatomic, strong) UIButton *testButton;



@end
