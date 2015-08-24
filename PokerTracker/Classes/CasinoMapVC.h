//
//  CasinoMapVC.h
//  PokerTracker
//
//  Created by Rick Medved on 2/3/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CasinoMapVC : UIViewController {
	NSManagedObjectContext *managedObjectContext;
	IBOutlet UIWebView *webView;

	NSString *casino;
}

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) NSString *casino;

@end
