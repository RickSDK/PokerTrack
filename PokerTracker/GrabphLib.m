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

#define kDebugPieChart	0

#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)


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
    
//    NSLog(@"\n\n%@\n\n", data);
    
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

+(int)totalWidth {
	int width = [[UIScreen mainScreen] bounds].size.width*2;
	if (width<640)
		width=640;
	return width;
}

+(GraphObject *)graphObjectWithName:(NSString *)name amount:(double)amout rowId:(int)rowId reverseColorFlg:(BOOL)reverseColorFlg currentMonthFlg:(BOOL)currentMonthFlg {
	GraphObject *obj = [[GraphObject alloc] init];
	obj.name=name;
	obj.amount=amout;
	obj.rowId=rowId;
	obj.reverseColorFlg=reverseColorFlg;
	obj.currentMonthFlg=currentMonthFlg;
	return obj;
}

+(void)drawYellowBGForContext:(CGContextRef)context topLeft:(CGPoint)topLeft botRight:(CGPoint)botRight {
	UIBezierPath *aPath3 = [UIBezierPath bezierPath];
	[aPath3 moveToPoint:CGPointMake(topLeft.x, topLeft.y)];
	[aPath3 addLineToPoint:CGPointMake(botRight.x, topLeft.y)];
	[aPath3 addLineToPoint:CGPointMake(botRight.x, botRight.y)];
	[aPath3 addLineToPoint:CGPointMake(topLeft.x, botRight.y)];
	[aPath3 moveToPoint:CGPointMake(topLeft.x, topLeft.y)];
	[aPath3 closePath];
	[self addGradientToPath:aPath3 context:context color1:[UIColor yellowColor] color2:(UIColor *)[UIColor whiteColor] lineWidth:(int)1 imgWidth:botRight.x-topLeft.x imgHeight:botRight.y-topLeft.y];
}

+(UIImage *)pieChartWithItems:(NSArray *)itemList startDegree:(float)startDegree {
	int valueType=0; // 0=int, 1=float, 2=percent, 3=money
	
	int totalWidth=[self totalWidth];
	int totalHeight=totalWidth/2;
	NSArray *sortedArray = [itemList sortedArrayUsingSelector:@selector(compare:)];
	NSMutableArray *newArray = [[NSMutableArray alloc] init];
	double totalPieSize=0;
	double othersTotal=0;
	int maxItems=12;
	int i=0;
	for (GraphObject *graphObj in sortedArray) {
		totalPieSize += graphObj.amount;
		i++;
		if(i<maxItems)
			[newArray addObject:graphObj];
		else
			othersTotal+=abs(graphObj.amount);
	}
	if(othersTotal>0) {
		GraphObject *othersObj = [[GraphObject alloc] init];
		othersObj.name=@"Others";
		othersObj.amount=othersTotal;
		[newArray addObject:othersObj];
	}
	itemList=newArray;

	if(itemList.count>3) { // sort and stagger
		double min = 0;
		
		NSMutableArray *finalSortedArray = [[NSMutableArray alloc] init]; // sort from smallest to biggest
		for(int i=0; i<itemList.count; i++) {
			min = [self minAmountOfList:itemList min:totalPieSize prevMin:min];
			
			for (GraphObject *graphObj in itemList) {
				if(abs(graphObj.amount)==min)
					[finalSortedArray addObject:graphObj];
			}
		}
		
		NSMutableArray *finalSortedArray2 = [[NSMutableArray alloc] init]; // now stagger
		int i=0;
		BOOL topFlag=YES;
		while (finalSortedArray.count>0) {
			topFlag=!topFlag;
			if(topFlag) {
				[finalSortedArray2 addObject:[finalSortedArray objectAtIndex:0]];
				[finalSortedArray removeObjectAtIndex:0];
			} else {
				[finalSortedArray2 addObject:[finalSortedArray objectAtIndex:finalSortedArray.count-1]];
				[finalSortedArray removeObjectAtIndex:finalSortedArray.count-1];
			}
			i++;
		}
		
		itemList=finalSortedArray2;
	}
	
	CGContextRef c = [self contextRefForGraphofWidth:totalWidth totalHeight:totalHeight];
	
	[self drawYellowBGForContext:c topLeft:CGPointMake(0, 0) botRight:CGPointMake(totalWidth, totalHeight)];
	
	CGPoint center = CGPointMake(totalWidth/2, totalHeight/2);
	
	if(totalPieSize > 0) {
		float startAngle = - M_PI_2;
		CGFloat radius = (totalHeight-50)/2;
		
		float endDegree = 0;
		
		CGPoint startPoint = [self pointFromCenter:center radius:radius degrees:startDegree];
		[self drawCircleAtCenter:CGPointMake(center.x+8, center.y+8) startPoint:startPoint radius:radius color:[UIColor colorWithWhite:.2 alpha:1] context:c];
		
		CGPoint namePoint = CGPointMake(-20, -20); // off screen
		int i=0;
		for (GraphObject *graphObj in itemList) {
			double value = abs(graphObj.amount);
			endDegree = startDegree+value*360/totalPieSize;
			
			CGPoint startPoint = [self pointFromCenter:center radius:radius degrees:startDegree];
			CGPoint midPoint = [self pointFromCenter:center radius:radius/2 degrees:(startDegree+endDegree)/2];
			CGPoint longPoint = [self pointFromCenter:center radius:radius+trunc(totalWidth/24) degrees:(startDegree+endDegree)/2];
			CGPoint linePoint = [self pointFromCenter:center radius:radius+trunc(totalWidth/40) degrees:(startDegree+endDegree)/2];
			
			[self drawWedgeFromCenter:center startPoint:startPoint radius:radius startAngle:startDegree endAngle:endDegree color:[self colorForObject:graphObj.rowId] context:c];
			
			CGContextSetRGBFillColor(c, 0, 0, 0, 1); // text black
			
			int midDegree = (int)(endDegree+startDegree)/2;
			if(midDegree<0)
				midDegree+=360;
			if(midDegree>360)
				midDegree-=360;
			
			namePoint = [self startingPointForString:graphObj.name midDegree:midDegree size:(endDegree-startDegree) midPoint:longPoint prevPoint:namePoint];
			NSString *shortName = [self smartStringForName:graphObj.name max:11];
			float percentage = value*100/totalPieSize;
			[self setTextColorForContext:c color:[self colorForObject:graphObj.rowId] darkFlg:YES];
			
			if(kDebugPieChart)
				NSLog(@"+++%@: Wedge from %d to %d (of 360)", graphObj.name, (int)startDegree, (int)endDegree);
			
			NSString *percentStr = [NSString stringWithFormat:@"%.1f%%", percentage];
			if(valueType==0)
				percentStr = [NSString stringWithFormat:@"%d", (int)value];
			if(valueType==3)
				percentStr = [ProjectFunctions convertNumberToMoneyString:value];
			
			if(percentage>25) { // place label inside
				[self centerTextAtPoint:midPoint name:shortName percentStr:percentStr color:[self colorForObject:graphObj.rowId] context:c rowId:graphObj.rowId];
			} else {
				NSString *name = [NSString stringWithFormat:@"%@ %@", shortName, percentStr];
				[name drawAtPoint:CGPointMake(namePoint.x, namePoint.y) withFont:[UIFont boldSystemFontOfSize:trunc(totalWidth/29.09)]];
			}
			
			if(percentage<2) {
				[self drawLine:c startPoint:midPoint endPoint:linePoint];
			}
			
			if(kDebugPieChart) {
				[self drawGraphCircleForContext:c x:midPoint.x y:midPoint.y recordConfirmed:NO recExists:YES];
				[self drawGraphCircleForContext:c x:longPoint.x y:longPoint.y recordConfirmed:YES recExists:YES];
			}
			startAngle += M_PI*2*value/totalPieSize;
			startDegree=endDegree;
			i++;
		}
	}
	UIGraphicsPopContext();
	UIImage *dynamicChartImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return dynamicChartImage;
}

+(double)minAmountOfList:(NSArray *)list min:(double)min prevMin:(double)prevMin {
	for(GraphObject *graphObject in list) {
		double amount = abs(graphObject.amount);
		if(amount>prevMin && amount<min)
			min=amount;
	}
	return min;
}

