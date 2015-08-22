//
//  UserPin.m
//  WorkHours
//
//  Created by Admin on 7/20/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import "UserPin.h"
#import "NSDate+Utilities.h"

@implementation UserPin

@synthesize locationID, userID, creationTime, lat, lon;

- (void)initWithParam:(int)userLocationId userId:(int)userId creationtime:(NSString *)creationtime pinLat:(double)pinLat pinLon:(double)pinLon {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];

    
    locationID = userLocationId;
    userID = userId;
    lat = pinLat;
    lon = pinLon;
    creationTime = [[NSDate alloc] init];
    creationTime = [dateFormatter dateFromString:creationtime];
}


- (void)initWithParam:(int)userLocationId userId:(int)userId creationDateTime:(NSDate *)creationDateTime pinLat:(double)pinLat pinLon:(double)pinLon {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    
    locationID = userLocationId;
    userID = userId;
    lat = pinLat;
    lon = pinLon;
    creationTime = [[NSDate alloc] initWithTimeInterval:0 sinceDate:creationDateTime];
}

@end
