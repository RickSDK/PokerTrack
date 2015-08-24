//
//  GrabphLib.m
//  PokerTracker
//
//  Created by Rick Medved on 4/29/13.
//
//

#import "GrabphLib.h"
#import "ProjectFunctions.h"
#import "CoreDataLib.h"
#import "NSString+ATTString.h"
#import "NSDate+ATTDate.h"

@implementation GrabphLib
    
+(void)drawLine:(CGContextRef)c startX:(int)startX startY:(int)startY endX:(int)endX endY:(int)endY
{
	CGContextMoveToPoint(c, startX, startY);
	CGContextAddLineToPoint(c, endX, endY);
	CGContextStrokePath(c);
}

+(void)drawGrid:(CGContextRef)c max:(int)max min:(int)min totalWidth:(int)totalWidth totalHeight:(int)totalHeight {
	int totalRange = max-min;
	int leftEdgeOfChart=45;
	int bottomEdgeOfChart=totalHeight-50;
    
    // draw Box---------------------
    
    CGContextSetLineWidth(c, 1);
	CGContextSetRGBStrokeColor(c, 0, 0, 0, 1); // blank
	CGContextSetRGBFillColor(c, 1, 1, 1, 1); // white
	CGContextFillRect(c, CGRectMake(0, 0, totalWidth, totalHeight));
	CGContextStrokeRect(c, CGRectMake(0, 0, totalWidth, totalHeight));
    
    // draw zero line---------------
	CGContextSetRGBStrokeColor(c, 0.6, 0.2, 0.2, 1); // lightGray
	CGContextSetLineWidth(c, 2);
	//	int zeroLoc = max*yMultiplier-10;
	//	float percentOfScreen = max/(max-min);
//	int zeroLoc = 0;
//	if((max-min)>0)
//		zeroLoc = bottomEdgeOfChart*max/(max-min);
    
    int zeroLoc=[self getYValue:0 max:max min:min];

	if(zeroLoc<bottomEdgeOfChart)
        [self drawLine:c startX:leftEdgeOfChart startY:zeroLoc endX:totalWidth endY:zeroLoc];
	
	// draw left hand labels and grid---------------------
	CGContextSetRGBStrokeColor(c, 0.9, 0.9, 0.9, 1); // lightGray
	CGContextSetRGBFillColor(c, 0.4, 0.4, 0.4, 1); // black
	int YCord=10;
	for(int i=10; i>=0; i--) {
		float multiplyer = (float)totalRange/10;
		int amount = (multiplyer*i+min);
        [self drawLine:c startX:leftEdgeOfChart startY:YCord+7 endX:totalWidth endY:YCord+7];
		NSString *label = [NSString stringWithFormat:@"%d", amount];
		
		if(amount>=0)
			CGContextSetRGBFillColor(c, 0.4, 0.4, 0.4, 1); // gray
		else
			CGContextSetRGBFillColor(c, 0.5, 0.3, 0.3, 1); // red
		
		[label drawAtPoint:CGPointMake(5, YCord) withFont:[UIFont fontWithName:@"Helvetica" size:12]];
		YCord += totalHeight/13;
	}
    
    // draw axis lines
	CGContextSetRGBStrokeColor(c, 0, 0, 0, 1); // black
    [self drawLine:c startX:leftEdgeOfChart startY:0 endX:leftEdgeOfChart endY:bottomEdgeOfChart];
    [self drawLine:c startX:leftEdgeOfChart startY:bottomEdgeOfChart endX:totalWidth endY:bottomEdgeOfChart];
    
}



+(void)displayLegendofPlayers:(NSArray *)players c:(CGContextRef)c totalHeight:(int)totalHeight {
    CGContextSetRGBFillColor(c, .7, 0, 0, 1); //
    [@"Free Throws" drawAtPoint:CGPointMake(100, totalHeight-25) withFont:[UIFont fontWithName:@"Helvetica" size:18]];
    CGContextSetRGBFillColor(c, 0, 0, .7, 1); //
    [@"Three Pointers" drawAtPoint:CGPointMake(300, totalHeight-25) withFont:[UIFont fontWithName:@"Helvetica" size:18]];
}

