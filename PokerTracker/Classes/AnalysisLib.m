//
//  AnalysisLib.m
//  PokerTracker
//
//  Created by Rick Medved on 2/7/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "AnalysisLib.h"
#import "NSDate+ATTDate.h"
#import "CoreDataLib.h"
#import "NSArray+ATTArray.h"
#import "ProjectFunctions.h"


@implementation AnalysisLib

+(NSString *)getAnalysisForPlayer:(NSManagedObjectContext *)managedObjectContext
						predicate:(NSPredicate *)predicate
					  displayYear:(int)displayYear
						 gameType:(NSString *)gameType
						last10Flg:(BOOL)last10Flg
					 amountRisked:(int)amountRisked
					   foodDrinks:(int)foodDrinks
							tokes:(int)tokes
					 grosssIncome:(int)grosssIncome
				   takehomeIncome:(int)takehomeIncome
						netIncome:(int)netIncome
							limit:(int)limit
{

    NSString *currentYearStr = [[NSDate date] convertDateToStringWithFormat:@"yyyy"];
    NSPredicate *predicateYear = [NSPredicate predicateWithFormat:@"user_id = 0 AND year = %@", currentYearStr];
    NSArray *gamesYear = [CoreDataLib selectRowsFromEntity:@"GAME" predicate:predicateYear sortColumn:nil mOC:managedObjectContext ascendingFlg:NO];
    int numGamesThisYear = (int)[gamesYear count];

	int currentYear = [[[NSDate date] convertDateToStringWithFormat:@"yyyy"] intValue];
	int gameCount = [[CoreDataLib getGameStatWithLimit:managedObjectContext dataField:@"gameCount" predicate:predicate limit:limit] intValue];
	int totalWins = [[CoreDataLib getGameStatWithLimit:managedObjectContext dataField:@"totalWins" predicate:predicate limit:limit] intValue];
	int totalLosses = [[CoreDataLib getGameStatWithLimit:managedObjectContext dataField:@"totalLosses" predicate:predicate limit:limit] intValue];
	NSString *winString = (totalWins==1)?@"1 win":[NSString stringWithFormat:@"%d wins", totalWins];
	NSString *loseString = (totalLosses==1)?@"1 loss":[NSString stringWithFormat:@"%d losses", totalLosses];
	int streak = [[CoreDataLib getGameStat:managedObjectContext dataField:@"streak" predicate:predicate] intValue];
	BOOL lastGameWon=YES;

	int playerOverallSkill = [ProjectFunctions getPlayerType:amountRisked winnings:netIncome];

	NSString *pokerType = @"Poker";
	if([gameType isEqualToString:@"Cash"])
		pokerType = @"Cash Game";
	if([gameType isEqualToString:@"Tournament"])
		pokerType = @"Tournament";

	NSString *location= nil;
	NSString *daytime= nil;
	NSString *weekday= nil;
	int winnings=0;
	int buyIn=0;
	int rebuyAmount=0;
	int amountRisked2=0;
	NSArray *games = [CoreDataLib selectRowsFromEntity:@"GAME" predicate:predicate sortColumn:@"startTime" mOC:managedObjectContext ascendingFlg:NO];
	NSArray *allTimeGames = [CoreDataLib selectRowsFromEntity:@"GAME" predicate:nil sortColumn:@"startTime" mOC:managedObjectContext ascendingFlg:NO];
	int totalGameCount = (int)[allTimeGames count];
	
	if([games count]>0) {
		NSManagedObject *fisrtGame = [games objectAtIndex:0];
		location = [fisrtGame valueForKey:@"location"];
		weekday = [fisrtGame valueForKey:@"weekday"];
		daytime = [[fisrtGame valueForKey:@"daytime"] lowercaseString];
		winnings = [[fisrtGame valueForKey:@"winnings"] intValue];
		buyIn = [[fisrtGame valueForKey:@"buyInAmount"] intValue];
		rebuyAmount = [[fisrtGame valueForKey:@"rebuyAmount"] intValue];
		amountRisked2=buyIn+rebuyAmount;
		if(winnings<0)
			lastGameWon=NO;
	}
	int lastGameSkill = [ProjectFunctions getPlayerType:amountRisked2 winnings:winnings];
	NSString *winLossAmount = [ProjectFunctions convertIntToMoneyString:winnings];
	if(winnings<0)
		winLossAmount = [ProjectFunctions convertIntToMoneyString:(winnings*-1)];
	NSString *overallWinLossAmount = [ProjectFunctions convertIntToMoneyString:netIncome];
	if(netIncome<0)
		overallWinLossAmount = [ProjectFunctions convertIntToMoneyString:(netIncome*-1)];

	//################################## First 10 Games ######################################
	if((last10Flg || displayYear==0) && gameCount<=2) {
		if(gameCount==0)
			return @"Welcome to PokerTrack Game Analyzer. Look to this page for analysis of your game and helpful advice!";
		
		if(gameCount==1) {
			NSArray *adjectiveList = [NSArray arrayWithObjects:@"terrible", @"rough", @"decent", @"great", @"fantastic", nil];
			NSArray *adjectiveList2 = [NSArray arrayWithObjects:@"slow", @"slow", @"good", @"good", @"good", nil];
			NSString *adjective = [adjectiveList stringAtIndex:lastGameSkill];
			NSString *adjective2 = [adjectiveList2 stringAtIndex:lastGameSkill];
			NSString *winString = [NSString stringWithFormat:@"winning %@", [ProjectFunctions convertIntToMoneyString:winnings]];
			NSString *finalComment = @"Let's hope the solid play and good cards continue.";
			if(winnings<0) {
				winnings *= -1;
				finalComment = @"Let's hope your luck turns around with the next game.";
				winString = [NSString stringWithFormat:@"losing %@", [ProjectFunctions convertIntToMoneyString:winnings]];
			}
			return [NSString stringWithFormat:@"You are off to a %@ start after a %@ game at %@, %@ on the %@. %@", adjective2, adjective, location, winString, daytime, finalComment];
		}
		
		if(gameCount==2) {
			NSString *opening=nil;
			NSString *middle=nil;
			NSString *closing=nil;
			if(streak==-2) {
				winnings *=-1;
				opening = @"Ouch!";
				if(lastGameSkill==0)
					middle = [NSString stringWithFormat:@"Another crash and burn session this %@ at %@ losing %@ and racking up your second loss.", daytime, location, [ProjectFunctions convertIntToMoneyString:winnings]];
				else 
					middle = [NSString stringWithFormat:@"Another disappointing %@ at %@ losing %@ and racking up your second loss, but at least you were able to walk away from the table with some chips.", daytime, location, [ProjectFunctions convertIntToMoneyString:winnings]];
				closing = @"It's ok though, not time to panic. Everyone goes card dead from time to time and we all take our bad beats.";
			}
			if(streak==-1) {
				winnings *=-1;
				opening = [NSString stringWithFormat:@"Well you win some, you lose some and this just wasn't your %@.", daytime];
				if(netIncome>0)
					middle = [NSString stringWithFormat:@"Tough outing at %@, losing %@ in a game that just wasn't meant to be, but the good news is that you are up %@ after 2 games.", location, [ProjectFunctions convertIntToMoneyString:winnings], [ProjectFunctions convertIntToMoneyString:netIncome]];
				else 
					middle = [NSString stringWithFormat:@"Rough outing at %@, losing %@ in a game that just wasn't meant to be.", location, [ProjectFunctions convertIntToMoneyString:winnings]];
				closing = @"Ok its one good game, one bad game and moving on from here.";
			}
			if(streak==1) {
				opening = @"That's how you play poker!";
				if(netIncome>0)
					middle = [NSString stringWithFormat:@"Great night %@, recovering from the previous loss by winning %@ and getting your overall money in the black.", location, [ProjectFunctions convertIntToMoneyString:winnings]];
				else 
					middle = [NSString stringWithFormat:@"Good win at %@, for %@ which helped recover some of the losses from your first game.", location, [ProjectFunctions convertIntToMoneyString:winnings]];
				closing = @"Now that you are on a winning streak, its time to push forward and really get your bankroll moving.";
			}
			if(streak==2) {
				opening = @"Outstanding! You are making poker look easy.";
				if(lastGameSkill>2)
					middle = [NSString stringWithFormat:@"Not just another win, but a big win at %@, winning %@ and bumping your overall bankroll to %@ after 2 games.", location, [ProjectFunctions convertIntToMoneyString:winnings], [ProjectFunctions convertIntToMoneyString:netIncome]];
				else 
					middle = [NSString stringWithFormat:@"That's 2 wins in 2 games after taking %@ at %@ this %@.", [ProjectFunctions convertIntToMoneyString:winnings], location, daytime];
				closing = @"Great start. Keep it going.";
			}
			return [NSString stringWithFormat:@"%@ %@ %@", opening, middle, closing];
		}
	}
	
	
	
	
	//################################## LAST 10 ######################################
	if(last10Flg) {
        
        
        
		NSString *opening = @"";
		NSString *lastGameDetails = @"";
		NSString *closing = @"";
		NSArray *adjectives = [NSArray arrayWithObjects:@"devastating", @"small", @"little", @"decent", @"monster", nil];
		NSArray *adjectives2 = [NSArray arrayWithObjects:@"painful", @"slim", @"slight", @"respectable", @"huge", nil];
		NSArray *adjectives3 = [NSArray arrayWithObjects:@"crushing", @"moderate", @"modest", @"large", @"tremendous", nil];
		NSString *adjectGame = [adjectives stringAtIndex:lastGameSkill];
        
        if(totalGameCount%3==0)
            adjectGame = [adjectives2 stringAtIndex:lastGameSkill];

        if(totalGameCount%3==1)
            adjectGame = [adjectives3 stringAtIndex:lastGameSkill];

        switch (playerOverallSkill) {
			case 0:
				switch (lastGameSkill) {
					case 0:
						if(streak==-1) {
							opening = @"Yikes! Just when you thought your game could not get any worse, guess what? Its getting worse.";
							closing = @"This is pretty bad. Not only have you proven that you can lose, but that you can lose big.";
						} else { 
							opening = @"This month started out on a bad note and has gone downhill quickly from there. And I'm talking about your better games.";
							closing = @"I'm not sure if there has ever been a worse poker player. There was once this guy in Chattanooga that was pretty bad, but wait, no he won a game once.";
						}
						break;
					case 1:
						if(streak==-1) {
							opening = @"It's very possible that maybe poker is not your best game. Are you even looking at your cards before making those horrible bets?";
							closing = @"Hmmm... this is flat out ugly. Maybe a trip to your local book store to pick up Poker for Dummies?";
						} else { 
							opening = @"Calling your poker play a train wreck is giving you too much credit. This is a nuclear powered train crashing into the Titanic at Chernobyl!";
							closing = @"I am going to recommend some books to help you out. Starting with Gardening for Dummies. I think that might be a better use of your time.";
						}
						break;
					case 2:
						if(streak==1) {
							opening = @"Whoa. You won some chips? Who were you playing against? Your grandma at the retirement home?";
							closing = @"Every win helps, but you really need to work on the game fundamentals.";
						} else { 
							opening = @"This poker game of yours flat out sucks, but we are starting to see some signs of improvement.";
							closing = @"There might be a little hope in this disaster of a poker game you have.";
						}
						break;
					case 3:
						if(streak==1) {
							opening = @"Finally! At last a winning game after all the recent carnage.";
							closing = @"Now that you have discovered how to win at poker, maybe you can start climbing out of the hole your bankroll is currently in.";
						} else { 
							opening = @"Two good games in a row? I'm shocked! Who is coaching you? That guy deserves an award.";
							closing = @"We are almost ready to start calling you a fish and, believe me, with your poker game that's a huge compliment.";
						}
						break;
					case 4:
						if(streak==1) {
							opening = @"Wow! Even a blind squirrel finds a nut once in a while! And tonight, my friend, this was your blind squirrel night.";
							closing = @"Hopefully this latest game is a sign that you have discovered new talents because otherwise... well lets not think about the otherwise.";
						} else { 
							opening = @"I don't know what you changed recently, but whatever is was, don't go back to your old style!";
							closing = @"Keep it going. Some day they will write books about you... the Little Donkey who Could.";
						}
						break;
				}
			case 1:
				switch (lastGameSkill) {
					case 0:
						if(streak==-1) {
							opening = @"This is like watching a heavy-weight prize fighter. A prize fighter who's getting his lights knocked out, that is.";
							closing = @"The great thing about poker is that you are only one cash-machine visit away from being back in the game! It might be time to try some new strategies. This 'any two cards' strategy is not going so well.";
						} else {
							opening = @"Poker is a game of patience and bet sizing. You have demonstrated a remarkable deficientcy in both.";
							closing = @"I am going to recommend some books to help you out. Starting with Gardening for Dummies. I think that might be a better use of your time.";
						}

						break;
					case 1:
						if(streak==-1) {
							opening = @"Oh my. You've been playing pretty bad poker lately... and its getting worse.";
							closing = @"Have you considered taking up tennis? Maybe golfing? Bingo might be better suited for your 'talents'.";
						} else {
							opening = @"The bad breaks keep coming and they don't stop coming. Who taught you how to play poker anyways? I mean, come on!";
							closing = @"You need to turn this game around and turn it around fast. Because you are quickly approaching donkey territory!";
						}
						
						break;
					case 2:
						if(streak==1) {
							opening = @"Ok here we go. Nothing like winning some money at the poker table to put a smile on your face.";
							closing = @"Your game needs some fine tuning but its starting to show some flashes of... well... ok'ness.";
						} else {
							opening = @"Finally you are starting to play like you know what you are doing.";
							closing = @"After winning 2 in a row I think you may finally be playing some good poker. Or at least less-bad poker.";
						}
						
						break;
					case 3:
						if(streak==1) {
							opening = @"You have played some pretty bad poker lately, but things might be starting to turn around.";
							closing = @"Nice job on the last game. Hopefully the good play and big wins continue.";
						} else {
							opening = @"Now you are starting to get in a rhythm. You keep this up and we might stop calling you a fish.";
							closing = @"Nice little streak of 2 wins in a row. Keep it going.";
						}
						
						break;
					case 4:
						if(streak==1) {
							opening = @"Amazing! Wins have been kinda rare for you lately and this was not just a win, but a big win!";
							closing = @"This latest win helps put a bandaid over the bloodbath that's been your bankroll lately.";
						} else {
							opening = @"Pow! Another big win for the little guy who's been fighting to be taken seriously at the poker table.";
							closing = @"You are finally digging your way out of the hole. And digging out quickly. Keep it up.";
						}
						
						break;
				}
				break;
			case 2:
				switch (lastGameSkill) {
					case 0:
						if(streak==-1) {
							opening = @"Poker is a game of highs and lows and right now you are playing off a low.";
							closing = @"The goal is to brush off the recent loss and get back to winning.";
						} else {
							opening = @"Back to back craps. Crappy games that is. Times is tough.";
							closing = @"It's now time to turn this game around and get back to winning.";
						}
						break;
					case 1:
						if(streak==-1) {
							opening = @"Another rough outing at the poker tables but at least you walked away with some chips.";
							closing = @"The good news is that even with your losses you are generally playing smart and making good folds. Keep it going with the next game.";
						} else {
							opening = @"The bad beats keep coming and they don't stop coming. This is not shaping up to be a good week.";
							closing = @"Going through small slumps is part of the game. No big deal. Concentrate on solid poker and you will be fine.";
						}						
						break;
					case 2:
						if(streak==1) {
							opening = @"Nice job on your last game. Grinding out wins and playing very steady, solid poker is what it's all about.";
							closing = @"The important thing is to keep playing solid poker, keep making great laydowns, and don't get crazy with the bluffs.";
						} else {
							opening = @"Another day, another win. You are making some good bets and good folds lately which is leading to positive stats.";
							closing = @"Keep the winning streak going by playing good poker and making great laydowns.";
						}
						break;
					case 3:
						if(streak==1) {
							opening = @"Great job pulling off a win. Things are looking much better after that last game.";
							closing = @"Playing solid poker is the key to this game. Keep it up.";
						} else {
							opening = @"Not bad not bad. Another solid win for the good guys.";
							closing = @"Now that you have your game dialed in, you are ready to start winning some serious cash.";
						}
						break;
					case 4:
						if(streak==1) {
							opening = @"Great game! Poker is so much better when you are winning. And winning big.";
							closing = @"This might be the time for you to break out and become a really great poker player.";
						} else {
							opening = @"Sha-Powie! Your game is on fire. There might be another shark in the shark tank soon.";
							closing = @"This is the type of poker you have been wanting to play. Keep it going and keep the wins rolling.";
						}
						break;
				}
				break;
			case 3:
				switch (lastGameSkill) {
					case 0:
						if(streak==-1) {
							opening = @"Well, no one wins them all and this last game is proof of that.";
							closing = @"Time to shake off the loss and move on to the next game.";
						} else {
							opening = @"The slide continues as you are reminded that poker has its ups and downs... and the downs really suck.";
							closing = @"I hope we aren't seeing a new bad trend after all those earlier wins.";
						}
						
						break;
					case 1:
						if(streak==-1) {
							opening = @"You hit a small speed bump with that last game, but overall you've been playing some great poker lately.";
							closing = @"Nobody wins every game, but you've been playing solid poker as of late. keep it up.";
						} else {
							opening = @"Another loss hurts the bankroll a little, but that's small potatoes for a good player like you.";
							closing = @"The losses are piling up. It's time to get the game back on track.";
						}
						
						break;
					case 2:
						if(streak==1) {
							opening = @"Alright alright... a win and now the bankroll is moving in the right direction again.";
							closing = @"Keep the wins coming and keep playing the same solid poker.";
						} else {
							opening = @"It's nice to see you are back on a winning streak and playing good poker.";
							closing = @"This current little winning streak is helping keep your money on a positive cash flow.";
						}
						
						break;
					case 3:
						if(streak==1) {
							opening = @"Great game. Great poker. Poker is fun when you are walking away from the table with chips.";
							closing = @"Nice job getting your game back on track with the recent win. Keep it going.";
						} else {
							opening = @"Nice Win! You are giving donkey players the business and discarding them like yesterday's news!";
							closing = @"For people like you, winning is just a way of life.";
						}
						
						break;
					case 4:
						if(streak==1) {
							opening = @"Spectacular! Nice to get back on a winning note. You've been playing some great poker lately and its getting even better.";
							closing = @"Now that you are back to winning, it's time to put the car in high gear and really dominate the tables.";
						} else {
							opening = @"Win Win Win! Rack 'em up, stack 'em up. Stacking up chips that is.";
							closing = @"Keep the momentum going! It may be time to drop the hammer on these chumps.";
						}
						
						break;
				}
				break;
			case 4:
				switch (lastGameSkill) {
					case 0:
						if(streak==-1) {
							opening = @"No problem. You've played some great poker lately even though the last game was a blank.";
							closing = @"March right back into the poker room and focus on getting back on a winning streak.";
						} else {
							opening = @"Two losses in a row? Even great players go through their slumps, so shake it off.";
							closing = @"Don't lose your concentration and don't make calls when you know you are beat.";
						}
						break;
					case 1:
						if(streak==-1) {
							opening = @"Overall, great poker being played, even though the last game wasn't so good.";
							closing = @"Keep playing the same solid poker you've been playing and let the chips fall where they will.";
						} else {
							opening = @"Slumps are no fun and you've been taking a few hits lately, but keep your head up. Shake it off.";
							closing = @"Get back to the basics and focus on winning big pots. Don't be afraid of going into fold mode when the cards aren't coming your way.";
						}
						
						break;
					case 2:
						if(streak==1) {
							opening = @"Great job breaking your slump with that latest win. This game of yours is flat out solid right now.";
							closing = @"Its time to rev this game into high gear and go for a really big cashout.";
						} else {
							opening = @"Now your back to playing good poker! Two wins in a row is padding the ol' bank account.";
							closing = @"You have a solid game right now and are making all the right calls. Now it's time to extend this winning streak and really show them what you have.";
						}
						
						break;
					case 3:
						if(streak==1) {
							opening = @"Fantastic! Nice job getting back to a winning streak. You are looking like a true champion as of late.";
							closing = @"You are making this game look easy! But then again this game is easy when you have your skills.";
						} else {
							opening = @"One big win after another. You are making this game look easy.";
							closing = @"Now is not the time to get an inflated ego though... even if you are one of the greatest players of all time!";
						}
						
						break;
					case 4:
						if(streak==1) {
							opening = @"Great job getting back on a winning track with another big win. Putting the rare losses aside, you are playing some great poker right now!";
							closing = @"Don't get too overconfident though. Wait, what am I talking about? Its hard not to be confident when you are the shark, swimming in the fish tank.";
						} else {
							opening = @"It doesn't get any better than this! Masterful poker being played by one of poker's greats.";
							closing = @"It's time to quit your day job and just play poker... all day... every day.";
						}
						
						break;
				}
				break;
			default:
				break;
		}
		
		int cCounter = numGamesThisYear%6;
		if(netIncome<0) {
			if(winnings<0) {
				switch (cCounter) {
					case 0:
						lastGameDetails = [NSString stringWithFormat:@"You've now lost %@ recently after dropping another %@ at %@ %@ %@.", overallWinLossAmount, winLossAmount, location, weekday, daytime];
						break;
					case 1:
						lastGameDetails = [NSString stringWithFormat:@"You got rolled %@ %@ at %@ where you added to your losses by donking off another %@.", weekday, daytime, location, winLossAmount];
						break;
					case 2:
						lastGameDetails = [NSString stringWithFormat:@"%@ wasn't a good poker %@ for you as you lost another %@, pushing your bankroll to negative %@.", weekday, daytime, winLossAmount, overallWinLossAmount];
						break;
					case 3:
						lastGameDetails = [NSString stringWithFormat:@"Your recent losses have now totaled %@ after dropping another %@ at %@ %@ %@.", overallWinLossAmount, winLossAmount, location, weekday, daytime];
						break;
					case 4:
						lastGameDetails = [NSString stringWithFormat:@"Your current slump continued %@ %@ at %@ where your 'any-two-cards' strategy resulted in a %@ loss of %@.", weekday, daytime, location, adjectGame, winLossAmount];
						break;
					case 5:
						lastGameDetails = [NSString stringWithFormat:@"%@ was another saunter into the poker room. Different %@ same story. The result was another %@ loss (%@), pushing your bankroll to negative %@.", weekday, daytime, adjectGame, winLossAmount, overallWinLossAmount];
						break;
				}
			} else {
				switch (cCounter) {
					case 0:
						lastGameDetails = [NSString stringWithFormat:@"You were able to squeeze out a %@ %@ %@ %@ at %@ in an effort to stop the bleeding and hopefully get things moving in the right direction.", adjectGame, winLossAmount, weekday, daytime, location];
						break;
					case 1:
						lastGameDetails = [NSString stringWithFormat:@"Winning %@ at %@ %@ was a step in the right direction, but you are still down %@ in recent play.", winLossAmount, location, weekday, overallWinLossAmount];
						break;
					case 2:
						lastGameDetails = [NSString stringWithFormat:@"It was nice to walk away with a %@ %@ %@ %@, but you are going to need a few more of those to dig out of the current hole you are in.", adjectGame, winLossAmount, weekday, daytime];
						break;
					case 3:
						lastGameDetails = [NSString stringWithFormat:@"In a rare spark of good play, you were able to win a %@ %@ %@ %@ at %@. This will hopefully get things moving in the right direction.", adjectGame, winLossAmount, weekday, daytime, location];
						break;
					case 4:
						lastGameDetails = [NSString stringWithFormat:@"With a %@ %@ win at %@ %@ you are now moving things in the right direction. The bad news is you are still down %@ in recent play.", adjectGame, winLossAmount, location, weekday, overallWinLossAmount];
						break;
					case 5:
						lastGameDetails = [NSString stringWithFormat:@"The good news is you were able to walk away with a %@ %@ %@ %@. The bad news is you still have a ways to go to dig out of the current hole you are in.", adjectGame, winLossAmount, weekday, daytime];
						break;
				}
			}
		} else {
			if(winnings<0) {
				switch (cCounter) {
					case 0:
						lastGameDetails = [NSString stringWithFormat:@"%@ %@ took a %@ %@ hit to your bankroll but you are still in the black overall in recent games.", weekday, daytime, adjectGame, winLossAmount];
						break;
					case 1:
						lastGameDetails = [NSString stringWithFormat:@"You took it on the chin %@ %@ at %@ as a few small mistakes added up to a %@ losing session. The good news is you are still up %@ in recent games.", weekday, daytime, location, adjectGame, overallWinLossAmount];
						break;
					case 2:
						lastGameDetails = [NSString stringWithFormat:@"A %@ loss %@ %@ at %@ was not good but you are still up %@ in recent games.", adjectGame, weekday, daytime, location, overallWinLossAmount];
						break;
					case 3:
						lastGameDetails = [NSString stringWithFormat:@"%@ was an off %@ for you losing a %@ %@ but you are still in the black overall in recent games.", weekday, daytime, adjectGame, winLossAmount];
						break;
					case 4:
						lastGameDetails = [NSString stringWithFormat:@"A %@ %@ %@ at %@ took a bite out of your bankroll, but the good news is you are still up overall in recent games.", adjectGame, daytime, weekday, location];
						break;
					case 5:
						lastGameDetails = [NSString stringWithFormat:@"You managed a %@ loss %@ %@ at %@ but shake it off. You are still up %@ in recent games.", adjectGame, weekday, daytime, location, overallWinLossAmount];
						break;
				}
			} else {
				switch (cCounter) {
					case 0:
						lastGameDetails = [NSString stringWithFormat:@"A %@ %@ win %@ %@ at %@ is helping you keep a positive bankroll in recent games.", adjectGame, winLossAmount, weekday, daytime, location];
						break;
					case 1:
						lastGameDetails = [NSString stringWithFormat:@"You are now up %@ in recent games thanks to a %@ %@ win at %@ on %@.", overallWinLossAmount, adjectGame, winLossAmount, location, weekday];
						break;
					case 2:
						lastGameDetails = [NSString stringWithFormat:@"%@ %@ was proof of your good play when you were able to add an additional %@ to your bankroll.", weekday, daytime, winLossAmount];
						break;
					case 3:
						lastGameDetails = [NSString stringWithFormat:@"Not too shabby with a %@ %@ win %@ %@ at %@. Your recent play is helping you keep a positive bankroll.", adjectGame, winLossAmount, weekday, daytime, location];
						break;
					case 4:
						lastGameDetails = [NSString stringWithFormat:@"After another win, you are now up %@ in recent games. You are extending your positive bankroll thanks to a %@ %@ win at %@ on %@.", overallWinLossAmount, adjectGame, winLossAmount, location, weekday];
						break;
					case 5:
						lastGameDetails = [NSString stringWithFormat:@"%@ %@ was another %@ session for you as you were able to add an additional %@ to your bankroll.", weekday, daytime, adjectGame, winLossAmount];
						break;
				}
			}			
		}

		if(rebuyAmount>0) {
			if(winnings >0)
				lastGameDetails = [NSString stringWithFormat:@"Nice work %@ %@ as you took some early losses but were able to turn it into a winning session cashing out for %@ profit.", weekday, daytime, winLossAmount];
			if(winnings<0 && winnings*-1<buyIn)
				lastGameDetails = [NSString stringWithFormat:@"Well it could have been worse %@ %@ as you dug yourself into a hole ealy but were able to recover some of the losses to finish off just %@.", weekday, daytime, winLossAmount];
			
			if(winnings<0 && winnings*-1>buyIn)
				lastGameDetails = [NSString stringWithFormat:@"Ouch! %@ %@ started out bad and quickly went downhill from there. Not a good session as you dropped %@.", weekday, daytime, winLossAmount];
			
		}
		
		if(streak==3 && numGamesThisYear%2==0) {
			opening = @"Good work! Things are rolling now after winning your third game in a row!";
			closing = @"Keep the gravy train rumbling as you prepare for your next game.";
		}
		if(streak==3 && numGamesThisYear%2==1) {
			opening = @"Another win! Nice work getting your third winning game in a row!";
			closing = @"Keep your focus as you prepare to extend the winning streak.";
		}
		if(streak==4) {
			opening = @"Outstanding! Four wins in a row for you. Its almost like taking candy from a baby.";
			closing = @"Keep the pressure on and go for win #5!";
		}
		if(streak==5) {
			opening = @"This has been some unbelievable poker play as you just cruised to your fifth win in a row!";
			closing = @"Don't change your game now as you try for win #6";
		}
		if(streak==6) {
			opening = @"Wow! Six wins in a row? Are you serious? This is a serious winning streak.";
			closing = @"Whatever you've been doing lately is working, so keep it going.";
		}
		if(streak==7) {
			opening = @"Somebody pinch me. Did you really just win your 7th game in a row? Outstanding!";
			closing = @"I don't know how you find so many fish at one table, but hopefully the good fortune continues.";
		}
		if(streak==8) {
			opening = @"Great work getting your eighth straight win!";
			closing = @"Whatever you've been doing lately is working, so keep it going.";
		}
		if(streak==9) {
			opening = @"Dynomite! Good work rolling up your ninth straight win.";
			closing = @"I don't know how you find so many fish at one table, but hopefully the good fortune continues.";
		}
		if(streak==10) {
			opening = @"Superb! You just racked up your tenth straight win!";
			closing = @"Whatever you've been doing lately is working, so keep it going.";
		}
		
		if(streak==-3 && numGamesThisYear%2==0) {
			opening = @"Doh! Times are tough right now as you've come up short in three straight games.";
			closing = @"You are due for a win so concentrate on good play and don't... I repeat don't go on tilt!";
		}
		if(streak==-3 && numGamesThisYear%2==1) {
			opening = @"Ouch! Three straight losses is not good for the ol' bankroll.";
			closing = @"You need to start getting better value out of your good hands. If you are winning the small pots and losing the big pots, you need to change things up.";
		}
		if(streak==-4) {
			opening = @"Yuk! The onslaught is getting more severe as you have now lost 4 games in a row.";
			closing = @"I don't want to get nasty, so make sure you bring your 'A' game next time.";
		}
		if(streak==-5) {
			opening = @"These are certainly not the best of times, and may very well be the worst of times as you have now lost 5 straight games.";
			closing = @"Whatever you've been doing lately, try the exact opposite, because it's simply not working.";
		}
		if(streak==-6) {
			opening = @"Six bad games in a row! Its either bad luck or bad play but right now I'm leaning towards bad play.";
			closing = @"Make sure you eat a big meal and get lots of rest before going to your next game. You're gunna need it.";
		}
		if(streak==-7) {
			opening = @"UGH! It doesn't get any worse than this. Seven poor games in a row with no signs of improvement.";
			closing = @"This is it. You better win next game out because your bank account can't handle much more of this disaster.";
		}
		if(streak==-8) {
			opening = @"No. No. No. This is so bad. Eight straight losses!";
			closing = @"Whatever you've been doing lately, try the exact opposite, because it's simply not working.";
		}
		if(streak==-9) {
			opening = @"I can't believe what I am seeing! Nine straight losses?!?";
			closing = @"Make sure you eat a big meal and get lots of rest before going to your next game. You're gunna need it.";
		}
		if(streak==-10) {
			opening = @"Are you kidding me? Is this a joke? Ten losses in a row?!?";
			closing = @"This is it. You better win next game out because your bank account can't handle much more of this disaster.";
		}
		
		if(lastGameWon && netIncome>0 && netIncome<winnings)
			lastGameDetails = [NSString stringWithFormat:@"Raking in %@ %@ %@ at %@ was enough to push your overall recent game bankroll positive, so things are really looking up.", winLossAmount, weekday, daytime, location];
		
		if(!lastGameWon && netIncome<0 && netIncome>winnings)
			lastGameDetails = [NSString stringWithFormat:@"Unfortunately losing %@ %@ %@ at %@ was enough to push your overall recent game bankroll into the red, so its time to buckle up and focus on solid poker.", winLossAmount, weekday, daytime, location];

        NSString *currentYearStr = [[NSDate date] convertDateToStringWithFormat:@"yyyy"];
        NSString *currentMonth = [ProjectFunctions getMonthFromDate:[NSDate date]];
		
		NSString *basicPred = [ProjectFunctions getBasicPredicateString:[currentYearStr intValue] type:@"All"];
		NSPredicate *predicateMonth1 = [ProjectFunctions predicateForBasic:basicPred field:@"month" value:currentMonth];
        NSArray *gamesMonth = [CoreDataLib selectRowsFromEntityWithLimit:@"GAME" predicate:predicateMonth1 sortColumn:@"winnings" mOC:managedObjectContext ascendingFlg:NO limit:10];
        int numGamesThisMonth = (int)[gamesMonth count];
        NSString *statsThisMonth = [CoreDataLib getGameStat:managedObjectContext dataField:@"analysis1" predicate:predicateMonth1];
        NSArray *thisMonStats = [statsThisMonth componentsSeparatedByString:@"|"];
        int winningsThis = [[thisMonStats stringAtIndex:5] intValue];
        //-------------- top games-------------------------------
        if(gameCount>=1) { // must be at most 10 for last 10!!!!!
			// top & bottom 5
            
            if(numGamesThisMonth>1 && numGamesThisMonth%5==0) {
                int currentDay = [[[NSDate date] convertDateToStringWithFormat:@"dd"] intValue];
                NSDate *lastMonthDate = [[NSDate date] dateByAddingTimeInterval:-1*60*60*24*28];
                if(currentDay>20)
                    lastMonthDate = [[NSDate date] dateByAddingTimeInterval:-1*60*60*24*32];
                NSString *lastMonthYear = [lastMonthDate convertDateToStringWithFormat:@"yyyy"];
                NSString *lastMonthMonth = [ProjectFunctions getMonthFromDate:lastMonthDate];
 //               NSPredicate *predicateLastMonth = [NSPredicate predicateWithFormat:@"user_id = 0 AND year = %@ AND month = %@", lastMonthYear, lastMonthMonth];
				NSPredicate *predicateLastMonth = [ProjectFunctions predicateForBasic:basicPred field:@"month" value:lastMonthMonth];
                NSString *statsLastMonth = [CoreDataLib getGameStat:managedObjectContext dataField:@"analysis1" predicate:predicateLastMonth];
                NSArray *lastMonStats = [statsLastMonth componentsSeparatedByString:@"|"];
                
                int riskedLast = [[lastMonStats stringAtIndex:0] intValue];
                int riskedThis = [[thisMonStats stringAtIndex:0] intValue];
                int winningsLast = [[lastMonStats stringAtIndex:5] intValue];
                if(riskedLast>0 && riskedThis>0) {
                    int playerTypeLast = [ProjectFunctions getPlayerType:riskedLast winnings:winningsLast];
                    int playerTypeThis = [ProjectFunctions getPlayerType:riskedThis winnings:winningsThis];
                    opening = [AnalysisLib openingBasedOnStats:playerTypeLast thisMonthLevel:playerTypeThis games:numGamesThisMonth month:currentMonth winningsLastMonth:winningsLast winningsThisMonth:winningsThis];
                }
            }

            if(numGamesThisMonth==1 || numGamesThisMonth==2)
                opening = [self getOpeningForFirst2GamesOfMonth:lastGameWon numGames:numGamesThisMonth streak:streak monthName:currentMonth];
            
            
			if(lastGameWon) {
                
                if(numGamesThisYear==1)
                    opening = [NSString stringWithFormat:@"%@ is off to a great start for you! One game and one win.", currentYearStr];
                
                // best game this month
                NSPredicate *predicateMonth = [NSPredicate predicateWithFormat:@"winnings > %d AND user_id = 0 AND year = %@ AND month = %@", winnings, currentYearStr, currentMonth];
                opening = [self getOpeningForTop5Games:opening numGames:(int)[gamesMonth count] predicate:predicateMonth moc:managedObjectContext name:@"the month"];
                
                // best game this year
                NSPredicate *predicateYear2 = [NSPredicate predicateWithFormat:@"winnings > %d AND user_id = 0 AND year = %@", winnings, currentYearStr];
                opening = [self getOpeningForTop5Games:opening numGames:(int)[gamesYear count] predicate:predicateYear2 moc:managedObjectContext name:@"the year"];
                
                
                // best game all time
				NSPredicate *predicate = [NSPredicate predicateWithFormat:@"winnings > %d AND user_id = 0", winnings];
                opening = [self getOpeningForTop5Games:opening numGames:totalGameCount predicate:predicate moc:managedObjectContext name:@"all time"];
                
                
 			} else { // lost last game
                if(numGamesThisYear==1)
                    opening = [NSString stringWithFormat:@"%@ is not starting so great, but that's only one game and it's going to be a long year.", currentYearStr];
                
                
				NSPredicate *predicate = [NSPredicate predicateWithFormat:@"winnings < %d AND user_id = 0", winnings];
				NSArray *worstGames = [CoreDataLib selectRowsFromEntityWithLimit:@"GAME" predicate:predicate sortColumn:@"winnings" mOC:managedObjectContext ascendingFlg:YES limit:5];
				int place = (int)[worstGames count]+1;
				if(place<=5 && totalGameCount>35)
					opening = [NSString stringWithFormat:@"Rough night! Unfortunately you just had your %@ worst game of all time! Not fun.", [ProjectFunctions numberWithSuffix:place]];
				if(place<=3 && totalGameCount>25)
					opening = [NSString stringWithFormat:@"Not good! Unfortunately you just had your %@ worst game of all time! That wasn't fun.", [ProjectFunctions numberWithSuffix:place]];
				if(place==1 && totalGameCount>20)
					opening = @"Ugh and super ugh. You just had your worst game of all time.";
			}
		}
        //-------------- end top games-------------------------------
        
        // Month turned around
        if(numGamesThisMonth>3) {
            if(lastGameWon) {
                if(winningsThis>0 && winningsThis<winnings)
                    opening = [NSString stringWithFormat:@"Nice work! Your latest game just pushed you into the black for the month of %@.", currentMonth];
            } else {
                if(winningsThis<0 && winningsThis>winnings)
                    opening = [NSString stringWithFormat:@"Ouch! That one hurt. Your latest game just pushed you into the red for the month of %@.", currentMonth];
            }
        }

        // winning & losing streaks----------------
        int longestWinStreak = [[ProjectFunctions getUserDefaultValue:@"longestWinStreak"] intValue];
        int longestLoseStreak = [[ProjectFunctions getUserDefaultValue:@"longestLoseStreak"] intValue];
        if(streak==longestWinStreak && longestWinStreak>3 && numGamesThisYear%2==0)
            opening = [NSString stringWithFormat:@"Congratulations! You are currently on your best winning streak of the year at %d games in a row. You are likely playing the best poker of your life right now.", longestWinStreak];
        if(streak==longestWinStreak && longestWinStreak>3 && numGamesThisYear%2==1)
            opening = [NSString stringWithFormat:@"Outstanding! You have extended your winning streak to %d games in a row, which is now your best streak of the year. You are really playing some good poker right now.", longestWinStreak];
        if(streak==longestLoseStreak && longestLoseStreak<-3 && numGamesThisYear%2==0)
            opening = [NSString stringWithFormat:@"The train wreck continues! You are extending your worst losing streak of the year to %d consecutive losses. This is some really bad poker being played right now.", longestLoseStreak*-1];
        if(streak==longestLoseStreak && longestLoseStreak<-3 && numGamesThisYear%2==1)
            opening = [NSString stringWithFormat:@"This is bad. Really bad. You have extended your worst losing streak of the year to %d consecutive losses. Things continue to move in the wrong direction for you.", longestLoseStreak*-1];
        
        NSString *middle = @"";
        if(numGamesThisYear>10) {
            int middleNumber = totalGameCount%6;
            switch (middleNumber) {
                case 0: // last 10 games
                    middle = [AnalysisLib getLast3Analysis:managedObjectContext numGames:10];
                    break;
                case 1: // last 3 games
                    middle = [AnalysisLib getLocationAnalysis:managedObjectContext];
                    break;
                case 2: // This year compared to last
                    middle = [AnalysisLib getYearOverYearAnalysis:managedObjectContext];
                    break;
                case 3: // location analysis
                    middle = [AnalysisLib getLast3Analysis:managedObjectContext numGames:3];
                    break;
                case 4: // day of week analysis
                    middle = [AnalysisLib getDayOfWeekAnalysis:managedObjectContext];
                    break;
                    
                default: // year so far
                    middle = [AnalysisLib getCurrentYearDetails:managedObjectContext];
                    break;
            }
        } else
            middle = [AnalysisLib getCurrentYearDetails:managedObjectContext];
        
		NSString *famousQuote = [AnalysisLib getPokerQuote:numGamesThisYear];
		return [NSString stringWithFormat:@"%@\n\n%@\n\n%@\n\n%@\n\n%@", opening, lastGameDetails, closing, middle, famousQuote];
	}
	
	//################################## LifeTime ######################################
	if(displayYear==0) {
		NSArray *adjectiveList = [NSArray arrayWithObjects:@"awful", @"slow", @"fair", @"great", @"really great", nil];
		NSString *adjective = [adjectiveList stringAtIndex:playerOverallSkill];
		if(gameCount==1 && totalWins==1)
			return @"You've only played 1 game, but it was for a win so it looks like you are a pretty good poker player to me.";
		if(gameCount==1 && totalWins==0)
			return @"You've only played 1 game so its far too early to tell what kind of game you have.";
		
		if(gameCount <5) 
			return [NSString stringWithFormat:@"So far you have only played %d games so its too early to make any hard evaluations but with %@ and %@ you are off to a %@ start.", gameCount, winString, loseString, adjective];
		
		if([gameType isEqualToString:@"All Game Types"] || [gameType isEqualToString:@"All"]) {
			switch (playerOverallSkill) {
				case 0:
					return [NSString stringWithFormat:@"Your poker skills are in need of some serious fine tuning as you have only been able to get %@ in %d games and have lost a total of %@. You need to change up your game and study what the pros do. Poker is not about trying to outbluff the bluffer and stealing tiny pots with 2-4 offsuit.", winString, gameCount, overallWinLossAmount];
					break;
				case 1:
					return [NSString stringWithFormat:@"You have some signs of promise and moments of greatness, but after losing %d out of %d games for a loss of %@, you need some tweaking. Try reading up on poker strategy and start playing better cards. Bluff less in late rounds but play more aggressive preflop. The key is making targeted moves.", totalLosses, gameCount, overallWinLossAmount];
					break;
				case 2:
					return [NSString stringWithFormat:@"You have a solid poker game winning %d out of %d games for a career total of %@ in winnings. There's plenty of room for improvement though as you are still losing too many games. Try making larger bets against weak opponents and smaller bets against the stronger ones. You want to get the maximum pot out of each winning hand.", totalWins, gameCount, overallWinLossAmount];
					break;
				case 3:
					return [NSString stringWithFormat:@"You are truly a poker shark after winning %d out of %d games for a career total of %@ in winnings. Keep plugging away and keep working on your game. You aren't far from the 'Pro' classification.", totalWins, gameCount, overallWinLossAmount];
					break;
				case 4:
					return [NSString stringWithFormat:@"You have been given the rank of Pro and there's a reason for it. You have a phenomenal win percentage after %d games and have banked a massive %@ in winnings. Keep playing the same solid poker that got you here in the first place and don't let your ego get the best of you. Remember winning streaks never last forever and the next bad beat is just around the corner. But keep up the great work!", gameCount, overallWinLossAmount];
					break;
			}
		}
		if([gameType isEqualToString:@"Cash"]) {
			switch (playerOverallSkill) {
				case 0:
					return [NSString stringWithFormat:@"Your cash game skills are pretty bad right now as you were able to get only %@ in %d games and have lost a total of %@. Try getting more rest and don't be afraid to leave the table when you still have chips.", winString, gameCount, overallWinLossAmount];
					break;
				case 1:
					return [NSString stringWithFormat:@"You are currently losing money in cash games with %d losses in %d games for a combined total of %@ down the drain. You need to start playing smarter poker and make better laydowns. Don't be afraid to lay down top pair to a large bet.", totalLosses, gameCount, overallWinLossAmount];
					break;
				case 2:
					return [NSString stringWithFormat:@"Grinding out win after win at the cash tables has gained you a total of %@ by winning %d games. That's not bad but you are still leaving too much money on the table. Don't be afraid to play a little more aggressive at times in order to maximize every pot.", overallWinLossAmount, totalWins];
					break;
				case 3:
					return [NSString stringWithFormat:@"Danger! Shark alert! After winning %d out of %d cash games for a career total of %@ winnings you are a feared poker player. Keep plugging away and keep working on hte fundamentals to take your game to the next level.", totalWins, gameCount, overallWinLossAmount];
					break;
				case 4:
					return [NSString stringWithFormat:@"Making money at the cash tables has come easy to you, cashing %d times in %d games for a hefty %@ in winnings. Keep playing the same solid poker that got you here in the first place and don't let your ego get the best of you. You never want to let your guard down.", totalWins, gameCount, overallWinLossAmount];
					break;
			}
		}
		if([gameType isEqualToString:@"Tournament"]) {
			switch (playerOverallSkill) {
				case 0:
					return @"Tournament poker might not be the right game for you and maybe you should stick to the cash games for now";
					break;
				case 1:
					return @"You aren't the type of tournament player that's going to make a lot of money, but as long as you are playing for the entertainment, its a great sport.";
					break;
				case 2:
					return @"You are a very decent tournament player and have cashed often. Keep up the good work.";
					break;
				case 3:
					return @"Tournaments have become an atm for you so keep at it and continue to work on your game.";
					break;
				case 4:
					return @"Your tournament play is off the charts. If I was you I'd aim for bigger stakes.";
					break;
			}
		}
	}
	
	//################################## Current Year ######################################
	if(displayYear==currentYear) {
		NSArray *adjectiveList = [NSArray arrayWithObjects:@"terrible", @"rough", @"decent", @"great", @"fantastic", nil];
		NSString *adjective = [adjectiveList stringAtIndex:playerOverallSkill];
		NSArray *adjectiveList2 = [NSArray arrayWithObjects:@"awful", @"slow", @"moderate", @"good", @"wonderful", nil];
		NSString *adjective2 = [adjectiveList2 stringAtIndex:playerOverallSkill];
		NSString *upDown = @"up";
		NSString *winLose = @"earn";
		if(netIncome<0) {
			upDown = @"down";
			winLose = @"lose";
		}
		if(gameCount==0)
			return @"A new year starting! Lets hope its a good one...";

		if(gameCount==1 && totalWins==1)
			return @"You've only played 1 game, but it was for a win so it looks like it's going to be a pretty good year.";
		if(gameCount==1 && totalWins==0)
			return @"You've only played 1 game so its far too early to tell what kind of year it's going to be.";
		

		if(gameCount <5) {
			if([gameType isEqualToString:@"All Game Types"] || [gameType isEqualToString:@"All"])
				return [NSString stringWithFormat:@"So far you have only played %d games this year so its too early to make any hard evaluations but with %@ and %@ you are off to a %@ start.", gameCount, winString, loseString, adjective];
			if([gameType isEqualToString:@"Cash"])
				return [NSString stringWithFormat:@"You have only played %d cash games this year but with %@ and %@ you are off to a %@ start.", gameCount, winString, loseString, adjective2];
			if([gameType isEqualToString:@"Tournament"])
				return [NSString stringWithFormat:@"You have played %d tournaments so far this year so with %@ and %@ you are off to a %@ start.", gameCount, winString, loseString, adjective2];
		}

		int dayOfYear = [[[NSDate date] convertDateToStringWithFormat:@"D"] intValue];
		int yearRange = [[[NSDate date] convertDateToStringWithFormat:@"M"] intValue]/4;
		int yearTotal = 0;
		if(dayOfYear>0)
			yearTotal = netIncome*365/dayOfYear;
		if(yearTotal<0)
			yearTotal*=-1;
		
		NSString *bestTimes = [self getBestTimes:displayYear gameType:gameType moc:managedObjectContext];
		NSString *paragraph1 = [NSString stringWithFormat:@"Your %@ play has been %@ this year with %@ out of %d games played.", pokerType, adjective, winString, gameCount];
		NSString *paragraph2 = [NSString stringWithFormat:@"You are currently %@ %@ in %d and on pace to %@ %@. %@", upDown, overallWinLossAmount, displayYear, winLose, [ProjectFunctions convertIntToMoneyString:yearTotal], bestTimes];
		NSString *closing = @"";
		switch (playerOverallSkill) {
			case 0:
				switch (yearRange) {
					case 0:
						closing = @"You are not off to a good start this year and might need to mortgage your home before its over.";
						break;
					case 1:
						closing = @"So far this year has been a disaster. My grandma plays a better poker game.";
						break;
					default:
						closing = @"Its pretty much time to write this year off and start thinking about what you are going to do different next year.";
						break;
				}
				break;
			case 1:
				switch (yearRange) {
					case 0:
						closing = @"You are off to a slow start but there's still plenty of time to turn things around.";
						break;
					case 1:
						closing = @"Its time to turn this game around and start making some money.";
						break;
					default:
						closing = @"Hopefully a strong finish this year will put you back in the black.";
						break;
				}
				break;
			case 2:
				switch (yearRange) {
					case 0:
						closing = @"You are off to a good start this year and have a profitable game. Keep it going.";
						break;
					case 1:
						closing = @"You've been able to make some money this year, but you are in need of a couple more big wins.";
						break;
					default:
						closing = @"You've been making money solidly all year long, although its not time to quit your day job.";
						break;
				}
				break;
			case 3:
				switch (yearRange) {
					case 0:
						closing = @"Great start to the year so far and hopefully things continue at this pace.";
						break;
					case 1:
						closing = @"Its been a great year overall and well worth the time invested.";
						break;
					default:
						closing = @"You have to be very happy with your performance this year.";
						break;
				}
				break;
			case 4:
				switch (yearRange) {
					case 0:
						closing = @"You are off to an amazing start and hopefully its not just a couple of fluke games.";
						break;
					case 1:
						closing = @"This year has been one of the truly great stories in poker history.";
						break;
					default:
						closing = @"Another amazing year for the poker genius.";
						break;
				}
				break;
			default:
				break;
		}
		return [NSString stringWithFormat:@"%@\n\n%@\n\n%@", paragraph1, paragraph2, closing];
	}

	
	//################################## Prev Year ######################################
	if(displayYear<currentYear) {
		if(gameCount==0)
			return [NSString stringWithFormat:@"No %@ play in %d", pokerType, displayYear];

		NSArray *adjectiveList = [NSArray arrayWithObjects:@"terrible", @"rough", @"decent", @"great", @"fantastic", nil];
		NSString *adjective = [adjectiveList stringAtIndex:playerOverallSkill];
		if(gameCount==1 && totalWins==1)
			return @"You've only played 1 game, but it was for a win so i guess it was a good year.";
		if(gameCount==1 && totalWins==0)
			return @"You've only played 1 game so there's not enough info to make an informative evaluation.";
		
		NSString *evalStr = @"nice";
		if(playerOverallSkill<2)
			evalStr = @"disapointing";
		NSString *evalStr2 = @"good";
		if(playerOverallSkill<2)
			evalStr2 = @"down";
		
		if(gameCount <5) {
			if([gameType isEqualToString:@"All Game Types"] || [gameType isEqualToString:@"All"])
				return [NSString stringWithFormat:@"You only played %d games so its hard to tell, but with %@ and %@ you had a %@ year.", gameCount, winString, loseString, evalStr];
			if([gameType isEqualToString:@"Cash"])
				return [NSString stringWithFormat:@"With only %d cash games I don't have much information, but you were able to get %@ and %@ so it was a %@ year.", gameCount, winString, loseString, evalStr2];
			if([gameType isEqualToString:@"Tournament"])
				return [NSString stringWithFormat:@"You only played in %d tournaments in %d so there's not much to go on, but with %@ and %@ it was a %@ year.", gameCount, displayYear, winString, loseString, evalStr2];
		}
		
		if([gameType isEqualToString:@"All Game Types"] || [gameType isEqualToString:@"All"]) {
			switch (playerOverallSkill) {
				case 0:
					return [NSString stringWithFormat:@"%d was a terrible poker year for you as you had %@ out of %d games for a total loss of %@.", displayYear, loseString, gameCount, overallWinLossAmount];
					break;
				case 1:
					return [NSString stringWithFormat:@"%d wasn't a great poker year for you as you only had %@ out of %d games, but the good news is you only lost %@ on the year.", displayYear, winString, gameCount, overallWinLossAmount];
					break;
				case 2:
					return [NSString stringWithFormat:@"%d was a good poker year for you with %@ out of %d games for a total of %@.", displayYear, winString, gameCount, overallWinLossAmount];
					break;
				case 3:
					return [NSString stringWithFormat:@"%d was a great poker year for you with %@ out of %d games for a total of %@.", displayYear, winString, gameCount, overallWinLossAmount];
					break;
				case 4:
					return [NSString stringWithFormat:@"%d was a fantastic poker year for you with %@ out of %d games for a total of %@.", displayYear, winString, gameCount, overallWinLossAmount];
					break;
			}
		}
		if([gameType isEqualToString:@"Cash"]) {
			switch (playerOverallSkill) {
				case 0:
					return [NSString stringWithFormat:@"%d sucked at the cash tables as you had %@ out of %d games for a total of %@.", displayYear, loseString, gameCount, overallWinLossAmount];
					break;
				case 1:
					return [NSString stringWithFormat:@"%d wasn't a great cash game year for you as you only had %@ out of %d games, but the good news is you only lost %@ on the year.", displayYear, winString, gameCount, overallWinLossAmount];
					break;
				case 2:
					return [NSString stringWithFormat:@"You won %@ in %d cash games including %@ so overall it was a good year.", overallWinLossAmount, displayYear, winString];
					break;
				case 3:
					return [NSString stringWithFormat:@"Great year! %d saw you rack up %@ out of %d cash games for a total of %@.", displayYear, winString, gameCount, overallWinLossAmount];
					break;
				case 4:
					return [NSString stringWithFormat:@"Fabulous! %d was a fantastic cash game year for you with %@ out of %d games for a total of %@.", displayYear, winString, gameCount, overallWinLossAmount];
					break;
			}
		}
		if([gameType isEqualToString:@"Tournament"]) {
			NSString *wonStr = @"won";
			if(playerOverallSkill<2)
				wonStr = @"lost";
			return [NSString stringWithFormat:@"%d was a %@ tournament year for you as you %@ %@.", displayYear, adjective, wonStr, overallWinLossAmount];
		}
	}
	return [NSString stringWithFormat:@"-No Analysis found- %d|%d %@",displayYear,currentYear,gameType];
}


