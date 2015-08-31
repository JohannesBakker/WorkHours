//
//  UserContext.h
//  WorkHours
//
//  Created by Admin on 7/3/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TimeSheet.h"

#define kTestMode           YES //YES //NO

// User location refresh timer interval :  30 mins
#if (kTestMode == YES)
    #define kLocationRecordingIntervalMins                  (2)
#else
    #define kLocationRecordingIntervalMins                  (30)
#endif

#define kLocationRecordingIntervalSec                (60 * kLocationRecordingIntervalMins)

// distance offset for equal location (unit : m)
#define kDistanceOffset                         (30)

#define kLocalPushNotificationIntervalSec   (10)

@protocol PinMapDelegate;
@protocol NewEventWindowDelegate;

@interface UserContext : NSObject {
    
}



+ (instancetype)sharedInstance;



@property (nonatomic, retain) NSMutableArray *arrLabourType;

//  arrUserPins : array of UserPin for user location
// used in map view
@property (nonatomic, retain) NSMutableArray *arrUserPins;

// used in calendar view
//      object key : date (yyyy-MM-dd)
//      object contetns : array of timesheet
@property (nonatomic, retain) NSMutableDictionary *dictTimesheets;



@property (nonatomic) BOOL isAppBackground;     // YES : in Background,   NO : in Foreground
@property (nonatomic) BOOL isTestMode;
@property (nonatomic) BOOL isNewEventWindow;

@property (weak, nonatomic) NSObject <PinMapDelegate> *mapDelegate;
@property (weak, nonatomic) NSObject <NewEventWindowDelegate> *addEventWindowDelegate;

- (void)initUserContext;

- (void)initLabourTypeArray:(NSMutableArray *)arrType;
- (void)initUserPinArray:(NSMutableArray *)arrPins;

- (void)addTimesheets:(NSMutableArray *)arrSheets;
- (void)addTimesheets:(NSDate *)date arrSheets:(NSMutableArray *)arrSheets;
- (void)removeTimesheets:(NSDate *)date;
- (void)removeTimesheets:(NSDate *)beginDate endDate:(NSDate*)endDate;

- (TimeSheet *)getCoveredTimesheet:(NSDate *)pinCreateTime;
- (NSArray *)getTimesheets:(NSDate *)date;
- (NSUInteger)getTimesheetsCount:(NSDate *)date;
- (NSUInteger)getTimesheetsConnections:(NSDate *)date;


@end


// PinMap delegate for pin displaying in map
@protocol PinMapDelegate
@optional
- (void)displayUserLocation;
- (void)displayPins;
- (void)gotoNewEventWindow:(NSDate *)startTime endTime:(NSDate*)endTime initLabourTypeId:(int)initLabourTypeId;

@end

// NewEventWindow delegate for add new event window
@protocol NewEventWindowDelegate
@optional
- (void)updateNewEventWindow:(NSDate *)eventStartTime endTime:(NSDate*)eventEndTime initLabourTypeId:(int)labourTypeId;
@end