+(void)centerTextAtPoint:(CGPoint)midPoint name:(NSString *)name percentStr:(NSString *)percentStr color:(UIColor *)color context:(CGContextRef)context rowId:(int)rowId {
	
	int totalWidth = [self totalWidth];
	int letterSpacing = trunc(totalWidth/80);
	int lineSpacing = trunc(totalWidth/25.6);
	int nameHalfLength = (int)((name.length+3)*letterSpacing/2);
	int percentHalfLength = (int)((percentStr.length+3)*letterSpacing/2);
	
	if(rowId%2==0)
		CGContextSetRGBFillColor(context, 0, 0, 0, 1); // text black
	else
		CGContextSetRGBFillColor(context, 1, 1, 1, 1); // text white
	
	[name drawAtPoint:CGPointMake(midPoint.x-nameHalfLength, midPoint.y-(lineSpacing)) withFont:[UIFont boldSystemFontOfSize:trunc(totalWidth/29.09)]];
	[percentStr drawAtPoint:CGPointMake(midPoint.x-percentHalfLength, midPoint.y) withFont:[UIFont boldSystemFontOfSize:trunc(totalWidth/29.09)]];
	
	if(rowId%2==0)
		CGContextSetRGBFillColor(context, 1, 1, 1, 1); // text white
	else
		[self setDarkTextColorForContext:context color:color];
	
	[name drawAtPoint:CGPointMake(midPoint.x+1-nameHalfLength, midPoint.y+1-(lineSpacing)) withFont:[UIFont boldSystemFontOfSize:trunc(totalWidth/29.09)]];
	[percentStr drawAtPoint:CGPointMake(midPoint.x+1-percentHalfLength, midPoint.y+1) withFont:[UIFont boldSystemFontOfSize:trunc(totalWidth/29.09)]];
	
}

+(void)setDarkTextColorForContext:(CGContextRef)context color:(UIColor *)color {
	CGFloat red = 0.0, green = 0.0, blue = 0.0, alpha =0.0;
	[color getRed:&red green:&green blue:&blue alpha:&alpha];
	red/=2;
	green/=2;
	blue/=2;
	CGContextSetRGBFillColor(context, red, green, blue, alpha); // text black
}

+(void)setTextColorForContext:(CGContextRef)context color:(UIColor *)color darkFlg:(BOOL)darkFlg {
	CGFloat red = 0.0, green = 0.0, blue = 0.0, alpha =0.0;
	[color getRed:&red green:&green blue:&blue alpha:&alpha];
	if(darkFlg && ((red+green+blue)>1.5 || green==1)) {
		red/=2;
		green/=2;
		blue/=2;
	}
	CGContextSetRGBFillColor(context, red, green, blue, alpha); // text black
}

+(CGPoint)startingPointForString:(NSString *)name midDegree:(int)midDegree size:(int)size midPoint:(CGPoint)midPoint prevPoint:(CGPoint)prevPoint {
	int totalWidth = [self totalWidth];
	int letterSpacing = trunc(totalWidth/60);
	int lineSpacing = trunc(totalWidth/36);
	
	int x=midPoint.x-(letterSpacing/2);
	int y=midPoint.y-lineSpacing/2;
	
	if(kDebugPieChart)
		NSLog(@"%@ xyStart=(%d, %d) midDegree=[%d]", name, x, y, midDegree);
	
	BOOL leftSideFlg=NO;
	if(midDegree>90 && midDegree<270)
		leftSideFlg=YES;
	
	if(leftSideFlg)
		x-=name.length*letterSpacing+letterSpacing*6;
	
	if(abs(y-prevPoint.y)<lineSpacing && abs(x-prevPoint.x)<100) {
		if(kDebugPieChart)
			NSLog(@"Prev Y: %f", prevPoint.y);
		
		if(midDegree>90 && midDegree<270)
			y=prevPoint.y-lineSpacing; // move up
		else
			y=prevPoint.y+lineSpacing; // move down
		
		if(midDegree>270)
			x+=letterSpacing;
	}
	
	int botMax = trunc(totalWidth/2.21);
	if(y>botMax) { // It's too Low!
		y=botMax;
		if(leftSideFlg)
			x-=letterSpacing;
		else
			x+=letterSpacing;
		
		if(midDegree>=85 && midDegree<=95) { // right at bottom
			if(leftSideFlg)
				x-=letterSpacing*4;
			else
				x+=letterSpacing*4;
		}
	}
	
	if(x<4) // keep it in the screen
		x=4;
	
	if(y<0) // keep it in the screen
		y=0;
	
	if(kDebugPieChart)
		NSLog(@"%@ xyEnd=(%d, %d) midDegree=[%d]", name, x, y, midDegree);
	
	return CGPointMake(x, y);
}

+(CGPoint)pointFromCenter:(CGPoint)center radius:(float)radius degrees:(float)degrees {
	float x_oncircle = center.x + radius * cos (degrees * M_PI / 180);
	float y_oncircle = center.y + radius * sin (degrees * M_PI / 180);
	return CGPointMake(x_oncircle, y_oncircle);
}

+(UIColor *)colorForObject:(int)number {
	if(number==99)
		return [UIColor colorWithRed:(6/255.0) green:(122/255.0) blue:(180/255.0) alpha:1.0];
	if(number==100)
		return [UIColor colorWithRed:237/255.0 green:243/255.0 blue:254/255.0 alpha:1.0];
	if(number==101)
		return [UIColor colorWithRed:(182/255.0) green:(191/255.0) blue:(0/255.0) alpha:1.0];
	
	NSArray *colors=[NSArray arrayWithObjects:
					 [UIColor colorWithRed:0 green:.5 blue:0 alpha:1], // green
					 [UIColor colorWithRed:1 green:.8 blue:0 alpha:1], // Gold
					 [UIColor redColor],
					 [UIColor greenColor],
					 [UIColor blueColor],
					 [UIColor cyanColor],
					 [UIColor magentaColor],
					 [UIColor orangeColor],
					 [UIColor purpleColor],
					 [UIColor whiteColor],
					 [UIColor grayColor],
					 [UIColor colorWithRed:1 green:1 blue:.5 alpha:1],
					 [UIColor colorWithRed:.5 green:0 blue:0 alpha:1],
					 [UIColor colorWithRed:1 green:.5 blue:1 alpha:1],
					 nil];
	return [colors objectAtIndex:number%colors.count];
}

+(void) drawCircleAtCenter:(CGPoint)center startPoint:(CGPoint)startPoint radius:(float)radius color:(UIColor *)color context:(CGContextRef)context
{
	UIBezierPath * aPath = [UIBezierPath bezierPath];
	[aPath moveToPoint:startPoint];
	[aPath addArcWithCenter:center radius:radius startAngle:DEGREES_TO_RADIANS(0) endAngle:DEGREES_TO_RADIANS(360) clockwise:YES];
	[aPath closePath];
	
	aPath.lineWidth = 0;
	[aPath stroke];
	[self addGradientToWedgePath:aPath context:context color1:color lineWidth:0 imgWidth:[self totalWidth] imgHeight:[self totalWidth]/2];
}


+(void) drawWedgeFromCenter:(CGPoint)center startPoint:(CGPoint)startPoint radius:(float)radius startAngle:(float)startAngle endAngle:(float)endAngle color:(UIColor *)color context:(CGContextRef)context
{
	UIBezierPath * aPath = [UIBezierPath bezierPath];
	[aPath moveToPoint:center];
	[aPath addLineToPoint:startPoint];
	[aPath addArcWithCenter:center radius:radius startAngle:DEGREES_TO_RADIANS(startAngle) endAngle:DEGREES_TO_RADIANS(endAngle) clockwise:YES];
	[aPath closePath];
	
	aPath.lineWidth = 0;
	[aPath stroke];
	[self addGradientToWedgePath:aPath context:context color1:color lineWidth:1 imgWidth:[self totalWidth] imgHeight:[self totalWidth]/2];
}

+(void)addGradientToWedgePath:(UIBezierPath *)aPath
					  context:(CGContextRef)context
					   color1:(UIColor *)color1
					lineWidth:(int)lineWidth
					 imgWidth:(int)width
					imgHeight:(int)height
{
	width=[self totalWidth];
	height=width/2;
	
	CGFloat red1 = 0.0, green1 = 0.0, blue1 = 0.0, alpha1 =0.0;
	[color1 getRed:&red1 green:&green1 blue:&blue1 alpha:&alpha1];
	
	CGFloat red2 = red1+.5, green2 = green1+.5, blue2 = blue1+.5, alpha2 =alpha1;
	
	CGColorSpaceRef myColorspace=CGColorSpaceCreateDeviceRGB();
	size_t num_locations = 2;
	CGFloat locations[2] = { 1.0, 0.0 };
	CGFloat components[8] =	{ red2, green2, blue2, alpha2,    red1, green1, blue1, alpha1};
	
	CGGradientRef myGradient = CGGradientCreateWithColorComponents(myColorspace, components, locations, num_locations);
	
	CGContextSaveGState(context);
	[aPath addClip];
	CGContextDrawLinearGradient(context, myGradient, CGPointMake(0, 0), CGPointMake(width, height), 0);
	CGContextRestoreGState(context);
	
	[[UIColor blackColor] setStroke];
	aPath.lineWidth = lineWidth;
	[aPath stroke];
	
	CGGradientRelease(myGradient);
}


