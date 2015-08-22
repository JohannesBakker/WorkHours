//
//  AppContext.m
//
//  Created by Admin on 2/10/15.
//  Copyright (c) 2015 RuiFeng. All rights reserved.
//

#import "AppContext.h"
#import "AppDelegate.h"

@implementation AppContext

+ (instancetype)sharedInstance {
    static dispatch_once_t once;
    static id sharedInstance;
    
    dispatch_once(&once, ^
                  {
                      sharedInstance = [self new];
                  });
    
    return sharedInstance;
}

- (void) saveSession:(NSString *)session {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject: session forKey:@"session"];
    [defaults synchronize];
}

- (NSString *)loadSession; {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *savedSession = [defaults stringForKey:@"session"];
    
    return savedSession;
}

- (void)saveUserID:(int)userID {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@(userID) forKey:@"userID"];
    [defaults synchronize];
}

- (int)loadUserID {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    int savedUserID = (int)[defaults integerForKey:@"userID"];
    
    return savedUserID;
}

- (void)saveUserFullName:(NSString *)userFullName {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject: userFullName forKey:@"userFullName"];
    [defaults synchronize];
}

- (NSString *)loadUserFullName {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *savedUserFullName = [defaults stringForKey:@"userFullName"];
    
    return savedUserFullName;
}

- (void)saveUserName:(NSString *)userName {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject: userName forKey:@"userName"];
    [defaults synchronize];
}

- (NSString *)loadUserName {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *savedUserName = [defaults stringForKey:@"userName"];
    
    return savedUserName;
}


- (void)saveUserLocationLat:(double)latitude {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@(latitude) forKey:@"lat"];
    [defaults synchronize];
}

- (double)loadUserLocationLat {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    double latitude = (double)[defaults doubleForKey:@"lat"];
    
    return latitude;
}

- (void)saveUserLocationLng:(double)longitude {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@(longitude) forKey:@"lng"];
    [defaults synchronize];
}

- (double)loadUserLocationLng {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    double longitude = (double)[defaults doubleForKey:@"lng"];
    
    return longitude;
}


@end
