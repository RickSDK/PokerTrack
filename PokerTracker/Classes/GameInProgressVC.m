//
//  GameInProgressVC.m
//  PokerTracker
//
//  Created by Rick Medved on 10/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GameInProgressVC.h"
#import "ProjectFunctions.h"
#import "MoneyPickerVC.h"
#import "CoreDataLib.h"
#import "MainMenuVC.h"
#import "GameDetailsVC.h"
#import "MinuteEnterVC.h"
#import "GameGraphVC.h"
#import "TextEnterVC.h"
#import "SoundsLib.h"
#import "FriendInProgressVC.h"
#import "NSString+ATTString.h"
#import "NSArray+ATTArray.h"
#import "WebServicesFunctions.h"
#import "MultiLineDetailCellWordWrap.h"
#import "NSDate+ATTDate.h"
#import "MultiCellObj.h"
#import "HudTrackerVC.h"
#import "AnalysisDetailsVC.h"

#define kEndGameAlert	1
//attrib05	//startingChips
//hudHeroLine	//currentChips
//hudVillianLine // rebuyChips


@implementation GameInProgressVC
@synthesize managedObjectContext, mo, clockLabel, notesButton, graphButton;
@synthesize foodButton, tokesButton, chipStackButton, rebuyButton, pauseButton, doneButton;
@synthesize onBreakLabel, timerLabel, buyinLabel, rebuysLabel, rebuyAmountLabel, hourlyLabel, grossLabel, takehomeLabel, profitLabel, pauseTimerLabel;
@synthesize activityIndicator, selectedObjectForEdit, grayPauseBG, infoImage, infoScreenShown;
@synthesize gameInProgress, friendButton, messageString;
@synthesize foodLabel, tokesLabel, currentStackLabel, gameTypeLabel, infoText, cashUpdatedFlg, editButton;
@synthesize userData, startDate, netProfit, totalBreakSeconds, gamePaused, popupViewNumber, addOnFlg;
@synthesize mainTableView, playerTypeImage, netUserObj;

- (void)viewDidLoad {
	[super viewDidLoad];
	self.gameObj = [GameObj gameObjFromDBObj:mo];
	[self setTitle:(self.gameObj.isTourney)?NSLocalizedString(@"Tournament", nil):NSLocalizedString(@"Cash Game", nil)];
	
	self.userData = [[NSString alloc] init];
	self.valuesArray = [[NSMutableArray alloc] init];
	self.colorsArray = [[NSMutableArray alloc] init];
	
	self.currentStackLabel.text = NSLocalizedString(@"Current Chips", nil);
	self.tokesLabel.text = NSLocalizedString(@"Tips", nil);
	self.foodLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:11];
	self.tokesLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:11];
	if(self.gameObj.tournamentGameFlg) {
		self.foodLabel.text = NSLocalizedString(@"# Players", nil);
		self.tokesLabel.text = NSLocalizedString(@"tournamentFinish", nil);
	} else {
		self.foodLabel.text = [NSString stringWithFormat:@"%@ %@", [NSString fontAwesomeIconStringForEnum:FACutlery], NSLocalizedString(@"foodDrinks", nil)];
		self.tokesLabel.text = [NSString stringWithFormat:@"%@ %@", [NSString fontAwesomeIconStringForEnum:FAMoney], NSLocalizedString(@"Tips", nil)];
	}

	self.clockLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:30];
	self.clockLabel.text = [NSString fontAwesomeIconStringForEnum:FAClockO];
	[ProjectFunctions makeFAButton:self.notesButton type:6 size:16];
	[ProjectFunctions makeFAButton:self.graphButton type:11 size:16];
	[ProjectFunctions makeFAButton:self.editButton type:2 size:16];
	[ProjectFunctions makeFAButton:self.hudButton type:5 size:16];

	[ProjectFunctions makeFAButton:self.pauseButton type:7 size:16];
	[ProjectFunctions makeFAButton:self.doneButton type:8 size:24 text:NSLocalizedString(@"End", nil)];
	[ProjectFunctions makeFAButton:self.rebuyButton type:25 size:24];
	self.pauseTimerLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:11];
	self.rebuyAmountLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:11];
	self.pauseTimerLabel.text = [NSString stringWithFormat:@"%@ %@", [NSString fontAwesomeIconStringForEnum:FAPause], NSLocalizedString(@"Pause", nil)];
	self.rebuyAmountLabel.text = [NSString stringWithFormat:@"%@ %@", [NSString fontAwesomeIconStringForEnum:FARepeat], NSLocalizedString(@"rebuy", nil)];

	self.mainTableView.tableHeaderView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0.01f)];
	
	[UIApplication sharedApplication].applicationIconBadgeNumber=1;

	self.navigationItem.leftBarButtonItem = [ProjectFunctions UIBarButtonItemWithIcon:[NSString fontAwesomeIconStringForEnum:FAHome] target:self action:@selector(mainMenuButtonClicked:)];
	self.navigationItem.rightBarButtonItem = [ProjectFunctions UIBarButtonItemWithIcon:[NSString fontAwesomeIconStringForEnum:FAInfoCircle] target:self action:@selector(popupButtonClicked)];

	onBreakLabel.hidden=YES;
	[activityIndicator startAnimating];
	
	self.selectedObjectForEdit=0;
	self.infoScreenShown=NO;
	self.cashUpdatedFlg=NO;
	editButton.hidden=NO;
	friendButton.alpha=0;
	infoImage.alpha=0;
	
	self.popupView.titleLabel.text = @"Terms";
	self.playersPopupView.titleLabel.text = @"Tournament Players";
	self.tournamentEndPopupView.titleLabel.text = NSLocalizedString(@"Amount Won", nil);
	self.numberPlayersLabel.text = NSLocalizedString(@"# Players", nil);
	self.numberSpotPaidLabel.text = NSLocalizedString(@"tournamentSpotsPaid", nil);
	self.tournamentEndPopupView.hidden=YES;
	
	self.playersPopupView.hidden=YES;
	
	[self.numberPlayersButton setTitle:self.gameObj.tournamentSpotsStr forState:UIControlStateNormal];
	[self.numberSpotPaidButton setTitle:self.gameObj.tournamentSpotsPaidStr forState:UIControlStateNormal];
	
	[self endWebServiceCall];
	[self displayBadgeNumber];
	[self updatePicture];
	[self setUpScreen];
	[self liveUpdate];
	self.multiCellObj = [MultiCellObj initWithTitle:@"" altTitle:@"" labelPercent:.5];
}

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	if([self respondsToSelector:@selector(edgesForExtendedLayout)])
		[self setEdgesForExtendedLayout:UIRectEdgeBottom];
	
	self.popupViewNumber=0;
	
	self.viewLoadedFlg=YES;
	self.gameInProgress=YES;

	self.gameObj = [GameObj gameObjFromDBObj:mo];
	[self.multiCellObj populateObjWithGame:self.gameObj];
	[self.mainTableView reloadData];

	if([[mo valueForKey:@"onBreakFlag"] isEqualToString:@"Y"]) {
		self.gamePaused=YES;
		[self pauseScreen];
	} else
		self.gamePaused=NO;

	[self performSelectorInBackground:@selector(countTheCounter) withObject:nil];
}

