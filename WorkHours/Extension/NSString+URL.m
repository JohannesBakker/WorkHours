//
//  NSString+URL.m
//  WellnessChallenge
//
//  Created by Donald Pae on 4/14/15.
//  Copyright (c) 2015 Calorie Cloud. All rights reserved.
//

#import "NSString+URL.h"

@implementation NSString(URL)

- (NSString *)stringByAddingPercentEncodingForURLQueryValue {
    NSMutableCharacterSet *charaterSet = [NSMutableCharacterSet alphanumericCharacterSet];
    [charaterSet addCharactersInString:@"-._~"];
    return [self stringByAddingPercentEncodingWithAllowedCharacters:charaterSet];
}

@end