+(UIImage *)graphBarsWithItems:(NSArray *)itemList {
	
	int totalWidth=[self totalWidth];
	int totalHeight=totalWidth/2;
	int leftEdgeOfChart=totalWidth/12.8;
	int bottomEdgeOfChart=totalHeight-(totalWidth/25.6);
	
	int maxItems=12;
	if(itemList.count>maxItems) {
		NSMutableArray *newArray = [[NSMutableArray alloc] init];
		int i=0;
		double othersTotal=0;
		for (GraphObject *graphObj in itemList) {
			i++;
			if(i<maxItems)
				[newArray addObject:graphObj];
			else
				othersTotal+=graphObj.amount;
		}
		GraphObject *othersObj = [[GraphObject alloc] init];
		othersObj.name=@"Others";
		othersObj.amount=othersTotal;
		[newArray addObject:othersObj];
		itemList=newArray;
	}
	
	double min=0;
	double max=0;
	for (GraphObject *graphObj in itemList) {
		if(graphObj.amount > max)
			max=graphObj.amount;
		if(graphObj.amount < min)
			min=graphObj.amount;
	}
	
	max*=1.1;
	min*=1.05;
	if(max==0)
		max=min*-.1;
	
	if(min==0)
		min=max*-.06;
	int totalMoneyRange = max-min;
	
	float yMultiplier = 1;
	if(totalMoneyRange>0)
		yMultiplier = (float)bottomEdgeOfChart/totalMoneyRange;
	
	CGContextRef c = [self contextRefForGraphofWidth:totalWidth totalHeight:totalHeight];
	int zeroLoc = [self drawZeroLineForContext:c min:min max:max bottomEdgeOfChart:bottomEdgeOfChart leftEdgeOfChart:leftEdgeOfChart totalWidth:totalWidth];
	
	[self drawLeftLabelsAndLinesForContext:c totalMoneyRange:(max-min) min:min leftEdgeOfChart:leftEdgeOfChart totalHeight:totalHeight totalWidth:totalWidth numOnlyFlg:NO];
	
	[self drawBottomLabelsForArray:itemList c:c bottomEdgeOfChart:bottomEdgeOfChart leftEdgeOfChart:leftEdgeOfChart totalWidth:totalWidth];
	
	[self drawBarChartForContext:c itemArray:itemList leftEdgeOfChart:leftEdgeOfChart mainGoal:0 zeroLoc:zeroLoc yMultiplier:yMultiplier totalWidth:totalWidth];
	
	UIGraphicsPopContext();
	UIImage *dynamicChartImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return dynamicChartImage;
}

+(CGContextRef)contextRefForGraphofWidth:(int)totalWidth totalHeight:(int)totalHeight
{
	UIGraphicsBeginImageContext(CGSizeMake(totalWidth,totalHeight));
	CGContextRef c = UIGraphicsGetCurrentContext();
	UIGraphicsPushContext(c); // <--
	CGContextSetLineCap(c, kCGLineCapRound);
	
	// draw Box---------------------
	CGContextSetLineWidth(c, 0);
	CGContextSetRGBStrokeColor(c, 0, 0, 0, 1); // black
	CGContextSetRGBFillColor(c, 1, 1, 1, 1); // white
	CGContextFillRect(c, CGRectMake(0, 0, totalWidth, totalHeight));
	CGContextStrokeRect(c, CGRectMake(0, 0, totalWidth, totalHeight));
	
	return c;
}

+(int)drawZeroLineForContext:(CGContextRef)c min:(float)min max:(float)max bottomEdgeOfChart:(int)bottomEdgeOfChart leftEdgeOfChart:(int)leftEdgeOfChart totalWidth:(int)totalWidth
{
	
	[self drawYellowBGForContext:c topLeft:CGPointMake(leftEdgeOfChart, 0) botRight:CGPointMake(totalWidth, bottomEdgeOfChart)];
	// draw zero line---------------
	CGContextSetRGBStrokeColor(c, 0.6, 0, 0, 1); // red
	CGContextSetLineWidth(c, 4);
	int zeroLoc = 0;
	if((max-min)>0)
		zeroLoc = bottomEdgeOfChart*max/(max-min);
	if(zeroLoc<bottomEdgeOfChart)
		[self drawLine:c startX:leftEdgeOfChart startY:zeroLoc endX:totalWidth endY:zeroLoc];
	
	// Draw horizontal and vertical baselines
	CGContextSetRGBStrokeColor(c, 0, 0, 0, 1); // black
	[self drawLine:c startX:leftEdgeOfChart startY:bottomEdgeOfChart endX:totalWidth endY:bottomEdgeOfChart];
	[self drawLine:c startX:leftEdgeOfChart startY:0 endX:leftEdgeOfChart endY:bottomEdgeOfChart];
	
	CGContextSetLineWidth(c, 1);
	
	return zeroLoc;
}

+(void)drawLeftLabelsAndLinesForContext:(CGContextRef)c totalMoneyRange:(float)totalMoneyRange min:(double)min leftEdgeOfChart:(int)leftEdgeOfChart totalHeight:(int)totalHeight totalWidth:(int)totalWidth numOnlyFlg:(BOOL)numOnlyFlg
{
	//------ draw left hand labels and grid---------------------
	int distance = trunc(totalWidth/80);
	int YCord=-distance;
	for(int i=11; i>=0; i--) {
		float multiplyer = (float)totalMoneyRange/11;
		float money = (multiplyer*i+min);
		
		NSString *label = (numOnlyFlg)?[NSString stringWithFormat:@"%d", (int)money]:[self smallLabelForMoney:money totalMoneyRange:totalMoneyRange];
		
		if(money>=0)
			CGContextSetRGBFillColor(c, 0.0, 0.3, 0.0, 1); // text green
		else
			CGContextSetRGBFillColor(c, .8, 0, 0, 1); // text red
		
		if(i<11) {
			[label drawAtPoint:CGPointMake(6, YCord) withFont:[UIFont fontWithName:@"Helvetica" size:trunc(totalWidth/42.67)]];
			CGContextSetRGBFillColor(c, 0.9, 0.9, 0.9, 1); // text light gray
			CGContextSetRGBStrokeColor(c, 0.9, 0.9, 0.9, 1); // line color - lightGray
			[self drawLine:c startX:leftEdgeOfChart+1 startY:YCord+distance endX:totalWidth endY:YCord+distance];
		}
		YCord += totalHeight/12;
	}
	
}

+(void)drawBottomLabelsForArray:(NSArray *)labels c:(CGContextRef)c bottomEdgeOfChart:(int)bottomEdgeOfChart leftEdgeOfChart:(int)leftEdgeOfChart totalWidth:(int)totalWidth
{
	int spacing = totalWidth/(labels.count+1);
	int XCord = leftEdgeOfChart+spacing/2-10;
	CGContextSetRGBFillColor(c, 0, 0, 0, 1); // black
	
	int lenMax = 15-(int)labels.count;
	if(lenMax<1)
		lenMax=1;
	
	for(GraphObject *graphObject in labels) {
		NSString *labelStr = graphObject.name;
		if(labelStr.length > lenMax)
			labelStr = [self smartStringForName:graphObject.name max:lenMax];
		
		[labelStr drawAtPoint:CGPointMake(XCord+spacing/10, bottomEdgeOfChart+2) withFont:[UIFont fontWithName:@"Helvetica" size:trunc(totalWidth/35.55)]];
		XCord+=spacing;
	}
}

+(NSString *)smartStringForName:(NSString *)name max:(int)max {
	/*
	 if(name.length<=max)
		return name;
	 
	 NSArray *words = [name componentsSeparatedByString:@" "];
	 NSMutableArray *newWords = [[NSMutableArray alloc] init];
	 if(words.count>1) {
		int wordLen = max/words.count;
		for(NSString *word in words) {
	 NSString *newWord=word;
	 if(word.length>wordLen)
	 newWord=[word substringToIndex:wordLen];
	 [newWords addObject:newWord];
		}
		name = [newWords componentsJoinedByString:@" "];
		
	 }
	 */
	name = [name stringByReplacingOccurrencesOfString:@" " withString:@"_"];
	if(name.length<=max)
		return name;
	else
		return [name substringToIndex:max];
}

