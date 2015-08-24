//
//  LocationGetter.h
//  BASE
//
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>


@interface LocationGetter : NSObject <CLLocationManagerDelegate> {

	CLLocationManager *locationManager;
	CLLocation *currentLocation;
}

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *currentLocation;

+ (LocationGetter *)sharedInstance;

@end
