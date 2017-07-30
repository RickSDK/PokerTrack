//
//  MainMenuVC.h
//  PokerTracker
//
//  Created by Rick Medved on 10/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>
#import "TemplateVC.h"
#import "PopupView.h"


@interface MainMenuVC : UIViewController {
	//---Passed In----------------------------
    NSManagedObjectContext *managedObjectContext;
	
	//---XIB----------------------------
	IBOutlet UIButton *statsButton;
	IBOutlet UIButton *gamesButton;
	IBOutlet UIButton *oddsButton;
	IBOutlet UIButton *moreTrackersButton;
	IBOutlet UIButton *forumButton;
	IBOutlet UIButton *netTrackerButton;
	IBOutlet UIButton *startNewGameButton;
	IBOutlet UIButton *reviewButton;
	IBOutlet UIButton *analysisButton;
	IBOutlet UIButton *casinoButton;
	IBOutlet UIButton *editButton;

	IBOutlet UIButton *emailButton;
	IBOutlet UILabel *yearLabel;
	IBOutlet UILabel *openGamesLabel;
	IBOutlet UILabel *versionLabel;
	IBOutlet UILabel *bankrollLabel;
	IBOutlet UILabel *bankrollNameLabel;
	IBOutlet UILabel *smallYearLabel;
	IBOutlet UILabel *yearTotalLabel;
	IBOutlet UILabel *friendsNumLabel;
	IBOutlet UILabel *casinoLabel;
	IBOutlet UILabel *forumNumLabel;
	
	IBOutlet UIImageView *openGamesCircle;
	IBOutlet UIImageView *friendsNumCircle;
	IBOutlet UIImageView *forumNumCircle;
	IBOutlet UIImageView *graphChart;
	IBOutlet UIImageView *largeGraph;
	
	IBOutlet UIActivityIndicatorView *activityIndicatorData;
	IBOutlet UIActivityIndicatorView *activityIndicatorNet;
	

	//---Gloabls----------------------------
	BOOL displayBySession;
	BOOL rotateLock;
	int alertViewNum;
}

- (IBAction) statsPressed: (id) sender;
- (IBAction) cashPressed: (id) sender;
- (IBAction) friendsPressed: (id) sender;
- (IBAction) oddsPressed: (id) sender;
- (IBAction) handsPressed: (id) sender;
- (IBAction) moreTrackersPressed: (id) sender;
- (IBAction) startGameButtonClicked:(id)sender;
- (IBAction) casinoTrackerClicked:(id)sender;

-(IBAction)reviewButtonClicks:(id)sender;
-(IBAction)ptpButtonClicked:(id)sender;
-(IBAction)emailButtonClicked:(id)sender;
-(IBAction)editButtonClicked:(id)sender;
-(IBAction)analysisButtonClicked:(id)sender;
-(void)calculateStats;
-(BOOL)isPokerZilla;


@property (nonatomic, strong) UILabel *smallYearLabel;
@property (nonatomic, strong) UILabel *yearTotalLabel;

@property (nonatomic, strong) IBOutlet PopupView *aboutView;
@property (nonatomic, strong) IBOutlet UIView *botView;
@property (nonatomic, strong) IBOutlet UIView *reviewView;
@property (nonatomic, strong) IBOutlet UILabel *reviewCountLabel;
@property (nonatomic, strong) IBOutlet UILabel *analysisLabel;
@property (nonatomic, strong) IBOutlet UITextView *aboutTextView;
@property (nonatomic, strong) IBOutlet UIView *topView;
@property (nonatomic, strong) IBOutlet UILabel *last10Label;
@property (nonatomic, strong) IBOutlet UILabel *iNewGameLabel;
@property (nonatomic, strong) IBOutlet UIImageView *statusImageView;
@property (nonatomic, strong) IBOutlet UIImageView *pokerZillaImageView;
@property (nonatomic, strong) UIImageView *friendsNumCircle;
@property (nonatomic, strong) UILabel *friendsNumLabel;
@property (nonatomic) BOOL displayBySession;
@property (nonatomic) BOOL rotateLock;
@property (nonatomic) BOOL checkForScreenLockPassword;
@property (nonatomic) BOOL loggedInFlg;
@property (nonatomic) int displayYear;
@property (nonatomic) int alertViewNum;
@property (nonatomic) float currentVersion;

@property (nonatomic, strong) UIButton *statsButton;
@property (nonatomic, strong) UIButton *reviewButton;
@property (nonatomic, strong) UIButton *emailButton;
@property (nonatomic, strong) UILabel *versionLabel;
@property (nonatomic, strong) UIButton *gamesButton;
@property (nonatomic, strong) UIButton *netTrackerButton;
@property (nonatomic, strong) UIButton *oddsButton;
@property (nonatomic, strong) UIButton *forumButton;
@property (nonatomic, strong) UIButton *moreTrackersButton;
@property (nonatomic, strong) UIButton *casinoButton;
@property (nonatomic, strong) UIButton *editButton;
@property (nonatomic, strong) UIButton *startNewGameButton;
@property (nonatomic, strong) UILabel *yearLabel;
@property (nonatomic, strong) UILabel *casinoLabel;
@property (nonatomic, strong) UIImageView *graphChart;
@property (nonatomic, strong) UIImageView *largeGraph;
@property (nonatomic, strong) UIButton *analysisButton;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorData;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorNet;


@property (nonatomic, strong) UIImageView *openGamesCircle;
@property (nonatomic, strong) UILabel *openGamesLabel;
@property (nonatomic, strong) UILabel *bankrollLabel;
@property (nonatomic, strong) UILabel *bankrollNameLabel;
@property (nonatomic, strong) UILabel *forumNumLabel;
@property (nonatomic, strong) UIImageView *forumNumCircle;


@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end
