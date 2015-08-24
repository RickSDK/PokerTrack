//
//  NSString+ATTString.h
//  OrderStatus
//
//

#import <Foundation/Foundation.h>

#define DISPLAYSTRING(var) (var ? var : @"")   //macro to display blank if the variable is nil
#define DISPLAYDATE(var) [[DISPLAYSTRING(var) componentsSeparatedByString:@" "] objectAtIndex:0]   //macro to display just date portion
#define STRINGTODATEFORSORT(var,dFormat) [NSString stringValue:var asDateUsingDateFormatter:dFormat]

@interface NSString (ATTString) 

- (BOOL) isNumeric;
- (BOOL) isAlphaNumeric;
- (BOOL) isAlphaNumericWithWhiteSpace;

+ (BOOL) isStringInArrayOfStrings:(NSArray *)arrayOfStrings stringValue:(NSString *) stringValue;
- (int) indexForStringInArray:(NSArray *) array;
- (NSDate *)convertStringToDateWithFormat:(NSString *)format;

+ (NSString *) getValueOrEmtpyString:(NSString *) string;
+ (BOOL) hasValue:(NSString *) str;

+ (NSString *)formatAsParticalTelephone:(NSString *)string;
+ (NSString *)formatAsTelephone:(NSString *)string;
+ (NSString *)removeTelephoneFormatting:(NSString *)string;

// Function is designed to handle BOOL String of YES and TRUE in all cases. If string is nil NO is returned. 
+ (BOOL) BOOLValue:(NSString *) str;

//clas function because if string is nil, the date returned is distant date which is good for sorting purpose
+ (NSDate *)stringValue:(NSString *)value asDateUsingDateFormatter:(NSDateFormatter *)dFormatter;
+ (NSDate *)stringValue:(NSString *)value asDateWithFormat:(NSString *)format;
+ (NSData *)base64DataFromString: (NSString *)string;
+ (NSString *) base64StringFromData: (NSData *)data length: (int)length;


@end
