//
//  MainMenuVC.h
//  PokerTracker
//
//  Created by Rick Medved on 10/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>


@interface MainMenuVC : UIViewController {
	//---Passed In----------------------------
    NSManagedObjectContext *managedObjectContext;
	
	//---XIB----------------------------
	IBOutlet UIButton *statsButton;
	IBOutlet UIButton *cashButton;
	IBOutlet UIButton *tournamentButton;
	IBOutlet UIButton *friendsButton;
	IBOutlet UIButton *oddsButton;
	IBOutlet UIButton *bigHandsButton;
	IBOutlet UIButton *oldGamesButton;
	IBOutlet UIButton *startNewGameButton;
	IBOutlet UIButton *refreshButton;
	IBOutlet UIButton *reviewButton;
	IBOutlet UIButton *emailButton;
	IBOutlet UIButton *upgradeButton;
	IBOutlet UIButton *analysisButton;
	IBOutlet UIButton *casinoButton;
	UIBarButtonItem *aboutButton;
	
	IBOutlet UILabel *yearLabel;
	IBOutlet UILabel *moneyLabel;
	IBOutlet UILabel *openGamesLabel;
	IBOutlet UILabel *versionLabel;
	IBOutlet UILabel *bankrollLabel;
	IBOutlet UILabel *bankrollNameLabel;
	IBOutlet UILabel *smallYearLabel;
	IBOutlet UILabel *yearTotalLabel;
	IBOutlet UILabel *friendsNumLabel;
	IBOutlet UILabel *casinoLabel;
	IBOutlet UILabel *playerTypeLabel;
	IBOutlet UILabel *forumNumLabel;
	
	IBOutlet UIImageView *aboutImage;
	IBOutlet UIImageView *logoImage;
	IBOutlet UIImageView *openGamesCircle;
	IBOutlet UIImageView *friendsNumCircle;
	IBOutlet UIImageView *forumNumCircle;
	IBOutlet UIImageView *graphChart;
	IBOutlet UIImageView *largeGraph;
	IBOutlet UIImageView *analysisBG;
	
	IBOutlet UITextView *aboutText;
	
	IBOutlet UIActivityIndicatorView *activityIndicatorData;
	IBOutlet UIActivityIndicatorView *activityIndicatorNet;
	

	//---Gloabls----------------------------
	int displayYear;
	BOOL aboutShowing;
	BOOL displayBySession;
	BOOL rotateLock;
	BOOL showDisolve;
	BOOL screenLock;
	BOOL avoidPopup;
	int toggleMode;
	int alertViewNum;
	int logoAlpha;
	

}

- (IBAction) statsPressed: (id) sender;
- (IBAction) cashPressed: (id) sender;
- (IBAction) friendsPressed: (id) sender;
- (IBAction) oddsPressed: (id) sender;
- (IBAction) handsPressed: (id) sender;
- (IBAction) moreTrackersPressed: (id) sender;
- (IBAction) refreshPressed: (id) sender;
- (IBAction) startGameButtonClicked:(id)sender;
- (IBAction) casinoTrackerClicked:(id)sender;

-(IBAction)reviewButtonClicks:(id)sender;
-(IBAction)emailButtonClicked:(id)sender;
-(IBAction)upgradeButtonClicked:(id)sender;
-(IBAction)editButtonClicked:(id)sender;
-(IBAction)analysisButtonClicked:(id)sender;
-(void)calculateStats;
-(void)startDisolveNow;


@property (nonatomic, strong) UILabel *smallYearLabel;
@property (nonatomic, strong) UILabel *yearTotalLabel;

@property (nonatomic, strong) UIImageView *friendsNumCircle;
@property (nonatomic, strong) UILabel *friendsNumLabel;
@property (nonatomic, strong) UIBarButtonItem *aboutButton;
@property (nonatomic) BOOL aboutShowing;
@property (nonatomic) BOOL displayBySession;
@property (nonatomic) BOOL rotateLock;
@property (nonatomic) BOOL showDisolve;
@property (nonatomic) BOOL screenLock;
@property (nonatomic) BOOL avoidPopup;
@property (nonatomic) int toggleMode;
@property (nonatomic) int displayYear;
@property (nonatomic) int alertViewNum;
@property (nonatomic) int logoAlpha;
@property (nonatomic, strong) UIButton *statsButton;
@property (nonatomic, strong) UIButton *reviewButton;
@property (nonatomic, strong) UIButton *emailButton;
@property (nonatomic, strong) UIButton *upgradeButton;
@property (nonatomic, strong) UILabel *versionLabel;
@property (nonatomic, strong) UIButton *cashButton;
@property (nonatomic, strong) UIButton *tournamentButton;
@property (nonatomic, strong) UIButton *friendsButton;
@property (nonatomic, strong) UIButton *oddsButton;
@property (nonatomic, strong) UIButton *bigHandsButton;
@property (nonatomic, strong) UIButton *oldGamesButton;
@property (nonatomic, strong) UIButton *casinoButton;
@property (nonatomic, strong) UIButton *startNewGameButton;
@property (nonatomic, strong) UILabel *yearLabel;
@property (nonatomic, strong) UILabel *moneyLabel;
@property (nonatomic, strong) UILabel *casinoLabel;
@property (nonatomic, strong) UILabel *playerTypeLabel;
@property (nonatomic, strong) UIImageView *aboutImage;
@property (nonatomic, strong) UIImageView *logoImage;
@property (nonatomic, strong) UIImageView *graphChart;
@property (nonatomic, strong) UIImageView *largeGraph;
@property (nonatomic, strong) UIImageView *analysisBG;
@property (nonatomic, strong) UITextView *aboutText;
@property (nonatomic, strong) UIButton *refreshButton;
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
