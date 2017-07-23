//
//  ChangeIconVC.m
//  PokerTracker
//
//  Created by Rick Medved on 7/20/17.
//
//

#import "ChangeIconVC.h"

@interface ChangeIconVC ()

@end

@implementation ChangeIconVC

- (void)viewDidLoad {
    [super viewDidLoad];
	[self setTitle:@"Change Icons"];
	
	self.navigationItem.rightBarButtonItem = [ProjectFunctions UIBarButtonItemWithIcon:[NSString fontAwesomeIconStringForEnum:FAFloppyO] target:self action:@selector(savePressed)];
	
	self.icons = [[NSMutableArray alloc] initWithArray:[NSArray arrayWithObjects:
														self.image5a,
														self.image5b,
														self.image5c,
														self.image5d,
														self.image4a,
														self.image4b,
														self.image4c,
														self.image4d,
														self.image3a,
														self.image3b,
														self.image3c,
														self.image3d,
														self.image2a,
														self.image2b,
														self.image2c,
														self.image2d,
														self.image1a,
														self.image1b,
														self.image1c,
														self.image1d,
														self.image0a,
														self.image0b,
														self.image0c,
														self.image0d,
														nil]];
	
	int playerType=0;
	NSString *letter = @"";
	for(UIImageView *imageView in self.icons) {
		imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"playerType%d%@.png", playerType, letter]];
		if([letter isEqualToString:@""]) {
			letter=@"b";
		} else if([letter isEqualToString:@"b"]) {
			letter=@"c";
		} else if([letter isEqualToString:@"c"]) {
			letter=@"d";
		} else {
			letter=@"";
			playerType++;
		}
	}
	self.mainSegment.selectedSegmentIndex = [[ProjectFunctions getUserDefaultValue:@"IconGroupNumber"] intValue];
	[self setupImages];
}

-(void)setupImages {
	int group=0;
	int i=0;
	for(UIImageView *imageView in self.icons) {
		if(i%4==self.mainSegment.selectedSegmentIndex)
			imageView.alpha=1;
		else
			imageView.alpha=.5;
		if(i++%4==0)
			group++;
	}
}

-(void)savePressed {
	[ProjectFunctions setUserDefaultValue:[NSString stringWithFormat:@"%d", (int)self.mainSegment.selectedSegmentIndex] forKey:@"IconGroupNumber"];
	[ProjectFunctions showAlertPopup:@"Icons Changed" message:@""];
	[self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)segmentChanged:(id)sender {
	[self setupImages];
}

@end
