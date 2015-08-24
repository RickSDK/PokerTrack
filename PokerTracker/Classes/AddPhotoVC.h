//
//  AddPhotoVC.h
//  BabyBook
//
//  Created by Rick Medved on 11/15/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AddPhotoVC : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate>    {
 	//---Passed In----------------------------
	NSManagedObject *managedObject;
    NSManagedObjectContext *managedObjectContext;
	NSInteger menuNumber;
	NSInteger cameraMode;
	UIViewController *callBackViewController;

	//---XIB----------------------------
    IBOutlet UIImageView *image;

	//---Gloabls----------------------------
	UIImagePickerController *imgPicker;
	

}

- (IBAction)grabImage;

@property (nonatomic, strong) UIImageView *image;
@property (nonatomic, strong) NSManagedObject *managedObject;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic) NSInteger menuNumber;
@property (nonatomic) NSInteger cameraMode;

@property (nonatomic, strong) UIImagePickerController *imgPicker;
@property (nonatomic, strong) UIViewController *callBackViewController;

@end