-(BOOL)shouldAutorotate
{
    return YES;
}

- (IBAction) friendButtonPressed: (id) sender
{
    NSArray *elements = [self.userData componentsSeparatedByString:@"<xx>"];
    if([elements count]>4) {
        if([elements count]>1) {
            FriendInProgressVC *detailViewController = [[FriendInProgressVC alloc] initWithNibName:@"FriendInProgressVC" bundle:nil];
            detailViewController.managedObjectContext=self.managedObjectContext;
			detailViewController.netUserObj=self.netUserObj;
            [self.navigationController pushViewController:detailViewController animated:YES];
        };
    } else {
        [ProjectFunctions showAlertPopup:@"Data Sync Error" message:@""];
    }
}

- (IBAction) hudButtonPressed: (id) sender {
	HudTrackerVC *detailViewController = [[HudTrackerVC alloc] initWithNibName:@"HudTrackerVC" bundle:nil];
	detailViewController.managedObjectContext = managedObjectContext;
	detailViewController.gameMo = mo;
	[self.navigationController pushViewController:detailViewController animated:YES];
}

- (IBAction) editButtonPressed: (id) sender
{
	GameDetailsVC *detailViewController = [[GameDetailsVC alloc] initWithNibName:@"GameDetailsVC" bundle:nil];
	detailViewController.managedObjectContext = managedObjectContext;
	detailViewController.mo = mo;
	[self.navigationController pushViewController:detailViewController animated:YES];
}

- (IBAction) playerTypeButtonPressed: (id) sender {
	AnalysisDetailsVC *detailViewController = [[AnalysisDetailsVC alloc] initWithNibName:@"AnalysisDetailsVC" bundle:nil];
	detailViewController.managedObjectContext = managedObjectContext;
	[self.navigationController pushViewController:detailViewController animated:YES];
}

- (IBAction) notesButtonPressed: (id) sender
{
	self.selectedObjectForEdit=9;
	TextEnterVC *localViewController = [[TextEnterVC alloc] initWithNibName:@"TextEnterVC" bundle:nil];
	[localViewController setCallBackViewController:self];
	localViewController.managedObjectContext=managedObjectContext;
	localViewController.initialDateValue = [mo valueForKey:@"notes"];
	localViewController.titleLabel = @"Edit Notes";
	[self.navigationController pushViewController:localViewController animated:YES];
}

- (IBAction) graphButtonPressed: (id) sender
{
	GameGraphVC *detailViewController = [[GameGraphVC alloc] initWithNibName:@"GameGraphVC" bundle:nil];
	detailViewController.managedObjectContext=managedObjectContext;
	detailViewController.showMainMenuFlg = NO;
	detailViewController.mo = mo;
	[self.navigationController pushViewController:detailViewController animated:YES];
}


- (IBAction) foodButtonPressed: (id) sender
{
	self.selectedObjectForEdit=1;
	if(self.gameObj.tournamentGameFlg) {
		self.playersPopupView.hidden=!self.playersPopupView.hidden;
	} else {
		MoneyPickerVC *detailViewController = [[MoneyPickerVC alloc] initWithNibName:@"MoneyPickerVC" bundle:nil];
		detailViewController.callBackViewController = self;
		detailViewController.managedObjectContext=managedObjectContext;
		detailViewController.titleLabel = @"foodDrink";
		detailViewController.initialDateValue = [NSString stringWithFormat:@"%@", foodButton.titleLabel.text];
		[self.navigationController pushViewController:detailViewController animated:YES];
	}
}

