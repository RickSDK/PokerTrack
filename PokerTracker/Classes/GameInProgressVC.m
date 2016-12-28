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

#define kEndGameAlert	1


@implementation GameInProgressVC
@synthesize managedObjectContext, mo;
@synthesize foodButton, tokesButton, chipStackButton, rebuyButton, pauseButton, doneButton;
@synthesize onBreakLabel, timerLabel, buyinLabel, rebuysLabel, rebuyAmountLabel, hourlyLabel, grossLabel, takehomeLabel, profitLabel, pauseTimerLabel;
@synthesize activityIndicator, selectedObjectForEdit, grayPauseBG, infoImage, infoScreenShown;
@synthesize gameInProgress, friendButton, messageString;
@synthesize foodLabel, tokesLabel, currentStackLabel, gameTypeLabel, infoText, cashUpdatedFlg, editButton;
@synthesize userData, startDate, netProfit, totalBreakSeconds, gamePaused, popupViewNumber, addOnFlg;
@synthesize mainTableView, playerTypeImage;

- (void)viewDidLoad {
	[super viewDidLoad];
	[self setTitle:@"In Progress"];
	
	self.userData = [[NSString alloc] init];
	self.valuesArray = [[NSMutableArray alloc] init];
	self.colorsArray = [[NSMutableArray alloc] init];
	
	self.mainTableView.tableHeaderView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0.01f)];
	
	[UIApplication sharedApplication].applicationIconBadgeNumber=1;
	
	self.navigationItem.leftBarButtonItem = [ProjectFunctions navigationButtonWithTitle:@"Main Menu" selector:@selector(mainMenuButtonClicked:) target:self];
	
	self.navigationItem.rightBarButtonItem = [ProjectFunctions navigationButtonWithTitle:@"Info" selector:@selector(infoButtonClicked:) target:self];;
	
	pauseTimerLabel.alpha=0;
	onBreakLabel.alpha=0;
	[activityIndicator startAnimating];
	
	self.selectedObjectForEdit=0;
	self.infoScreenShown=NO;
	self.cashUpdatedFlg=NO;
	editButton.hidden=NO;
	friendButton.alpha=0;
	infoImage.alpha=0;
	infoText.alpha=0;
	
	gameTypeLabel.text = @"Cash Game";
	if([[mo valueForKey:@"Type"] isEqualToString:@"Tournament"]) {
		foodLabel.text = @"# Players";
		tokesLabel.text = @"Finished";
		currentStackLabel.text = @"Winning Amount";
		gameTypeLabel.text = @"Tournament";
	}
	
	[self endWebServiceCall];
	[self displayBadgeNumber];
	[self updatePicture];
	[self setUpScreen];
	[self liveUpdate];
	
	
}

-(BOOL)shouldAutorotate
{
    return YES;
}

- (IBAction) friendButtonPressed: (id) sender
{
    NSArray *elements = [self.userData componentsSeparatedByString:@"<xx>"];
    if([elements count]>4) {
        NSString *basics = [elements stringAtIndex:0];
        NSString *yearStats = [elements stringAtIndex:2];
        NSString *lastGame = [elements stringAtIndex:4];
        if([elements count]>1) {
            FriendInProgressVC *detailViewController = [[FriendInProgressVC alloc] initWithNibName:@"FriendInProgressVC" bundle:nil];
            detailViewController.managedObjectContext=self.managedObjectContext;
			detailViewController.netUserObj=self.netUserObj;
 //           detailViewController.userValues=[NSString stringWithFormat:@"100<xx>%@<xx>%@<xx>%@<aa>%@", yearStats, basics, lastGame, self.userData];
            [self.navigationController pushViewController:detailViewController animated:YES];
        };
    } else {
        [ProjectFunctions showAlertPopup:@"Data Sync Error" message:@""];
    }
}