+(void)drawBottomLabelsForArray2:(NSArray *)labels c:(CGContextRef)c bottomEdgeOfChart:(int)bottomEdgeOfChart leftEdgeOfChart:(int)leftEdgeOfChart totalWidth:(int)totalWidth
{
	if(labels.count==0)
		return;
	
	int spacing = (totalWidth-10)/(labels.count);
	int XCord = leftEdgeOfChart-15;
	CGContextSetRGBFillColor(c, 0, 0, 0, 1); // black
	
	int lenMax = 14-(int)labels.count;
	if(lenMax<3)
		lenMax=3;
	
	for(GraphObject *graphObject in labels) {
		NSString *labelStr = graphObject.name;
		if(labelStr.length > lenMax)
			labelStr = [self smartStringForName:graphObject.name max:lenMax];
		
		[labelStr drawAtPoint:CGPointMake(XCord+spacing/10, bottomEdgeOfChart-2) withFont:[UIFont fontWithName:@"Helvetica" size:trunc(totalWidth/35.55)]];
		XCord+=spacing;
	}
}

+(UIColor *)darkColor {
	return [UIColor colorWithRed:(12/255.0) green:(37/255.0) blue:(119/255.0) alpha:1.0];
}

+(UIColor *)mediumkColor {
	return [UIColor colorWithRed:(6/255.0) green:(122/255.0) blue:(180/255.0) alpha:1.0];
}

+(UIColor *)lightColor {
	return [UIColor colorWithRed:(58/255.0) green:(165/255.0) blue:(220/255.0) alpha:1.0];
}


+(void)drawBarChartForContext:(CGContextRef)c itemArray:(NSArray *)itemArray leftEdgeOfChart:(int)leftEdgeOfChart mainGoal:(int)mainGoal zeroLoc:(int)zeroLoc yMultiplier:(float)yMultiplier totalWidth:(int)totalWidth
{
	int spacing = totalWidth/(itemArray.count+1);
	int XCord = leftEdgeOfChart+spacing/2-10;
	for(GraphObject *graphObject in itemArray) {
		double value = graphObject.amount;
		
		BOOL showGreen = value>=0;
		if(graphObject.reverseColorFlg)
			showGreen=!showGreen;
		
		UIColor *mainColor = (showGreen)?[UIColor colorWithRed:0 green:.8 blue:0 alpha:1]:[UIColor colorWithRed:1 green:0 blue:0 alpha:1];
		UIColor *topColor = (showGreen)?[UIColor colorWithRed:0 green:.5 blue:0 alpha:1]:[UIColor colorWithRed:.5 green:0 blue:0 alpha:1];
		UIColor *sideColor = (showGreen)?[UIColor colorWithRed:.7 green:1 blue:.7 alpha:1]:[UIColor colorWithRed:1 green:.8 blue:.8 alpha:1];
		if(graphObject.currentMonthFlg) {
			mainColor = [self mediumkColor];
			topColor = [self darkColor];
			sideColor = [self lightColor];
		}
		
		int top = zeroLoc-value*yMultiplier;
		int bot = zeroLoc;
		if(value<0) {
			bot = top;
			top = zeroLoc;
		}
		
		if(value != 0) {
			int width=(totalWidth/(itemArray.count+2))-10;
			UIBezierPath *aPath = [UIBezierPath bezierPath];
			[aPath moveToPoint:CGPointMake(XCord, bot)];
			[aPath addLineToPoint:CGPointMake(XCord, top)];
			[aPath addLineToPoint:CGPointMake(XCord+width, top)];
			[aPath addLineToPoint:CGPointMake(XCord+width, bot)];
			[aPath addLineToPoint:CGPointMake(XCord, bot)];
			[aPath closePath];
			[self addGradientToPath:aPath context:c color1:[UIColor whiteColor] color2:(UIColor *)mainColor lineWidth:(int)1 imgWidth:XCord+width imgHeight:300];
			
			UIBezierPath *aPath2 = [UIBezierPath bezierPath];
			[aPath2 moveToPoint:CGPointMake(XCord, top)];
			[aPath2 addLineToPoint:CGPointMake(XCord+10, top-10)];
			[aPath2 addLineToPoint:CGPointMake(XCord+10+width, top-10)];
			[aPath2 addLineToPoint:CGPointMake(XCord+width, top)];
			[aPath2 addLineToPoint:CGPointMake(XCord, top)];
			[aPath2 closePath];
			[self addGradientToPath:aPath2 context:c color1:[UIColor whiteColor] color2:(UIColor *)topColor lineWidth:(int)1 imgWidth:XCord+width imgHeight:300];
			
			UIBezierPath *aPath3 = [UIBezierPath bezierPath];
			[aPath3 moveToPoint:CGPointMake(XCord+width, top)];
			[aPath3 addLineToPoint:CGPointMake(XCord+width+10, top-10)];
			[aPath3 addLineToPoint:CGPointMake(XCord+10+width, bot-10)];
			[aPath3 addLineToPoint:CGPointMake(XCord+width, bot)];
			[aPath3 addLineToPoint:CGPointMake(XCord+width, bot)];
			[aPath3 closePath];
			[self addGradientToPath:aPath3 context:c color1:[UIColor whiteColor] color2:(UIColor *)sideColor lineWidth:(int)1 imgWidth:XCord+width imgHeight:300];
			
		}
		XCord+=spacing;
	}
}







