//
//  AppDelegate.m
//  WorkHours
//
//  Created by Admin on 5/12/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import "AppDelegate.h"
#import <Crashlytics/Crashlytics.h>
#import <GoogleMaps/GoogleMaps.h>
#import "AppContext.h"
#import "UserContext.h"
#import "UserLocationManager.h"
#import "NSDate+Utilities.h"
#import "ServerManager.h"
#import "SVProgressHUD+WorkHours.h"
#import "TimeSheet.h"
#import "LabourType.h"


@interface AppDelegate () <UserLocationManagerDelegate> {
    
    double prevUserLat;
    double prevUserLon;
    
    AppContext *appContext;
    UserContext *userContext;
    
    
    UserLocationManager *userLocationManager;
    
    NSTimer *locationTimer;
    NSTimeInterval intervalSecs;
    
    NSDate *prevRecordTime;
    
    NSDate *todayWorkTimeBegin;
    NSDate *todayWorkTimeEnd;
    
    BOOL isTestMode;
    NSDate *prevNotificationTime;
    
    NSString *strNotifaction;
}

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [Crashlytics startWithAPIKey:@"3e5c4861349fc8a3a2660e57379a12d3952d3001"];
    [GMSServices provideAPIKey:@"AIzaSyDq1Phu_xDyOSxsVNnmZk_nzHTOEuE8eO4"];
    
    
    // init app public variables
    [self initAppStatus];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    [self processMode:NO];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    [self processMode:YES];
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    // cancel all local notification
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}



// local functions
- (void)initAppStatus {
    appContext = [AppContext sharedInstance];
    userContext = [UserContext sharedInstance];
    
    userContext.isAppBackground = NO;
    userContext.isTestMode = kTestMode;
    userContext.isNewEventWindow = NO;
    
    [userContext initUserContext];

    // init alert variable
    userContext.isAlertDisplay = NO;

    strNotifaction = [[NSString alloc] init];
    
    isTestMode = userContext.isTestMode;
    

    
    // init user location manager
    {
        userLocationManager = [UserLocationManager sharedManager];
        [userLocationManager initLocationManager];
        userLocationManager.delegate = self;
        userLocationManager.isTestMode = userContext.isTestMode;
        [userLocationManager requestAuthorization];
    }
    
    
    prevRecordTime = [NSDate date];
    
    // init work begin/end time
    {
        NSDate *todayDate = [NSDate date];
        
        NSString *szWorkTimeBegin = [NSString stringWithFormat:@"%04d-%02d-%02d %02d:%02d:00",
                                     (int)todayDate.year, (int)todayDate.month, (int)todayDate.day, kDayWorkTime_BeginHour, kDayWorkTime_BeginMin];
        NSString *szWorkTimeEnd = [NSString stringWithFormat:@"%04d-%02d-%02d %02d:%02d:00",
                                   (int)todayDate.year, (int)todayDate.month, (int)todayDate.day, kDayWorkTime_EndHour, kDayWorkTime_EndMin];
        
        
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        
        todayWorkTimeBegin = [[NSDate alloc] init];
        todayWorkTimeEnd = [[NSDate alloc] init];
        
        todayWorkTimeBegin = [dateFormat dateFromString:szWorkTimeBegin];
        todayWorkTimeEnd = [dateFormat dateFromString:szWorkTimeEnd];
    }
    
    [self processMode:YES];
    
    // Registering notification type
    {
        UIUserNotificationType types = UIUserNotificationTypeBadge |
        UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
        
        UIUserNotificationSettings *mySettings =
        [UIUserNotificationSettings settingsForTypes:types categories:nil];
        
        [[UIApplication sharedApplication] registerUserNotificationSettings:mySettings];
    }
    
    // init previous time with current time
    prevNotificationTime = [NSDate date];
    
}


