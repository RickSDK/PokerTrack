//
//  NSDate+ATTDate.m
//
//

#import "NSDate+ATTDate.h"

@implementation NSDate (ATTDate)

-(NSString *)convertDateToStringWithFormat:(NSString *)format
{
	if(format==nil || [format isEqualToString:@""])
		format = @"MM/dd/yyyy hh:mm:ss a";
	
	if([format isEqualToString:@"short"])
		format = @"MM/dd/yyyy hh:mm a";
	
	if([format isEqualToString:@"date"])
		format = @"MM/dd/yyyy";

	if([format isEqualToString:@"long"])
		format = @"yyyy-MM-dd HH:mm:ss ZZ";
	
	if([format isEqualToString:@"pokerJounral"])
		format = @"MM/dd/yyyy HH:mm";
	
	if([format isEqualToString:@"pokerJounral2"])
		format = @"M/d/yy hh:mm a";
	
	NSDateFormatter *df = [[NSDateFormatter alloc] init];
	[df setDateFormat:format];
	NSString *dateString = [df stringFromDate:self];
    if(dateString==nil)
        dateString=@"-";
	return dateString;
}

-(NSComparisonResult)compareDatesIgnoringTime:(NSDate *)date
{
	if([[self convertDateToStringWithFormat:nil] isEqualToString:[date convertDateToStringWithFormat:nil]])
		return NSOrderedSame;
	else
		return [self compare:date];
}

@end

