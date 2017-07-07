//
//  CardHandPicker.m
//  PokerTracker
//
//  Created by Rick Medved on 10/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CardHandPicker.h"
#import "PokerOddsFunctions.h"
#import "ProjectFunctions.h"
#import "OddsFormVC.h"


@implementation CardHandPicker
@synthesize label, textField, callBackViewController, titleLabel;
@synthesize numberCards, initialDateValue, randomButton, burnedcards;
@synthesize card1Segment, suit1Segment, card2Segment, suit2Segment, card3Segment, suit3Segment;
@synthesize conflictLabel, selectButton, managedObjectContext;
@synthesize card1BG, card2BG, card3BG, suit1Image, suit2Image, suit3Image, card1Label, card2Label, card3Label;


- (IBAction)randomButtonPressed:(id)sender {
	if(numberCards==1)
		self.textField.text = [PokerOddsFunctions getRandomCard:self.burnedcards];
	else if(numberCards==3)
		self.textField.text = [PokerOddsFunctions getRandomFlop:self.burnedcards];
	else
		self.textField.text = [PokerOddsFunctions getRandomHand:self.burnedcards];

	[self setUpSegments:[NSString stringWithFormat:@"%@", textField.text]];
}

- (IBAction)unknownButtonPressed:(id)sender {
    NSString *returnValue = @"2c-3c";
    switch (numberCards) {
        case 1:
            returnValue = @"?x";
            break;
        case 2:
            returnValue = @"?x-?x";
            break;
        case 3:
            returnValue = @"?x-?x-?x";
            break;
            
        default:
            break;
    }
	[ProjectFunctions setUserDefaultValue:returnValue forKey:@"returnValue"];
	[(OddsFormVC *)callBackViewController setReturningValue:returnValue];
	[self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)cancel:(id)sender {
	[self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)save:(id)sender {
	[ProjectFunctions setUserDefaultValue:[NSString stringWithFormat:@"%@", textField.text] forKey:@"returnValue"];
	[(OddsFormVC *)callBackViewController setReturningValue:@""];
	[self.navigationController popViewControllerAnimated:YES];
}

+(void)displayCardGraphic:(UIImageView *)suitImage cardlabel:(UILabel *)cardlabel card:(NSString *)card suit:(NSString *)suit
{
	cardlabel.text = card;
	if([suit isEqualToString:@"s"] || [suit isEqualToString:@"c"])
		cardlabel.textColor = [UIColor blackColor];
	else 
		cardlabel.textColor = [UIColor redColor];
	suitImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"card%@.png", suit]];
}

