//
//  UserContext.m
//  WorkHours
//
//  Created by Admin on 7/3/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import "UserContext.h"
#import "NSDate+Utilities.h"

@interface UserContext() {
    
    NSSortDescriptor *timesheetSortDescriptor;
    NSMutableArray *timesheetSortDescriptors;
    
    NSSortDescriptor *userPinSortDescriptor;
    NSMutableArray *userPinSortDescriptors;
}

@end

@implementation UserContext

@synthesize arrLabourType;
@synthesize arrUserPins;
@synthesize dictTimesheets;
@synthesize arrJobs;


+ (instancetype)sharedInstance {
    static dispatch_once_t once;
    static id sharedInstance;
    
    dispatch_once(&once, ^
                  {
                      sharedInstance = [self new];
                  });
    
    return sharedInstance;
}


- (void)initUserContext {
    
    // init local variables
    dictTimesheets = [[NSMutableDictionary alloc] init];
    arrLabourType = [NSMutableArray array];
    arrUserPins = [NSMutableArray array];
    arrJobs = [NSMutableArray array];
    
    // init sort descriptor for timesheets
    timesheetSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"startTime"
                                                 ascending:YES];
    timesheetSortDescriptors = [NSMutableArray arrayWithObject:timesheetSortDescriptor];
    
    // init sor descriptor for userPins
    userPinSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"creationTime"
                                                          ascending:YES];
    userPinSortDescriptors = [NSMutableArray arrayWithObject:userPinSortDescriptor];
}

- (void)initLabourTypeArray:(NSMutableArray *)arrType
{
    if (arrType == nil) {
        arrLabourType = [NSMutableArray array];
    }
    else {
        arrLabourType = [[NSMutableArray alloc] initWithArray:arrType];
    }
}


- (void)initUserPinArray:(NSMutableArray *)arrPins
{
    if (arrUserPins) {
        [arrUserPins removeAllObjects];
    } else {
        arrUserPins = [NSMutableArray array];
    }
    
    if (arrPins) {
        NSArray *sortedArray = [arrPins sortedArrayUsingDescriptors:userPinSortDescriptors];
        [arrUserPins addObjectsFromArray:sortedArray];
    }
}

- (void)initJobs:(NSMutableArray *)arrJobList
{
    if (arrJobs) {
        [arrJobs removeAllObjects];
    } else {
        arrJobs = [NSMutableArray array];
    }
    
    if (arrJobList) {
        [arrJobs addObjectsFromArray:arrJobList];
    }
        
}

//********************************
//  functions of LabourType
//********************************
- (LabourType*)getLabourType:(int)typeId
{
    if (arrLabourType != nil && arrLabourType.count > 0) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"typeID == %d", typeId];
        NSArray *filteredArray = [arrLabourType filteredArrayUsingPredicate:predicate];
        
        if (filteredArray != nil && filteredArray.count > 0) {
            LabourType *selType = [filteredArray objectAtIndex:0];
            
            return selType;
        }
    }
    return nil;
}

//********************************
//  functions of Jobs
//********************************
- (Job *)getJob:(int)jobId
{
    if (jobId != kJobId_UNASSIGNED
        && arrJobs != nil
        && arrJobs.count > 0) {
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"jobID == %d", jobId];
        NSArray *filteredArray = [arrJobs filteredArrayUsingPredicate:predicate];
        
        if (filteredArray != nil && filteredArray.count > 0) {
            Job *selJob = [filteredArray objectAtIndex:0];
            
            return selJob;
        }
    }
    return nil;
}


//********************************
//  functions of Timesheets dictionary
//********************************
- (NSString *)keyOfTimesheets:(NSDate *)date
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    dateFormat.dateFormat = @"yyyy-MM-dd";
    
    NSString *szKey = [dateFormat stringFromDate:date];
    
    return szKey;
}

