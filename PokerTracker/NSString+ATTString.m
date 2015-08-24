//
//  NSString+ATTString.m
//  OrderStatus
//
//

#import "NSString+ATTString.h"

@implementation NSString (ATTString)

- (BOOL) isNumeric {
	return  [self rangeOfCharacterFromSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]].location == NSNotFound;
}

- (BOOL) isAlphaNumeric {
	return [self rangeOfCharacterFromSet:[[NSCharacterSet alphanumericCharacterSet] invertedSet]].location == NSNotFound;
}

- (BOOL) isAlphaNumericWithWhiteSpace {
	NSMutableCharacterSet *aCharacterSet = [[NSMutableCharacterSet alloc] init];
	
	[aCharacterSet formUnionWithCharacterSet:[NSCharacterSet alphanumericCharacterSet]];
	[aCharacterSet formUnionWithCharacterSet:[NSCharacterSet whitespaceCharacterSet]];
	
	BOOL result = [self rangeOfCharacterFromSet:[aCharacterSet invertedSet]].location == NSNotFound;
	
	
	return result;
}

/* Convience Function to minimize Strings check that require 
 * you to check value and then assing empty string or the value. 
 */
+ (NSString *) getValueOrEmtpyString:(NSString *) string {
	if ([NSString hasValue:string]) {
		return string;
	}
	return @"";
}

+ (BOOL) hasValue:(NSString *) str {
	if (str != nil && [str length] > 0) {
		return YES;
	}
	return NO;
}

+ (BOOL) isStringInArrayOfStrings:(NSArray *)arrayOfStrings stringValue:(NSString *) stringValue {
	if (arrayOfStrings == nil || [arrayOfStrings count] == 0) {
		return NO;
	}
	
	BOOL found = NO;
	
	for (NSString *uso in arrayOfStrings) {
		if ([uso isEqualToString:stringValue]) { 
			found = YES;
			break;
		} 
	}
	
	return found;
}

/* returns the index of arrays item that matches the passed in String value
 * returns -1 if value not found 
 */
- (int) indexForStringInArray:(NSArray *) theArray{
	int result = -1;
	
	if (theArray && [NSString hasValue:self]) {
		for (int i = 0; i < [theArray count]; i++) {
			if ([theArray objectAtIndex:i] != nil && [self localizedCaseInsensitiveCompare:[theArray objectAtIndex:i]] == NSOrderedSame) {
				result = i;
				break;
			}
		}
	}
	return result;
}

// This will return a telephone number formatted even if it is partically complete.
+ (NSString *)formatAsParticalTelephone:(NSString *)string {
	if (string == nil) return nil;
	NSMutableString *result = [NSMutableString stringWithCapacity:10];
	
	int stringLength = [string length];
	if (stringLength > 7  && stringLength <= 10) {
		NSString *NPA = [string substringWithRange:NSMakeRange(0, 3)];
		NSString *NXX = [string substringWithRange:NSMakeRange(3, 3)];
		int leftOver = stringLength - 6;
		NSString *lastFour = [string substringWithRange:NSMakeRange(6, leftOver)];
		[result appendFormat:@"(%@) %@-%@",NPA, NXX, lastFour];		
	} else if (stringLength >= 4 && stringLength <= 7) {
		NSString *NXX = [string substringWithRange:NSMakeRange(0, 3)];
		int leftOver = stringLength - [NXX length];
		NSString *lastFour = [string substringWithRange:NSMakeRange(3, leftOver)];
		[result appendFormat:@"%@-%@",NXX, lastFour ];
	} else {
		// Either String is to short, Less then 3, or to Long greater then 10 so don't format.
		[result appendString:string];
	}

	return result;
}

+ (NSString *)formatAsTelephone:(NSString *)string {
	string = [self removeTelephoneFormatting:string];
	
	int len = [string length];
	if (len==11 && [[string substringWithRange:NSMakeRange(0, 1)] isEqualToString:@"1"]) {
		string = [string substringWithRange:NSMakeRange(1, len-1)];
		len--;
	}
	
	
	if (len == 7) 
		return [NSString stringWithFormat:@"%@-%@",
				[string substringWithRange:NSMakeRange(0, 3)],
				[string substringWithRange:NSMakeRange(3, 4)]];

	else if(len<10)
		return string;

	else if (len == 10) 
		return [NSString stringWithFormat:@"(%@) %@-%@",
				[string substringWithRange:NSMakeRange(0, 3)],
				[string substringWithRange:NSMakeRange(3, 3)],
				[string substringWithRange:NSMakeRange(6, 4)]];
		
	
	return [NSString stringWithFormat:@"(%@) %@-%@ x%@",
			[string substringWithRange:NSMakeRange(0, 3)],
			[string substringWithRange:NSMakeRange(3, 3)],
			[string substringWithRange:NSMakeRange(6, 4)],
			[string substringWithRange:NSMakeRange(10, len-10)]];
	
}