- (IBAction) numberPlayersButtonPressed: (id) sender
{
	self.selectedObjectForEdit=11;
	MinuteEnterVC *detailViewController = [[MinuteEnterVC alloc] initWithNibName:@"MinuteEnterVC" bundle:nil];
	detailViewController.managedObjectContext=managedObjectContext;
	[detailViewController setCallBackViewController:self];
	detailViewController.sendTitle = NSLocalizedString(@"# Players", nil);
	detailViewController.initialDateValue = (self.gameObj.tournamentSpots==0)?@"":[NSString stringWithFormat:@"%@", self.numberPlayersButton.titleLabel.text];
	[self.navigationController pushViewController:detailViewController animated:YES];
}
- (IBAction) numberSpotsPaidButtonPressed: (id) sender
{
	self.selectedObjectForEdit=12;
	MinuteEnterVC *detailViewController = [[MinuteEnterVC alloc] initWithNibName:@"MinuteEnterVC" bundle:nil];
	detailViewController.managedObjectContext=managedObjectContext;
	[detailViewController setCallBackViewController:self];
	detailViewController.sendTitle = NSLocalizedString(@"# Spots Paid", nil);
	detailViewController.initialDateValue = (self.gameObj.tournamentSpotsPaid==0)?@"":[NSString stringWithFormat:@"%@", self.numberSpotPaidButton.titleLabel.text];
	[self.navigationController pushViewController:detailViewController animated:YES];
}

- (IBAction) tokesButtonPressed: (id) sender
{
	self.selectedObjectForEdit=2;
	if(self.gameObj.tournamentGameFlg) {
		MinuteEnterVC *detailViewController = [[MinuteEnterVC alloc] initWithNibName:@"MinuteEnterVC" bundle:nil];
		detailViewController.managedObjectContext=managedObjectContext;
		[detailViewController setCallBackViewController:self];
		detailViewController.sendTitle = NSLocalizedString(@"Your Finish", nil);
		detailViewController.initialDateValue = (self.gameObj.tournamentFinish==0)?@"":[NSString stringWithFormat:@"%d", self.gameObj.tournamentFinish];
		[self.navigationController pushViewController:detailViewController animated:YES];
	} else {
		MoneyPickerVC *detailViewController = [[MoneyPickerVC alloc] initWithNibName:@"MoneyPickerVC" bundle:nil];
		detailViewController.managedObjectContext=managedObjectContext;
		[detailViewController setCallBackViewController:self];
		detailViewController.titleLabel = NSLocalizedString(@"Tips", nil);
		detailViewController.initialDateValue = [NSString stringWithFormat:@"%@", tokesButton.titleLabel.text];
		[self.navigationController pushViewController:detailViewController animated:YES];
	}
}

- (IBAction) chipsButtonPressed: (id) sender
{
	[self gotoChipUpdate:[NSString stringWithFormat:@"%@", chipStackButton.titleLabel.text]];
}

-(void)gotoChipUpdate:(NSString *)chips {
	self.cashUpdatedFlg=YES;
	self.selectedObjectForEdit=3;
	self.popupViewNumber=0;
	MoneyPickerVC *detailViewController = [[MoneyPickerVC alloc] initWithNibName:@"MoneyPickerVC" bundle:nil];
	detailViewController.callBackViewController = self;
	detailViewController.managedObjectContext=managedObjectContext;
	detailViewController.titleLabel = @"Current Chips";
	detailViewController.initialDateValue = chips;
	[self.navigationController pushViewController:detailViewController animated:YES];
}

- (IBAction) rebuyButtonPressed: (id) sender 
{
	self.selectedObjectForEdit=4;
    self.popupViewNumber=99;
    [ProjectFunctions showTwoButtonPopupWithTitle:NSLocalizedString(@"rebuyAmount", nil) message:@"Select Rebuy Type" button1:@"Add-on" button2:@"Re-buy" delegate:self];
}

-(void)pauseScreen {
	NSLog(@"Screen is paused");
	[activityIndicator stopAnimating];
	self.mainTableView.alpha=.5;
	[self.pauseButton setTitle:[NSString fontAwesomeIconStringForEnum:FAPlay] forState:UIControlStateNormal];
	[self enableButtons:!self.gamePaused];
}

-(void)unPauseScreen {
	[activityIndicator startAnimating];
	self.mainTableView.alpha=1;
	[self.pauseButton setTitle:[NSString fontAwesomeIconStringForEnum:FAPause] forState:UIControlStateNormal];
	[self enableButtons:!self.gamePaused];
}

-(void)enableButtons:(BOOL)enabled {
	onBreakLabel.hidden=enabled;
	
	self.notesButton.enabled=enabled;
	self.graphButton.enabled=enabled;
	self.editButton.enabled=enabled;

	self.doneButton.enabled=enabled;
	self.chipStackButton.enabled=enabled;

	self.foodButton.enabled=enabled;
	self.tokesButton.enabled=enabled;
	self.rebuyButton.enabled=enabled;

	if(self.gameObj.tournamentGameFlg && ![ProjectFunctions trackChipsSwitchValue]) {
		[self.chipStackButton setTitle:@"-" forState:UIControlStateNormal];
		self.chipStackButton.enabled=NO;
	}
}

