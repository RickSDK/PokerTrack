//
//  NSData+ATTData.h
//  iBabyBook
//
//  Created by Rick Medved on 2/1/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSData (ATTData) 
	
+ (NSData *)base64DataFromString: (NSString *)string;

@end
