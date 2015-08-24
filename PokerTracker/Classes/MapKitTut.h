//
//  MapKitTut.h
//  PokerTracker
//
//  Created by Rick Medved on 1/20/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface AddressAnnotation : NSObject <MKAnnotation>
{
	CLLocationCoordinate2D coordinate;
	NSString *title;
	NSString *subTitle;
	
}
@end

@interface MapKitTut : UIViewController {

	IBOutlet MKMapView *mapView;
	AddressAnnotation *addAnnotation;
	float lat;
	float lng;
	NSString *casino;
}

-(IBAction) showAddress;
- (IBAction) mapPressed: (id) sender;

@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic, strong) NSString *casino;
@property (nonatomic) float lat;
@property (nonatomic) float lng;

@end

