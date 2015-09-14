//
//  UserContext.h
//  WorkHours
//
//  Created by Admin on 7/3/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TimeSheet.h"
#import "Job.h"
#import "LabourType.h"

#define kTestMode           NO //YES //NO

// User location refresh timer interval :  30 mins
#if (kTestMode == YES)
    #define kLocationRecordingIntervalMins                  (2)
#else
    #define kLocationRecordingIntervalMins                  (30)
#endif

#define kLocationRecordingIntervalSec                (60 * kLocationRecordingIntervalMins)

// distance offset for equal location (unit : m)
#define kDistanceOffset                         (30)

#define kLocalPushNotificationIntervalSec    (10)

// ViewController type
enum {
    VC_LOGIN = 1,           // LoginViewController
    VC_HOME,                // HomeViewController
    VC_ADDWORK,             // AddWorkViewController
    VC_SEL_LABOUR_TYPE,     // SelLabourTypeViewController
    VC_SEL_ATTENDEES,       // SelAttendeesViewController
    VC_JOB_SELECTION,       // JobSelectionViewController
};

// Alert type
enum {
    ALERT_AWAY_LOCATION = 1,    // Away Location
    ALERT_TODAY_WORKING,        // Today working
    ALERT_NO_TIMESHEET,         // No Timesheet
};

@protocol PinMapDelegate;
@protocol NewEventWindowDelegate;
@protocol HomeViewDelegate;


//*******************************
//******    UserContext *********
//*******************************
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

//  arrJobs : array of Jobs for user near
@property (nonatomic, retain) NSMutableArray *arrJobs;



@property (nonatomic) BOOL isAppBackground;     // YES : in Background,   NO : in Foreground
@property (nonatomic) BOOL isTestMode;
@property (nonatomic) BOOL isNewEventWindow;
@property (nonatomic) BOOL isAlertReserved;      // YES : Alert reserved
@property (nonatomic) BOOL isAlertDisplay;      // YES : Alert display


@property (weak, nonatomic) NSObject <PinMapDelegate> *mapDelegate;
@property (weak, nonatomic) NSObject <NewEventWindowDelegate> *addEventWindowDelegate;
@property (weak, nonatomic) NSObject <HomeViewDelegate> *homeViewDelegate;

- (void)initUserContext;

- (void)initLabourTypeArray:(NSMutableArray *)arrType;
- (void)initUserPinArray:(NSMutableArray *)arrPins;
- (void)initJobs:(NSMutableArray *)arrJobList;

- (LabourType*)getLabourType:(int)typeId;
- (Job *)getJob:(int)jobId;

- (void)addTimesheets:(NSMutableArray *)arrSheets;
- (void)addTimesheets:(NSDate *)date arrSheets:(NSMutableArray *)arrSheets;
- (void)removeTimesheets:(NSDate *)date;
- (void)removeTimesheets:(NSDate *)beginDate endDate:(NSDate*)endDate;

- (TimeSheet *)getCoveredTimesheet:(NSDate *)pinCreateTime;
- (NSArray *)getTimesheets:(NSDate *)date;
- (NSUInteger)getTimesheetsCount:(NSDate *)date;
- (NSUInteger)getTimesheetsConnections:(NSDate *)date;

- (void)setActiveVC:(int)vcType;
- (int)getActiveVC;
- (BOOL)validAlertDisplay;
- (void)reserveAlert:(int)alertType title:(NSString*)title msg:(NSString*)msg;
- (void)releaseAlert;
- (void)displayAlert;

@end

//*******************************
//******    PinMapDelegate ******
//*******************************

// PinMap delegate for pin displaying in map
@protocol PinMapDelegate
@optional
- (void)displayUserLocation;
- (void)displayPins;
- (void)gotoNewEventWindow:(NSDate *)startTime endTime:(NSDate*)endTime initLabourTypeId:(int)initLabourTypeId;
- (void)gotoEditEventWindow:(TimeSheet *)sheet;

@end

//***************************************
//******    NewEventWindowDelegate ******
//***************************************

// NewEventWindow delegate for add new event window
@protocol NewEventWindowDelegate
@optional
- (void)updateNewEventWindow:(NSDate *)eventStartTime endTime:(NSDate*)eventEndTime initLabourTypeId:(int)labourTypeId;
@end

//*********************************
//******    HomeViewDelegate ******
//*********************************

// HomeView Delegate for HomeView Controller
@protocol HomeViewDelegate
@optional
- (void)reserveAlert:(int)alertType title:(NSString*)title msg:(NSString*)msg;
- (void)releaseAlert;
- (void)displayAlert;
@end

