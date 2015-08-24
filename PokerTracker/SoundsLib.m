//
//  SoundsLib.m
//  TournamentDirector
//
//  Created by Rick Medved on 3/5/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "SoundsLib.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import "ProjectFunctions.h"


@implementation SoundsLib

+(void)PlaySound:(NSString *)file type:(NSString *)type
{
//	return;
    NSString *soundOn = [ProjectFunctions getUserDefaultValue:@"soundOn"];
    if([soundOn length]==0) {
        SystemSoundID soundID;
        NSString *path = [[NSBundle mainBundle] pathForResource:file ofType:type];
        NSURL *url = [NSURL fileURLWithPath:path];
		AudioServicesCreateSystemSoundID ((__bridge CFURLRef)url, &soundID);
        AudioServicesPlaySystemSound(soundID);
    }
}

@end