+(UIImage *)plotItemChart:(NSManagedObjectContext *)mOC type:(int)type displayYear:(int)displayYear item_id:(int)item_id displayMonth:(int)displayMonth startMonth:(int)startMonth startYear:(int)startYear numYears:(int)numYears
{
	int totalWidth=[self totalWidth];
	int totalHeight=totalWidth/2;
	int leftEdgeOfChart=totalWidth/12.8;
	int bottomEdgeOfChart=totalHeight-(totalWidth/25.6);
	
	int nowYear = [[[NSDate date] convertDateToStringWithFormat:@"yyyy"] intValue];
	int nowMonth = [[[NSDate date] convertDateToStringWithFormat:@"MM"] intValue];
	
	//Find min and max---------
	float min=999999;
	float max=0;
	
	int predYear=startYear-numYears;
	int month=startMonth;
	
	NSMutableArray *assetArray = [[NSMutableArray alloc] init];
	NSMutableArray *balanceArray = [[NSMutableArray alloc] init];
	BOOL networthPositive=YES;
	for(int i=1; i<=numYears*12; i++) {
		month++;
		if(month>12) {
			month=1;
			predYear++;
		}
		NSPredicate *predicate = [self predicateForMonth:month year:predYear item_id:item_id type:type];
		NSArray *items = [CoreDataLib selectRowsFromEntity:@"VALUE_UPDATE" predicate:predicate sortColumn:nil mOC:mOC ascendingFlg:YES];
		double asset_value=0;
		double balance_owed=0;
		double interest=0;
		for(NSManagedObject *mo in items) {
			asset_value += [[mo valueForKey:@"asset_value"] doubleValue];
			balance_owed += [[mo valueForKey:@"balance_owed"] doubleValue];
			interest += [[mo valueForKey:@"interest"] doubleValue];
		}
		if(month==displayMonth)
			networthPositive = (asset_value>=balance_owed);
		
		if(type==99 || type==5) {
			asset_value=interest;
			balance_owed=interest;
		}
		
		[assetArray addObject:[NSString stringWithFormat:@"%f", asset_value]];
		[balanceArray addObject:[NSString stringWithFormat:@"%f", balance_owed]];
		
		if(asset_value<min)
			min=asset_value;
		if(balance_owed<min)
			min=balance_owed;
		
		if(asset_value>max)
			max=asset_value;
		if(balance_owed>max)
			max=balance_owed;
	}
	
	max*=1.1; //Put graphs more in the middle
	min/=2;
	
	float totalMoneyRange=max-min;
	float yMultiplier = 1;
	if(totalMoneyRange>0)
		yMultiplier = (float)bottomEdgeOfChart/totalMoneyRange;
	
	
	UIGraphicsBeginImageContext(CGSizeMake(totalWidth,totalHeight));
	CGContextRef c = UIGraphicsGetCurrentContext();
	UIGraphicsPushContext(c); // <--
	CGContextSetLineCap(c, kCGLineCapRound);
	
	// draw Box---------------------
	CGContextSetLineWidth(c, 1);
	CGContextSetRGBStrokeColor(c, 0, 0, 0, 1); // black
	CGContextSetRGBFillColor(c, 1, 1, 1, 1); // white
	CGContextFillRect(c, CGRectMake(0, 0, totalWidth, totalHeight));
	CGContextStrokeRect(c, CGRectMake(0, 0, totalWidth, totalHeight));
	
	[self drawYellowBGForContext:c topLeft:CGPointMake(leftEdgeOfChart, 0) botRight:CGPointMake(totalWidth, bottomEdgeOfChart)];
	
	
	//First do the gradients
	float xCord = leftEdgeOfChart;
	UIBezierPath *aPath = [UIBezierPath bezierPath];
	[aPath moveToPoint:CGPointMake(leftEdgeOfChart, bottomEdgeOfChart)];
	UIBezierPath *aPath2 = [UIBezierPath bezierPath];
	[aPath2 moveToPoint:CGPointMake(leftEdgeOfChart, bottomEdgeOfChart)];
	int plotY=0;
	int plotY2=0;
	for(int i=0; i<numYears*12; i++) {
		double asset_value = [[assetArray objectAtIndex:i] doubleValue];
		double balance_owed = [[balanceArray objectAtIndex:i] doubleValue];
		
		int plotX = xCord;
		plotY = bottomEdgeOfChart-(asset_value-min)*yMultiplier;
		plotY2 = bottomEdgeOfChart-(balance_owed-min)*yMultiplier;
		[aPath addLineToPoint:CGPointMake(plotX, plotY)];
		[aPath2 addLineToPoint:CGPointMake(plotX, plotY2)];
		xCord+=totalWidth/(numYears*12);
	}
	
	[aPath addLineToPoint:CGPointMake(totalWidth, plotY)];
	[aPath addLineToPoint:CGPointMake(totalWidth, bottomEdgeOfChart)];
	[aPath addLineToPoint:CGPointMake(leftEdgeOfChart, bottomEdgeOfChart)];
	[aPath closePath];
	
	[aPath2 addLineToPoint:CGPointMake(totalWidth, plotY2)];
	[aPath2 addLineToPoint:CGPointMake(totalWidth, bottomEdgeOfChart)];
	[aPath2 addLineToPoint:CGPointMake(leftEdgeOfChart, bottomEdgeOfChart)];
	[aPath2 closePath];
	UIColor *mainColor = [UIColor greenColor];
	UIColor *secondColor = [UIColor redColor];
	if(type==99 || type==5)
		secondColor = [UIColor blackColor];
	
	if(networthPositive) {
		[self addGradientToPath:aPath context:c color1:[UIColor whiteColor] color2:(UIColor *)mainColor lineWidth:(int)0 imgWidth:totalWidth imgHeight:totalHeight];
		[self addGradientToPath:aPath2 context:c color1:[UIColor whiteColor] color2:(UIColor *)secondColor lineWidth:(int)0 imgWidth:totalWidth imgHeight:totalHeight];
	} else {
		[self addGradientToPath:aPath2 context:c color1:[UIColor whiteColor] color2:(UIColor *)secondColor lineWidth:(int)0 imgWidth:totalWidth imgHeight:totalHeight];
		[self addGradientToPath:aPath context:c color1:[UIColor whiteColor] color2:(UIColor *)[UIColor greenColor] lineWidth:(int)0 imgWidth:totalWidth imgHeight:totalHeight];
	}
	
	// draw bottom labels ---------------------
	CGContextSetRGBFillColor(c, 0.4, 0.4, 0.4, 1); // gray
	xCord = leftEdgeOfChart-10;
	NSArray *months = [NSArray arrayWithObjects:@"Jan", @"Feb", @"Mar", @"Apr", @"May", @"Jun", @"Jul", @"Aug", @"Sep", @"Oct", @"Nov", @"Dec", nil];
	month = startMonth;
	for(int i=1; i<=(numYears*12); i++) {
		month++;
		if(month>12)
			month=1;
		[[months objectAtIndex:month-1] drawAtPoint:CGPointMake(xCord, bottomEdgeOfChart) withFont:[UIFont fontWithName:@"Helvetica" size:trunc(totalWidth/42.67)]];
		xCord+=totalWidth/(numYears*12);
	}
	
	// draw left hand labels and grid---------------------
	int YCord=-8;
	for(int i=11; i>=0; i--) {
		CGContextSetRGBStrokeColor(c, 0.9, 0.9, 0.9, 1); // lightGray <--- this one does lines
		float multiplyer = (float)totalMoneyRange/11;
		float money = (multiplyer*i+min);
		
		NSString *label = [self smallLabelForMoney:money totalMoneyRange:totalMoneyRange];
		
		if(money>=0)
			CGContextSetRGBFillColor(c, 0, 0, 0, 1); // black // <--- this one does letters
		else
			CGContextSetRGBFillColor(c, 0.5, 0.3, 0.3, 1); // red // <--- this one does letters
		
		if(i<11) {
			[self drawLine:c startX:leftEdgeOfChart startY:YCord+7 endX:totalWidth endY:YCord+7];
			[label drawAtPoint:CGPointMake(10, YCord) withFont:[UIFont fontWithName:@"Helvetica" size:trunc(totalWidth/45.71)]];
		}
		YCord += totalHeight/12;
	}
	
	
	// draw zero line---------------
	CGContextSetRGBStrokeColor(c, 0.6, 0.2, 0.2, 1); // red
	CGContextSetLineWidth(c, 2);
	int zeroLoc = 0;
	
	float percentUp = 0;
	if(totalMoneyRange>0)
		percentUp = (float)(0 - min) / totalMoneyRange;
	
	zeroLoc = bottomEdgeOfChart - ((float)bottomEdgeOfChart*percentUp);
	if(zeroLoc <= bottomEdgeOfChart && zeroLoc >= 0)
		[self drawLine:c startX:leftEdgeOfChart startY:zeroLoc endX:totalWidth endY:zeroLoc];
	
	
	// Draw horizontal and vertical baselines
	CGContextSetRGBStrokeColor(c, 0, 0, 0, 1); // black
	[self drawLine:c startX:leftEdgeOfChart startY:bottomEdgeOfChart endX:totalWidth endY:bottomEdgeOfChart];
	[self drawLine:c startX:leftEdgeOfChart startY:0 endX:leftEdgeOfChart endY:bottomEdgeOfChart];
	
	
	// Draw box outline again
	CGContextSetRGBStrokeColor(c, 0, 0, 0, 1); // black
	CGContextStrokeRect(c, CGRectMake(0, 0, totalWidth, totalHeight));
	
	
	// Graph the Chart---------------------
	
	int oldX=0;
	int oldY=0;
	int oldY2=0;
	
	int todayX=0;
	int todayY=0;
	NSString *todayAmount=nil;
	
	int todayY2=0;
	NSString *todayAmount2=nil;
	
	
	CGContextSetRGBFillColor(c, 0.4, 0.4, 0.4, 1); // gray
	xCord = leftEdgeOfChart;
	BOOL firstRecord = YES;
	BOOL oldRecordConfirmed=NO;
	BOOL oldRecordConfirmed2=NO;
	BOOL isTodayFlg=NO;
	
	predYear=startYear-numYears;
	month=startMonth;
	for(int i=1; i<=(numYears*12); i++) {
		month++;
		if(month>12) {
			month=1;
			predYear++;
		}
		NSPredicate *predicate = [self predicateForMonth:month year:predYear item_id:item_id type:type];
		NSArray *items = [CoreDataLib selectRowsFromEntity:@"VALUE_UPDATE" predicate:predicate sortColumn:nil mOC:mOC ascendingFlg:YES];
		float asset_value=0;
		float balance_owed=0;
		float interest=0;
		BOOL bal_confirm_flg=NO;
		BOOL val_confirm_flg=NO;
		BOOL recordConfirmed=NO;
		BOOL recordConfirmed2=NO;
		BOOL recordExists=NO;
		BOOL recExists = (predYear<nowYear || (predYear==nowYear && month<=nowMonth+1));
		for(NSManagedObject *mo in items) {
			asset_value += [[mo valueForKey:@"asset_value"] floatValue];
			balance_owed += [[mo valueForKey:@"balance_owed"] floatValue];
			interest += [[mo valueForKey:@"interest"] floatValue];
			
			bal_confirm_flg = [[mo valueForKey:@"bal_confirm_flg"] boolValue];
			val_confirm_flg = [[mo valueForKey:@"val_confirm_flg"] boolValue];
			if(val_confirm_flg)
				recordConfirmed=YES;
			if(bal_confirm_flg)
				recordConfirmed2=YES;
			
			recordExists=YES;
		}
		
		if(recordExists) {
			int plotX = xCord;
			int plotY = bottomEdgeOfChart-(asset_value-min)*yMultiplier;
			int plotY2 = bottomEdgeOfChart-(balance_owed-min)*yMultiplier;
			if(type==99 || type==5) {
				// interest
				plotY2 = bottomEdgeOfChart-(interest-min)*yMultiplier;
				balance_owed=interest;
			}
			
			if(firstRecord) {
				oldY = plotY;
				oldY2 = plotY2;
				oldX = plotX;
				firstRecord=NO;
			}
			
			
			
			if(type !=3 ) {
				// draw green line (not needed for debt)
				CGContextSetLineWidth(c, 2);
				CGContextSetRGBStrokeColor(c, 0, .5, 0, 1); // green
				[self drawLine:c startX:oldX startY:oldY endX:plotX endY:plotY];
				
				// draw circle
				[self drawGraphCircleForContext:c x:oldX y:oldY recordConfirmed:oldRecordConfirmed recExists:recExists];
				[self drawGraphCircleForContext:c x:plotX y:plotY recordConfirmed:recordConfirmed recExists:recExists];
				
			}
			
			if(1) {
				// draw red line (not needed for asset)
				CGContextSetLineWidth(c, 2);
				CGContextSetRGBStrokeColor(c, .5, 0, 0, 1); // green
				[self drawLine:c startX:oldX startY:oldY2 endX:plotX endY:plotY2];
				
				// draw circle
				[self drawGraphCircleForContext:c x:oldX y:oldY2 recordConfirmed:oldRecordConfirmed2 recExists:recExists];
				[self drawGraphCircleForContext:c x:plotX y:plotY2 recordConfirmed:recordConfirmed2 recExists:recExists];
				
			}
			
			
			
			if(month==nowMonth && predYear==nowYear) {
				CGContextSetLineWidth(c, 4);
				CGContextSetRGBStrokeColor(c, 0, .5, .5, 1); // today
				[self drawLine:c startX:plotX startY:0 endX:plotX endY:bottomEdgeOfChart];
			}
			if(month==displayMonth) {
				if(month==nowMonth && nowYear==predYear)
					isTodayFlg=YES;
				CGContextSetLineWidth(c, 2);
				CGContextSetRGBStrokeColor(c, .5, .5, 0, 1); // display month
				[self drawLine:c startX:plotX startY:0 endX:plotX endY:bottomEdgeOfChart];
				todayX=plotX;
				todayY=plotY;
				NSString *label = @"Assets";
				if(type==1 || type==2)
					label = @"Value";
				todayAmount = [NSString stringWithFormat:@"%@: %@", label, [ProjectFunctions convertNumberToMoneyString:asset_value]];
				
				todayY2=plotY2;
				label = @"Debts";
				if(type==99|| type==5)
					label = @"Interest";
				if(type==1 || type==2)
					label = @"Owed";
				
				todayAmount2 = [NSString stringWithFormat:@"%@: %@", label, [ProjectFunctions convertNumberToMoneyString:balance_owed]];
				
				
			}
			
			oldX = plotX;
			oldY = plotY;
			oldY2 = plotY2;
			oldRecordConfirmed = recordConfirmed;
			oldRecordConfirmed2 = recordConfirmed2;
		}
		
		xCord+=totalWidth/(numYears*12);
	} // for month
	
	if(todayY>0)
		[self drawGraphLabelForContext:c x:todayX y:todayY string:todayAmount isTodayFlg:isTodayFlg];
	
	if(abs(todayY-todayY2)<=30 && todayY2>0 && todayY>todayY2) { // make sure they don't overlap
		todayY2-=30;
		if(todayY2<=0)
			todayY2+=60;
	}
	if(abs(todayY-todayY2)<=30 && todayY2>0 && todayY<=todayY2) { // make sure they don't overlap
		todayY2+=30;
		if(todayY2>bottomEdgeOfChart-30)
			todayY2-=60;
	}
	
	if(todayY2>0)
		[self drawGraphLabelForContext:c x:todayX y:todayY2 string:todayAmount2 isTodayFlg:isTodayFlg];
	
	
	
	UIGraphicsPopContext();
	//	UIImage *dynamicImage = [[UIImage alloc] init];
	UIImage *dynamicImage = UIGraphicsGetImageFromCurrentImageContext();
	
	UIGraphicsEndImageContext();
	
	return dynamicImage;
	
}

