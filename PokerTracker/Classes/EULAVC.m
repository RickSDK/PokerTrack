//
//  EULAVC.m
//  Draw Me!
//
//  Created by Rick Medved on 9/15/14.
//  Copyright (c) 2014 Rick Medved. All rights reserved.
//

#import "EULAVC.h"

@interface EULAVC ()

@end

@implementation EULAVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if([self respondsToSelector:@selector(edgesForExtendedLayout)])
		[self setEdgesForExtendedLayout:UIRectEdgeBottom];
	
}



- (void)viewDidLoad
{
    [super viewDidLoad];
	[self setTitle:@"Privacy Policy"];
	
	self.mainTextView.text = @"Poker Track Pro EULA\n\nPrivacy Guarantee: PTP will never sell or share your personal information with any other third party vendor.\n\nEmail address is only used to reset lost passwords and is never shared with any user.\n\nFirst name and some poker stats may be shared with other users in the Net Tracker unless you choose not to participate.\n\nAll users have the option of not sharing any of their info.";
	
    // Do any additional setup after loading the view from its nib.
}




@end
