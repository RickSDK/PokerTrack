//
//  CustomSegment.m
//  WealthTracker
//
//  Created by Rick Medved on 10/29/15.
//  Copyright (c) 2015 Rick Medved. All rights reserved.
//

#import "CustomSegment.h"
#import "ProjectFunctions.h"
#import "CoreDataLib.h"

@implementation CustomSegment

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
		[self commonInit];
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self) {
		[self commonInit];
	}
	return self;
}

- (id)initWithItems:(NSArray *)items {
	self = [super initWithItems:items];
	if (self) {
		[self commonInit];
	}
	return self;
}

- (void)commonInit
{
	//	[self setTintColor:[UIColor colorWithRed:(6/255.0) green:(122/255.0) blue:(180/255.0) alpha:1.0]];

	self.layer.cornerRadius = 4;
	self.layer.masksToBounds = YES;
	self.layer.borderColor = [UIColor blackColor].CGColor;
	self.layer.borderWidth = 1;

	[self applyThemeColor];

	[self applyFontOfSize:13];
	
	[self changeSegment];
	
	[self addTarget:self action:@selector(valueChanged) forControlEvents:UIControlEventValueChanged];
}

-(void)valueChanged {
	[self changeSegment];
}

-(void)applyFontOfSize:(float)size {
	UIFont *font = [UIFont fontWithName:kFontAwesomeFamilyName size:size];
	NSMutableDictionary *attribsNormal;
	attribsNormal = [NSMutableDictionary dictionaryWithObjectsAndKeys:font, UITextAttributeFont, [UIColor whiteColor], UITextAttributeTextColor, nil];
	
	NSMutableDictionary *attribsSelected;
	attribsSelected = [NSMutableDictionary dictionaryWithObjectsAndKeys:font, UITextAttributeFont, [UIColor blackColor], UITextAttributeTextColor, nil];
	
	[self setTitleTextAttributes:attribsNormal forState:UIControlStateNormal];
	[self setTitleTextAttributes:attribsSelected forState:UIControlStateSelected];
}

-(void)applyThemeColor {
	[self setTintColor:[ProjectFunctions primaryButtonColor]];
	self.layer.backgroundColor = [ProjectFunctions themeBGColor].CGColor;
}

-(void)turnIntoTop5Segment {
	if(self.numberOfSegments==3) {
		[self setTitle:[NSString stringWithFormat:@"%@ %@", [NSString fontAwesomeIconStringForEnum:FAStar], NSLocalizedString(@"Game", nil)] forSegmentAtIndex:0];
		[self setTitle:[NSString stringWithFormat:@"%@ %@", [NSString fontAwesomeIconStringForEnum:FACalendar], NSLocalizedString(@"month", nil)] forSegmentAtIndex:1];
		[self setTitle:[NSString stringWithFormat:@"%@ %@", [NSString fontAwesomeIconStringForEnum:FAcalendarCheckO], NSLocalizedString(@"Quarter", nil)] forSegmentAtIndex:2];
	}
}

-(void)turnIntoGameSegment {
	if(self.numberOfSegments==2)
		return [self twoSegmentBar];
	
	int index=0;
	if(self.numberOfSegments==3) {
		[self changeGameSegmentForIndex:index name:@"All" alt:[NSString stringWithFormat:@"%@ + %@", [NSString fontAwesomeIconStringForEnum:FAMoney], [NSString fontAwesomeIconStringForEnum:FATrophy]]];
		index++;
	}
	[self changeGameSegmentForIndex:index++ name:@"Cash Games" alt:[NSString fontAwesomeIconStringForEnum:FAMoney]];
	[self changeGameSegmentForIndex:index name:@"Tournaments" alt:[NSString fontAwesomeIconStringForEnum:FATrophy]];
}

-(void)twoSegmentBar {
	[self changeGameSegmentForIndex:0 name:@"Cash Game" alt:@"Cash Game"];
	[self changeGameSegmentForIndex:1 name:@"Tournament" alt:@"Tournament"];
}

-(void)changeGameSegmentForIndex:(int)index name:(NSString *)name alt:(NSString *)alt {
	if(self.selectedSegmentIndex==index)
		[self setTitle:[NSString stringWithFormat:@"%@%@", [NSString fontAwesomeIconStringForEnum:FACheck], NSLocalizedString(name, nil)] forSegmentAtIndex:index];
	else
		[self setTitle:NSLocalizedString(alt, nil) forSegmentAtIndex:index];
}

-(void)turnIntoFilterSegment:(NSManagedObjectContext *)context {
	[self applyFontOfSize:11];
	if(self.numberOfSegments==4) {
		[self setTitle:@"-None-" forSegmentAtIndex:0];
		for(int i=1; i<=3; i++) {
			NSPredicate *predicate = [NSPredicate predicateWithFormat:@"button = %d", i];
			NSArray *filters = [CoreDataLib selectRowsFromEntity:@"FILTER" predicate:predicate sortColumn:@"button" mOC:context ascendingFlg:YES];
			if([filters count]>0) {
				NSManagedObject *mo = [filters objectAtIndex:0];
				NSString *name = [mo valueForKey:@"name"];
				if(name.length>12)
					name = [name substringToIndex:12];
				[self setTitle:name forSegmentAtIndex:i];
			} else
				[self setTitle:@"Extra" forSegmentAtIndex:i];
		}
	}
	[self changeSegment];
}

-(void)turnIntoTypeSegment {
	if(self.numberOfSegments==5) {
		[self setTitle:[NSString fontAwesomeIconStringForEnum:FAMoney] forSegmentAtIndex:0];
		[self setTitle:[NSString fontAwesomeIconStringForEnum:FAdatabase] forSegmentAtIndex:1];
		[self setTitle:[NSString fontAwesomeIconStringForEnum:FApaperPlane] forSegmentAtIndex:2];
		[self setTitle:[NSString fontAwesomeIconStringForEnum:FAUsd] forSegmentAtIndex:3];
		[self setTitle:[NSString fontAwesomeIconStringForEnum:FAGlobe] forSegmentAtIndex:4];
		[self changeSegment];
	}
}

-(void)gameSegmentChanged {
	int number = (int)self.selectedSegmentIndex;
	if(self.numberOfSegments==2)
		number++;
	if(number==0) {
		[self applyThemeColor];
	} else if(number==1) {
		[self setTintColor:[UIColor colorWithRed:0 green:1 blue:.1 alpha:1]];
	} else {
		[self setTintColor:[UIColor colorWithRed:0 green:1 blue:1 alpha:1]];
	}
	[self turnIntoGameSegment];
}

-(void)changeSegment {
	if(self.selectedSegmentIndex < self.numberOfSegments) {
		NSString *checkMark = [NSString fontAwesomeIconStringForEnum:FACheck];
		for(int i=0; i<self.numberOfSegments; i++) {
			NSString *title = [self titleForSegmentAtIndex:i];
			[self setTitle:[title stringByReplacingOccurrencesOfString:checkMark withString:@""] forSegmentAtIndex:i];
		}
		
		NSString *checkMarkTitle = [NSString stringWithFormat:@"%@%@", checkMark, [self titleForSegmentAtIndex:self.selectedSegmentIndex]];
		[self setTitle:checkMarkTitle forSegmentAtIndex:self.selectedSegmentIndex];
	}
}

@end
