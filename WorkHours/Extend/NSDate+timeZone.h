//
//  NSDate+timeZone.h
//  WorkHours
//
//  Created by Admin on 5/26/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate(timeZone)

- (NSDate *)toLocalTime;
- (NSDate *)toGlobalTime;

@end