- (IBAction) pauseButtonPressed: (id) sender
{
	self.gamePaused = ! self.gamePaused;
	
	 if(self.gamePaused) {
		 [mo setValue:[NSDate date] forKey:@"endTime"];
		 [mo setValue:@"Y" forKey:@"onBreakFlag"];
		 [self saveDatabase];
		 [self pauseScreen];
	 } else {
		 int totalSeconds = [[NSDate date] timeIntervalSinceDate:[mo valueForKey:@"endTime"]];
		 int breakMinutes = [[mo valueForKey:@"breakMinutes"] intValue];
		 breakMinutes += totalSeconds/60;
		 [mo setValue:[NSNumber numberWithInt:breakMinutes] forKey:@"breakMinutes"];
		 [mo setValue:@"N" forKey:@"onBreakFlag"];
		 [self saveDatabase];
		 [self unPauseScreen];
	 }
 	[self setUpScreen];
}

-(void)refreshWebRequest
{
	@autoreleasepool {
    
		BOOL success = [ProjectFunctions uploadUniverseStats:managedObjectContext];
		NSLog(@"+++Net Tracker Updated");
		
		[self sendEndGameMessageWebRequest];
		[self endWebServiceCall];
		
        if(success)
            [ProjectFunctions showAlertPopupWithDelegate:@"Success" message:@"Stats sent to Net Tracker" delegate:self];
		else
			[ProjectFunctions showAlertPopupWithDelegate:@"Game Saved" message:@"Game saved but unable to reach NetTracker server." delegate:self];
	}
}

-(void)startWebServiceCall:(NSString *)message {
	NSLog(@"+++startWebServiceCall");
	[self.webServiceView startWithTitle:message];
	[self.webServiceView showCancelButton];
	[self enableButtons:NO];
}

-(void)endWebServiceCall {
	NSLog(@"+++endWebServiceCall");
	[self.webServiceView stop];
	[self enableButtons:!self.gamePaused];
}

-(void)sendEndGameMessageWebRequest
{
		// send text message saying that game ended
        NSArray *nameList = [NSArray arrayWithObjects:@"Username", @"Password", @"status", nil];
        NSArray *valueList = [NSArray arrayWithObjects:[ProjectFunctions getUserDefaultValue:@"userName"], [ProjectFunctions getUserDefaultValue:@"password"], @"end", nil];
        NSString *webAddr = @"http://www.appdigity.com/poker/pokerFriendSendText.php";
        NSString *responseStr = [WebServicesFunctions getResponseFromServerUsingPost:webAddr fieldList:nameList valueList:valueList];
        NSLog(@"+++%@", responseStr);
}

- (IBAction) tournamenDoneButtonPressed: (id) sender {
	[self.mainTextfield resignFirstResponder];
	[chipStackButton setTitle:self.mainTextfield.text forState:UIControlStateNormal];
	chipStackButton.titleLabel.text=self.mainTextfield.text;
	[mo setValue:[NSNumber numberWithDouble:[self.mainTextfield.text doubleValue]] forKey:@"cashoutAmount"];
	double chips = 0;
	if(self.gameObj.buyInAmount>0)
		chips = self.gameObj.startingChips*[self.mainTextfield.text doubleValue]/self.gameObj.buyInAmount;

	NSLog(@"chips %f %f", chips, self.gameObj.startingChips);
	[ProjectFunctions createChipTimeStamp:managedObjectContext mo:mo timeStamp:nil amount:chips-self.gameObj.rebuyChips-self.gameObj.startingChips rebuyFlg:NO];
	[self completeGame];
}

