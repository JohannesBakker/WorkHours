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

#define kAlertType_AwayLocation    1
#define kAlertType_TodayWorking    2
#define kAlertType_NoTimesheet      3


@interface AppDelegate () <UserLocationManagerDelegate> {
    int nAlertViewType;
    double prevUserLat;
    double prevUserLon;
    
    AppContext *appContext;
    UserContext *userContext;
    
    
    UserLocationManager *userLocationManager;
    
    NSTimer *locationTImer;
    NSTimeInterval intervalSecs;
    
    NSDate *prevRecordTime;
    
    NSDate *todayWorkTimeBegin;
    NSDate *todayWorkTimeEnd;
    
    BOOL isTestMode;
    BOOL isAlertDisplay;
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

    // init alert variable
    isAlertDisplay = NO;

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
        
        
        // todo timer start
        locationTImer = [NSTimer scheduledTimerWithTimeInterval:intervalSecs
                                                                    target:self
                                                       selector:@selector(locationTimerFunc:)
                                                                  userInfo:nil
                                                                   repeats:YES];

    }
    else {
        // background mode processing
        userContext.isAppBackground = YES;
        
        // todo timer stop
        [locationTImer invalidate];
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
        [locationTImer invalidate];
        
        intervalSecs = kLocationRecordingIntervalSec;
        locationTImer = [NSTimer scheduledTimerWithTimeInterval:intervalSecs
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
    
    if (isAlertDisplay) {
        return;
    }
    
    TimeSheet *coveredTimesheet = [userContext getCoveredTimesheet:currTime];
    NSString *title = @"Are you working?";
    NSString *message = @"No : Don't work,  Yes : Working";
    
    double currLat = [appContext loadUserLocationLat];
    double currLon = [appContext loadUserLocationLng];
    
    nAlertViewType = kAlertType_AwayLocation;
    
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
                    nAlertViewType = kAlertType_AwayLocation;
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
                nAlertViewType = kAlertType_TodayWorking;
                strNotifaction = [NSString stringWithFormat:@"%@", @"Are you working today?"];
                break;
        }
    }
    else {
//        return YES;
        
        title = @"Please allocate your time to a Job";
        message = @"No : Don't allocate,  Yes : allocate";
        
        nAlertViewType = kAlertType_NoTimesheet;
        strNotifaction = [NSString stringWithFormat:@"%@", @"Please allocate your time to a Job"];
    }
    
    // timer stop, and alert display
    [locationTImer invalidate];
    
    
    // display alert view
    UIAlertView *alertView = [ [UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"YES", nil ];
    
    [alertView show];
    
    isAlertDisplay = YES;
}


// alert view
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    double lat = [appContext loadUserLocationLat];
    double lon = [appContext loadUserLocationLng];

    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    dateFormat.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    
    isAlertDisplay = NO;
    
    if (buttonIndex == 1) {
        
        if ((nAlertViewType == kAlertType_AwayLocation)
            || (nAlertViewType == kAlertType_TodayWorking)
            || (nAlertViewType == kAlertType_NoTimesheet)) {
            
            [[ServerManager sharedManager] insertUserPin:[appContext loadUserID]
                                                     lat:lat
                                                     lon:lon
                                        creationDateTime:prevRecordTime success:^(BOOL result)
             {
             } failure:^(NSString *failure)
             {
                 NSLog(@"location recording failed, %@ on %@\n", failure, [dateFormat stringFromDate:prevRecordTime]);
             }];
            
            intervalSecs = kLocationRecordingIntervalSec;
            locationTImer = [NSTimer scheduledTimerWithTimeInterval:intervalSecs
                                                             target:self
                                                           selector:@selector(locationTimerFunc:)
                                                           userInfo:nil
                                                            repeats:YES];
            
            if (nAlertViewType == kAlertType_NoTimesheet) {
                NSDate *startTime = [NSDate date];
                NSDate *endTime = [[NSDate alloc] initWithTimeInterval:3600 sinceDate:startTime];
                [self gotoNewEventWindow:startTime endTime:endTime initLabourTypeId:kLabourTypeId_Labour];
            }
        }
    }
    else {
        if (nAlertViewType == kAlertType_TodayWorking) {
            
            NSString *startDateTime = [NSString stringWithFormat:@"%04d-%02d-%02d %02d:%02d:00",
                                       (int)prevRecordTime.year, (int)prevRecordTime.month, (int)prevRecordTime.day, kDayWorkTime_BeginHour, kDayWorkTime_BeginMin];
            NSString *endDateTime = [NSString stringWithFormat:@"%04d-%02d-%02d %02d:%02d:00",
                                     (int)prevRecordTime.year, (int)prevRecordTime.month, (int)prevRecordTime.day, kDayWorkTime_EndHour, kDayWorkTime_EndMin];
            
            NSDate *startTime = [[NSDate alloc] init];
            startTime = [dateFormat dateFromString:startDateTime];
            
            NSDate *endTime = [[NSDate alloc] init];
            endTime = [dateFormat dateFromString:endDateTime];
            
            [self gotoNewEventWindow:startTime endTime:endTime initLabourTypeId:kLabourTypeId_Sick];
        }
        
    }
}

- (void)gotoNewEventWindow:(NSDate *)startTime endTime:(NSDate *)endTime initLabourTypeId:(int)initLabourTypeId
{
    if (userContext.isNewEventWindow) {
        
        // update event window
        if (userContext.addEventWindowDelegate) {
            if ([userContext.addEventWindowDelegate respondsToSelector:@selector(updateNewEventWindow:endTime:initLabourTypeId:)]) {
                [userContext.addEventWindowDelegate updateNewEventWindow:startTime endTime:endTime initLabourTypeId:initLabourTypeId];
            }
        }
    }
    else {
        // goto new event window
        if (userContext.mapDelegate) {
            if ([userContext.mapDelegate respondsToSelector:@selector(gotoNewEventWindow:endTime:initLabourTypeId:)]) {
                [userContext.mapDelegate gotoNewEventWindow:startTime endTime:endTime initLabourTypeId:initLabourTypeId];
            }
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
            // lownload timesheet
            [self downloadTimesheets:prevRecordTime];
            [self displayUserPins];
            
        } failure:^(NSString *failure)
         {
             NSLog(@"location recording failed, %@ on %@\n", failure, [dateFormat stringFromDate:prevRecordTime]);
             
             // lownload timesheet
             [self downloadTimesheets:prevRecordTime];
             [self displayUserPins];
         }];
        
        return;
    }
    
    // display notification repeatly
    if (userContext.isAppBackground == YES && isAlertDisplay == YES) {
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
         [userContext initTodayTimesheets:arrSheets];
         
         [self checkLocationNotification:selectDate];
         
     } failure:^(NSString *failure)  {
         [self checkLocationNotification:selectDate];
     }];
}

- (void)checkLocationNotification:(NSDate *)selectDate {
    [self checkUserLocation:selectDate];
    
    if (userContext.isAppBackground == YES && isAlertDisplay == YES) {
        // display push notification and return
        [self displayPushNotification];
    }
    
}


@end