+(void)displayLegendofDates:(CGContextRef)c totalHeight:(int)totalHeight startDate:(NSDate *)startDate endDate:(NSDate *)endDate {
    CGContextSetRGBFillColor(c, .5, .5, .5, 1); //

    int totalSeconds = [endDate timeIntervalSinceDate:startDate];
    int seconds = totalSeconds*.01;

    for(int i=0; i<=6; i++) {
        NSDate *thisDate = [startDate dateByAddingTimeInterval:seconds];
        NSString *dateStr = [thisDate convertDateToStringWithFormat:@"MM/dd"];
        [dateStr drawAtPoint:CGPointMake(i*70+35, totalHeight-50) withFont:[UIFont fontWithName:@"Helvetica" size:16]];
        seconds+=totalSeconds/6.2;
    }
}


+(int)getYValue:(int)value max:(int)max min:(int)min
{
    int bottomEdgeOfChart=250;
    if(max==0) {
        NSLog(@"Whoa!");
        max=100;
    }
    
    int range=max-min;
    if(range==0) {
        NSLog(@"Whoa!");
        max=100;
        min=0;
        range=max-min;
    }
    value -= min;
    int result = value*bottomEdgeOfChart/range;
    return bottomEdgeOfChart-result;
    
}



+(UIImageView *)graphStatsChart:(NSManagedObjectContext *)mOC data:(NSString *)data type:(int)type
{
    
    int totalWidth=500;
    int totalHeight=300;
    
    NSLog(@"\n\n%@\n\n", data);
    
	UIImageView *dynamicChartImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon.png"]];
    
    UIGraphicsBeginImageContext(CGSizeMake(totalWidth,totalHeight));
	CGContextRef c = UIGraphicsGetCurrentContext();
	UIGraphicsPushContext(c); // <--
	CGContextSetLineCap(c, kCGLineCapRound);

    int max=100;
    int min=0;

//    NSDate *intitDate = [[NSDate date] dateByAddingTimeInterval:-1*60*60*24*90];
    NSDate *startDate = [NSDate date];
    if(type==0)
        startDate = [[NSDate date] dateByAddingTimeInterval:-1*60*60*24*90];
    
    if(type==2)
        startDate = [ProjectFunctions getFirstDayOfMonth:startDate];
    
    NSDate *endDate = [NSDate date];
    
    NSMutableArray *playerNames = [[NSMutableArray alloc] initWithCapacity:10];
    NSArray *players = [data componentsSeparatedByString:@"+"];
    for(NSString *player in players) {
        NSArray *components = [player componentsSeparatedByString:@"<1>"];
        if([components count]>1) {
            [playerNames addObject:[components objectAtIndex:0]];
            NSString *gameStr = [components objectAtIndex:1];
            NSArray *games = [gameStr componentsSeparatedByString:@":"];
            int total=0;
            for(NSString *game in games) {
                NSArray *components = [game componentsSeparatedByString:@"|"];
                if([components count]>1) {
                    int profit = [[components objectAtIndex:1] intValue];
                    total+=profit;
                    if(total>max)
                        max=total;
                    if(total<min)
                        min=total;

                    NSDate *startDt = [[components objectAtIndex:0] convertStringToDateWithFormat:@"MM/dd/yyyy"];
                    if(type==1 && [startDt timeIntervalSinceDate:startDate]<0)
                        startDate=startDt;

                }
            }
        }
    }
    
    int totalSeconds = [endDate timeIntervalSinceDate:startDate];
    if (totalSeconds<1000)
        totalSeconds=1000;
    
	[self drawGrid:c max:max min:min totalWidth:totalWidth totalHeight:totalHeight];
    int origX=45;
    int origY=[self getYValue:0 max:max min:min];
    
    int count=0;
    for(NSString *player in players) {
        int oldX=origX;
        int oldY=origY;
        NSArray *components = [player componentsSeparatedByString:@"<1>"];
        if([components count]>1) {
            count++;
            CGContextSetRGBFillColor(c, 1, 0, 0, 1); //
            CGContextSetRGBStrokeColor(c, 1, 0, 0, 1); //
            
            if(count==1) {
                CGContextSetRGBFillColor(c, .7, 0, 0, 1); //
                CGContextSetRGBStrokeColor(c, .7, 0, 0, 1); //
            }
            if(count==2) {
                CGContextSetRGBFillColor(c, 0, .6, 0, 1); //
                CGContextSetRGBStrokeColor(c, 0, .6, 0, 1); //
            }
            if(count==3) {
                CGContextSetRGBFillColor(c, 0, 0, .7, 1); //
                CGContextSetRGBStrokeColor(c, 0, 0, .7, 1); //
            }
            if(count==4) {
                CGContextSetRGBFillColor(c, .5, .5, 0, 1); //
                CGContextSetRGBStrokeColor(c, .5, .5, 0, 1); //
            }
            if(count==5) {
                CGContextSetRGBFillColor(c, 0, .5, .5, 1); //
                CGContextSetRGBStrokeColor(c, 0, .5, .5, 1); //
            }
            if(count==6) {
                CGContextSetRGBFillColor(c, .5, 0, .5, 1); //
                CGContextSetRGBStrokeColor(c, .5, 0, .5, 1); //
            }
            if(count==7) {
                CGContextSetRGBFillColor(c, .2, .5, .2, 1); //
                CGContextSetRGBStrokeColor(c, .2, .5, .2, 1); //
            }
            if(count==8) {
                CGContextSetRGBFillColor(c, 0, 0, 0, 1); //
                CGContextSetRGBStrokeColor(c, 0, 0, 0, 1); //
            }
            int circleSize=6;
            int circleOffset=circleSize/2;
            int height=totalHeight-35;
            int width = 100*count;
            if(count>4) {
                height+=15;
                width-=450;
            }
            [[components objectAtIndex:0] drawAtPoint:CGPointMake(width, height) withFont:[UIFont fontWithName:@"Helvetica" size:18]];
            NSString *gameStr = [components objectAtIndex:1];
            NSArray *games = [gameStr componentsSeparatedByString:@":"];
            int total=0;
            float modifyer = (float)totalWidth/totalSeconds;
            modifyer*=.92;
            for(NSString *game in games) {
                NSArray *components = [game componentsSeparatedByString:@"|"];
                if([components count]>1) {
                    int profit = [[components objectAtIndex:1] intValue];
                    total+=profit;
                    
                    NSDate *startDt = [[components objectAtIndex:0] convertStringToDateWithFormat:@"MM/dd/yyyy"];
                        
                    int seconds = [startDt timeIntervalSinceDate:startDate];
                    if(seconds>=0) {
                        int newY = [self getYValue:total max:max min:min];
  
                        int newX = 45+(seconds*modifyer);
//                        NSLog(@"+++ %@", game);
                        
                        [self drawLine:c startX:oldX startY:oldY endX:newX endY:newY];
                        CGContextFillEllipseInRect(c, CGRectMake(newX-circleOffset,newY-circleOffset,circleSize,circleSize));
                        oldX=newX;
                        oldY=newY;
                    }
                }
            }
        }
    }


    [self displayLegendofDates:c totalHeight:totalHeight startDate:startDate endDate:endDate];
    
    UIGraphicsPopContext();
	dynamicChartImage.image = UIGraphicsGetImageFromCurrentImageContext();
	
	UIGraphicsEndImageContext();
    
    return dynamicChartImage;
}


@end
