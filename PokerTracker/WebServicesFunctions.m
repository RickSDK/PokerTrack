    //
//  WebServicesFunctions.m
//  PokerTracker
//
//  Created by Rick Medved on 10/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "WebServicesFunctions.h"
#import "ProjectFunctions.h"
#import "NSArray+ATTArray.h"


@implementation WebServicesFunctions

+(NSString *)getResponseFromWeb:(NSString *)webAddressLink
{
	NSString *responseString = nil;
//	NSString *webLink = [webAddressLink stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
	
	NSURL *url = [NSURL URLWithString:[webAddressLink stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
	NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url
												  cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval: 10];
	NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	
	if(connection) {
		NSLog(@"Web Connection Established");
		NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
		responseString = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
	} else {
//		[ProjectFunctions showAlertPopup:@"WebService Error" :@"Not able to connect to the server. Try again later."];
	}
	
	
	
	return responseString;
}

+(NSString *)formatEmailForUrl:(NSString *)email
{
	return [[email stringByReplacingOccurrencesOfString:@"@" withString:@"%%40"] stringByReplacingOccurrencesOfString:@"." withString:@"%%23"];
}

+(NSString *)getResponseFromServerUsingPost:(NSString *)weblink fieldList:(NSArray *)fieldList valueList:(NSArray *)valueList
{
	if([fieldList count] != [valueList count]) {
		return [NSString stringWithFormat:@"Invalid value list! (%d, %d) %@", (int)[fieldList count], (int)[valueList count], weblink];
	}
	int i=0;
	NSMutableString *fieldStr= [[NSMutableString alloc] init];
	for(NSString *name in fieldList)
		[fieldStr appendFormat:@"&%@=%@", name, [valueList objectAtIndex:i++]];
	
	NSString *responseString = nil;
	NSData *postData = [fieldStr dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
	NSString *postLength = [NSString stringWithFormat:@"%d", (int)[postData length]];
    
    
 	NSURL *url = [NSURL URLWithString:weblink];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	[request setHTTPBody:postData];
	
    NSURLResponse *response;
    NSError *err;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
    NSString *reString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    responseString = [NSString stringWithFormat:@"%@", reString];
    
	return responseString;
}

+(BOOL)validateStandardResponse:(NSString *)responseStr delegate:(id)delegate
{
	if(responseStr==nil || [responseStr length]==0)
		responseStr = @"No Response Received.";
	
	if([responseStr length]>=7 && [[responseStr substringToIndex:7] isEqualToString:@"Success"]) {
		return YES;
	}
	else {
		NSLog(@"validateStandardResponse responseStr: %@", responseStr);
		if([responseStr length]>100)
			responseStr = @"Possible server issues. Please try again later.";
		[ProjectFunctions showAlertPopupWithDelegate:@"ERROR" message:responseStr delegate:(id)delegate];
		return NO;
	}
}

+(NSString *)parseCoord:(NSString *)line
{
	NSString *final = @"";
	NSArray *components = [line componentsSeparatedByString:@":"];
	if([components count]>1) {
		final = [components objectAtIndex:1];
		NSArray *groups = [final componentsSeparatedByString:@"\""];
		if([groups count]>1) {
			NSString *goodstuff = [groups objectAtIndex:1];
			NSArray *mixes = [goodstuff componentsSeparatedByString:@", "];
			if([mixes count]>3) {
				NSArray *stateZip = [[mixes objectAtIndex:2] componentsSeparatedByString:@" "];
				final = [NSString stringWithFormat:@"%@|%@|%@|%@|%@", [mixes stringAtIndex:3], [mixes stringAtIndex:0], [mixes stringAtIndex:1], [stateZip stringAtIndex:0], [stateZip stringAtIndex:1]];
			}
		}
	}
	return final;
}

+(NSString *)getFormattedAddress:(NSString *)response value:(NSString *)value
{
	NSArray *lines = [response componentsSeparatedByString:@"\n"];
	for(NSString *line in lines) {
		NSString *newline = [line stringByReplacingOccurrencesOfString:@" " withString:@""];
		if([newline length]>19) {
			if([[newline substringToIndex:19] isEqualToString:[NSString stringWithFormat:@"\"%@\"", value]])
				return [WebServicesFunctions parseCoord:line];
		}
	}
	return @"";
}


+(NSString *)getAddressFromGPSLat:(float)lat lng:(float)lng type:(int)type;
{
	
	NSString *latitude = [NSString stringWithFormat:@"%.6f", lat];
	NSString *longitutde = [NSString stringWithFormat:@"%.6f", lng];
	NSString *googleAPI = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/geocode/json?latlng=%@,%@&sensor=true", latitude, longitutde];
	NSString *response = [WebServicesFunctions getResponseFromWeb:googleAPI];
	
	NSString *address = [WebServicesFunctions getFormattedAddress:response value:@"formatted_address"];
	if(type==0)
		return address;
	if(type==1) {
		NSArray *elements = [address componentsSeparatedByString:@"|"];
        if([elements count]>2)
            return [elements stringAtIndex:2];
	}
	return nil;
}	





@end
