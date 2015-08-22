//
//  UserInfo.m
//  WorkHours
//
//  Created by Admin on 7/20/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import "UserInfo.h"

@implementation UserInfo

@synthesize userID, firstName, lastName;

- (void)initWithParam:(int)userId firstname:(NSString *)firstname lastname:(NSString *)lastname {
    userID = userId;
    firstName = [NSString stringWithFormat:@"%@", firstname];
    lastName = [NSString stringWithFormat:@"%@", lastname];
}

@end