+(UIImage *)plotGraphWithItems:(NSArray *)itemList
{
	int totalWidth=[self totalWidth];
	int totalHeight=totalWidth/2;
	int leftEdgeOfChart=totalWidth/12.8;
	int bottomEdgeOfChart=totalHeight-(totalWidth/25.6);
	
	//Find min and max---------
	double min=0;
	double max=0;
	for (GraphObject *graphObj in itemList) {
		if(graphObj.amount > max)
			max=graphObj.amount;
		if(graphObj.amount < min)
			min=graphObj.amount;
	}
	
	max*=1.1;
	min*=1.05;
	double totalMoneyRange = max-min;
	
	float yMultiplier = 1;
	if(totalMoneyRange>0)
		yMultiplier = (float)bottomEdgeOfChart/totalMoneyRange;
	
	
	CGContextRef c = [self contextRefForGraphofWidth:totalWidth totalHeight:totalHeight];
	int zeroLoc = [self drawZeroLineForContext:c min:min max:max bottomEdgeOfChart:bottomEdgeOfChart leftEdgeOfChart:leftEdgeOfChart totalWidth:totalWidth];
	
	[self drawLeftLabelsAndLinesForContext:c totalMoneyRange:(max-min) min:min leftEdgeOfChart:leftEdgeOfChart totalHeight:totalHeight totalWidth:totalWidth numOnlyFlg:YES];
	
	[self drawBottomLabelsForArray2:itemList c:c bottomEdgeOfChart:bottomEdgeOfChart leftEdgeOfChart:leftEdgeOfChart totalWidth:totalWidth];
	
	[self drawGraphForContext:c itemArray:itemList leftEdgeOfChart:leftEdgeOfChart zeroLoc:zeroLoc yMultiplier:yMultiplier totalWidth:totalWidth bottomEdgeOfChart:bottomEdgeOfChart shadingFlg:YES];
	[self drawGraphForContext:c itemArray:itemList leftEdgeOfChart:leftEdgeOfChart zeroLoc:zeroLoc yMultiplier:yMultiplier totalWidth:totalWidth bottomEdgeOfChart:bottomEdgeOfChart shadingFlg:NO];
	
	
	UIGraphicsPopContext();
	UIImage *dynamicChartImage = UIGraphicsGetImageFromCurrentImageContext();
	
	UIGraphicsEndImageContext();
	
	return dynamicChartImage;
	
}

+(void)drawGraphForContext:(CGContextRef)c itemArray:(NSArray *)itemArray leftEdgeOfChart:(int)leftEdgeOfChart zeroLoc:(int)zeroLoc yMultiplier:(float)yMultiplier totalWidth:(int)totalWidth bottomEdgeOfChart:(int)bottomEdgeOfChart shadingFlg:(BOOL)shadingFlg
{
	if(itemArray.count==0)
		return;
	
	UIBezierPath *aPath = [UIBezierPath bezierPath];
	[aPath moveToPoint:CGPointMake(leftEdgeOfChart, zeroLoc)];
	int spacing = totalWidth/(itemArray.count);
	int XCord = leftEdgeOfChart;
	int YCord = 0;
	int oldX=leftEdgeOfChart;
	int oldY=bottomEdgeOfChart;
	int i=1;
	double oldValue=0;
	BOOL confirmOld=NO;
	BOOL existsOld=NO;
	for(GraphObject *graphObject in itemArray) {
		double value = graphObject.amount;
		
		//		BOOL showGreen = value>=0;
		//		if(graphObject.reverseColorFlg)
		//			showGreen=!showGreen;
		
		YCord=zeroLoc-value*yMultiplier;
		
		if(value>=oldValue)
			CGContextSetRGBStrokeColor(c, 0, .5, 0, 1); // green
		else
			CGContextSetRGBStrokeColor(c, 1, 0, 0, 1); // red
		
		[self drawGraphCircleForContext:c x:XCord y:YCord recordConfirmed:graphObject.confirmFlg recExists:graphObject.existsFlg];
		if(i==1)
			[aPath addLineToPoint:CGPointMake(leftEdgeOfChart, YCord)];
		else {
			[self drawLine:c startX:oldX startY:oldY endX:XCord endY:YCord];
			[self drawGraphCircleForContext:c x:oldX y:oldY recordConfirmed:confirmOld recExists:existsOld];
		}
		
		[aPath addLineToPoint:CGPointMake(XCord, YCord)];
		confirmOld = graphObject.confirmFlg;
		existsOld = graphObject.existsFlg;
		oldX=XCord;
		oldY=YCord;
		XCord+=spacing;
		i++;
	}
	[self drawGraphCircleForContext:c x:oldX y:oldY recordConfirmed:confirmOld recExists:YES];
	[aPath addLineToPoint:CGPointMake(totalWidth, YCord)];
	[aPath addLineToPoint:CGPointMake(totalWidth, bottomEdgeOfChart)];
	[aPath addLineToPoint:CGPointMake(leftEdgeOfChart, bottomEdgeOfChart)];
	[aPath closePath];
	if(shadingFlg)
		[self addGradientToPath:aPath context:c color1:[UIColor whiteColor] color2:(UIColor *)[UIColor orangeColor] lineWidth:(int)1 imgWidth:totalWidth imgHeight:300];
}