- (IBAction) editButtonPressed: (id) sender
{
	[mo setValue:[NSDate date] forKey:@"endTime"];
	[managedObjectContext save:nil];
	GameDetailsVC *detailViewController = [[GameDetailsVC alloc] initWithNibName:@"GameDetailsVC" bundle:nil];
	detailViewController.managedObjectContext = managedObjectContext;
	detailViewController.viewEditable = YES;
	detailViewController.mo = mo;
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
	if([[mo valueForKey:@"Type"] isEqualToString:@"Tournament"]) {
		MinuteEnterVC *detailViewController = [[MinuteEnterVC alloc] initWithNibName:@"MinuteEnterVC" bundle:nil];
		detailViewController.callBackViewController = self;
        detailViewController.managedObjectContext=self.managedObjectContext;
		detailViewController.sendTitle = @"Total # Players";
		detailViewController.initialDateValue = [NSString stringWithFormat:@"%@", foodButton.titleLabel.text];
		[self.navigationController pushViewController:detailViewController animated:YES];
	} else {
		MoneyPickerVC *detailViewController = [[MoneyPickerVC alloc] initWithNibName:@"MoneyPickerVC" bundle:nil];
		detailViewController.callBackViewController = self;
		detailViewController.managedObjectContext=managedObjectContext;
		detailViewController.titleLabel = @"Total Food/Drinks";
		detailViewController.initialDateValue = [NSString stringWithFormat:@"%@", foodButton.titleLabel.text];
		[self.navigationController pushViewController:detailViewController animated:YES];
	}
}
- (IBAction) tokesButtonPressed: (id) sender
{
	self.selectedObjectForEdit=2;
	if([[mo valueForKey:@"Type"] isEqualToString:@"Tournament"]) {
		MinuteEnterVC *detailViewController = [[MinuteEnterVC alloc] initWithNibName:@"MinuteEnterVC" bundle:nil];
		detailViewController.callBackViewController = self;
        detailViewController.managedObjectContext=self.managedObjectContext;
		detailViewController.sendTitle = @"Place Finished";
		detailViewController.initialDateValue = [NSString stringWithFormat:@"%@", tokesButton.titleLabel.text];
		[self.navigationController pushViewController:detailViewController animated:YES];
	} else {
		MoneyPickerVC *detailViewController = [[MoneyPickerVC alloc] initWithNibName:@"MoneyPickerVC" bundle:nil];
		detailViewController.managedObjectContext=managedObjectContext;
		[detailViewController setCallBackViewController:self];
		detailViewController.titleLabel = @"Total Dealer Tips";
		detailViewController.initialDateValue = [NSString stringWithFormat:@"%@", tokesButton.titleLabel.text];
		[self.navigationController pushViewController:detailViewController animated:YES];
	}
}
- (IBAction) chipsButtonPressed: (id) sender
{
	self.cashUpdatedFlg=YES;
	self.selectedObjectForEdit=3;
    self.popupViewNumber=0;
	MoneyPickerVC *detailViewController = [[MoneyPickerVC alloc] initWithNibName:@"MoneyPickerVC" bundle:nil];
	detailViewController.callBackViewController = self;
	detailViewController.managedObjectContext=managedObjectContext;
	detailViewController.titleLabel = @"Current Chips";
	detailViewController.initialDateValue = [NSString stringWithFormat:@"%@", chipStackButton.titleLabel.text];
	[self.navigationController pushViewController:detailViewController animated:YES];
}



- (IBAction) rebuyButtonPressed: (id) sender 
{
	self.selectedObjectForEdit=4;
    self.popupViewNumber=99;
    [ProjectFunctions showTwoButtonPopupWithTitle:@"Rebuy" message:@"Select Rebuy Type" button1:@"Add-on" button2:@"Re-buy" delegate:self];
    
}

-(void)pauseScreen {
	NSLog(@"Screen is paused");
	self.chipStackButton.enabled=NO;
	self.doneButton.enabled=NO;
	[activityIndicator stopAnimating];
	onBreakLabel.alpha=1;
	grayPauseBG.alpha=.5;
	[pauseButton setTitle:@"Resume" forState:UIControlStateNormal];
}

-(void)unPauseScreen {
	self.doneButton.enabled=YES;
	self.chipStackButton.enabled=YES;
	[activityIndicator startAnimating];
	onBreakLabel.alpha=0;
	grayPauseBG.alpha=0;
	[pauseButton setTitle:@"Pause" forState:UIControlStateNormal];
}

