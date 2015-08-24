//
//  NSString+ATTString.h
//  OrderStatus
//
//

#import <Foundation/Foundation.h>



@interface NSDate (ATTDate) 

-(NSString *)convertDateToStringWithFormat:(NSString *)format;
-(NSComparisonResult)compareDatesIgnoringTime:(NSDate *)date;

@end
