//
//  UserPin.h
//  WorkHours
//
//  Created by Admin on 7/20/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserPin : NSObject

@property (nonatomic) int locationID;                                                     // user location id
@property (nonatomic) int userID;                                                                   // user id
@property (nonatomic, retain) NSDate *creationTime;                                    // creation time   yyyy-MM-dd HH:mm:ss
@property (nonatomic) double lat;                                                                   // latitude of pin location
@property (nonatomic) double lon;                                                                  // longitude of pin location


- (void)initWithParam:(int)userLocationId userId:(int)userId creationtime:(NSString *)creationtime pinLat:(double)pinLat pinLon:(double)pinLon;

- (void)initWithParam:(int)userLocationId userId:(int)userId creationDateTime:(NSDate *)creationDateTime pinLat:(double)pinLat pinLon:(double)pinLon;

@end