- (IBAction) pauseButtonPressed: (id) sender
{
    pauseTimerLabel.alpha=1;
	self.gamePaused = ! self.gamePaused;
	
	 if(self.gamePaused) {
		 [mo setValue:[NSDate date] forKey:@"endTime"];
		 [mo setValue:@"Y" forKey:@"onBreakFlag"];
		 [managedObjectContext save:nil];
		 [self pauseScreen];
	 } else {
		 int totalSeconds = [[NSDate date] timeIntervalSinceDate:[mo valueForKey:@"endTime"]];
		 int breakMinutes = [[mo valueForKey:@"breakMinutes"] intValue];
		 breakMinutes += totalSeconds/60;
		 [mo setValue:[NSNumber numberWithInt:breakMinutes] forKey:@"breakMinutes"];
		 [mo setValue:@"N" forKey:@"onBreakFlag"];
		 [managedObjectContext save:nil];
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
	self.chipStackButton.enabled=NO;
	self.rebuyButton.enabled=NO;
	self.pauseButton.enabled=NO;
}

-(void)endWebServiceCall {
	NSLog(@"+++endWebServiceCall");
	[self.webServiceView stop];
	self.chipStackButton.enabled=YES;
	self.rebuyButton.enabled=YES;
	self.pauseButton.enabled=YES;
	self.doneButton.enabled=YES;
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



-(void)completeGame {
    self.selectedObjectForEdit=0;
	self.gameInProgress=NO;
	[self startWebServiceCall:@"Ending Game"];
	
	grayPauseBG.alpha=.75;
	int buyIn = [[mo valueForKey:@"buyInAmount"] intValue];
	int rebuyAmount = [[mo valueForKey:@"rebuyAmount"] intValue];
	
	float foodMoney = [ProjectFunctions getMoneyValueFromText:foodButton.titleLabel.text];
	float tokes = [ProjectFunctions getMoneyValueFromText:tokesButton.titleLabel.text];
	float chips = [ProjectFunctions getMoneyValueFromText:chipStackButton.titleLabel.text];
	if([[mo valueForKey:@"Type"] isEqualToString:@"Tournament"]) {
		[mo setValue:[NSNumber numberWithInt:foodMoney] forKey:@"tournamentSpots"];
		[mo setValue:[NSNumber numberWithInt:tokes] forKey:@"tournamentFinish"];
		[mo setValue:[NSNumber numberWithInt:(foodMoney/10)+2] forKey:@"breakMinutes"];
		foodMoney=0;
	}
	
	[ProjectFunctions createChipTimeStamp:managedObjectContext mo:mo timeStamp:nil amount:chips+foodMoney-buyIn-rebuyAmount rebuyFlg:NO];


	self.netProfit = chips+foodMoney-buyIn-rebuyAmount;
	if([[mo valueForKey:@"Type"] isEqualToString:@"Tournament"])
		netProfit = chips-buyIn-rebuyAmount;
	
	int seconds = [[NSDate date] timeIntervalSinceDate:[mo valueForKey:@"startTime"]];
	int breakMinutes = [[mo valueForKey:@"breakMinutes"] intValue];
	seconds -= breakMinutes*60;
	int minutes = seconds/60;
	float hours = (float)seconds/3600;
	
	[mo setValue:[NSNumber numberWithInt:netProfit] forKey:@"winnings"];
	[mo setValue:[NSNumber numberWithInt:breakMinutes] forKey:@"breakMinutes"];
	[mo setValue:[NSNumber numberWithInt:minutes] forKey:@"minutes"];
	[mo setValue:@"Completed" forKey:@"status"];
	[mo setValue:[NSDate date] forKey:@"endTime"];
	[mo setValue:[NSString stringWithFormat:@"%.1f", hours] forKey:@"hours"];
	
	
	[managedObjectContext save:nil];
	
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
			[ProjectFunctions showAlertPopupWithDelegate:@"Data not backed up" message:[NSString stringWithFormat:@"Note: You have %d games on device that haven't been backed up. If you lose your phone you will lose this data. To back up your data go to the 'More' menu and click 'Export Data'.", gamesSinceSync] delegate:self];
		
	} else {
		[self endWebServiceCall];
		if(gamesSinceSync>1 && gamesSinceSync%10==0)
			[ProjectFunctions showAlertPopupWithDelegate:@"Data not backed up" message:[NSString stringWithFormat:@"Note: You have %d games on device that haven't been backed up. If you lose your phone you will lose this data. To back up your data go to the 'More' menu and click 'Export Data'.", gamesSinceSync] delegate:self];
		else
			[ProjectFunctions showAlertPopupWithDelegate:@"Game Over!" message:@"Game data has been saved" delegate:self];


	}


}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *cellIdentifier = [NSString stringWithFormat:@"cellIdentifierSection%ldRow%ld", (long)indexPath.section, (long)indexPath.row];

	NSArray *titles = [NSArray arrayWithObjects:@"Game Type", @"BuyIn", @"# Rebuys", @"Rebuy Amount", @"Current Chips", @"Gross Earnings", @"Take-Home", @"Net Profit", @"Game Minutes", @"Notes", nil];
	MultiLineDetailCellWordWrap *cell = (MultiLineDetailCellWordWrap *) [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (cell == nil) {
		cell = [[MultiLineDetailCellWordWrap alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier withRows:[titles count] labelProportion:0.5];
	}
	

	cell.mainTitle = [[mo valueForKey:@"startTime"] convertDateToStringWithFormat:@"EEEE hh:mm a"];
	cell.alternateTitle = [NSString stringWithFormat:@"%@", [mo valueForKey:@"location"]];
	cell.titleTextArray = titles;
	cell.fieldTextArray = self.valuesArray;
	cell.fieldColorArray = self.colorsArray;

	cell.accessoryType= UITableViewCellAccessoryNone;
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
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
		return [MultiLineDetailCellWordWrap cellHeightWithNoMainTitleForData:[NSArray arrayWithObject:[mo valueForKey:@"notes"]]
																   tableView:self.mainTableView
														labelWidthProportion:0.4]+10*18;
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
            if(buttonIndex==0)
                self.addOnFlg=YES;
            else {
                self.addOnFlg=NO;
                intitialAmount=@"0";
            }
            
            MoneyPickerVC *detailViewController = [[MoneyPickerVC alloc] initWithNibName:@"MoneyPickerVC" bundle:nil];
            detailViewController.managedObjectContext=managedObjectContext;
            [detailViewController setCallBackViewController:self];
            detailViewController.titleLabel = @"Re-buy Amount";
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
	[ProjectFunctions showConfirmationPopup:@"End Game?" message:[NSString stringWithFormat:@"Leaving game with %@?", chipStackButton.titleLabel.text] delegate:self tag:kEndGameAlert];
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

	[self setupArrays];

    NSString *foodButtonText = @"";
    NSString *tokesButtonText = @"";
    NSString *chipsButtonText = @"";


        int foodDrinks=0;
        int tokesMoney = 0;
        if([[mo valueForKey:@"Type"] isEqualToString:@"Tournament"]) {
            int numPlayers = [[mo valueForKey:@"foodDrinks"] intValue];
            if(numPlayers==0)
                numPlayers=10;
            int placeFinished = [[mo valueForKey:@"tokes"] intValue];
            if(placeFinished==0)
                placeFinished=5;
            foodButtonText = [NSString stringWithFormat:@"%d", numPlayers];
            tokesButtonText = [NSString stringWithFormat:@"%d", placeFinished];
        } else {
            foodDrinks = [[mo valueForKey:@"foodDrinks"] intValue];
            tokesMoney = [[mo valueForKey:@"tokes"] intValue];
            foodButtonText = [NSString stringWithFormat:@"%@%d", [ProjectFunctions getMoneySymbol], [[mo valueForKey:@"foodDrinks"] intValue]];
            tokesButtonText = [NSString stringWithFormat:@"%@%d", [ProjectFunctions getMoneySymbol], [[mo valueForKey:@"tokes"] intValue]];
        }
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

        [buyinLabel performSelectorOnMainThread:@selector(setText: ) withObject:[ProjectFunctions displayMoney:mo column:@"buyInAmount"] waitUntilDone:YES];
        [rebuysLabel performSelectorOnMainThread:@selector(setText: ) withObject:[NSString stringWithFormat:@"%d",[[mo valueForKey:@"numRebuys"] intValue] ] waitUntilDone:YES];
        [rebuyAmountLabel performSelectorOnMainThread:@selector(setText: ) withObject:[ProjectFunctions displayMoney:mo column:@"rebuyAmount"] waitUntilDone:YES];

        double chips = [[mo valueForKey:@"cashoutAmount"] doubleValue];
	
        self.netProfit = chips+foodDrinks-buyIn-rebuyAmount;
        int grossEarnings = netProfit+tokesMoney;
        int takeHome = netProfit-foodDrinks;
        
        
        if([[mo valueForKey:@"Type"] isEqualToString:@"Tournament"]) {
            netProfit = chips-buyIn-rebuyAmount;
            grossEarnings = netProfit;
            takeHome = netProfit;
        }
        

        [grossLabel performSelectorOnMainThread:@selector(setText: ) withObject:[ProjectFunctions convertIntToMoneyString:grossEarnings] waitUntilDone:YES];
        [takehomeLabel performSelectorOnMainThread:@selector(setText: ) withObject:[ProjectFunctions convertIntToMoneyString:takeHome] waitUntilDone:YES];
        [profitLabel performSelectorOnMainThread:@selector(setText: ) withObject:[ProjectFunctions convertIntToMoneyString:netProfit] waitUntilDone:YES];

        
        // hourly-----
        NSString *hourlytext = @"-";
        if(totalSeconds>0)
            hourlytext = [NSString stringWithFormat:@"%@%d/hr", [ProjectFunctions getMoneySymbol], netProfit*3600/totalSeconds];
        
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
        

        [pauseTimerLabel performSelectorOnMainThread:@selector(setText: ) withObject:pauseTimerText waitUntilDone:YES];
        [hourlyLabel performSelectorOnMainThread:@selector(setText: ) withObject:hourlytext waitUntilDone:YES];
	float fontSize = chipsButtonText.length>7?26.0:32.0;
	chipStackButton.titleLabel.font = [UIFont boldSystemFontOfSize:fontSize];

        dispatch_async(dispatch_get_main_queue(), ^{
            [foodButton setTitle:foodButtonText forState:UIControlStateNormal];
            [tokesButton setTitle:tokesButtonText forState:UIControlStateNormal];
            [chipStackButton setTitle:chipsButtonText forState:UIControlStateNormal];
        }
                       );


}

- (void) infoButtonClicked:(id)sender {
	self.infoScreenShown = !infoScreenShown;
	infoImage.alpha=infoScreenShown;
	infoText.alpha=infoScreenShown;
}

-(void)mainMenuButtonClicked:(id)sender {
	[self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
}




-(void)countTheCounter
{
	@autoreleasepool {
		
		if(self.gameInProgress && self.viewLoadedFlg)
            [self refreshScreen];
        
		[NSThread sleepForTimeInterval:.8];
        
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
    
    self.playerTypeImage.image = [ProjectFunctions getPlayerTypeImage:risked winnings:profit];
}

-(void)doLiveUpdate {
	@autoreleasepool {
        [ProjectFunctions uploadUniverseStats:managedObjectContext]; // web service call
        self.userData = [ProjectFunctions getFriendsPlayingData]; // web service call
        friendButton.alpha=0;
        if([self.userData length]>10) {
			self.netUserObj = [NetUserObj userObjFromString:self.userData];
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
//		[self startWebServiceCall:@"Updating Server"];
        [self performSelectorInBackground:@selector(doLiveUpdate) withObject:nil];
    }
}


-(void)setupArrays {
	
	
	double buyIn = [[mo valueForKey:@"buyInAmount"] doubleValue];
	double rebuyAmount = [[mo valueForKey:@"rebuyAmount"] doubleValue];
	
	
	
	double chips = [[mo valueForKey:@"cashoutAmount"] doubleValue];
	int foodDrinks = [[mo valueForKey:@"foodDrinks"] intValue];
	int tokesMoney = [[mo valueForKey:@"tokes"] intValue];
	
	if([[mo valueForKey:@"Type"] isEqualToString:@"Tournament"]) {
		foodDrinks=0;
		tokesMoney=0;
	}
	
	self.netProfit = chips+foodDrinks-buyIn-rebuyAmount;
	double grossEarnings = self.netProfit+tokesMoney;
	double takeHome = self.netProfit-foodDrinks;

	
	[self.valuesArray removeAllObjects];
	[self.valuesArray addObject:[self.mo valueForKey:@"Type"]];
	[self.valuesArray addObject:[ProjectFunctions convertIntToMoneyString:(int)[[self.mo valueForKey:@"buyInAmount"] doubleValue]]];
	[self.valuesArray addObject:[NSString stringWithFormat:@"%d", (int)[[self.mo valueForKey:@"numRebuys"] intValue]]];
	[self.valuesArray addObject:[ProjectFunctions convertIntToMoneyString:[[self.mo valueForKey:@"rebuyAmount"] doubleValue]]];
	
	
	[self.valuesArray addObject:[ProjectFunctions convertIntToMoneyString:(int)[[self.mo valueForKey:@"cashoutAmount"] doubleValue]]];
	[self.valuesArray addObject:[ProjectFunctions convertIntToMoneyString:grossEarnings]];
	[self.valuesArray addObject:[ProjectFunctions convertIntToMoneyString:takeHome]];
	
	self.startDate = [mo valueForKey:@"startTime"];
	int totalSeconds = [[NSDate date] timeIntervalSinceDate:startDate];
	if(totalSeconds>0)
		[self.valuesArray addObject:[NSString stringWithFormat:@"%@ (%@/hr)", [ProjectFunctions convertIntToMoneyString:self.netProfit], [ProjectFunctions convertIntToMoneyString:self.netProfit*3600/totalSeconds]]];
	else
		[self.valuesArray addObject:[ProjectFunctions convertIntToMoneyString:self.netProfit]];
	
	int breakMinutes = [[self.mo valueForKey:@"breakMinutes"] intValue];
	if (breakMinutes>0)
		[self.valuesArray addObject:[NSString stringWithFormat:@"%d (%d on break)", (totalSeconds/60)-breakMinutes, breakMinutes]];
	else
		[self.valuesArray addObject:[NSString stringWithFormat:@"%d min", totalSeconds/60]];


	[self.valuesArray addObject:[self.mo valueForKey:@"notes"]];
	
	[self.colorsArray removeAllObjects];
	[self.colorsArray addObject:[UIColor blackColor]];
	[self.colorsArray addObject:[UIColor blackColor]];
	[self.colorsArray addObject:[UIColor blackColor]];
	[self.colorsArray addObject:[UIColor blackColor]];
	[self.colorsArray addObject:[UIColor blackColor]];
	[self.colorsArray addObject:[self colorOfMoney:grossEarnings]];
	[self.colorsArray addObject:[self colorOfMoney:takeHome]];
	[self.colorsArray addObject:[self colorOfMoney:self.netProfit]];
	[self.colorsArray addObject:[UIColor blackColor]];
	[self.colorsArray addObject:[UIColor blackColor]];
	[self.mainTableView reloadData];
	
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

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
	
    if([self respondsToSelector:@selector(edgesForExtendedLayout)])
        [self setEdgesForExtendedLayout:UIRectEdgeBottom];
	
    self.popupViewNumber=0;
    if([[mo valueForKey:@"onBreakFlag"] isEqualToString:@"Y"]) {
		self.gamePaused=YES;
		[self pauseScreen];
	} else
		self.gamePaused=NO;
	
	self.viewLoadedFlg=YES;
	self.gameInProgress=YES;
	
	[self performSelectorInBackground:@selector(countTheCounter) withObject:nil];
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
		[mo setValue:[NSNumber numberWithInt:[value intValue]] forKey:@"tokes"];
	}
	if(selectedObjectForEdit==3) {
		// set current chip stack
		double buyInAmount = [[mo valueForKey:@"buyInAmount"] doubleValue];
		double rebuyAmount = [[mo valueForKey:@"rebuyAmount"] doubleValue];
		[mo setValue:[NSNumber numberWithFloat:[value doubleValue]] forKey:@"cashoutAmount"];
		double chips = [value doubleValue];
		[ProjectFunctions createChipTimeStamp:managedObjectContext mo:mo timeStamp:nil amount:chips-rebuyAmount-buyInAmount rebuyFlg:NO];
		doLiveUpdate=YES;
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
		
		int amount1 = thisRebuy+thisRebuy-rebuyAmount-buyInAmount;
		int amount2 = cashoutAmount-rebuyAmount-buyInAmount;
		if(!addOnFlg)
			[ProjectFunctions createChipTimeStamp:managedObjectContext mo:mo timeStamp:nil amount:amount1 rebuyFlg:NO];
		[NSThread sleepForTimeInterval:0.1];
		[ProjectFunctions createChipTimeStamp:managedObjectContext mo:mo timeStamp:nil amount:amount2 rebuyFlg:YES];
		
		[mo setValue:[NSNumber numberWithDouble:cashoutAmount] forKey:@"cashoutAmount"];
		[mo setValue:[NSNumber numberWithDouble:rebuyAmount] forKey:@"rebuyAmount"];
		[mo setValue:[NSNumber numberWithInt:numRebuys] forKey:@"numRebuys"];
		doLiveUpdate=YES;
		
	}
	if(selectedObjectForEdit==9) {
		[mo setValue:value forKey:@"notes"];
	}
	NSError *error = nil;
	if (![managedObjectContext save:&error]) {
		NSLog(@"Error whoa! %@", error.localizedDescription);
	}
	[self updatePicture];
	[self setUpScreen];
	if(doLiveUpdate)
		[self liveUpdate];
	
}





@end
