//
//  NSString+Trim.m
//  WellnessChallenge
//
//  Created by Admin on 5/8/15.
//  Copyright (c) 2015 Calorie Cloud. All rights reserved.
//

#import "NSString+Trim.h"

@implementation NSString(Trim)

- (NSString *)stringByTrim {
    NSString *szRet;
    
    szRet = [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    return szRet;
}

@end
