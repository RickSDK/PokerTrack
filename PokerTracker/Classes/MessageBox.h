//
//  MessageBox.h
//  PokerTracker
//
//  Created by Rick Medved on 11/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface MessageBox : UIViewController {
 	//---Passed In----------------------------
	NSManagedObjectContext *managedObjectContext;

	//---XIB----------------------------
	IBOutlet UILabel *fromLabel;
	IBOutlet UILabel *statusLabel;
	IBOutlet UILabel *dateLabel;
	IBOutlet UILabel *indexLabel;
	IBOutlet UITextView *messageBody;
	IBOutlet UIButton *prevButton;
	IBOutlet UIButton *replyButton;
	IBOutlet UIButton *nextButton;
	IBOutlet UIButton *deleteButton;

	//---Gloabls----------------------------
	NSMutableArray *items;
	int currentMessage;
	
}

- (IBAction) prevButtonClicked:(id)sender;
- (IBAction) replyButtonClicked:(id)sender;
- (IBAction) nextButtonClicked:(id)sender;
- (IBAction) deleteButtonClicked:(id)sender;
-(void)displayMail;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@property (nonatomic) int currentMessage;
@property (nonatomic, strong) UILabel *fromLabel;
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) UILabel *indexLabel;
@property (nonatomic, strong) UITextView *messageBody;

@property (nonatomic, strong) UIButton *prevButton;
@property (nonatomic, strong) UIButton *replyButton;
@property (nonatomic, strong) UIButton *nextButton;
@property (nonatomic, strong) UIButton *deleteButton;

@property (nonatomic, strong) NSMutableArray *items;



@end
