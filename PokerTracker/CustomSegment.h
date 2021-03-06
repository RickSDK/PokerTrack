//
//  CustomSegment.h
//  WealthTracker
//
//  Created by Rick Medved on 10/29/15.
//  Copyright (c) 2015 Rick Medved. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomSegment : UISegmentedControl

-(void)changeSegment;
-(void)turnIntoTop5Segment;
-(void)turnIntoGameSegment;
-(void)turnIntoFilterSegment:(NSManagedObjectContext *)context;
-(void)turnIntoTypeSegment;
-(void)gameSegmentChanged;
-(void)applyThemeColor;

@end
