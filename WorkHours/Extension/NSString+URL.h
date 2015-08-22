//
//  NSString+URL.h
//  WellnessChallenge
//
//  Created by Donald Pae on 4/14/15.
//  Copyright (c) 2015 Calorie Cloud. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString(URL)

/// Percent escape value to be added to a URL query value as specified in RFC 3986
///
/// This percent-escapes all characters besize the alphanumeric character set and "-", ".", "_", and "~".
///
/// http://www.ietf.org/rfc/rfc3986.txt
///
/// :returns: Return precent escaped string.

- (NSString *)stringByAddingPercentEncodingForURLQueryValue;

@end
