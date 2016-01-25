//
//  MessageBox.m
//  PokerTracker
//
//  Created by Rick Medved on 11/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MessageBox.h"
#import "CoreDataLib.h"
#import "FriendSendMessage.h"
#import "NSDate+ATTDate.h"


@implementation MessageBox
@synthesize managedObjectContext;
@synthesize fromLabel, statusLabel, messageBody, prevButton, replyButton, nextButton, deleteButton;
@synthesize dateLabel, indexLabel;
@synthesize items, currentMessage;


- (IBAction) prevButtonClicked:(id)sender
{
	currentMessage--;
	[self displayMail];
}
- (IBAction) replyButtonClicked:(id)sender
{
	NSManagedObject *msgObject = [items objectAtIndex:currentMessage];
	int friend_id = [[msgObject valueForKey:@"friend_id"] intValue];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"user_id = %d", friend_id];
	NSArray *friendList = [CoreDataLib selectRowsFromEntity:@"FRIEND" predicate:predicate sortColumn:nil mOC:managedObjectContext ascendingFlg:YES];
	NSManagedObject *mo = nil;
	if([friendList count]>0)
		mo = [friendList objectAtIndex:0];
	
	FriendSendMessage *detailViewController = [[FriendSendMessage alloc] initWithNibName:@"FriendSendMessage" bundle:nil];
	detailViewController.managedObjectContext = managedObjectContext;
	detailViewController.mo = mo;
	[self.navigationController pushViewController:detailViewController animated:YES];
}
- (IBAction) nextButtonClicked:(id)sender
{
	currentMessage++;
	[self displayMail];
}
- (IBAction) deleteButtonClicked:(id)sender
{
	NSManagedObject *mo = [items objectAtIndex:currentMessage];
	[managedObjectContext deleteObject:mo];
	[managedObjectContext save:nil];
	[items removeObjectAtIndex:currentMessage];
	currentMessage=0;
	[self displayMail];
}

-(void)displayMail {
	if([items count]<=currentMessage) {
		prevButton.enabled=NO;
		nextButton.enabled=NO;
		deleteButton.enabled=NO;
		replyButton.enabled=NO;
		dateLabel.text = @"";
		indexLabel.text = @"0 of 0";
		dateLabel.text = @"";
		statusLabel.text = @"";
		return;
	}
	NSManagedObject *mo = [items objectAtIndex:currentMessage];
	messageBody.text = [mo valueForKey:@"body"];
	NSDate *created = [mo valueForKey:@"created"];
	
	int friend_id = [[mo valueForKey:@"friend_id"] intValue];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"user_id = %d", friend_id];

	dateLabel.text = [created convertDateToStringWithFormat:nil];
	fromLabel.text = [CoreDataLib getFieldValueForEntityWithPredicate:managedObjectContext entityName:@"FRIEND" field:@"name" predicate:predicate indexPathRow:0];
	indexLabel.text = [NSString stringWithFormat:@"%d / %d", (int)currentMessage+1, (int)[items count]];
	
	if(currentMessage<=0)
		prevButton.enabled=NO;
	else
		prevButton.enabled=YES;
	
	if(currentMessage>=[items count]-1)
		nextButton.enabled=NO;
	else
		nextButton.enabled=YES;
	
	replyButton.enabled=YES;
	deleteButton.enabled=YES;
	
	statusLabel.text = [mo valueForKey:@"status"];
	
	if([[mo valueForKey:@"status"] isEqualToString:@""] || [mo valueForKey:@"status"]==nil) {
		statusLabel.text = @"New";
		[mo setValue:@"Read" forKey:@"status"];
		[managedObjectContext save:nil];
	}
	
}

-(void)mainMenuButtonClicked:(id)sender {
	[self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	[self setTitle:@"Inbox"];

	self.currentMessage=0;
	items = [[NSMutableArray alloc] initWithArray:[CoreDataLib selectRowsFromEntity:@"MESSAGE" predicate:nil sortColumn:nil mOC:managedObjectContext ascendingFlg:YES]];

	[deleteButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	[deleteButton setBackgroundImage:[UIImage imageNamed:@"redButton.png"] forState:UIControlStateNormal];
	
	[replyButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	[replyButton setBackgroundImage:[UIImage imageNamed:@"yellowButton.png"] forState:UIControlStateNormal];

	[prevButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	[prevButton setBackgroundImage:[UIImage imageNamed:@"tealButton.png"] forState:UIControlStateNormal];
	
	[nextButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	[nextButton setBackgroundImage:[UIImage imageNamed:@"tealButton.png"] forState:UIControlStateNormal];
	
	UIBarButtonItem *homeButton = [[UIBarButtonItem alloc] initWithTitle:@"Main Menu" style:UIBarButtonItemStylePlain target:self action:@selector(mainMenuButtonClicked:)];
	self.navigationItem.rightBarButtonItem = homeButton;

	[self displayMail];
	

}







@end
