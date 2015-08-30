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
    
    
}

@end

@implementation UserContext

@synthesize arrLabourType;
@synthesize arrTimesheetByDate;
@synthesize arrTodayTimesheets;
@synthesize arrUserPins;
@synthesize dictTimesheets;


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
    arrTimesheetByDate = [NSMutableArray array];
    arrTodayTimesheets = [NSMutableArray array];
    arrUserPins = [NSMutableArray array];
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


- (void)initTodayTimesheets:(NSMutableArray *)arrTimeSheets
{
    if (arrTimeSheets == nil) {
        arrTodayTimesheets = [NSMutableArray array];
    }
    else {
        arrTodayTimesheets = [[NSMutableArray alloc] initWithArray:arrTimeSheets];
    }
}


- (void)initUserPinArray:(NSMutableArray *)arrPins
{
    if (arrPins == nil) {
        arrUserPins = [NSMutableArray array];
    }
    else {
        arrUserPins = [[NSMutableArray alloc] initWithArray:arrPins];
    }
}

- (TimeSheet *)getCoveredTimesheet:(NSDate *)pinCreateTime
{
    if (pinCreateTime == nil  || arrTodayTimesheets == nil)
        return nil;
    
    for (NSUInteger i = 0; i < arrTodayTimesheets.count; i++)
    {
        TimeSheet *sheet = [arrTodayTimesheets objectAtIndex:i];
        
        if ( ([pinCreateTime isEqualToDate:sheet.startTime] || [pinCreateTime isLaterThanDate:sheet.startTime])
            && ([pinCreateTime isEqualToDate:sheet.endTime] || [pinCreateTime isEarlierThanDate:sheet.endTime])  )
        {
            return sheet;
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
- (NSMutableArray *)getTimesheets:(NSDate *)date
{
    if (date == nil)
        return nil;
    
    NSString *szKey = [self keyOfTimesheets:date];
    NSMutableArray *arrTimesheets = [dictTimesheets objectForKey:szKey];
    
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
    NSMutableArray *arrTimesheets = [self getTimesheets:date];
    
    if (arrTimesheets != nil)
        return arrTimesheets.count;
    
    return 0;
}




@end