-(void)completeGame {
    self.selectedObjectForEdit=0;
	self.gameInProgress=NO;
	[self startWebServiceCall:@"Ending Game"];
	
	double buyIn = [[mo valueForKey:@"buyInAmount"] doubleValue];
	double rebuyAmount = [[mo valueForKey:@"rebuyAmount"] doubleValue];
	
	float foodMoney = self.gameObj.foodDrink;
	float tokes = self.gameObj.tokes;
	double chips = [ProjectFunctions convertMoneyStringToDouble:chipStackButton.titleLabel.text];
	NSLog(@"chips: %f", chips);
	NSLog(@"buyIn: %f", buyIn);
	NSLog(@"rebuyAmount: %f", rebuyAmount);
	
	if(!self.gameObj.tournamentGameFlg)
		[ProjectFunctions createChipTimeStamp:managedObjectContext mo:mo timeStamp:nil amount:chips+foodMoney-buyIn-rebuyAmount rebuyFlg:NO];

	self.netProfit = chips+foodMoney-buyIn-rebuyAmount;
	
	int seconds = [[NSDate date] timeIntervalSinceDate:[mo valueForKey:@"startTime"]];
	int breakMinutes = [[mo valueForKey:@"breakMinutes"] intValue];
	seconds -= breakMinutes*60;
	int minutes = seconds/60;
	float hours = (float)seconds/3600;
	
	[mo setValue:[NSNumber numberWithDouble:self.netProfit] forKey:@"winnings"];
	[mo setValue:[NSNumber numberWithInt:breakMinutes] forKey:@"breakMinutes"];
	[mo setValue:[NSNumber numberWithInt:minutes] forKey:@"minutes"];
	[mo setValue:[NSNumber numberWithInt:tokes] forKey:@"tokes"];
	[mo setValue:@"Completed" forKey:@"status"];
	[mo setValue:[NSDate date] forKey:@"endTime"];
	[mo setValue:[NSString stringWithFormat:@"%.1f", hours] forKey:@"hours"];
	
	
	[self saveDatabase];
	[ProjectFunctions findMinAndMaxYear:self.managedObjectContext];
	
    [ProjectFunctions updateBankroll:netProfit bankrollName:[mo valueForKey:@"bankroll"] MOC:managedObjectContext];

	[ProjectFunctions updateGamesOnDevice:self.managedObjectContext];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"user_id = 0 AND status = %@", @"In Progress"];
	NSArray *items = [CoreDataLib selectRowsFromEntity:@"GAME" predicate:predicate sortColumn:@"name" mOC:managedObjectContext ascendingFlg:YES];
	[UIApplication sharedApplication].applicationIconBadgeNumber=[items count];
	[activityIndicator stopAnimating];
	
	if(netProfit>0)
		[SoundsLib PlaySound:@"crowdapplause" type:@"wav"];
	if(netProfit<0)
		[SoundsLib PlaySound:@"boo-crowd-02" type:@"wav"];

	int gamesOnDevice = [[ProjectFunctions getUserDefaultValue:@"gamesOnDevice"] intValue];
	int numGamesServer = [[ProjectFunctions getUserDefaultValue:@"numGamesServer"] intValue];
	int numGamesServer2 = [[ProjectFunctions getUserDefaultValue:@"numGamesServer2"] intValue];
	if(numGamesServer2>numGamesServer)
		numGamesServer=numGamesServer2;
	int gamesSinceSync = gamesOnDevice-numGamesServer;
	NSLog(@"+++gamesSinceSync: %d [%d %d %d]", gamesSinceSync, gamesOnDevice, numGamesServer, numGamesServer2);

	if([ProjectFunctions shouldSyncGameResultsWithServer:managedObjectContext]) {
		[self startWebServiceCall:@"Updating NetTracker..."];
		[self performSelectorInBackground:@selector(refreshWebRequest) withObject:nil];
		if(gamesSinceSync>1 && gamesSinceSync%10==0)
			[ProjectFunctions showAlertPopupWithDelegate:@"Data not backed up" message:[NSString stringWithFormat:@"Note: You have %d games on device that haven't been backed up. If you lose your phone you will lose this data. To back up your data go to the 'Options' menu and click 'Export Data'.", gamesSinceSync] delegate:self];
		
	} else {
		[self endWebServiceCall];
		if(gamesSinceSync>1 && gamesSinceSync%20==0)
			[ProjectFunctions showAlertPopupWithDelegate:@"Data not backed up" message:[NSString stringWithFormat:@"Note: You have %d games on device that haven't been backed up. If you lose your phone you will lose this data. To back up your data go to the 'Options' menu and click 'Export Data'.", gamesSinceSync] delegate:self];
		else
			[ProjectFunctions showAlertPopupWithDelegate:@"Game Over!" message:@"Game data has been saved" delegate:self];
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *cellIdentifier = [NSString stringWithFormat:@"cellIdentifierSection%ldRow%ld", (long)indexPath.section, (long)indexPath.row];
	return [MultiLineDetailCellWordWrap multiCellForID:cellIdentifier obj:self.multiCellObj tableView:tableView];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[self updatePicture];
	[self setUpScreen];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if(indexPath.section==0 && mo != nil) {
		return [MultiLineDetailCellWordWrap heightForMultiCellObj:self.multiCellObj tableView:self.mainTableView];
	}
	return 44;
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if(alertView.tag==kEndGameAlert) {
		if(buttonIndex != alertView.cancelButtonIndex)
			[self completeGame];

		return;
	}
	if(popupViewNumber==99) {
		NSString *intitialAmount=[NSString stringWithFormat:@"%@", chipStackButton.titleLabel.text];
		intitialAmount = self.gameObj.buyInAmountStr;
		if(buttonIndex==0)
			self.addOnFlg=YES;
		else {
			self.addOnFlg=NO;
			intitialAmount=@"0";
		}
		NSLog(@"rebuyAmount");
		MoneyPickerVC *detailViewController = [[MoneyPickerVC alloc] initWithNibName:@"MoneyPickerVC" bundle:nil];
		detailViewController.managedObjectContext=managedObjectContext;
		[detailViewController setCallBackViewController:self];
		detailViewController.titleLabel = NSLocalizedString(@"rebuyAmount", nil);
		detailViewController.initialDateValue = intitialAmount;
		[self.navigationController pushViewController:detailViewController animated:YES];
	} else {
		GameGraphVC *detailViewController = [[GameGraphVC alloc] initWithNibName:@"GameGraphVC" bundle:nil];
		detailViewController.managedObjectContext=managedObjectContext;
		detailViewController.showMainMenuFlg = YES;
		detailViewController.mo = mo;
		[self.navigationController pushViewController:detailViewController animated:YES];
	}
}