+(void)addGradientToPath:(UIBezierPath *)aPath
				 context:(CGContextRef)context
				  color1:(UIColor *)color1
				  color2:(UIColor *)color2
			   lineWidth:(int)lineWidth
				imgWidth:(int)width
			   imgHeight:(int)height
{
	width=[self totalWidth];
	height=width/2;
	
	CGFloat red1 = 0.0, green1 = 0.0, blue1 = 0.0, alpha1 =0.0;
	[color1 getRed:&red1 green:&green1 blue:&blue1 alpha:&alpha1];
	
	CGFloat red2 = 0.0, green2 = 0.0, blue2 = 0.0, alpha2 =0.0;
	[color2 getRed:&red2 green:&green2 blue:&blue2 alpha:&alpha2];
	
	CGColorSpaceRef myColorspace=CGColorSpaceCreateDeviceRGB();
	size_t num_locations = 2;
	CGFloat locations[2] = { 1.0, 0.0 };
	CGFloat components[8] =	{ red2, green2, blue2, alpha2,    red1, green1, blue1, alpha1};
	
	CGGradientRef myGradient = CGGradientCreateWithColorComponents(myColorspace, components, locations, num_locations);
	
	CGContextSaveGState(context);
	[aPath addClip];
	CGContextDrawLinearGradient(context, myGradient, CGPointMake(0, 0), CGPointMake(width, height), 0);
	CGContextRestoreGState(context);
	
	[[UIColor blackColor] setStroke];
	aPath.lineWidth = lineWidth;
	[aPath stroke];
	
	CGGradientRelease(myGradient);
}

+(void)drawGraphLabelForContext:(CGContextRef)c x:(int)x y:(int)y string:(NSString *)string isTodayFlg:(BOOL)isTodayFlg {
	int charSpacing=trunc([self totalWidth]/55);
	int width=(int)string.length*charSpacing+charSpacing*4;
	int height=trunc([self totalWidth]/20);
	
	x-=width/2-5;
	y+=14;
	
	if(x<40)
		x=40;
	if(x>trunc([self totalWidth]/1.5))
		x=trunc([self totalWidth]/1.5);
	if(y>[self totalWidth]/4)
		y-=(height*2);
	
	CGContextSetRGBFillColor(c, 0, 0, 0, 1); //
	CGContextFillRect(c, CGRectMake(x-charSpacing, y, width, height));
	if(isTodayFlg)
		CGContextSetRGBFillColor(c, 1, 1, 0, 1);
	else
		CGContextSetRGBFillColor(c, 1, 1, 1, 1);
	CGContextFillRect(c, CGRectMake(x-charSpacing+2, y+2, width-4, height-4));
	
	CGContextSetRGBFillColor(c, 0, 0, 0, 1); // red // <--- this one does letters
	[string drawAtPoint:CGPointMake(x, y+1) withFont:[UIFont fontWithName:@"Helvetica" size:trunc([self totalWidth]/25)]];
}

+(void)drawGraphCircleForContext:(CGContextRef)c x:(int)x y:(int)y recordConfirmed:(BOOL)recordConfirmed recExists:(BOOL)recExists {
	int circleMultiplyer = trunc([self totalWidth]/320);
	int circleSize=circleMultiplyer*11;
	
	CGContextSetRGBFillColor(c, .5, .5, .5, 1);
	for(int i=1; i<=2; i++)
		CGContextFillEllipseInRect(c, CGRectMake(x-circleSize/2+i,y-circleSize/2+i,circleSize,circleSize));
	
	CGContextSetRGBFillColor(c, 0, 0, 0, 1);
	CGContextFillEllipseInRect(c, CGRectMake(x-circleSize/2,y-circleSize/2,circleSize,circleSize));
	
	circleSize-=circleMultiplyer;
	CGContextSetRGBFillColor(c, 1, 1, 1, 1);
	CGContextFillEllipseInRect(c, CGRectMake(x-circleSize/2,y-circleSize/2,circleSize,circleSize));
	
	circleSize-=circleMultiplyer*4;
	if(recordConfirmed)
		CGContextSetRGBFillColor(c, 0, .5, 0, 1);
	else
		CGContextSetRGBFillColor(c, 1, 0, 0, 1);
	
	if(!recExists)
		CGContextSetRGBFillColor(c, 1, 1, 0, 1);
	
	CGContextFillEllipseInRect(c, CGRectMake(x-circleSize/2,y-circleSize/2,circleSize,circleSize));
	
	CGContextDrawPath(c, kCGPathFillStroke);
}

+(NSPredicate *)predicateForMonth:(int)month year:(int)year item_id:(int)item_id type:(int)type {
	if(item_id>0) // single item
		return [NSPredicate predicateWithFormat:@"year = %d AND month = %d AND item_id = %d", year, month, item_id];
	
	if(type==1 || type==2) // assets and debts
		return [NSPredicate predicateWithFormat:@"year = %d AND month = %d AND type = %d", year, month, type];
	else
		return [NSPredicate predicateWithFormat:@"year = %d AND month = %d", year, month];
}


+(NSString *)smallLabelForMoney:(double)moneyDouble totalMoneyRange:(double)totalMoneyRange {
	int money = round(moneyDouble);
	int moneyRoundingFactor = 1;
	if(totalMoneyRange>500)
		moneyRoundingFactor=10;
	if(totalMoneyRange>5000)
		moneyRoundingFactor=100;
	if(totalMoneyRange>50000)
		moneyRoundingFactor=1000;
	if(totalMoneyRange>500000)
		moneyRoundingFactor=10000;
	if(totalMoneyRange>5000000)
		moneyRoundingFactor=100000;
	if(totalMoneyRange>50000000)
		moneyRoundingFactor=1000000;
	
	money /=moneyRoundingFactor;
	money *=moneyRoundingFactor;
	
	BOOL negValue = (money<0)?YES:NO;
	if(negValue)
		money*=-1;
	
	NSString *label = [NSString stringWithFormat:@"%@%d", [self getMoneySymbol], (int)money];
	if(money>=1000)
		label = [NSString stringWithFormat:@"%@%.1fk", [self getMoneySymbol], (double)money/1000];
	if(money>=10000)
		label = [NSString stringWithFormat:@"%@%dk", [self getMoneySymbol], (int)money/1000];
	if(money>=100000)
		label = [NSString stringWithFormat:@"%dk", (int)money/1000];
	if(money>=1000000)
		label = [NSString stringWithFormat:@"%@%.1fM", [self getMoneySymbol], (double)money/1000000];
	if(money>=10000000)
		label = [NSString stringWithFormat:@"%@%dM", [self getMoneySymbol], (int)money/1000000];
	if(money>=100000000)
		label = [NSString stringWithFormat:@"%@%.1fB", [self getMoneySymbol], (double)money/1000000000];
	
	if (negValue)
		return [NSString stringWithFormat:@"-%@", label];
	else
		return label;
}

+(NSString *)getMoneySymbol {
	return @"$";
}
/*
+(void)drawLine:(CGContextRef)c startX:(int)startX startY:(int)startY endX:(int)endX endY:(int)endY
{
	CGContextMoveToPoint(c, startX, startY);
	CGContextAddLineToPoint(c, endX, endY);
	CGContextStrokePath(c);
}
*/
+(void)drawLine:(CGContextRef)c startPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint
{
	CGContextMoveToPoint(c, startPoint.x, startPoint.y);
	CGContextAddLineToPoint(c, endPoint.x, endPoint.y);
	CGContextStrokePath(c);
}