- (void)processMode:(BOOL)isEnterForegroundMode {
    
    if (isEnterForegroundMode) {
        // foreground mode processing
        userContext.isAppBackground = NO;
        
        NSDate *currDateTime = [NSDate date];
        
        intervalSecs = [currDateTime minutesAfterDate:prevRecordTime] * 60;
        
        if (intervalSecs < 60 || intervalSecs > kLocationRecordingIntervalSec) {
            intervalSecs = kLocationRecordingIntervalSec;
        }
        
        
        // timer start
        locationTimer = [NSTimer scheduledTimerWithTimeInterval:intervalSecs
                                                                    target:self
                                                       selector:@selector(locationTimerFunc:)
                                                                  userInfo:nil
                                                                   repeats:YES];
        
        if (userContext.isAlertReserved && !userContext.isAlertDisplay) {
            [userContext displayAlert];
        }
    }
    else {
        // background mode processing
        userContext.isAppBackground = YES;
        
        // todo timer stop
        [locationTimer invalidate];
    }
    
}

- (void)locationTimerFunc:(NSTimer *)theTimer
{
    NSLog(@"called locationTimerFunc \n");
    
    if (appContext.isLoginSuccess == NO)
        return;
    
    NSDate *currTime = [NSDate date];
    
    if (intervalSecs < kLocationRecordingIntervalSec)
    {
        // reset timer
        [locationTimer invalidate];
        
        intervalSecs = kLocationRecordingIntervalSec;
        locationTimer = [NSTimer scheduledTimerWithTimeInterval:intervalSecs
                                                         target:self
                                                       selector:@selector(locationTimerFunc:)
                                                       userInfo:nil
                                                        repeats:YES];
    }
    
    if ([todayWorkTimeBegin isLaterThanDate:currTime] || [todayWorkTimeEnd isEarlierThanDate:currTime]) {
        NSLog(@"Overflow time area\n");
        return;
    }
    
    [self checkUserLocation:currTime];
}


- (BOOL)isEqualLocation:(double)prevLat prevLon:(double)prevLon currLat:(double)currLat currLon:(double)currLon {
    
    CLLocation *prevLocation = [[CLLocation alloc]initWithLatitude:prevLat longitude:prevLon];
    CLLocation *currLocation = [[CLLocation alloc]initWithLatitude:currLat longitude:currLon];
    
    CLLocationDistance dist = [prevLocation distanceFromLocation:currLocation];
    
    if (dist > kDistanceOffset)
        return NO;
    
    return YES;
}

- (void)checkUserLocation:(NSDate *)currTime {
    
    TimeSheet *coveredTimesheet = [userContext getCoveredTimesheet:currTime];
    NSString *title = @"Are you working?";
    NSString *message = @"No : Don't work,  Yes : Working";
    
    double currLat = [appContext loadUserLocationLat];
    double currLon = [appContext loadUserLocationLng];
    
    int nAlertViewType = ALERT_AWAY_LOCATION;
    
    if (coveredTimesheet)
    {
        switch (coveredTimesheet.labourTypeID) {
            case kLabourTypeId_Labour:
                if ([self isEqualLocation:prevUserLat prevLon:prevUserLon currLat:currLat currLon:currLon]) {
                    // covered timesheet exist
                    return;
                }
                else {
                    
                    title = @"Are you working?";
                    message = @"No : Don't work,  Yes : Working";
                    nAlertViewType = ALERT_AWAY_LOCATION;
                    strNotifaction = [NSString stringWithFormat:@"%@", @"Are you working?"];
                }
                break;
                
            case kLabourTypeId_Holiday:
            case kLabourTypeId_PHoliday:
            case kLabourTypeId_Sick:
            case kLabourTypeId_LWP:
                return;
                
            default:
                title = @"Are you working today?";
                message = @"No : Sick,  Yes : working";
                nAlertViewType = ALERT_TODAY_WORKING;
                strNotifaction = [NSString stringWithFormat:@"%@", @"Are you working today?"];
                break;
        }
    }
    else {
        
        title = @"Please allocate your time to a Job";
        message = @"No : Don't allocate,  Yes : allocate";
        
        nAlertViewType = ALERT_NO_TIMESHEET;
        strNotifaction = [NSString stringWithFormat:@"%@", @"Please allocate your time to a Job"];
    }
    
    // reserve alert
    [userContext reserveAlert:nAlertViewType title:title msg:message];
    
    if (userContext.isAppBackground) {
        [self displayPushNotification];
    } else {
        if (!userContext.isAlertDisplay && [userContext validAlertDisplay]) {
            [userContext displayAlert];
        }
    }
}

