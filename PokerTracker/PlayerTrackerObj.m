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
	
	int playerType = [[mo valueForKey:@"attrib_01"] intValue];
	int playerSkill = [[mo valueForKey:@"attrib_02"] intValue];	
	int user_id = [[mo valueForKey:@"user_id"] intValue];
	int agressiveNum = [[mo valueForKey:@"agressiveNum"] intValue];
	int looseNum = [[mo valueForKey:@"looseNum"] intValue];
	if(agressiveNum==0 && looseNum==0) {
		looseNum=playerType/100;
		agressiveNum=playerType-(looseNum*100);
		
		if(agressiveNum>100)
			agressiveNum=100;
		if(agressiveNum<1)
			agressiveNum=1;
		if(looseNum>100)
			looseNum=100;
		if(looseNum<1)
			looseNum=1;
	}
	
	obj.location = [mo valueForKey:@"status"];
	NSArray *skills = [NSArray arrayWithObjects:@"Weak", @"Average", @"Strong", @"Pro", nil];
	if(playerSkill<skills.count)
		obj.skillLevel = [skills objectAtIndex:playerSkill];

	obj.playerType = [self playerTypeString:looseNum passNum:agressiveNum];
	obj.pic = [self getUserPic:user_id playerSkill:playerSkill];
	
	obj.hudPlayerType = @"-";
	NSString *hudStyleStr = [mo valueForKey:@"desc"];
	NSArray *components = [hudStyleStr componentsSeparatedByString:@":"];
	if(components.count>7) {
		obj.hudPlayerType = [components objectAtIndex:7];
		obj.hudFlag=YES;
	}
	obj.strengths = [mo valueForKey:@"attrib_03"];
	obj.weaknesses = [mo valueForKey:@"attrib_04"];
	
	obj.playerSkill = [[mo valueForKey:@"attrib_02"] intValue];
	
	//------------update this stuff for some reason------------------
	if(user_id==0) {
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"type = %@", @"PLAYER"];
		NSArray *items = [CoreDataLib selectRowsFromEntity:@"EXTRA" predicate:predicate sortColumn:@"user_id" mOC:managedObjectContext ascendingFlg:NO];
		user_id = 1;
		if([items count]>0) {
			NSManagedObject *mo2 = [items objectAtIndex:0];
			user_id = [[mo2 valueForKey:@"user_id"] intValue];
			user_id++;
			[mo setValue:[NSNumber numberWithInt:user_id] forKey:@"user_id"];
			[managedObjectContext save:nil];
		}
	}
	
	if(mo != nil) {
		int player_id = [[mo valueForKey:@"player_id"] intValue];
		if(player_id==0) {
			player_id = [ProjectFunctions generateUniqueId];
			[mo setValue:[NSNumber numberWithInt:player_id] forKey:@"player_id"];
			[managedObjectContext save:nil];
		}
		
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"type = %@ AND user_id = %d", @"PLAYER", user_id];
		NSArray *items = [CoreDataLib selectRowsFromEntity:@"EXTRA" predicate:predicate sortColumn:nil mOC:managedObjectContext ascendingFlg:YES];
		if([items count]>1) {
			player_id = [ProjectFunctions generateUniqueId];
			[mo setValue:[NSNumber numberWithInt:player_id] forKey:@"player_id"];
			[managedObjectContext save:nil];
		}
	}


	return obj;
}

+(NSString *)playerTypeString:(int)looseNum passNum:(int)passNum
{
	if(looseNum<=50 && passNum<=50)
		return @"Loose-Passive";
	
	if(looseNum<=50 && passNum>50)
		return @"Loose-Aggressive";
	
	if(looseNum>50 && passNum<=50)
		return @"Tight-Passive";
	
	return @"Tight-Aggressive";
}

+(UIImage *)getUserPic:(int)user_id playerSkill:(int)playerSkill
{
	UIImage *image=nil;
	NSString *jpgPath = [self getPicPath:user_id];
	
	NSFileHandle *fh = [NSFileHandle fileHandleForReadingAtPath:jpgPath];
	if(fh==nil)
		image = [UIImage imageNamed:[NSString stringWithFormat:@"playerType%d.png", playerSkill+1]];
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
