//
//  CasinoMapVC.m
//  PokerTracker
//
//  Created by Rick Medved on 2/3/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "CasinoMapVC.h"
#import "NSArray+ATTArray.h"
#import "MapKitTut.h"

@implementation CasinoMapVC
@synthesize managedObjectContext, webView, casino;


-(void)mapsButtonClicked:(id)sender {
	NSArray *items = [casino componentsSeparatedByString:@"|"];
	MapKitTut *detailViewController = [[MapKitTut alloc] initWithNibName:@"MapKitTut" bundle:nil];
	detailViewController.lat = [[items stringAtIndex:6] floatValue];
	detailViewController.lng = [[items stringAtIndex:7] floatValue];
	detailViewController.casino=casino;
	[self.navigationController pushViewController:detailViewController animated:YES];
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	NSArray *items = [casino componentsSeparatedByString:@"|"];
	NSString *address = [NSString stringWithFormat:@"%@+%@+%@+%@", [items stringAtIndex:8], [items stringAtIndex:2], [items stringAtIndex:3], [items stringAtIndex:9]];
	NSString *urlStr = [NSString stringWithFormat:@"http://maps.google.com/maps?q=%@", [address stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];

	[self setTitle:[items stringAtIndex:1]];
	[webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]]];

	UIBarButtonItem *mapsButton = [[UIBarButtonItem alloc] initWithTitle:@"GPS Map" style:UIBarButtonItemStylePlain target:self action:@selector(mapsButtonClicked:)];
	self.navigationItem.rightBarButtonItem = mapsButton;
	
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}




@end