+(NSString *)getLast3Analysis:(NSManagedObjectContext *)managedObjectContext numGames:(int)numGames
{
    
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"user_id = 0"];
    NSArray *games = [CoreDataLib selectRowsFromEntityWithLimit:@"GAME" predicate:predicate sortColumn:@"startTime" mOC:managedObjectContext ascendingFlg:NO limit:numGames];
    
    int wins=0;
    int losses=0;
    int totalProfit=0;
    int totalRisked=0;
    for(NSManagedObject *game in games) {
        int winnings = [[game valueForKey:@"cashoutAmount"] intValue];
        int foodMoney = [[game valueForKey:@"foodDrinks"] intValue];
        float buyInAmount = [[game valueForKey:@"buyInAmount"] floatValue];
        float rebuyAmount = [[game valueForKey:@"rebuyAmount"] floatValue];
        
        int risked = buyInAmount+rebuyAmount;
        int profit = winnings+foodMoney-risked;
        totalProfit+=profit;
        totalRisked+=risked;
        
        if(profit>=0)
            wins++;
        else
            losses++;
    }
    NSString *winsStr = (wins==1)?@"win":@"wins";
    NSString *lossesStr = (losses==1)?@"loss":@"losses";
    int skill = [ProjectFunctions getPlayerType:totalRisked winnings:totalProfit];
    
    switch (skill) {
        case 0:
            return [NSString stringWithFormat:@"You have been getting clobbered in your last %d games, losing %@ with %d %@ and %d %@. It might be a good time to mix up your strategy.",
                    numGames, 
             [ProjectFunctions convertIntToMoneyString:totalProfit],
             wins,
             winsStr,
             losses,
             lossesStr
             ];
            break;
        case 1:
            return [NSString stringWithFormat:@"You have taken a few hits in your last %d games and are down %@ with %d %@ and %d %@. Making solid reads and laying down those good but losing hands is going to be the key for you.",
                    numGames,
             [ProjectFunctions convertIntToMoneyString:totalProfit],
             wins,
             winsStr,
             losses,
             lossesStr
             ];
            break;
        case 2:
            return [NSString stringWithFormat:@"You have managed to keep your bankroll positive in your last %d games and are up %@ with %d %@ and %d %@. Hopefully your next game is a really big win.",
                    numGames,
             [ProjectFunctions convertIntToMoneyString:totalProfit],
             wins,
             winsStr,
             losses,
             lossesStr
             ];
            break;
        case 3:
            return [NSString stringWithFormat:@"Your last %d games have been great for a combined profit of %@ with %d %@ and %d %@. keep it going.",
                    numGames,
             [ProjectFunctions convertIntToMoneyString:totalProfit],
             wins,
             winsStr,
             losses,
             lossesStr
             ];
            break;
        case 4:
            return [NSString stringWithFormat:@"Your recent play has been spectacular profiting %@ with %d %@ and %d %@ in your past %d games. Keep up the good work.",
             [ProjectFunctions convertIntToMoneyString:totalProfit],
             wins,
             winsStr,
             losses,
             lossesStr,
                    numGames
             ];
            break;
            
        default:
            break;
    }
    
    
    return [NSString stringWithFormat:@"In your last 3 games you are up %@ with %d %@ and %d %@.",
            [ProjectFunctions convertIntToMoneyString:totalProfit],
            wins,
            winsStr,
            losses,
            lossesStr
            ];
    
}

