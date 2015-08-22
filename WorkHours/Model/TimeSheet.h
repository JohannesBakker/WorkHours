//
//  TimeSheet.h
//  WorkHours
//
//  Created by Admin on 7/20/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>

// work time in day -  07:30 AM ~ 5:00 PM
#define kDayWorkTime_BeginHour        07
#define kDayWorkTime_BeginMin          00
#define kDayWorkTime_EndHour        17
#define kDayWorkTime_EndMin          00


@interface TimeSheet : NSObject

@property (nonatomic) int labourID;                                                                   // labour record Id
@property (nonatomic, retain) NSDate *startTime;                                       // timesheet start time  yyyy-MM-dd HH:mm:ss
@property (nonatomic, retain) NSDate *endTime;                                       // timesheet end time     yyyy-MM-dd HH:mm:ss
@property (nonatomic) int jobID;                                                                   // Job ID
@property (nonatomic, retain) NSString *companyName;                                       // company name
@property (nonatomic) int labourTypeID;                                                                   // labour basis id
@property (nonatomic, retain) NSString *jobDescription;                                       // description



- (void)initWithParam:(int)labourId starttime:(NSString*)starttime endtime:(NSString*)endtime jobId:(int)jobId company:(NSString*)company labourTypeId:(int)labourTypeId jobNotes:(NSString*)jobNotes ;

- (void)initWithParam:(int)labourId startDateTime:(NSDate*)startDateTime endDateTime:(NSDate*)endDateTime jobId:(int)jobId company:(NSString*)company labourTypeId:(int)labourTypeId jobNotes:(NSString*)jobNotes;

@end




//--------------------------------------
//  Timesheets per day
//--------------------------------------

@interface TimeSheetPerDay : NSObject

@property (nonatomic, retain) NSDate *dayDate;
@property (nonatomic, retain) NSMutableArray *arrTimesheets;

- (void)initWithParam:(NSDate *)selDate arrTimeSheets:(NSMutableArray *)arrTimeSheets;
- (BOOL)isValidTimesheetAdding:(TimeSheet *)newTimesheet;
- (void)addNewTimesheet:(TimeSheet *)newTimesheet;


@end