- (IBAction) doneButtonPressed: (id) sender
{
	if(self.gameObj.tournamentGameFlg) {
		self.tournamentEndPopupView.hidden=!self.tournamentEndPopupView.hidden;
		[self.mainTextfield becomeFirstResponder];
		return;
	}
	if(!self.cashUpdatedFlg) {
		[ProjectFunctions showAlertPopup:NSLocalizedString(@"notice", nil) message:[NSString stringWithFormat:@"%@ %@ %@", NSLocalizedString(@"Update", nil), NSLocalizedString(@"your", nil), NSLocalizedString(@"Current Chips", nil)]];
		return;
	}
	[ProjectFunctions showConfirmationPopup:@"End Game?" message:[NSString stringWithFormat:@"%@ %@?", NSLocalizedString(@"LeavingGame", nil), chipStackButton.titleLabel.text] delegate:self tag:kEndGameAlert];
}

-(void)refreshScreen
{
    if(self.gamePaused || !self.gameInProgress)
        return;
	
	int totalSeconds = [[NSDate date] timeIntervalSinceDate:startDate];
	
	// Timer-------
	int seconds = totalSeconds-totalBreakSeconds;
	int hours = (int)(seconds/3600);
	seconds -= hours*3600;
	int minutes = (int)(seconds/60);
	seconds -= minutes*60;
	NSString *clockText = [NSString stringWithFormat:@"%d:%02d:%02d", hours, minutes, seconds];
	[timerLabel performSelectorOnMainThread:@selector(setText: ) withObject:clockText waitUntilDone:YES];
	
	// Hourly-------
	if(totalSeconds<=0)
		return;
}

-(void)setUpScreen
{

    NSString *foodButtonText = @"";
    NSString *tokesButtonText = @"";
    NSString *chipsButtonText = @"";
	
	int foodDrinks = [[mo valueForKey:@"foodDrinks"] intValue];
	int tokesMoney = [[mo valueForKey:@"tokes"] intValue];
	if(self.gameObj.tournamentGameFlg) {
		foodButtonText = [NSString stringWithFormat:@"%@ / %@", self.gameObj.tournamentSpotsStr, self.gameObj.tournamentSpotsPaidStr];
		tokesButtonText = self.gameObj.tournamentFinishStr;
	} else {
		foodButtonText = self.gameObj.foodDrinkStr;
		tokesButtonText = self.gameObj.tokesStr;
	}

	if(self.gameObj.tournamentGameFlg) {
		if([ProjectFunctions trackChipsSwitchValue])
			chipsButtonText = [ProjectFunctions displayMoney:mo column:@"hudHeroLine"];
		else
			chipsButtonText = @"-";
	} else
		chipsButtonText = [ProjectFunctions displayMoney:mo column:@"cashoutAmount"];
	
	self.startDate = [mo valueForKey:@"startTime"];
	int totalSeconds = [[NSDate date] timeIntervalSinceDate:startDate];
	
	int breakMinutes = [[mo valueForKey:@"breakMinutes"] intValue];
	int breakSeconds = breakMinutes*60;
	if([[mo valueForKey:@"onBreakFlag"] isEqualToString:@"Y"]) {
		int additionalBreakSeconds = [[NSDate date] timeIntervalSinceDate:[mo valueForKey:@"endTime"]];
		breakSeconds += additionalBreakSeconds;
	}
	
	self.totalBreakSeconds = breakSeconds;
	
	// Stats-------
	double buyIn = [[mo valueForKey:@"buyInAmount"] doubleValue];
	double rebuyAmount = [[mo valueForKey:@"rebuyAmount"] doubleValue];
	
	double chips = [[mo valueForKey:@"cashoutAmount"] doubleValue];
	
	self.netProfit = chips+foodDrinks-buyIn-rebuyAmount;
	int grossEarnings = netProfit+tokesMoney;
	int takeHome = netProfit-foodDrinks;
	
	
	[grossLabel performSelectorOnMainThread:@selector(setText: ) withObject:[ProjectFunctions convertNumberToMoneyString:grossEarnings] waitUntilDone:YES];
	[takehomeLabel performSelectorOnMainThread:@selector(setText: ) withObject:[ProjectFunctions convertNumberToMoneyString:takeHome] waitUntilDone:YES];
	[profitLabel performSelectorOnMainThread:@selector(setText: ) withObject:[ProjectFunctions convertNumberToMoneyString:netProfit] waitUntilDone:YES];
	
	
	// hourly-----
	NSString *hourlytext = @"-";
	if(totalSeconds>0) {
		int amountHr = ceil(netProfit*3600/totalSeconds);
		hourlytext = [NSString stringWithFormat:@"%@/hr", [ProjectFunctions convertNumberToMoneyString: amountHr]];
	}
	
	// colors
	if(netProfit>=0) {
		hourlyLabel.textColor = [UIColor yellowColor];
		profitLabel.textColor = [UIColor greenColor];
	} else {
		hourlyLabel.textColor = [UIColor colorWithRed:1 green:.8 blue:0 alpha:1];
		profitLabel.textColor = [UIColor orangeColor];
	}
	if(grossEarnings>=0)
		grossLabel.textColor = [UIColor greenColor];
	else
		grossLabel.textColor = [UIColor orangeColor];
	if(takeHome>=0)
		takehomeLabel.textColor = [UIColor greenColor];
	else
		takehomeLabel.textColor = [UIColor orangeColor];
	
	int hours = breakSeconds/3600;
	breakSeconds -= hours*3600;
	int minutes = breakSeconds/60;
	breakSeconds -= minutes*60;
	NSString *pauseTimerText = [NSString stringWithFormat:@"%d:%02d:%02d", hours, minutes, breakSeconds];
	if(hours==0 && breakSeconds==0)
		pauseTimerText = [NSString stringWithFormat:@"%d min", minutes];
	
	if(breakSeconds>0)
		[pauseTimerLabel performSelectorOnMainThread:@selector(setText: ) withObject:pauseTimerText waitUntilDone:YES];
	[hourlyLabel performSelectorOnMainThread:@selector(setText: ) withObject:hourlytext waitUntilDone:YES];
	float fontSize = chipsButtonText.length>7?26.0:32.0;
	if(chipsButtonText.length>10)
		fontSize = 18;
	chipStackButton.titleLabel.font = [UIFont boldSystemFontOfSize:fontSize];

        dispatch_async(dispatch_get_main_queue(), ^{
            [foodButton setTitle:foodButtonText forState:UIControlStateNormal];
            [tokesButton setTitle:tokesButtonText forState:UIControlStateNormal];
            [chipStackButton setTitle:chipsButtonText forState:UIControlStateNormal];
        }
                       );

	[self.mainTableView reloadData];

}