+(NSString *)getYearOverYearAnalysis:(NSManagedObjectContext *)managedObjectContext
{
    int displayYear = [[[NSDate date] convertDateToStringWithFormat:@"yyyy"] intValue];
    NSString *gameType = @"All Game Types";
	NSString *basicPred = [ProjectFunctions getBasicPredicateString:displayYear type:gameType];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:basicPred];
    int winningsThisYear = [[CoreDataLib getGameStat:managedObjectContext dataField:@"winnings" predicate:predicate] intValue];
    int gameCountThisYear = [[CoreDataLib getGameStat:managedObjectContext dataField:@"gameCount" predicate:predicate] intValue];
    int riskedThisYear = [[CoreDataLib getGameStat:managedObjectContext dataField:@"amountRisked" predicate:predicate] intValue];
    
    
	NSString *basicPred2 = [ProjectFunctions getBasicPredicateString:displayYear-1 type:gameType];
    NSPredicate *predicate2 = [NSPredicate predicateWithFormat:basicPred2];
    int winningsLastYear = [[CoreDataLib getGameStat:managedObjectContext dataField:@"winnings" predicate:predicate2] intValue];
//    int gameCountLastYear = [[CoreDataLib getGameStat:managedObjectContext :@"gameCount" :predicate2] intValue];
    int riskedLastYear = [[CoreDataLib getGameStat:managedObjectContext dataField:@"amountRisked" predicate:predicate2] intValue];
    
    if(riskedLastYear==0 || riskedThisYear==0)
        return [AnalysisLib getCurrentYearDetails:managedObjectContext];
    
 
    int skillThis = [ProjectFunctions getPlayerType:riskedThisYear winnings:winningsThisYear];
    int skillLast = [ProjectFunctions getPlayerType:riskedLastYear winnings:winningsLastYear];
    
   
    int skillDifference = skillThis-skillLast+4;
    NSArray *makeMoneyArray = [NSArray arrayWithObjects:@"losing big and down a whopping",
                               @"losing money and down",
                               @"making money and up",
                               @"making good money and up",
                               @"making terrific money and up", nil];
    
    NSArray *improvmentArray = [NSArray arrayWithObjects:@"a catastrophy compared to",
                                @"significantly off",
                                @"way down from",
                                @"down from",
                                @"about the same as",
                                @"better than",
                                @"much better than",
                                @"a huge improvement from",
                                @"a monumental turnaround from",
                                nil];

    NSString *wonLoss = (winningsLastYear>=0)?@"won":@"lost";
    
    return [NSString stringWithFormat:@"This year you are %@ %@ in %d games which is %@ your pace in %d when you %@ %@.",
            [makeMoneyArray objectAtIndex:skillThis],
            [ProjectFunctions convertIntToMoneyString:winningsThisYear],
            gameCountThisYear,
            [improvmentArray objectAtIndex:skillDifference],
            displayYear-1,
            wonLoss,
            [ProjectFunctions convertIntToMoneyString:winningsLastYear]
            ];


 }

