//
//  PokerCell.h
//  PokerTracker
//
//  Created by Rick Medved on 11/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface PokerCell : UITableViewCell {
	UILabel *selection;
	UIImageView *card1BG;
	UIImageView *card2BG;
	UIImageView *card3BG;

	UIImageView *suit1Image;
	UIImageView *suit2Image;
	UIImageView *suit3Image;
	
	IBOutlet UILabel *card1Label;
	IBOutlet UILabel *card2Label;
	IBOutlet UILabel *card3Label;
	
}

+(UITableViewCell *)pokerCell:(UITableView *)tableView cellIdentifier:(NSString *)cellIdentifier cellLabel:(NSString *)cellLabel cellValue:(NSString *)cellValue viewEditable:(BOOL)viewEditable;

@property (readonly) UILabel *selection;
@property (readonly) UIImageView *card1BG;
@property (readonly) UIImageView *card2BG;
@property (readonly) UIImageView *card3BG;

@property (readonly) UIImageView *suit1Image;
@property (readonly) UIImageView *suit2Image;
@property (readonly) UIImageView *suit3Image;

@property (readonly) UILabel *card1Label;
@property (readonly) UILabel *card2Label;
@property (readonly) UILabel *card3Label;

@end
