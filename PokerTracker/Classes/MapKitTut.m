//
//  MapKitTut.m
//  PokerTracker
//
//  Created by Rick Medved on 1/20/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "MapKitTut.h"
#import "NSArray+ATTArray.h"

@implementation AddressAnnotation

@synthesize coordinate;
-(NSString *)subtitle
{
	return @"Sub";
}
-(NSString *)title
{
	return @"title";
}
-(id)initWithCoordinate:(CLLocationCoordinate2D) c
{
	coordinate=c;
	NSLog(@"%f %f", c.latitude, c.longitude);
	return self;
}

@end

@implementation MapKitTut
@synthesize mapView, lat, lng, casino;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/

- (IBAction) mapPressed: (id) sender
{
	
	NSArray *items = [casino componentsSeparatedByString:@"|"];
	NSString *address = [NSString stringWithFormat:@"%@+%@+%@+%@", [items stringAtIndex:8], [items stringAtIndex:2], [items stringAtIndex:3], [items stringAtIndex:9]];
	
	
	NSString *urlStr = [NSString stringWithFormat:@"http://maps.google.com/maps?q=%@", [address stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlStr]];
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	[self showAddress];
	[self setTitle:@"Map"];

    if(casino!=nil) {
        UIBarButtonItem *homeButton = [[UIBarButtonItem alloc] initWithTitle:@"Directions" style:UIBarButtonItemStylePlain target:self action:@selector(mapPressed:)];
        self.navigationItem.rightBarButtonItem = homeButton;
    }
}

- (IBAction) showAddress
{
	
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    span.latitudeDelta=0.2;
    span.longitudeDelta=0.2;
	
    CLLocationCoordinate2D location = mapView.userLocation.coordinate;
	
	location.latitude = lat;
	location.longitude = lng;
	if(lat==0) {
		location.latitude = 38.898748 ;
		location.longitude = -77.037684;
	}
    region.span=span;
    region.center=location;
	
    if(addAnnotation != nil)
    {
        [mapView removeAnnotation:addAnnotation];
        addAnnotation = nil;
    }
	
    addAnnotation = [[AddressAnnotation alloc] initWithCoordinate:location];
    
    [mapView addAnnotation:addAnnotation];
	
    [mapView setRegion:region animated:TRUE];
    [mapView regionThatFits:region];
    //[mapView selectAnnotation:mLodgeAnnotation animated:YES];
}


- (MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation: annotation
{
    MKPinAnnotationView *annView=[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"currentloc"];
    annView.pinColor = MKPinAnnotationColorGreen;
    annView.animatesDrop=TRUE;
    annView.canShowCallout = YES;
    annView.calloutOffset = CGPointMake(-5, 5);
    return annView;
}







@end
