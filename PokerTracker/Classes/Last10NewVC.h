//
//  Last10NewVC.h
//  PokerTracker
//
//  Created by Rick Medved on 12/11/12.
//
//

#import <UIKit/UIKit.h>
#import "GameSummaryView.h"
#import "TemplateVC.h"

@interface Last10NewVC : TemplateVC
{
	NSMutableArray *bestGames;
}


@property (nonatomic, strong) IBOutlet GameSummaryView *gameSummaryView;
@property (nonatomic, strong) NSMutableArray *bestGames;

@end