+(NSString *)getLocationAnalysis:(NSManagedObjectContext *)managedObjectContext
{
    int displayYear = [[[NSDate date] convertDateToStringWithFormat:@"yyyy"] intValue];
    NSString *gameType = @"All Game Types";
	NSString *basicPred = [ProjectFunctions getBasicPredicateString:displayYear type:gameType];
	NSArray *items = [CoreDataLib selectRowsFromTable:@"LOCATION" mOC:managedObjectContext];
    NSMutableArray *locations = [[NSMutableArray alloc] initWithCapacity:100];
	for(NSManagedObject *mo in items) {
		[locations addObject:[NSString stringWithFormat:@"%@", [mo valueForKey:@"name"]]];
    }
    
    int totalGamesCount=0;
    int winMin=0;
    int winMax=-99999;
    int gameMax=0;
    NSString *winLoc = @"Casino";
	NSString *loseLoc = @"Casino";
	NSString *gameLoc = @"Casino";
    for(NSString *location in locations) {
//        NSString *predString = [NSString stringWithFormat:@"%@ AND %@ = %%@", basicPred, @"location"];
//		NSPredicate *predicate = [NSPredicate predicateWithFormat:predString, location];
		NSPredicate *predicate = [ProjectFunctions predicateForBasic:basicPred field:@"location" value:location];
		int winnings = [[CoreDataLib getGameStat:managedObjectContext dataField:@"winnings" predicate:predicate] intValue];
		int gameCount = [[CoreDataLib getGameStat:managedObjectContext dataField:@"gameCount" predicate:predicate] intValue];
        
        totalGamesCount+=gameCount;
        
        
		if(winnings>winMax) {
			winLoc = location;
			winMax=winnings;
		}
		if(winnings<winMin) {
			loseLoc = location;
			winMin=winnings;
		}
		if(gameCount>gameMax) {
			gameLoc = location;
			gameMax=gameCount;
		}

    }
 
    if([winLoc isEqualToString:loseLoc])
        return [NSString stringWithFormat:@"You have played all %d of your games this year at %@ with a total profit of %@.", totalGamesCount, winLoc, [ProjectFunctions convertIntToMoneyString:winMax]];

    
    if(totalGamesCount>0 && (gameMax*100/totalGamesCount)>50) {
        if(![gameLoc isEqualToString:winLoc])
            return [NSString stringWithFormat:@"Most of your games this year have been played at %@, however your best winning has come from %@ where your profit is %@. %@ is your worst casino with a profit of %@.", gameLoc, winLoc, [ProjectFunctions convertIntToMoneyString:winMax], loseLoc, [ProjectFunctions convertIntToMoneyString:winMin]];
        else
            return [NSString stringWithFormat:@"Most of your games this year have been played at %@ where you are up %@. %@ is your worst casino where your profit is %@.", gameLoc, [ProjectFunctions convertIntToMoneyString:winMax], loseLoc, [ProjectFunctions convertIntToMoneyString:winMin]];
    }
    

   if(winMax<0)
       return [NSString stringWithFormat:@"This has been a rough year for you so far, but your best games have been played at %@ where you are only down %@. %@ is your worst casino where your profit is down %@.", winLoc, [ProjectFunctions convertIntToMoneyString:winMax], loseLoc, [ProjectFunctions convertIntToMoneyString:winMin]];

    return [NSString stringWithFormat:@"Your best games this year have been played at %@ where you are up %@. %@ is your worst casino where your profit is %@.", winLoc, [ProjectFunctions convertIntToMoneyString:winMax], loseLoc, [ProjectFunctions convertIntToMoneyString:winMin]];
}