- (void)displayPushNotification {

    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    
    if (localNotification == nil) {
        return;
    }
    else {
        localNotification.fireDate = nil;
        localNotification.alertAction = nil;
        localNotification.soundName = UILocalNotificationDefaultSoundName;
        localNotification.alertBody = strNotifaction;
        localNotification.alertAction = NSLocalizedString(@"Read Msg", nil);
        localNotification.applicationIconBadgeNumber = 1;
        localNotification.repeatInterval = 0;
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
        
        prevNotificationTime = [NSDate date];
    }
    
}

#pragma userlocationmanager delegate
- (void)updatedUserLocation:(CLLocation *)newlocation
{
    static BOOL isGettedLocation = NO;
    
    double new_lat = newlocation.coordinate.latitude;
    double new_lon = newlocation.coordinate.longitude;
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    dateFormat.dateFormat = @"yyyy-MM-dd hh:mm a";
    
    NSDate *currTime = [NSDate date];
    
    // save user location to app context
    prevUserLat = [appContext loadUserLocationLat];
    prevUserLon = [appContext loadUserLocationLng];
    
    
    [appContext saveUserLocationLat:newlocation.coordinate.latitude];
    [appContext saveUserLocationLng:newlocation.coordinate.longitude];
    
    if (appContext.isLoginSuccess == NO)
        return;
    
    if (isGettedLocation == NO) {
        isGettedLocation = YES;
        
        [[ServerManager sharedManager] insertUserPin:[appContext loadUserID]
                                                 lat:new_lat
                                                 lon:new_lon
                                    creationDateTime:prevRecordTime success:^(BOOL result)
        {
            // download timesheet
            [self downloadTimesheets:prevRecordTime];
            [self displayUserPins];
            
        } failure:^(NSString *failure)
         {
             NSLog(@"location recording failed, %@ on %@\n", failure, [dateFormat stringFromDate:prevRecordTime]);
             
             // download timesheet
             [self downloadTimesheets:prevRecordTime];
             [self displayUserPins];
         }];
        
        return;
    }
    
    // display notification repeatly
    if (userContext.isAppBackground && userContext.isAlertReserved) {
        if ([currTime timeIntervalSinceDate:prevNotificationTime] >= kLocalPushNotificationIntervalSec) {
            [self displayPushNotification];
        }
        
        return;
    }
    
    if ([currTime minutesAfterDate:prevRecordTime] < kLocationRecordingIntervalMins)
        return;
    
    prevRecordTime = [[NSDate alloc] initWithTimeInterval:0 sinceDate:currTime];
    
    [self downloadTimesheets:prevRecordTime];
}

- (void)displayUserPins
{
    // display user location in map
    if (userContext.mapDelegate) {
        if ([userContext.mapDelegate respondsToSelector:@selector(displayPins)]) {
            [userContext.mapDelegate displayPins];
        }
    }
}

- (void)downloadTimesheets:(NSDate *)selectDate {
    [[ServerManager sharedManager] getTimesheetByDate:[appContext loadUserID] selectedDate:selectDate success:^(NSMutableArray *arrSheets)
     {
         // set date timesheets
         [userContext addTimesheets:selectDate arrSheets:arrSheets];
         
         [self checkLocationNotification:selectDate];
         
     } failure:^(NSString *failure)  {
         [self checkLocationNotification:selectDate];
     }];
}

- (void)checkLocationNotification:(NSDate *)selectDate {
    [self checkUserLocation:selectDate];
    
    if (userContext.isAppBackground && userContext.isAlertReserved) {
        [self displayPushNotification];
    }
}



@end