+(BOOL) isDigit:(unichar) c {
	
	NSMutableCharacterSet *set = [[NSMutableCharacterSet alloc] init];
	[set addCharactersInString:@"0123456789"];
	return [set characterIsMember:c];
}

+ (NSString *) removeTelephoneFormatting:(NSString *)string {
	if (string == nil) {
		return @"";
	}
	NSMutableString *result = [NSMutableString stringWithCapacity:15];
	
	for (int i = 0; i < [string length]; i++) {
		if ([NSString isDigit:[string characterAtIndex:i]]) {
			[result appendFormat:@"%c", [string characterAtIndex:i] ];
		}
	}
	return result;
}

+ (BOOL) BOOLValue:(NSString *) str {
	if (str == nil) {
		return NO;
	}
	if ([str caseInsensitiveCompare:@"YES"] == NSOrderedSame) { // Do NS boolean translation
		return YES;
	}
	if ([str caseInsensitiveCompare:@"Y"] == NSOrderedSame) { // Do NS boolean translation
		return YES;
	}
	if ([str caseInsensitiveCompare:@"true"] == NSOrderedSame) { // Do statndard True False compare {
		return YES;
	}
	return NO;
}

+ (NSDate *)stringValue:(NSString *)value asDateUsingDateFormatter:(NSDateFormatter *)dFormatter {
	NSDate *date;
	if (value == nil)
		date = nil;
	else 
		date = [dFormatter dateFromString:value];
	return (date ? date : [NSDate distantFuture]);
}

+ (NSDate *)stringValue:(NSString *)value asDateWithFormat:(NSString *)format {
	NSDate *date;
	if (value == nil)
		date = nil;
	else 
		date = [value convertStringToDateWithFormat:format];
	return (date ? date : [NSDate distantFuture]);	
}

-(NSDate *)convertStringToDateWithFormat:(NSString *)format
{
	if(format==nil || [format isEqualToString:@""])
		format = @"MM/dd/yyyy hh:mm:ss a";
	
	if([format isEqualToString:@"short"])
		format = @"MM/dd/yyyy hh:mm a";
	
	if([format isEqualToString:@"date"])
		format = @"MM/dd/yyyy";

	if([format isEqualToString:@"long"])
		format = @"yyyy-MM-dd hh:mm:ss ZZ";
	
	if([format isEqualToString:@"pokerJounral"])
		format = @"MM/dd/yyyy HH:mm";

	if([format isEqualToString:@"pokerJounral2"])
		format = @"M/d/yy hh:mm a";

	NSDateFormatter *df = [[NSDateFormatter alloc] init];
	[df setDateFormat:format];
	NSDate *dateVar = [df dateFromString:self];

	if(dateVar==nil) {
		int year=2015;
		int month=1;
		int day=1;
		NSString *dateStr = [self stringByReplacingOccurrencesOfString:@"/" withString:@"-"];
		NSArray *components = [dateStr componentsSeparatedByString:@" "];
		if(components.count>0) {
			NSArray *valComp = [[components objectAtIndex:0] componentsSeparatedByString:@"-"];
			if(valComp.count>2) {
				month=[[valComp objectAtIndex:0] intValue];
				day=[[valComp objectAtIndex:1] intValue];
				year=[[valComp objectAtIndex:2] intValue];
				if(month>12) {
					year=[[valComp objectAtIndex:0] intValue];
					month=[[valComp objectAtIndex:1] intValue];
					day=[[valComp objectAtIndex:2] intValue];
				}
			}
		}
		dateVar = [[NSString stringWithFormat:@"%02d/%02d/%d 06:00:00 AM", month, day, year] convertStringToDateWithFormat:@"MM/dd/yyyy hh:mm:ss a"];
	}
    if(dateVar==nil)
        dateVar= [NSDate date];

	return dateVar;
}

