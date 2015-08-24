//
//  SoundsLib.h
//  TournamentDirector
//
//  Created by Rick Medved on 3/5/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//
//	1.	In the project navigator, select your project
//	2.	Select your target
//	3.	Select the 'Build Phases' tab
//	4.	Open 'Link Binaries With Libraries' expander
//	5.	Click the '+' button
//	6.	Select framework AudioToolbox.framework

#import <Foundation/Foundation.h>


@interface SoundsLib : NSObject {

}

+(void)PlaySound:(NSString *)file type:(NSString *)type;

@end
