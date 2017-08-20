//
//  PokerCell.m
//  PokerTracker
//
//  Created by Rick Medved on 11/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PokerCell.h"
#import "UIColor+ATTColor.h"
#import "CardHandPicker.h"
#import "ProjectFunctions.h"

#define kCellLeftOffset			8.0
#define kTextWidth				160.0


@implementation PokerCell
@synthesize selection, card1BG, card2BG, card3BG, suit1Image, suit2Image, suit3Image;
@synthesize card1Label, card2Label, card3Label;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        // Initialization code
		self.textLabel.font = [UIFont boldSystemFontOfSize:[UIFont labelFontSize]];	// label is 17, system is 14
		self.textLabel.textAlignment = NSTextAlignmentLeft;
		
		self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		
        selection = [[UILabel alloc] initWithFrame:CGRectZero];
        selection.font = [UIFont systemFontOfSize:[UIFont labelFontSize]];
		selection.adjustsFontSizeToFitWidth = YES;
		selection.minimumScaleFactor = .7;
		selection.textAlignment = NSTextAlignmentRight;
		selection.textColor = [ProjectFunctions themeBGColor];
        selection.backgroundColor = [UIColor clearColor];
		
		[self.contentView addSubview:selection];
		
		card1BG = [[UIImageView alloc] initWithFrame:CGRectZero];
		card1BG.image = [UIImage imageNamed:@"blankCard.png"];
		card1BG.frame = CGRectMake(160, 0, 35, 42);
		[self.contentView addSubview:card1BG];
		
		card2BG = [[UIImageView alloc] initWithFrame:CGRectZero];
		card2BG.image = [UIImage imageNamed:@"blankCard.png"];
		card2BG.frame = CGRectMake(200, 0, 35, 42);
		[self.contentView addSubview:card2BG];
		
		card3BG = [[UIImageView alloc] initWithFrame:CGRectZero];
		card3BG.image = [UIImage imageNamed:@"blankCard.png"];
		card3BG.frame = CGRectMake(240, 0, 35, 42);
		[self.contentView addSubview:card3BG];
		
		suit1Image = [[UIImageView alloc] initWithFrame:CGRectZero];
		suit1Image.image = [UIImage imageNamed:@"cards.png"];
		suit1Image.frame = CGRectMake(170, 22, 16, 16);
		[self.contentView addSubview:suit1Image];
		
		suit2Image = [[UIImageView alloc] initWithFrame:CGRectZero];
		suit2Image.image = [UIImage imageNamed:@"cards.png"];
		suit2Image.frame = CGRectMake(210, 22, 16, 16);
		[self.contentView addSubview:suit2Image];
		
		suit3Image = [[UIImageView alloc] initWithFrame:CGRectZero];
		suit3Image.image = [UIImage imageNamed:@"cards.png"];
		suit3Image.frame = CGRectMake(250, 22, 16, 16);
		[self.contentView addSubview:suit3Image];

		card1Label = [[UILabel alloc] initWithFrame:CGRectZero];
		card1Label.text = @"A";
		card1Label.frame = CGRectMake(172, 4, 20, 20);
		card1Label.backgroundColor = [UIColor clearColor];
		[self.contentView addSubview:card1Label];
		
		card2Label = [[UILabel alloc] initWithFrame:CGRectZero];
		card2Label.text = @"A";
		card2Label.frame = CGRectMake(212, 4, 20, 20);
		card2Label.backgroundColor = [UIColor clearColor];
		[self.contentView addSubview:card2Label];
		
		card3Label = [[UILabel alloc] initWithFrame:CGRectZero];
		card3Label.text = @"A";
		card3Label.frame = CGRectMake(252, 4, 20, 20);
		card3Label.backgroundColor = [UIColor clearColor];
		[self.contentView addSubview:card3Label];
		
    }
    return self;
}


- (void)layoutSubviews
{	
	[super layoutSubviews];
    CGRect contentRect = [self.contentView bounds];
	
	CGRect uiFrame = CGRectMake(contentRect.size.width - kTextWidth - kCellLeftOffset, 0,
								kTextWidth, contentRect.size.height);
	selection.frame = uiFrame;
	[self.contentView bringSubviewToFront:selection];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	
    [super setSelected:selected animated:animated];
	
    // Configure the view for the selected state
}

