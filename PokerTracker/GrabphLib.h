//
//  GrabphLib.h
//  PokerTracker
//
//  Created by Rick Medved on 4/29/13.
//
//

#import <Foundation/Foundation.h>

@interface GrabphLib : NSObject {
    
}

+(void)drawLine:(CGContextRef)c startX:(int)startX startY:(int)startY endX:(int)endX endY:(int)endY;
+(UIImageView *)graphStatsChart:(NSManagedObjectContext *)mOC data:(NSString *)data type:(int)type;
//+(int)getYFromValue:(int)value;
+(int)getYValue:(int)value max:(int)max min:(int)min;

@end
