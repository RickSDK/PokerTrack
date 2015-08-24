//
//  WebServicesFunctions.h
//  PokerTracker
//
//  Created by Rick Medved on 10/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface WebServicesFunctions : UIViewController {

}

+(NSString *)getResponseFromWeb:(NSString *)webAddressLink;
+(NSString *)formatEmailForUrl:(NSString *)email;
+(NSString *)getResponseFromServerUsingPost:(NSString *)weblink fieldList:(NSArray *)fieldList valueList:(NSArray *)valueList;
+(BOOL)validateStandardResponse:(NSString *)responseStr delegate:(id)delegate;
+(NSString *)parseCoord:(NSString *)line;
+(NSString *)getFormattedAddress:(NSString *)response value:(NSString *)value;
+(NSString *)getAddressFromGPSLat:(float)lat lng:(float)lng type:(int)type;



@end