+(NSString *)getDayOfWeekAnalysis:(NSManagedObjectContext *)managedObjectContext
{
    int displayYear = [[[NSDate date] convertDateToStringWithFormat:@"yyyy"] intValue];
    NSString *gameType = @"All Game Types";
    
	NSString *basicPred = [ProjectFunctions getBasicPredicateString:displayYear type:gameType];
    
	NSArray *typeList = [ProjectFunctions namesOfAllWeekdays];
	NSString *weekday = @"";
	NSString *weekdayLo = @"";
	if (typeList.count>2) {
		weekday = [typeList objectAtIndex:0];
		weekdayLo = [typeList objectAtIndex:1];
	}
	int min=0;
	int max=0;
	for(NSString *type in typeList) {
		NSPredicate *predicate = [ProjectFunctions predicateForBasic:basicPred field:@"weekday" value:type];
		double winnings = [[CoreDataLib getGameStat:managedObjectContext dataField:@"winnings" predicate:predicate] doubleValue];
		if(winnings>max) {
			weekday = type;
			max=winnings;
		}
		if(winnings<min) {
			weekdayLo = type;
			min=winnings;
		}
	}
    
    int maxDay=max;
    int minDay=min;
    
	min=0;
	max=0;
	NSArray *typeList2 = [ProjectFunctions namesOfAllDayTimes];
	NSString *daytime = [typeList2 objectAtIndex:2];
	NSString *daytimeLo = [typeList2 objectAtIndex:3];
	for(NSString *type in typeList2) {
		NSPredicate *predicate = [ProjectFunctions predicateForBasic:basicPred field:@"daytime" value:type];
		int winnings = [[CoreDataLib getGameStat:managedObjectContext dataField:@"winnings" predicate:predicate] intValue];
		if(winnings>min) {
			daytime = type;
			min=winnings;
		}
		if(winnings<max) {
			daytimeLo = type;
			max=winnings;
		}
	}
    
    if(minDay>0)
        return [NSString stringWithFormat:@"This has been a fantastic year for you with your best games %@ %@s (up %@). Even your worst day of the week, %@ %@s, have not been bad and you are up %@ those days.", weekday, [daytime lowercaseString], [ProjectFunctions convertIntToMoneyString:maxDay], weekdayLo, [daytimeLo lowercaseString], [ProjectFunctions convertIntToMoneyString:minDay]];

    if(maxDay<0)
        return [NSString stringWithFormat:@"This year has been an unmitigated disaster. Your best games have been %@ %@s where you have ONLY lost %@. %@ %@s have been the real bloodbath as you are down a whopping %@.", weekday, [daytime lowercaseString], [ProjectFunctions convertIntToMoneyString:maxDay], weekdayLo, [daytimeLo lowercaseString], [ProjectFunctions convertIntToMoneyString:minDay]];
   
	return [NSString stringWithFormat:@"So far this year %@ %@s have been your best games where you are up %@. %@ %@s have not been so good for you as you are down %@.", weekday, [daytime lowercaseString], [ProjectFunctions convertIntToMoneyString:maxDay], weekdayLo, [daytimeLo lowercaseString], [ProjectFunctions convertIntToMoneyString:minDay]];
}

