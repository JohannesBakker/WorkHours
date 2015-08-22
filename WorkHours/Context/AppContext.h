//
//  AppContext.h
//
//  Created by Admin on 2/10/15.
//  Copyright (c) 2015 RuiFeng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppContext : NSObject {
}

@property (nonatomic) BOOL isLoginSuccess;

+ (instancetype)sharedInstance;

- (void)saveSession:(NSString *)session;
- (NSString *)loadSession;

- (void)saveUserID:(int)userID;
- (int)loadUserID;

- (void)saveUserFullName:(NSString *)userFullName;
- (NSString *)loadUserFullName;

- (void)saveUserName:(NSString *)userName;
- (NSString *)loadUserName;

- (void)saveUserLocationLat:(double)latitude;
- (double)loadUserLocationLat;

- (void)saveUserLocationLng:(double)longitude;
- (double)loadUserLocationLng;

@end