// get coverd timesheet with pin creating time
- (TimeSheet *)getCoveredTimesheet:(NSDate *)pinCreateTime
{
    NSArray *arrTimeSheets = [self getTimesheets:pinCreateTime];
    
    if (arrTimeSheets) {
        for (TimeSheet *sheet in arrTimeSheets) {
            
            if ( ([pinCreateTime isEqualToDate:sheet.startTime] || [pinCreateTime isLaterThanDate:sheet.startTime])
                && ([pinCreateTime isEqualToDate:sheet.endTime] || [pinCreateTime isEarlierThanDate:sheet.endTime])  )
            {
                return sheet;
            }
        }
    }
    
    return nil;
}

// add timesheets for all timesheets
- (void)addTimesheets:(NSMutableArray *)arrSheets
{
    if (arrSheets == nil)
        return;

    for (TimeSheet *oneSheet in arrSheets) {
        if (oneSheet == nil)
            continue;
        
        // get Timesheet array on timesheet dictionary
        NSString *szKey = [self keyOfTimesheets:oneSheet.startTime];
        NSMutableArray *arrTimesheets = [dictTimesheets objectForKey:szKey];
        
        if (arrTimesheets == nil)
            arrTimesheets = [NSMutableArray array];
        
        [arrTimesheets addObject:oneSheet];
        
        // save timesheets array
        [dictTimesheets setObject:arrTimesheets forKey:szKey];
    }
}

// add timesheets for selected date
- (void)addTimesheets:(NSDate *)date arrSheets:(NSMutableArray *)arrSheets
{
    if (date == nil || arrSheets == nil)
        return;
    
    NSString *szKey = [self keyOfTimesheets:date];
    NSMutableArray *arrTimesheets = [dictTimesheets objectForKey:szKey];
    
    arrTimesheets = [NSMutableArray arrayWithArray:arrSheets];
    
    // save timesheets array
    [dictTimesheets setObject:arrTimesheets forKey:szKey];
}

// get timesheets for selected date
- (NSArray *)getTimesheets:(NSDate *)date
{
    if (date == nil)
        return nil;
    
    NSString *szKey = [self keyOfTimesheets:date];
    NSArray *arrTimesheets = [dictTimesheets objectForKey:szKey];
    
    if (arrTimesheets) {
        NSArray *sortedArray = [arrTimesheets sortedArrayUsingDescriptors:timesheetSortDescriptors];
        return sortedArray;
    }
    
    return arrTimesheets;
}

// remove timesheets for selected date
- (void)removeTimesheets:(NSDate *)date
{
    if (date == nil)
        return;
    
    NSString *szKey = [self keyOfTimesheets:date];
    
    // remove timesheets for date
    [dictTimesheets removeObjectForKey:szKey];
}

// remove timesheets between beginDate and endDate
- (void)removeTimesheets:(NSDate *)beginDate endDate:(NSDate*)endDate
{
    if (beginDate == nil || endDate == nil)
        return;
    
    if ([endDate isEarlierThanDate:beginDate])
        return;
    
    NSDate *date = [[NSDate alloc] initWithTimeInterval:0 sinceDate:beginDate];
    
    do {
        [self removeTimesheets:date];
        
        // next date
        date = [date dateByAddingDays:1];
        
    } while ( ![date isEqualToDateIgnoringTime:endDate] );
    
}

// get timesheets count for date
- (NSUInteger)getTimesheetsCount:(NSDate *)date
{
    NSArray *arrTimesheets = [self getTimesheets:date];
    
    if (arrTimesheets != nil)
        return arrTimesheets.count;
    
    return 0;
}

// get timesheets connection count for date
- (NSUInteger)getTimesheetsConnections:(NSDate *)date
{
    NSArray *arrTimesheets = [self getTimesheets:date];
    NSUInteger nConnections = 0;
    
    if (arrTimesheets != nil) {
        for (TimeSheet *oneSheet in arrTimesheets) {
            if (oneSheet.labourTypeID == kLabourTypeId_Labour)
                nConnections ++;
        }
    }
    
    return nConnections;
}

@end