+(NSString *)getCurrentYearDetails:(NSManagedObjectContext *)managedObjectContext
{
    NSString *currentYearStr = [[NSDate date] convertDateToStringWithFormat:@"yyyy"];
    NSPredicate *predicateYear = [NSPredicate predicateWithFormat:@"user_id = 0 AND year = %@", currentYearStr];
    int amountRisked=0;
    int netIncome=0;
    int limit=0;
 
    NSString *analysis1 = [CoreDataLib getGameStatWithLimit:managedObjectContext dataField:@"analysis1" predicate:predicateYear limit:limit];
    NSArray *values = [analysis1 componentsSeparatedByString:@"|"];
    if([values count]>10) {
        amountRisked = [[values stringAtIndex:0] intValue];
        netIncome = [[values stringAtIndex:5] intValue];
    }
    

    
	int currentYear = [[[NSDate date] convertDateToStringWithFormat:@"yyyy"] intValue];
	int gameCount = [[CoreDataLib getGameStatWithLimit:managedObjectContext dataField:@"gameCount" predicate:predicateYear limit:limit] intValue];
	int totalWins = [[CoreDataLib getGameStatWithLimit:managedObjectContext dataField:@"totalWins" predicate:predicateYear limit:limit] intValue];
	int totalLosses = [[CoreDataLib getGameStatWithLimit:managedObjectContext dataField:@"totalLosses" predicate:predicateYear limit:limit] intValue];
	NSString *winString = (totalWins==1)?@"1 win":[NSString stringWithFormat:@"%d wins", totalWins];
	NSString *loseString = (totalLosses==1)?@"1 loss":[NSString stringWithFormat:@"%d losses", totalLosses];
	NSString *overallWinLossAmount = [ProjectFunctions convertIntToMoneyString:netIncome];
	int playerOverallSkill = [ProjectFunctions getPlayerType:amountRisked winnings:netIncome];

    NSArray *adjectiveList = [NSArray arrayWithObjects:@"terrible", @"rough", @"decent", @"great", @"fantastic", nil];
    NSString *adjective = [adjectiveList stringAtIndex:playerOverallSkill];
    NSString *upDown = @"up";
    NSString *winLose = @"earn";
    if(netIncome<0) {
        upDown = @"down";
        winLose = @"lose";
    }
    if(gameCount==0)
        return @"A new year starting! Lets hope its a good one...";
    
    if(gameCount==1 && totalWins==1)
        return @"You've only played 1 game, but it was for a win so it looks like it's going to be a pretty good year to me.";
    if(gameCount==1 && totalWins==0)
        return @"You've only played 1 game so its far too early to tell what kind of year it's going to be.";
    
    
    if(gameCount <5) {
            return [NSString stringWithFormat:@"So far you have only played %d games this year so its too early to make any hard evaluations but with %@ and %@ you are off to a %@ start.", gameCount, winString, loseString, adjective];
    }
    
    int dayOfYear = [[[NSDate date] convertDateToStringWithFormat:@"D"] intValue];
    int yearTotal = 0;
    if(dayOfYear>0)
        yearTotal = netIncome*365/dayOfYear;
    if(yearTotal<0)
        yearTotal*=-1;
    
    NSString *bestTimes = [self getBestTimes:currentYear gameType:@"All Game Types" moc:managedObjectContext];
    NSString *paragraph1 = [NSString stringWithFormat:@"Looking at the year so far, your play has been %@ with %@ out of %d games played.", adjective, winString, gameCount];
    NSString *paragraph2 = [NSString stringWithFormat:@"You are currently %@ %@ in %d and on pace to %@ %@. %@", upDown, overallWinLossAmount, currentYear, winLose, [ProjectFunctions convertIntToMoneyString:yearTotal], bestTimes];

    return [NSString stringWithFormat:@"%@ %@", paragraph1, paragraph2];
}

