//
//  TauntVC.m
//  PokerTracker
//
//  Created by Rick Medved on 6/14/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "TauntVC.h"
#import "SoundsLib.h"


@implementation TauntVC

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/


-(void)playButtonClicked:(id)sender {
	[SoundsLib PlaySound:@"donkey" type:@"wav"];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	[self setTitle:@"Donkey Play!"];
	[SoundsLib PlaySound:@"donkey" type:@"wav"];

    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Play" style:UIBarButtonItemStylePlain target:self action:@selector(playButtonClicked:)];
    self.navigationItem.rightBarButtonItem = rightButton;

}





@end
