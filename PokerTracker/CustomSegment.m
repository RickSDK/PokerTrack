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

- (void)commonInit
{
//	[self setTintColor:[UIColor colorWithRed:(6/255.0) green:(122/255.0) blue:(180/255.0) alpha:1.0]];
	[self setTintColor:[UIColor colorWithRed:0 green:.5 blue:0 alpha:1.0]];
	
	self.layer.backgroundColor = [UIColor whiteColor].CGColor;
	self.layer.cornerRadius = 7;
	self.layer.masksToBounds = YES;				// clips background images to rounded corners
	self.layer.borderColor = [UIColor blackColor].CGColor;
	self.layer.borderWidth = 1;
	
	UIFont *font = [UIFont fontWithName:kFontAwesomeFamilyName size:14.f];
	NSMutableDictionary *attribsNormal;
	attribsNormal = [NSMutableDictionary dictionaryWithObjectsAndKeys:font, UITextAttributeFont, [UIColor blackColor], UITextAttributeTextColor, nil];
	
	NSMutableDictionary *attribsSelected;
	attribsSelected = [NSMutableDictionary dictionaryWithObjectsAndKeys:font, UITextAttributeFont, [UIColor whiteColor], UITextAttributeTextColor, nil];
	
	[self setTitleTextAttributes:attribsNormal forState:UIControlStateNormal];
	[self setTitleTextAttributes:attribsSelected forState:UIControlStateSelected];
	
	[self changeSegment];
}

-(void)turnIntoTop5Segment {
	if(self.numberOfSegments==3) {
		[self setTitle:[NSString stringWithFormat:@"%@ %@", [NSString fontAwesomeIconStringForEnum:FAStar], NSLocalizedString(@"Game", nil)] forSegmentAtIndex:0];
		[self setTitle:[NSString stringWithFormat:@"%@ %@", [NSString fontAwesomeIconStringForEnum:FACalendar], NSLocalizedString(@"month", nil)] forSegmentAtIndex:1];
		[self setTitle:[NSString stringWithFormat:@"%@ %@", [NSString fontAwesomeIconStringForEnum:FAcalendarCheckO], NSLocalizedString(@"Quarter", nil)] forSegmentAtIndex:2];
	}
}

-(void)turnIntoGameSegment {
	if(self.numberOfSegments==3) {
		[self setTitle:[NSString stringWithFormat:@"%@ + %@", [NSString fontAwesomeIconStringForEnum:FAMoney], [NSString fontAwesomeIconStringForEnum:FATrophy]] forSegmentAtIndex:0];
		[self setTitle:[NSString fontAwesomeIconStringForEnum:FAMoney] forSegmentAtIndex:1];
		[self setTitle:[NSString fontAwesomeIconStringForEnum:FATrophy] forSegmentAtIndex:2];
	}
}

-(void)turnIntoFilterSegment:(NSManagedObjectContext *)context {
	UIFont *font = [UIFont fontWithName:kFontAwesomeFamilyName size:11.f];
	NSMutableDictionary *attribsNormal;
	attribsNormal = [NSMutableDictionary dictionaryWithObjectsAndKeys:font, UITextAttributeFont, [UIColor blackColor], UITextAttributeTextColor, nil];
	
	NSMutableDictionary *attribsSelected;
	attribsSelected = [NSMutableDictionary dictionaryWithObjectsAndKeys:font, UITextAttributeFont, [UIColor whiteColor], UITextAttributeTextColor, nil];
	
	[self setTitleTextAttributes:attribsNormal forState:UIControlStateNormal];
	[self setTitleTextAttributes:attribsSelected forState:UIControlStateSelected];
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
}

-(void)turnIntoTypeSegment {
	if(self.numberOfSegments==5) {
		[self setTitle:[NSString fontAwesomeIconStringForEnum:FAMoney] forSegmentAtIndex:0];
		[self setTitle:[NSString fontAwesomeIconStringForEnum:FAdatabase] forSegmentAtIndex:1];
		[self setTitle:[NSString fontAwesomeIconStringForEnum:FApaperPlane] forSegmentAtIndex:2];
		[self setTitle:[NSString fontAwesomeIconStringForEnum:FAUsd] forSegmentAtIndex:3];
		[self setTitle:[NSString fontAwesomeIconStringForEnum:FAGlobe] forSegmentAtIndex:4];
	}
}

-(void)gameSegmentChanged {
	int number = (int)self.selectedSegmentIndex;
	if(self.numberOfSegments==2)
		number++;
	
	if(number==0)
		[self setTintColor:[UIColor colorWithRed:0 green:.5 blue:0 alpha:1]];
	else if(number==1)
		[self setTintColor:[UIColor colorWithRed:.9 green:.7 blue:0 alpha:1]];
	else
		[self setTintColor:[UIColor colorWithRed:0 green:.7 blue:.9 alpha:1]];
}

-(void)changeSegment {
	return;;
	NSString *checkMark = [NSString stringWithFormat:@"%@ ", @"\u2705"];
	for(int i=0; i<self.numberOfSegments; i++) {
		NSString *title = [self titleForSegmentAtIndex:i];
		[self setTitle:[title stringByReplacingOccurrencesOfString:checkMark withString:@""] forSegmentAtIndex:i];
	}
		
	NSString *checkMarkTitle = [NSString stringWithFormat:@"%@%@", checkMark, [self titleForSegmentAtIndex:self.selectedSegmentIndex]];
	[self setTitle:checkMarkTitle forSegmentAtIndex:self.selectedSegmentIndex];
}

@end
