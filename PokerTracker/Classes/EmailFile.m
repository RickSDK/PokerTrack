//
//  EmailFile.m
//  PokerTracker
//
//  Created by Rick Medved on 1/16/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "EmailFile.h"
#import "ProjectFunctions.h"
#import "CoreDataLib.h"
#import "NSDate+ATTDate.h"


@implementation EmailFile
@synthesize managedObjectContext;

-(NSMutableString *)getDataForTheseRecords:(NSArray *)items keyList:(NSArray *)keyList
{
	NSMutableString *page = [NSMutableString stringWithCapacity:10000];
	
	NSString *header = [keyList componentsJoinedByString:@"\t"];
	[page appendFormat:@"%@\n", header];
	for(NSManagedObject *mo in items) {
		NSMutableString *line = [NSMutableString stringWithCapacity:10000];
		for(NSString *key in keyList) {
			NSString *value = [mo valueForKey:key];
			if([key isEqualToString:@"startTime"] || [key isEqualToString:@"endTime"] || [key isEqualToString:@"gameDate"] || [key isEqualToString:@"created"]) {
				value = [[mo valueForKey:key] convertDateToStringWithFormat:nil];
			}
			[line appendFormat:@"%@%@", value, @"\t"];
		}
		NSString *finalLine = [line stringByReplacingOccurrencesOfString:@"\n" withString:@"[nl]"];
		[page appendString:finalLine];
		[page appendString:@"\n"];
	} // <-- for
	return [NSMutableString stringWithFormat:@"%@", page];
}

-(NSString *)getGameData
{
	NSArray *keyList = [ProjectFunctions getColumnListForEntity:@"GAME" type:@"column"];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"user_id = %d", 0];
	NSArray *items = [CoreDataLib selectRowsFromEntity:@"GAME" predicate:predicate sortColumn:@"startTime" mOC:managedObjectContext ascendingFlg:YES];
	return [self getDataForTheseRecords:items keyList:keyList];
}

-(void)viewDidLoad {
	[super viewDidLoad];
	
//	NSFileHandle *fh = [NSFileHandle fileHandleForWritingAtPath:@"data.xls"];
	NSString *dataFile = [self getGameData];
	
	MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
	picker.mailComposeDelegate = self;
	
	[picker setSubject:@"Your PokerTrack Data"];
	
	
	// Set up recipients
	NSArray *toRecipients = [NSArray arrayWithObject:[ProjectFunctions getUserDefaultValue:@"emailAddress"]]; 
//	NSArray *ccRecipients = [NSArray arrayWithObjects:@"second@example.com", @"third@example.com", nil]; 
//	NSArray *bccRecipients = [NSArray arrayWithObject:@"fourth@example.com"]; 
	
	[picker setToRecipients:toRecipients];
//	[picker setCcRecipients:ccRecipients];  
//	[picker setBccRecipients:bccRecipients];
	
	// Attach an image to the email
//	NSString *path = [[NSBundle mainBundle] pathForResource:@"rainy" ofType:@"png"];
//	NSData *myData = [NSData dataWithContentsOfFile:path];
//	[picker addAttachmentData:myData mimeType:@"image/png" fileName:@"rainy"];

//	UIImage *roboPic = [UIImage imageNamed:@"Icon.png"];
//	NSData *imageData = UIImageJPEGRepresentation(roboPic, 1);
	
	NSData *fileData = [dataFile dataUsingEncoding:NSUTF8StringEncoding];
	[picker addAttachmentData:fileData mimeType:@"text/plain" fileName:@"data.xls"];
	
	// Fill out the email body text
	NSString *emailBody = @"Here is Your PokerTrack Data";
	[picker setMessageBody:emailBody isHTML:NO];
	
	[self presentModalViewController:picker animated:YES];
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error 
{   
    // Notifies users about errors associated with the interface
	NSString *resultStr = nil;
    switch (result)
    {
        case MFMailComposeResultCancelled:
            resultStr = @"Canceled";
            break;
        case MFMailComposeResultSaved:
            resultStr = @"Saved";
            break;
        case MFMailComposeResultSent:
            resultStr = @"Sent";
            break;
        case MFMailComposeResultFailed:
            resultStr = @"Failed";
            break;
        default:
            resultStr = @"Not Sent";
            break;
    }
    [self dismissModalViewControllerAnimated:YES];
	[ProjectFunctions showAlertPopup:@"Email" message:resultStr];
	[self.navigationController popViewControllerAnimated:YES];
	
}





@end
