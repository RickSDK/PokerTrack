//
//  AddPhotoVC.m
//  BabyBook
//
//  Created by Rick Medved on 11/15/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AddPhotoVC.h"
#import "MainMenuVC.h"
#import "EditPlayerTracker.h"
#import "MobileCoreServices/UTCoreTypes.h"
#import <MediaPlayer/MediaPlayer.h>
#import "ProjectFunctions.h"
#import "EditPlayerTracker.h"

 

@implementation AddPhotoVC

@synthesize imgPicker;
@synthesize managedObject, managedObjectContext, menuNumber, image, cameraMode, callBackViewController;

- (void)viewDidLoad {
	[super viewDidLoad];
	[self setTitle:@"Choose Photo"];
	NSString *name = [managedObject valueForKey:@"name"];
	[self setTitle:name];

	imgPicker = [[UIImagePickerController alloc] init];
	imgPicker.allowsEditing = YES;
	imgPicker.delegate = self;
	if(cameraMode==0 && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
		imgPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
	if(cameraMode==1)
		imgPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
	{
		[self presentViewController:imgPicker animated:YES completion:nil];
	}
}

- (IBAction)grabImage {
	[self presentViewController:imgPicker animated:NO completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	[picker dismissViewControllerAnimated:YES completion:nil];
	UIImage *img = [info objectForKey:@"UIImagePickerControllerEditedImage"];
	image.image = img;
	CGSize newSize;
	newSize.height=100;
	newSize.width=100;
	UIImage *newImg = [ProjectFunctions imageWithImage:img newSize:newSize];
	NSString *jpgPath = [ProjectFunctions getPicPath:(int)menuNumber];

	[UIImageJPEGRepresentation(newImg, 1.0) writeToFile:jpgPath atomically:YES];

	[(EditPlayerTracker *)callBackViewController updateImage];
	[self.navigationController popViewControllerAnimated:YES];
}

@end
