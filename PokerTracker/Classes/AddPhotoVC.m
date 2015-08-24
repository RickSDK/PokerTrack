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
	[self setTitle:name]; // <-- testing

	

	imgPicker = [[UIImagePickerController alloc] init];
//	imgPicker.allowsImageEditing = YES;
	imgPicker.allowsEditing = YES;
	imgPicker.delegate = self;
	if(cameraMode==0 && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
		imgPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
	if(cameraMode==1)
		imgPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
	{

		[self presentModalViewController:imgPicker animated:NO];
	}


}



- (IBAction)grabImage {
	[self presentModalViewController:imgPicker animated:NO];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {

	[picker dismissModalViewControllerAnimated:YES];


	UIImage *img = [info objectForKey:@"UIImagePickerControllerEditedImage"];
//	NSData *imgData = UIImageJPEGRepresentation(img, 1.0);
//	int bytes = [imgData length];
//	NSLog(@"size: %d", bytes);
	image.image = img;
	CGSize newSize;
	newSize.height=100;
	newSize.width=100;
	UIImage *newImg = [ProjectFunctions imageWithImage:img newSize:newSize];
//	imgData = UIImageJPEGRepresentation(newImg, 1.0);
//	bytes = [imgData length];
//	NSLog(@"new size: %d %d", bytes, menuNumber);
//	NSString *jpgPath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"player%d.jpg", menuNumber]];
//	NSString *jpgPath = [NSString stringWithFormat:@"player%d.jpg", menuNumber];
	NSString *jpgPath = [ProjectFunctions getPicPath:menuNumber];

	[UIImageJPEGRepresentation(newImg, 1.0) writeToFile:jpgPath atomically:YES];

	[(EditPlayerTracker *)callBackViewController updateImage];
	[self.navigationController popViewControllerAnimated:YES];

//	EditPlayerTracker *detailViewController = [[EditPlayerTracker alloc] initWithNibName:@"EditPlayerTracker" bundle:nil];
//	detailViewController.managedObject = managedObject;
//	detailViewController.managedObjectContext = managedObjectContext;
//	detailViewController.showMenuFlg=YES;
//	[self.navigationController pushViewController:detailViewController animated:YES];
//	[detailViewController release];	
}




- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}




@end