static char base64EncodingTable[64] = {
	'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P',
	'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', 'a', 'b', 'c', 'd', 'e', 'f',
	'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v',
	'w', 'x', 'y', 'z', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '+', '/'
};

+ (NSString *) base64StringFromData: (NSData *)data length: (int)length {
	unsigned long ixtext, lentext;
	long ctremaining;
	unsigned char input[3], output[4];
	short i, charsonline = 0, ctcopy;
	const unsigned char *raw;
	NSMutableString *result;
	
	lentext = [data length]; 
	if (lentext < 1)
		return @"";
	result = [NSMutableString stringWithCapacity: lentext];
	raw = [data bytes];
	ixtext = 0; 
	
	while (true) {
		ctremaining = lentext - ixtext;
		if (ctremaining <= 0) 
			break;        
		for (i = 0; i < 3; i++) { 
			unsigned long ix = ixtext + i;
			if (ix < lentext)
				input[i] = raw[ix];
			else
				input[i] = 0;
		}
		output[0] = (input[0] & 0xFC) >> 2;
		output[1] = ((input[0] & 0x03) << 4) | ((input[1] & 0xF0) >> 4);
		output[2] = ((input[1] & 0x0F) << 2) | ((input[2] & 0xC0) >> 6);
		output[3] = input[2] & 0x3F;
		ctcopy = 4;
		switch (ctremaining) {
			case 1: 
				ctcopy = 2; 
				break;
			case 2: 
				ctcopy = 3; 
				break;
		}
		
		for (i = 0; i < ctcopy; i++)
			[result appendString: [NSString stringWithFormat: @"%c", base64EncodingTable[output[i]]]];
		
		for (i = ctcopy; i < 4; i++)
			[result appendString: @"="];
		
		ixtext += 3;
		charsonline += 4;
		
		if ((length > 0) && (charsonline >= length))
			charsonline = 0;
	}     
	return result;
}

+ (NSData *)base64DataFromString: (NSString *)string
{
    unsigned long ixtext, lentext;
    unsigned char ch, inbuf[4], outbuf[3];
    short i, ixinbuf;
    Boolean flignore, flendtext = false;
    const unsigned char *tempcstring;
    NSMutableData *theData;
	
    if (string == nil)
    {
        return [NSData data];
    }
	
    ixtext = 0;
	
    tempcstring = (const unsigned char *)[string UTF8String];
	
    lentext = [string length];
	
    theData = [NSMutableData dataWithCapacity: lentext];
	
    ixinbuf = 0;
	
    while (true)
    {
        if (ixtext >= lentext)
        {
            break;
        }
		
        ch = tempcstring [ixtext++];
		
        flignore = false;
		
        if ((ch >= 'A') && (ch <= 'Z'))
        {
            ch = ch - 'A';
        }
        else if ((ch >= 'a') && (ch <= 'z'))
        {
            ch = ch - 'a' + 26;
        }
        else if ((ch >= '0') && (ch <= '9'))
        {
            ch = ch - '0' + 52;
        }
        else if (ch == '+')
        {
            ch = 62;
        }
        else if (ch == '=')
        {
            flendtext = true;
        }
        else if (ch == '/')
        {
            ch = 63;
        }
        else
        {
            flignore = true; 
        }
		
        if (!flignore)
        {
            short ctcharsinbuf = 3;
            Boolean flbreak = false;
			
            if (flendtext)
            {
                if (ixinbuf == 0)
                {
                    break;
                }
				
                if ((ixinbuf == 1) || (ixinbuf == 2))
                {
                    ctcharsinbuf = 1;
                }
                else
                {
                    ctcharsinbuf = 2;
                }
				
                ixinbuf = 3;
				
                flbreak = true;
            }
			
            inbuf [ixinbuf++] = ch;
			
            if (ixinbuf == 4)
            {
                ixinbuf = 0;
				
                outbuf[0] = (inbuf[0] << 2) | ((inbuf[1] & 0x30) >> 4);
                outbuf[1] = ((inbuf[1] & 0x0F) << 4) | ((inbuf[2] & 0x3C) >> 2);
                outbuf[2] = ((inbuf[2] & 0x03) << 6) | (inbuf[3] & 0x3F);
				
                for (i = 0; i < ctcharsinbuf; i++)
                {
                    [theData appendBytes: &outbuf[i] length: 1];
                }
            }
			
            if (flbreak)
            {
                break;
            }
        }
    }
	
    return theData;
}



@end
