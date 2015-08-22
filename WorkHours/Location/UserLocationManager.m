//
//  LocationManager.m
//  WorkHours
//
//  Created by Admin on 7/16/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import "UserLocationManager.h"

static UserLocationManager *_sharedUserLocationManager = nil;
static double test_location_lat = -33.86;
static double test_location_lon = 151.20;


@interface UserLocationManager() {
    CLLocationManager *locationManager;
    CLLocation *currentLocation;
}

@end

@implementation UserLocationManager

@synthesize delegate;
@synthesize isTestMode;

+ (UserLocationManager *)sharedManager
{
    if (_sharedUserLocationManager == nil) {
        _sharedUserLocationManager = [[UserLocationManager alloc] init];
    }
    return _sharedUserLocationManager;
}

// GPS locaiton
- (void)initLocationManager
{
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.pausesLocationUpdatesAutomatically = NO;
    locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    
    currentLocation = [[CLLocation alloc] init];
    
    isTestMode = NO;
}

- (void)requestAuthorization
{
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    
    // If the status is denied or only granted for when in use, display an alert
    if (status == kCLAuthorizationStatusDenied
        || status == kCLAuthorizationStatusRestricted ) {
        NSString *title;
        
        title = @"Location services are off";
        NSString *message = @"To use location service you must turn on in the location Services Settings";
        
        UIAlertView *alertView = [ [UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Settings", nil ];
        
        [alertView show];
    }
    else {
        //
        [locationManager requestAlwaysAuthorization];
    }
}

- (CLLocation *)getUserLocation {
    return currentLocation;
}

// alert view
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 1)
    {
        // Send the user to the Settings for this app
        NSURL *settingsURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        [[UIApplication sharedApplication] openURL:settingsURL];
    }
}



#pragma mark LocationManager Delegate
-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    
    if (status == kCLAuthorizationStatusAuthorizedAlways || status == kCLAuthorizationStatusAuthorizedWhenInUse)
    {
        [locationManager startUpdatingLocation];
    } else {
        NSLog(@"Location services is not enabled");
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    if (locations != nil && [locations count] != 0) {
        currentLocation = [locations lastObject];
        
        if (isTestMode) {
            currentLocation = [[CLLocation alloc] initWithLatitude:test_location_lat longitude:test_location_lon];
        }
    }
    
    if ([delegate respondsToSelector:@selector(updatedUserLocation:)])
    {
        [delegate updatedUserLocation:currentLocation];
    }

}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    currentLocation = newLocation;
    
    if (isTestMode) {
        currentLocation = [[CLLocation alloc] initWithLatitude:test_location_lat longitude:test_location_lon];
    }
    
    if ([delegate respondsToSelector:@selector(updatedUserLocation:)])
    {
        [delegate updatedUserLocation:currentLocation];
    }
}


@end