- (IBAction) cancelButtonPressed: (id) sender {
	[self.mainTextfield resignFirstResponder];
	self.tournamentEndPopupView.hidden=YES;
}

-(void)mainMenuButtonClicked:(id)sender {
	[self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
}

-(void)countTheCounter
{
	@autoreleasepool {
		
		if(self.gameInProgress && self.viewLoadedFlg)
            [self refreshScreen];
        
		[NSThread sleepForTimeInterval:1];
		
		if(self.gamePaused)
			[self setUpScreen];
		
		if(gameInProgress && self.viewLoadedFlg)
			[self performSelectorInBackground:@selector(countTheCounter) withObject:nil];

	}
}

-(void)updatePicture {
    double buyIn = [[mo valueForKey:@"buyInAmount"] doubleValue];
	double rebuyAmount = [[mo valueForKey:@"rebuyAmount"] doubleValue];
    
    double risked = buyIn+rebuyAmount;
    double cashoutAmount = [[mo valueForKey:@"cashoutAmount"] doubleValue];
    int foodDrinks = [[mo valueForKey:@"foodDrinks"] intValue];
    double profit = foodDrinks+cashoutAmount-risked;
    
	[self.playerTypeButton setBackgroundImage:[ProjectFunctions getPlayerTypeImage:risked winnings:profit] forState:UIControlStateNormal];
}

-(void)doLiveUpdate {
	@autoreleasepool {
        [ProjectFunctions uploadUniverseStats:managedObjectContext]; // web service call
        self.userData = [ProjectFunctions getFriendsPlayingData]; // web service call
        friendButton.alpha=0;
        if([self.userData length]>10) {
			self.netUserObj = [NetUserObj userObjFromString:self.userData type:1];
            NSArray *elements = [self.userData componentsSeparatedByString:@"<xx>"];
            if([elements count]>1)
                friendButton.alpha=1;
        }
        NSLog(@"doLiveUpdate - Done");
		[self endWebServiceCall];
	}
}

-(void)liveUpdate
{
 	if([[ProjectFunctions getUserDefaultValue:@"userName"] length]>0) {
        [self performSelectorInBackground:@selector(doLiveUpdate) withObject:nil];
    }
}

-(UIColor *)colorOfMoney:(float)money {
	if(money>=0)
		return [UIColor colorWithRed:0 green:.5 blue:0 alpha:1];
	else
		return [UIColor redColor];
}

-(void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	self.viewLoadedFlg=NO;
}

- (void)displayBadgeNumber {
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"user_id = 0 AND status = %@", @"In Progress"];
	NSArray *items = [CoreDataLib selectRowsFromEntity:@"GAME" predicate:predicate sortColumn:@"name" mOC:managedObjectContext ascendingFlg:YES];
	[UIApplication sharedApplication].applicationIconBadgeNumber=[items count];
}

