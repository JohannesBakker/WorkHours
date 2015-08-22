//
//  LocationManager.h
//  WorkHours
//
//  Created by Admin on 7/16/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GoogleMaps/GoogleMaps.h>

@protocol UserLocationManagerDelegate;

@interface UserLocationManager : NSObject <CLLocationManagerDelegate>

+ (UserLocationManager *)sharedManager;

@property (weak, nonatomic) NSObject <UserLocationManagerDelegate> *delegate;
@property (nonatomic) BOOL isTestMode;

- (void)initLocationManager;
- (void)requestAuthorization;
- (CLLocation *)getUserLocation;

@end



@protocol UserLocationManagerDelegate <NSObject>
@optional

- (void)updatedUserLocation:(CLLocation *)newlocation;

@end