+(NSString *)getOpeningForTop5Games:(NSString *)opening
                           numGames:(int)numGames
                          predicate:(NSPredicate *)predicate
                                moc:(NSManagedObjectContext *)moc
                               name:(NSString *)name
{
    NSArray *topGames = [CoreDataLib selectRowsFromEntityWithLimit:@"GAME" predicate:predicate sortColumn:@"winnings" mOC:moc ascendingFlg:NO limit:5];
    int place = (int)[topGames count]+1;
    
    if(place>5)
        return opening;

    if(place<=5 && numGames>(place*4))
        opening = [NSString stringWithFormat:@"Congratulations on just getting your %@ best game of %@! Not bad!", [ProjectFunctions numberWithSuffix:place], name];
    
    if(place==1 && numGames>(place*4))
        opening = [NSString stringWithFormat:@"Congratulations on just having your best game of %@! Way to go!!", name];

    return opening;
}

+(NSString *)getOpeningForFirst2GamesOfMonth:(BOOL)gameWon numGames:(int)numGames streak:(int)streak monthName:(NSString *)monthName
{
    if(gameWon) {
        if(numGames==1)
            return [NSString stringWithFormat:@"%@ is off to a good start for you as you got a quick win right out of the gates.", monthName];
        
        if(numGames==2 && streak>1)
            return [NSString stringWithFormat:@"Nice! %@ is turning into a great month for you as you have now won both of your first 2 games.", monthName];
        
        if(numGames==2 && streak==1)
            return [NSString stringWithFormat:@"Good win. You are now 1 and 1 for %@ after 2 games and heading in the right direction.", monthName];
    } else {
        if(numGames==1)
            return [NSString stringWithFormat:@"%@ is off to a slow start for you as you weren't able to profit in the first game of the month.", monthName];
        
        if(numGames==2 && streak<-1)
            return [NSString stringWithFormat:@"%@ is really not looking so great as you have now lost your first 2 games.", monthName];
        
        if(numGames==2 && streak==-1)
            return [NSString stringWithFormat:@"Tough loss. After starting the month on the right note, you are now 1 and 1 for %@ and looking to turn things back around.", monthName];
    }
     
    return [NSString stringWithFormat:@"Error on first games of month. numGames: %d, streak: %d", numGames, streak];
}

+(NSString *)getPokerQuote:(int)number
{
	NSArray *quotes = [NSArray arrayWithObjects:
					   @"\"Learning to play two pairs is worth about as much as a college education, and about as costly.\"\n  -- Mark Twain",
					   @"\"Limit poker is a science, but no-limit is an art. In limit, you are shooting at a target. In no-limit, the target comes alive and shoots back at you.\"\n-Jack Strauss",
					   @"PTP Poker Advice: Never bust out with top pair. Weak players hit top pair and they think they just won the lottery. Donkeys will call any bet with top pair but good players can easily fold it when they sense danger. Similarly, never call with top pair: re-raise or fold.",
					   @"\"The guy who invented poker was bright, but the guy who invented the chip was a genius.\"\n-- Julius Weintraub",
					   @"\"Cards are war, in disguise of a sport.\"\n-- Charles Lamb",
					   @"PTP Poker Advice: With a large number of people in the hand, it is best to bet the flop when you pair your ace, regardless of kicker. An ace on the board gives everyone some kind of straight draw so giving a free card is a mistake, even if you hold pocket aces.",
					   @"\"Poker may be a branch of psychological warfare, an art form or indeed a way of life; but it is also merely a game, in which money is simply the means of keeping score.\"\n-- Anthony Holden",
					   @"\"The strong point in poker is never to lose your temper, either with those you are playing with or, more particularly, with the cards.\"\n-William J. Florence",
					   @"Remember there's a sucker at every table. So if, after the first twenty minutes, you can't spot the sucker... it's you!",
					   @"PTP Poker Advice: Never slow play 2-pair. It feels like a monster when it hits but is easily counterfeited. More money is lost with 2-pair than any other hand.",
					   @"\"Aces are larger than life and greater than mountains.\"\n-- Mike Caro",
					   @"\"It's not enough to succeed. Others must fail.\"\n - Gore Vidal",
					   @"\"Poker exemplifies the worst aspects of capitalism that have made our country so great.\"\n- Walter Matthau",
					   @"PTP Poker Advice: Never chase flushes and straights heads up. Having 3 or more players in a hand gives you pot odds to chase flushes, but heads up is generally bad poker.",
					   @"\"Baseball is like a poker game. Nobody wants to quit when he's losing; nobody wants you to quit when you're ahead.\"\n-Jackie Robinson",
					   @"\"I hope to break even this week. I need the money.\"\n--annonymous gambler",
					   @"PTP Poker Advice: The biggest difference between good and great players is skilled bet sizing. Strong players bet based, not on their own hands, but on their opponents. If they want a call they will bet $1 less than the opponent is willing to fold. If they want a fold, they will bet $1 more than the opponent is willing to call. The strength of their own hand is irrelevant.",
					   @"\"A Smith & Wesson beats four aces.\"\n-- famous American proverb",
					   @"PTP Poker Advice: Play Big-Pot-Poker. Always play for big pots and avoid winning small ones. The object is to build pots if you are ahead and fold if you are behind. Trying to steal a $10 pot with nothing is bad poker!",
					   @"\"At gambling, the deadly sin is to mistake bad play for bad luck.\"\n-- Ian Fleming",
					   @"\"Neither I nor anyone else can guarantee you will win. If someone tells you they can, do not believe them. Run making sure you have a death grip on your wallet.\"\n-Ken Pearlman",
					   @"\"The smarter you play, the luckier you'll be.\"\n-Mark Pilarski",
					   @"PTP Poker Advice: Risk your good hands. Put your good hands in play and don't fear them! Losing $100 with pocket aces is better poker than winning $4 with them.",
					   @"\"No wife can endure a gambling husband unless he is a steady winner.\"\n-Lord Dewar",
					   @"\"Judged by the dollars spent, gambling is now more popular in America than baseball, the movies, and Disneyland-combined.\"\n-Timothy L. O'Brien",
					   @"\"Luck never gives; it only lends\"\n-- Swedish Proverb",
					   @"PTP Poker Advice: Play tight, play aggressive and play smart. Don't be afraid to fold for an hour and don't complain about it either! Being card dead is part of the game and everyone has to deal with it.",
					   @"\"They gambled in the Garden of Eden, and they will again if there's another one.\"\n-- Richard Albert Canfield",
					   @"\"The commonest mistake in history is underestimating your opponent; it happens at the poker table all the time.\"\n-David Shoup",
					   @"\"Poker's a day to learn and a lifetime to master.\"\n  ~Robert Williamson III",
					   @"PTP Poker Advice: Avoid playing pocket pairs heads up. Pocket pairs lose all their value when playing heads up against a raiser. You have a 1 in 8 chance of spiking a set, which makes the math tough to win. Its better to fold or re-raise preflop, because calling a large bet just to fold on the flop is losing poker.",
					   @"\"I never go looking for a sucker. I look for a Champion and make a sucker of of him.\"\n- Slim Preston",
					   @"\"Poker is a lot like sex, everyone thinks they are the best, but most don't have a clue what they are doing!\"\n - Dutch Boy'd",
					   @"\"Hold'em is a game of calculated aggression: Any cards good enough to call, are good enough to raise.\"\n-- Alfred Alvarez",
					   @"PTP Poker Advice: Short Stack Rule - When short stacked, its better to bet 1/3rd of your chips preflop and push all-in on the flop, rather than pushing all-in preflop. By pushing all-in preflop you will either win a tiny pot or be facing a 50% chance of getting knocked out. Both are bad situations. By betting the flop you gain a ton of fold equity.",
					   @"\"Show me a good loser and I'll show you a loser.\"\n - Stu Ungar",
					   @"\"If you reraise a raiser, and he doesn't raise you back, you know he has kicker problems.\"\n-- Crandall Addington",
					   @"\"Sometimes you'll miss a bet, sure, but it's OK to miss a bet. Poker is an art form, of course, but sometimes you have to sacrifice art in favour of making a profit.\"\n - Mike Caro",
					   @"PTP Poker Advice: Slow-play Trips. When 2 matching cards flop giving you trips its almost always best to slow play them. The board is scary so leading out with a bet will generally win you a tiny pot. Besides that if you have kicker problems you don't want the betting too out of control.",
					   @"\"Poker is a microcosm of all we admire and disdain about capitalism and democracy.\"\n- Lou Krieger",
					   @"PTP Poker Advice: The most important skill at the poker table is not math, or reads, or courage or even temperament. It is patience. Those who cannot wait for their opportunity will be throwing money into the pot when it ís someone else's opportunity.",
					   @"\"One day a chump, the next day a champion. What a difference a day makes in tournament poker.\"\n-- Mike Sexton",
					   @"\"Most of the money you'll win at poker comes not from the brilliance of your own play, but from the ineptitude of your opponents.\"\n - Lou Krieger",
					   @"PTP Poker Advice: Flopped Straight Rule: Always bet when you flop a straight because your hand is well disguised and there's a high chance of getting counterfeited.",
					   @"\"Hold em is to stud what chess is to checkers.\"\n-- Johnny Moss",
					   @"\"It's immoral to let a sucker keep his money.\"\n - Canada Bill Jones",
					   @"\"In the long run there's no luck in poker, but the short run is longer than most people know.\"\n - Rick Bennet",
					   @"PTP Poker Advice: Pot Committed Rule: If you are already pot committed and first to act on the river, ALWAYS push all-in no matter how scary the river card is. Checking does no good because if the river card killed you, you are still forced to call any bet, but if you are ahead, you are giving your opponent a free check.",
                       @"\"It is better to let people think you are a bad poker player, then to play and remove all doubt.\"\n -- Michael Gersitz",
					   @"\"Omaha is a game that was invented by a Sadist and is played by Masochists.\"\n-- Shane Smith",
					   @"PTP Poker Quote: If you survey any 10 poker players, all 10 will claim to suffer more bad beats than they dish out. So who is doing all the bad beating?",
					   @"\"The next best thing to gambling and winning is gambling and losing.\"\n - Nick \"The Greek\" Dandalos",
					   @"\"When a man with money meets a man with experience, the man with experience leaves with money and the man with money leaves with experience.\"\n - Anonymous",
					   @"PTP Poker Advice: Reliable Tells. A player who looks long at his hold cards is likely on a very strong draw. always bet big. Also a player who grabs his chips out of turn, in an aggressive manor like he is getting ready to make a big bet is hoping to intimidate you and is likely on a strong draw. Always bet big.",
					   @"\"Poker is generally reckoned to be America's second most popular after-dark activity.  Sex is good, they say, but poker lasts longer.\"\n   -- Alfred Alvarez (2001)",
					   @"\"To master poker and make it profitable, you must first master patience and discipline, as a lack of either is a sure disaster regardless of all other talents, or lucky streaks.\"\n   -- Freddie Gasperian",
					   @"PTP Poker Advice: As a poker player think of yourself as an investor. Investing in your own skills. If you are bullish on your prospects to win, buy in for the max chips and rebuy for the max allowed. If, on the other hand, you expect to lose, buy in for the minimum and leave when your chips run out.",
					   @"\"The single greatest key to winning is knowing thy enemy... Yourself!\"\n   -- Andy Glazer",
                       @"\"There is a very easy way to return from a casino with a small fortune: go there with a large one.\"\n -- Jack Yelton",
					   @"PTP Poker Advice: Reliable Tells. A player with shaking hands or trys to goad you into calling by saying something like, 'I think you are bluffing' has a monster. Be very cautious. On the other hand, a player that stares you down or directs his bet towards you in an aggressive manor is trying to intimidate and is hoping for a fold.",
					   @"\"Poker is not a game in which the meek inherit the earth.\"\n -- David Hayano",
					   @"\"There is more to poker than life.\"\n   -- Tom McEvoy",
					   @"PTP Poker Advice: Never fold with 1/3 of your chips in the pot. Realize, before you bet, that you are making yourself pot committed.",
                       @"\"Poker is a combination of luck and skill. People think mastering the skill part is hard, but they're wrong. The trick to poker is mastering the luck.\"\n -- Jesse May",
                       @"\"If you play bridge badly you make your partner suffer, but if you play poker badly you make everybody happy.\"\n -- Joe Laurie Jr",
                       @"\"There's opportunity in poker.... If Horace Greeley were alive today, his advice wouldn't be 'Go West, young man, and grow up with the country.' Instead, he'd point to that deck of cards on table and say, 'Shuffle up and deal!' \"\n -- Lou Krieger",
                       @"\"The ignorance of the people is fearful. Why, I have known clergymen, good men, kind-hearted, sincere, and all that, who did not know the meaning of a flush. It is enough to make one ashamed of the species.\"\n -- Mark Twain",
                       @"\"People would be surprised to know how much I learned about prayer from playing poker.\"\n -- Mary Austin",
                       @"\"A dollar won is twice as sweet as a dollar earned.\"\n -- Paul Newman",
                       @"\"Last night I stayed up late playing poker with Tarot cards. I got a full house and four people died.\"\n -- Steven Wright",
                       @"\"Your best chance to get a Royal Flush in a casino is in the bathroom.\"\n -- VP Pappy",
                       @"\"Lottery: A tax on people who are bad at math.\"\n -- Unknown",
					   nil];
   return [quotes stringAtIndex:number%[quotes count]];
}