-(void) setReturningValue:(NSString *) value {
	BOOL doLiveUpdate=NO;
	if(selectedObjectForEdit==1) {
		[mo setValue:[NSNumber numberWithInt:[value intValue]] forKey:@"foodDrinks"];
	}
	if(selectedObjectForEdit==2) {
		if(self.gameObj.tournamentGameFlg)
			[mo setValue:[NSNumber numberWithInt:[value intValue]] forKey:@"tournamentFinish"];
		else
			[mo setValue:[NSNumber numberWithInt:[value intValue]] forKey:@"tokes"];
	}
	if(selectedObjectForEdit==3) {
		// set current chip stack
		double chips = [value doubleValue];
		double buyInAmount = [[mo valueForKey:@"buyInAmount"] doubleValue];
		double rebuyAmount = [[mo valueForKey:@"rebuyAmount"] doubleValue];
		doLiveUpdate=YES;
		if(self.gameObj.tournamentGameFlg) {
			[mo setValue:[NSString stringWithFormat:@"%d", [value intValue]] forKey:@"hudHeroLine"];
			float tCashoutAmount = 0;
			if(self.gameObj.startingChips>0)
				tCashoutAmount = (buyInAmount+rebuyAmount)*chips/(self.gameObj.startingChips+self.gameObj.rebuyChips);
			[mo setValue:[NSNumber numberWithFloat:tCashoutAmount] forKey:@"cashoutAmount"];
			
			buyInAmount = self.gameObj.startingChips;
			rebuyAmount = self.gameObj.rebuyChips;
		} else {
			[mo setValue:[NSNumber numberWithFloat:[value doubleValue]] forKey:@"cashoutAmount"];
		}
		[ProjectFunctions createChipTimeStamp:managedObjectContext mo:mo timeStamp:nil amount:chips-rebuyAmount-buyInAmount rebuyFlg:NO];
	}
	if(selectedObjectForEdit==4) {
		// rebuy
		int numRebuys = [[mo valueForKey:@"numRebuys"] intValue];
		double buyInAmount = [[mo valueForKey:@"buyInAmount"] doubleValue];
		double rebuyAmount = [[mo valueForKey:@"rebuyAmount"] doubleValue];
		double cashoutAmount = [[mo valueForKey:@"cashoutAmount"] doubleValue];
		double thisRebuy = [value doubleValue];
		numRebuys++;
		rebuyAmount+=thisRebuy;
		
		if(addOnFlg)
			cashoutAmount += thisRebuy;
		else
			cashoutAmount = thisRebuy;
		
		[mo setValue:[NSNumber numberWithDouble:cashoutAmount] forKey:@"cashoutAmount"];
		[mo setValue:[NSNumber numberWithDouble:rebuyAmount] forKey:@"rebuyAmount"];
		[mo setValue:[NSNumber numberWithInt:numRebuys] forKey:@"numRebuys"];

		if(self.gameObj.tournamentGameFlg) {
			int startingChips = self.gameObj.startingChips;
			int rebuyChips = self.gameObj.rebuyChips;
//			rebuyChips += startingChips;
			[mo setValue:[NSString stringWithFormat:@"%d", rebuyChips+startingChips] forKey:@"hudVillianLine"];
			int newChipAmount = startingChips;
			if(addOnFlg)
				newChipAmount = startingChips+(int)self.gameObj.currentChips;
			[mo setValue:[NSString stringWithFormat:@"%d", newChipAmount] forKey:@"hudHeroLine"];
			cashoutAmount = buyInAmount;
			float tCashoutAmount = 0;
			if(self.gameObj.startingChips>0)
				tCashoutAmount = buyInAmount*newChipAmount/(self.gameObj.startingChips+rebuyChips);
			[mo setValue:[NSNumber numberWithFloat:tCashoutAmount] forKey:@"cashoutAmount"];
			thisRebuy = startingChips;
			buyInAmount = self.gameObj.startingChips;
			rebuyAmount = self.gameObj.rebuyChips;
			if(addOnFlg && [ProjectFunctions trackChipsSwitchValue]) {
				[self performSelector:@selector(gotoChipUpdate:) withObject:@"0" afterDelay:.5];
				return;
			}
			
		}
		double amount1 = thisRebuy+thisRebuy-rebuyAmount-buyInAmount;
		double amount2 = cashoutAmount-rebuyAmount-buyInAmount;
		
		if(!addOnFlg)
			[ProjectFunctions createChipTimeStamp:managedObjectContext mo:mo timeStamp:nil amount:amount1 rebuyFlg:NO];
		[NSThread sleepForTimeInterval:0.1];
		[ProjectFunctions createChipTimeStamp:managedObjectContext mo:mo timeStamp:nil amount:amount2 rebuyFlg:YES];
		
		doLiveUpdate=YES;
		
	}
	if(selectedObjectForEdit==9) {
		[mo setValue:value forKey:@"notes"];
	}
	if(self.selectedObjectForEdit==11) {
		[mo setValue:[NSNumber numberWithInt:[value intValue]] forKey:@"tournamentSpots"];
		[self.numberPlayersButton setTitle:value forState:UIControlStateNormal];
		if(self.gameObj.tournamentSpotsPaid==0) {
			self.selectedObjectForEdit=12;
			value = [NSString stringWithFormat:@"%d", [value intValue]/10];
		}
	}
	if(self.selectedObjectForEdit==12) {
		[mo setValue:[NSNumber numberWithInt:[value intValue]] forKey:@"tournamentSpotsPaid"];
		[self.numberSpotPaidButton setTitle:value forState:UIControlStateNormal];
	}
	[self saveDatabase];
	self.gameObj = [GameObj gameObjFromDBObj:mo];
	[self.multiCellObj populateObjWithGame:self.gameObj];
	[self updatePicture];
	[self setUpScreen];
	if(doLiveUpdate)
		[self liveUpdate];
}

@end
