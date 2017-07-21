//
//  PlayerTrackerObj.m
//  PokerTracker
//
//  Created by Rick Medved on 7/12/17.
//
//

#import "PlayerTrackerObj.h"
#import "ProjectFunctions.h"
#import "CoreDataLib.h"

@implementation PlayerTrackerObj

+(PlayerTrackerObj *)createObjWithMO:(NSManagedObject *)mo managedObjectContext:(NSManagedObjectContext *)managedObjectContext {
	PlayerTrackerObj *obj = [[PlayerTrackerObj alloc] init];
	obj.name = [mo valueForKey:@"name"];
	
	obj.playerSkill = [[mo valueForKey:@"attrib_02"] intValue];
	obj.user_id = [[mo valueForKey:@"user_id"] intValue];
	obj.agressiveNum = [[mo valueForKey:@"agressiveNum"] intValue];
	obj.looseNum = [[mo valueForKey:@"looseNum"] intValue];
	obj.player_id = [[mo valueForKey:@"player_id"] intValue];
	
	obj.location = [mo valueForKey:@"status"];
	NSArray *skills = [NSArray arrayWithObjects:@"Weak", @"Average", @"Strong", @"Pro", nil];
	if(obj.playerSkill<skills.count)
		obj.skillLevel = [skills objectAtIndex:obj.playerSkill];

	obj.playerType = [self playerTypeString:obj.looseNum passNum:obj.agressiveNum];
	obj.picId = (obj.playerSkill==0)?1:obj.playerSkill+2;
	obj.pic = [self getUserPic:obj.user_id picId:obj.picId];
	
	obj.hudPlayerType = @"-";
	obj.hudString = [mo valueForKey:@"desc"];
	NSArray *components = [obj.hudString componentsSeparatedByString:@":"];
	if(components.count>8) {
		obj.hudPlayerType = [components objectAtIndex:7];
		obj.hudPicId = [[components objectAtIndex:8] intValue];
		obj.hudFlag=YES;
	}
	obj.strengths = [mo valueForKey:@"attrib_03"];
	obj.weaknesses = [mo valueForKey:@"attrib_04"];	
	
	return obj;
}

+(NSString *)playerTypeString:(int)looseNum passNum:(int)agressiveNum
{
	return [NSString stringWithFormat:@"%@-%@", (looseNum<=50)?@"Loose":@"Tight", (agressiveNum<=50)?@"Passive":@"Aggressive"];
}

+(UIImage *)getUserPic:(int)user_id picId:(int)picId
{
	UIImage *image=nil;
	NSString *jpgPath = [self getPicPath:user_id];
	
	NSFileHandle *fh = [NSFileHandle fileHandleForReadingAtPath:jpgPath];
	if(fh==nil)
		image = [ProjectFunctions playerImageOfType:picId];
	else {
		image = [UIImage imageWithContentsOfFile:jpgPath];
	}
	[fh closeFile];
	
	return image;
}

+(NSString *)getPicPath:(int)user_id
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *docDir = @"";
	if(paths.count>0)
		docDir = [paths objectAtIndex:0];
	return [docDir stringByAppendingPathComponent:[NSString stringWithFormat:@"player%d.jpg", user_id]];
}

@end