+(NSString *)openingBasedOnStats:(int)lastMonthLevel
                  thisMonthLevel:(int)thisMonthLevel
                           games:(int)games
                           month:(NSString *)month
               winningsLastMonth:(int)winningsLastMonth
               winningsThisMonth:(int)winningsThisMonth
{
    NSString *numStr = [ProjectFunctions numberWithSuffix:games];
    switch (lastMonthLevel) {
        case 0:
            switch (thisMonthLevel) {
                case 0:
                    return [NSString stringWithFormat:@"Well at least you are consistent. We all thought last month was a disaster but after %d games, your %@ play is proof that you are flat out just a bad player.", games, month];
                    break;
                case 1:
                    return [NSString stringWithFormat:@"After %d games completed, %@ is a total disaster. The single redeeming fact is that this month is just slightly less crappy than last month.", games, month];
                    break;
                case 2:
                    return [NSString stringWithFormat:@"With %d games on the books, you are managing to keep a positive bankroll in %@, which is a huge improvement from the disaster you faced last month.", games, month];
                    break;
                case 3:
                    return [NSString stringWithFormat:@"Wow! What a difference a month makes. You just completed your %@ game and %@ is shaping up to be a great poker month for you. Much improved from the bloodbath last month. You have been able to add %@ to your bankroll in %@.", numStr, month, [ProjectFunctions convertIntToMoneyString:winningsLastMonth], month];
                    break;
                case 4:
                    return [NSString stringWithFormat:@"Amazing! From worst to first in one month! %@ has been a fantastic month for you, with %@ in winnings after just completing your %@ game. A huge swing from the disaster last month.", month, [ProjectFunctions convertIntToMoneyString:winningsLastMonth], numStr];
                    break;
                    
                default:
                    break;
            }
            break;
        case 1:
            switch (thisMonthLevel) {
                case 0:
                    return [NSString stringWithFormat:@"Just when we thought it couldn't get any worse. We all thought last month was a disaster but after %d games, you have actually managed to play even more poorly in %@!", games, month];
                    break;
                case 1:
                    return [NSString stringWithFormat:@"After %d games completed, %@ is another losing month for you so far. You are on pace to finish this month about the same as last.", games, month];
                    break;
                case 2:
                    return [NSString stringWithFormat:@"With %d games on the books, you are managing to keep a positive bankroll in %@, which is a an improvement from the losing you faced last month.", games, month];
                    break;
                case 3:
                    return [NSString stringWithFormat:@"Wow! What a difference a month makes. You just completed your %@ game and %@ is shaping up to be a great poker month for you. Much improved from the disappointment last month. You have been able to add %@ to your bankroll in %@.", numStr, month, [ProjectFunctions convertIntToMoneyString:winningsLastMonth], month];
                    break;
                case 4:
                    return [NSString stringWithFormat:@"Amazing! You have really turned your game around this month! %@ has been a fantastic month for you so far, with %@ in winnings after just completing your %@ game. A nice turnaround from the losses last month.", month, [ProjectFunctions convertIntToMoneyString:winningsLastMonth], numStr];
                    break;
                    
                default:
                    break;
            }
            break;
        case 2:
            switch (thisMonthLevel) {
                case 0:
                    return [NSString stringWithFormat:@"So far after %d games, %@ is a disaster. Especially compared to last month when you were able to bring in %@ in profit.", games, month, [ProjectFunctions convertIntToMoneyString:winningsLastMonth]];
                    break;
                case 1:
                    return [NSString stringWithFormat:@"After %d games completed, %@ is shaping up to be a losing month. Not quite as nice as last month when you brought in %@ in profit.", games, month, [ProjectFunctions convertIntToMoneyString:winningsLastMonth]];
                    break;
                case 2:
                    return [NSString stringWithFormat:@"With %d games on the books, you are managing to keep a positive bankroll in %@, about on pace with your play last month.", games, month];
                    break;
                case 3:
                    return [NSString stringWithFormat:@"You just completed your %@ game and %@ is shaping up to be another solid month and even better than you did last month. You have been able to add %@ to your bankroll this month.", numStr, month, [ProjectFunctions convertIntToMoneyString:winningsLastMonth]];
                    break;
                case 4:
                    return [NSString stringWithFormat:@"%@ has been a really fantastic month for you, with %@ in winnings after just completing your %@ game. A big improvement from last month.", month, [ProjectFunctions convertIntToMoneyString:winningsLastMonth], numStr];
                    break;
                    
                default:
                    break;
            }
            break;
        case 3:
            switch (thisMonthLevel) {
                case 0:
                    return [NSString stringWithFormat:@"So far after %d games, %@ is a disaster. Especially compared to last month when you raked in %@ in profit.", games, month, [ProjectFunctions convertIntToMoneyString:winningsLastMonth]];
                    break;
                case 1:
                    return [NSString stringWithFormat:@"After %d games completed, %@ is shaping up to be a pretty crappy month compared to last month when you added %@ in profit.", games, month, [ProjectFunctions convertIntToMoneyString:winningsLastMonth]];
                    break;
                case 2:
                    return [NSString stringWithFormat:@"With %d games on the books, you are managing to keep a positive bankroll in %@, although it's not quite as strong as you did last month.", games, month];
                    break;
                case 3:
                    return [NSString stringWithFormat:@"You just completed your %@ game and %@ is shaping up to be another solid month and on pace with what you did last month. You have been able to add %@ to your bankroll this month.", numStr, month, [ProjectFunctions convertIntToMoneyString:winningsLastMonth]];
                    break;
                case 4:
                    return [NSString stringWithFormat:@"%@ has been another fantastic month for you, with %@ in winnings after just completing your %@ game. You are on pace to have an even better month than you did last month.", month, [ProjectFunctions convertIntToMoneyString:winningsLastMonth], numStr];
                    break;
                    
                default:
                    break;
            }
            break;
        case 4:
            switch (thisMonthLevel) {
                case 0:
                    return [NSString stringWithFormat:@"So far after %d games, %@ is a disaster. Especially compared to last month when you raked in %@ in profit.", games, month, [ProjectFunctions convertIntToMoneyString:winningsLastMonth]];
                    break;
                case 1:
                    return [NSString stringWithFormat:@"After %d games completed, %@ is shaping up to be a pretty crappy month compared to last month when you raked in %@ in profit.", games, month, [ProjectFunctions convertIntToMoneyString:winningsLastMonth]];
                    break;
                case 2:
                    return [NSString stringWithFormat:@"With %d games on the books, you are managing to keep a positive bankroll in %@, although it's not nearly as strong as you did last month.", games, month];
                    break;
                case 3:
                    return [NSString stringWithFormat:@"You just completed your %@ game and %@ is shaping up to be another solid month although not quite as good as you did last month. You have been able to add %@ to your bankroll this month.", numStr, month, [ProjectFunctions convertIntToMoneyString:winningsLastMonth]];
                    break;
                case 4:
                    return [NSString stringWithFormat:@"%@ has been another fantastic month for you, with %@ in winnings after just completing your %@ game.", month, [ProjectFunctions convertIntToMoneyString:winningsLastMonth], numStr];
                    break;
                    
                default:
                    break;
            }
            break;
            
        default:
            break;
    }
    return @"Empty";
}

+(NSString *)getBestTimes:(int)displayYear gameType:(NSString *)gameType moc:(NSManagedObjectContext *)managedObjectContext
{
	NSString *basicPred = [ProjectFunctions getBasicPredicateString:displayYear type:gameType];

	NSArray *typeList = [ProjectFunctions namesOfAllWeekdays];
	NSString *weekday = @"";
	NSString *weekdayLo = @"";
	if (typeList.count>2) {
		weekday = [typeList objectAtIndex:0];
		weekdayLo = [typeList objectAtIndex:1];
	}
	int min=0;
	int max=0;
	for(NSString *type in typeList) {
		NSPredicate *predicate = [ProjectFunctions predicateForBasic:basicPred field:@"weekday" value:type];
		double winnings = [[CoreDataLib getGameStat:managedObjectContext dataField:@"winnings" predicate:predicate] doubleValue];
		if(winnings>min) {
			weekday = type;
			min=winnings;
		}
		if(winnings<max) {
			weekdayLo = type;
			max=winnings;
		}
	}

	min=0;
	max=0;
	NSArray *typeList2 = [ProjectFunctions namesOfAllDayTimes];
	NSString *daytime = [typeList2 objectAtIndex:2];
	NSString *daytimeLo = [typeList2 objectAtIndex:3];
	for(NSString *type in typeList2) {
		NSPredicate *predicate = [ProjectFunctions predicateForBasic:basicPred field:@"daytime" value:type];
		double winnings = [[CoreDataLib getGameStat:managedObjectContext dataField:@"winnings" predicate:predicate] doubleValue];
		if(winnings>min) {
			daytime = type;
			min=winnings;
		}
		if(winnings<max) {
			daytimeLo = type;
			max=winnings;
		}
	}
	return [NSString stringWithFormat:@"It looks like %@ %@s have been your best games, and %@ %@s have been your worst.", weekday, [daytime lowercaseString], weekdayLo, [daytimeLo lowercaseString]];
}
					   
					   
@end
