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
    #define kLocationRecordingIntervalMins                  (5)
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

//  arrTimesheetByDate : array of TimeSheetPerDay for user date
// used in calendar view
@property (nonatomic, retain) NSMutableArray *arrTimesheetByDate;

//  arrUserPins : array of UserPin for user location
// used in map view
@property (nonatomic, retain) NSMutableArray *arrUserPins;

// in use only map view for user pin
@property (nonatomic, retain) NSMutableArray *arrTodayTimesheets;


@property (nonatomic) BOOL isAppBackground;     // YES : in Background,   NO : in Foreground
@property (nonatomic) BOOL isTestMode;
@property (nonatomic) BOOL isNewEventWindow;

@property (weak, nonatomic) NSObject <PinMapDelegate> *mapDelegate;
@property (weak, nonatomic) NSObject <NewEventWindowDelegate> *addEventWindowDelegate;


- (void)initLabourTypeArray:(NSMutableArray *)arrType;
- (void)initTimesheetByDateArray:(NSMutableArray *)arrTimesheetPerDay;
- (void)initTodayTimesheets:(NSMutableArray *)arrTimeSheets;
- (void)initUserPinArray:(NSMutableArray *)arrPins;

- (void)addTimesheet:(TimeSheet *)oneSheet;
- (void)addDayTimesheets:(TimeSheetPerDay *)dayTimesheets;

- (NSMutableArray*)getDayTimesheets:(NSDate *)date;
- (TimeSheet *)getCoveredTimesheet:(NSDate *)pinCreateTime;

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