-(void)displayCardGraphics
{
  	NSArray *cards = [NSArray arrayWithObjects:@"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"T", @"J", @"Q", @"K", @"A", @"?", nil];
	NSArray *suits = [NSArray arrayWithObjects:@"c", @"d", @"h", @"s", nil];
	
	if(numberCards==1) {
		[CardHandPicker displayCardGraphic:suit2Image cardlabel:card2Label card:[cards objectAtIndex:card1Segment.selectedSegmentIndex] suit:[suits objectAtIndex:suit1Segment.selectedSegmentIndex]];
		self.textField.text = [NSString stringWithFormat:@"%@%@", [cards objectAtIndex:card1Segment.selectedSegmentIndex], [suits objectAtIndex:suit1Segment.selectedSegmentIndex]];
	} else if(numberCards==3) {
		[CardHandPicker displayCardGraphic:suit1Image cardlabel:card1Label card:[cards objectAtIndex:card1Segment.selectedSegmentIndex] suit:[suits objectAtIndex:suit1Segment.selectedSegmentIndex]];
		[CardHandPicker displayCardGraphic:suit2Image cardlabel:card2Label card:[cards objectAtIndex:card2Segment.selectedSegmentIndex] suit:[suits objectAtIndex:suit2Segment.selectedSegmentIndex]];
		[CardHandPicker displayCardGraphic:suit3Image cardlabel:card3Label card:[cards objectAtIndex:card3Segment.selectedSegmentIndex] suit:[suits objectAtIndex:suit3Segment.selectedSegmentIndex]];
		self.textField.text = [NSString stringWithFormat:@"%@%@-%@%@-%@%@", 
                               [cards objectAtIndex:card1Segment.selectedSegmentIndex], 
                               [suits objectAtIndex:suit1Segment.selectedSegmentIndex],
                               [cards objectAtIndex:card2Segment.selectedSegmentIndex], 
                               [suits objectAtIndex:suit2Segment.selectedSegmentIndex],
                               [cards objectAtIndex:card3Segment.selectedSegmentIndex], 
                               [suits objectAtIndex:suit3Segment.selectedSegmentIndex]
                               ];
	} else {
		[CardHandPicker displayCardGraphic:suit2Image cardlabel:card2Label card:[cards objectAtIndex:card1Segment.selectedSegmentIndex] suit:[suits objectAtIndex:suit1Segment.selectedSegmentIndex]];
		[CardHandPicker displayCardGraphic:suit3Image cardlabel:card3Label card:[cards objectAtIndex:card2Segment.selectedSegmentIndex] suit:[suits objectAtIndex:suit2Segment.selectedSegmentIndex]];
		self.textField.text = [NSString stringWithFormat:@"%@%@-%@%@", 
                               [cards objectAtIndex:card1Segment.selectedSegmentIndex], 
                               [suits objectAtIndex:suit1Segment.selectedSegmentIndex],
                               [cards objectAtIndex:card2Segment.selectedSegmentIndex], 
                               [suits objectAtIndex:suit2Segment.selectedSegmentIndex]
                               ];
	}
	NSArray *selectedCards = [textField.text componentsSeparatedByString:@"-"];
	self.conflictLabel.alpha=0;
	self.selectButton.enabled=YES;
	
	for(NSString *card in selectedCards) {
		if([self.burnedcards rangeOfString:card].location != NSNotFound) {
			self.conflictLabel.alpha=1;
			self.selectButton.enabled=NO;
		}
	} // for
	if([selectedCards count]==2 && [[selectedCards objectAtIndex:0] isEqualToString:[selectedCards objectAtIndex:1]]) {
		self.conflictLabel.alpha=1;
		self.selectButton.enabled=NO;
	}
	if([selectedCards count]==3) {
		if([[selectedCards objectAtIndex:0] isEqualToString:[selectedCards objectAtIndex:1]] || [[selectedCards objectAtIndex:1] isEqualToString:[selectedCards objectAtIndex:2]] || [[selectedCards objectAtIndex:0] isEqualToString:[selectedCards objectAtIndex:2]]) {
			self.conflictLabel.alpha=1;
			self.selectButton.enabled=NO;
		}
	}
  
}

- (IBAction) segmentPressed: (id) sender
{
    [self displayCardGraphics];
}



-(void)setUpSegments:(NSString *)textValue
{
	
	NSArray *cards = [NSArray arrayWithObjects:@"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"T", @"J", @"Q", @"K", @"A", @"?", nil];
	NSArray *suits = [NSArray arrayWithObjects:@"c", @"d", @"h", @"s", nil];
	if(![textValue isEqualToString:@"-select-"]) {
		NSArray *cardList = [textValue componentsSeparatedByString:@"-"];
		int i=1;
		for(NSString *cardValue in cardList) {
			NSString *card = [cardValue substringToIndex:1];
			NSString *suit = [cardValue substringFromIndex:1];
			
			int x=0;
			for(NSString *possibleCardValue in cards) {
				if([possibleCardValue isEqualToString:card]) {
					if(i==1)
						self.card1Segment.selectedSegmentIndex=x;
					if(i==2)
						self.card2Segment.selectedSegmentIndex=x;
					if(i==3)
						self.card3Segment.selectedSegmentIndex=x;
				}
				x++;
			}
			x=0;
			for(NSString *possibleSuitValue in suits) {
				if([possibleSuitValue isEqualToString:suit]) {
					if(i==1)
						self.suit1Segment.selectedSegmentIndex=x;
					if(i==2)
						self.suit2Segment.selectedSegmentIndex=x;
					if(i==3)
						self.suit3Segment.selectedSegmentIndex=x;
				}
				x++;
			}
			i++;
		}
	}
    [self displayCardGraphics];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	[self setTitle:@"Hand Picker"];

//	UIBarButtonItem *modalButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancel:)];
//	self.navigationItem.leftBarButtonItem = modalButton;
	self.navigationItem.leftBarButtonItem = [ProjectFunctions UIBarButtonItemWithIcon:[NSString fontAwesomeIconStringForEnum:FATimes] target:self action:@selector(cancel:)];
	
	selectButton = [[UIBarButtonItem alloc] initWithTitle:@"Select" style:UIBarButtonItemStyleBordered target:self action:@selector(save:)];
	self.navigationItem.rightBarButtonItem = selectButton;
	
	self.label.text = [NSString stringWithFormat:@"%@", self.titleLabel];

	self.conflictLabel.alpha=0;
	self.selectButton.enabled=YES;

	if(numberCards==1) {
		self.card2Segment.alpha=0;
		self.suit2Segment.alpha=0;
		self.card3Segment.alpha=0;
		self.suit3Segment.alpha=0;
		self.card1BG.alpha=0;
		self.suit1Image.alpha=0;
		self.card1Label.alpha=0;
		self.card3BG.alpha=0;
		self.suit3Image.alpha=0;
		self.card3Label.alpha=0;
		if([self.initialDateValue isEqualToString:@"-select-"])
			self.initialDateValue = @"2c";
	} else if(numberCards==3) {
		if([self.initialDateValue isEqualToString:@"-select-"])
			self.initialDateValue = @"2c-3c-4c";
	} else {
		self.card1BG.alpha=0;
		self.suit1Image.alpha=0;
		self.card1Label.alpha=0;
		self.card3Segment.alpha=0;
		self.suit3Segment.alpha=0;
		if([self.initialDateValue isEqualToString:@"-select-"])
			self.initialDateValue = @"2c-3c";
	}

	[CardHandPicker displayCardGraphic:suit2Image cardlabel:card2Label card:@"2" suit:@"c"];
	self.textField.text = [NSString stringWithFormat:@"%@", self.initialDateValue];
    
	

	[self setUpSegments:self.initialDateValue];

}






@end