+(UITableViewCell *)pokerCell:(UITableView *)tableView cellIdentifier:(NSString *)cellIdentifier cellLabel:(NSString *)cellLabel cellValue:(NSString *)cellValue viewEditable:(BOOL)viewEditable
{
	PokerCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (cell == nil) {
		cell = [[PokerCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
	}
	
	cell.textLabel.text = cellLabel;
	cell.selection.text = cellValue;
	
	cell.backgroundColor = [ProjectFunctions primaryButtonColor];
	cell.selectionStyle = UITableViewCellSelectionStyleGray;
	if(viewEditable)
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	else
		cell.accessoryType = UITableViewCellAccessoryNone;
	
	if([cellValue isEqualToString:@""] || [cellValue isEqualToString:@"-select-"]) {
		cell.card1BG.alpha=0;
		cell.suit1Image.alpha=0;
		cell.card1Label.alpha=0;
		cell.card2BG.alpha=0;
		cell.suit2Image.alpha=0;
		cell.card2Label.alpha=0;
		cell.card3BG.alpha=0;
		cell.suit3Image.alpha=0;
		cell.card3Label.alpha=0;
		return cell;
	}
	
	cell.selection.alpha=0;
    
    cell.card1BG.image = [UIImage imageNamed:@"blankCard.png"];
    cell.card2BG.image = [UIImage imageNamed:@"blankCard.png"];
    cell.card3BG.image = [UIImage imageNamed:@"blankCard.png"];
    
    if([cellValue isEqualToString:@"?x"]) {
		cell.card1BG.alpha=0;
		cell.suit1Image.alpha=0;
		cell.card1Label.alpha=0;
		cell.card2BG.alpha=1;
		cell.suit2Image.alpha=0;
		cell.card2Label.alpha=0;
        cell.card2BG.image = [UIImage imageNamed:@"cardBack.png"];
		cell.card3BG.alpha=0;
		cell.suit3Image.alpha=0;
		cell.card3Label.alpha=0;
        return cell;
    }
	
    if([cellValue isEqualToString:@"?x-?x"]) {
		cell.card1BG.alpha=0;
		cell.suit1Image.alpha=0;
		cell.card1Label.alpha=0;
		cell.card2BG.alpha=1;
		cell.suit2Image.alpha=0;
		cell.card2Label.alpha=0;
        cell.card2BG.image = [UIImage imageNamed:@"cardBack.png"];
        cell.card3BG.image = [UIImage imageNamed:@"cardBack.png"];
		cell.card3BG.alpha=1;
		cell.suit3Image.alpha=0;
		cell.card3Label.alpha=0;
        return cell;
    }
	
    if([cellValue isEqualToString:@"?x-?x-?x"]) {
		cell.card1BG.alpha=1;
		cell.suit1Image.alpha=0;
		cell.card1Label.alpha=0;
		cell.card2BG.alpha=1;
		cell.suit2Image.alpha=0;
		cell.card2Label.alpha=0;
        cell.card1BG.image = [UIImage imageNamed:@"cardBack.png"];
        cell.card2BG.image = [UIImage imageNamed:@"cardBack.png"];
        cell.card3BG.image = [UIImage imageNamed:@"cardBack.png"];
		cell.card3BG.alpha=1;
		cell.suit3Image.alpha=0;
		cell.card3Label.alpha=0;
        return cell;
    }
	
	NSArray *cards = [cellValue componentsSeparatedByString:@"-"];
	if([cards count]==1) {
		NSString *cardValue = [cards objectAtIndex:0];
		NSString *card = [cardValue substringToIndex:1];
		NSString *suit = [cardValue substringFromIndex:1];
		[CardHandPicker displayCardGraphic:cell.suit3Image cardlabel:cell.card3Label card:card suit:suit];
		cell.card1BG.alpha=0;
		cell.suit1Image.alpha=0;
		cell.card1Label.alpha=0;
		cell.card2BG.alpha=0;
		cell.suit2Image.alpha=0;
		cell.card2Label.alpha=0;
		cell.card3BG.alpha=1;
		cell.suit3Image.alpha=1;
		cell.card3Label.alpha=1;
	}
	if([cards count]==2) {
		NSString *cardValue = [cards objectAtIndex:0];
		NSString *card = [cardValue substringToIndex:1];
		NSString *suit = [cardValue substringFromIndex:1];
		[CardHandPicker displayCardGraphic:cell.suit2Image cardlabel:cell.card2Label card:card suit:suit];
		
		NSString *cardValue2 = [cards objectAtIndex:1];
		NSString *card2 = [cardValue2 substringToIndex:1];
		NSString *suit2 = [cardValue2 substringFromIndex:1];
		[CardHandPicker displayCardGraphic:cell.suit3Image cardlabel:cell.card3Label card:card2 suit:suit2];
		
		cell.card1BG.alpha=0;
		cell.suit1Image.alpha=0;
		cell.card1Label.alpha=0;
		cell.card2BG.alpha=1;
		cell.suit2Image.alpha=1;
		cell.card2Label.alpha=1;
		cell.card3BG.alpha=1;
		cell.suit3Image.alpha=1;
		cell.card3Label.alpha=1;
	}
	if([cards count]==3) {
		NSString *cardValue = [cards objectAtIndex:0];
		NSString *card = [cardValue substringToIndex:1];
		NSString *suit = [cardValue substringFromIndex:1];
		[CardHandPicker displayCardGraphic:cell.suit1Image cardlabel:cell.card1Label card:card suit:suit];
		
		NSString *cardValue2 = [cards objectAtIndex:1];
		NSString *card2 = [cardValue2 substringToIndex:1];
		NSString *suit2 = [cardValue2 substringFromIndex:1];
		[CardHandPicker displayCardGraphic:cell.suit2Image cardlabel:cell.card2Label card:card2 suit:suit2];
		
		NSString *cardValue3 = [cards objectAtIndex:2];
		NSString *card3 = [cardValue3 substringToIndex:1];
		NSString *suit3 = [cardValue3 substringFromIndex:1];
		[CardHandPicker displayCardGraphic:cell.suit3Image cardlabel:cell.card3Label card:card3 suit:suit3];
		
		cell.card1BG.alpha=1;
		cell.card2BG.alpha=1;
		cell.suit1Image.alpha=1;
		cell.card1Label.alpha=1;
		cell.suit2Image.alpha=1;
		cell.card2Label.alpha=1;
		cell.card3BG.alpha=1;
		cell.suit3Image.alpha=1;
		cell.card3Label.alpha=1;
	}
	
	return cell;
}





@end
