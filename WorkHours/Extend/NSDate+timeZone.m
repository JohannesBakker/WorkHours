//
//  NSDate+timeZone.m
//  WorkHours
//
//  Created by Admin on 5/26/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import "NSDate+timeZone.h"

@implementation NSDate(timeZone)

- (NSDate *)toLocalTime
{
    NSTimeZone *tz = [NSTimeZone defaultTimeZone];
    NSInteger seconds = [tz secondsFromGMTForDate: self];
    return [NSDate dateWithTimeInterval: seconds sinceDate: self];
}

- (NSDate *)toGlobalTime
{
    NSTimeZone *tz = [NSTimeZone defaultTimeZone];
    NSInteger seconds = -[tz secondsFromGMTForDate: self];
    return [NSDate dateWithTimeInterval: seconds sinceDate: self];
}

@end
