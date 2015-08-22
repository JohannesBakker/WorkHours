//
//  NSDictionary+URL.h
//  WellnessChallenge
//
//  Created by Donald Pae on 4/14/15.
//  Copyright (c) 2015 Calorie Cloud. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary(URL)

/// Build string representation of HTTP parameter dictionary of keys and objects
///
/// This percent escapes in compliance with RFC 3986
///
/// http://www.ietf.org/rfc/rfc3986.txt
///
/// :returns: String representation in the form of key1=value1&key2=value2 where the keys and values are percent escaped

- (NSString *)stringFromHttpParameters;

@end
