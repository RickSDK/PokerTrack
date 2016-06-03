//
//  OnlineReviewVC.m
//  PokerTracker
//
//  Created by Rick Medved on 5/26/16.
//
//

#import "OnlineReviewVC.h"

@interface OnlineReviewVC ()

@end

@implementation OnlineReviewVC

- (void)viewDidLoad {
    [super viewDidLoad];
	
	[self setTitle:@"Review"];
	[self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.pocketfives.com/articles/poker-track-pro-robust-live-poker-tracking-smartphone-app-592116/"]]];
	
}



@end