+(NSArray *)barChartValuesLast6MonthsForItem:(int)row_id month:(int)month year:(int)year reverseColorFlg:(BOOL)reverseColorFlg type:(int)type context:(NSManagedObjectContext *)context fieldType:(int)fieldType displayTotalFlg:(BOOL)displayTotalFlg {
	
	int timeFrame=12;
	NSMutableArray *graphArray = [[NSMutableArray alloc] init];
	month-=(timeFrame-1);
	if(month<1) {
		month+=12;
		year--;
	}
	int prevMonth=month;
	int prevYear=year;
	prevMonth--;
	if(prevMonth<1) {
		prevMonth=12;
		prevYear--;
	}
	
	NSArray *monthList = [ProjectFunctions namesOfAllMonths];
	for(int i=1; i<=timeFrame; i++) {
		GraphObject *graphObject = [[GraphObject alloc] init];
		graphObject.name=[monthList objectAtIndex:month-1];
		double amount=[self getAmountForMonth:month year:year type:type context:context reverseColorFlg:reverseColorFlg row_id:row_id fieldType:fieldType];
		double prevAmount=[self getAmountForMonth:prevMonth year:prevYear type:type context:context reverseColorFlg:reverseColorFlg row_id:row_id fieldType:fieldType];
		
		if(displayTotalFlg)
			graphObject.amount=amount;
		else
			graphObject.amount=amount-prevAmount;
		
		graphObject.reverseColorFlg = reverseColorFlg;
		[graphArray addObject:graphObject];
		prevYear=year;
		prevMonth=month;
		
		month++;
		if(month>12) {
			month=1;
			year++;
		}
	}
	return graphArray;
}

+(double)getAmountForMonth:(int)month year:(int)year type:(int)type context:(NSManagedObjectContext *)context reverseColorFlg:(BOOL)reverseColorFlg row_id:(int)row_id fieldType:(int)fieldType {
	
	double amount=0;
	return amount;
}

+(float)spinPieChart:(UIImageView *)imageView startTouchPosition:(CGPoint)startTouchPosition newTouchPosition:(CGPoint)newTouchPosition startDegree:(float)startDegree barGraphObjects:(NSMutableArray *)barGraphObjects {
	
	float changeX = (startTouchPosition.y>imageView.center.y)?startTouchPosition.x-newTouchPosition.x:newTouchPosition.x-startTouchPosition.x;
	
	float changeY = (startTouchPosition.x<imageView.center.x)?startTouchPosition.y-newTouchPosition.y:newTouchPosition.y-startTouchPosition.y;
	
	float newStartDegree = abs(changeX)>abs(changeY)?changeX:changeY;
	startDegree += newStartDegree;
	imageView.image = [self pieChartWithItems:barGraphObjects startDegree:startDegree];
	
	if(startDegree<0)
		startDegree+=360;
	if(startDegree>360)
		startDegree-=360;
	
	return startDegree;
}

+(int)getMonthFromView:(UIImageView *)imageView point:(CGPoint)point startingMonth:(int)startingMonth {
	float width = imageView.frame.size.width;
	int month=startingMonth;
	if(width>0) {
		int leftEdge = imageView.center.x-width/2;
		month = (10+point.x-leftEdge)*12/width;
		if(month>12)
			month=12;
		if(month<1)
			month=1;
	}
	month+=startingMonth;
	if(month>12)
		month-=12;
	return month;
}

+(NSArray *)itemsForMonth:(int)month year:(int)year type:(int)type context:(NSManagedObjectContext *)context {
	NSMutableArray *chartValuesArray = [[NSMutableArray alloc] init];
	NSArray *items = [CoreDataLib selectRowsFromEntity:@"ITEM" predicate:nil sortColumn:@"rowId" mOC:context ascendingFlg:YES];
	for(NSManagedObject *item in items) {
		NSString *name = [item valueForKey:@"name"];
		NSString *itemType = [item valueForKey:@"type"];
		int rowId = [[item valueForKey:@"rowId"] intValue];
		
		NSPredicate *predicate=[NSPredicate predicateWithFormat:@"year = %d AND month = %d AND item_id = %d", year, month, rowId];
		NSArray *values = [CoreDataLib selectRowsFromEntity:@"VALUE_UPDATE" predicate:predicate sortColumn:nil mOC:context ascendingFlg:NO];
		
		if(values.count>0) {
			NSManagedObject *mo = [values objectAtIndex:0];
			
			double amount=[self amountForObject:mo type:type itemType:itemType];
			
			if(amount>0)
				[chartValuesArray addObject:[self graphObjectWithName:name amount:amount rowId:rowId reverseColorFlg:(type==4) currentMonthFlg:NO]];
		}
	}
	return chartValuesArray;
}

+(double)amountForObject:(NSManagedObject *)mo type:(int)type itemType:(NSString *)itemType {
	double amount=0;
	if(type==0) //assets
		amount = [[mo valueForKey:@"asset_value"] doubleValue];
	if(type==1 && [@"Real Estate" isEqualToString:itemType]) //real estate
		amount = [[mo valueForKey:@"asset_value"] doubleValue];
	if(type==1 && itemType.length==0)
		amount = [[mo valueForKey:@"asset_value"] doubleValue]-[[mo valueForKey:@"balance_owed"] doubleValue];
	
	if(type==2 && [@"Vehicle" isEqualToString:itemType]) //real estate
		amount = [[mo valueForKey:@"asset_value"] doubleValue];
	if(type==2 && itemType.length==0)
		amount = [[mo valueForKey:@"asset_value"] doubleValue]-[[mo valueForKey:@"balance_owed"] doubleValue];
	
	if(type==3)
		amount = [[mo valueForKey:@"balance_owed"] doubleValue];
	if(type==4)
		amount = [[mo valueForKey:@"asset_value"] doubleValue]-[[mo valueForKey:@"balance_owed"] doubleValue];
	if(type==5)
		amount = [[mo valueForKey:@"interest"] doubleValue];
	return amount;
}

+(double)amountForObject:(NSManagedObject *)mo asset_type:(int)asset_type amount_type:(int)amount_type {
	int itemType = [[mo valueForKey:@"type"] intValue];
	if (asset_type==1 && itemType!=1)
		return 0;
	if (asset_type==2 && itemType!=2)
		return 0;
	
	double asset_value = [[mo valueForKey:@"asset_value"] doubleValue];
	double balance_owed = [[mo valueForKey:@"balance_owed"] doubleValue];
	double interest = [[mo valueForKey:@"interest"] doubleValue];
	
	if(amount_type==0)
		return asset_value;
	if(amount_type==1)
		return balance_owed;
	if(amount_type==3)
		return interest;
	
	return asset_value-balance_owed;
}

+(NSArray *)yearGraphItemsForMonth:(int)displayMonth year:(int)displayYear context:(NSManagedObjectContext *)context numYears:(int)numYears type:(int)type amount_type:(int)amount_type {
	// type: 0 = assets, 1=real estate, 2=vehicles, 3=debt, 4=equity, 5=interest, 6 cc debt, 7 investments
	//asset_type: 0=all, 1=real estate, 2=vehicle
	//amount_type: 0=value, 1=balance, 2=equity, 3= interest
//	int asset_type = type;
//	if(asset_type>2)
//		asset_type=0;
	
	NSMutableArray *graphArray = [[NSMutableArray alloc] init];

	return graphArray;
}

+(UIImage *)graphChartForMonth:(int)displayMonth year:(int)displayYear context:(NSManagedObjectContext *)context numYears:(int)numYears type:(int)type barsFlg:(BOOL)barsFlg asset_type:(int)asset_type amount_type:(int)amount_type {
	
	if(barsFlg) {
		NSArray *barItems = [self yearGraphItemsForMonth:displayMonth year:displayYear context:context numYears:numYears type:type amount_type:amount_type];
		return [self graphBarsWithItems:barItems];
	} else {
		return [self plotItemChart:context type:type displayYear:displayYear item_id:0 displayMonth:displayMonth startMonth:displayMonth startYear:displayYear numYears:numYears];
	}
}

+(NSArray *)pieItemsForMonth:(int)month year:(int)year context:(NSManagedObjectContext *)context {
	NSMutableArray *pieItems = [[NSMutableArray alloc] init];
	
	return pieItems;
}


@end
