//
//  LocationGetter.m
//  BASE
//
//

#import "LocationGetter.h"

// This is a singleton class, see below
static LocationGetter *sharedInstance = nil;

@implementation LocationGetter

@synthesize locationManager, currentLocation;

- (id)init
{
	self = [super init];
	if (self != nil) {
		locationManager = [[CLLocationManager alloc] init];
		locationManager.delegate = self;
		locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
		// Set a movement threshold for new events.  meters
		locationManager.distanceFilter = 500;
	}
	return self;
}


// Delegate method from the CLLocationManagerDelegate protocol.
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
		   fromLocation:(CLLocation *)oldLocation
{
	{// diagnostics
		NSMutableString *update = [[NSMutableString alloc] init];
		
		// Timestamp
		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
		[dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
		[update appendFormat:@"%@\n\n", [dateFormatter stringFromDate:newLocation.timestamp]];
		
		// Horizontal coordinates
		if (signbit(newLocation.horizontalAccuracy)) {
			// Negative accuracy means an invalid or unavailable measurement
			[update appendString:(@"Latitude / Longitude unavailable")];
		} else {
			// CoreLocation returns positive for North & East, negative for South & West
			[update appendFormat:(@"Location: %.4f° %@, %.4f° %@"), // This format takes 4 args: 2 pairs of the form coordinate + compass direction
			 fabs(newLocation.coordinate.latitude), signbit(newLocation.coordinate.latitude) ? (@"South") : (@"North"),
			 fabs(newLocation.coordinate.longitude),	signbit(newLocation.coordinate.longitude) ? (@"West") : (@"East")];
			[update appendString:@"\n"];
			[update appendFormat:(@"(accuracy %.0f meters)"), newLocation.horizontalAccuracy];
		}
		[update appendString:@"\n\n"];
		
		// Altitude
		if (signbit(newLocation.verticalAccuracy)) {
			// Negative accuracy means an invalid or unavailable measurement
			[update appendString:(@"AltUnavailable")];
		} else {
			// Positive and negative in altitude denote above & below sea level, respectively
			[update appendFormat:(@"Altitude: %.2f meters %@"), fabs(newLocation.altitude),	(signbit(newLocation.altitude)) ? (@"BelowSeaLevel") : (@"AboveSeaLevel")];
			[update appendString:@"\n"];
			[update appendFormat:(@"(accuracy %.0f meters)"), newLocation.verticalAccuracy];
		}
		NSLog(@"%@", update);
	}
	
    // If it's a relatively recent event, turn off updates to save power
    NSDate* eventDate = newLocation.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    if (abs(howRecent) < 5.0)
    {
        [manager stopUpdatingLocation];
		
		self.currentLocation = newLocation;
		
        NSLog(@"latitude %+.6f, longitude %+.6f\n",
			   newLocation.coordinate.latitude,
			   newLocation.coordinate.longitude);
    }
    // else skip the event and process the next one.
}


#pragma mark ---- singleton object methods ----

// See "Creating a Singleton Instance" in the Cocoa Fundamentals Guide for more info

+ (LocationGetter *)sharedInstance {
    @synchronized(self) {
        if (sharedInstance == nil) {
            [[self alloc] init]; // assignment not done here
        }
    }
    return sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (sharedInstance == nil) {
            sharedInstance = [super allocWithZone:zone];
            return sharedInstance;  // assignment and return on first allocation
        }
    }
    return nil; // on subsequent allocation attempts return nil
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}


@end
